USE Tienda3D;
GO

-- Compara 100.000 cálculos directos con 100.000 llamadas a la función.
-- No modifica tablas.
SET NOCOUNT ON;

DECLARE @Inicio DATETIME2(7);
DECLARE @Fin DATETIME2(7);
DECLARE @TiempoDirecto BIGINT;
DECLARE @TiempoFuncion BIGINT;
DECLARE @Total DECIMAL(38,2);

SET @Inicio = SYSDATETIME();

SELECT @Total = SUM(CAST(18000.00 * 2 AS DECIMAL(12,2)))
FROM (
    SELECT TOP (100000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
) AS Numeros;

SET @Fin = SYSDATETIME();
SET @TiempoDirecto = DATEDIFF_BIG(MICROSECOND, @Inicio, @Fin);

SET @Inicio = SYSDATETIME();

SELECT @Total = SUM(dbo.CalcularImporteVenta(18000.00, 2))
FROM (
    SELECT TOP (100000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
) AS Numeros;

SET @Fin = SYSDATETIME();
SET @TiempoFuncion = DATEDIFF_BIG(MICROSECOND, @Inicio, @Fin);

SELECT 'Multiplicacion directa' AS Prueba,
       @TiempoDirecto AS TiempoMicrosegundos
UNION ALL
SELECT 'Mediante funcion', @TiempoFuncion;
GO
