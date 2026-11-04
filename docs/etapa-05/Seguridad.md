
# Etapa V — Seguridad y control de acceso en SQL Server

**Proyecto:** Sistema de Gestión de Ventas e Inventario para Tienda de Insumos de Impresión 3D (`Tienda3D`)  
**Equipo:** 39  
**Período de pruebas:** noviembre de 2026  
**Motor utilizado:** SQL Server Express  
**Herramienta de administración:** SQL Server Management Studio (SSMS)

---

## 1. Definición y objetivo

La seguridad de una base de datos comprende los mecanismos que controlan **quién puede acceder al sistema** y **qué operaciones puede realizar** sobre la información almacenada.

SQL Server permite implementar controles de acceso a nivel del servidor, de la base de datos y de objetos específicos, como tablas, vistas y procedimientos almacenados.

En `Tienda3D` se implementó un esquema de seguridad destinado a diferenciar las responsabilidades de administradores, vendedores y usuarios con o sin autorización de consulta.

Los objetivos principales fueron:

- Configurar el mecanismo de autenticación de SQL Server.
- Crear inicios de sesión y usuarios de base de datos.
- Definir roles con diferentes responsabilidades.
- Asignar permisos específicos sobre tablas y procedimientos almacenados.
- Restringir las operaciones directas no autorizadas.
- Verificar el funcionamiento de los controles mediante pruebas SQL.
- Documentar los resultados obtenidos mediante evidencias.

Los archivos correspondientes se encuentran en:

`sql/tecnico/seguridad/`

---

## 2. Marco teórico

### 2.1. Autenticación y autorización

La **autenticación** es el proceso mediante el cual SQL Server verifica la identidad de quien intenta conectarse al servidor.

La **autorización** determina qué operaciones puede realizar una entidad autenticada sobre los recursos de la base de datos.

En SQL Server se distinguen dos entidades principales:

| Concepto | Definición | Alcance |
| --- | --- | --- |
| **LOGIN** | Entidad de seguridad que permite autenticarse en una instancia de SQL Server. | Servidor |
| **USER** | Entidad de seguridad perteneciente a una base de datos, mediante la cual se administran permisos y roles. | Base de datos |

En la implementación realizada se utilizaron inicios de sesión de tipo `SQL_LOGIN`, asociados a usuarios de `Tienda3D` mediante `CREATE USER ... FOR LOGIN`.

De esta manera, la autenticación se administra en el servidor, mientras que los permisos sobre los objetos se controlan dentro de la base de datos.

### 2.2. Modos de autenticación en SQL Server

SQL Server admite dos modalidades principales:

| Modalidad | Descripción |
| --- | --- |
| **Autenticación de Windows** | Utiliza identidades administradas por Windows. |
| **Autenticación mixta** | Permite autenticación de Windows y autenticación propia de SQL Server. |

Para las pruebas se configuró el modo **SQL Server y Windows**, también denominado autenticación mixta.

### 2.3. Comandos de administración de permisos

SQL Server proporciona instrucciones específicas para controlar el acceso a los objetos.

| Comando | Función | Ejemplo |
| --- | --- | --- |
| `GRANT` | Concede explícitamente un permiso. | `GRANT SELECT` |
| `DENY` | Establece una denegación explícita. | `DENY INSERT` |
| `REVOKE` | Retira una concesión o denegación previamente establecida. | `REVOKE SELECT` |

**GRANT**

Permite autorizar una operación determinada sobre un objeto.

```sql
GRANT SELECT ON dbo.Producto TO rol_vendedor;
```

**DENY**

Permite establecer una restricción explícita. En general, una denegación tiene precedencia sobre permisos concedidos por otras vías, aunque el modelo de seguridad de SQL Server contempla excepciones.

```sql
DENY INSERT ON dbo.Venta TO usuario_lector_prueba;
```

**REVOKE**

Elimina una concesión o denegación explícita sin establecer necesariamente una prohibición.

```sql
REVOKE SELECT ON dbo.Producto FROM usuario_lector_prueba;
```

**Aclaración:** los ejemplos de `DENY` y `REVOKE` anteriores son ilustrativos. Los scripts ejecutados para esta etapa utilizaron concesiones `GRANT` y no incorporaron esas instrucciones de denegación o revocación.

