-- Detalle de ventas

-- sp_registrarDetalleVenta: agrega un registro de detalle a una venta.
CREATE PROCEDURE sp_registrarDetalleVenta
    @IdVenta INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @PrecioUnitario DECIMAL(12,2);
    DECLARE @Subtotal DECIMAL(12,2);

    IF @IdVenta IS NULL OR @IdVenta <= 0
    BEGIN
        PRINT 'El id de venta es invalido';
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

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas
        WHERE IdVenta = @IdVenta
    )
    BEGIN
        PRINT 'No existe una venta con ese id';
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

-- Validamos que la venta no este confirmada, ya que no se puede modificar el detalle de una venta confirmada.
    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
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

    SELECT @PrecioUnitario = PrecioVenta
    FROM Productos
    WHERE IdProducto = @IdProducto;

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    INSERT INTO DetalleVentas (IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal)
    VALUES (@IdVenta, @IdProducto, @Cantidad, @PrecioUnitario, @Subtotal);

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta registrado';
END;
GO

-- sp_actualizarDetalleVenta: actualiza un registro de detalle de venta.
CREATE PROCEDURE sp_actualizarDetalleVenta
    @IdDetalleVenta INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @PrecioUnitario DECIMAL(12,2);
    DECLARE @Subtotal DECIMAL(12,2);
    DECLARE @IdVenta INT;

    IF @IdDetalleVenta IS NULL OR @IdDetalleVenta <= 0
    BEGIN
        PRINT 'El id de detalle de venta es invalido';
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

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleVentas
        WHERE IdDetalleVenta = @IdDetalleVenta
    )
    BEGIN
        PRINT 'No existe un detalle de venta con ese id';
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

    SELECT @IdVenta = IdVenta
    FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
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

    SELECT @PrecioUnitario = PrecioVenta
    FROM Productos
    WHERE IdProducto = @IdProducto;

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    UPDATE DetalleVentas
    SET IdProducto = @IdProducto,
        Cantidad = @Cantidad,
        PrecioUnitario = @PrecioUnitario,
        Subtotal = @Subtotal
    WHERE IdDetalleVenta = @IdDetalleVenta;

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta actualizado';
END;
GO

-- sp_eliminarDetalleVenta: elimina una linea de detalle de venta.
CREATE PROCEDURE sp_eliminarDetalleVenta
    @IdDetalleVenta INT
AS
BEGIN
    DECLARE @IdVenta INT;

    IF @IdDetalleVenta IS NULL OR @IdDetalleVenta <= 0
    BEGIN
        PRINT 'El id de detalle de venta es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleVentas
        WHERE IdDetalleVenta = @IdDetalleVenta
    )
    BEGIN
        PRINT 'No existe un detalle de venta con ese id';
        RETURN;
    END

    SELECT @IdVenta = IdVenta
    FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
        RETURN;
    END

    DELETE FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta eliminado';
END;
GO
