# Triggers de Auditoría

## 1. Objetivo
Implementar y probar triggers (desencadenadores) de auditoría en SQL Server Express, aplicados a la gestión de catálogo del sistema **Tienda3D**. 
Se busca garantizar la trazabilidad automática de cambios críticos en los productos (como modificaciones de precios y stock o eliminaciones de registros), registrando quién, cuándo y qué datos se alteraron de forma transparente e inalterable por el usuario.

## 2. Objetos SQL implementados

### 2.1. Tabla de auditoría
Se creó la tabla `dbo.Auditoria_Producto` para almacenar el historial de cambios efectuados sobre la tabla principal de productos (`dbo.Producto`).

### 2.2. Triggers de auditoría
Un trigger es un procedimiento que se ejecuta automáticamente ante eventos de manipulación de datos (`INSERT`, `UPDATE`, `DELETE`). 
Se implementaron dos triggers principales para auditar operaciones sobre el catálogo.

| Trigger | Objetivo | Validaciones y comportamiento |
| :--- | :--- | :--- |
| `dbo.trg_Auditoria_Producto_Update` | Auditar modificaciones en precios y stock de productos. | Se dispara tras un `UPDATE` en `dbo.Producto`. Mediante `IF UPDATE(precio) OR UPDATE(stock)`, verifica si cambiaron estas columnas. Compara las tablas virtuales `inserted` y `deleted` para registrar valores anteriores y nuevos. |
| `dbo.trg_Auditoria_Producto_Delete` | Auditar la eliminación de productos del catálogo. | Se dispara tras un `DELETE` en `dbo.Producto`. Captura los datos guardados en la tabla virtual `deleted` e inserta el registro indicando la baja y los datos que tenía el producto. |


## 3. Aplicación en Tienda3D
- **Trazabilidad automática:** El sistema registra de forma transparente quién modificó el precio de un filamento o resina, el día y la hora exacta,
-  sin requerir intervención del usuario o desarrollador.
- **Respaldo de Reglas de Negocio:** Ayuda a respaldar la **RN.03** (Historial de precios) y
- **RN.10** (Movimientos de stock), manteniendo un historial inmutable de las variaciones del catálogo.
- **Seguridad e inalterabilidad:** Dado que la ejecución ocurre en el motor SQL Server mediante las tablas virtuales `inserted` y `deleted`, no es posible saltearse la auditoría, aun realizando modificaciones directas sobre la tabla.
- **Mantenimiento centralizado:** La lógica de auditoría reside únicamente en la base de datos y no necesita duplicarse en la capa de aplicación o en cada consulta.

## 4. Organización de los scripts SQL

Los scripts se organizan en el repositorio dentro de la carpeta correspondiente a la Etapa V:

## 5. Pruebas funcionales de los triggers

### 5.1. Registro de producto temporal para pruebas
Se insertó un producto de prueba denominado `'TEST_TRIGGER_PLA'` con un precio inicial de **$18.000,00** y un stock de **10 unidades** para verificar la captura de eventos.

### 5.2. Modificación de precio y stock (UPDATE)
Se modificaron los valores del producto de prueba utilizando el procedimiento almacenado `dbo.sp_ModificarProducto`, estableciendo un nuevo precio de **$21.000,00** y un stock de **15 unidades**.
- **Resultado:** Se disparó automáticamente `dbo.trg_Auditoria_Producto_Update`, guardando una fila en `dbo.Auditoria_Producto` con el precio y stock anterior versus el nuevo.

### 5.3. Eliminación de producto (DELETE)
Se procedió a eliminar el producto de prueba utilizando el procedimiento `dbo.sp_EliminarProducto`.
- **Resultado:** Se disparó automáticamente `dbo.trg_Auditoria_Producto_Delete`, registrando la baja en `dbo.Auditoria_Producto` con `tipo_operacion = 'DELETE'` y conservando los últimos datos conocidos del insumo.

### 5.4. Prueba transaccional con ROLLBACK
Se ejecutaron modificaciones sobre productos dentro de un bloque `BEGIN TRANSACTION ... ROLLBACK TRANSACTION`.
Se verificó que los registros de auditoría y los cambios generados dentro de la transacción se deshacen de forma atómica al revertir la operación, garantizando la consistencia.


## 6. Resultados de los triggers de auditoría

### Trazabilidad de operaciones obtenida
Al consultar la tabla `dbo.Auditoria_Producto` tras ejecutar las pruebas de modificación y eliminación, se obtuvieron los siguientes resultados:

| id_auditoria | fecha_hora | usuario | codigo_producto | nombre_producto | precio_anterior | precio_nuevo | stock_anterior | stock_nuevo | tipo_operacion |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 2026-10-28 14:30:10 | dbo / sa | 15 | TEST_TRIGGER_PLA | $18.000,00 | $21.000,00 | 10 | 15 | UPDATE |
| 2 | 2026-10-28 14:30:12 | dbo / sa | 15 | TEST_TRIGGER_PLA | $21.000,00 | NULL | 15 | NULL | DELETE |

Los resultados muestran que el trigger capturó con exactitud la transición de valores del producto y el tipo de operación efectuada.

## 7. Ventajas y aplicaciones
- **Automatización:** Elimina la necesidad de programar manualmente registros de auditoría en la aplicación.
- **Monitoreo de precios y stock:** Permite auditar fácilmente variaciones en insumos clave (filamentos PLA/ABS, resinas), detectando errores o modificaciones no autorizadas.
- **Trazabilidad:** Proporciona un historial con usuario y marca temporal (`DATETIME2`) para auditorías de seguridad y control interno.
- **Soporte para recuperación de datos:** En caso de eliminaciones erróneas, los registros en la tabla de auditoría conservan los datos previos del insumo.

---

## 8. Conclusiones
Se implementaron y probaron exitosamente la tabla de auditoría `dbo.Auditoria_Producto` y los triggers `dbo.trg_Auditoria_Producto_Update` y `dbo.trg_Auditoria_Producto_Delete` en SQL Server Express. Las pruebas demostraron que los desencadenadores responden de forma automática y transparente ante cambios en la tabla de productos, garantizando el registro de valores previos y nuevos, la fecha/hora y el usuario responsable.

Esta implementación refuerza la seguridad e integridad del sistema **Tienda3D**, asegurando un control estricto sobre el catálogo de insumos de impresión 3D.

