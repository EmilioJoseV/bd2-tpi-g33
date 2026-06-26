-- Detalle de compras

-- SP_DetalleCompra_Registrar: agrega un registro de detalle a una compra.
IF OBJECT_ID(N'dbo.SP_DetalleCompra_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_DetalleCompra_Registrar;
GO

CREATE PROCEDURE dbo.SP_DetalleCompra_Registrar
    @IdCompra INT,
    @IdProducto INT,
    @Cantidad INT,
    @PrecioUnitario DECIMAL(12,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(12,2);

    IF @IdCompra IS NULL OR @IdCompra <= 0
    BEGIN
        PRINT 'El id de compra es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF @PrecioUnitario IS NULL OR @PrecioUnitario < 0
    BEGIN
        PRINT 'El precio unitario es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Compras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No existe una compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    INSERT INTO DetalleCompras (IdCompra, IdProducto, Cantidad, PrecioUnitario, Subtotal)
    VALUES (@IdCompra, @IdProducto, @Cantidad, @PrecioUnitario, @Subtotal);

    PRINT 'Detalle de compra registrado';
END;
GO

-- SP_DetalleCompra_Actualizar: actualiza una linea de detalle de compra.
IF OBJECT_ID(N'dbo.SP_DetalleCompra_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_DetalleCompra_Actualizar;
GO

CREATE PROCEDURE dbo.SP_DetalleCompra_Actualizar
    @IdDetalleCompra INT,
    @IdProducto INT,
    @Cantidad INT,
    @PrecioUnitario DECIMAL(12,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(12,2);
    DECLARE @IdCompra INT;

    IF @IdDetalleCompra IS NULL OR @IdDetalleCompra <= 0
    BEGIN
        PRINT 'El id de detalle de compra es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF @PrecioUnitario IS NULL OR @PrecioUnitario < 0
    BEGIN
        PRINT 'El precio unitario es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdDetalleCompra = @IdDetalleCompra
    )
    BEGIN
        PRINT 'No existe un detalle de compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

    SELECT @IdCompra = IdCompra
    FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

-- Valiamdos que la compra no este confirmada, ya que no se puede modificar el detalle de una compra confirmada.
    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    UPDATE DetalleCompras
    SET IdProducto = @IdProducto,
        Cantidad = @Cantidad,
        PrecioUnitario = @PrecioUnitario,
        Subtotal = @Subtotal
    WHERE IdDetalleCompra = @IdDetalleCompra;

    PRINT 'Detalle de compra actualizado';
END;
GO

-- SP_DetalleCompra_Eliminar: elimina una linea de detalle de compra.
IF OBJECT_ID(N'dbo.SP_DetalleCompra_Eliminar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_DetalleCompra_Eliminar;
GO

CREATE PROCEDURE dbo.SP_DetalleCompra_Eliminar
    @IdDetalleCompra INT
AS
BEGIN
    DECLARE @IdCompra INT;

    IF @IdDetalleCompra IS NULL OR @IdDetalleCompra <= 0
    BEGIN
        PRINT 'El id de detalle de compra es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdDetalleCompra = @IdDetalleCompra
    )
    BEGIN
        PRINT 'No existe un detalle de compra con ese id';
        RETURN;
    END

    SELECT @IdCompra = IdCompra
    FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

-- Validamos que la compra no este confirmada, ya que no se puede modificar el detalle de una compra confirmada.
    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    DELETE FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

    PRINT 'Detalle de compra eliminado';
END;
GO