La ausencia de un permiso también puede producir el rechazo de una operación, como se observó en las pruebas que devolvieron el error 229.

### 2.4. Roles de base de datos

Un **rol** es una entidad de seguridad que permite agrupar usuarios y administrar permisos de manera conjunta.

En lugar de asignar individualmente los mismos permisos a múltiples usuarios, se pueden conceder al rol y posteriormente incorporar sus miembros.

Las principales ventajas son:

1. **Administración centralizada:** simplifica la gestión de permisos.
2. **Separación de responsabilidades:** permite distinguir diferentes perfiles operativos.
3. **Mantenimiento:** facilita incorporar o retirar usuarios sin repetir todas las autorizaciones.
4. **Consistencia:** permite aplicar un mismo conjunto de permisos a usuarios con funciones equivalentes.
5. **Seguridad:** ayuda a limitar el acceso a los recursos necesarios para cada tarea.

SQL Server dispone de roles predefinidos, como `db_owner`, y permite crear roles personalizados mediante `CREATE ROLE`.

### 2.5. Principio de mínimo privilegio

El **principio de mínimo privilegio** establece que cada usuario debe disponer únicamente de los permisos necesarios para desarrollar sus funciones.

Aplicado a `Tienda3D`, esto significa que:

- El administrador puede realizar tareas de administración de la base de datos.
- El vendedor puede consultar productos y ejecutar el procedimiento autorizado para registrar ventas.
- El usuario de consulta puede acceder al catálogo mediante su rol.
- Un usuario sin los permisos requeridos no puede realizar las operaciones protegidas.

Este principio reduce las posibilidades de modificaciones accidentales y accesos no autorizados.

### 2.6. Permiso EXECUTE y procedimientos almacenados

Los procedimientos almacenados permiten encapsular operaciones SQL y ofrecer una interfaz controlada para determinadas acciones del sistema.

El permiso `EXECUTE` autoriza a un usuario a ejecutar un procedimiento, pero no le concede automáticamente permisos directos de `INSERT`, `UPDATE` o `DELETE` sobre las tablas que utiliza.

En el proyecto se utilizó:

```sql
GRANT EXECUTE
ON dbo.sp_RegistrarVenta3D
TO usuario_lector_prueba;
```

Esta autorización permite ejecutar la operación de venta mediante el procedimiento almacenado.

### 2.7. Cadena de propiedad (Ownership Chaining)

SQL Server implementa un mecanismo denominado **cadena de propiedad**, conocido como *ownership chaining*.

Cuando un procedimiento almacenado y los objetos a los que accede comparten el mismo propietario, SQL Server puede omitir determinadas comprobaciones de permisos sobre los objetos subyacentes utilizados por instrucciones DML estáticas.

Esto permite que un usuario ejecute operaciones encapsuladas sin disponer necesariamente de permisos directos sobre todas las tablas involucradas.

El mecanismo depende de la propiedad efectiva de los objetos y no solamente de que sus nombres utilicen el esquema `dbo`. Asimismo, el SQL dinámico requiere consideraciones adicionales.

**Aplicación en Tienda3D:**

El usuario `usuario_lector_prueba` no pudo realizar un `INSERT` directo sobre `dbo.Venta`, pero sí pudo ejecutar `dbo.sp_RegistrarVenta3D`.

Esto demuestra la utilidad de los procedimientos almacenados como mecanismo para ofrecer operaciones controladas, sin conceder permisos de modificación directa sobre las tablas.

---

## 3. Implementación en SQL Server Express

### 3.1. Configuración de autenticación mixta

Se habilitó el modo de autenticación **SQL Server y Windows**.

Luego del cambio de configuración y del reinicio del servicio, se ejecutó la siguiente consulta de verificación:

```sql
SELECT
    SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoloWindows;
```

**Resultado obtenido:**

| SoloWindows | Interpretación |
| --- | --- |
| `0` | Autenticación mixta habilitada |

**Evidencia:** [01 — Autenticación mixta](../../sql/tecnico/seguridad/evidencias/01-autenticacion-mixta.png)

### 3.2. Creación de LOGIN y USER

