-- Categorias

-- SP_Categoria_Registrar
IF OBJECT_ID(N'dbo.SP_Categoria_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Registrar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Registrar
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50041, 'El nombre de la categoria es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Categorias WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50042, 'Ya existe una categoria con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Categorias (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50042, 'Ya existe una categoria con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = SCOPE_IDENTITY();
END;
GO


-- SP_Categoria_Actualizar
IF OBJECT_ID(N'dbo.SP_Categoria_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Actualizar
    @IdCategoria int,
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50041, 'El nombre de la categoria es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Categorias
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdCategoria <> @IdCategoria
    )
        THROW 50042, 'Ya existe otra categoria con ese nombre.', 1;

    BEGIN TRY
        UPDATE Categorias
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdCategoria = @IdCategoria;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50042, 'Ya existe otra categoria con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO


-- SP_Categoria_Desactivar
IF OBJECT_ID(N'dbo.SP_Categoria_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Desactivar
    @IdCategoria int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    UPDATE Categorias
    SET Activo = 0
    WHERE IdCategoria = @IdCategoria;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO


-- SP_Categoria_Reactivar
IF OBJECT_ID(N'dbo.SP_Categoria_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Reactivar
    @IdCategoria int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    UPDATE Categorias
    SET Activo = 1
    WHERE IdCategoria = @IdCategoria;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO
