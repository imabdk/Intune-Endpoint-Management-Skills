---
name: intune-endpoint-security-disk-encryption
description: "Microsoft Intune Endpoint security > Disk encryption policy node - the surface for BitLocker and Personal Data Encryption on Windows and FileVault on macOS, with recovery key escrow to Microsoft Entra ID. Covers silent vs standard BitLocker, the silent-encryption settings (Require Device Encryption, Allow Warning For Other Disk Encryption, Allow Standard User Encryption), key escrow and rotation, the 200-key-per-device limit, and TPM prerequisites. WHEN: Intune disk encryption policy, BitLocker Intune, silent BitLocker, enable BitLocker, BitLocker recovery key Entra, escrow recovery key, recovery key rotation, FileVault Intune, macOS FileVault, Personal Data Encryption PDE, Allow Standard User Encryption, encryption report, BitLocker TPM. DO NOT USE for compliance rules requiring encryption, broad Windows hardening baselines, or BitLocker key-protector / network-unlock design."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Disk encryption

The **Disk encryption** node in Intune Endpoint security manages the built-in encryption of each
platform - **BitLocker** and **Personal Data Encryption** on Windows, **FileVault** on macOS -
and, crucially, escrows the recovery key to Microsoft Entra ID. Each profile carries only
encryption settings, so you configure encryption without wading through unrelated endpoint-
protection settings. The goal: every managed device encrypted, with a recoverable key.

## When to use
Enabling and managing built-in disk encryption on Windows and macOS through Intune: silent
BitLocker rollout, FileVault enablement, recovery key escrow and rotation, and monitoring
encryption state. Use this skill to encrypt cleanly and never lose a recovery key.

**Do not use this skill** for compliance rules that require encryption, broad Windows hardening
baselines, or deep BitLocker key-protector/network-unlock design.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Disk encryption > Create Policy**, then
pick the **Platform** and **Profile**. Some BitLocker settings require a supported **TPM**.
Recovery keys escrow to **Microsoft Entra ID**; view them via **Devices > Monitor > Encryption
report** or a device's **Recovery keys** blade.

> **Recovery key escrow must succeed before encryption starts.** Entra ID stores a maximum of
> **200 BitLocker recovery keys per device** - if you hit that limit, silent encryption fails
> because the key backup fails first. Keep key churn under control.

## Pick the profile

| Platform | Profile | What it manages |
|---|---|---|
| Windows | **BitLocker** | OS/fixed/removable drive encryption, silent enablement, recovery options, key rotation |
| Windows | **Personal Data Encryption (PDE)** | Per-user file encryption on Windows 11 22H2+, complementary to BitLocker |
| macOS | **FileVault** | Full-disk encryption, recovery key escrow, rotation, and user deferral behavior |

## Approach

1. **Choose silent or standard BitLocker** - prefer **silent** for managed Windows: it encrypts
   without user interaction or local admin rights. Set **Require Device Encryption = Enabled**,
   **Allow Warning For Other Disk Encryption = Disabled**, and **Allow Standard User Encryption =
   Enabled** (needed when standard users sign in).
   *Verify: a pilot device encrypts without prompts; the encryption report shows it Encrypted.*

2. **Confirm no third-party encryption is present first** - disabling the "warning for other
   disk encryption" lets BitLocker proceed even if another encryption product is installed,
   risking data loss and boot failures. Use device inventory to confirm the fleet is clean before
   silent rollout.
   *Verify: inventory shows no third-party encryption software on target devices.*

3. **Guarantee recovery key escrow** - ensure keys back up to Entra ID (and consider **recovery
   password rotation** via the BitLocker CSP). Without successful escrow, silent encryption won't
   even start.
   *Verify: the device's Recovery keys blade shows a BitLocker Key ID and recovery key in Entra.*

4. **Configure FileVault for macOS** - in the macOS FileVault profile set **Enable = On**, **Use
   Recovery Key = Enabled**, a **recovery key rotation** interval, and an **escrow location
   message** so users know how to retrieve a key from Company Portal.
   *Verify: `fdesetup status` shows FileVault On; the recovery key is escrowed and retrievable in Company Portal.*

5. **Set key-retrieval permissions for the helpdesk** - granting recovery keys requires the
   `microsoft.directory/bitlockerKeys/key/read` permission (Cloud Device Administrator, Helpdesk
   Administrator, or Global Administrator). Scope this deliberately - reading a key is audited.
   *Verify: a helpdesk role can view a recovery key; the action logs a KeyManagement audit entry.*

6. **Monitor with the encryption report and roll out in rings** - watch **Devices > Monitor >
   Encryption report** through pilot > broad to catch TPM/escrow failures before they scale.
   *Verify: the encryption report shows the ring fully encrypted with keys escrowed.*

## Guardrails
- **No encryption is "done" without an escrowed recovery key.** A device encrypted with a key
  only on the device is a lockout waiting to happen. Confirm escrow to Entra ID.
- **Don't silently encrypt over third-party encryption.** Disabling the other-encryption warning
  can cause data loss and boot failures. Verify the fleet is free of third-party encryption first.
- **Mind the 200-keys-per-device limit.** Excessive key churn fills the Entra limit and breaks
  silent encryption (escrow fails before encryption). Don't rotate needlessly.
- **Standard-user devices need Allow Standard User Encryption.** Without it, silent encryption
  won't run when a non-admin is signed in.
- **TPM matters.** Some BitLocker configurations require a supported TPM; account for hardware
  variance in mixed fleets.
- **Restrict who can read recovery keys.** Key reads are sensitive and audited - grant the
  bitlockerKeys read permission only to the roles that need it.

## Common anti-patterns
- **"Enabled silent BitLocker fleet-wide without checking for third-party encryption"** - data
  loss and boot failures. Inventory first.
- **"Device is encrypted, we're done"** - if the key didn't escrow, a TPM/PIN issue means
  permanent lockout. Verify the key is in Entra.
- **"Rotate recovery keys aggressively for security"** - you can hit the 200-key cap and break
  escrow/encryption. Rotate with purpose.
- **"Standard users, but didn't set Allow Standard User Encryption"** - encryption never triggers
  for non-admin sessions.
- **"Everyone can read recovery keys"** - over-broad key access. Scope the bitlockerKeys read
  permission to helpdesk/admin roles only.

## Example prompts
- `Create a silent BitLocker disk encryption policy that escrows the recovery key to Entra ID for a pilot ring.`
- `Which BitLocker settings enable silent encryption for standard (non-admin) users?`
- `Set up macOS FileVault in Intune with recovery key rotation and an escrow location message.`
- `A user is at the BitLocker recovery screen - where do I find their recovery key and who can view it?`
- `Why is silent BitLocker failing to start on some devices?`

## Microsoft Learn
- Disk encryption policy (Intune Endpoint security): https://learn.microsoft.com/intune/device-configuration/endpoint-security/disk-encryption
- Encrypt Windows devices with BitLocker (incl. silent): https://learn.microsoft.com/intune/device-configuration/endpoint-security/encrypt-bitlocker-windows
- Encrypt macOS devices with FileVault: https://learn.microsoft.com/intune/device-configuration/endpoint-security/encrypt-filevault-macos
- Monitor device encryption (encryption report): https://learn.microsoft.com/intune/device-management/monitor-encryption
- BitLocker CSP (recovery password rotation): https://learn.microsoft.com/windows/client-management/mdm/bitlocker-csp
- Personal Data Encryption (PDE): https://learn.microsoft.com/windows/security/operating-system-security/data-protection/personal-data-encryption/
