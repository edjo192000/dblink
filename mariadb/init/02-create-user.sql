-- Crear usuario con acceso remoto
-- El usuario oracle_user ya se crea automáticamente con MYSQL_USER
-- Solo necesitamos asegurar que tenga permisos desde cualquier host

USE mysql;

-- Otorgar permisos completos al usuario oracle_user
GRANT ALL PRIVILEGES ON testdb.* TO 'oracle_user'@'%';
FLUSH PRIVILEGES;

SELECT 'Usuario oracle_user configurado con permisos en testdb' as mensaje;
