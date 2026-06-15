# 🔐 RoutingTable - PowerShell Network & VPN Management

![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Windows](https://img.shields.io/badge/Windows-10/11-0078D4)
![License](https://img.shields.io/badge/License-MIT-green)

> Windows PowerShell утилиты для диагностики таблицы маршрутизации и управления IKEv2 VPN подключениями к strongSwan серверу.

---

## 📦 Содержимое

| Файл | Описание |
|------|---------|
| **RoutingTable.ps1** | Диагностика сетевых интерфейсов и таблицы маршрутизации (IPv4/IPv6) |
| **CreateVPNConnection.ps1** | Автоматическое создание IKEv2 VPN подключения |
| **getnic.ps1** | Список активных сетевых адаптеров с параметрами |

---

## 🚀 Быстрый старт

### Просмотр таблицы маршрутизации
```powershell
# Запусти скрипт (требуется PowerShell 5.1+)
.\RoutingTable.ps1

# Вывод:
# === АКТИВНЫЕ ИНТЕРФЕЙСЫ ===
# Ethernet
#   IPv4 : 192.168.1.100/24
#   GW   : 192.168.1.1
#   DNS  : 8.8.8.8, 8.8.4.4
#
# === IPv4 МАРШРУТЫ ===
# ... (таблица маршрутов)
```

### Просмотр сетевых адаптеров
```powershell
.\getnic.ps1

# Откроется интерактивное окно с таблицей адаптеров
```

### Создание VPN подключения
```powershell
# С параметрами по умолчанию:
.\CreateVPNConnection.ps1

# С пользовательскими параметрами:
.\CreateVPNConnection.ps1 -ServerAddress "your-vpn-server.com" `
                           -Username "your-username" `
                           -ConnectionName "my-vpn"
```

---

## 🔧 Требования

- ✅ **ОС:** Windows 10, Windows 11, Windows Server 2016+
- ✅ **PowerShell:** 5.1 или выше
- ✅ **Права:** Администратор (для изменения VPN и маршрутов)
- ✅ **Сеть:** Доступ к strongSwan серверу (IKEv2)

---

## 📋 Описание скриптов

### RoutingTable.ps1
Компактный инструмент для диагностики сетевой конфигурации:
- ✓ Список активных интерфейсов с IPv4/IPv6, шлюзами и DNS
- ✓ Таблица IPv4 маршрутов (с фильтрацией служебных маршрутов)
- ✓ Таблица IPv6 маршрутов
- ✓ Выделение критических маршрутов (default, WireGuard, Cisco VPN)
- ✓ Цветной вывод для удобства

**Пример:**
```
=== КЛЮЧЕВЫЕ МАРШРУТЫ ===
По умолчанию: 192.168.1.1 через Ethernet (метрика 256)
WireGuard:    10.8.0.0/24 (WireGuard Adapter, метрика 0)
```

### CreateVPNConnection.ps1
Автоматизация создания IKEv2 VPN подключения:
- ✓ Проверка и удаление существующего подключения
- ✓ Создание подключения с параметризацией
- ✓ Настройка IPsec (GCMAES128, ECP256, SHA256)
- ✓ Split Tunneling поддержка
- ✓ Вывод инструкций по подключению

**Параметры:**
```powershell
-ServerAddress    : IP/FQDN сервера (по умолчанию: 45.152.86.79)
-Username         : Имя пользователя (по умолчанию: winuser)
-ConnectionName   : Имя подключения (по умолчанию: roadwarrior)
```

### getnic.ps1
Интерактивный просмотр сетевых адаптеров:
- ✓ Фильтрация физических адаптеров (исключает туннели, WAN Miniport)
- ✓ Вывод в интерактивную таблицу (Out-GridView)
- ✓ Параметры: MAC, Link Speed, IPv4/IPv6, Gateway, DNS, Profile

---

## 🔒 Безопасность

⚠️ **Важно:**
- Скрипты содержат пример конфигурации. Используйте свои реальные параметры!
- Пароли VPN **не сохраняются** в скриптах (требуется ввод при подключении)
- Используйте `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned` перед запуском
- Запускайте скрипты от администратора

**Рекомендации:**
```powershell
# Разрешить локальные скрипты
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Запустить скрипт
powershell -ExecutionPolicy Bypass -File .\RoutingTable.ps1
```

---

## 💡 Примеры использования

### Мониторинг маршрутов
```powershell
# Запускай регулярно для проверки активного маршрута
.\RoutingTable.ps1 | Out-File -FilePath "routing-log.txt" -Append
```

### Автоматизация подключения
```powershell
# В PowerShell профиле ($PROFILE):
$vpnName = "roadwarrior"
if ((Get-VpnConnection -Name $vpnName -ErrorAction SilentlyContinue) -eq $null) {
    .\CreateVPNConnection.ps1
}
```

### Скрипт для проверки статуса VPN
```powershell
$vpnStatus = Get-VpnConnection -Name "roadwarrior" -ErrorAction SilentlyContinue
if ($vpnStatus) {
    Write-Host "✓ VPN подключение доступно" -ForegroundColor Green
} else {
    Write-Host "✗ VPN подключение не найдено" -ForegroundColor Red
}
```

---

## 🐛 Известные проблемы

- Скрипты требуют права администратора для модификации маршрутов
- IPv6 поддержка зависит от конфигурации системы
- strongSwan сервер должен поддерживать IKEv2 + EAP-MSCHAPv2

---

## 📝 Версионирование

| Версия | Дата | Изменения |
|--------|------|-----------|
| 1.0.0 | 2026-06-15 | Первый релиз (RoutingTable, CreateVPN, getnic) |

---

## 📧 Автор

**Igor Lytkin** ([@IgorLytkin](https://github.com/IgorLytkin))  
Email: [i.lytkin@jurkomp.ru](mailto:i.lytkin@jurkomp.ru)

---

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) для деталей

---

## 🤝 Вклад

Если у вас есть идеи для улучшения:
1. Создайте Issue
2. Сделайте Fork
3. Создайте Pull Request

---

## 📚 Ссылки

- [strongSwan Documentation](https://www.strongswan.org/documentation.html)
- [PowerShell Documentation](https://learn.microsoft.com/powershell/)
- [Windows VPN Routing](https://learn.microsoft.com/en-us/windows-server/remote/remote-access/vpn/vpn-routing)
