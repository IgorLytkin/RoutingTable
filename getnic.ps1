# Получаем только физические/активные адаптеры (исключаем туннельные и WAN Miniport)
$adapters = Get-NetAdapter -IncludeHidden | 
    Where-Object { 
        $_.InterfaceDescription -notmatch 'WAN Miniport|6to4|IP-HTTPS|Teredo|отладчик ядра' -and
        $_.Status -eq 'Up'
    } |
    Sort-Object InterfaceIndex

$result = foreach ($nic in $adapters) {
    $cfg = try {
        Get-NetIPConfiguration -InterfaceAlias $nic.InterfaceAlias -Detailed -ErrorAction SilentlyContinue
    } catch {
        $null
    }

    [PSCustomObject]@{
        Name             = $nic.Name
        InterfaceAlias   = $nic.InterfaceAlias
        InterfaceDescription = $nic.InterfaceDescription
        InterfaceIndex   = $nic.InterfaceIndex
        Status           = $nic.Status
        MacAddress       = $nic.MacAddress
        LinkSpeed        = $nic.LinkSpeed
        IPv4Address      = if ($cfg) { ($cfg.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', ' } else { $null }
        IPv6Address      = if ($cfg) { ($cfg.IPv6Address | ForEach-Object { $_.IPAddress }) -join ', ' } else { $null }
        IPv4Gateway      = if ($cfg) { ($cfg.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ' } else { $null }
        IPv6Gateway      = if ($cfg) { ($cfg.IPv6DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ' } else { $null }
        DnsServers       = if ($cfg) { ($cfg.DnsServer.ServerAddresses) -join ', ' } else { $null }
        ProfileName      = if ($cfg) { $cfg.NetProfile.Name } else { $null }
    }
}

# Вывод в виде интерактивного окна с таблицей
$result | Out-GridView -Title "NetAdapters" -PassThru