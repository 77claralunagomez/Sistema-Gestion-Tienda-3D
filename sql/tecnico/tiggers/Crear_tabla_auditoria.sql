USE Tienda3D;
GO

IF OBJECT_ID('dbo.Auditoria_Producto', 'U') IS NOT NULL
    DROP TABLE dbo.Auditoria_Producto;
GO

CREATE TABLE dbo.Auditoria_Producto (
    id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
    fecha_hora DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    usuario VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER,
    codigo_producto INT NOT NULL,
    nombre_producto VARCHAR(100) NULL,
    precio_anterior DECIMAL(12,2) NULL,
    precio_nuevo DECIMAL(12,2) NULL,
    stock_anterior INT NULL,
    stock_nuevo INT NULL,
    tipo_operacion VARCHAR(20) NOT NULL
);
GO
