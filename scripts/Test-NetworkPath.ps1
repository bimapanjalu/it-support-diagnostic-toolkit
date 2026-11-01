[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Target = "example.com",

    [Parameter()]
    [ValidateRange(0, 65535)]
    [int]$Port = 0,

    [Parameter()]
    [string]$OutputPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$startedAt = Get-Date
$dnsStatus = "NOT TESTED"
$resolvedAddresses = @()
$icmpReachable = $null
$tcpResult = $null
$notes = [System.Collections.Generic.List[string]]::new()

try {
    $dnsRecords = @(Resolve-DnsName -Name $Target -ErrorAction Stop)
    $resolvedAddresses = @(
        $dnsRecords |
            Where-Object { $_.IPAddress } |
            Select-Object -ExpandProperty IPAddress -Unique
    )
    $dnsStatus = if ($resolvedAddresses.Count -gt 0) { "RESOLVED" } else { "NO IP RECORD RETURNED" }
}
catch {
    $dnsStatus = "FAILED"
    $notes.Add("DNS query failed: $($_.Exception.Message)")
}

try {
    $icmpReachable = [bool](Test-Connection -ComputerName $Target -Count 2 -Quiet -ErrorAction Stop)
}
catch {
    $icmpReachable = $false
    $notes.Add("ICMP test failed or was blocked: $($_.Exception.Message)")
}

if ($Port -gt 0) {
    try {
        $tcp = Test-NetConnection -ComputerName $Target -Port $Port -WarningAction SilentlyContinue
        $tcpResult = [bool]$tcp.TcpTestSucceeded
    }
    catch {
        $tcpResult = $false
        $notes.Add("TCP test failed: $($_.Exception.Message)")
    }
}

$result = [pscustomobject]@{
    Target             = $Target
    StartedAt          = $startedAt.ToString("o")
    CompletedAt        = (Get-Date).ToString("o")
    DNSStatus          = $dnsStatus
    ResolvedAddresses  = ($resolvedAddresses -join "; ")
    IcmpReachable      = $icmpReachable
    TcpPortTested      = if ($Port -gt 0) { $Port } else { $null }
    TcpConnectionWorks = $tcpResult
    Notes              = ($notes -join " | ")
    Interpretation     = "A failed ICMP test does not prove that the host or service is unavailable. Compare DNS, TCP, and application-level evidence."
}

$result | Format-List

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
    $parentDirectory = Split-Path -Parent $resolvedOutput

    if ($parentDirectory -and -not (Test-Path -LiteralPath $parentDirectory)) {
        New-Item -ItemType Directory -Path $parentDirectory -Force | Out-Null
    }

    $result | Export-Csv -LiteralPath $resolvedOutput -NoTypeInformation -Encoding UTF8
    Write-Host "Network check saved to: $resolvedOutput" -ForegroundColor Green
}
