<div align="center">

# IT Support Diagnostic Toolkit

**Small, read-only PowerShell utilities for first-line system and network checks.**

`PowerShell` `Windows` `Networking` `Diagnostics`

</div>

---

## Purpose

This toolkit demonstrates how routine diagnostic checks can be made more consistent. It includes scripts to collect a local system snapshot and inspect basic DNS/network reachability.

The scripts are **read-only with respect to system configuration**. They do not change firewall rules, DNS settings, adapters, registry values, or user accounts.

## Included scripts

| Script | Purpose | Output |
|---|---|---|
| `scripts/Get-SystemSnapshot.ps1` | Collect selected OS, hardware, adapter, and IP-configuration details | Local JSON report |
| `scripts/Test-NetworkPath.ps1` | Check DNS resolution, ICMP reachability, and optional TCP port connectivity | Console summary and optional CSV report |

## Requirements

- Windows 10/11 or a compatible Windows PowerShell / PowerShell environment.
- Permission to run local diagnostic commands.
- PowerShell execution policy that permits the script, according to your device policy.
- Network access to the test target, if network checks are performed.

Do not bypass an organization's execution policy. If script execution is blocked, follow the approved local process.

## Run the system snapshot

Open PowerShell in the project folder:

```powershell
.\scripts\Get-SystemSnapshot.ps1
```

By default, it writes a file named `system-snapshot.local.json` in the current directory. The file is ignored by Git because it may contain a hostname, adapter identifiers, and IP configuration.

Choose a different local output path:

```powershell
.\scripts\Get-SystemSnapshot.ps1 -OutputPath ".\reports\my-system.local.json"
```

The script creates the parent directory if needed.

## Run a network check

```powershell
.\scripts\Test-NetworkPath.ps1 -Target "example.com"
```

Check a specific TCP port when appropriate:

```powershell
.\scripts\Test-NetworkPath.ps1 -Target "example.com" -Port 443
```

Write a CSV report to a local path:

```powershell
.\scripts\Test-NetworkPath.ps1 -Target "example.com" -Port 443 -OutputPath ".\reports\network-check.local.csv"
```

Use only targets you are permitted to test. ICMP can be blocked even when a service is available; interpret ping results alongside DNS, TCP, and application-level evidence.

## Example workflow

1. Ask what is failing and identify the affected device or service.
2. Run the system snapshot to record the local environment.
3. Run a targeted network check based on the symptom.
4. Compare the observation with a known-good device or expected configuration.
5. Record the result in an incident report.
6. Review and sanitize the report before attaching it to a public issue or portfolio.

## Privacy and safe use

- Do not commit raw local JSON or CSV reports without reviewing them.
- Never include passwords, tokens, customer data, or confidential workplace information.
- Run only on devices you own or are authorized to support.
- These scripts do not establish that a device is healthy or secure; they provide a limited snapshot for further investigation.

## Project status

The scripts are provided as a starting implementation. Run them in your own Windows environment, inspect the output, and add a dated **Tested on** section with the PowerShell and Windows versions you actually used. Do not claim compatibility with environments you have not tested.

## Structure

```text
.
├── README.md
├── scripts/
│   ├── Get-SystemSnapshot.ps1
│   └── Test-NetworkPath.ps1
├── docs/
│   ├── test-plan.md
│   └── sample-report-notes.md
└── .gitignore
```
