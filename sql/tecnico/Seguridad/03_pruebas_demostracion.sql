-- ETAPA V - TIENDA3D: Pruebas y verificaciones de seguridad
-- Ejecutar cada seccion de manera independiente en SSMS.
-- Las pruebas de INSERT y EXECUTE hacen cambios TEMPORALES y revierten con ROLLBACK.
-- Si se pierde la conexion antes de finalizar, SQL Server revierte la transaccion no confirmada.

-- VERIFICACION 01: modo de autenticacion mixto; 0 = SQL y Windows
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoloWindows;
GO
-- VERIFICACION 13: logins del servidor
USE master;
GO
SELECT name AS NombreLogin, type_desc AS TipoLogin, is_disabled AS Deshabilitado
FROM sys.server_principals
WHERE name IN ('usuario_admin','usuario_lector_prueba','usuario_con_rol_prueba','usuario_sin_rol_prueba')
ORDER BY name;
GO
-- VERIFICACION 14: users en Tienda3D y sus logins vinculados
USE Tienda3D;
GO
SELECT dp.name AS NombreUsuario, dp.type_desc AS TipoUsuario, sp.name AS LoginAsociado
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON dp.sid=sp.sid
WHERE dp.name IN ('usuario_admin','usuario_lector_prueba','usuario_con_rol_prueba','usuario_sin_rol_prueba')
ORDER BY dp.name;
GO
-- VERIFICACION 10: usuarios y roles
SELECT name AS Nombre, CASE WHEN type='R' THEN 'ROL' WHEN type='S' THEN 'USUARIO SQL' END AS Tipo
FROM sys.database_principals
WHERE name IN ('usuario_admin','usuario_lector_prueba','usuario_con_rol_prueba','usuario_sin_rol_prueba','rol_vendedor','rol_consulta_productos')
ORDER BY Tipo,Nombre;
GO
-- VERIFICACION DE ROLES (EVIDENCIA 10): existencia de roles personalizados
SELECT name AS NombreRol, type_desc AS Tipo
FROM sys.database_principals
WHERE name IN ('rol_vendedor','rol_consulta_productos')
ORDER BY name;
GO
-- VERIFICACION 11: miembros de los roles
SELECT r.name AS Rol,u.name AS Usuario
FROM sys.database_role_members AS drm
JOIN sys.database_principals AS r ON r.principal_id=drm.role_principal_id
JOIN sys.database_principals AS u ON u.principal_id=drm.member_principal_id
WHERE r.name IN ('db_owner','rol_vendedor','rol_consulta_productos')
  AND u.name IN ('usuario_admin','usuario_lector_prueba','usuario_con_rol_prueba','usuario_sin_rol_prueba')
ORDER BY r.name,u.name;
GO
-- VERIFICACION 12: permisos registrados sobre objetos
SELECT p.name AS UsuarioORol,dp.permission_name AS Permiso,dp.state_desc AS Estado,
       OBJECT_SCHEMA_NAME(dp.major_id) AS Esquema,OBJECT_NAME(dp.major_id) AS Objeto
FROM sys.database_permissions AS dp
JOIN sys.database_principals AS p ON p.principal_id=dp.grantee_principal_id
WHERE p.name IN ('rol_vendedor','rol_consulta_productos','usuario_lector_prueba')
  AND dp.permission_name IN ('SELECT','EXECUTE') AND dp.class=1
ORDER BY p.name,dp.permission_name;
GO
-- PRUEBA FUNCIONAL 1 - EVIDENCIA 04: administrador inserta y revierte
BEGIN TRY
    BEGIN TRANSACTION;
    EXECUTE AS USER='usuario_admin';
    SELECT USER_NAME() AS UsuarioActual;
    INSERT INTO dbo.Venta (fecha,id_estado_venta,importe,dni_cliente,id_metodo)
    VALUES (GETDATE(),1,15000.00,'20123456',1);
    SELECT SCOPE_IDENTITY() AS ComprobanteInsertado,'INSERT permitido' AS Resultado;
    REVERT;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF USER_NAME()='usuario_admin' REVERT;
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS NumeroError,ERROR_MESSAGE() AS MensajeError;
END CATCH;
GO
-- PRUEBA FUNCIONAL 2 - EVIDENCIA 05: lector intenta INSERT, resultado observado error 229
BEGIN TRY
    BEGIN TRANSACTION;
    EXECUTE AS USER='usuario_lector_prueba';
    SELECT USER_NAME() AS UsuarioActual;
    INSERT INTO dbo.Venta (fecha,id_estado_venta,importe,dni_cliente,id_metodo)
    VALUES (GETDATE(),1,15000.00,'20123456',1);
    REVERT;
    ROLLBACK TRANSACTION;
    SELECT 'INSERT permitido (REVISAR SEGURIDAD)' AS Resultado;
