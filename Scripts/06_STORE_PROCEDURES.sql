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
