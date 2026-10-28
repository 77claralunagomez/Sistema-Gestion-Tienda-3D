USE Tienda3D;
GO

CREATE OR ALTER PROCEDURE dbo.sp_EliminarProducto
    @codigo_producto INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Producto
        WHERE codigo_producto = @codigo_producto
    )
        THROW 50015, 'El producto no existe.', 1;

    DELETE FROM dbo.Producto
    WHERE codigo_producto = @codigo_producto;

    SELECT 'Producto eliminado correctamente' AS resultado;
END;
GO
