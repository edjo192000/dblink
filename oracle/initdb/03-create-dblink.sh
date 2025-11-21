#!/bin/bash
# Script para crear el Database Link en Oracle

echo "=== Creando Database Link en Oracle ==="

# Variables de entorno
export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
export ORACLE_SID=XE
export PATH=$ORACLE_HOME/bin:$PATH

# Esperar a que el listener esté completamente configurado
sleep 10

# Conectar a Oracle y crear el DBLink
sqlplus -s system/12345@XE <<'EOSQL'
SET ECHO ON
SET SERVEROUTPUT ON

-- Parte 6: Crear el Database Link en Oracle
PROMPT === Creando Database Link ===

-- Eliminar DBLink si ya existe
BEGIN
   EXECUTE IMMEDIATE 'DROP DATABASE LINK mariadblk';
   DBMS_OUTPUT.PUT_LINE('Database link anterior eliminado');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('No existía database link previo');
END;
/

-- Crear el Database Link
CREATE DATABASE LINK mariadblk
CONNECT TO "oracle_user" IDENTIFIED BY "12345"
USING 'mariadb';

PROMPT Database Link 'mariadblk' creado exitosamente

-- Parte 7: Validación
PROMPT === Validación del Database Link ===

-- Consultar cantidad de registros
PROMPT Consultando cantidad de registros:
SELECT COUNT(*) as total_registros FROM alumnos@mariadblk;

-- Consultar todos los datos
PROMPT Consultando todos los datos:
SELECT * FROM alumnos@mariadblk;

-- Insertar un nuevo registro desde Oracle
PROMPT Insertando nuevo registro desde Oracle:
INSERT INTO alumnos@mariadblk
VALUES (4, 'David', 'Redes y Telecomunicaciones');
COMMIT;

-- Verificar la inserción
PROMPT Verificando datos después de la inserción:
SELECT * FROM alumnos@mariadblk;

PROMPT === Validación completada exitosamente ===

EXIT;
EOSQL

echo "=== Database Link creado y validado ==="
