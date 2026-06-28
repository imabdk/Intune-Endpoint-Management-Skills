# Example prompts

Each skill triggers automatically from how you phrase a question - you don't call it by name. Just
ask naturally in Copilot Chat and the agent picks the right skill from its description.

The prompts below are real phrasings I've checked against the skills, so **each prompt here has
been verified by me to trigger the skill shown**. Use them as-is to confirm a skill is installed
and routing correctly, or as a template for your own questions.

> Tip: these are starting points, not magic words. Rephrase freely - the agent routes on intent,
> not exact wording.

## Account protection

`intune-endpoint-security-account-protection`

- How do I roll out Windows LAPS so local admin passwords back up to Entra ID and rotate automatically?
- On Entra-joined devices I want to make sure only specific accounts stay in the local Administrators group - how?
- I want to turn on Credential Guard for a small pilot ring of Windows machines via Intune endpoint security.
- After I wipe the local administrators group with the Replace action, what does a later Add (Replace) operation actually do?

## Antivirus

`intune-endpoint-security-antivirus`

- Turn on cloud-delivered protection and set PUA to audit for Microsoft Defender Antivirus through Intune.
- Can I create a profile that only manages Defender exclusions and nothing else?
- Where do I configure tamper protection and the Windows Security app experience for end users?
- How do I stage Defender platform/engine update channels so pilot devices get updates before broad?

## App Control for Business

`intune-endpoint-security-app-control-for-business`

- Set up WDAC application allowlisting in audit mode and trust apps deployed through Intune.
- How do I designate the Intune Management Extension as a managed installer?
- What's the safe way to remove an App Control policy without bricking machines?
- I need a supplemental policy so the help desk can run a few extra tools.

## Attack surface reduction

`intune-endpoint-security-attack-surface-reduction`

- Deploy the standard set of attack surface reduction rules in audit first.
- Add an exclusion for one ASR rule that's blocking a legitimate macro.
- Configure exploit protection and device control for removable storage.
- If I set ASR exclusions in two different policies, how do they combine?

## Conditional access

`intune-endpoint-security-conditional-access`

- Create a report-only Conditional Access policy that requires compliant devices for a pilot group.
- How should I handle break-glass account exclusions on my CA policies?
- Move my report-only require-compliant policy to enabled.
- Block non-compliant devices from SharePoint and Exchange email.

## Device compliance

`intune-endpoint-security-device-compliance`

- Build a Windows compliance policy requiring BitLocker, Secure Boot and a minimum OS version.
- Add a grace period and send the user an email before marking noncompliant.
- Use the Defender for Endpoint machine risk score as a compliance signal.
- Write a custom compliance script for a registry check.

## Disk encryption

`intune-endpoint-security-disk-encryption`

- Enable silent BitLocker with the recovery key escrowed to Entra ID.
- Which settings do I need so standard users get silent encryption without admin rights?
- Rotate FileVault keys on macOS and customize the escrow message.
- A user is at the BitLocker recovery screen - how do I retrieve the key and who's allowed to read it?

## Endpoint detection and response

`intune-endpoint-security-endpoint-detection-and-response`

- Connect Intune to Defender for Endpoint and use Auto from connector onboarding.
- Some devices aren't showing up in the Defender portal - how do I troubleshoot onboarding?
- Turn on EDR in block mode so a passive-mode AV still remediates.
- Onboard macOS and Linux machines to EDR.

## Endpoint Privilege Management

`intune-endpoint-security-endpoint-privilege-management`

- Let standard users elevate approved apps just-in-time without being permanent admins.
- Create a user-confirmed elevation rule scoped to a signed cert and a secured file path.
- I want EPM in audit first and review the Elevation report before enforcing.
- How are conflicts resolved when two elevation rules match the same file?

## Firewall

`intune-endpoint-security-firewall`

- Turn the Windows firewall on for domain, private and public profiles with default inbound block.
- Create an outbound firewall rule for a line-of-business app.
- Set up a reusable settings group for a set of remote IP ranges.
- Add Hyper-V firewall rules for WSL.

## Security baselines

`intune-endpoint-security-security-baselines`

- Deploy the Windows security baseline defaults to a pilot ring.
- Update my security baseline to the latest version while keeping my customizations.
- What's the difference between the MDM, Defender for Endpoint, and Edge baselines?
- Retire an old baseline instance without double-targeting devices.
