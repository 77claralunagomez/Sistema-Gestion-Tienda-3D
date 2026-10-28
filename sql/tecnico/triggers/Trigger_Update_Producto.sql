USE Tienda3D;
GO

CREATE OR ALTER TRIGGER dbo.trg_Auditoria_Producto_Update
ON dbo.Producto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(precio) OR UPDATE(stock)
    BEGIN
        INSERT INTO dbo.Auditoria_Producto (
            fecha_hora, usuario, codigo_producto, nombre_producto,
            precio_anterior, precio_nuevo, stock_anterior, stock_nuevo, tipo_operacion
        )
        
        SELECT 
            SYSDATETIME(),
            SYSTEM_USER,
            i.codigo_producto,
            i.nombre,
            d.precio AS precio_anterior,
            i.precio AS precio_nuevo,
            d.stock AS stock_anterior,
            i.stock AS stock_nuevo,
            'UPDATE'
        FROM inserted i
        INNER JOIN deleted d ON i.codigo_producto = d.codigo_producto;
    END
END;
GOTrigger_Update_Producto.sql
