USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #14 - Consultar el historial de movimientos de stock de cada producto
-- vw_historialMovimientosStock: Mostrar los movimientos de stock del producto.

IF OBJECT_ID(N'dbo.vw_historialMovimientosStock', N'V') IS NOT NULL
    DROP VIEW dbo.vw_historialMovimientosStock;
GO

CREATE VIEW vw_historialMovimientosStock
AS
SELECT
    p.IdProducto,
    p.CodigoProducto,
    p.Nombre AS NombreProducto,
    tms.Nombre AS TipoMovimiento,
    e.Apellido + ', ' + e.Nombre AS Empleado,
    CASE
        WHEN ms.IdCompra IS NOT NULL THEN 'Compra'
        WHEN ms.IdVenta IS NOT NULL THEN 'Venta'
        ELSE 'Ajuste'
    END AS OrigenMovimiento,
    c.NumeroComprobante AS NumeroComprobanteCompra,
    ms.FechaMovimiento,
    ms.Cantidad,
    ms.Motivo
FROM MovimientosStock ms
INNER JOIN Productos p ON p.IdProducto = ms.IdProducto
INNER JOIN TiposMovimientoStock tms ON tms.IdTipoMovimientoStock = ms.IdTipoMovimientoStock
LEFT JOIN Empleados e ON e.IdEmpleado = ms.IdEmpleado
LEFT JOIN Compras c ON c.IdCompra = ms.IdCompra;
GO

------------------------------------------------------------------------------------------------
-- #15 - Detectar productos cuyo stock se encuentra por debajo del minimo definido
-- vw_productosStockBajoMinimo: muestra los productos que ya estan por debajo del minimo

IF OBJECT_ID(N'dbo.vw_productosStockBajoMinimo', N'V') IS NOT NULL
    DROP VIEW dbo.vw_productosStockBajoMinimo;
GO

CREATE VIEW vw_productosStockBajoMinimo
AS
SELECT
    p.IdProducto,
    p.CodigoProducto,
    p.Nombre,
    p.StockActual,
    p.StockMinimo,
    p.StockMinimo - p.StockActual AS CantidadPorDebajoDelMinimo
FROM Productos p
WHERE p.Activo = 1 --Siempre fijarnos en los productos activos
  AND p.StockActual < p.StockMinimo;
GO

------------------------------------------------------------------------------------------------
-- #18 - Obtener reportes de productos mas vendidos
-- vw_productosMasVendidos: muestra cuales productos tuvieron mas salida.

IF OBJECT_ID(N'dbo.vw_productosMasVendidos', N'V') IS NOT NULL
    DROP VIEW dbo.vw_productosMasVendidos;
GO

CREATE VIEW vw_productosMasVendidos
AS
SELECT
    p.IdProducto,
    p.CodigoProducto,
    p.Nombre AS NombreProducto,
    SUM(dv.Cantidad) AS CantidadVendida,
    SUM(dv.Subtotal) AS TotalFacturado
FROM DetalleVentas dv
INNER JOIN Productos p ON p.IdProducto = dv.IdProducto
GROUP BY
    p.IdProducto,
    p.CodigoProducto,
    p.Nombre;
GO

------------------------------------------------------------------------------------------------
-- #19 - Obtener reportes de ventas mensuales
-- vw_ventasMensuales: resume cuantas ventas hubo por  año-mes y cuanto se facturo.

IF OBJECT_ID(N'dbo.vw_ventasMensuales', N'V') IS NOT NULL
    DROP VIEW dbo.vw_ventasMensuales;
GO

CREATE VIEW vw_ventasMensuales
AS
SELECT
    YEAR(v.FechaVenta) AS Anio,
    MONTH(v.FechaVenta) AS Mes,
    COUNT(*) AS CantidadVentas,
    SUM(v.Total) AS TotalFacturado
FROM Ventas v
GROUP BY
    YEAR(v.FechaVenta),
    MONTH(v.FechaVenta);
GO

------------------------------------------------------------------------------------------------
-- #20 - Controlar el stock actual de cada producto
-- vw_stockActualProductos: muestra el stock actual de todos los productos y si ya esta por debajo del minimo

IF OBJECT_ID(N'dbo.vw_stockActualProductos', N'V') IS NOT NULL
    DROP VIEW dbo.vw_stockActualProductos;
GO

CREATE VIEW vw_stockActualProductos
AS
SELECT
    p.IdProducto,
    p.CodigoProducto,
    p.Nombre,
    p.StockActual,
    p.StockMinimo,
    p.StockActual - p.StockMinimo AS DiferenciaConMinimo,
    CASE
        WHEN p.StockActual < p.StockMinimo THEN 'Stock bajo'
        ELSE 'OK'
    END AS EstadoStock
FROM Productos p
WHERE p.Activo = 1;
GO

------------------------------------------------------------------------------------------------
-- #21 - Calcular el valor total del inventario disponible
-- vw_valorTotalInventarioDisponible: suma el valor de todo el stock activo.

IF OBJECT_ID(N'dbo.vw_valorTotalInventarioDisponible', N'V') IS NOT NULL
    DROP VIEW dbo.vw_valorTotalInventarioDisponible;
GO

CREATE VIEW vw_valorTotalInventarioDisponible
AS
SELECT
    SUM(p.StockActual * p.PrecioVenta) AS ValorTotalInventarioDisponible
FROM Productos p
GO
