---
name: intune-endpoint-security-security-baselines
description: "Microsoft Intune Endpoint security > Security baselines node - deploying Microsoft's preconfigured, recommended groups of Windows settings as a starting posture. Covers the baseline types (Security Baseline for Windows / MDM Security Baseline, Defender for Endpoint, Microsoft Edge, Windows 365), versioned instances, customizing vs defaults, the May-2023 format change, version updates (read-only older instances, Update Version), and conflict avoidance. WHEN: Intune security baselines, Windows security baseline, MDM security baseline, Defender for Endpoint baseline, Edge security baseline, Windows 365 baseline, baseline version update, update baseline to latest version, baseline read-only, baseline conflicts, baseline customization, recommended security settings. DO NOT USE for individual standalone endpoint security profiles (antivirus, firewall, attack surface reduction, and similar), or compliance evaluation."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Security baselines

The **Security baselines** node deploys **Microsoft's preconfigured groups of recommended Windows
settings** as a fast starting posture - hundreds of hardening settings with security-team defaults
in one profile. Use a baseline to establish a strong baseline quickly, then customize and layer
specific endpoint-security policies on top.

## When to use
Establishing a recommended security posture from Microsoft defaults (Windows, Defender for
Endpoint, Edge, Windows 365), customizing those defaults, and managing baseline **versions** and
**conflicts** over time.

**Do not use this skill** for individual standalone endpoint-security profiles (antivirus,
firewall, attack surface reduction, and similar), or for compliance evaluation.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Security baselines.** Baselines are
**Windows-focused**. Each baseline is a versioned template; a **baseline profile** is an instance
of a specific baseline version, deployed with defaults or your customizations.

> **A baseline is a starting point, not the whole posture.** It sets recommended defaults across
> many areas at once. Treat it as the floor, then customize and add targeted endpoint-security
> policies - and watch for conflicts where those overlap the baseline.

## Pick the baseline

| Baseline | What it covers |
|---|---|
| **Security Baseline for Windows** (MDM Security Baseline) | Core Windows device hardening - the broad general-purpose baseline |
| **Microsoft Defender for Endpoint baseline** | Recommended Defender for Endpoint protection settings (requires the MDE connection) |
| **Microsoft Edge baseline** | Recommended Edge browser security settings (SmartScreen, typosquatting, etc.) |
| **Windows 365 Security Baseline** | Recommended posture for Cloud PCs |

## Approach

1. **Pick one general baseline as the floor** - start with the Security Baseline for Windows on a
   pilot ring; deploy with defaults first to see the impact before customizing.
   *Verify: pilot devices report the baseline profile applied; per-setting status shows succeeded, not error/conflict.*

2. **Customize only what you must** - edit the profile to change settings that don't fit your
   environment, keeping changes minimal and documented. The baseline is a template of many device
   configuration settings.
   *Verify: customized settings reflect your intended values; the rest remain at Microsoft defaults.*

3. **Map and avoid conflicts** - don't stack multiple baselines on the same devices, and watch for
   overlap with settings catalog, ASR, antivirus, or firewall policies. Overlapping settings with
   different values land in conflict and don't apply.
   *Verify: no settings show a conflict state; a setting is owned by exactly one policy source per device.*

4. **Add product baselines deliberately** - layer Defender for Endpoint or Edge baselines only
   where needed, and check they don't collide with the general Windows baseline or your standalone
   policies.
   *Verify: product baseline settings apply without conflicting against the base Windows baseline.*

5. **Keep baselines on a current version** - older profile instances become **read-only** when a
   new version ships. Use **Update Version**, choosing to keep or discard your customizations, then
   move assignments to the new instance.
   *Verify: the new-version profile is assigned and applying; the old read-only instance has no remaining assignments.*

6. **Retire the old instance cleanly** - remove scope tags and assignments from the original
   baseline so the old and new don't both target the same devices, then delete the old instance
   once it's unassigned.
   *Verify: only the updated baseline instance targets the device group; the superseded instance is unassigned/deleted.*

## Guardrails
- **Deploy one general baseline per device.** Two baselines (or a baseline plus an overlapping
  policy) fighting over the same setting produces conflicts that silently don't apply.
- **Baselines are a starting point.** They set defaults, not a final state - expect to customize
  and to add specific endpoint-security policies, managing the overlap.
- **Mind the version lifecycle.** New versions make old instances read-only. Plan periodic
  **Update Version** runs rather than letting profiles drift on stale versions.
- **Choose keep vs discard customizations deliberately on update.** "Keep customizations" carries
  your edits forward; "discard" resets to the new version's defaults.
- **Clean up superseded instances.** Strip scope tags/assignments from the old baseline before the
  new one goes live so both don't target the same devices, then delete it.
- **Note the May-2023 format change.** Newer baseline versions use the current settings format;
  the last old-format version stays usable side-by-side but gets no new settings/updates.

## Common anti-patterns
- **"Deployed two baselines to the same group"** - guaranteed conflicts. One general baseline per
  device; layer product baselines only where they don't overlap.
- **"Baseline plus a settings-catalog policy both set the same value differently"** - conflict,
  setting doesn't apply. Decide one owner per setting.
- **"Treated the baseline as the entire security config"** - it's the floor. Add antivirus,
  firewall, ASR, EDR, disk encryption as needed.
- **"Left profiles on an old read-only version for years"** - missing newer recommended settings.
  Run Update Version periodically.
- **"Updated to a new version but left the old instance assigned"** - both target the device and
  conflict. Move assignments and retire the old instance.

## Example prompts
- `Deploy the Windows Security Baseline with defaults to a pilot ring and show me how to check per-setting status.`
- `Which baseline settings conflict with my existing antivirus and ASR policies, and how do I resolve them?`
- `Update our Windows security baseline to the latest version and keep our customizations.`
- `What's the difference between the MDM Security Baseline, the Defender for Endpoint baseline, and the Edge baseline?`
- `How do I retire the old baseline instance after updating to a new version without double-targeting devices?`

## Microsoft Learn
- Use security baselines to configure Windows devices in Intune (overview): https://learn.microsoft.com/intune/device-security/security-baselines/overview
- Avoid conflicts: https://learn.microsoft.com/intune/device-security/security-baselines/overview#avoid-conflicts
- Manage security baseline profiles (update versions): https://learn.microsoft.com/intune/device-security/security-baselines/configure-baselines
- Manage endpoint security in Intune: https://learn.microsoft.com/intune/device-security/endpoint-security-policies