Se configuraron cuatro inicios de sesión y sus correspondientes usuarios en la base de datos `Tienda3D`.

| LOGIN | USER asociado |
| --- | --- |
| `usuario_admin` | `usuario_admin` |
| `usuario_lector_prueba` | `usuario_lector_prueba` |
| `usuario_con_rol_prueba` | `usuario_con_rol_prueba` |
| `usuario_sin_rol_prueba` | `usuario_sin_rol_prueba` |

El archivo `01_creacion_usuarios_y_roles.sql` contiene las instrucciones:

- `CREATE LOGIN`
- `CREATE USER ... FOR LOGIN`
- `CREATE ROLE`
- `ALTER ROLE ... ADD MEMBER`

También incorpora comprobaciones de existencia para evitar crear nuevamente las mismas entidades.

#### Tratamiento de las contraseñas

Por razones de seguridad, el script contiene **valores de ejemplo que deben reemplazarse durante la instalación**.

Las contraseñas reales utilizadas en el entorno de pruebas no deben incorporarse al repositorio.

Antes de ejecutar los scripts en una instancia nueva, se deben establecer contraseñas únicas y robustas.

Además, si un LOGIN ya existe, el script de creación no modifica automáticamente su contraseña.

#### Verificación realizada

Se consultaron las vistas del catálogo:

- `sys.server_principals`
- `sys.database_principals`

Los resultados confirmaron la existencia de cuatro LOGIN de tipo `SQL_LOGIN`, todos habilitados, y cuatro USER correctamente asociados.

**Evidencias:**

- [10 — Usuarios y roles creados](../../sql/tecnico/seguridad/evidencias/10-usuarios-roles-creados.png)
- [13 — Verificación de LOGIN](../../sql/tecnico/seguridad/evidencias/13-verificacion-logins.png)
- [14 — Verificación de USER](../../sql/tecnico/seguridad/evidencias/14-verificacion-usuarios.png)

### 3.3. Creación de roles y asignación de usuarios

Se utilizó el rol fijo `db_owner` y se crearon dos roles personalizados:

- `rol_vendedor`
- `rol_consulta_productos`

La asignación de usuarios se realizó mediante `ALTER ROLE ... ADD MEMBER`.

| Usuario | Rol asignado | Finalidad |
| --- | --- | --- |
| `usuario_admin` | `db_owner` | Administración de la base de datos |
| `usuario_lector_prueba` | `rol_vendedor` | Consulta de productos y operación de venta autorizada |
| `usuario_con_rol_prueba` | `rol_consulta_productos` | Consulta de productos mediante rol |
| `usuario_sin_rol_prueba` | Sin ninguno de los roles anteriores | Demostración de acceso denegado |

Las membresías se comprobaron mediante las vistas:

- `sys.database_role_members`
- `sys.database_principals`

**Evidencias:**

- [03 — Usuario administrador](../../sql/tecnico/seguridad/evidencias/03-usuario-administrador.png)
- [11 — Asignación de usuarios a roles](../../sql/tecnico/seguridad/evidencias/11-asignacion-usuarios-roles.png)

### 3.4. Asignación de permisos

El archivo `02_permisos_y_sp.sql` contiene las concesiones de permisos sobre los objetos de la base de datos.

| Principal | Permiso | Objeto |
| --- | --- | --- |
| `rol_vendedor` | `GRANT SELECT` | `dbo.Producto` |
| `rol_consulta_productos` | `GRANT SELECT` | `dbo.Producto` |
| `usuario_lector_prueba` | `GRANT SELECT` | `dbo.Producto` |
| `usuario_lector_prueba` | `GRANT EXECUTE` | `dbo.sp_RegistrarVenta3D` |

Se verificaron los permisos mediante `sys.database_permissions`.

Los cuatro permisos aparecieron con estado **GRANT**.

El usuario lector recibe el permiso `SELECT` directamente y también mediante `rol_vendedor`. Esta redundancia corresponde a la configuración comprobada durante las pruebas.

**Evidencias:**

- [02 — Permisos de usuarios y roles](../../sql/tecnico/seguridad/evidencias/02-permisos-usuarios-roles.png)
- [12 — Permisos asignados](../../sql/tecnico/seguridad/evidencias/12-permisos-asignados.png)

