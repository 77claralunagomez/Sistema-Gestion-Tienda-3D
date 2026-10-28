USE Tienda3D;
GO

-- 1. Total acumulado por cliente
SELECT
    dni_cliente,
    dbo.CalcularTotalComprasCliente(dni_cliente) AS TotalCompras
FROM dbo.Cliente;
GO

-- 2. Total acumulado y descuento por cliente
SELECT
    dni_cliente,
    dbo.CalcularTotalComprasCliente(dni_cliente) AS TotalCompras,
    dbo.CalcularDescuento(dni_cliente) * 100 AS DescuentoPorcentaje
FROM dbo.Cliente;
GO

-- 3. Ejemplos de cálculo de importe
SELECT
    dbo.CalcularImporteVenta(18000, 2) AS ImporteEjemplo1,
    dbo.CalcularImporteVenta(2500, 4) AS ImporteEjemplo2;
GO

-- 4. Verificación de los umbrales de descuento
-- Esta consulta comprueba la lógica de los porcentajes.
-- No ejecuta directamente dbo.CalcularDescuento.

SELECT
    total AS TotalAcumuladoPrueba,
    CASE
        WHEN total > 500000 THEN 10.00
        WHEN total > 200000 THEN 5.00
        ELSE 0.00
    END AS DescuentoPorcentajeEsperado
FROM (VALUES
    (150000.00),
    (200000.00),
    (200001.00),
    (500000.00),
    (500001.00)
) AS Pruebas(total);
GO