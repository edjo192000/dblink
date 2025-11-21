#!/bin/bash
# Script maestro que ejecuta todos los pasos de configuración

echo "======================================"
echo "Configuración de DBLink Oracle-MariaDB"
echo "======================================"

# Esperar a que Oracle esté completamente iniciado
echo "Esperando a que Oracle Database esté listo..."
max_attempts=30
attempt=0

until echo exit | sqlplus -s system/12345@XE > /dev/null 2>&1; do
    attempt=$((attempt+1))
    if [ $attempt -ge $max_attempts ]; then
        echo "ERROR: Oracle Database no está disponible después de $max_attempts intentos"
        exit 1
    fi
    echo "Intento $attempt/$max_attempts - Esperando Oracle Database..."
    sleep 10
done

echo "Oracle Database está listo!"

# Ejecutar scripts de configuración
echo ""
echo "=== Paso 1: Instalando driver ODBC ==="
bash /opt/oracle/scripts/startup/01-install-odbc.sh

echo ""
echo "=== Paso 2: Configurando DG4ODBC ==="
bash /opt/oracle/scripts/startup/02-configure-dg4odbc.sh

echo ""
echo "=== Paso 3: Esperando a que MariaDB tenga datos ==="
sleep 15

echo ""
echo "=== Paso 4: Creando Database Link ==="
bash /opt/oracle/scripts/startup/03-create-dblink.sh

echo ""
echo "======================================"
echo "Configuración completada!"
echo "======================================"
echo ""
echo "Para probar el Database Link, ejecuta:"
echo "docker exec -it oracle-xe-dblink sqlplus system/12345@XE"
echo ""
echo "Luego ejecuta:"
echo "SELECT * FROM alumnos@mariadblk;"
