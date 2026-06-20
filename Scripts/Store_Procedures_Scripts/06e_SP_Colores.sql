-- Colores

-- SP_Color_Registrar
IF OBJECT_ID(N'dbo.SP_Color_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Registrar;
GO

CREATE PROCEDURE dbo.SP_Color_Registrar
    @Nombre varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50031, 'El nombre del color es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Colores WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50032, 'Ya existe un color con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Colores (Nombre, Activo)
        VALUES (LTRIM(RTRIM(@Nombre)), 1);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50032, 'Ya existe un color con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = SCOPE_IDENTITY();
END;
GO


-- SP_Color_Actualizar
IF OBJECT_ID(N'dbo.SP_Color_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Color_Actualizar
    @IdColor int,
    @Nombre  varchar(50),
    @Activo  bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50031, 'El nombre del color es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Colores
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdColor <> @IdColor
    )
        THROW 50032, 'Ya existe otro color con ese nombre.', 1;

    BEGIN TRY
        UPDATE Colores
        SET Nombre = LTRIM(RTRIM(@Nombre)),
            Activo = @Activo
        WHERE IdColor = @IdColor;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50032, 'Ya existe otro color con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO


-- SP_Color_Desactivar
IF OBJECT_ID(N'dbo.SP_Color_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Color_Desactivar
    @IdColor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    UPDATE Colores
    SET Activo = 0
    WHERE IdColor = @IdColor;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO


-- SP_Color_Reactivar
IF OBJECT_ID(N'dbo.SP_Color_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Color_Reactivar
    @IdColor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    UPDATE Colores
    SET Activo = 1
    WHERE IdColor = @IdColor;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO
