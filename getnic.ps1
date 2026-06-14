$adapters = Get-NetAdapter -IncludeHidden | Sort-Object InterfaceIndex

$result = foreach ($nic in $adapters) {
    $cfg = Get-NetIPConfiguration -InterfaceAlias $nic.InterfaceAlias -Detailed -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Name                 = $nic.Name
        InterfaceAlias       = $nic.InterfaceAlias
        InterfaceDescription = $nic.InterfaceDescription
        InterfaceIndex       = $nic.InterfaceIndex
        Status               = $nic.Status
        MacAddress           = $nic.MacAddress
        LinkSpeed            = $nic.LinkSpeed
        IPv4Address          = if ($cfg) { ($cfg.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', ' } else { $null }
        IPv6Address          = if ($cfg) { ($cfg.IPv6Address | ForEach-Object { $_.IPAddress }) -join ', ' } else { $null }
        IPv4Gateway          = if ($cfg) { ($cfg.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ' } else { $null }
        IPv6Gateway          = if ($cfg) { ($cfg.IPv6DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ' } else { $null }
        DnsServers           = if ($cfg) { ($cfg.DnsServer.ServerAddresses) -join ', ' } else { $null }
        ProfileName          = if ($cfg) { $cfg.NetProfile.Name } else { $null }
    }
}

$result | Format-Table -AutoSize