END TRY
BEGIN CATCH
    IF USER_NAME()='usuario_lector_prueba' REVERT;
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS NumeroError,ERROR_MESSAGE() AS MensajeError;
END CATCH;
GO
-- PRUEBA FUNCIONAL 3 - EVIDENCIA 06: lector puede ejecutar el procedimiento
-- Si el procedimiento interno detecta un error, puede revertir toda la transaccion
-- y devolver un mensaje PRINT. Verificar siempre la cantidad de ventas y el stock.
DECLARE @VentasAntes INT,@VentasDespues INT;
DECLARE @StockAntes DECIMAL(10,2),@StockDespues DECIMAL(10,2);
BEGIN TRY
    SELECT @VentasAntes=COUNT(*) FROM dbo.Venta;
    SELECT @StockAntes=stock FROM dbo.Producto WHERE codigo_producto=1;
    BEGIN TRANSACTION;
    EXECUTE AS USER='usuario_lector_prueba';
    SELECT USER_NAME() AS UsuarioEjecutor;
    EXEC dbo.sp_RegistrarVenta3D
        @DniCliente='20123456',@IdMetodo=1,@CodigoProducto=1,
        @Cantidad=1,@PrecioUnitario=18000.00;
    REVERT;
    SELECT @VentasDespues=COUNT(*) FROM dbo.Venta;
    SELECT @StockDespues=stock FROM dbo.Producto WHERE codigo_producto=1;
    SELECT @VentasAntes AS VentasAntes,@VentasDespues AS VentasDespues,
           @StockAntes AS StockAntes,@StockDespues AS StockDespues,
           CASE WHEN @VentasDespues=@VentasAntes+1 AND @StockDespues=@StockAntes-1
           THEN 'PRUEBA EXITOSA' ELSE 'REVISAR RESULTADO' END AS Resultado;
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF USER_NAME()='usuario_lector_prueba' REVERT;
    IF @@TRANCOUNT>0 ROLLBACK TRANSACTION;
    SELECT ERROR_NUMBER() AS NumeroError,ERROR_MESSAGE() AS MensajeError;
END CATCH;
GO
-- VERIFICACION 07: estado final despues de ROLLBACK de la prueba del comprobante 26
-- El identificador del comprobante puede cambiar en otras ejecuciones.
SELECT COUNT(*) AS TotalVentas FROM dbo.Venta;
SELECT codigo_producto,nombre,stock FROM dbo.Producto WHERE codigo_producto=1;
SELECT COUNT(*) AS Comprobante26Existe FROM dbo.Venta WHERE nro_comprobante=26;
GO
-- PRUEBA FUNCIONAL 4 - EVIDENCIA 08: SELECT permitido mediante rol
BEGIN TRY
    EXECUTE AS USER='usuario_con_rol_prueba';
    SELECT USER_NAME() AS UsuarioActual;
    SELECT TOP (5) codigo_producto,nombre,precio,stock FROM dbo.Producto;
    REVERT;
END TRY
BEGIN CATCH
    IF USER_NAME()='usuario_con_rol_prueba' REVERT;
    SELECT ERROR_NUMBER() AS NumeroError,ERROR_MESSAGE() AS MensajeError;
END CATCH;
GO
-- PRUEBA FUNCIONAL 5 - EVIDENCIA 09: SELECT denegado sin rol, error 229
BEGIN TRY
    EXECUTE AS USER='usuario_sin_rol_prueba';
    SELECT USER_NAME() AS UsuarioActual;
    SELECT TOP (5) codigo_producto,nombre,precio,stock FROM dbo.Producto;
    REVERT;
END TRY
BEGIN CATCH
    IF USER_NAME()='usuario_sin_rol_prueba' REVERT;
    SELECT ERROR_NUMBER() AS NumeroError,ERROR_MESSAGE() AS MensajeError;
END CATCH;
GO
