-- Ventas

-- sp_registrarVenta: registra la cabecera de una venta en estado pendiente.
IF OBJECT_ID(N'dbo.sp_registrarVenta', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_registrarVenta;
GO

CREATE PROCEDURE dbo.sp_registrarVenta
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

-- sp_actualizarVenta: actualiza los datos principales de una venta existente.
IF OBJECT_ID(N'dbo.sp_actualizarVenta', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_actualizarVenta;
GO

CREATE PROCEDURE dbo.sp_actualizarVenta
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
