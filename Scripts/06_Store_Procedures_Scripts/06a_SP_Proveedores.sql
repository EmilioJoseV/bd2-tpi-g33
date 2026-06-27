------------------------------------------------------------------------------------------------
-- Proveedores

------------------------------------------------------------------------------------------------
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

    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    IF @RazonSocial IS NULL OR @RazonSocial = ''
        THROW 50001, 'La razon social es obligatoria.', 1;

    IF @CUIT IS NULL OR @CUIT = ''
        THROW 50002, 'El CUIT es obligatorio.', 1;

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
        THROW 50003, 'Ya existe un proveedor con ese CUIT.', 1;

    BEGIN TRY
        INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
        VALUES (
            @RazonSocial,
            @CUIT,
            @Email,
            @Telefono,
            @Direccion,
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

------------------------------------------------------------------------------------------------
-- SP_Proveedor_Actualizar (Actualiza los datos principales de un proveedor existente.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Actualizar
    @IdProveedor int,
    @RazonSocial varchar(150),
    @CUIT        varchar(20),
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

    IF @RazonSocial IS NULL OR @RazonSocial = ''
        THROW 50001, 'La razon social es obligatoria.', 1;

    IF @CUIT IS NULL OR @CUIT = ''
        THROW 50002, 'El CUIT es obligatorio.', 1;

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
          AND IdProveedor <> @IdProveedor
    )
        THROW 50003, 'Ya existe otro proveedor con ese CUIT.', 1;

    BEGIN TRY
        UPDATE Proveedores
        SET RazonSocial = @RazonSocial,
            CUIT        = @CUIT,
            Email       = @Email,
            Telefono    = @Telefono,
            Direccion   = @Direccion,
            Activo      = @Activo
        WHERE IdProveedor = @IdProveedor;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50003, 'Ya existe otro proveedor con ese CUIT.', 1;
        ELSE
            THROW;
    END CATCH;

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

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

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

------------------------------------------------------------------------------------------------
-- SP_Proveedor_Reactivar (Reactivacion de un proveedor desactivado.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Reactivar
    @IdProveedor int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

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
