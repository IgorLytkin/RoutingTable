# Сброс пароля учётной записи Admin в контейнере Zabbix
sudo docker exec -i zabbix-mysql-server-1 mysql -uroot -proot_pwd zabbix <<'SQL'
UPDATE users
SET passwd = '$2a$10$ZXIvHAEP2ZM.dLXTm6uPHOMVlARXX7cqjbhM6Fn0cANzkCQBWpMrS'
WHERE username = 'Admin';
SQL