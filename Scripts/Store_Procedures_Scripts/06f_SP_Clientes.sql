-- Clientes

-- sp_registrarCliente: da de alta un cliente y valida que el documento no se repita.
IF OBJECT_ID(N'dbo.sp_registrarCliente', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_registrarCliente;
GO

CREATE PROCEDURE sp_registrarCliente
    @Apellido VARCHAR(100),
    @Nombre VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30)
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Documento = LTRIM(RTRIM(@Documento));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF @Apellido IS NULL OR @Apellido = ''
    BEGIN
        PRINT 'Falta el apellido';
        RETURN;
    END

    IF @Nombre IS NULL OR @Nombre = ''
    BEGIN
        PRINT 'Falta el nombre';
        RETURN;
    END

    IF @Documento IS NULL OR @Documento = ''
    BEGIN
        PRINT 'Falta el documento';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE UPPER(Documento) = UPPER(@Documento)
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

-- sp_actualizarCliente: actualiza los datos principales de un cliente existente.
IF OBJECT_ID(N'dbo.sp_actualizarCliente', N'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_actualizarCliente;
GO

CREATE PROCEDURE sp_actualizarCliente
    @IdCliente INT,
    @Apellido VARCHAR(100),
    @Nombre VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Activo BIT
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Documento = LTRIM(RTRIM(@Documento));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF @IdCliente IS NULL OR @IdCliente <= 0
    BEGIN
        PRINT 'IdCliente invalido';
        RETURN;
    END

    IF @Apellido IS NULL OR @Apellido = ''
    BEGIN
        PRINT 'Falta el apellido';
        RETURN;
    END

    IF @Nombre IS NULL OR @Nombre = ''
    BEGIN
        PRINT 'Falta el nombre';
        RETURN;
    END

    IF @Documento IS NULL OR @Documento = ''
    BEGIN
        PRINT 'Falta el documento';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM Clientes
        WHERE IdCliente = @IdCliente
    )
    BEGIN
        PRINT 'No existe un cliente con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE UPPER(Documento) = UPPER(@Documento)
          AND IdCliente <> @IdCliente
    )
    BEGIN
        PRINT 'Ya existe otro cliente con ese documento';
        RETURN;
    END

    UPDATE Clientes
    SET Apellido = @Apellido,
        Nombre = @Nombre,
        Documento = @Documento,
        Email = @Email,
        Telefono = @Telefono,
        Activo = @Activo
    WHERE IdCliente = @IdCliente;

    PRINT 'Cliente actualizado';
END;
GO
