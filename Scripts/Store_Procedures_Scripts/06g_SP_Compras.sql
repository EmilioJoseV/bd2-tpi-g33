-- Compras

-- sp_registrarCompra: registra una compra validando bien los datos de entrada.
CREATE PROCEDURE sp_registrarCompra
    @IdProveedor INT,
    @IdEmpleado INT,
    @NumeroComprobante VARCHAR(50),
    @Total DECIMAL(12,2)
AS
BEGIN
    DECLARE @IdEstadoPendiente INT;

-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'El proveedor es invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'El empleado es invalido';
        RETURN;
    END

    IF @Total IS NULL OR @Total < 0
    BEGIN
        PRINT 'El total es invalido';
        RETURN;
    END
    
-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado no esta activo';
        RETURN;
    END

-- Iniciamos la compra siempre con estado pendiente, por lo que buscamos el id de ese estado para asignarlo a la compra. 
-- Si no existe el estado pendiente, se muestra un mensaje de error y se cancela el registro de la compra.
    SELECT @IdEstadoPendiente = IdEstadoCompra
    FROM EstadosCompra
    WHERE UPPER(Nombre) = 'PENDIENTE';

    IF @IdEstadoPendiente IS NULL
    BEGIN
        PRINT 'No existe el estado pendiente registrado en la bd';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

-- Registrar la compra arrancando siempre en pendiente.
    INSERT INTO Compras (IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total)
    VALUES (@IdProveedor, @IdEmpleado, @IdEstadoPendiente, SYSDATETIME(), @NumeroComprobante, @Total);

    PRINT 'Compra registrada';
END;
GO

-- sp_actualizarCompra: actualiza los datos principales de una compra existente.
CREATE PROCEDURE sp_actualizarCompra
    @IdCompra INT,
    @IdProveedor INT,
    @IdEmpleado INT,
    @IdEstadoCompra INT,
    @NumeroComprobante VARCHAR(50),
    @Total DECIMAL(12,2)
AS
BEGIN
-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

-- Validar datos ingresados para la actualizacion de la compra.
    IF @IdCompra IS NULL OR @IdCompra <= 0
    BEGIN
        PRINT 'El id de la compra es invalido';
        RETURN;
    END

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'El proveedor es invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'El empleado es invalido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'El estado de la compra es invalido';
        RETURN;
    END

    IF @Total IS NULL OR @Total < 0
    BEGIN
        PRINT 'El total es invalido';
        RETURN;
    END

-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Compras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No existe una compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
    )
    BEGIN
        PRINT 'No existe un estado de compra con ese id';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

    IF EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
          AND UPPER(Nombre) = 'CONFIRMADA'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No se puede confirmar una compra sin detalle';
        RETURN;
    END

-- Actualizar la compra con los nuevos datos ingresados.
    UPDATE Compras
    SET IdProveedor = @IdProveedor,
        IdEmpleado = @IdEmpleado,
        IdEstadoCompra = @IdEstadoCompra,
        NumeroComprobante = @NumeroComprobante,
        Total = @Total
    WHERE IdCompra = @IdCompra;

    PRINT 'Compra actualizada';
END;
GO

-- sp_consultarCompras: filtra compras por proveedor y por fecha.

CREATE PROCEDURE sp_consultarCompras
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @IdProveedor INT = NULL
AS
BEGIN
    IF @FechaDesde IS NOT NULL AND @FechaHasta IS NOT NULL AND @FechaDesde > @FechaHasta
    BEGIN
        PRINT 'Las fechas no cierran';
        RETURN;
    END

    IF @IdProveedor IS NOT NULL AND @IdProveedor <= 0
    BEGIN
        PRINT 'El id de proveedor es invalido';
        RETURN;
    END

    SELECT
        c.IdCompra,
        c.FechaCompra,
        c.NumeroComprobante,
        c.Total,
        p.RazonSocial AS Proveedor,
        e.Apellido + ', ' + e.Nombre AS Empleado,
        ec.Nombre AS EstadoCompra
    FROM Compras c
    INNER JOIN Proveedores p ON p.IdProveedor = c.IdProveedor
    INNER JOIN Empleados e ON e.IdEmpleado = c.IdEmpleado
    INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
    WHERE (@FechaDesde IS NULL OR CAST(c.FechaCompra AS date) >= @FechaDesde)
      AND (@FechaHasta IS NULL OR CAST(c.FechaCompra AS date) <= @FechaHasta)
      AND (@IdProveedor IS NULL OR c.IdProveedor = @IdProveedor)
    ORDER BY c.FechaCompra, c.IdCompra;
END;
GO