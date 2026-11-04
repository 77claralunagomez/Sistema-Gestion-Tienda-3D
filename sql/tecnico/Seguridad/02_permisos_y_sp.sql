-- ETAPA V - TIENDA3D: Permisos configurados y verificados
-- Ejecutar luego del script 01 y de la creacion de sp_RegistrarVenta3D.
USE Tienda3D;
GO
GRANT SELECT ON dbo.Producto TO rol_vendedor;
GRANT SELECT ON dbo.Producto TO rol_consulta_productos;
GRANT SELECT ON dbo.Producto TO usuario_lector_prueba;
GRANT EXECUTE ON dbo.sp_RegistrarVenta3D TO usuario_lector_prueba;
GO
