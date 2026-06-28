#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Intune Endpoint security Copilot agent skills into a workspace.

.DESCRIPTION
    Downloads the intune-endpoint-security-* skills from
    github.com/imabdk/intune-endpoint-management-skills into a target workspace's
    skills folder (.github\skills by default) so VS Code Copilot can load them.
    Optionally creates a workspace instructions file and pins the Microsoft Learn
    MCP server.

.PARAMETER WorkspaceRoot
    Target workspace root. Prompted for if not supplied.

.PARAMETER DestSubPath
    Skills folder relative to the workspace root. Defaults to '.github\skills',
    the location VS Code discovers automatically.

.EXAMPLE
    .\Install-EndpointMgmtWorkspace.ps1
    Prompts for the workspace root and installs the latest skills from main.

.EXAMPLE
    .\Install-EndpointMgmtWorkspace.ps1 -WorkspaceRoot C:\repo
#>
[CmdletBinding()]
param(
    [string]$WorkspaceRoot,
    [string]$DestSubPath = '.github\skills'
)

# Ensure TLS 1.2 for GitHub on Windows PowerShell 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$skills = @(
    'intune-endpoint-security-account-protection'
    'intune-endpoint-security-antivirus'
    'intune-endpoint-security-app-control-for-business'
    'intune-endpoint-security-attack-surface-reduction'
    'intune-endpoint-security-conditional-access'
    'intune-endpoint-security-device-compliance'
    'intune-endpoint-security-disk-encryption'
    'intune-endpoint-security-endpoint-detection-and-response'
    'intune-endpoint-security-endpoint-privilege-management'
    'intune-endpoint-security-firewall'
    'intune-endpoint-security-security-baselines'
)

$repo    = 'imabdk/intune-endpoint-management-skills'
$treeApi = "https://api.github.com/repos/$repo/git/trees/main`?recursive=1"
$rawBase = "https://raw.githubusercontent.com/$repo/main"

# Resolve workspace root (prompt if not supplied)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    Write-Host ""
    $WorkspaceRoot = (Read-Host "Workspace root").Trim()
}

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    Write-Warning "No workspace root provided."
    exit 1
}

if (-not (Test-Path $WorkspaceRoot)) {
    Write-Warning "Workspace root not found: $WorkspaceRoot"
    exit 1
}

$WorkspaceRoot  = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$destSkillsPath = Join-Path $WorkspaceRoot $DestSubPath

if (-not (Test-Path $destSkillsPath)) {
    New-Item -ItemType Directory -Path $destSkillsPath -Force | Out-Null
    Write-Host "Created: $destSkillsPath" -ForegroundColor DarkGray
}

