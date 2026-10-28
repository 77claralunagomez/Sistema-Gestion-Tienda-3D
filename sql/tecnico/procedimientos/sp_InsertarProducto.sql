
USE Tienda3D;
GO

CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto
    @descripcion VARCHAR(100),
    @precio DECIMAL(10,2),
    @nombre VARCHAR(100),
    @stock DECIMAL(10,2),
    @codigo_categoria INT,
    @id_marca INT,
    @id_unidad INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @precio IS NULL OR @precio <= 0
        THROW 50010, 'El precio debe ser mayor que cero.', 1;

    IF @stock IS NULL OR @stock < 0
        THROW 50011, 'El stock no puede ser negativo ni nulo.', 1;

    INSERT INTO dbo.Producto
        (descripcion, precio, nombre, stock,
         codigo_categoria, id_marca, id_unidad)
    VALUES
        (@descripcion, @precio, @nombre, @stock,
         @codigo_categoria, @id_marca, @id_unidad);

    SELECT CONVERT(INT, SCOPE_IDENTITY()) AS codigo_producto,
           'Producto insertado correctamente' AS resultado;
END;
GO