---

## 4. Aplicación de la seguridad en Tienda3D

En el sistema de ventas se necesita permitir que un vendedor registre operaciones comerciales sin que pueda modificar libremente las tablas de la base de datos.

Para resolver esta necesidad se diferenciaron dos mecanismos:

1. **Acceso directo a las tablas:** requiere que el usuario tenga el permiso correspondiente.
2. **Ejecución de procedimientos almacenados:** permite realizar operaciones autorizadas mediante una rutina controlada.

En `Tienda3D` se trabajó con los siguientes objetos:

| Objeto | Función en las pruebas |
| --- | --- |
| `dbo.Venta` | Almacenamiento de comprobantes de venta |
| `dbo.Producto` | Consulta de productos y verificación de stock |
| `dbo.sp_RegistrarVenta3D` | Registro de ventas mediante procedimiento almacenado |

La configuración permitió comprobar que:

- El administrador pudo insertar directamente una venta.
- El lector no pudo insertar directamente en `dbo.Venta`.
- El lector sí pudo ejecutar el procedimiento almacenado de ventas.
- El usuario con rol de consulta pudo acceder a los productos.
- El usuario sin autorización de consulta recibió un error de permisos.

Las pruebas de escritura se ejecutaron mediante transacciones reversibles para evitar conservar operaciones ficticias.

---

## 5. Pruebas de funcionamiento

Las pruebas se encuentran documentadas en `03_pruebas_demostracion.sql`.

Se utilizaron instrucciones como:

- `EXECUTE AS USER`
- `REVERT`
- `TRY...CATCH`
- `ROLLBACK`

Se realizaron **cinco pruebas funcionales** y una **verificación complementaria del ROLLBACK**.

### 5.1. Prueba 1 — INSERT directo con administrador

**Objetivo:** comprobar que el usuario administrador puede insertar registros en `dbo.Venta`.

Se utilizó `usuario_admin`, miembro del rol `db_owner`, para realizar una inserción temporal en la tabla `dbo.Venta`.

Los valores utilizados fueron:

| Campo | Valor |
| --- | --- |
| Cliente | `20123456` |
| Importe | `15000` |
| Estado | `1` |
| Método de pago | `1` |

SQL Server autorizó la operación y se generó temporalmente el comprobante **27**.

Posteriormente, la transacción se revirtió mediante `ROLLBACK` para evitar conservar una venta ficticia.

**Resultado:** INSERT permitido.

**Evidencia:** [04 — INSERT autorizado al administrador](../../sql/tecnico/seguridad/evidencias/04-insert-administrador.png)

### 5.2. Prueba 2 — INSERT directo con usuario lector

**Objetivo:** comprobar que un usuario sin permiso `INSERT` no puede insertar directamente en la tabla `dbo.Venta`.

Se ejecutó la operación bajo el contexto de `usuario_lector_prueba`.

SQL Server rechazó la inserción y devolvió el **error 229**, correspondiente a la falta de autorización sobre el objeto.

**Resultado:** INSERT denegado.

**Evidencia:** [05 — INSERT denegado al lector](../../sql/tecnico/seguridad/evidencias/05-insert-lector-denegado.png)

### 5.3. Prueba 3 — Ejecución del procedimiento almacenado

**Objetivo:** comprobar que el lector puede registrar una venta mediante un procedimiento autorizado, aunque no tenga permiso de inserción directa sobre las tablas.

Se ejecutó `dbo.sp_RegistrarVenta3D` mediante el permiso `EXECUTE` concedido al usuario.

Los datos utilizados fueron:

| Dato | Valor |
| --- | --- |
| Producto | Filamento PLA Negro |
| Código de producto | `1` |
| Cantidad | `1` |
| Precio unitario | `$18.000` |
| Cliente | `20123456` |
| Método de pago | `1` |

La ejecución generó temporalmente el comprobante **26**.

Se observaron los siguientes cambios:

| Elemento | Antes | Durante la transacción |
| --- | --- | --- |
| Cantidad de ventas | `5` | `6` |
| Stock del producto | `8` | `7` |
| Comprobante 26 | No existía | Generado temporalmente |

