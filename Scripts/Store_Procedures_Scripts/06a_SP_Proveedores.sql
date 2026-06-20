-- Proveedores

-- SP_Proveedor_Registrar (Procedimiento para registrar un nuevo proveedor y mantener sus datos de contacto)
IF OBJECT_ID(N'dbo.SP_Proveedor_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Registrar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Registrar
    @RazonSocial varchar(150),
    @CUIT        varchar(20),
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@RazonSocial, ''))) = ''
        THROW 50001, 'La razon social es obligatoria.', 1;

    IF LTRIM(RTRIM(ISNULL(@CUIT, ''))) = ''
        THROW 50002, 'El CUIT es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Proveedores WHERE CUIT = LTRIM(RTRIM(@CUIT)))
        THROW 50003, 'Ya existe un proveedor con ese CUIT.', 1;

    BEGIN TRY
        INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
        VALUES (
            LTRIM(RTRIM(@RazonSocial)),
            LTRIM(RTRIM(@CUIT)),
            NULLIF(LTRIM(RTRIM(@Email)), ''),
            NULLIF(LTRIM(RTRIM(@Telefono)), ''),
            NULLIF(LTRIM(RTRIM(@Direccion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50003, 'Ya existe un proveedor con ese CUIT.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = SCOPE_IDENTITY();
END;
GO


-- SP_Proveedor_ActualizarContacto (Mantener sus datos de contacto: solo Email, Telefono y Direccion.)
IF OBJECT_ID(N'dbo.SP_Proveedor_ActualizarContacto', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_ActualizarContacto;
GO

CREATE PROCEDURE dbo.SP_Proveedor_ActualizarContacto
    @IdProveedor int,
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Email     = NULLIF(LTRIM(RTRIM(@Email)), ''),
        Telefono  = NULLIF(LTRIM(RTRIM(@Telefono)), ''),
        Direccion = NULLIF(LTRIM(RTRIM(@Direccion)), '')
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO


-- SP_Proveedor_Desactivar (Baja logica.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Desactivar
    @IdProveedor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Activo = 0
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO


-- SP_Proveedor_Reactivar (Reactivacion de un proveedor desactivado.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Reactivar
    @IdProveedor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Activo = 1
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO
