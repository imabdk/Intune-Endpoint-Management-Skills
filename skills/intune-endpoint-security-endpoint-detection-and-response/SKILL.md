---
name: intune-endpoint-security-endpoint-detection-and-response
description: "Microsoft Intune Endpoint security > Endpoint detection and response (EDR) policy node - onboards devices to Microsoft Defender for Endpoint and manages EDR settings. Covers the Intune-Defender for Endpoint connector dependency, Auto from connector vs manual onboarding packages, platform coverage (Windows, macOS, Linux, Windows Server via settings management / tenant attach), EDR in block mode (Plan 2, passive-mode AV), and the EDR Onboarding Status report. WHEN: Intune EDR policy, endpoint detection and response, onboard Defender for Endpoint, MDE onboarding package, Auto from connector, Defender for Endpoint connector, EDR onboarding status, EDR in block mode, passive remediation, sensor health, device not appearing in Defender portal, offboard Defender. DO NOT USE for next-gen antivirus settings, ASR rules, or MDE licensing/portal setup and advanced hunting."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Endpoint detection and response

The **Endpoint detection and response** node in Intune Endpoint security does one core job:
**onboard devices to Microsoft Defender for Endpoint** so they stream security telemetry for
detection, investigation, and response. It is the bridge between Intune-managed devices and the
Defender for Endpoint sensor - and it depends on the Intune-Defender connector being in place.

## When to use
Onboarding Windows, macOS, and Linux devices to Defender for Endpoint through Intune, managing
EDR profile settings (sample sharing, device tags), and turning on EDR in block mode. Use this
skill to get devices reporting into the Defender portal reliably.

**Do not use this skill** for next-gen antivirus settings, ASR rules, or MDE licensing/portal
setup and advanced hunting.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Endpoint detection and response > Create
Policy**, then pick the **Platform** and **Profile**. EDR policy requires the **Intune-Defender
for Endpoint connector** at **Tenant administration > Connectors and tokens > Microsoft Defender
for Endpoint** (status must be **Connected**).

> **Onboarding is just the front door.** An EDR policy makes a device send telemetry to Defender
> for Endpoint - it does **not** configure antivirus, ASR, or firewall, and it doesn't manage
> hunting rules, custom detections, or automated response. Those live in their own nodes / the
> Defender portal.

## Pick the profile

| Platform | What EDR onboarding covers |
|---|---|
| **Windows** | Onboard/offboard to MDE, sample sharing; quick-deploy via preconfigured policy |
| **macOS** | Onboard to MDE, device tags for filtering/grouping |
| **Linux** | Onboard to MDE, device tags |
| **Windows Server 2012 R2+** | Supported via ConfigMgr tenant attach or MDE security settings management (not standard Intune enrollment) |

## Approach

1. **Connect Intune to Defender for Endpoint first** - at Tenant administration > Connectors and
   tokens, enable the Microsoft Defender for Endpoint connection and confirm it shows
   **Connected** (allow up to ~15 minutes). This unlocks **Auto from connector** onboarding.
   *Verify: the connector status reads Connected; the "Auto from connector" package option appears in EDR policy.*

2. **Use Auto from connector for onboarding** - create the EDR policy with the Microsoft Defender
   for Endpoint client configuration **package type = Auto from connector**, so Intune always uses
   the latest onboarding package. Reserve **manual** package download (from the Defender portal)
   for air-gapped, multi-tenant, or strict-change-control scenarios.
   *Verify: a pilot device onboards; it appears in the Defender portal device inventory with healthy sensor status.*

3. **Quick-deploy to Windows when appropriate** - the preconfigured policy on the **EDR
   Onboarding Status** tab pushes the latest package with recommended settings to all Windows
   devices fast; use Create Policy when you need per-group/per-platform control.
   *Verify: EDR Onboarding Status shows the targeted devices onboarded.*

4. **Avoid onboarding conflicts** - onboard through **one** mechanism. Don't onboard the same
   device with both a device configuration profile and an EDR policy (and note device
   configuration onboarding doesn't support tenant-attached devices).
   *Verify: no policy-conflict errors on the device; a single onboarding source is in effect.*

5. **Enable EDR in block mode where it fits** - block mode (Defender for Endpoint **Plan 2**) is
   primarily for devices running Defender Antivirus in **passive mode** (a third-party AV is
   active). Set it tenant-wide in the Defender portal, or per device group via the Defender CSP
   (PassiveRemediation).
   *Verify: block mode shows enabled; a known-bad artifact missed by the third-party AV is remediated by Defender.*

6. **Monitor onboarding and roll out in rings** - watch the EDR Onboarding Status report and
   Defender sensor health through pilot > broad; resolve devices that don't appear (check
   connectivity to the Defender service endpoints).
   *Verify: onboarding success rate and sensor health are green across the ring before expanding.*

## Guardrails
- **No connector, no Auto from connector.** EDR policy depends on the Intune-Defender connection;
  set it up and confirm Connected before building policy.
- **Onboard once.** Onboarding a device through both device configuration and EDR policy creates
  conflicts. Pick one source per device.
- **EDR onboarding ≠ protection config.** Onboarding only starts telemetry. You still need
  Antivirus, ASR, and Firewall policies for actual protection.
- **EDR in block mode needs Plan 2 and suits passive-mode AV.** Don't enable it expecting it to
  replace a properly configured primary Defender Antivirus.
- **Windows Server isn't standard Intune onboarding.** Use ConfigMgr tenant attach or MDE
  security settings management for servers.
- **If devices don't appear, check connectivity.** Missing devices usually can't reach the
  Defender service endpoints, or the sensor service isn't running.

## Common anti-patterns
- **"Created the EDR policy before connecting the connector"** - no Auto from connector, and a
  stale/manual package. Connect first.
- **"Onboarded with both a device config profile and EDR policy"** - policy conflict; devices
  flap. One onboarding source.
- **"Devices are onboarded, so they're protected"** - onboarding is telemetry only. Add AV/ASR/
  firewall policies.
- **"Turned on EDR in block mode as the primary AV strategy"** - it's a safety net for passive-
  mode/third-party-AV devices, not a substitute for configured Defender AV.
- **"Tried to onboard Windows Server via standard Intune enrollment"** - use tenant attach or MDE
  security settings management.

## Example prompts
- `Connect Intune to Defender for Endpoint and create an EDR onboarding policy using Auto from connector for a pilot ring.`
- `Quick-deploy EDR onboarding to all Windows devices using the preconfigured policy.`
- `Some devices aren't showing in the Defender portal after onboarding - how do I troubleshoot?`
- `Enable EDR in block mode for devices running Defender Antivirus in passive mode.`
- `How do I onboard macOS and Linux devices to Defender for Endpoint through Intune?`

## Microsoft Learn
- Deploy EDR policy with Intune: https://learn.microsoft.com/intune/device-configuration/endpoint-security/deploy-edr
- Connect Defender for Endpoint to Intune: https://learn.microsoft.com/intune/device-security/microsoft-defender/configure-integration
- Onboard devices to Microsoft Defender for Endpoint: https://learn.microsoft.com/defender-endpoint/onboarding
- EDR in block mode: https://learn.microsoft.com/defender-endpoint/edr-in-block-mode
- Defender CSP (PassiveRemediation): https://learn.microsoft.com/windows/client-management/mdm/defender-csp
- Manage endpoint security policies in Defender for Endpoint: https://learn.microsoft.com/defender-endpoint/manage-security-policies
