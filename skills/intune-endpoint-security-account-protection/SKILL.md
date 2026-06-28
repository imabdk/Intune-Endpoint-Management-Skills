---
name: intune-endpoint-security-account-protection
description: "Microsoft Intune Endpoint security > Account protection policy node - the consolidated Windows profile protecting user credentials and managing local group membership (Windows Hello for Business + Credential Guard; Windows LAPS; Local user group membership via the LocalUsersAndGroups CSP). WHEN: Intune account protection policy, endpoint security account protection, Credential Guard policy, Windows Hello for Business account protection, Windows LAPS, local admin password solution, local user group membership, LocalUsersAndGroups CSP, restrict local administrators group, lock down local admins, Add Replace Remove local group, identity protection deprecated. DO NOT USE for Windows Hello for Business trust-model design, broad Windows 11 hardening / VBS / HVCI / LSA baseline, or Conditional Access authentication strength."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Account protection

The **Account protection** node in Intune Endpoint security protects user credentials and
controls who holds local privilege on Windows devices. It is the credential-and-local-account
layer of endpoint security: passwordless sign-in (Windows Hello for Business), credential
isolation (Credential Guard), local admin password rotation (Windows LAPS), and tight control
of built-in local group membership.

## When to use
Configuring the **Endpoint security > Account protection** policies in Intune: protecting
Windows credentials, rotating the local administrator password, and locking down the local
Administrators group. Use this skill to pick the right profile, set it, and roll it out safely.

**Do not use this skill** for end-to-end WHfB trust-model design, the broad Windows 11
hardening baseline incl. VBS/HVCI/LSA protection, or CA authentication strength.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Account protection > Create Policy >
Platform: Windows.** The same settings are also available in the **Settings catalog**.

> **Consolidation note (July 2024):** The legacy *Identity protection* and *Account protection
> (Preview)* templates were deprecated and replaced by a single consolidated **Account
> protection** profile. Existing instances of the old profiles still work and can be edited,
> but create new policies only from the consolidated profile.

## Pick the profile

Account protection offers three Windows profiles:

| Profile | What it manages | Key prerequisite |
|---|---|---|
| **Account protection** | Windows Hello for Business (device- and user-scoped) + Credential Guard | Windows |
| **Local admin password solution (Windows LAPS)** | Rotates and escrows one local admin account per device | See Windows LAPS prerequisites (Entra ID or AD backup) |
| **Local user group membership** | Add/remove/replace members of built-in local groups via the LocalUsersAndGroups CSP | Windows 10 20H2+ or Windows 11 |

## Approach

1. **Account protection profile (WHfB + Credential Guard)** - Configure Windows Hello for
   Business policy and enable **Credential Guard** to isolate LSASS and defeat most
   credential-theft tooling. Keep tenant-wide WHfB off and target the profile to a pilot ring.
   For trust-model selection and WHfB provisioning depth, follow dedicated Windows Hello for
   Business design guidance.
   *Verify: pilot device shows WHfB at first sign-in; `msinfo32` shows Credential Guard running.*

2. **Windows LAPS profile** - Manage a single local administrator account per device. Set
   **Administrator Account Name** to the exact account the policy targets (don't leave it
   pointed at a renamed or non-existent account). Confirm the backup directory (Entra ID for
   cloud, AD for hybrid) and password rotation cadence.
   *Verify: device reports a rotated password escrowed to the chosen directory; retrieve it
   from the device's Entra object / AD.*

3. **Local user group membership profile** - Use the **LocalUsersAndGroups** CSP to control the
   built-in **Administrators** group (and the other five guaranteed-at-logon built-in groups).
   Choose the action deliberately:
   - **Add (Update)** - adds members; leaves unlisted members untouched.
   - **Remove (Update)** - removes the listed members only.
   - **Add (Replace)** - Restricted-Group behaviour: replaces all members with exactly those
     you list; anyone not listed is removed.
   For Entra-joined devices use **Users** selection; for hybrid, use **Manual** with SID
   (preferred), `domain\username`, or username.
   *Verify: on a target device, `net localgroup administrators` shows exactly the intended
   members.*

4. **Roll out in rings** - Pilot > broad, like every endpoint security policy. Validate against
   real sign-in and admin-access scenarios before tenant-wide assignment.

## Guardrails
- **Add (Replace) is a Restricted Group.** It removes every local admin you didn't explicitly
  list - including break-glass and imaging accounts. List them, or use Add (Update) instead.
- **Pair LAPS with locked-down local admins.** Rotating the local admin password is far weaker
  if the Administrators group is full of unmanaged members. Use the Local user group membership
  profile alongside LAPS.
- **Replace wins over Update - by design, not a conflict.** If the same group gets both a
  Replace and an Update action (across policies or via Graph), Replace applies and Update is
  silently ignored. Don't split a group's management across both actions.
- **Entra group membership doesn't apply to RDP.** Groups deployed by this policy don't govern
  remote desktop connections on Entra-joined devices; add the individual user SID for RDP.
- **Credential Guard needs the hardware floor.** It depends on VBS, which needs Secure Boot +
  TPM and UEFI. On devices that can't run VBS, Credential Guard won't engage - verify, don't
  assume.
- **Group membership conflicts are dropped, not merged.** Conflicting rules across policies are
  not sent to the device and are reported as errors in the admin center. Check reporting.

## Common anti-patterns
- **"Add (Replace) to clean up local admins"** without listing break-glass - locks you out of
  local admin on every targeted device.
- **"LAPS handles local admin risk"** while the Administrators group still has stale members - rotate the password *and* restrict membership.
- **"Enable WHfB tenant-wide from the Account protection profile"** - forced enablement breaks
  shared and non-TPM devices. Target rings.
- **"Manage the same local group with two policies"** - leads to Replace/Update precedence
  surprises and dropped conflicting rules.
- **"Use the old Identity protection template for new policy"** - deprecated July 2024; create
  from the consolidated Account protection profile.

## Example prompts
- `Create an Intune Account protection policy that enables Credential Guard and Windows Hello for Business for a pilot ring.`
- `Lock the local Administrators group down to break-glass plus a named Entra group using the Local user group membership profile.`
- `Configure Windows LAPS through the Account protection node and escrow the password to Entra ID.`
- `Explain the difference between Add (Update), Remove (Update), and Add (Replace) for local groups.`
- `Why did my local admins get wiped after deploying a Local user group membership policy?`

## Microsoft Learn
- Account protection policy: https://learn.microsoft.com/intune/device-configuration/endpoint-security/account-protection
- Windows LAPS in Intune: https://learn.microsoft.com/intune/device-security/laps/overview
- Deploy Windows LAPS policy: https://learn.microsoft.com/intune/device-security/laps/deploy-policy
- LocalUsersAndGroups CSP: https://learn.microsoft.com/windows/client-management/mdm/policy-csp-localusersandgroups
- Credential Guard: https://learn.microsoft.com/windows/security/identity-protection/credential-guard/
- Manage local admins with Entra groups: https://learn.microsoft.com/entra/identity/devices/assign-local-admin
- Windows identity and access management: https://learn.microsoft.com/windows/security/book/identity-protection
