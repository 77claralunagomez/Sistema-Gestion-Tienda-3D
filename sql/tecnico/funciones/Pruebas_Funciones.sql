USE Tienda3D;
GO

-- Total acumulado por cliente
SELECT
    dni_cliente,
    dbo.CalcularTotalComprasCliente(dni_cliente) AS TotalCompras
FROM dbo.Cliente;

-- Total acumulado y descuento
SELECT
    dni_cliente,
    dbo.CalcularTotalComprasCliente(dni_cliente) AS TotalCompras,
    dbo.CalcularDescuento(dni_cliente) * 100 AS DescuentoPorcentaje
FROM dbo.Cliente;

-- Ejemplos de cálculo de importe
SELECT
    dbo.CalcularImporteVenta(18000, 2) AS ImporteEjemplo1,
    dbo.CalcularImporteVenta(2500, 4) AS ImporteEjemplo2;
GO
