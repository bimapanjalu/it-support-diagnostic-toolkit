# Toolkit Test Plan

## Purpose

Verify that the scripts complete expected read-only checks, handle common failures without terminating unexpectedly, and write reports to the requested location.

## Test environment record

Fill this section after execution.

- Windows edition/build:
- PowerShell version (`$PSVersionTable.PSVersion`):
- Date:
- Tester:
- Test device is owned or authorized: `[yes/no]`

## Test cases

| ID | Test | Steps | Expected result | Status |
|---|---|---|---|---|
| TOOL-01 | Default snapshot | Run `Get-SystemSnapshot.ps1` | JSON file is created and contains timestamp, OS, and network sections | NOT RUN |
| TOOL-02 | Snapshot custom path | Run with `-OutputPath ".\reports\test.local.json"` | Parent folder is created if needed; JSON file is written | NOT RUN |
| TOOL-03 | Default DNS target | Run `Test-NetworkPath.ps1 -Target "example.com"` | Summary includes DNS and ICMP fields; ICMP outcome is not treated as definitive service status | NOT RUN |
| TOOL-04 | TCP test | Run with a permitted target and `-Port 443` | TCP outcome is included in the summary | NOT RUN |
| TOOL-05 | Invalid / unreachable target | Use a deliberately invalid test hostname | DNS failure is reported without hiding the failure | NOT RUN |
| TOOL-06 | Optional CSV output | Supply an `-OutputPath` ending in `.csv` | CSV file is created with a result row | NOT RUN |
| TOOL-07 | Privacy review | Inspect generated output | Identify fields are understood and sanitized before sharing | NOT RUN |

## Execution rules

- Replace `NOT RUN` only after the test is executed.
- Record actual result and evidence path.
- Do not use an unapproved target to test connectivity.
- If the environment blocks a command, record the limitation rather than claiming a pass.

## Known limitations

Network results depend on local policy, DNS, firewall rules, proxy configuration, and remote service availability. These tests do not prove end-to-end application health.
