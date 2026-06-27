USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- TRG_Venta_ActualizarStockPorEstado: toca el stock si la venta pasa a confirmada o deja de estarlo.

IF OBJECT_ID(N'dbo.TRG_Venta_ActualizarStockPorEstado', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TRG_Venta_ActualizarStockPorEstado;
GO

CREATE TRIGGER dbo.TRG_Venta_ActualizarStockPorEstado
ON Ventas
AFTER UPDATE
AS
BEGIN
    DECLARE @VentasQueSeConfirmaron TABLE (
        IdVenta INT
    );

    DECLARE @VentasQueSeDesconfirmaron TABLE (
        IdVenta INT
    );

    DECLARE @MovimientosStock TABLE (
        IdProducto INT,
        CantidadAAjustar INT
    );

    -- Aca guardamos las ventas que antes no estaban confirmadas y ahora si.
    INSERT INTO @VentasQueSeConfirmaron (IdVenta)
    SELECT i.IdVenta
    FROM inserted i
    INNER JOIN deleted d ON d.IdVenta = i.IdVenta
    INNER JOIN EstadosVenta evAnterior ON evAnterior.IdEstadoVenta = d.IdEstadoVenta
    INNER JOIN EstadosVenta evNuevo ON evNuevo.IdEstadoVenta = i.IdEstadoVenta
    WHERE i.IdEstadoVenta <> d.IdEstadoVenta
      AND UPPER(evAnterior.Nombre) <> 'CONFIRMADA'
      AND UPPER(evNuevo.Nombre) = 'CONFIRMADA';

    -- Aca guardamos las ventas que antes estaban confirmadas y ahora no.
    INSERT INTO @VentasQueSeDesconfirmaron (IdVenta)
    SELECT i.IdVenta
    FROM inserted i
    INNER JOIN deleted d ON d.IdVenta = i.IdVenta
    INNER JOIN EstadosVenta evAnterior ON evAnterior.IdEstadoVenta = d.IdEstadoVenta
    INNER JOIN EstadosVenta evNuevo ON evNuevo.IdEstadoVenta = i.IdEstadoVenta
    WHERE i.IdEstadoVenta <> d.IdEstadoVenta
      AND UPPER(evAnterior.Nombre) = 'CONFIRMADA'
      AND UPPER(evNuevo.Nombre) <> 'CONFIRMADA';

    -- Si una venta se confirma, el stock baja.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dv.IdProducto,
           SUM(dv.Cantidad) * -1
    FROM DetalleVentas dv
    INNER JOIN @VentasQueSeConfirmaron vc ON vc.IdVenta = dv.IdVenta
    GROUP BY dv.IdProducto;

    -- Si una venta deja de estar confirmada, el stock vuelve.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dv.IdProducto,
           SUM(dv.Cantidad)
    FROM DetalleVentas dv
    INNER JOIN @VentasQueSeDesconfirmaron vd ON vd.IdVenta = dv.IdVenta
    GROUP BY dv.IdProducto;

    -- Antes de actualizar nada, revisamos si algun stock quedaria negativo.
    IF EXISTS (
        SELECT 1
        FROM Productos p
        INNER JOIN (
            SELECT IdProducto,
                   SUM(CantidadAAjustar) AS CantidadAAjustar
            FROM @MovimientosStock
            GROUP BY IdProducto
        ) m ON m.IdProducto = p.IdProducto
        WHERE p.StockActual + m.CantidadAAjustar < 0
    )
    BEGIN
        RAISERROR ('Stock insuficiente', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Si esta todo bien, aplicamos el movimiento final al stock.
    UPDATE p
    SET p.StockActual = p.StockActual + m.CantidadAAjustar
    FROM Productos p
    INNER JOIN (
        SELECT IdProducto,
               SUM(CantidadAAjustar) AS CantidadAAjustar
        FROM @MovimientosStock
        GROUP BY IdProducto
    ) m ON m.IdProducto = p.IdProducto;
END;
GO

------------------------------------------------------------------------------------------------
-- TRG_Compra_ActualizarStockPorEstado: toca el stock si la compra pasa a confirmada o deja de estarlo.

IF OBJECT_ID(N'dbo.TRG_Compra_ActualizarStockPorEstado', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TRG_Compra_ActualizarStockPorEstado;
GO

CREATE TRIGGER dbo.TRG_Compra_ActualizarStockPorEstado
ON Compras
AFTER UPDATE
AS
BEGIN
    DECLARE @ComprasQueSeConfirmaron TABLE (
        IdCompra INT
    );

    DECLARE @ComprasQueSeDesconfirmaron TABLE (
        IdCompra INT
    );

    DECLARE @MovimientosStock TABLE (
        IdProducto INT,
        CantidadAAjustar INT
    );

    -- Aca guardamos las compras que antes no estaban confirmadas y ahora si.
    INSERT INTO @ComprasQueSeConfirmaron (IdCompra)
    SELECT i.IdCompra
    FROM inserted i
    INNER JOIN deleted d ON d.IdCompra = i.IdCompra
    INNER JOIN EstadosCompra ecAnterior ON ecAnterior.IdEstadoCompra = d.IdEstadoCompra
    INNER JOIN EstadosCompra ecNuevo ON ecNuevo.IdEstadoCompra = i.IdEstadoCompra
    WHERE i.IdEstadoCompra <> d.IdEstadoCompra
      AND UPPER(ecAnterior.Nombre) <> 'CONFIRMADA'
      AND UPPER(ecNuevo.Nombre) = 'CONFIRMADA';

    -- Aca guardamos las compras que antes estaban confirmadas y ahora no.
    INSERT INTO @ComprasQueSeDesconfirmaron (IdCompra)
    SELECT i.IdCompra
    FROM inserted i
    INNER JOIN deleted d ON d.IdCompra = i.IdCompra
    INNER JOIN EstadosCompra ecAnterior ON ecAnterior.IdEstadoCompra = d.IdEstadoCompra
    INNER JOIN EstadosCompra ecNuevo ON ecNuevo.IdEstadoCompra = i.IdEstadoCompra
    WHERE i.IdEstadoCompra <> d.IdEstadoCompra
      AND UPPER(ecAnterior.Nombre) = 'CONFIRMADA'
      AND UPPER(ecNuevo.Nombre) <> 'CONFIRMADA';

    -- Si una compra se confirma, el stock sube.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dc.IdProducto,
           SUM(dc.Cantidad)
    FROM DetalleCompras dc
    INNER JOIN @ComprasQueSeConfirmaron cc ON cc.IdCompra = dc.IdCompra
    GROUP BY dc.IdProducto;

    -- Si una compra deja de estar confirmada, el stock vuelve para atras
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dc.IdProducto,
           SUM(dc.Cantidad) * -1
    FROM DetalleCompras dc
    INNER JOIN @ComprasQueSeDesconfirmaron cd ON cd.IdCompra = dc.IdCompra
    GROUP BY dc.IdProducto;

    -- Antes de actualizar nada, revisamos si algun stock quedaria negativo
    IF EXISTS (
        SELECT 1
        FROM Productos p
        INNER JOIN (
            SELECT IdProducto,
                   SUM(CantidadAAjustar) AS CantidadAAjustar
            FROM @MovimientosStock
            GROUP BY IdProducto
        ) m ON m.IdProducto = p.IdProducto
        WHERE p.StockActual + m.CantidadAAjustar < 0
    )
    BEGIN
        RAISERROR ('Stock insuficiente', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Si esta todo bien, aplicamos el movimiento final al stock.
    UPDATE p
    SET p.StockActual = p.StockActual + m.CantidadAAjustar
    FROM Productos p
    INNER JOIN (
        SELECT IdProducto,
               SUM(CantidadAAjustar) AS CantidadAAjustar
        FROM @MovimientosStock
        GROUP BY IdProducto
    ) m ON m.IdProducto = p.IdProducto;
END;
GO
