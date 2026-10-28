USE Tienda3D;
GO

CREATE OR ALTER FUNCTION dbo.CalcularTotalComprasCliente
(
    @DniCliente VARCHAR(20)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = COALESCE(SUM(importe), 0)
    FROM dbo.Venta
    WHERE dni_cliente = @DniCliente;

    RETURN @Total;
END;
GO
