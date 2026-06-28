# Intune Endpoint Management Skills

Opinionated [Copilot agent skills](https://code.visualstudio.com/docs/agent-customization/agent-skills)
for **Microsoft Intune endpoint management**. Each skill packages "how to do it right" as an
on-demand procedure that the agent loads only when it is relevant to what you are doing - grounded
in Microsoft Learn, with default-vs-recommended baselines, both portal and PowerShell/Graph paths,
and verification steps.

The first category maps 1:1 to the **Intune Endpoint security** node. Other Intune areas
(enrollment, app management, connectivity) will follow under their own prefixes over time.

## What's included

Eleven standalone skills, one per Endpoint security node:

| Skill | Endpoint security node |
|---|---|
| `intune-endpoint-security-account-protection` | Account protection |
| `intune-endpoint-security-antivirus` | Antivirus |
| `intune-endpoint-security-app-control-for-business` | App Control for Business |
| `intune-endpoint-security-attack-surface-reduction` | Attack surface reduction |
| `intune-endpoint-security-conditional-access` | Conditional access |
| `intune-endpoint-security-device-compliance` | Device compliance |
| `intune-endpoint-security-disk-encryption` | Disk encryption |
| `intune-endpoint-security-endpoint-detection-and-response` | Endpoint detection and response |
| `intune-endpoint-security-endpoint-privilege-management` | Endpoint Privilege Management |
| `intune-endpoint-security-firewall` | Firewall |
| `intune-endpoint-security-security-baselines` | Security baselines |

Each skill is self-contained - no cross-skill dependencies. The agent picks the right one from the
skill's `description`, and each skill states its own scope boundaries.

## Install

Skills are loaded from a `skills/` folder. Drop the skill folders into one of the locations
[VS Code discovers automatically](https://code.visualstudio.com/docs/agent-customization/agent-skills#_skill-locations):

- **Per workspace:** `.github/skills/` in your repo
- **Per user:** `~/.copilot/skills/`

Manual install (per workspace):

```powershell
# from your workspace root
git clone https://github.com/imabdk/intune-endpoint-management-skills.git
New-Item -ItemType Directory -Force -Path .github\skills | Out-Null
Copy-Item -Recurse intune-endpoint-management-skills\skills\intune-endpoint-security-* .github\skills\
```

Then open the workspace in VS Code and confirm the skills appear in the `/` menu in Copilot Chat.

### Scripted install

`Install-EndpointMgmtWorkspace.ps1` sets up a ready-to-use VS Code workspace in one step. It pulls
the 11 skills into `.github\skills\` and can optionally drop in a workspace context instructions
file and pin the Microsoft Learn MCP server - so a fresh workspace has everything wired up for
Copilot out of the box.

```powershell
# prompts for the workspace root, installs from the main branch
.\Install-EndpointMgmtWorkspace.ps1

# or non-interactively, pinned to a release tag
.\Install-EndpointMgmtWorkspace.ps1 -WorkspaceRoot C:\repo -Ref v1.0.0
```

| Parameter | Default | Purpose |
|---|---|---|
| `-WorkspaceRoot` | *(prompted)* | Target workspace root |
| `-Ref` | `main` | Release tag or branch to install from; pin a tag for reproducible installs |
| `-DestSubPath` | `.github\skills` | Skills folder, relative to the workspace root |

## How a skill is built

Every skill follows the same spine so they stay predictable:

1. **Prerequisites** - licensing, roles, platform support
2. **Answer / procedure** - portal and PowerShell/Graph steps
3. **Baseline** - default vs recommended configuration
4. **Verification** - how to confirm it applied
5. **Boundaries** - what the skill does *not* cover

Volatile specifics (CSP values, portal paths, profile names) are validated against Microsoft Learn,
but the portal and CSPs drift - treat them as guidance, not gospel.

## Scope and intent

These are **opinionated procedures, not official Microsoft guidance**. The boundary is managing and
securing Intune endpoints. The Endpoint security set is intentionally completed first so the library
stays curated rather than a drawer of half-finished skills.

## License and attribution

MIT-licensed. This project started from the community project
[vinayaklatthe/microsoft-security-skills](https://github.com/vinayaklatthe/microsoft-security-skills)
(a Microsoft architect's personal, MIT-licensed project - **not** an official Microsoft product).
Reused content keeps its MIT license and credit.

## Author

Martin Bengtsson - [imab.dk](https://imab.dk) - endpoint management & security at Mindcore.
