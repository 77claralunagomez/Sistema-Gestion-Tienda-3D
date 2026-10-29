
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

    IF EXISTS (
        SELECT 1
        FROM dbo.Detalle_Venta
        WHERE codigo_producto = @codigo_producto
    )
        THROW 50016,
              'No se puede eliminar el producto porque tiene ventas asociadas.',
              1;

    IF EXISTS (
        SELECT 1
        FROM dbo.Movimiento_Stock
        WHERE codigo_producto = @codigo_producto
    )
        THROW 50017,
              'No se puede eliminar el producto porque tiene movimientos de stock asociados.',
              1;

    IF EXISTS (
        SELECT 1
        FROM dbo.Proveedor_producto
        WHERE codigo_producto = @codigo_producto
    )
        THROW 50018,
              'No se puede eliminar el producto porque está asociado a proveedores.',
              1;

    DELETE FROM dbo.Producto
    WHERE codigo_producto = @codigo_producto;

    SELECT 'Producto eliminado correctamente' AS resultado;
END;
GO
