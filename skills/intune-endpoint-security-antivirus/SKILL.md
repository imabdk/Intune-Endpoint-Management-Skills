---
name: intune-endpoint-security-antivirus
description: "Microsoft Intune Endpoint security > Antivirus policy node - the configuration surface for Microsoft Defender Antivirus across Windows, macOS, and Linux (and Windows Server via Defender security settings management). Profiles: Defender Antivirus, Antivirus exclusions, Windows Security experience, Defender Update controls, macOS/Linux Antivirus. WHEN: Intune Antivirus policy, endpoint security antivirus, Microsoft Defender Antivirus profile, Defender AV settings, Windows Security experience, Defender Update controls, update channel, antivirus exclusions, cloud-delivered protection, PUA blocking, real-time protection, macOS/Linux Defender antivirus, tamper protection, passive mode. DO NOT USE for ASR rules and controlled folder access, EDR onboarding / block mode, or MDE plan selection and onboarding."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Antivirus

The **Antivirus** node in Intune Endpoint security is the focused configuration surface for
**Microsoft Defender Antivirus**. Each profile carries only the settings relevant to antivirus
(or to the Windows Security app experience), so you manage the AV workload without wading
through the unrelated settings bundled into device-restriction or endpoint-protection templates.
It covers **Windows, macOS, and Linux**, plus **Windows Server** through the Defender for
Endpoint security settings management scenario.

## When to use
Configuring **Endpoint security > Antivirus** policies: Defender AV protection settings, the
Windows Security app experience, Defender update channels, and antivirus exclusions, across
Windows, macOS, and Linux. Use this skill to pick the right profile, set sensible values, and
roll it out in rings.

**Do not use this skill** for ASR rules and controlled folder access rollout, EDR onboarding
or block mode, or MDE plan selection and device onboarding.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Antivirus > Create Policy**, then pick
the **Platform** (Windows, macOS, Linux) and the **Profile**. The same Windows settings are
also available in the **Settings catalog**, but the Antivirus node keeps them scoped to just AV.

> The macOS Antivirus profile replaces the need to hand-author `.plist` configuration files.
> Windows Server is configured through the Defender for Endpoint **security settings
> management** scenario, not standard Intune enrollment.

## Pick the profile

| Platform | Profile | What it manages |
|---|---|---|
| Windows | **Microsoft Defender Antivirus** | Core AV: real-time protection, cloud-delivered protection, PUA, scans, remediation, exclusions |
| Windows | **Microsoft Defender Antivirus exclusions** | A standalone exclusions-only profile so you can delegate exclusion management separately |
| Windows | **Windows Security experience** | What end users see in the Windows Security app and which notifications they get; tamper protection lives here |
| Windows | **Defender Update controls** | Engine, platform, and security intelligence update channels (from the Defender CSP) for staged update rollout |
| macOS | **Antivirus** / **Antivirus exclusions** | Defender AV settings (replaces `.plist`) and a separate exclusions profile |
| Linux | **Microsoft Defender Antivirus** / **Antivirus exclusions** | Defender AV settings and a separate path/extension/process exclusions profile |

## Approach

1. **Set the core Microsoft Defender Antivirus profile (Windows)** - real-time protection on,
   cloud-delivered protection on (raise the block level for high-risk groups), PUA protection
   in **audit first, then block**, scheduled scan plus on-access, and a sane remediation action.
   Keep exclusions out of this profile if you intend to delegate them (see step 3).
   *Verify: `Get-MpComputerStatus` on a pilot device shows `AMServiceEnabled`, `RealTimeProtectionEnabled`, and `AntivirusEnabled` all True.*

2. **Enable Tamper Protection via the Windows Security experience profile** - do this early.
   Without tamper protection, every other AV setting is advisory: local admins and malware can
   switch protection off. Use the Windows Security experience profile to also control which
   notifications and Security app areas users see.
   *Verify: device shows Tamper Protection On in the Windows Security app / Defender portal.*

3. **Manage exclusions in the dedicated Antivirus exclusions profile** - keep exclusions out of
   the main AV profile so you can scope and delegate them to the team that owns the line-of-
   business app, without granting full AV-policy rights. Exclude only known-good paths,
   extensions, or processes. Remember exclusions from multiple sources (AV profile, exclusions
   profile, and on Linux the EDR Global Exclusions AV+EDR profile) **merge into a superset** on
   the device.
   *Verify: `Get-MpPreference` shows only the intended `ExclusionPath`/`ExclusionProcess` entries.*

