<#
.SYNOPSIS
    Display Windows Routing Table and Network Configuration

.DESCRIPTION
    Компактный инструмент для диагностики сетевой конфигурации:
    - Активные интерфейсы с IPv4/IPv6
    - Таблица маршрутизации IPv4/IPv6
    - Выделение критических маршрутов (default, WireGuard, Cisco VPN)

.NOTES
    Requires PowerShell 5.1+
    For full functionality, run as Administrator
    Compatible with Windows 10/11, Windows Server 2016+
#>

$ErrorActionPreference = 'Stop'

function Get-ValueText {
    <#
    .SYNOPSIS
        Convert value to string with default fallback
    #>
    param($Value, $Default = 'none')
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        return $Default
    }
    return [string]$Value
}

try {
    Write-Host "=== Routing Table ===" -ForegroundColor Cyan
    Write-Host ("Computer: {0}" -f $env:COMPUTERNAME) -ForegroundColor Gray
    Write-Host ("Date:     {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "=== ACTIVE INTERFACES ===" -ForegroundColor Yellow
    $cfgs = Get-NetIPConfiguration | Where-Object {
        $_.NetAdapter.Status -eq 'Up'
    }
    
    if ($cfgs.Count -eq 0) {
        Write-Host "No active interfaces found" -ForegroundColor Yellow
    } else {
        foreach ($cfg in $cfgs) {
            $alias = Get-ValueText $cfg.InterfaceAlias "unknown"
            $ipv4 = Get-ValueText ($cfg.IPv4Address.IPAddress) "none"
            $prefix = Get-ValueText ($cfg.IPv4Address.PrefixLength) "none"
            $gw = Get-ValueText ($cfg.IPv4DefaultGateway.NextHop) "none"
            
            $dnsArr = @($cfg.DnsServer.ServerAddresses)
            if ($dnsArr.Count -gt 0) {
                $dns = $dnsArr -join ', '
            } else {
                $dns = 'none'
            }
            
            Write-Host ("{0}" -f $alias) -ForegroundColor Green
            Write-Host ("  IPv4 : {0}/{1}" -f $ipv4, $prefix) -ForegroundColor White
            Write-Host ("  GW   : {0}" -f $gw) -ForegroundColor White
            Write-Host ("  DNS  : {0}" -f $dns) -ForegroundColor White
            Write-Host ""
        }
    }
    
    Write-Host "=== IPv4 ROUTES ===" -ForegroundColor Yellow
    $routes4 = Get-NetRoute -AddressFamily IPv4 | Where-Object {
        $_.DestinationPrefix -notlike '127.*' -and
        $_.DestinationPrefix -notlike '224.*' -and
        $_.DestinationPrefix -notlike '255.255.255.255/32'
    } | Sort-Object RouteMetric, DestinationPrefix
    
    if ($routes4.Count -eq 0) {
        Write-Host "No IPv4 routes found" -ForegroundColor Yellow
    } else {
        $routes4 |
            Select-Object DestinationPrefix, NextHop, InterfaceAlias,
                @{Name='Metric';Expression={$_.RouteMetric}},
                @{Name='PolicyStore';Expression={$_.PolicyStore}} |
            Format-Table -AutoSize
    }
    
    Write-Host ""
    Write-Host "=== KEY ROUTES ===" -ForegroundColor Yellow
    
    $default = $routes4 | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' } | Select-Object -First 1
    if ($default) {
        Write-Host ("Default:     {0} via {1} (metric {2})" -f $default.NextHop, $default.InterfaceAlias, $default.RouteMetric) -ForegroundColor Cyan
    }
    
    $wg = $routes4 | Where-Object { $_.InterfaceAlias -like '*WireGuard*' -or $_.DestinationPrefix -like '10.8.0.*' } | Select-Object -First 1
    if ($wg) {
        Write-Host ("WireGuard:   {0} ({1}, metric {2})" -f $wg.DestinationPrefix, $wg.InterfaceAlias, $wg.RouteMetric) -ForegroundColor Cyan
    }
    
    $cisco = $routes4 | Where-Object { $_.InterfaceAlias -like '*Cisco*' -or $_.DestinationPrefix -like '192.168.11.*' } | Select-Object -First 1
    if ($cisco) {
        Write-Host ("Cisco VPN:   {0} ({1}, metric {2})" -f $cisco.NextHop, $cisco.InterfaceAlias, $cisco.RouteMetric) -ForegroundColor Magenta
    }
    
    Write-Host ""
    Write-Host "=== IPv6 ROUTES ===" -ForegroundColor Yellow
    $routes6 = Get-NetRoute -AddressFamily IPv6 | Where-Object {
        $_.DestinationPrefix -ne '::1/128' -and $_.DestinationPrefix -notlike 'ff00::*'
    } | Sort-Object RouteMetric, DestinationPrefix
    
    if ($routes6.Count -eq 0) {
        Write-Host "No IPv6 routes found" -ForegroundColor Yellow
    } else {
        $routes6 |
            Select-Object DestinationPrefix, NextHop, InterfaceAlias,
                @{Name='Metric';Expression={$_.RouteMetric}} |
            Format-Table -AutoSize
    }
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    exit 1
}
