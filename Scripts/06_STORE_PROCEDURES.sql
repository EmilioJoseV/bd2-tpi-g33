USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #3 - Registrar y administrar proveedores
-- sp_registrarProveedor: da de alta un proveedor y valida que el CUIT no se repita.

CREATE PROCEDURE sp_registrarProveedor
    @RazonSocial VARCHAR(150),
    @CUIT VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200)
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    -- Validar los datos obligatorios antes del insert.
    IF @RazonSocial IS NULL OR @RazonSocial = ''
    BEGIN
        PRINT 'Falta la razon social.';
        RETURN;
    END

    IF @CUIT IS NULL OR @CUIT = ''
    BEGIN
        PRINT 'Falta el CUIT.';
        RETURN;
    END

    -- Si vino vacio en los opcionales, se guarda como NULL.
    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
    )
    BEGIN
        PRINT 'Ya existe un proveedor con ese CUIT.';
        RETURN;
    END

    INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
    VALUES (@RazonSocial, @CUIT, @Email, @Telefono, @Direccion, 1);

    PRINT 'Proveedor registrado.';
END;
GO

-- sp_actualizarProveedor: actualiza los datos principales de un proveedor existente.

CREATE PROCEDURE sp_actualizarProveedor
    @IdProveedor INT,
    @RazonSocial VARCHAR(150),
    @CUIT VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200),
    @Activo BIT
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    -- Validar que el id y los datos obligatorios vengan bien.
    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'IdProveedor invalido.';
        RETURN;
    END

    IF @RazonSocial IS NULL OR @RazonSocial = ''
    BEGIN
        PRINT 'Falta la razon social.';
        RETURN;
    END

    IF @CUIT IS NULL OR @CUIT = ''
    BEGIN
        PRINT 'Falta el CUIT.';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
          AND IdProveedor <> @IdProveedor
    )
    BEGIN
        PRINT 'Ya existe otro proveedor con ese CUIT.';
        RETURN;
    END

    UPDATE Proveedores
    SET RazonSocial = @RazonSocial,
        CUIT = @CUIT,
        Email = @Email,
        Telefono = @Telefono,
        Direccion = @Direccion,
        Activo = @Activo
    WHERE IdProveedor = @IdProveedor;

    PRINT 'Proveedor actualizado.';
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
        PRINT 'Ya existe un cliente con ese documento';
        RETURN;
    END

    INSERT INTO Clientes (Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo)
    VALUES (@Apellido, @Nombre, @Documento, @Email, @Telefono, GETDATE(), 1);

    PRINT 'Cliente registrado';
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
        PRINT 'IdProveedor invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'IdEmpleado invalido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'IdEstadoCompra invalido';
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

    IF NOT EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
    )
    BEGIN
        PRINT 'No existe un estado de compra con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
          AND UPPER(Nombre) = 'CANCELADA'
    )
    BEGIN
        PRINT 'No se puede registrar una compra cancelada';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

-- Registrar la compra con los datos ingresados, el campo Total se completa con 0 ya que se actualizara al agregar los detalles de compra
    INSERT INTO Compras (IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total)
    VALUES (@IdProveedor, @IdEmpleado, @IdEstadoCompra, SYSDATETIME(), @NumeroComprobante, 0);

    PRINT 'Compra registrada';
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
        PRINT 'IdCompra invalido';
        RETURN;
    END

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'IdProveedor invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'IdEmpleado invalido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'IdEstadoCompra invalido';
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

-- Actualizar la compra con los nuevos datos ingresados.
    UPDATE Compras
    SET IdProveedor = @IdProveedor,
        IdEmpleado = @IdEmpleado,
        IdEstadoCompra = @IdEstadoCompra,
        NumeroComprobante = @NumeroComprobante
    WHERE IdCompra = @IdCompra;

    PRINT 'Compra actualizada';
END;
GO
------------------------------------------------------------------------------------------------
