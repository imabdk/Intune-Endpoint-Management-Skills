---
name: intune-endpoint-security-attack-surface-reduction
description: "Microsoft Intune Endpoint security > Attack surface reduction policy node - the Windows surface for Defender ASR rules, controlled folder access, exploit protection, device control, network protection, and app/browser isolation. Covers ASR rule modes (Audit/Block/Warn), audit-then-block rollout, and global vs per-rule superset exclusions. WHEN: Intune attack surface reduction policy, ASR rules, Defender ASR, controlled folder access, CFA, exploit protection, device control, network protection, removable storage access control, ASR audit/block/warn, ASR rule exclusions, standard protection rules, app and browser isolation. DO NOT USE for core Defender Antivirus settings and AV exclusions, EDR onboarding / block mode, or WDAC application allowlisting."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Attack surface reduction

The **Attack surface reduction** node in Intune Endpoint security is where you shrink the ways
malware can get a foothold on Windows: the Defender **ASR rules**, **controlled folder access**,
**exploit protection**, **device control**, and **app and browser isolation**. These are
high-value, high-blast-radius controls - run them in audit before you enforce, or you will block
legitimate business activity.

## When to use
Configuring **Endpoint security > Attack surface reduction** policies in Intune: turning on ASR
rules, controlled folder access, exploit protection, and device control on Windows, and managing
their exclusions. Use this skill to pick the profile, choose the right rule mode, and roll out
from audit to block.

**Do not use this skill** for core Defender Antivirus settings or AV exclusions, EDR onboarding
or block mode, or WDAC application allowlisting.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Attack surface reduction > Create Policy >
Platform: Windows**, then pick the **Profile**. ASR is part of Defender for Endpoint management,
which **supports device objects only** - assign policies to Entra **device** groups, not user
groups.

> **Application control here is deprecated.** The old Application Control profile under Attack
> surface reduction is being retired - configure application allowlisting in the **App Control
> for Business** node instead.

## Pick the profile

| Profile | What it manages |
|---|---|
| **Attack Surface Reduction Rules** | The ASR rules, plus controlled folder access (CFA) settings and ASR rule exclusions |
| **Device control** | Removable storage / device access control, often via reusable settings groups |
| **Exploit protection** | System and per-app exploit mitigations (XML-defined) |
| **App and browser isolation** | Microsoft Defender Application Guard hardware-isolated browsing |
| **Web protection** | Network protection / web threat blocking (legacy profile; network protection is the forward path) |

## Approach

1. **Start ASR rules in Audit mode** - set the standard protection rules (and any others you
   want) to **Audit** first. ASR rules block common malware techniques, but several also catch
   legitimate tooling and macros. Audit collects "would block" data without breaking anything.
   *Verify: Defender portal / advanced hunting shows ASR audit events for the rules, with no blocks.*

2. **Review audit data, then move rules to Block** - promote rules to **Block** (or **Warn**
   for user-bypassable cases) once audit shows no legitimate impact. Microsoft's standard
   protection rules are the safe baseline to enforce first.
   *Verify: pilot devices run their full workload; ASR block events only for genuinely unwanted behavior.*

3. **Prefer exclusions over disabling a rule** - if a rule causes a false positive, add a
   targeted file/folder exclusion rather than turning the rule off or leaving it in audit. Use
   **per-rule** exclusions for a single rule, or **global** exclusions only when you truly mean
   all rules.
   *Verify: the excluded app runs; the rule still blocks everything else.*

4. **Enable controlled folder access in audit, then on** - CFA (in the ASR Rules profile)
   protects folders from unauthorized changes (ransomware). Run it in **Audit Mode**, allow the
   apps that legitimately write to protected folders, then set it to **Enabled**.
   *Verify: CFA audit events show which apps would be blocked; after allowing them, no legitimate writes are blocked.*

5. **Layer device control and exploit protection** - use the Device control profile (reusable
   settings groups) for removable storage, and Exploit protection for system/app mitigations.
   Treat each as its own audited rollout.
   *Verify: a test USB device is governed as intended; exploit-protection mitigations report applied.*

6. **Roll out in rings** - pilot > broad. ASR has a wide blast radius; never enforce tenant-wide
   from a cold start.
   *Verify: each ring validates real workloads before the next ring enforces.*

## Guardrails
- **Audit before block.** Every ASR rule and CFA should run in audit first. Going straight to
  block is the fastest way to break macros, installers, and LOB tooling.
- **Exclusions are a superset across policies.** Global **Attack Surface Reduction Only
  Exclusions** from every applicable policy merge and apply to all ASR rules on the device - you
  can't scope a global exclusion to one policy. Use per-rule exclusions when you mean one rule.
- **ASR is device-scoped.** Assign to Entra device groups. User-group assignment does not apply.
- **Exclusions beat disabling.** A targeted exclusion keeps the rule protecting everything else;
  disabling or parking a rule in audit removes the protection entirely.
- **Watch the "disable admin merge" interaction.** With local admin merge disabled, per-rule and
  local ASR exclusions don't apply - plan exclusions centrally.
- **Server enforcement caveat.** There's a known issue where ASR can show compliant on Server OS
  without actually enforcing - don't assume servers are protected by an ASR policy alone.

## Common anti-patterns
- **"Set all ASR rules to Block on day one"** - guaranteed false positives on macros and
  installers. Audit, review, then block.
- **"A rule caused a false positive, so I disabled it"** - you lost the protection. Add a
  targeted exclusion instead.
- **"One global exclusion for this one rule"** - global exclusions hit every rule on the device.
  Use a per-rule exclusion for single-rule problems.
- **"Enabled controlled folder access straight to On"** - blocks legitimate apps that write to
  Documents/Desktop. Audit, allow the apps, then enable.
- **"Assigned the ASR policy to a user group"** - ASR is device-only; it won't apply.
- **"Configured application control here"** - that profile is deprecated; use the App Control
  for Business node.

## Example prompts
- `Create an Intune ASR policy with the standard protection rules in audit mode for a pilot ring.`
- `An ASR rule is blocking our line-of-business macro - add a per-rule exclusion instead of disabling it.`
- `Move my audited ASR rules to block and roll out pilot to broad.`
- `Turn on controlled folder access in audit and allow our backup agent before enforcing.`
- `Why are ASR exclusions from another policy applying to devices I didn't target?`

## Microsoft Learn
- Attack surface reduction policy (Intune Endpoint security): https://learn.microsoft.com/intune/device-configuration/endpoint-security/attack-surface-reduction
- ASR policy settings reference (Intune): https://learn.microsoft.com/intune/device-configuration/endpoint-security/ref-attack-surface-reduction-settings
- ASR rules overview and reference: https://learn.microsoft.com/defender-endpoint/attack-surface-reduction-rules-overview
- Configure ASR rules and exclusions: https://learn.microsoft.com/defender-endpoint/attack-surface-reduction-rules-configure
- ASR rules deployment and testing (audit to enforce): https://learn.microsoft.com/defender-endpoint/attack-surface-reduction-rules-deployment
- Controlled folder access configuration: https://learn.microsoft.com/defender-endpoint/controlled-folder-access-configure
- Device control overview: https://learn.microsoft.com/defender-endpoint/device-control-report
