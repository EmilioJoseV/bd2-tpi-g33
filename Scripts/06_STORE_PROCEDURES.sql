USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #3 - Registrar proveedores y mantener sus datos de contacto
-- sp_registrarProveedor: registra un nuevo proveedor validando que el CUIT no exista.

CREATE PROCEDURE sp_registrarProveedor
    @RazonSocial VARCHAR(150),
    @CUIT VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE CUIT = @CUIT
    )
    BEGIN
        PRINT 'Ya existe un proveedor registrado con ese CUIT.';
        RETURN;
    END

    INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
    VALUES (@RazonSocial, @CUIT, @Email, @Telefono, @Direccion, 1);

    PRINT 'Proveedor registrado correctamente.';
END;
GO

-- sp_actualizarContactoProveedor: actualizar datos como email, telefono y direccion de un proveedor existente

CREATE PROCEDURE sp_actualizarContactoProveedor
    @IdProveedor INT,
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con el IdProveedor ingresado';
        RETURN;
    END

    UPDATE Proveedores
    SET Email = @Email,
        Telefono = @Telefono,
        Direccion = @Direccion
    WHERE IdProveedor = @IdProveedor;

PRINT 'Datos de contacto actualizados correctamente.';
END;
GO

------------------------------------------------------------------------------------------------
-- #5 - Registrar clientes para asociarlos a las ventas realizadas
-- sp_registrarCliente: registra un nuevo cliente el numero de documento

CREATE PROCEDURE sp_registrarCliente
    @Apellido VARCHAR(100),
    @Nombre VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30)
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE Documento = @Documento
    )
    BEGIN
        PRINT 'Ya existe un cliente registrado con ese documento';
        RETURN;
    END

    INSERT INTO Clientes (Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo)
    VALUES (@Apellido, @Nombre, @Documento, @Email, @Telefono, GETDATE(), 1);

    PRINT 'Cliente registrado correctamente';
END;
GO

------------------------------------------------------------------------------------------------
-- #7 - Registrar compras de mercadería realizadas a proveedores
-- sp_registrarCompra: registra una compra validando bien los datos de entrada.

CREATE PROCEDURE sp_registrarCompra
    @IdProveedor INT,
    @IdEmpleado INT,
    @IdEstadoCompra INT,
    @NumeroComprobante VARCHAR(50)
AS
BEGIN
-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'Debe ingresar un id de proveedor valido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'Debe ingresar un id de empleado valido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'Debe ingresar un id de estado de compra valido';
        RETURN;
    END
    
-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con el id ingresado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor ingresado no se encuentra activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con el id ingresado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado ingresado no se encuentra activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
    )
    BEGIN
        PRINT 'No existe un estado de compra con el id ingresado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
          AND UPPER(Nombre) = 'CANCELADA'
    )
    BEGIN
        PRINT 'No se puede registrar una compra nueva con estado cancelada';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

-- Registrar la compra con los datos ingresados, el campo Total se completa con 0 ya que se actualizara al agregar los detalles de compra
    INSERT INTO Compras (IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total)
    VALUES (@IdProveedor, @IdEmpleado, @IdEstadoCompra, SYSDATETIME(), @NumeroComprobante, 0);

    PRINT 'Compra registrada correctamente';
END;
GO

-- sp_actualizarCompra: actualiza los datos principales de una compra existente.

CREATE PROCEDURE sp_actualizarCompra
    @IdCompra INT,
    @IdProveedor INT,
    @IdEmpleado INT,
    @IdEstadoCompra INT,
    @NumeroComprobante VARCHAR(50)
AS
BEGIN
-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

-- Validar datos ingresados, asi como se hace en el procedimiento de registro pero considerando que el numero de comprobante repetido no es valido
    IF @IdCompra IS NULL OR @IdCompra <= 0
    BEGIN
        PRINT 'Debe ingresar un id de compra valido';
        RETURN;
    END

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'Debe ingresar un id de proveedor valido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'Debe ingresar un id de empleado valido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'Debe ingresar un id de estado de compra valido';
        RETURN;
    END

-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Compras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No existe una compra con el id ingresado';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con el id ingresado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor ingresado no se encuentra activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con el id ingresado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado ingresado no se encuentra activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
    )
    BEGIN
        PRINT 'No existe un estado de compra con el id ingresado';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

-- Actualizar la compra con los nuevos datos ingresados.
    UPDATE Compras
    SET IdProveedor = @IdProveedor,
        IdEmpleado = @IdEmpleado,
        IdEstadoCompra = @IdEstadoCompra,
        NumeroComprobante = @NumeroComprobante
    WHERE IdCompra = @IdCompra;

    PRINT 'Compra actualizada correctamente';
END;
GO
------------------------------------------------------------------------------------------------
