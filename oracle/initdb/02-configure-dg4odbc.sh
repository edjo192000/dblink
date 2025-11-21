#!/bin/bash
# Script para configurar Database Gateway for ODBC (DG4ODBC)

echo "=== Configurando DG4ODBC ==="

# Esperar a que Oracle esté completamente iniciado
echo "Esperando a que Oracle esté listo..."
sleep 30

# Variables de entorno
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=$ORACLE_HOME/bin:$PATH

# Crear directorio para configuración de DG4ODBC
mkdir -p $ORACLE_HOME/hs/admin

# Crear archivo initmariadb.ora
cat > $ORACLE_HOME/hs/admin/initmariadb.ora <<'EOF'
# initmariadb.ora - Configuración para DG4ODBC
HS_FDS_CONNECT_INFO = mariadb
HS_FDS_TRACE_LEVEL = OFF
HS_FDS_SHAREABLE_NAME = /usr/lib64/mariadb/libmaodbc.so
HS_FDS_SUPPORT_STATISTICS = FALSE
HS_LANGUAGE = AMERICAN_AMERICA.AL32UTF8

# Establecer variables de entorno para ODBC
set ODBCSYSINI=/etc
set ODBCINI=/etc/odbc.ini
EOF

echo "Archivo initmariadb.ora creado:"
cat $ORACLE_HOME/hs/admin/initmariadb.ora

# Configurar listener.ora
cat > $ORACLE_HOME/network/admin/listener.ora <<EOF
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = mariadb)
      (ORACLE_HOME = $ORACLE_HOME)
      (PROGRAM = dg4odbc)
    )
  )
EOF

echo "Archivo listener.ora configurado:"
cat $ORACLE_HOME/network/admin/listener.ora

# Configurar tnsnames.ora
cat > $ORACLE_HOME/network/admin/tnsnames.ora <<EOF
XE =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE)
    )
  )

LISTENER_XE =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))

ORACLR_CONNECTION_DATA =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
    (CONNECT_DATA =
      (SID = CLRExtProc)
      (PRESENTATION = RO)
    )
  )

mariadb =
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID=mariadb))
    (HS=OK)
  )
EOF

echo "Archivo tnsnames.ora configurado:"
cat $ORACLE_HOME/network/admin/tnsnames.ora

# Reiniciar el listener
echo "=== Reiniciando listener ==="
lsnrctl stop
sleep 5
lsnrctl start

echo "=== Estado del listener ==="
lsnrctl status

echo "=== Configuración de DG4ODBC completada ==="
