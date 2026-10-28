USE Tienda3D;
GO

-- Procedimiento auxiliar utilizado por la prueba de rendimiento.
-- Ejecutar una sola vez para crearlo.
CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto_Benchmark
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Producto
        (descripcion, precio, nombre, stock,
         codigo_categoria, id_marca, id_unidad)
    VALUES
        ('Benchmark de rendimiento', 1000.00, @nombre, 1, 1, 2, 1);
END;
GO

-- Medición: 1.000 INSERT directos en un lote frente a 1.000 llamadas individuales.
-- Las transacciones se revierten; los valores IDENTITY pueden avanzar igualmente.
SET NOCOUNT ON;

DECLARE @Inicio DATETIME2(7);
DECLARE @Fin DATETIME2(7);
DECLARE @TiempoDirecto BIGINT;
DECLARE @TiempoProc BIGINT;
DECLARE @i INT;
DECLARE @Nombre VARCHAR(100);

BEGIN TRANSACTION;
SET @Inicio = SYSDATETIME();

;WITH Numeros AS (
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Producto
    (descripcion, precio, nombre, stock, codigo_categoria, id_marca, id_unidad)
SELECT
    'Benchmark directo', 1000.00,
    'BENCH_D_' + CONVERT(VARCHAR(10), n),
    1, 1, 2, 1
FROM Numeros;

SET @Fin = SYSDATETIME();
SET @TiempoDirecto = DATEDIFF_BIG(MICROSECOND, @Inicio, @Fin);
ROLLBACK TRANSACTION;

BEGIN TRANSACTION;
SET @i = 1;
SET @Inicio = SYSDATETIME();

WHILE @i <= 1000
BEGIN
    SET @Nombre = 'BENCH_P_' + CONVERT(VARCHAR(10), @i);
    EXEC dbo.sp_InsertarProducto_Benchmark @nombre = @Nombre;
    SET @i = @i + 1;
END;

SET @Fin = SYSDATETIME();
SET @TiempoProc = DATEDIFF_BIG(MICROSECOND, @Inicio, @Fin);
ROLLBACK TRANSACTION;

SELECT 'INSERT directo (1000 registros)' AS Prueba,
       @TiempoDirecto AS TiempoMicrosegundos
UNION ALL
SELECT 'Procedimiento (1000 llamadas)', @TiempoProc;
GO
