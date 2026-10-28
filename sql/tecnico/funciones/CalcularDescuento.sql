USE Tienda3D;
GO

CREATE OR ALTER FUNCTION dbo.CalcularDescuento
(
    @DniCliente VARCHAR(20)
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @TotalAcumulado DECIMAL(12,2);
    DECLARE @Descuento DECIMAL(5,2);

    SELECT @TotalAcumulado = COALESCE(SUM(importe), 0)
    FROM dbo.Venta
    WHERE dni_cliente = @DniCliente
      AND id_estado_venta IN (2, 3, 4);

    IF @TotalAcumulado > 500000
        SET @Descuento = 0.10;
    ELSE IF @TotalAcumulado > 200000
        SET @Descuento = 0.05;
    ELSE
        SET @Descuento = 0.00;

    RETURN @Descuento;
END;
GO