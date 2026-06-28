#Requires -Version 5.1

# Ensure TLS 1.2 for GitHub on Windows PowerShell 5.1
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$skills = @(
    'intune-device-mgmt'
    'intune-app-protection'
    'defender-for-endpoint'
    'defender-for-business'
    'defender-tvm'
    'windows-11-security-baseline'
    'windows-hello'
    'bitlocker-design'
    'macos-intune-baseline'
    'passkeys-fido2'
    'paw-design'
    'defender-for-servers'
    'conditional-access-mfa'
    'entra-id-protection'
    'pki-design'
)

$repo    = 'vinayaklatthe/microsoft-security-skills'
$ref     = 'main'
$treeApi = "https://api.github.com/repos/$repo/git/trees/$ref`?recursive=1"
$rawBase = "https://raw.githubusercontent.com/$repo/$ref"

# Prompt for workspace root
Write-Host ""
$workspaceRoot = (Read-Host "Workspace root").Trim()

if ([string]::IsNullOrWhiteSpace($workspaceRoot)) {
    Write-Warning "No workspace root provided."
    exit 1
}

if (-not (Test-Path $workspaceRoot)) {
    Write-Warning "Workspace root not found: $workspaceRoot"
    exit 1
}

$destSkillsPath = Join-Path $workspaceRoot '.agents\skills'

if (-not (Test-Path $destSkillsPath)) {
    New-Item -ItemType Directory -Path $destSkillsPath -Force | Out-Null
    Write-Host "Created: $destSkillsPath" -ForegroundColor DarkGray
}

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
        $destDir  = Split-Path $destFile -Parent

        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        try {
            Invoke-WebRequest -Uri "$rawBase/$($blob.path)" -OutFile $destFile -UseBasicParsing -ErrorAction Stop
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
$createInstructions = Read-Host "Create workspace instructions file (.github\instructions\device-mgmt-context.instructions.md)? [Y/N]"

if ($createInstructions -match '^[Yy]$') {
    $instructionsDir  = Join-Path $workspaceRoot '.github\instructions'
    $instructionsFile = Join-Path $instructionsDir 'device-mgmt-context.instructions.md'

    if (-not (Test-Path $instructionsDir)) {
        New-Item -ItemType Directory -Path $instructionsDir -Force | Out-Null
    }

    $skillList = $skills -join ', '

    $content = @"
---
applyTo: "**"
---
# Workspace context

This workspace covers Microsoft endpoint management and security across the Microsoft 365 and
Entra stack - device management (Intune), endpoint and server defense (Defender), identity and
access (Conditional Access, Entra ID Protection, passwordless), Windows hardening, and PKI.
It is self-contained - it does not depend on any user-level or global instruction files.

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
    $vscodeDir = Join-Path $workspaceRoot '.vscode'
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
Write-Host "Done." -ForegroundColor Cyan