La prueba devolvió el resultado **PRUEBA EXITOSA**.

**Resultado:** ejecución autorizada del procedimiento almacenado.

**Evidencia:** [06 — Ejecución permitida al lector](../../sql/tecnico/seguridad/evidencias/06-exec-lector-permitido.png)

### 5.4. Verificación complementaria — ROLLBACK

**Objetivo:** comprobar que la transacción de prueba fue revertida y que no quedaron modificaciones permanentes.

Después de ejecutar `ROLLBACK`, se consultó el estado de la base de datos.

| Elemento verificado | Resultado |
| --- | --- |
| Cantidad de ventas | `5` |
| Stock del producto 1 | `8` |
| Existencia del comprobante 26 | `0` (no existe) |

Los resultados confirmaron que la venta temporal quedó revertida.

La numeración de las columnas `IDENTITY` puede avanzar aunque se revierta una transacción; por eso, los comprobantes 26 y 27 identifican ejecuciones concretas y no números fijos para futuras pruebas.

**Resultado:** reversión comprobada.

**Evidencia:** [07 — Verificación del ROLLBACK](../../sql/tecnico/seguridad/evidencias/07-verificacion-rollback.png)

### 5.5. Prueba 4 — SELECT permitido mediante rol

**Objetivo:** verificar que un usuario perteneciente a un rol con permiso `SELECT` puede consultar productos.

Se ejecutó una consulta sobre `dbo.Producto` bajo el contexto de `usuario_con_rol_prueba`.

El usuario pertenecía al rol `rol_consulta_productos`, que tenía concedido el permiso `SELECT`.

SQL Server permitió consultar cinco productos.

**Resultado:** SELECT permitido mediante rol.

**Evidencia:** [08 — SELECT permitido con rol](../../sql/tecnico/seguridad/evidencias/08-select-con-rol.png)

### 5.6. Prueba 5 — SELECT denegado sin rol

**Objetivo:** comprobar que un usuario sin autorización de lectura no puede consultar `dbo.Producto`.

Se ejecutó la misma consulta bajo el contexto de `usuario_sin_rol_prueba`.

SQL Server devolvió el **error 229**, impidiendo el acceso a la información.

**Resultado:** SELECT denegado.

**Evidencia:** [09 — SELECT denegado sin rol](../../sql/tecnico/seguridad/evidencias/09-select-sin-rol-denegado.png)

---

## 6. Matriz comparativa de resultados

| Prueba | Usuario | Resultado observado | Evidencia |
| --- | --- | --- | --- |
| INSERT directo en `dbo.Venta` | `usuario_admin` | Permitido; comprobante temporal 27 | 04 |
| INSERT directo en `dbo.Venta` | `usuario_lector_prueba` | Denegado; error 229 | 05 |
| EXEC de `sp_RegistrarVenta3D` | `usuario_lector_prueba` | Permitido; comprobante temporal 26 | 06 |
| Estado posterior al ROLLBACK | Contexto original | 5 ventas, stock 8, comprobante 26 ausente | 07 |
| SELECT sobre `dbo.Producto` | `usuario_con_rol_prueba` | Permitido | 08 |
| SELECT sobre `dbo.Producto` | `usuario_sin_rol_prueba` | Denegado; error 229 | 09 |

**Alcance de los resultados:** no se presentan como pruebas realizadas los intentos de inserción directa en `Detalle_Venta` ni de actualización directa en `Producto`, porque no forman parte de las evidencias actuales.

El comprobante 22 pertenece a una ejecución anterior y no se utiliza como evidencia de las pruebas reversibles de esta etapa.

---

## 7. Evidencias y ubicación

Las capturas de pantalla obtenidas mediante SSMS se encuentran en:

`sql/tecnico/seguridad/evidencias/`

