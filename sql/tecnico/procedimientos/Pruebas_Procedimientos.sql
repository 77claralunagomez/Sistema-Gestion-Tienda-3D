USE Tienda3D;
GO
SET NOCOUNT ON;

-- Prueba controlada. Si falla una instrucción, se revierten los cambios.
BEGIN TRY
    BEGIN TRANSACTION;

    -- A) Inserción directa
    INSERT INTO dbo.Producto
        (descripcion, precio, nombre, stock, codigo_categoria, id_marca, id_unidad)
    VALUES
        ('Prueba de etapa V', 1000.00, 'TEST_DIRECTO_ETAPA_V', 1, 1, 2, 1);

    -- B) Inserción mediante procedimiento
    EXEC dbo.sp_InsertarProducto
        @descripcion = 'Prueba de etapa V',
        @precio = 1000.00,
        @nombre = 'TEST_PROCEDIMIENTO_ETAPA_V',
        @stock = 1,
        @codigo_categoria = 1,
        @id_marca = 2,
        @id_unidad = 1;

    DECLARE @CodigoProc INT;
    SELECT @CodigoProc = codigo_producto
    FROM dbo.Producto
    WHERE nombre = 'TEST_PROCEDIMIENTO_ETAPA_V';

    -- C) Modificación mediante procedimiento
    EXEC dbo.sp_ModificarProducto
        @codigo_producto = @CodigoProc,
        @precio = 1200.00,
        @stock = 2;

    SELECT codigo_producto, nombre, precio, stock
    FROM dbo.Producto
    WHERE nombre IN ('TEST_DIRECTO_ETAPA_V', 'TEST_PROCEDIMIENTO_ETAPA_V');

    -- D) Antes de borrar, verificar que el producto del procedimiento no tenga relaciones.
    IF EXISTS (SELECT 1 FROM dbo.Detalle_Venta WHERE codigo_producto = @CodigoProc)
       OR EXISTS (SELECT 1 FROM dbo.Movimiento_Stock WHERE codigo_producto = @CodigoProc)
       OR EXISTS (SELECT 1 FROM dbo.Proveedor_producto WHERE codigo_producto = @CodigoProc)
        THROW 50100, 'El producto de prueba tiene registros relacionados; se cancela la eliminación.', 1;

    EXEC dbo.sp_EliminarProducto @codigo_producto = @CodigoProc;

    -- El registro insertado directamente también se elimina dentro de la transacción.
    DECLARE @CodigoDirecto INT;
    SELECT @CodigoDirecto = codigo_producto
    FROM dbo.Producto
    WHERE nombre = 'TEST_DIRECTO_ETAPA_V';

    IF @CodigoDirecto IS NOT NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.Detalle_Venta WHERE codigo_producto = @CodigoDirecto)
           OR EXISTS (SELECT 1 FROM dbo.Movimiento_Stock WHERE codigo_producto = @CodigoDirecto)
           OR EXISTS (SELECT 1 FROM dbo.Proveedor_producto WHERE codigo_producto = @CodigoDirecto)
            THROW 50101, 'El producto directo de prueba tiene registros relacionados; se cancela la eliminación.', 1;

        DELETE FROM dbo.Producto WHERE codigo_producto = @CodigoDirecto;
    END;

    ROLLBACK TRANSACTION;
    SELECT 'Pruebas finalizadas; los cambios de prueba fueron revertidos.' AS resultado;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
