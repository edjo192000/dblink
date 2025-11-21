# Práctica: Conexión DBLink entre MariaDB y Oracle XE 19c con Docker

Esta práctica implementa un Database Link (DBLink) que permite a Oracle XE consultar tablas de MariaDB utilizando Oracle Database Gateway for ODBC (DG4ODBC), completamente dockerizado para ejecutarse en Mac.

## Objetivo

Configurar y probar un Database Link (DBLink) que permita a Oracle XE 19c consultar tablas de MariaDB 8.0.44, utilizando Oracle Database Gateway for ODBC (DG4ODBC).

## Requisitos Previos

- **Docker Desktop** instalado y ejecutándose en Mac
- Al menos **8 GB de RAM** disponibles para Docker
- Aproximadamente **10 GB de espacio en disco**
- Conexión a Internet para descargar las imágenes

## Arquitectura de la Solución

```
┌─────────────────┐         ┌──────────────────┐
│   MariaDB 8.0   │◄───────┤   Oracle XE 21c  │
│                 │  ODBC  │                  │
│  - testdb       │         │  - DG4ODBC       │
│  - alumnos      │         │  - DBLink        │
└─────────────────┘         └──────────────────┘
```

## Estructura del Proyecto

```
dblink/
├── docker-compose.yml          # Orquestación de contenedores
├── mariadb/
│   └── init/
│       ├── 01-create-table.sql # Crea tabla alumnos
│       └── 02-create-user.sql  # Configura usuario oracle_user
├── oracle/
│   └── initdb/
│       ├── 00-wait-and-setup.sh    # Script maestro
│       ├── 01-install-odbc.sh      # Instala driver ODBC
│       ├── 02-configure-dg4odbc.sh # Configura DG4ODBC
│       └── 03-create-dblink.sh     # Crea y valida DBLink
└── README.md
```

## Pasos para Ejecutar la Práctica

### 1. Iniciar los Contenedores

```bash
# Levantar los servicios
docker-compose up -d

# Ver los logs (esto puede tomar 5-10 minutos en la primera ejecución)
docker-compose logs -f
```

**Nota:** La primera vez descargará la imagen de Oracle (~8 GB), lo cual puede tardar varios minutos dependiendo de tu conexión a Internet.

### 2. Verificar que los Servicios Estén Listos

```bash
# Verificar estado de los contenedores
docker-compose ps

# Verificar logs de Oracle
docker logs oracle-xe-dblink

# Verificar logs de MariaDB
docker logs mariadb-dblink
```

Espera hasta que veas mensajes indicando que ambos servicios están listos.

### 3. Ejecutar la Configuración Automática

Los scripts de configuración se ejecutan automáticamente al iniciar el contenedor de Oracle. Para verificar el progreso:

```bash
# Ver logs del proceso de configuración
docker exec -it oracle-xe-dblink tail -f /opt/oracle/scripts/startup/setup.log
```

### 4. Validar la Configuración

#### Conectarse a Oracle y Probar el DBLink

```bash
# Conectar a Oracle
docker exec -it oracle-xe-dblink sqlplus system/12345@XE
```

Una vez conectado, ejecuta:

```sql
-- Consultar datos desde MariaDB a través del DBLink
SELECT * FROM alumnos@mariadblk;

-- Insertar un nuevo registro
INSERT INTO alumnos@mariadblk
VALUES (5, 'María García', 'Ciencias de la Computación');
COMMIT;

-- Verificar la inserción
SELECT * FROM alumnos@mariadblk;

-- Salir
EXIT;
```

#### Conectarse a MariaDB Directamente

```bash
# Conectar a MariaDB
docker exec -it mariadb-dblink mysql -u oracle_user -p12345 testdb
```

Una vez conectado:

```sql
-- Ver todos los registros (incluyendo los insertados desde Oracle)
SELECT * FROM alumnos;

-- Salir
EXIT;
```

## Configuración Detallada

### Parte 1: MariaDB

La base de datos MariaDB se configura automáticamente con:

- **Base de datos:** `testdb`
- **Usuario:** `oracle_user`
- **Contraseña:** `12345`
- **Tabla:** `alumnos` (id, nombre, carrera)
- **Datos iniciales:** Ana Torres, Luis Gómez

### Parte 2: ODBC

El driver ODBC de MariaDB se instala automáticamente en el contenedor de Oracle:

- **Driver:** MariaDB Connector/ODBC 3.1.1
- **DSN:** `mariadb`
- **Configuración:** `/etc/odbc.ini` y `/etc/odbcinst.ini`

### Parte 3: DG4ODBC (Database Gateway for ODBC)

Oracle Database Gateway se configura con:

- **Archivo:** `$ORACLE_HOME/hs/admin/initmariadb.ora`
- **Parámetros clave:**
  - `HS_FDS_CONNECT_INFO = mariadb`
  - `HS_FDS_SHAREABLE_NAME = /usr/lib64/mariadb/libmaodbc.so`

### Parte 4: Oracle Listener

El listener se configura para escuchar conexiones del gateway:

```
SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = mariadb)
      (ORACLE_HOME = /opt/oracle/product/21c/dbhomeXE)
      (PROGRAM = dg4odbc)
    )
  )
```

### Parte 5: TNS Names

El archivo `tnsnames.ora` incluye la entrada para el DBLink:

```
mariadb =
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID=mariadb))
    (HS=OK)
  )
```

### Parte 6: Database Link

El DBLink se crea con:

```sql
CREATE DATABASE LINK mariadblk
CONNECT TO "oracle_user" IDENTIFIED BY "12345"
USING 'mariadb';
```

## Solución de Problemas

### El contenedor de Oracle no inicia

```bash
# Verificar logs
docker logs oracle-xe-dblink

# Aumentar memoria de Docker a 8GB en Docker Desktop > Preferences > Resources
```

### Error "ORA-12154: TNS:could not resolve the connect identifier"

```bash
# Verificar configuración de tnsnames.ora
docker exec oracle-xe-dblink cat /opt/oracle/product/21c/dbhomeXE/network/admin/tnsnames.ora

# Verificar estado del listener
docker exec oracle-xe-dblink lsnrctl status
```

### Error "ORA-02068: following severe error from mariadblk"

```bash
# Verificar conectividad entre contenedores
docker exec oracle-xe-dblink ping mariadb

# Verificar configuración ODBC
docker exec oracle-xe-dblink cat /etc/odbc.ini

# Probar conexión ODBC directamente
docker exec oracle-xe-dblink isql -v mariadb
```

### MariaDB no acepta conexiones

```bash
# Verificar que MariaDB esté corriendo
docker exec mariadb-dblink mysqladmin -u root -prootpass ping

# Verificar usuarios
docker exec mariadb-dblink mysql -u root -prootpass -e "SELECT user, host FROM mysql.user;"
```

## Comandos Útiles

```bash
# Reiniciar todos los servicios
docker-compose restart

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (CUIDADO: elimina datos)
docker-compose down -v

# Ver recursos utilizados
docker stats

# Ejecutar configuración manualmente
docker exec -it oracle-xe-dblink bash /opt/oracle/scripts/startup/00-wait-and-setup.sh

# Reiniciar solo el listener de Oracle
docker exec oracle-xe-dblink lsnrctl stop
docker exec oracle-xe-dblink lsnrctl start
```

## Adaptaciones de la Práctica Original

Esta implementación adapta la práctica original de Windows a Docker:

| Aspecto | Windows Original | Docker (Mac/Linux) |
|---------|------------------|-------------------|
| SO | Windows 10/11 | Linux (contenedor) |
| Instalación Oracle | Manual | Imagen oficial |
| Instalación MariaDB | Manual | Imagen oficial |
| Driver ODBC | Instalación MSI | Instalación desde tarball |
| Configuración | GUI ODBC | Archivos de configuración |
| Ruta archivos | `C:\app\Alfredo\...` | `/opt/oracle/...` |
| Host MariaDB | `localhost` | `mariadb` (nombre del servicio) |

## Limpieza

Para limpiar completamente el entorno:

```bash
# Detener y eliminar contenedores y volúmenes
docker-compose down -v

# Eliminar imágenes (opcional)
docker rmi mariadb:8.0.44
docker rmi container-registry.oracle.com/database/express:21.3.0-xe
```

## Referencias

- [Oracle Database Gateway for ODBC Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/heter/)
- [MariaDB Connector/ODBC](https://mariadb.com/kb/en/about-mariadb-connector-odbc/)
- [Oracle Database Express Edition](https://www.oracle.com/database/technologies/xe-downloads.html)

## Notas Importantes

1. **Contraseñas:** Las contraseñas utilizadas (`12345`, `rootpass`) son solo para propósitos educativos. En producción, usa contraseñas seguras.

2. **Primera ejecución:** La primera vez que ejecutes `docker-compose up` puede tardar 10-15 minutos mientras se descargan las imágenes y se configuran las bases de datos.

3. **Recursos:** Oracle XE requiere al menos 2 GB de RAM. Asegúrate de tener suficientes recursos asignados a Docker.

4. **Persistencia:** Los datos se mantienen en volúmenes de Docker. Si ejecutas `docker-compose down -v`, perderás todos los datos.

5. **Compatibilidad:** Esta configuración funciona en:
   - macOS (Intel y Apple Silicon)
   - Linux
   - Windows con WSL2

## Licencia

Esta práctica es con fines educativos. Oracle y MariaDB tienen sus propias licencias respectivas.