| Archivo de evidencia | Contenido comprobado |
| --- | --- |
| [01-autenticacion-mixta.png](../../sql/tecnico/seguridad/evidencias/01-autenticacion-mixta.png) | Autenticación mixta habilitada |
| [02-permisos-usuarios-roles.png](../../sql/tecnico/seguridad/evidencias/02-permisos-usuarios-roles.png) | Inspección de permisos de usuarios y roles |
| [03-usuario-administrador.png](../../sql/tecnico/seguridad/evidencias/03-usuario-administrador.png) | Pertenencia del administrador a `db_owner` |
| [04-insert-administrador.png](../../sql/tecnico/seguridad/evidencias/04-insert-administrador.png) | INSERT autorizado al administrador |
| [05-insert-lector-denegado.png](../../sql/tecnico/seguridad/evidencias/05-insert-lector-denegado.png) | INSERT denegado al lector |
| [06-exec-lector-permitido.png](../../sql/tecnico/seguridad/evidencias/06-exec-lector-permitido.png) | Ejecución permitida del procedimiento |
| [07-verificacion-rollback.png](../../sql/tecnico/seguridad/evidencias/07-verificacion-rollback.png) | Verificación de reversión |
| [08-select-con-rol.png](../../sql/tecnico/seguridad/evidencias/08-select-con-rol.png) | SELECT permitido mediante rol |
| [09-select-sin-rol-denegado.png](../../sql/tecnico/seguridad/evidencias/09-select-sin-rol-denegado.png) | SELECT denegado sin rol |
| [10-usuarios-roles-creados.png](../../sql/tecnico/seguridad/evidencias/10-usuarios-roles-creados.png) | Cuatro usuarios y dos roles personalizados |
| [11-asignacion-usuarios-roles.png](../../sql/tecnico/seguridad/evidencias/11-asignacion-usuarios-roles.png) | Asignación de usuarios a roles |
| [12-permisos-asignados.png](../../sql/tecnico/seguridad/evidencias/12-permisos-asignados.png) | Cuatro permisos `GRANT` |
| [13-verificacion-logins.png](../../sql/tecnico/seguridad/evidencias/13-verificacion-logins.png) | Cuatro LOGIN habilitados |
| [14-verificacion-usuarios.png](../../sql/tecnico/seguridad/evidencias/14-verificacion-usuarios.png) | Cuatro USER asociados a sus LOGIN |

Las **14 evidencias** fueron incorporadas al paquete de Seguridad.

El archivo `LEEME_EVIDENCIAS.md`, ubicado en la misma carpeta, contiene el inventario de las capturas.

---

## 8. Conclusiones

Se implementó y verificó un esquema de seguridad para `Tienda3D`, basado en la diferenciación de usuarios, roles y permisos.

Las pruebas demostraron que:

1. El administrador pudo realizar una inserción directa sobre `dbo.Venta`.
2. El lector no pudo insertar directamente en esa tabla.
3. El lector pudo ejecutar el procedimiento almacenado autorizado para registrar una venta.
4. El usuario con rol de consulta pudo acceder a los productos.
5. El usuario sin permiso de consulta recibió un error de autorización.

Adicionalmente, se verificó que el uso de `ROLLBACK` permitió revertir las operaciones de prueba, evitando conservar ventas ficticias.

La implementación permitió relacionar el principio de mínimo privilegio, los permisos mediante roles y la ejecución controlada de procedimientos almacenados con un caso concreto del sistema de ventas e inventario.

Los resultados están respaldados por scripts SQL y evidencias obtenidas en SSMS.

---

## 9. Archivos técnicos relacionados

| Archivo | Contenido |
| --- | --- |
| `01_creacion_usuarios_y_roles.sql` | Creación de LOGIN, USER y ROLE; asignación de membresías |
| `02_permisos_y_sp.sql` | Concesión de permisos SELECT y EXECUTE |
| `03_pruebas_demostracion.sql` | Consultas de verificación y pruebas funcionales |
| `scripts.sql` | Implementación consolidada de cuentas, roles y permisos |

El archivo `scripts.sql` no ejecuta automáticamente las pruebas funcionales.

---

## 10. Referencias

### Material de cátedra

- *Guía para la implementación de los Temas Técnicos*. Etapa V: Seguridad — Manejo de permisos a nivel de usuarios y roles en SQL Server.


### Fuentes de los resultados prácticos

- Scripts SQL de la Etapa V del proyecto `Tienda3D`.
- Pruebas realizadas en SQL Server Management Studio.
- Evidencias numeradas del 01 al 14.
