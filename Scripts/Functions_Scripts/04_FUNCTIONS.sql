USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

-- FN_Venta_CalcularTotal: devuelve el total actual de una venta segun sus detalles
IF OBJECT_ID(N'dbo.FN_Venta_CalcularTotal', N'FN') IS NOT NULL
    DROP FUNCTION dbo.FN_Venta_CalcularTotal;
GO

CREATE FUNCTION dbo.FN_Venta_CalcularTotal
(
    @IdVenta INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Total DECIMAL(12,2);

    SELECT @Total = ISNULL(SUM(dv.Subtotal), 0)
    FROM DetalleVentas dv
    WHERE dv.IdVenta = @IdVenta;

    RETURN @Total;
END;
GO
