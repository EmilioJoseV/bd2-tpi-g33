-- Marcas

-- SP_Marca_Registrar
IF OBJECT_ID(N'dbo.SP_Marca_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Registrar;
GO

CREATE PROCEDURE dbo.SP_Marca_Registrar
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50021, 'El nombre de la marca es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Marcas WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50022, 'Ya existe una marca con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Marcas (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50022, 'Ya existe una marca con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = SCOPE_IDENTITY();
END;
GO


-- SP_Marca_Actualizar
IF OBJECT_ID(N'dbo.SP_Marca_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Marca_Actualizar
    @IdMarca     int,
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50021, 'El nombre de la marca es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Marcas
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdMarca <> @IdMarca
    )
        THROW 50022, 'Ya existe otra marca con ese nombre.', 1;

    BEGIN TRY
        UPDATE Marcas
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdMarca = @IdMarca;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50022, 'Ya existe otra marca con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO


-- SP_Marca_Desactivar
IF OBJECT_ID(N'dbo.SP_Marca_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Marca_Desactivar
    @IdMarca int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    UPDATE Marcas
    SET Activo = 0
    WHERE IdMarca = @IdMarca;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO


-- SP_Marca_Reactivar
IF OBJECT_ID(N'dbo.SP_Marca_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Marca_Reactivar
    @IdMarca int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    UPDATE Marcas
    SET Activo = 1
    WHERE IdMarca = @IdMarca;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO
