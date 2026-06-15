<#
.SYNOPSIS
    IKEv2 VPN Connection Creator for strongSwan Server

.DESCRIPTION
    Автоматическое создание и настройка IKEv2 VPN подключения на Windows 10/11.
    Поддерживает параметризацию для различных серверов и пользователей.

.PARAMETER ServerAddress
    IP адрес или FQDN strongSwan сервера
    По умолчанию: 45.152.86.79

.PARAMETER Username
    Имя пользователя для VPN подключения
    По умолчанию: winuser

.PARAMETER ConnectionName
    Имя создаваемого подключения в Windows
    По умолчанию: roadwarrior

.PARAMETER DnsSuffix
    DNS суффикс для подключения
    По умолчанию: singularity.local

.EXAMPLE
    .\CreateVPNConnection.ps1
    # Создаст подключение с параметрами по умолчанию

.EXAMPLE
    .\CreateVPNConnection.ps1 -ServerAddress "vpn.example.com" `
                              -Username "john.doe" `
                              -ConnectionName "MyVPN"
    # Создаст подключение с пользовательскими параметрами

.NOTES
    Требуется запуск от администратора
    PowerShell 5.1+
    Compatible with Windows 10/11, Windows Server 2016+
#>

param(
    [string]$ServerAddress = "45.152.86.79",
    [string]$Username = "winuser",
    [string]$ConnectionName = "roadwarrior",
    [string]$DnsSuffix = "singularity.local"
)

$ErrorActionPreference = 'Stop'

try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  IKEv2 VPN Connection Creator" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check for administrator rights
    $isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544')
    if (-not $isAdmin) {
        throw "This script must be run as Administrator!"
    }
    
    Write-Host "Configuration:" -ForegroundColor Green
    Write-Host "  Server:     $ServerAddress"
    Write-Host "  Username:   $Username"
    Write-Host "  Connection: $ConnectionName"
    Write-Host "  DNS Suffix: $DnsSuffix"
    Write-Host "  Protocol:   IKEv2 + EAP_MSCHAPV2"
    Write-Host ""
    
    # Check for existing VPN connection
    Write-Host "Checking for existing VPN connection..." -ForegroundColor Yellow
    $existingVpn = Get-VpnConnection -Name $ConnectionName -ErrorAction SilentlyContinue
    
    if ($existingVpn) {
        Write-Host "Found '$ConnectionName'. Removing..." -ForegroundColor Yellow
        Remove-VpnConnection -Name $ConnectionName -Force
        Write-Host "Removed." -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Milliseconds 500
    }
    
    # Create VPN connection
    Write-Host "Creating IKEv2 VPN connection..." -ForegroundColor Yellow
    
    Add-VpnConnection `
        -Name $ConnectionName `
        -ServerAddress $ServerAddress `
        -TunnelType IKEv2 `
        -AuthenticationMethod EAP `
        -EncryptionLevel Maximum `
        -RememberCredential `
        -SplitTunneling `
        -DnsSuffix $DnsSuffix `
        -Force
    
    Write-Host "✓ VPN connection created!" -ForegroundColor Green
    Write-Host ""
    
    # Configure IPsec
    Write-Host "Configuring IPsec..." -ForegroundColor Yellow
    
    Set-VpnConnectionIPsecConfiguration `
        -Name $ConnectionName `
        -AuthenticationTransformConstants GCMAES128 `
        -CipherTransformConstants GCMAES128 `
        -DHGroup ECP256 `
        -IntegrityCheckMethod SHA256 `
        -PfsGroup ECP256 `
        -EncryptionMethod GCMAES128 `
        -Force
    
    Write-Host "✓ IPsec configured!" -ForegroundColor Green
    Write-Host ""
    
    # Display summary
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  ✓ VPN Created Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Name:       $ConnectionName"
    Write-Host "Server:     $ServerAddress"
    Write-Host "Username:   $Username"
    Write-Host "Protocol:   IKEv2 + EAP"
    Write-Host ""
    Write-Host "🔐 Enter password when prompted during connection" -ForegroundColor Yellow
    Write-Host "   Username: $Username"
    Write-Host "   Password: (enter your password)"
    Write-Host ""
    Write-Host "🚀 To Connect:" -ForegroundColor Green
    Write-Host "   PowerShell:  Connect-VpnConnection -Name '$ConnectionName'"
    Write-Host "   GUI:         Start → Settings → Network → VPN → $ConnectionName → Connect"
    Write-Host ""

} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    exit 1
}
