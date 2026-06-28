---
name: intune-endpoint-security-conditional-access
description: "Guidance for the Microsoft Intune Endpoint security > Conditional Access node - the same Microsoft Entra Conditional Access surface reached from Intune, used to turn Intune device compliance into an access gate. Covers device-based Conditional Access, the compliance-first dependency, report-only rollout, break-glass exclusions, and the Require device to be marked as compliant grant. WHEN: Intune Conditional Access, endpoint security conditional access, device-based Conditional Access, require device to be marked as compliant, compliant device Conditional Access, Intune compliance Conditional Access, CA policy from Intune, report-only Conditional Access, block unmanaged devices, require compliant or hybrid joined device. DO NOT USE for authoring the compliance rules themselves, or full Conditional Access design - authentication strength, sign-in/user risk, session controls, MFA."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Conditional Access

The **Conditional Access** node in Intune Endpoint security is not a separate Intune feature - it
is the **Microsoft Entra Conditional Access** node surfaced inside the Intune admin center.
Creating a policy here creates an Entra CA policy. Its role in endpoint security is specific:
it's how you turn an Intune **compliance** verdict into an enforced **access** decision -
device-based Conditional Access.

## When to use
Gating access to corporate resources on Intune device compliance: requiring a device be marked
as compliant (or Entra hybrid joined) before it can reach email, SharePoint, and other apps. Use
this skill for the compliance-to-access bridge and a safe report-only rollout.

**Do not use this skill** for authoring the compliance rules themselves, or full Conditional
Access design - authentication strength, sign-in/user risk, session controls, MFA.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Conditional Access > Create new policy.**
The pane that opens is the Entra Conditional Access configuration pane - the same node you'd
reach at **entra.microsoft.com > Entra ID > Conditional Access**. There are no Intune "profiles"
or platforms here; you build a standard CA policy.

> **Compliance comes first.** A "require compliant device" CA policy does nothing useful until
> you have device compliance policies in place and at least one device reporting compliant. Build
> compliance first, confirm a device is
> compliant, then add the CA policy.

## How device-based Conditional Access works

1. Intune device **compliance policies** evaluate each enrolled device and report a
   compliant/noncompliant status to Entra ID.
2. An Entra **Conditional Access** policy with the grant **Require device to be marked as
   compliant** reads that status at sign-in.
3. Compliant devices are granted access; noncompliant (or unmanaged) devices are blocked or
   challenged, per the policy.

## Approach

1. **Confirm the prerequisites** - Entra ID **P1/P2** licensing, and an account with **Security
   administrator** or **Conditional Access administrator**. Have working compliance policies and
   at least one compliant device before you build the gate.
   *Verify: a pilot device shows Compliant in Intune and as a compliant device identity in Entra.*

2. **Build the CA policy in Report-only** - target your pilot users and resources (start narrow,
   not All resources), and set the grant to **Require device to be marked as compliant**. Leave
   the policy in **Report-only** so you can see who it would affect without blocking anyone.
   *Verify: CA report-only / What If and sign-in logs show the policy would grant compliant devices and block others as intended.*

3. **Exclude break-glass and service accounts** - always exclude emergency-access/break-glass
   accounts and directory synchronization accounts so a misconfiguration can't lock you out.
   *Verify: the exclusion list contains your break-glass accounts; test a break-glass sign-in is unaffected.*

4. **Expand scope, then enable** - once report-only data is clean, widen the user/resource scope
   in rings and switch the policy from Report-only to **On**.
   *Verify: targeted users on compliant devices get access; noncompliant devices are blocked; break-glass still works.*

5. **Decide the "no compliance policy assigned" behavior** - review the Intune **Compliance
   policy settings** option *Mark devices with no compliance policy assigned as* (Compliant vs
   Not compliant). Setting it to Not compliant closes a gap where unevaluated devices slip through.
   *Verify: a device with no compliance policy reports the intended status and is gated accordingly.*

## Guardrails
- **Never start in On - start in Report-only.** A "require compliant device" policy applied
  cold can lock out your whole estate (and you). Report-only first, validate, then enable.
- **Always exclude break-glass accounts.** Emergency-access and directory-sync accounts must be
  excluded from every CA policy, or a bad policy means no way back in.
- **Compliance must exist first.** Without compliance policies and a compliant device, the gate
  blocks everyone. Build and validate compliance before the CA policy.
- **Don't target All resources blind.** If you include All resources, exclude your own account
  and admin access first, and ring the rollout.
- **This is an Entra policy.** Changes here are tenant-wide Entra Conditional Access, not Intune-
  scoped - treat them with that blast radius in mind.

## Common anti-patterns
- **"Enabled the require-compliant policy straight away"** - mass lockout. Report-only, then on.
- **"No break-glass exclusion"** - one misconfiguration and every admin is locked out. Exclude
  emergency-access accounts on every policy.
- **"Built the CA gate before any compliance policy"** - nothing reports compliant, so the gate
  blocks everyone. Compliance first.
- **"Left 'no compliance policy assigned' as Compliant"** - unevaluated devices are treated as
  compliant and bypass the gate. Set it to Not compliant once compliance is rolled out.
- **"Tried to write compliance rules in this node"** - this node is the access gate; author the
  rules in the Device compliance node.

## Example prompts
- `Create a report-only Conditional Access policy that requires a compliant device for a pilot group.`
- `Which break-glass and service accounts should I exclude from my compliance CA policy?`
- `My require-compliant CA policy is blocking compliant devices - how do I troubleshoot the compliance signal?`
- `Move my device-compliance CA policy from report-only to enabled across rings.`
- `How does the "mark devices with no compliance policy assigned as" setting affect my CA gate?`

## Microsoft Learn
- Conditional Access and Intune (overview): https://learn.microsoft.com/intune/device-security/conditional-access-integration/overview
- Create a device-based Conditional Access policy: https://learn.microsoft.com/intune/device-security/conditional-access-integration/device-based-policies
- Require device compliance with Conditional Access: https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-compliance
- Conditional Access policy components: https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-policies
- Report-only mode: https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-report-only
- Manage emergency access (break-glass) accounts: https://learn.microsoft.com/entra/identity/role-based-access-control/security-emergency-access
