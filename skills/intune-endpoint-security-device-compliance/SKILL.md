---
name: intune-endpoint-security-device-compliance
description: "Microsoft Intune Endpoint security > Device compliance policy node - the platform-specific rules deciding whether a managed device is compliant, plus the actions when it isn't. Covers rules per platform (OS version, password/PIN, encryption, jailbreak/root, device health/attestation, Defender for Endpoint threat level), actions for noncompliance with grace periods, custom compliance scripts, and how compliance feeds Conditional Access. WHEN: Intune device compliance policy, compliance rules, mark device noncompliant, actions for noncompliance, grace period, minimum OS version, require BitLocker compliance, jailbreak root detection, device threat level, custom compliance script, Windows/macOS/iOS/Android compliance, no compliance policy assigned. DO NOT USE for the Conditional Access policy that enforces the verdict, or device hardening/configuration."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Device compliance

The **Device compliance** node in Intune Endpoint security defines the rules a managed device
must meet to be considered compliant, and the actions Intune takes when it isn't. Compliance is
the **health verdict**; on its own it only reports. Paired with Conditional Access, that verdict
becomes an access gate. This is the signal almost every other access control depends on.

## When to use
Authoring the platform-specific rules that determine device compliance (OS version, encryption,
password, device health, threat level) and configuring what happens to noncompliant devices. Use
this skill to design compliance rules, set sensible grace periods, and produce a clean signal for
Conditional Access.

**Do not use this skill** for the Conditional Access policy that enforces the verdict, or for
device hardening/configuration settings.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Device compliance** (also at **Devices >
Compliance**) **> Create Policy**, then pick the **Platform**. Each platform has its own rule
set. You can assign to user or device groups; assigning to a user evaluates all of that user's
devices (device groups give cleaner reporting).

> **Compliance reports; Conditional Access enforces.** A device marked noncompliant is only
> blocked from resources if a Conditional Access "require compliant device" policy exists. Build
> compliance here, then gate it with a Conditional Access "require compliant device" policy.

## Pick the platform

| Platform | Notable compliance rules |
|---|---|
| **Windows** | Min/max OS version, BitLocker, Secure Boot, code integrity (device health attestation), password/complexity, Defender for Endpoint machine risk score, custom compliance scripts |
| **macOS** | Min/max OS version, FileVault, system integrity, password, firewall, threat level |
| **iOS/iPadOS** | Min/max OS version, jailbreak detection, passcode, threat level (MTD) |
| **Android Enterprise** | OS version, root detection, Play Integrity, encryption, passcode, threat level (MTD/MDE) |
| **Linux** | Distribution/version, encryption, password rules (via the Linux compliance settings) |

## Approach

1. **Start with a minimal, achievable baseline per platform** - require the essentials first
   (supported OS version, encryption, a password/PIN). A baseline most of your fleet already
   meets keeps the rollout from generating a wall of false noncompliance.
   *Verify: a pilot device evaluates Compliant in Intune against the new policy.*

2. **Add device-health and threat rules where licensed** - on Windows, layer BitLocker, Secure
   Boot, and the Defender for Endpoint **machine risk score**; on mobile, jailbreak/root and an
   MTD threat level. These turn compliance from "configured" into "actually healthy."
   *Verify: a device with an elevated Defender risk score flips to Not compliant; a healthy one stays Compliant.*

3. **Set the noncompliance actions with a grace period** - the default **Mark device
   noncompliant** action fires at 0 days (immediate) and can't be removed, but you can change its
   schedule to give users a grace window. Add **Send email to end users** (with a message
   template) early, and reserve harsher actions (remote lock, retire) for later in the schedule.
   *Verify: a noncompliant pilot device gets the email on schedule; the noncompliant mark lands at the configured day, not before.*

4. **Decide the tenant-wide "no policy assigned" behavior** - in Compliance policy settings, set
   *Mark devices with no compliance policy assigned as* to **Not compliant** once compliance is
   broadly deployed, so unevaluated devices don't silently pass.
   *Verify: a device with no compliance policy reports Not compliant.*

5. **Use custom compliance for gaps (Windows)** - when a needed check isn't a built-in setting,
   author a custom compliance **PowerShell discovery script** plus a JSON rules file.
   *Verify: the custom setting reports the expected compliant/noncompliant result on a test device.*

6. **Roll out in rings, then wire Conditional Access** - validate compliance reporting across a
   pilot before enabling the CA gate that acts on it.
   *Verify: compliance dashboard shows expected pass/fail; only then enable the require-compliant CA policy.*

## Guardrails
- **Compliance without Conditional Access only reports.** If you actually want to block
  noncompliant devices, you need a CA policy that requires a compliant device. Don't assume the
  compliance policy alone keeps anyone out.
- **The default mark-noncompliant action is immediate.** It fires at 0 days. If you want a grace
  period before users lose access, change its schedule - and stage email warnings before it.
- **Don't ship an aspirational baseline cold.** A policy half your fleet fails on day one floods
  the helpdesk and (with CA) locks users out. Baseline to current reality, then tighten.
- **Mind compliance vs configuration conflicts.** Some compliance settings can override device
  configuration settings; check conflict resolution when results look wrong.
- **Set "no policy assigned" to Not compliant after rollout.** Leaving it Compliant lets
  unevaluated devices bypass the gate.
- **Third-party-partner devices in device groups can't receive compliance actions** - account
  for that when relying on actions.

## Common anti-patterns
- **"The compliance policy will block noncompliant devices"** - only Conditional Access blocks;
  compliance reports. Pair them.
- **"Strictest possible baseline from the start"** - mass noncompliance and lockouts. Start
  achievable, tighten in rings.
- **"Mark noncompliant immediately with no warning"** - users lose access with no chance to
  remediate. Add a grace period and email warnings.
- **"Left 'no compliance policy assigned' as Compliant"** - unmanaged/unevaluated devices pass
  silently. Flip to Not compliant.
- **"One policy for all platforms"** - compliance is platform-specific; author a policy per
  platform.

## Example prompts
- `Create a Windows compliance policy requiring BitLocker, Secure Boot, and a supported OS version for a pilot ring.`
- `Add a 3-day grace period and an email warning before devices are marked noncompliant.`
- `Use the Defender for Endpoint machine risk score in my Windows compliance policy.`
- `Write a custom compliance script to check a registry value not exposed as a built-in setting.`
- `Why is a device showing compliant when it has no compliance policy assigned?`

## Microsoft Learn
- Device compliance overview: https://learn.microsoft.com/intune/device-security/compliance/overview
- Create a compliance policy: https://learn.microsoft.com/intune/device-security/compliance/create-policy
- Actions for noncompliance: https://learn.microsoft.com/intune/device-security/compliance/configure-noncompliance-actions
- Windows compliance settings reference: https://learn.microsoft.com/intune/device-security/compliance/ref-windows-settings
- Custom compliance (scripts + JSON): https://learn.microsoft.com/intune/device-security/compliance/custom-settings
- Compliance policy settings (no-policy-assigned, etc.): https://learn.microsoft.com/intune/device-security/compliance/create-policy
- Conditional Access integration: https://learn.microsoft.com/intune/device-security/conditional-access-integration/scenarios
