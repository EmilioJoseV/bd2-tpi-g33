--#region Proveedores

-- SPNuevoProveedor (Procedimiento para registrar un nuevo proveedor y mantener sus datos de contacto)
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


--#endregion 

--#region Empleados
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
