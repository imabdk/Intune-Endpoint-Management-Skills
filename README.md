# Intune Endpoint Management Skills

[Copilot agent skills](https://code.visualstudio.com/docs/agent-customization/agent-skills)
for **Microsoft Intune endpoint management**. Each skill is a procedure the agent loads on demand
when it's relevant, sourced from Microsoft Learn. A skill gives you the recommended configuration,
the portal and PowerShell/Graph steps to apply it, and how to check it worked.

The first category maps 1:1 to the **Intune Endpoint security** node. Other Intune areas
(enrollment, app management, Windows Autopilot, Windows Autopatch) will follow under their own
prefixes over time.

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

`Install-IntuneEndpointMgmtWorkspace.ps1` sets up a VS Code workspace in one step. It pulls
the 11 skills into `.github\skills\` and can optionally drop in a workspace context instructions
file and pin the Microsoft Learn MCP server, so the workspace works without further setup.

```powershell
# prompts for the workspace root, installs the latest skills from main
.\Install-IntuneEndpointMgmtWorkspace.ps1

# or non-interactively
.\Install-IntuneEndpointMgmtWorkspace.ps1 -WorkspaceRoot C:\repo
```

| Parameter | Default | Purpose |
|---|---|---|
| `-WorkspaceRoot` | *(prompted)* | Target workspace root |
| `-DestSubPath` | `.github\skills` | Skills folder, relative to the workspace root |

## Example prompts

You don't call a skill by name - just ask naturally in Copilot Chat and the agent picks the right
one. See [EXAMPLE-PROMPTS.md](EXAMPLE-PROMPTS.md) for sample questions per skill; each prompt has
been verified by me to land on the skill shown.

## License and attribution

MIT-licensed. These skills are original work, authored from scratch against the official
[VS Code Agent Skills documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
and Microsoft Learn. They are **not** an official Microsoft product.

## Author

Martin Bengtsson - [imab.dk](https://imab.dk) - endpoint management & security.
