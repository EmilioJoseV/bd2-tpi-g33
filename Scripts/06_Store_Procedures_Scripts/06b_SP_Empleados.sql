------------------------------------------------------------------------------------------------
-- Empleados

------------------------------------------------------------------------------------------------
-- SP_Empleado_Registrar
IF OBJECT_ID(N'dbo.SP_Empleado_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Registrar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Registrar
    @Apellido  varchar(100),
    @Nombre    varchar(100),
    @Documento varchar(20),
    @Email     varchar(150) = NULL,
    @Telefono  varchar(30)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Apellido, ''))) = ''
        THROW 50011, 'El apellido es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50012, 'El nombre es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Documento, ''))) = ''
        THROW 50013, 'El documento es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Empleados WHERE Documento = LTRIM(RTRIM(@Documento)))
        THROW 50014, 'Ya existe un empleado con ese documento.', 1;

    BEGIN TRY
        INSERT INTO Empleados (Apellido, Nombre, Documento, Email, Telefono, Activo)
        VALUES (
            LTRIM(RTRIM(@Apellido)),
            LTRIM(RTRIM(@Nombre)),
            LTRIM(RTRIM(@Documento)),
            NULLIF(LTRIM(RTRIM(@Email)), ''),
            NULLIF(LTRIM(RTRIM(@Telefono)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50014, 'Ya existe un empleado con ese documento.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = SCOPE_IDENTITY();
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Empleado_Actualizar
IF OBJECT_ID(N'dbo.SP_Empleado_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Actualizar
    @IdEmpleado int,
    @Apellido   varchar(100),
    @Nombre     varchar(100),
    @Documento  varchar(20),
    @Email      varchar(150) = NULL,
    @Telefono   varchar(30)  = NULL,
    @Activo     bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Apellido, ''))) = ''
        THROW 50011, 'El apellido es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50012, 'El nombre es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Documento, ''))) = ''
        THROW 50013, 'El documento es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Empleados
        WHERE Documento = LTRIM(RTRIM(@Documento))
          AND IdEmpleado <> @IdEmpleado
    )
        THROW 50014, 'Ya existe otro empleado con ese documento.', 1;

    BEGIN TRY
        UPDATE Empleados
        SET Apellido  = LTRIM(RTRIM(@Apellido)),
            Nombre    = LTRIM(RTRIM(@Nombre)),
            Documento = LTRIM(RTRIM(@Documento)),
            Email     = NULLIF(LTRIM(RTRIM(@Email)), ''),
            Telefono  = NULLIF(LTRIM(RTRIM(@Telefono)), ''),
            Activo    = @Activo
        WHERE IdEmpleado = @IdEmpleado;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50014, 'Ya existe otro empleado con ese documento.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Empleado_Desactivar
IF OBJECT_ID(N'dbo.SP_Empleado_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Desactivar
    @IdEmpleado int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    UPDATE Empleados
    SET Activo = 0
    WHERE IdEmpleado = @IdEmpleado;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Empleado_Reactivar
IF OBJECT_ID(N'dbo.SP_Empleado_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Reactivar
    @IdEmpleado int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    UPDATE Empleados
    SET Activo = 1
    WHERE IdEmpleado = @IdEmpleado;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO
