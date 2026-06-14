# =============================================================================
# IKEv2 VPN Connection Creator for strongSwan Server (FINAL VERSION)
# =============================================================================

$ServerAddress = "45.152.86.79"
$Username = "winuser"
$ConnectionName = "roadwarrior"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  IKEv2 VPN Connection Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Green
Write-Host "  Server:     $ServerAddress"
Write-Host "  Username:   $Username"
Write-Host "  Connection: $ConnectionName"
Write-Host "  Protocol:   IKEv2 + EAP_MSCHAPV2"
Write-Host ""

# Remove existing VPN connection
Write-Host "Checking for existing VPN connection..." -ForegroundColor Yellow
$existingVpn = Get-VpnConnection -Name $ConnectionName -ErrorAction SilentlyContinue

if ($existingVpn) {
    Write-Host "Found '$ConnectionName'. Removing..." -ForegroundColor Yellow
    Remove-VpnConnection -Name $ConnectionName -Force
    Write-Host "Removed." -ForegroundColor Green
    Write-Host ""
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
    -DnsSuffix "singularity.local"

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
Write-Host "  VPN Created Successfully!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Name:       $ConnectionName"
Write-Host "Server:     $ServerAddress"
Write-Host "Username:   $Username"
Write-Host "Protocol:   IKEv2 + EAP"
Write-Host ""
Write-Host "🔐 PAROЛЬ нужно ввести вручную при подключении!" -ForegroundColor Yellow
Write-Host "   Username: $Username"
Write-Host "   Password: (введи свой пароль)"
Write-Host ""
Write-Host "🚀 Подключиться:" -ForegroundColor Green
Write-Host "   Connect-VpnConnection -Name '$ConnectionName'"
Write-Host ""
Write-Host "   Или через GUI: Пуск → Settings → Network → VPN → roadwarrior → Connect"
Write-Host ""