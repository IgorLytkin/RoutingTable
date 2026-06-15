$adapters = Get-NetAdapter -IncludeHidden | Sort-Object InterfaceIndex

$result = foreach ($nic in $adapters) {
    # Проверка: есть ли у адаптера IP-интерфейс
    $hasIPInterface = Get-NetIPInterface -InterfaceAlias $nic.InterfaceAlias -ErrorAction SilentlyContinue
    
    $cfg = if ($hasIPInterface) {
        Get-NetIPConfiguration -InterfaceAlias $nic.InterfaceAlias -Detailed -ErrorAction SilentlyContinue
    } else {
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