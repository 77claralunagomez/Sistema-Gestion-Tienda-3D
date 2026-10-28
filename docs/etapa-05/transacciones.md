# Manejo de Transacciones en SQL Server Express

**Sistema:** Tienda3D (Sistema de Gestión de Ventas e Inventario para Tienda de Insumos de Impresión 3D)  
**Módulo:** Etapa V — Temas Técnicos Avanzados  

---

## 1. Definición y Objetivo

Una **transacción** es un conjunto de sentencias SQL (`INSERT`, `UPDATE`, `DELETE`) que el motor de base de datos ejecuta como una **única unidad lógica de trabajo**[cite: 4, 20]. 

El **objetivo principal** del manejo de transacciones es garantizar la integridad absoluta de los datos mediante las propiedades **ACID**:
* **Atomicidad (All or Nothing):** O se ejecutan con éxito todas las operaciones de la transacción (`COMMIT`), o se deshacen por completo sus efectos (`ROLLBACK`) si ocurre algún fallo[cite: 4, 20].
* **Consistencia:** La base de datos pasa de un estado válido a otro estado válido, respetando todas las restricciones de integridad (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`)[cite: 4].
* **Aislamiento (Isolation):** Las operaciones dentro de una transacción son invisibles para otras transacciones concurrentes hasta que se confirmen[cite: 4].
* **Durabilidad:** Una vez que la transacción confirma sus cambios con `COMMIT`, los datos persisten de forma permanente en el disco[cite: 4].

---

## 2. Ventajas y Aplicaciones

En un sistema de gestión comercial como **Tienda3D**, una operación como la venta de filamentos, resinas o repuestos no es un evento aislado, sino un proceso compuesto por múltiples pasos interrelacionados:
1. Verificación e inserción de la cabecera en la tabla `Venta`[cite: 20].
2. Inserción de las líneas de artículos vendidos en `Detalle_Venta`[cite: 20].
3. Descuento físico de unidades o kilogramos en la tabla `Producto`[cite: 20].
4. Registro del comprobante de egreso en `Movimiento_Stock`[cite: 20].

### Ventajas clave de aplicar transacciones:
* **Previene inconsistencias y datos "fantasma":** Evita que una venta quede registrada en el sistema si por alguna razón falla el descuento de stock o la conexión del servidor[cite: 4, 20].
* **Control de concurrencia:** Protege el inventario frente a compras simultáneas realizadas desde diferentes terminales o por la tienda web.
* **Recuperación ante errores:** Permite atrapar cualquier excepción en el bloque `CATCH` y revertir automáticamente todos los cambios parciales con `ROLLBACK TRANSACTION`[cite: 4, 20].

---

## 3. Implementación en SQL Server Express

En SQL Server Express, las transacciones explícitas se gestionan mediante las siguientes sentencias T-SQL combinadas con estructuras de control de errores `BEGIN TRY ... BEGIN CATCH`:

* `BEGIN TRANSACTION:` Inicia formalmente el bloque de la unidad lógica de trabajo[cite: 20].
* `COMMIT TRANSACTION:` Confirma definitivamente todos los cambios realizados durante la transacción[cite: 20].
* `ROLLBACK TRANSACTION:` Deshace todas las operaciones realizadas desde el inicio de la transacción si se detecta un error o falta de stock[cite: 4, 20].
* `@@TRANCOUNT:` Variable del sistema que permite verificar si existe una transacción activa antes de ejecutar un `ROLLBACK`[cite: 20].

---

## 4. Caso Concreto Aplicado al Sistema de Ventas de Tienda3D

En el dominio de la **Tienda3D**, si un cliente adquiere bobinas de filamento PLA, el procedimiento almacenado `sp_RegistrarVenta3D` toma el control transaccional:
1. Evalúa si el `stock` del producto es mayor o igual a la cantidad solicitada[cite: 20].
2. Si el stock es insuficiente o el producto no existe, interrumpe la ejecución mediante `RAISERROR` enviando el flujo directamente al bloque `CATCH`[cite: 20].
3. En el bloque `CATCH`, se ejecuta `ROLLBACK TRANSACTION`, anulando cualquier inserción parcial realizada en `Venta` o `Detalle_Venta`, manteniendo la consistencia del catálogo[cite: 4, 20].

---

## 5. Script de Demostración y Resultados Obtenidos

### A. Script SQL de Implementación

```sql
USE Tienda3D;
GO

IF OBJECT_ID('dbo.sp_RegistrarVenta3D', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarVenta3D;
GO

CREATE PROCEDURE dbo.sp_RegistrarVenta3D
    @DniCliente VARCHAR(20),
    @IdMetodo INT,
    @CodigoProducto INT,
    @Cantidad DECIMAL(10,2),
    @PrecioUnitario DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- Inicio de la unidad lógica de trabajo
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @StockActual DECIMAL(10,2);
        DECLARE @ImporteTotal DECIMAL(10,2) = @Cantidad * @PrecioUnitario;

        -- 1. Verificación de existencia y disponibilidad de stock
        SELECT @StockActual = stock 
        FROM Producto 
        WHERE codigo_producto = @CodigoProducto;

        IF @StockActual IS NULL
        BEGIN
            RAISERROR('El producto especificado no existe en el catálogo.', 16, 1);
        END

        IF @StockActual < @Cantidad
        BEGIN
            RAISERROR('Stock insuficiente de material para concretar la venta.', 16, 1);
        END

        -- 2. Insertar Comprobante de Venta
        INSERT INTO Venta (fecha, id_estado_venta, importe, dni_cliente, id_metodo)
        VALUES (GETDATE(), 2, @ImporteTotal, @DniCliente, @IdMetodo); -- Estado 2 = Confirmada

        DECLARE @NroComprobante INT = SCOPE_IDENTITY();

        -- 3. Insertar Detalle de Venta
        INSERT INTO Detalle_Venta (nro_comprobante, codigo_producto, cantidad, precio_unitario)
        VALUES (@NroComprobante, @CodigoProducto, @Cantidad, @PrecioUnitario);

        -- 4. Descontar Stock en el Catálogo
        UPDATE Producto
        SET stock = stock - @Cantidad
        WHERE codigo_producto = @CodigoProducto;

        -- 5. Registrar el movimiento de salida
        INSERT INTO Movimiento_Stock (fecha, cantidad, descripcion, codigo_producto, id_tipo_movimiento_stock)
        VALUES (GETDATE(), -@Cantidad, 'Salida por venta Nro ' + CAST(@NroComprobante AS VARCHAR), @CodigoProducto, 2);

        -- Confirmar todas las operaciones
        COMMIT TRANSACTION;
        PRINT 'Transacción exitosa: Venta, detalle, stock y movimiento actualizados correctamente.';
    END TRY
    BEGIN CATCH
        -- Revertir cualquier cambio parcial en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error detectado en la transacción. Operación cancelada (ROLLBACK): ' + ERROR_MESSAGE();
    END CATCH
END;
GO
