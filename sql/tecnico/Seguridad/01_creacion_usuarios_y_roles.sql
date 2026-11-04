-- ETAPA V - TIENDA3D: Creacion de logins, usuarios y roles
-- Instalacion: requiere permisos administrativos y Tienda3D existente.
-- IMPORTANTE: reemplazar las contrasenas de ejemplo por claves seguras no publicadas.
-- Si el login ya existe, este script NO modifica su contrasena.
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_admin')
    CREATE LOGIN usuario_admin WITH PASSWORD = 'REEMPLAZAR_POR_CLAVE_SEGURA_1!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_lector_prueba')
    CREATE LOGIN usuario_lector_prueba WITH PASSWORD = 'REEMPLAZAR_POR_CLAVE_SEGURA_2!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_con_rol_prueba')
    CREATE LOGIN usuario_con_rol_prueba WITH PASSWORD = 'REEMPLAZAR_POR_CLAVE_SEGURA_3!';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_sin_rol_prueba')
    CREATE LOGIN usuario_sin_rol_prueba WITH PASSWORD = 'REEMPLAZAR_POR_CLAVE_SEGURA_4!';
GO
USE Tienda3D;
GO
IF USER_ID('usuario_admin') IS NULL
    CREATE USER usuario_admin FOR LOGIN usuario_admin;
IF USER_ID('usuario_lector_prueba') IS NULL
    CREATE USER usuario_lector_prueba FOR LOGIN usuario_lector_prueba;
IF USER_ID('usuario_con_rol_prueba') IS NULL
    CREATE USER usuario_con_rol_prueba FOR LOGIN usuario_con_rol_prueba;
IF USER_ID('usuario_sin_rol_prueba') IS NULL
    CREATE USER usuario_sin_rol_prueba FOR LOGIN usuario_sin_rol_prueba;
GO
IF DATABASE_PRINCIPAL_ID('rol_vendedor') IS NULL CREATE ROLE rol_vendedor;
IF DATABASE_PRINCIPAL_ID('rol_consulta_productos') IS NULL CREATE ROLE rol_consulta_productos;
GO
IF IS_ROLEMEMBER('db_owner', 'usuario_admin') = 0
    ALTER ROLE db_owner ADD MEMBER usuario_admin;
IF IS_ROLEMEMBER('rol_vendedor', 'usuario_lector_prueba') = 0
    ALTER ROLE rol_vendedor ADD MEMBER usuario_lector_prueba;
IF IS_ROLEMEMBER('rol_consulta_productos', 'usuario_con_rol_prueba') = 0
    ALTER ROLE rol_consulta_productos ADD MEMBER usuario_con_rol_prueba;
GO
