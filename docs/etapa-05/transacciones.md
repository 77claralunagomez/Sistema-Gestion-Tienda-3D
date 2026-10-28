# Justificación del Manejo de Transacciones

Este documento detalla la implementación, importancia y justificación técnica del manejo de transacciones en la **Tienda3D** (Sistema de Gestión de Ventas e Inventario para Tienda de Insumos de Impresión 3D).

---

## 1. Concepto y Justificación en el Dominio del Negocio

Una **transacción** es un conjunto de instrucciones SQL (`INSERT`, `UPDATE`, `DELETE`) que el motor de base de datos ejecuta como una **única unidad lógica de trabajo**.

En la **Tienda3D**, una venta no consiste en una única acción aislada; involucra múltiples modificaciones operativas críticas:
1. Verificación e inserción de la cabecera en la tabla `Venta`.
2. Inserción de las líneas de productos vendidos en `Detalle_Venta`.
3. Descuento físico de unidades/gramos en la tabla `Producto`.
4. Registro del comprobante de movimiento en `Movimiento_Stock`.

Si alguna de estas operaciones falla a mitad de camino (por ejemplo, falta de stock suficiente de filamento/resina o una falla de conexión en el servidor), la base de datos no puede quedar en un estado inconsistente (como haber creado la venta sin descontar el stock, o descontar el stock sin generar el comprobante). 

El uso de transacciones garantiza que **o se completan exitosamente todas las operaciones (`COMMIT`), o se revierten absolutamente todos los cambios parciales (`ROLLBACK`)**.

---

## 2. Garantía de las Propiedades ACID

La implementación transaccional en SQL Server asegura las cuatro propiedades fundamentales para la Tienda3D:

* **Atomicidad (All or Nothing):** Garantiza que la venta, el detalle, la actualización de stock y el registro de movimiento se ejecuten como un todo indivisible. Si falla el descuento de stock, se aplica un `ROLLBACK` y se revierte la inserción de la venta.
* **Consistencia:** La base de datos pasa de un estado válido a otro estado válido. Se respetan las restricciones de integridad (`CHECK`, `FOREIGN KEY`), asegurando que el stock de un producto nunca quede por debajo de cero (`stock >= 0`).
* **Aislamiento (Isolation):** Si dos vendedores registran ventas de filamento simultáneamente desde diferentes terminales, las transacciones se ejecutan de manera aislada para evitar "lecturas sucias" o modificaciones concurrentes sobre el mismo stock.
* **Durabilidad:** Una vez que la transacción confirma sus cambios con `COMMIT TRANSACTION`, la venta y el descuento de inventario persisten de forma permanente en el disco del servidor, incluso si ocurre una falla eléctrica inmediatamente después.

---

## 3. Implementación Técnica en SQL Server

A continuación se presenta el procedimiento almacenado transaccional `dbo.sp_RegistrarVenta3D` que centraliza la lógica operativa aplicando bloques `BEGIN TRANSACTION`, `TRY...CATCH`, `COMMIT` y `ROLLBACK`.

```sql
USE Tienda3D;
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
