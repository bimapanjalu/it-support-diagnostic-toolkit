[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = ".\system-snapshot.local.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-SafeValue {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
    }
    catch {
        [pscustomobject]@{
            Available = $false
            Note      = $_.Exception.Message
        }
    }
}

$timestamp = Get-Date
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1

$adapters = @(
    Get-NetAdapter -ErrorAction SilentlyContinue |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress
)

$ipConfiguration = @(
    Get-NetIPConfiguration -ErrorAction SilentlyContinue |
        ForEach-Object {
            [pscustomobject]@{
                InterfaceAlias = $_.InterfaceAlias
                IPv4Address    = @($_.IPv4Address | ForEach-Object { $_.IPAddress })
                IPv4Gateway    = @($_.IPv4DefaultGateway | ForEach-Object { $_.NextHop })
                DNSServer      = @($_.DNSServer.ServerAddresses)
            }
        }
)

$report = [pscustomobject]@{
    ReportGeneratedAt = $timestamp.ToString("o")
    CollectionScope   = "Read-only local system snapshot"
    Computer          = [pscustomobject]@{
        Name        = $computer.Name
        Manufacturer = $computer.Manufacturer
        Model       = $computer.Model
        Domain      = $computer.Domain
    }
    OperatingSystem   = [pscustomobject]@{
        Caption        = $os.Caption
        Version        = $os.Version
        BuildNumber    = $os.BuildNumber
        LastBootUpTime = $os.LastBootUpTime
    }
    Processor         = [pscustomobject]@{
        Name                  = $processor.Name
        NumberOfCores         = $processor.NumberOfCores
        NumberOfLogicalCores  = $processor.NumberOfLogicalProcessors
    }
    NetworkAdapters   = $adapters
    IPConfiguration   = $ipConfiguration
    PrivacyWarning    = "Review and sanitize hostname, domain, MAC addresses, IP addresses, and other identifiers before sharing."
}

$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
$parentDirectory = Split-Path -Parent $resolvedOutput

if ($parentDirectory -and -not (Test-Path -LiteralPath $parentDirectory)) {
    New-Item -ItemType Directory -Path $parentDirectory -Force | Out-Null
}

$report | ConvertTo-Json -Depth 6 |
    Set-Content -LiteralPath $resolvedOutput -Encoding UTF8

Write-Host "System snapshot saved to: $resolvedOutput" -ForegroundColor Green
Write-Host "Review the report for identifying information before sharing it." -ForegroundColor Yellow
