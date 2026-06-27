-- Ventas

-- SP_Venta_Registrar: registra la cabecera de una venta en estado pendiente.
IF OBJECT_ID(N'dbo.SP_Venta_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Venta_Registrar;
GO

CREATE PROCEDURE dbo.SP_Venta_Registrar
    @IdCliente INT,
    @IdEmpleado INT,
    @IdMedioPago INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoPendiente INT;
    DECLARE @IdVenta INT;

    IF @IdCliente IS NULL OR @IdCliente <= 0
        THROW 50101, 'El cliente es invalido.', 1;

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
        THROW 50102, 'El empleado es invalido.', 1;

    IF @IdMedioPago IS NULL OR @IdMedioPago <= 0
        THROW 50103, 'El medio de pago es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IdCliente = @IdCliente AND Activo = 1)
        THROW 50104, 'El cliente indicado no existe o no esta activo.', 1;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado AND Activo = 1)
        THROW 50105, 'El empleado indicado no existe o no esta activo.', 1;

    IF NOT EXISTS (SELECT 1 FROM MediosPago WHERE IdMedioPago = @IdMedioPago AND Activo = 1)
        THROW 50106, 'El medio de pago indicado no existe o no esta activo.', 1;

    SELECT @IdEstadoPendiente = IdEstadoVenta
    FROM EstadosVenta
    WHERE UPPER(Nombre) = 'PENDIENTE';

    IF @IdEstadoPendiente IS NULL
        THROW 50107, 'No existe el estado pendiente registrado en la base.', 1;

    INSERT INTO Ventas (IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total)
    VALUES (@IdCliente, @IdEmpleado, @IdMedioPago, @IdEstadoPendiente, SYSDATETIME(), 0);

    SET @IdVenta = CONVERT(INT, SCOPE_IDENTITY());

    SELECT IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total
    FROM Ventas
    WHERE IdVenta = @IdVenta;
END;
GO

-- SP_Venta_Consultar: filtra ventas por fecha, cliente, empleado y medio de pago.
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
    SET NOCOUNT ON;

    IF @FechaDesde IS NOT NULL AND @FechaHasta IS NOT NULL AND @FechaDesde > @FechaHasta
        THROW 50301, 'Las fechas no cierran.', 1;

    IF @IdCliente IS NOT NULL AND @IdCliente <= 0
        THROW 50302, 'El cliente es invalido.', 1;

    IF @IdEmpleado IS NOT NULL AND @IdEmpleado <= 0
        THROW 50303, 'El empleado es invalido.', 1;

    IF @IdMedioPago IS NOT NULL AND @IdMedioPago <= 0
        THROW 50304, 'El medio de pago es invalido.', 1;

    SELECT
        v.IdVenta,
        v.IdCliente,
        c.Apellido + ', ' + c.Nombre AS Cliente,
        v.IdEmpleado,
        e.Apellido + ', ' + e.Nombre AS Empleado,
        v.IdMedioPago,
        mp.Nombre AS MedioPago,
        v.IdEstadoVenta,
        ev.Nombre AS Estado,
        v.FechaVenta,
        v.Total
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
    ORDER BY v.FechaVenta DESC, v.IdVenta DESC;
END;
GO

-- SP_Venta_Actualizar: actualiza los datos principales de una venta existente.
IF OBJECT_ID(N'dbo.SP_Venta_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Venta_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Venta_Actualizar
    @IdVenta INT,
    @IdCliente INT,
    @IdEmpleado INT,
    @IdMedioPago INT,
    @IdEstadoVenta INT,
    @Total DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdVenta IS NULL OR @IdVenta <= 0
        THROW 50201, 'El id de venta es invalido.', 1;

    IF @IdCliente IS NULL OR @IdCliente <= 0
        THROW 50202, 'El cliente es invalido.', 1;

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
        THROW 50203, 'El empleado es invalido.', 1;

    IF @IdMedioPago IS NULL OR @IdMedioPago <= 0
        THROW 50204, 'El medio de pago es invalido.', 1;

    IF @IdEstadoVenta IS NULL OR @IdEstadoVenta <= 0
        THROW 50205, 'El estado de venta es invalido.', 1;

    IF @Total IS NULL OR @Total < 0
        THROW 50206, 'El total es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Ventas WHERE IdVenta = @IdVenta)
        THROW 50207, 'No existe una venta con ese id.', 1;

    IF NOT EXISTS (SELECT 1 FROM Clientes WHERE IdCliente = @IdCliente AND Activo = 1)
        THROW 50208, 'El cliente indicado no existe o no esta activo.', 1;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado AND Activo = 1)
        THROW 50209, 'El empleado indicado no existe o no esta activo.', 1;

    IF NOT EXISTS (SELECT 1 FROM MediosPago WHERE IdMedioPago = @IdMedioPago AND Activo = 1)
        THROW 50210, 'El medio de pago indicado no existe o no esta activo.', 1;

    IF NOT EXISTS (SELECT 1 FROM EstadosVenta WHERE IdEstadoVenta = @IdEstadoVenta)
        THROW 50211, 'No existe un estado de venta con ese id.', 1;

    IF EXISTS (
        SELECT 1
        FROM EstadosVenta
        WHERE IdEstadoVenta = @IdEstadoVenta
          AND UPPER(Nombre) = 'CONFIRMADA'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM DetalleVentas
        WHERE IdVenta = @IdVenta
    )
        THROW 50212, 'No se puede confirmar una venta sin detalle.', 1;

    UPDATE Ventas
    SET IdCliente = @IdCliente,
        IdEmpleado = @IdEmpleado,
        IdMedioPago = @IdMedioPago,
        IdEstadoVenta = @IdEstadoVenta,
        Total = @Total
    WHERE IdVenta = @IdVenta;

    SELECT IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total
    FROM Ventas
    WHERE IdVenta = @IdVenta;
END;
GO
