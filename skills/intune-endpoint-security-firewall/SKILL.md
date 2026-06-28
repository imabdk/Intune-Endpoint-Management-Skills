---
name: intune-endpoint-security-firewall
description: "Microsoft Intune Endpoint security > Firewall policy node - configuring the built-in host firewall on Windows and macOS. Profiles: Windows Firewall (global), Windows Firewall Rules (inbound/outbound), Windows Hyper-V Firewall Rules (WSL/WSA), macOS Firewall. Covers reusable settings groups (remote IP ranges, FQDN), the inbound-FQDN limitation, and default inbound-block/outbound-allow posture. WHEN: Intune firewall policy, Windows Defender Firewall Intune, firewall rules profile, Hyper-V firewall, WSL WSA firewall rules, macOS firewall, reusable settings groups firewall, remote IP address ranges, FQDN firewall rule, inbound outbound firewall rule, stealth mode, block all incoming, firewall profile domain private public, network segmentation. DO NOT USE for Defender Antivirus settings, ASR rules, device control or network protection, or WDAC app allowlisting."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Firewall

The **Firewall** node configures the **built-in host firewall** on **Windows** and **macOS** -
turning it on, setting the default posture, and managing granular inbound/outbound rules. It's the
network-layer control for endpoint segmentation and reducing exposed surface.

## When to use
Enabling and hardening the OS firewall, setting a default inbound-block posture, and authoring
specific allow/block rules (including Hyper-V container rules for WSL/WSA). Use this skill to pick
the right profile, apply reusable settings groups, and avoid conflicting deployments.

**Do not use this skill** for Defender Antivirus or network protection, ASR rules or device
control, or WDAC application control.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Firewall.** Platforms: **Windows** and
**macOS**. Firewall uses separate profiles for the global on/off posture versus the granular
rules - don't mix the two jobs in one profile.

> **Global profile vs rules are different jobs.** The Windows Firewall profile sets the
> state/behavior per network type; the Windows Firewall Rules profile defines individual
> allow/block rules. Deploy a comprehensive global profile *and* keep rules in their own profile -
> conflicting settings across them cause unpredictable results.

## Pick the profile

| Platform | Profile | What it manages |
|---|---|---|
| Windows | **Windows Firewall** | Global state and behavior per network type (domain/private/public): firewall on/off, default inbound/outbound action, stealth mode, logging |
| Windows | **Windows Firewall Rules** | Granular inbound/outbound rules by app, port, protocol, IP, and FQDN; supports reusable settings groups |
| Windows | **Windows Hyper-V Firewall Rules** | Firewall rules for Hyper-V containers - WSL (Subsystem for Linux) and WSA (Subsystem for Android) |
| macOS | **macOS Firewall** | Enable the firewall, block all incoming, stealth mode, and per-app allow/block behavior |

## Approach

1. **Turn the firewall on for every network type** - deploy a Windows Firewall profile that
   enables the firewall for domain, private, and public, with a default **inbound block /
   outbound allow** posture.
   *Verify: on a target device, `Get-NetFirewallProfile` shows Enabled=True for all three profiles with the expected default actions.*

2. **Author granular rules in a Firewall Rules profile** - keep individual allow/block rules in
   the Windows Firewall Rules profile (or macOS Firewall), separate from the global profile.
   Define rules by app, port/protocol, direction, and IP/FQDN.
   *Verify: an allowed app/port connects and a blocked one is denied as expected on a pilot device.*

3. **Use reusable settings groups for shared scopes** - for Windows firewall rules, put **remote
   IP address ranges** and **FQDN definitions/auto-resolution** into a reusable settings group, set
   the rule **Action**, then reference the group from multiple rules. Editing the group updates
   every rule that uses it.
   *Verify: changing a value in the reusable group propagates to all profiles that reference it.*

4. **Handle the inbound-FQDN limitation** - inbound FQDN rules aren't natively supported. For
   inbound-by-name needs, use Windows Firewall **dynamic keywords** with pre-hydration scripts to
   generate inbound IP entries.
   *Verify: the inbound rule resolves to concrete IP entries via the dynamic-keyword/pre-hydration approach rather than relying on an unsupported inbound FQDN.*

5. **Cover Hyper-V containers if used** - if WSL/WSA is in play, add a Windows Hyper-V Firewall
   Rules profile to govern that container traffic separately from the host rules.
   *Verify: container traffic follows the Hyper-V rules independently of host firewall rules.*

## Guardrails
- **Firewall on for all three Windows profiles.** Domain, private, and public should all be
  enabled - a disabled public profile on a laptop off-network is a real exposure.
- **Default inbound block, outbound allow.** Start from deny-inbound and add explicit allow rules;
  blanket inbound-allow defeats the purpose.
- **Keep the global profile and rules separate.** One Windows Firewall profile for posture, one
  Windows Firewall Rules profile for rules - don't author conflicting state across both.
- **Within a rule, separate reusable groups from inline settings.** Use a given rule for either
  reusable groups or directly-added settings to keep future changes simple.
- **Inbound FQDN isn't native.** Don't assume an inbound FQDN rule works - use dynamic
  keywords/pre-hydration for inbound-by-name.
- **Pilot before broad allow/block.** A wrong block rule can cut off management or LOB
  connectivity - ring it out first.

## Common anti-patterns
- **"Disabled the firewall to fix a connectivity issue"** - removes a core control. Add a scoped
  allow rule instead.
- **"Public profile left off"** - laptops are most exposed off the corporate network. Enable all
  three.
- **"Global posture and rules crammed into one profile with conflicts"** - unpredictable behavior.
  Split posture and rules into their own profiles.
- **"Built an inbound FQDN rule and expected it to work"** - it isn't natively supported. Use
  dynamic keywords/pre-hydration.
- **"Duplicated the same IP ranges across ten rules"** - maintenance nightmare. Put them in a
  reusable settings group.

## Example prompts
- `Create a Windows Firewall profile that enables the firewall for domain, private, and public with default inbound block.`
- `Build a Windows Firewall Rules profile allowing our LOB app outbound on a specific port.`
- `Use a reusable settings group for our datacenter IP ranges and reference it from multiple firewall rules.`
- `How do I handle an inbound rule that needs to match a hostname when inbound FQDN isn't supported?`
- `Add Hyper-V firewall rules to control WSL network traffic separately from the host.`

## Microsoft Learn
- Firewall policy for endpoint security in Intune: https://learn.microsoft.com/intune/device-configuration/endpoint-security/firewall
- Use reusable groups of settings with Intune policies: https://learn.microsoft.com/intune/device-security/reusable-settings-groups
- Manage endpoint security policies in Intune: https://learn.microsoft.com/intune/device-configuration/endpoint-security/manage-policies
- Windows Firewall dynamic keywords: https://learn.microsoft.com/windows/security/operating-system-security/network-security/windows-firewall/dynamic-keywords
