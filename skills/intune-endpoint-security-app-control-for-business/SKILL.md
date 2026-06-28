---
name: intune-endpoint-security-app-control-for-business
description: "Microsoft Intune Endpoint security > App Control for Business policy node - the Intune surface for Windows Defender Application Control (WDAC) application allowlisting on Windows. Two tabs (App Control policy, Managed installer); built-in controls vs custom XML; Intune Management Extension as managed installer; audit-then-enforce. WHEN: Intune App Control for Business, App Control policy, WDAC Intune, Windows Defender Application Control, application allowlisting, managed installer, Intune Management Extension managed installer, trust apps with good reputation, Intelligent Security Graph ISG, built-in controls, App Control XML, supplemental policy, AllowAll policy removal, ApplicationControl CSP, audit mode. DO NOT USE for ASR rules / controlled folder access, AppLocker-only or app packaging, or per-app run-as-admin elevation."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - App Control for Business

The **App Control for Business** node in Intune Endpoint security is the deployment surface for
**Windows Defender Application Control (WDAC)** - the strongest application control Windows
offers. Instead of blocking known-bad, it does the opposite: only code you explicitly trust is
allowed to run. This is the application allowlisting layer of endpoint security, Windows-only,
and it is unforgiving if rolled out without an audit phase.

## When to use
Configuring **Endpoint security > App Control for Business** policies in Intune: defining which
apps are allowed to run on Windows devices via built-in trust controls or custom WDAC XML, and
tagging Intune-deployed apps as trusted through the managed installer. Use this skill to choose
the right trust model, run audit before enforce, and remove policies safely.

**Do not use this skill** for ASR rules and controlled folder access, app packaging/deployment,
or per-app run-as-admin elevation.

## Where it lives

**Microsoft Intune admin center > Endpoint security > App Control for Business**, which has two
tabs: the **App Control for Business** tab (create the WDAC policy) and the **Managed installer**
tab (set the Intune Management Extension as a managed installer). WDAC policies apply to the
**device scope only** - assign them to device groups, not user groups.

> **Order matters:** set up the managed installer **before** you deploy apps you want trusted.
> There is no retroactive tagging - apps installed before the managed installer was enabled are
> not tagged, so an enforced policy will block them unless you explicitly allow them.

## Pick the profile

| Tab / profile | What it manages | When to use |
|---|---|---|
| **App Control for Business** (built-in controls) | Trust Windows components + Store apps, optionally trust apps with good reputation (ISG) and/or apps from managed installers; supports Audit only | Most tenants - no XML authoring required |
| **App Control for Business** (Enter xml data) | A full custom WDAC policy uploaded as XML | Granular allowlisting beyond the built-in toggles |
| **Managed installer** | Sets the Intune Management Extension as a managed installer so Intune-deployed apps are tagged as trusted | Enable first, so "trust apps from managed installers" actually trusts your app deployments |

## Approach

1. **Enable the managed installer first** - on the Managed installer tab, create a policy that
   sets *Enable Intune Managed Extension as Managed Installer* to **Enabled** and assign it to
   your device groups. From then on, apps Intune deploys are tagged as installed by a known
   source.
   *Verify: a newly Intune-deployed app on a pilot device is tagged; AppLocker managed installer events appear in the local event log.*

2. **Create the App Control policy in Audit only first** - use built-in controls: keep *Enable
   trust of Windows components and Store apps* enabled and add *Trust apps from managed
   installers* (and optionally *Trust apps with good reputation* / ISG). Set it to **Audit
   only** so nothing is blocked yet.
   *Verify: CodeIntegrity audit events list apps that would be blocked, without blocking them.*

3. **Review audit events and close the gaps** - find apps that ran but were not tagged
   (anything installed before the managed installer, or sideloaded). Decide what to trust and
   add a supplemental policy (custom XML referencing the base PolicyID) for the rest.
   *Verify: re-running the workload produces no unexpected "would block" audit events.*

4. **Switch to enforce, in rings** - only after audit is clean, flip the policy from Audit only
   to enforced and roll pilot > broad. A premature enforce is how you break a fleet.
   *Verify: pilot users run their full app set; no legitimate app is blocked; CodeIntegrity shows enforced mode.*

5. **Use supplemental policies for team-specific apps** - expand a base policy with supplemental
   policies (XML, referencing the base PolicyID) scoped by assignment, so the Executive and
   Help Desk groups can each trust their own extra apps off the same base.
   *Verify: each group can run its supplemental apps; other groups cannot.*

## Guardrails
- **Audit before enforce, always.** App Control blocks everything not trusted. Run Audit only,
  review CodeIntegrity events, and close gaps before enforcing - or you will block legitimate
  apps fleet-wide.
- **Managed installer is not retroactive.** Apps present before you enabled it are untagged.
  Plan to allow them explicitly (supplemental policy) or reinstall them through Intune.
- **Remove policies the safe way.** Before deleting an App Control policy, deploy a replacement
  that allows everything (the `AllowAll.xml` pattern) so no blocks linger; policies stay in
  effect until the next reboot. Deleting straight away can leave a device blocking apps.
- **Mind boot-stop failures on unenrollment.** Before unenrolling a device that received App
  Control policies, follow Microsoft's removal steps - improper removal can cause boot-stop
  failures.
- **WDAC is device-scoped.** Assign to device groups. User-group assignment does not apply WDAC.

## Common anti-patterns
- **"Enforce on day one"** - without an audit phase you will block line-of-business apps the
  moment the policy lands. Audit, review, then enforce.
- **"Enable the policy, then set up the managed installer later"** - apps deployed in between
  are untagged and get blocked. Managed installer first, then the trust policy.
- **"Just delete the policy to roll back"** - leaves blocks in place until reboot and risks
  boot-stop issues. Deploy an allow-all replacement first, then delete.
- **"Trust apps with good reputation means I don't need anything else"** - ISG helps with common
  reputable apps but won't cover your internal LOB apps; pair it with the managed installer or a
  supplemental policy.
- **"Configured app control under Attack surface reduction"** - the old Application Control
  policy under ASR is deprecated; use the App Control for Business node.

## Example prompts
- `Set up the Intune Management Extension as a managed installer, then an audit-mode App Control for Business policy that trusts managed installers.`
- `My App Control policy is blocking a legacy app installed before the managed installer - how do I trust it?`
- `Walk me from audit to enforced App Control for Business across pilot and broad rings.`
- `Create a supplemental App Control policy for the Help Desk team's tools without changing the base.`
- `How do I safely remove an App Control for Business policy without leaving devices blocking apps?`

## Microsoft Learn
- App Control for Business policy and managed installers (Intune): https://learn.microsoft.com/intune/device-configuration/endpoint-security/manage-app-control
- Application Control for Windows (WDAC) overview: https://learn.microsoft.com/windows/security/application-security/application-control/app-control-for-business/appcontrol
- Deploy App Control policies with MDM/Intune: https://learn.microsoft.com/windows/security/application-security/application-control/app-control-for-business/deployment/deploy-appcontrol-policies-using-intune
- Allow reputable apps with the Intelligent Security Graph (ISG): https://learn.microsoft.com/windows/security/application-security/application-control/app-control-for-business/design/use-appcontrol-with-intelligent-security-graph
- Configure apps deployed with a managed installer: https://learn.microsoft.com/windows/security/application-security/application-control/app-control-for-business/design/configure-authorized-apps-deployed-with-a-managed-installer
- Remove App Control policies (avoid boot-stop failures): https://learn.microsoft.com/windows/security/application-security/application-control/app-control-for-business/deployment/disable-appcontrol-policies
