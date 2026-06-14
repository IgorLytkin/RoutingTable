# RoutingTable.ps1
# Совместимо с Windows PowerShell 5.1

$ErrorActionPreference = 'Stop'

function Get-ValueText {
    param($Value, $Default = 'нет')
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $Default
    }
    return [string]$Value
}

Write-Host "=== Таблица маршрутизации ===" -ForegroundColor Cyan
Write-Host ("Компьютер: {0}" -f $env:COMPUTERNAME) -ForegroundColor Gray
Write-Host ("Дата:      {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host ""

Write-Host "=== АКТИВНЫЕ ИНТЕРФЕЙСЫ ===" -ForegroundColor Yellow
$cfgs = Get-NetIPConfiguration | Where-Object {
    $_.NetAdapter.Status -eq 'Up'
}

foreach ($cfg in $cfgs) {
    $alias = Get-ValueText $cfg.InterfaceAlias
    $ipv4 = Get-ValueText ($cfg.IPv4Address.IPAddress)
    $prefix = Get-ValueText ($cfg.IPv4Address.PrefixLength)
    $gw = Get-ValueText ($cfg.IPv4DefaultGateway.NextHop)

    $dnsArr = @($cfg.DnsServer.ServerAddresses)
    if ($dnsArr.Count -gt 0) {
        $dns = $dnsArr -join ', '
    } else {
        $dns = 'нет'
    }

    Write-Host ("{0}" -f $alias) -ForegroundColor Green
    Write-Host ("  IPv4 : {0}/{1}" -f $ipv4, $prefix) -ForegroundColor White
    Write-Host ("  GW   : {0}" -f $gw) -ForegroundColor White
    Write-Host ("  DNS  : {0}" -f $dns) -ForegroundColor White
    Write-Host ""
}

Write-Host "=== IPv4 МАРШРУТЫ ===" -ForegroundColor Yellow
$routes4 = Get-NetRoute -AddressFamily IPv4 | Where-Object {
    $_.DestinationPrefix -notlike '127.*' -and
    $_.DestinationPrefix -notlike '224.*' -and
    $_.DestinationPrefix -notlike '255.255.255.255/32'
} | Sort-Object RouteMetric, DestinationPrefix

$routes4 |
    Select-Object DestinationPrefix, NextHop, InterfaceAlias,
        @{Name='Metric';Expression={$_.RouteMetric}},
        @{Name='PolicyStore';Expression={$_.PolicyStore}} |
    Format-Table -AutoSize

Write-Host ""
Write-Host "=== КЛЮЧЕВЫЕ МАРШРУТЫ ===" -ForegroundColor Yellow

$default = $routes4 | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select-Object -First 1
if ($default) {
    Write-Host ("По умолчанию: {0} через {1} (метрика {2})" -f $default.NextHop, $default.InterfaceAlias, $default.RouteMetric) -ForegroundColor Cyan
}

$wg = $routes4 | Where-Object { $_.InterfaceAlias -like '*WireGuard*' -or $_.DestinationPrefix -like '10.8.0.*' } | Select-Object -First 1
if ($wg) {
    Write-Host ("WireGuard:    {0} ({1}, метрика {2})" -f $wg.DestinationPrefix, $wg.InterfaceAlias, $wg.RouteMetric) -ForegroundColor Cyan
}

$cisco = $routes4 | Where-Object { $_.InterfaceAlias -like '*Cisco*' -or $_.DestinationPrefix -like '192.168.11.*' } | Select-Object -First 1
if ($cisco) {
    Write-Host ("Cisco VPN:    {0} ({1}, метрика {2})" -f $cisco.NextHop, $cisco.InterfaceAlias, $cisco.RouteMetric) -ForegroundColor Magenta
}

Write-Host ""
Write-Host "=== IPv6 МАРШРУТЫ ===" -ForegroundColor Yellow
$routes6 = Get-NetRoute -AddressFamily IPv6 | Where-Object {
    $_.DestinationPrefix -ne '::1/128' -and $_.DestinationPrefix -notlike 'ff00::*'
} | Sort-Object RouteMetric, DestinationPrefix

$routes6 |
    Select-Object DestinationPrefix, NextHop, InterfaceAlias,
        @{Name='Metric';Expression={$_.RouteMetric}} |
    Format-Table -AutoSize