# Canonical destination root for the path-traversal guard (trailing separator)
$destSkillsRoot = (Resolve-Path -LiteralPath $destSkillsPath).Path.TrimEnd('\') + '\'

# Fetch the full repo tree in a single API call
Write-Host ""
Write-Host "Fetching repository tree..." -ForegroundColor DarkGray
try {
    $tree = (Invoke-RestMethod -Uri $treeApi -Headers @{ 'User-Agent' = 'skills-installer' } -ErrorAction Stop).tree
}
catch {
    Write-Warning "Failed to fetch repository tree: $($_.Exception.Message)"
    exit 1
}

Write-Host ""

# Download each skill (all files under skills/<skill>/, any depth)
$downloaded = 0
$failed     = 0
$notFound   = 0

foreach ($skill in $skills) {
    $prefix = "skills/$skill/"
    $blobs  = $tree | Where-Object { $_.type -eq 'blob' -and $_.path -like "$prefix*" }

    if (-not $blobs) {
        Write-Host "  Not found   $skill (no files under $prefix)" -ForegroundColor Yellow
        $notFound++
        continue
    }

    $fileCount = 0
    $skillOk   = $true

    foreach ($blob in $blobs) {
        $relative = $blob.path.Substring('skills/'.Length)        # <skill>/...
        $destFile = Join-Path $destSkillsPath ($relative -replace '/', '\')

        # Path-traversal guard: never write outside the skills folder
        $fullDest = [System.IO.Path]::GetFullPath($destFile)
        if (-not $fullDest.StartsWith($destSkillsRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Host "  Skipped     $($blob.path) (path escapes destination)" -ForegroundColor Red
            $skillOk = $false
            continue
        }

        $destDir = Split-Path $fullDest -Parent
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        try {
            Invoke-WebRequest -Uri "$rawBase/$($blob.path)" -OutFile $fullDest -UseBasicParsing -ErrorAction Stop
            $fileCount++
        }
        catch {
            Write-Host "  Failed      $($blob.path) ($($_.Exception.Message))" -ForegroundColor Red
            $skillOk = $false
        }
    }

    if ($skillOk) {
        Write-Host "  Downloaded  $skill ($fileCount file$(if ($fileCount -ne 1) {'s'}))" -ForegroundColor Green
        $downloaded++
    }
    else {
        $failed++
    }
}

Write-Host ""
Write-Host "$downloaded skills downloaded to $destSkillsPath" -ForegroundColor Cyan
if ($notFound -gt 0) {
    Write-Host "$notFound skills not found in the repo - check the skill names." -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host "$failed skills had one or more file failures - see above." -ForegroundColor Yellow
}

# Optionally create workspace instructions file
Write-Host ""
$createInstructions = Read-Host "Create workspace instructions file (.github\instructions\intune-endpoint-security-context.instructions.md)? [Y/N]"

if ($createInstructions -match '^[Yy]$') {
    $instructionsDir  = Join-Path $WorkspaceRoot '.github\instructions'
    $instructionsFile = Join-Path $instructionsDir 'intune-endpoint-security-context.instructions.md'

    if (-not (Test-Path $instructionsDir)) {
        New-Item -ItemType Directory -Path $instructionsDir -Force | Out-Null
    }

    $skillList = $skills -join ', '

    $content = @"
---
applyTo: "**"
---
# Workspace context

This workspace covers the Microsoft Intune Endpoint security node - antivirus, disk encryption,
firewall, attack surface reduction, endpoint detection and response, account protection, app
control, endpoint privilege management, device compliance, conditional access, and security
baselines. It is self-contained - it does not depend on any user-level or global instruction
files.

When answering questions, apply guidance from any of the available skills where relevant:
$skillList.

## Documentation rules

- Always use the Microsoft Learn (MCP) tools for product specifics - never rely solely on
  training knowledge.
- URL provided -> fetch it directly. Topic provided -> search Microsoft Learn first, then fetch
  the relevant article. Code or config example needed -> search Microsoft Learn code samples.
- Cite sources with full URLs and flag anything that looks outdated.
- If the MCP tools cannot answer, fall back to general knowledge and say so explicitly - state
  that the answer is not sourced from official documentation.

## Precedence

The workspace skills are authoritative for design and decision guidance (architecture choices,
recommended defaults, rollout approach). Use Microsoft Learn (MCP) to validate version-specific
details, exact setting paths, and licensing - and to fill gaps the skills don't cover. When a
skill already answers the design question, treat it as sufficient and reach for documentation
only to confirm volatile specifics.

## Response shape

Lead with prerequisites, then a direct answer verified against documentation, then sources (with
URLs), then practical considerations (pitfalls, licensing, security implications). For
implementation tasks, give both portal and PowerShell steps and the default-vs-recommended
baseline. Omit sections that add no value to simple factual questions.
"@

    Set-Content -Path $instructionsFile -Value $content -Encoding UTF8
    Write-Host "Created: $instructionsFile" -ForegroundColor Green
}

# Optionally pin the Microsoft Learn MCP server for this workspace (.vscode\mcp.json)
Write-Host ""
$createMcp = Read-Host "Pin the Microsoft Learn MCP server for this workspace (.vscode\mcp.json)? [Y/N]"

if ($createMcp -match '^[Yy]$') {
    $vscodeDir = Join-Path $WorkspaceRoot '.vscode'
    if (-not (Test-Path $vscodeDir)) {
        New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    }

    $mcpFile = Join-Path $vscodeDir 'mcp.json'

    if (Test-Path $mcpFile) {
        Write-Warning "Already exists, not overwriting: $mcpFile"
        Write-Host "  Add the 'microsoft-learn' server manually if it's missing." -ForegroundColor DarkGray
    }
    else {
        $mcpContent = @'
{
  "servers": {
    "microsoft-learn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
'@
        Set-Content -Path $mcpFile -Value $mcpContent -Encoding UTF8
        Write-Host "Created: $mcpFile" -ForegroundColor Green
        Write-Host "  Reload VS Code; you'll be prompted to trust the server on first start." -ForegroundColor DarkGray
    }
}

Write-Host ""
if ($failed -gt 0 -or $notFound -gt 0) {
    Write-Host "Done with issues - see warnings above." -ForegroundColor Yellow
    exit 1
}
Write-Host "Done." -ForegroundColor Cyan
exit 0
