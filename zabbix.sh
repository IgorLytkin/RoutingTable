# Сброс пароля учётной записи Admin в контейнере Zabbix
sudo docker exec -i zabbix-mysql-server-1 mysql -uroot -proot_pwd zabbix <<'SQL'
UPDATE users
SET passwd = '$2a$10$ZXIvHAEP2ZM.dLXTm6uPHOMVlARXX7cqjbhM6Fn0cANzkCQBWpMrS'
WHERE username = 'Admin';
SQL

# Вариант 2 скрипт
#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="zabbix-mysql-server-1"
DB_NAME="zabbix"
ROOT_PASS="root_pwd"
NEW_HASH='$2a$10$ZXIvHAEP2ZM.dLXTm6uPHOMVlARXX7cqjbhM6Fn0cANzkCQBWpMrS'

sudo docker exec -i "$DB_CONTAINER" mysql -uroot -p"$ROOT_PASS" "$DB_NAME" <<SQL
UPDATE users
SET passwd = '$NEW_HASH'
WHERE username = 'Admin';
SQL

echo "Admin password reset to zabbix"
