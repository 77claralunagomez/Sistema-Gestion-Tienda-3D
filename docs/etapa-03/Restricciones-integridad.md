# Restricciones de Integridad y Reglas de Negocio

El script DDL implementa diversas restricciones a nivel de motor de base de datos para garantizar la consistencia y fiabilidad de los datos.

## 1. Integridad de Entidad y Referencial
*   **Claves Primarias (PK):** Se utilizó el atributo autoincremental `INT IDENTITY(1,1)` para la mayoría de las entidades. En la tabla `Cliente`, el `dni_cliente` se definió como `VARCHAR(20)` para admitir documentos con ceros a la izquierda. `Proveedor_producto` utiliza una clave compuesta.
*   **Claves Foráneas (FK):** Se configuró opcionalidad (admite `NULL`) en la tabla `Cliente` para el atributo `id_usuario`, permitiendo registrar ventas presenciales de clientes sin cuenta en la plataforma web.

## 2. Restricciones de Dominio y Reglas de Negocio

*   **Restricciones UNIQUE:**
    *   `UQ_Rol_Nombre` y `UQ_MetodoPago_Nombre`: Impiden la duplicidad en los catálogos.
    *   `Usuario.email`: Evita que dos usuarios registren la misma cuenta de correo.
    *   `UQ_Anulacion_Venta_Comprobante`: Asegura que un comprobante de venta se pueda anular solo una vez.

*   **Restricciones CHECK:**
    *   `CK_Producto_Precio` y `CK_Producto_Stock`: Garantizan que los productos tengan un precio mayor a 0 y que el stock nunca sea negativo.
    *   `CK_Venta_Importe` y `CHK_DetalleVenta_Precio`: Fuerzan importes positivos en las transacciones.
    *   `CHK_DetalleVenta_Cantidad`: Obliga a que cada línea de venta tenga una cantidad mayor a 0.
    *   `CHK_MovimientoStock_Cantidad`: Impide registrar movimientos nulos (cantidad diferente de 0).

*   **Valores por Defecto (DEFAULT):**
    *   Las fechas de creación en `Consulta` y `Venta` utilizan `CURRENT_TIMESTAMP`. 
    *   `Movimiento_Stock` y `Anulacion_Venta` capturan la fecha y hora exacta mediante `GETDATE()`.
