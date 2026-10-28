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

        -- Confirmar todas las operaciones de forma atómica
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
