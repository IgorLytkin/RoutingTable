# Подготовка к введению в домен
C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown

# Переименовать сервер в top-fs1
Rename-Computer -NewName "top-fs1" -Force -Restart

# Простое введение сервера в домен
$cred = Get-Credential
Add-Computer -DomainName "top.local" -Credential $cred -Restart -Force

# Введение сервера в домен в заданный Organization Unit (OU)
$cred = Get-Credential
Add-Computer -DomainName "top.local" -OUPath "OU=Servers,DC=top,DC=local" -Credential $cred -Restart -Force

$Zone = "top.local"
$KmsHost = "vlmcs.lytkins.ru"
$RecordName = "_vlmcs._tcp"

# Настройка SRV-записи на эмулятор KMS для всего домена
Import-Module DnsServer

Add-DnsServerResourceRecord -ZoneName "top.local" `
  -Srv `
  -Name "_vlmcs._tcp" `
  -DomainName "vlmcsd.lytkins.ru" `
  -Priority 0 `
  -Weight 0 `
  -Port 1688 `
  -TimeToLive 01:00:00

  # Активация
$KmsHost = "vlmcsd.lytkins.ru:1688"
cscript.exe "$env:windir\system32\slmgr.vbs" /skms $KmsHost
cscript.exe "$env:windir\system32\slmgr.vbs" /ato

# Установить KMS client key для Windows Server 2019 Datacenter
cscript.exe "$env:windir\system32\slmgr.vbs" /ipk WMDGN-G9PQG-XVVXX-R3X43-63DFG

# Указать KMS-сервер
cscript.exe "$env:windir\system32\slmgr.vbs" /skms $KmsHost

# Запустить активацию
cscript.exe "$env:windir\system32\slmgr.vbs" /ato

# Показать статус
cscript.exe "$env:windir\system32\slmgr.vbs" /dlv

# Каталоги К+
$ShareRoot = "D:\Public"
$ConsultantRoot = "D:\Public\Consutant"
$AdmPath = "D:\Public\Consutant\ADM"
$ShareName = "Public"
$NamespaceRoot = "\\top.local\dfs"
$LinkPath = "\\top.local\dfs\dfs-Consultant"
$TargetPath = "\\top-fs1.top.local\Public\Consutant"

New-Item -ItemType Directory -Path $ShareRoot -Force | Out-Null
New-Item -ItemType Directory -Path $ConsultantRoot -Force | Out-Null
New-Item -ItemType Directory -Path $AdmPath -Force | Out-Null

if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $ShareRoot -FullAccess "DOMAIN Admins","Administrators"
}

if (-not (Get-DfsnRoot -Path $NamespaceRoot -ErrorAction SilentlyContinue)) {
    New-DfsnRoot -Type DomainV2 -Path $NamespaceRoot -TargetPath "\\top-fs1.top.local\Public"
}

if (-not (Get-DfsnFolder -Path $LinkPath -ErrorAction SilentlyContinue)) {
    New-DfsnFolder -Path $LinkPath -TargetPath $TargetPath
}