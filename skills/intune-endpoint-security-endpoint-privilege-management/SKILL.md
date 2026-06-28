---
name: intune-endpoint-security-endpoint-privilege-management
description: "Microsoft Intune Endpoint security > Endpoint Privilege Management (EPM) policy node - least-privilege elevation for Windows, letting standard users run approved tasks with admin rights. Covers the Intune Suite add-on licensing, the two policy types (Elevation settings and Elevation rules), and elevation types (Automatic, User confirmed, Support approved, Elevate as current user, Deny). WHEN: Intune Endpoint Privilege Management, EPM Intune, run with elevated access, standard user elevation, just-in-time elevation, elevation rules policy, elevation settings policy, support approved elevation, user confirmed elevation, automatic elevation rule, remove local admin rights, least privilege Windows, EPM elevation report, Intune Suite add-on. DO NOT USE for local Administrators group membership / LAPS, application allowlisting, or ASR rules."
license: MIT
metadata:
  author: Martin Bengtsson
  version: "0.1.0"
---

# Intune Endpoint security - Endpoint Privilege Management

The **Endpoint Privilege Management (EPM)** node lets you run Windows users as **standard users**
while granting **temporary, controlled elevation** for approved tasks - app installs, driver
updates, diagnostics. It's the practical way to remove standing local admin rights without
blocking the work that occasionally needs them. EPM is a **Windows-only Intune Suite add-on** and
requires extra licensing beyond Intune.

## When to use
Removing standing local administrator rights while still letting users elevate specific, approved
binaries on demand. Use this skill to license and plan EPM, audit real elevations, author
elevation rules with secure defaults, and roll out least privilege.

**Do not use this skill** for local Administrators group membership or LAPS, application
allowlisting, or ASR rules.

## Where it lives

**Microsoft Intune admin center > Endpoint security > Endpoint Privilege Management.** EPM is an
**advanced capability / Intune Suite add-on** for **Windows** - license it in the tenant before
the policies appear/work. A device needs an **Elevation settings policy** (to enable EPM) plus an
**Elevation rules policy** (the actual rules).

> **Two policies work together.** The Elevation settings policy turns EPM on and sets the default
> behavior; the Elevation rules policy defines per-app elevation. Rules do nothing on a device
> that hasn't also received an enabling settings policy.

## Pick the elevation type

| Elevation type | Behavior | Use for |
|---|---|---|
| **Automatic** | Elevates silently, no user interaction | Narrow, fully trusted binaries only - broad use is a big security risk |
| **User confirmed** | Right-click *Run with elevated access*; optional credential prompt and/or business justification | The everyday default for approved apps where the user keeps agency |
| **Support approved** | User submits a request; an admin approves before elevation | High-sensitivity apps; the most controlled, audited path |
| **Elevate as current user** | Runs under the user's own account instead of a virtual account | Only when virtual-account elevation breaks app compatibility (broader attack surface) |
| **Deny** | Blocks elevation | Explicitly stopping known apps; always wins on conflict |

## Approach

1. **License and plan** - enable the EPM add-on in the tenant and decide your default elevation
   response. Plan for Windows-only scope and the two-policy model.
   *Verify: EPM policy types are available under Endpoint security > Endpoint Privilege Management.*

2. **Enable EPM in audit first** - deploy an **Elevation settings policy** that enables EPM with
   reporting on (diagnostic data and all endpoint elevations). Don't author broad rules yet -
   let the **Elevation report** show what users actually elevate.
   *Verify: pilot devices show the "Run with elevated access" context menu; the Elevation report populates with real elevation events.*

3. **Set a secure default response** - set the default elevation response to **Require support
   approval** or **Deny**, not "require user confirmation". This forces known-binary rules rather
   than letting users elevate arbitrary executables.
   *Verify: an unrecognized binary follows the deny/support-approval default, not silent or self-confirmed elevation.*

4. **Author elevation rules from real data** - build an **Elevation rules policy** from the
   Elevation report or support-approved requests. Identify each file by name/extension, validate
   with a **certificate** (use a reusable publisher-cert group), and **require a file path** in a
   location standard users can't modify. Prefer **User confirmed** (with justification) over
   Automatic.
   *Verify: the targeted app elevates per its rule; the same binary from an unsecured path does not.*

5. **Prefer virtual-account elevation** - leave elevations on the default virtual account (which
   isolates from the user profile); only use **Elevate as current user** when an app genuinely
   breaks, and scope those rules tightly.
   *Verify: elevated processes run under the virtual account except where compatibility demands otherwise.*

6. **Manage and tighten over time** - process support-approved requests, review the Elevation
   report, prune over-broad rules, and remove standing local admin (pair with Account
   protection's local group membership control).
   *Verify: standing admin counts drop; elevations are all rule-governed and logged.*

## Guardrails
- **Audit before you write rules.** Enable EPM with reporting and watch the Elevation report
  first - rules built from real data beat guesses and avoid blocking legitimate work.
- **Secure default = support-approved or deny, not user-confirmation.** A user-confirmation
  default lets users elevate anything; predefined rules for known binaries are the point of EPM.
- **Require a file path in a protected location.** Without a path restriction, automatic or
  wildcard rules can be abused by swapping the binary. Point rules at secured system directories;
  network-share files aren't supported.
- **Minimize Automatic elevation.** Silent, broad automatic rules can hand out admin widely. Keep
  Automatic to a tight set of fully trusted binaries; prefer User confirmed.
- **Prefer the virtual account.** Elevate as current user widens the attack surface and reduces
  isolation - use it only for genuine compatibility failures, scoped narrowly.
- **Know the conflict precedence.** Deny always wins; user-targeted rules beat device-targeted;
  a hash is the most specific match; otherwise the most-defined rule wins.

## Common anti-patterns
- **"Default response set to user confirmation"** - users self-approve arbitrary elevation. Use
  support-approved or deny as the default.
- **"Wrote broad automatic rules to reduce helpdesk tickets"** - effectively re-grants admin.
  Audit, then scope tight rules, mostly User confirmed.
- **"Rule with no file path / wildcard from a user-writable folder"** - a swapped binary gets
  elevated. Require a secured path.
- **"Elevate as current user everywhere for compatibility"** - unnecessary exposure. Default to
  the virtual account; current-user only where needed.
- **"Deployed elevation rules but no settings policy"** - EPM isn't enabled on the device, so the
  rules do nothing. Ship the settings policy too.

## Example prompts
- `Enable EPM in audit mode and use the Elevation report to see what users elevate before I write rules.`
- `Create a user-confirmed elevation rule for our LOB installer, validated by certificate and a secured file path.`
- `Set a secure default elevation response and explain why support-approved beats user confirmation.`
- `How does EPM resolve two conflicting elevation rules for the same app?`
- `Move us from standing local admin to EPM least privilege - what's the rollout order?`

## Microsoft Learn
- EPM overview: https://learn.microsoft.com/intune/epm/overview
- Plan and prepare for EPM (concepts, security recommendations, conflicts): https://learn.microsoft.com/intune/epm/deployment-planning
- Deploy EPM: https://learn.microsoft.com/intune/epm/deploy
- Manage Windows elevation settings policy: https://learn.microsoft.com/intune/epm/manage-elevation-settings
- Create elevation rules: https://learn.microsoft.com/intune/epm/create-elevation-rules
- Monitor EPM (Elevation report): https://learn.microsoft.com/intune/epm/monitor-reports
- Manage support-approved requests: https://learn.microsoft.com/intune/epm/manage-support-approvals
- Intune Suite add-ons / advanced capabilities: https://learn.microsoft.com/intune/fundamentals/advanced-capabilities
