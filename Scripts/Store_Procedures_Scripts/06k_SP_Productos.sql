-- Productos

-- SP_Producto_Registrar
IF OBJECT_ID(N'dbo.SP_Producto_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Registrar;
GO

CREATE PROCEDURE dbo.SP_Producto_Registrar
    @IdCategoria     int,
    @IdMarca         int,
    @IdTalle         int,
    @IdColor         int,
    @CodigoProducto  varchar(50),
    @Nombre          varchar(150),
    @Descripcion     varchar(255) = NULL,
    @PrecioVenta     decimal(12,2),
    @StockActual     int = 0,
    @StockMinimo     int = 0
AS
BEGIN
    SET NOCOUNT ON;

    SET @CodigoProducto = LTRIM(RTRIM(@CodigoProducto));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Descripcion = LTRIM(RTRIM(@Descripcion));

    IF @CodigoProducto IS NULL OR @CodigoProducto = ''
        THROW 50061, 'El codigo del producto es obligatorio.', 1;

    IF @Nombre IS NULL OR @Nombre = ''
        THROW 50063, 'El nombre del producto es obligatorio.', 1;

    IF @Descripcion = ''
        SET @Descripcion = NULL;

    IF @PrecioVenta IS NULL OR @PrecioVenta < 0
        THROW 50064, 'El precio de venta es invalido.', 1;

    IF @StockActual IS NULL OR @StockActual < 0
        THROW 50065, 'El stock actual es invalido.', 1;

    IF @StockMinimo IS NULL OR @StockMinimo < 0
        THROW 50065, 'El stock minimo es invalido.', 1;

    IF @IdCategoria IS NULL OR @IdCategoria <= 0
        THROW 50066, 'La categoria indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Categorias
        WHERE IdCategoria = @IdCategoria
          AND Activo = 1
    )
        THROW 50066, 'La categoria indicada no existe o no esta activa.', 1;

    IF @IdMarca IS NULL OR @IdMarca <= 0
        THROW 50067, 'La marca indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE IdMarca = @IdMarca
          AND Activo = 1
    )
        THROW 50067, 'La marca indicada no existe o no esta activa.', 1;

    IF @IdTalle IS NULL OR @IdTalle <= 0
        THROW 50068, 'El talle indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Talles
        WHERE IdTalle = @IdTalle
          AND Activo = 1
    )
        THROW 50068, 'El talle indicado no existe o no esta activo.', 1;

    IF @IdColor IS NULL OR @IdColor <= 0
        THROW 50069, 'El color indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Colores
        WHERE IdColor = @IdColor
          AND Activo = 1
    )
        THROW 50069, 'El color indicado no existe o no esta activo.', 1;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE CodigoProducto = @CodigoProducto
    )
        THROW 50062, 'Ya existe un producto con ese codigo.', 1;

    BEGIN TRY
        INSERT INTO Productos (
            IdCategoria,
            IdMarca,
            IdTalle,
            IdColor,
            CodigoProducto,
            Nombre,
            Descripcion,
            PrecioVenta,
            StockActual,
            StockMinimo,
            Activo
        )
        VALUES (
            @IdCategoria,
            @IdMarca,
            @IdTalle,
            @IdColor,
            @CodigoProducto,
            @Nombre,
            @Descripcion,
            @PrecioVenta,
            @StockActual,
            @StockMinimo,
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50062, 'Ya existe un producto con ese codigo.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = SCOPE_IDENTITY();
END;
GO


-- SP_Producto_AjustarStock
IF OBJECT_ID(N'dbo.SP_Producto_AjustarStock', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_AjustarStock;
GO

CREATE PROCEDURE dbo.SP_Producto_AjustarStock
    @IdProducto int,
    @Operacion varchar(10),
    @Cantidad int,
    @IdEmpleado int = NULL,
    @Motivo varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdTipoMovimientoStock int;
    DECLARE @CantidadAAjustar int;

    SET @Operacion = UPPER(LTRIM(RTRIM(@Operacion)));
    SET @Motivo = LTRIM(RTRIM(@Motivo));

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 1
    )
        THROW 50070, 'El producto indicado no existe o no esta activo.', 1;

    IF @Operacion IS NULL OR @Operacion NOT IN ('SUMAR', 'RESTAR')
        THROW 50072, 'La operacion de stock debe ser SUMAR o RESTAR.', 1;

    IF @Cantidad IS NULL OR @Cantidad <= 0
        THROW 50073, 'La cantidad del ajuste debe ser mayor a cero.', 1;

    IF @IdEmpleado IS NOT NULL AND NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 1
    )
        THROW 50074, 'El empleado indicado no existe o no esta activo.', 1;

    IF @Motivo = ''
        SET @Motivo = NULL;

    SET @CantidadAAjustar = CASE
        WHEN @Operacion = 'SUMAR' THEN @Cantidad
        ELSE -@Cantidad
    END;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND StockActual + @CantidadAAjustar < 0
    )
        THROW 50075, 'El ajuste no puede dejar stock negativo.', 1;

    SELECT @IdTipoMovimientoStock = IdTipoMovimientoStock
    FROM TiposMovimientoStock
    WHERE Nombre = CASE
        WHEN @Operacion = 'SUMAR' THEN 'Ajuste manual'
        ELSE 'Ajuste negativo'
    END;

    IF @IdTipoMovimientoStock IS NULL
        THROW 50076, 'No existe el tipo de movimiento de stock requerido.', 1;

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE Productos
        SET StockActual = StockActual + @CantidadAAjustar
        WHERE IdProducto = @IdProducto;

        INSERT INTO MovimientosStock (
            IdProducto,
            IdTipoMovimientoStock,
            IdEmpleado,
            IdCompra,
            IdVenta,
            FechaMovimiento,
            Cantidad,
            Motivo
        )
        VALUES (
            @IdProducto,
            @IdTipoMovimientoStock,
            @IdEmpleado,
            NULL,
            NULL,
            SYSDATETIME(),
            @Cantidad,
            COALESCE(@Motivo, 'Ajuste manual de stock')
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Actualizar
IF OBJECT_ID(N'dbo.SP_Producto_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Producto_Actualizar
    @IdProducto      int,
    @IdCategoria     int,
    @IdMarca         int,
    @IdTalle         int,
    @IdColor         int,
    @CodigoProducto  varchar(50),
    @Nombre          varchar(150),
    @Descripcion     varchar(255) = NULL,
    @PrecioVenta     decimal(12,2),
    @StockActual     int,
    @StockMinimo     int,
    @Activo          bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @CodigoProducto = LTRIM(RTRIM(@CodigoProducto));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Descripcion = LTRIM(RTRIM(@Descripcion));

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    IF @CodigoProducto IS NULL OR @CodigoProducto = ''
        THROW 50061, 'El codigo del producto es obligatorio.', 1;

    IF @Nombre IS NULL OR @Nombre = ''
        THROW 50063, 'El nombre del producto es obligatorio.', 1;

    IF @Descripcion = ''
        SET @Descripcion = NULL;

    IF @PrecioVenta IS NULL OR @PrecioVenta < 0
        THROW 50064, 'El precio de venta es invalido.', 1;

    IF @StockActual IS NULL OR @StockActual < 0
        THROW 50065, 'El stock actual es invalido.', 1;

    IF @StockMinimo IS NULL OR @StockMinimo < 0
        THROW 50065, 'El stock minimo es invalido.', 1;

    IF @IdCategoria IS NULL OR @IdCategoria <= 0
        THROW 50066, 'La categoria indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Categorias
        WHERE IdCategoria = @IdCategoria
          AND Activo = 1
    )
        THROW 50066, 'La categoria indicada no existe o no esta activa.', 1;

    IF @IdMarca IS NULL OR @IdMarca <= 0
        THROW 50067, 'La marca indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE IdMarca = @IdMarca
          AND Activo = 1
    )
        THROW 50067, 'La marca indicada no existe o no esta activa.', 1;

    IF @IdTalle IS NULL OR @IdTalle <= 0
        THROW 50068, 'El talle indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Talles
        WHERE IdTalle = @IdTalle
          AND Activo = 1
    )
        THROW 50068, 'El talle indicado no existe o no esta activo.', 1;

    IF @IdColor IS NULL OR @IdColor <= 0
        THROW 50069, 'El color indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Colores
        WHERE IdColor = @IdColor
          AND Activo = 1
    )
        THROW 50069, 'El color indicado no existe o no esta activo.', 1;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE CodigoProducto = @CodigoProducto
          AND IdProducto <> @IdProducto
    )
        THROW 50062, 'Ya existe otro producto con ese codigo.', 1;

    BEGIN TRY
        UPDATE Productos
        SET IdCategoria    = @IdCategoria,
            IdMarca        = @IdMarca,
            IdTalle        = @IdTalle,
            IdColor        = @IdColor,
            CodigoProducto = @CodigoProducto,
            Nombre         = @Nombre,
            Descripcion    = @Descripcion,
            PrecioVenta    = @PrecioVenta,
            StockActual    = @StockActual,
            StockMinimo    = @StockMinimo,
            Activo         = @Activo
        WHERE IdProducto = @IdProducto;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50062, 'Ya existe otro producto con ese codigo.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Desactivar
IF OBJECT_ID(N'dbo.SP_Producto_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Producto_Desactivar
    @IdProducto int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    UPDATE Productos
    SET Activo = 0
    WHERE IdProducto = @IdProducto;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Reactivar
IF OBJECT_ID(N'dbo.SP_Producto_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Producto_Reactivar
    @IdProducto int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    UPDATE Productos
    SET Activo = 1
    WHERE IdProducto = @IdProducto;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO
