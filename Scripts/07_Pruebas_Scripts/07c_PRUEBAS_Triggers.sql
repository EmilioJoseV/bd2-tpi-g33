-- Probar que se ve el stock inicial
-- Caso: ver stock antes de confirmar compra
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Probar: TRG_Compra_ActualizarStockPorEstado y TRG_Compra_RegistrarMovimientoStock
-- Caso: confirmar compra pendiente
UPDATE Compras
SET IdEstadoCompra = 1
WHERE IdCompra = (
    SELECT TOP 1 IdCompra
    FROM Compras
    WHERE NumeroComprobante = 'COMP-0005'
    ORDER BY IdCompra DESC
);
GO

-- Probar que el stock sube al confirmar compra
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Probar que se genera el movimiento por compra
SELECT TOP 5 IdMovimientoStock, IdCompra, IdProducto, Cantidad, Motivo
FROM MovimientosStock
WHERE IdCompra = (
    SELECT TOP 1 IdCompra
    FROM Compras
    WHERE NumeroComprobante = 'COMP-0005'
    ORDER BY IdCompra DESC
)
ORDER BY IdMovimientoStock DESC;
GO

-- Probar: dbo.SP_DetalleCompra_Registrar
-- Caso: agregar detalle en compra confirmada
EXEC dbo.SP_DetalleCompra_Registrar
    @IdCompra = (
        SELECT TOP 1 IdCompra
        FROM Compras
        WHERE NumeroComprobante = 'COMP-0005'
        ORDER BY IdCompra DESC
    ),
    @IdProducto = 2,
    @Cantidad = 1,
    @PrecioUnitario = 9000.00;
GO

-- Probar que el stock no cambia
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Probar que se ve el stock inicial
-- Caso: ver stock antes de confirmar venta
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto IN (1, 2, 4)
ORDER BY IdProducto;
GO

-- Probar: TRG_Venta_ActualizarStockPorEstado y TRG_Venta_RegistrarMovimientoStock
-- Caso: confirmar venta pendiente
UPDATE Ventas
SET IdEstadoVenta = 1
WHERE IdVenta = 4;
GO

-- Probar que el stock baja al confirmar venta
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto IN (1, 2, 4)
ORDER BY IdProducto;
GO

-- Probar que se genera el movimiento por venta
SELECT TOP 10 IdMovimientoStock, IdVenta, IdProducto, Cantidad, Motivo
FROM MovimientosStock
WHERE IdVenta = 4
ORDER BY IdMovimientoStock DESC;
GO

-- Probar: dbo.SP_DetalleVenta_Registrar
-- Caso: agregar detalle en venta confirmada
EXEC dbo.SP_DetalleVenta_Registrar
    @IdVenta = 4,
    @IdProducto = 2,
    @Cantidad = 1;
GO

-- Preparar venta
-- Caso: volver venta 4 a pendiente
UPDATE Ventas
SET IdEstadoVenta = 2
WHERE IdVenta = 4;
GO

-- Probar: dbo.SP_DetalleVenta_Registrar
-- Caso: agregar detalle para probar falta de stock
EXEC dbo.SP_DetalleVenta_Registrar
    @IdVenta = 4,
    @IdProducto = 4,
    @Cantidad = 10;
GO

-- Probar: TRG_Venta_ActualizarStockPorEstado
-- Caso: confirmar venta sin stock suficiente
UPDATE Ventas
SET IdEstadoVenta = 1
WHERE IdVenta = 4;
GO

-- Probar que el stock no queda negativo
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 4;
GO
