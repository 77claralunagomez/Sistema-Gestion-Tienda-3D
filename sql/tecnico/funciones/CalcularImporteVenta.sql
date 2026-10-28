USE Tienda3D;
GO

CREATE OR ALTER FUNCTION dbo.CalcularImporteVenta
(
    @PrecioUnitario DECIMAL(12,2),
    @Cantidad DECIMAL(10,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    IF @PrecioUnitario < 0 OR @Cantidad < 0
        RETURN NULL;

    RETURN @PrecioUnitario * @Cantidad;
END;
GO
