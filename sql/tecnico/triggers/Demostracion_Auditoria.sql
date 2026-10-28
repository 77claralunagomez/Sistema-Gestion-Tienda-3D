USE Tienda3D;
GO

SET NOCOUNT ON;

-- 1. Inserción de prueba
INSERT INTO dbo.Producto (
    descripcion, precio, nombre, stock, codigo_categoria, id_marca, id_unidad
)
VALUES (
    'Insumo de prueba para verificación de Trigger', 
    18000.00, 'TEST_TRIGGER_PLA', 10, 1, 2, 1
);

DECLARE @IdPrueba INT = SCOPE_IDENTITY();

-- 2. Prueba de modificación (dispara trg_Auditoria_Producto_Update)
EXEC dbo.sp_ModificarProducto 
    @codigo_producto = @IdPrueba, 
    @precio = 21000.00, 
    @stock = 15;

-- 3. Prueba de eliminación (dispara trg_Auditoria_Producto_Delete)
EXEC dbo.sp_EliminarProducto 
    @codigo_producto = @IdPrueba;

-- 4. Verificación del resultado final
SELECT 
    id_auditoria,
    fecha_hora,
    usuario,
    codigo_producto,
    nombre_producto,
    precio_anterior,
    precio_nuevo,
    stock_anterior,
    stock_nuevo,
    tipo_operacion
FROM dbo.Auditoria_Producto;
GO
