USE Tienda3D;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ModificarProducto
    @codigo_producto INT,
    @precio DECIMAL(10,2),
    @stock DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @precio < 0
        THROW 50012, 'El precio no puede ser negativo.', 1;

    IF @stock < 0
        THROW 50013, 'El stock no puede ser negativo.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Producto
        WHERE codigo_producto = @codigo_producto
    )
        THROW 50014, 'El producto no existe.', 1;

    UPDATE dbo.Producto
    SET precio = @precio,
        stock = @stock
    WHERE codigo_producto = @codigo_producto;

    SELECT 'Producto modificado correctamente' AS resultado;
END;
GO
