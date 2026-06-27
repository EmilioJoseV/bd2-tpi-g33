-- Ventas
-- SP_Venta_Consultar: filtra ventas por fecha y por los datos que se quieran pasar.

IF OBJECT_ID(N'dbo.SP_Venta_Consultar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Venta_Consultar;
GO

CREATE PROCEDURE dbo.SP_Venta_Consultar
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @IdCliente INT = NULL,
    @IdEmpleado INT = NULL,
    @IdMedioPago INT = NULL
AS
BEGIN
    IF @FechaDesde IS NOT NULL AND @FechaHasta IS NOT NULL AND @FechaDesde > @FechaHasta
    BEGIN
        PRINT 'Las fechas no cierran';
        RETURN;
    END

    IF @IdCliente IS NOT NULL AND @IdCliente <= 0
    BEGIN
        PRINT 'El id de cliente es invalido';
        RETURN;
    END

    IF @IdEmpleado IS NOT NULL AND @IdEmpleado <= 0
    BEGIN
        PRINT 'El id de empleado es invalido';
        RETURN;
    END

    IF @IdMedioPago IS NOT NULL AND @IdMedioPago <= 0
    BEGIN
        PRINT 'El id de medio de pago es invalido';
        RETURN;
    END

    SELECT
        v.IdVenta,
        v.FechaVenta,
        v.Total,
        c.Apellido + ', ' + c.Nombre AS Cliente,
        e.Apellido + ', ' + e.Nombre AS Empleado,
        mp.Nombre AS MedioPago,
        ev.Nombre AS EstadoVenta
    FROM Ventas v
    INNER JOIN Clientes c ON c.IdCliente = v.IdCliente
    INNER JOIN Empleados e ON e.IdEmpleado = v.IdEmpleado
    INNER JOIN MediosPago mp ON mp.IdMedioPago = v.IdMedioPago
    INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
    WHERE (@FechaDesde IS NULL OR CAST(v.FechaVenta AS date) >= @FechaDesde)
      AND (@FechaHasta IS NULL OR CAST(v.FechaVenta AS date) <= @FechaHasta)
      AND (@IdCliente IS NULL OR v.IdCliente = @IdCliente)
      AND (@IdEmpleado IS NULL OR v.IdEmpleado = @IdEmpleado)
      AND (@IdMedioPago IS NULL OR v.IdMedioPago = @IdMedioPago)
    ORDER BY v.FechaVenta, v.IdVenta;
END;
GO