4. **Stage Defender updates with the Defender Update controls profile** - set the **Engine**,
   **Platform**, and **Security intelligence** update channels to build rings (e.g. a small
   pilot on a faster/staged channel, the broad estate on the Broad channel) so a bad definition
   or platform update doesn't hit everyone at once.
   *Verify: pilot devices report the assigned channel; platform/engine versions advance ahead of the broad ring.*

5. **Configure macOS and Linux separately** - use the platform-specific Antivirus and Antivirus
   exclusions profiles. On macOS this replaces `.plist` authoring; on Linux, path/extension/
   process exclusions also merge with any Defender Global Exclusions (AV+EDR) policy.
   *Verify: `mdatp health` on macOS/Linux shows real-time protection enabled and definitions current.*

6. **Roll out in rings** - pilot > broad, like every endpoint security policy. Validate against
   real workloads (installers, LOB apps, dev tooling) before tenant-wide assignment.

## Guardrails
- **Tamper protection first, or nothing else sticks.** Set it via the Windows Security
  experience profile before relying on any other AV setting.
- **Every exclusion lowers protection.** Treat exclusions as a deliberate, audited exception -
  broad path or process exclusions are a classic attacker persistence gap. Only exclude files
  you know aren't malicious.
- **Exclusions merge into a superset across profiles.** A device gets the union of exclusions
  from the AV profile, the exclusions profile, and (Linux) the EDR Global Exclusions policy -
  don't assume a single profile is the whole picture.
- **Don't run two active AV engines.** Either Defender is primary, or set Defender to **passive
  mode** with EDR block mode on. Two real-time engines fight and degrade performance.
- **Update channels are for staged rollout, not "fastest everywhere."** Putting the whole
  estate on a preview/staged channel removes the safety of catching a bad update in a pilot ring.
- **Windows Server goes through security settings management.** Don't expect the standard
  Windows enrollment profiles to apply to servers - they're managed via the Defender for
  Endpoint security settings management scenario.

## Common anti-patterns
- **"PUA straight to block on day one"** - audit first; PUA blocking can catch bundled installers
  and legitimate tooling. Audit, review, then block.
- **"Exclusions live in the main AV profile"** - couples exclusion management to full AV-policy
  rights and hides them. Use the dedicated Antivirus exclusions profile so they're delegable and visible.
- **"Add a broad folder exclusion to make the LOB app work"** - `C:\` or a whole user profile
  excluded is an open door. Scope to the exact file/process, and document why.
- **"All devices on the same Defender update channel"** - no pilot ring means a bad definition
  hits everyone. Stage engine/platform/intelligence channels.
- **"Defender plus a third-party AV both active"** - set the non-Microsoft AV to passive or set
  Defender to passive mode with EDR block mode; never two active engines.
- **"Configured ASR / controlled folder access here"** - those belong in the Attack surface
  reduction node, not the Antivirus profile.

## Example prompts
- `Create an Intune Microsoft Defender Antivirus profile with cloud-delivered protection and PUA in audit for a pilot ring.`
- `Set up a standalone Antivirus exclusions profile so the app team can manage their own exclusions.`
- `Stage Defender platform and security intelligence updates so a pilot ring gets them before the broad estate.`
- `Enable tamper protection through the Windows Security experience profile.`
- `Configure Microsoft Defender Antivirus for macOS in Intune instead of using a .plist.`
- `Why are exclusions I removed from one policy still applying on the device?`

## Microsoft Learn
- Antivirus policy overview: https://learn.microsoft.com/intune/device-configuration/endpoint-security/antivirus
- Antivirus profiles (per platform): https://learn.microsoft.com/intune/device-configuration/endpoint-security/antivirus#antivirus-profiles
- Manage endpoint security policies: https://learn.microsoft.com/intune/device-configuration/endpoint-security/manage-policies
- Defender CSP (update channels): https://learn.microsoft.com/windows/client-management/mdm/defender-csp
- Defender AV exclusions overview: https://learn.microsoft.com/defender-endpoint/navigate-defender-endpoint-antivirus-exclusions
- Tamper protection: https://learn.microsoft.com/defender-endpoint/prevent-changes-to-security-settings-with-tamper-protection
- Defender for Endpoint security settings management (servers): https://learn.microsoft.com/intune/device-security/microsoft-defender/security-settings-management
- Linux exclusions: https://learn.microsoft.com/defender-endpoint/linux-exclusions
- macOS exclusions: https://learn.microsoft.com/defender-endpoint/mac-exclusions
