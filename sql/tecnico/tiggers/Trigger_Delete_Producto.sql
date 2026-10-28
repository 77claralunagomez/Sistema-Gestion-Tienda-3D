USE Tienda3D;
GO

CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Producto_Delete
ON dbo.Producto
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Auditoria_Producto (
        fecha_hora, usuario, codigo_producto, nombre_producto,
        precio_anterior, precio_nuevo, stock_anterior, stock_nuevo, tipo_operacion
    )
    SELECT 
        SYSDATETIME(),
        SYSTEM_USER,
        d.codigo_producto,
        d.nombre,
        d.precio AS precio_anterior,
        NULL AS precio_nuevo,
        d.stock AS stock_anterior,
        NULL AS stock_nuevo,
        'DELETE'
    FROM deleted d;
END;
GO
