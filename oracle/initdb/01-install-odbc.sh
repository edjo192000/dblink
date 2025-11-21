#!/bin/bash
# Script para instalar driver ODBC de MariaDB en Oracle XE

echo "=== Instalando driver ODBC de MariaDB ==="

# Actualizar repositorios e instalar dependencias
microdnf install -y wget tar gzip unixODBC unixODBC-devel

# Descargar e instalar MariaDB Connector/ODBC
cd /tmp
wget https://dlm.mariadb.com/2701221/Connectors/odbc/connector-odbc-3.1.1/mariadb-connector-odbc-3.1.1-rhel8-x86_64.tar.gz
tar -xzf mariadb-connector-odbc-3.1.1-rhel8-x86_64.tar.gz

# Copiar la librería ODBC
mkdir -p /usr/lib64/mariadb
cp mariadb-connector-odbc-3.1.1-rhel8-x86_64/lib64/libmaodbc.so /usr/lib64/mariadb/

# Crear configuración ODBC
cat > /etc/odbc.ini <<'EOF'
[mariadb]
Description=MariaDB ODBC Connection
Driver=MariaDB ODBC Driver
SERVER=mariadb
PORT=3306
DATABASE=testdb
USER=oracle_user
PASSWORD=12345
OPTION=3
EOF

cat > /etc/odbcinst.ini <<'EOF'
[MariaDB ODBC Driver]
Description=MariaDB Connector/ODBC
Driver=/usr/lib64/mariadb/libmaodbc.so
FileUsage=1
EOF

echo "=== Driver ODBC instalado y configurado ==="
echo "Configuración ODBC:"
cat /etc/odbc.ini
echo ""
cat /etc/odbcinst.ini
