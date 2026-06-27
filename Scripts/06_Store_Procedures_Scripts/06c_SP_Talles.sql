------------------------------------------------------------------------------------------------
-- Talles

------------------------------------------------------------------------------------------------
-- SP_Talle_Registrar
IF OBJECT_ID(N'dbo.SP_Talle_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Registrar;
GO

CREATE PROCEDURE dbo.SP_Talle_Registrar
    @Nombre      varchar(20),
    @Descripcion varchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50051, 'El nombre del talle es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Talles WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50052, 'Ya existe un talle con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Talles (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50052, 'Ya existe un talle con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = SCOPE_IDENTITY();
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Talle_Actualizar
IF OBJECT_ID(N'dbo.SP_Talle_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Talle_Actualizar
    @IdTalle     int,
    @Nombre      varchar(20),
    @Descripcion varchar(100) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50051, 'El nombre del talle es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Talles
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdTalle <> @IdTalle
    )
        THROW 50052, 'Ya existe otro talle con ese nombre.', 1;

    BEGIN TRY
        UPDATE Talles
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdTalle = @IdTalle;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50052, 'Ya existe otro talle con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Talle_Desactivar
IF OBJECT_ID(N'dbo.SP_Talle_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Talle_Desactivar
    @IdTalle int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    UPDATE Talles
    SET Activo = 0
    WHERE IdTalle = @IdTalle;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO

------------------------------------------------------------------------------------------------
-- SP_Talle_Reactivar
IF OBJECT_ID(N'dbo.SP_Talle_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Talle_Reactivar
    @IdTalle int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    UPDATE Talles
    SET Activo = 1
    WHERE IdTalle = @IdTalle;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO
