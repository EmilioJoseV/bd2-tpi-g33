USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- VW_Producto_ConsultarHistorialStock: Mostrar los movimientos de stock del producto.

IF OBJECT_ID(N'dbo.VW_Producto_ConsultarHistorialStock', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Producto_ConsultarHistorialStock;
GO

CREATE VIEW dbo.VW_Producto_ConsultarHistorialStock
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
-- VW_Producto_ConsultarStockBajoMinimo: muestra los productos que ya estan por debajo del minimo

IF OBJECT_ID(N'dbo.VW_Producto_ConsultarStockBajoMinimo', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Producto_ConsultarStockBajoMinimo;
GO

CREATE VIEW dbo.VW_Producto_ConsultarStockBajoMinimo
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
-- VW_Producto_ConsultarMasVendido: muestra cuales productos tuvieron mas salida.

IF OBJECT_ID(N'dbo.VW_Producto_ConsultarMasVendido', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Producto_ConsultarMasVendido;
GO

CREATE VIEW dbo.VW_Producto_ConsultarMasVendido
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
-- VW_Venta_ConsultarMensual: resume cuantas ventas hubo por año-mes y cuanto se facturo.

IF OBJECT_ID(N'dbo.VW_Venta_ConsultarMensual', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Venta_ConsultarMensual;
GO

CREATE VIEW dbo.VW_Venta_ConsultarMensual
AS
SELECT
    YEAR(v.FechaVenta) AS Anio,
    MONTH(v.FechaVenta) AS Mes,
    COUNT(*) AS CantidadVentas,
    SUM(v.Total) AS TotalFacturado
FROM Ventas v
WHERE v.IdEstadoVenta IN (
    SELECT IdEstadoVenta
    FROM EstadosVenta
    WHERE UPPER(Nombre) = 'CONFIRMADA'
)
GROUP BY
    YEAR(v.FechaVenta),
    MONTH(v.FechaVenta);
GO

------------------------------------------------------------------------------------------------
-- VW_Producto_ConsultarStockActual: muestra el stock actual de todos los productos y si ya esta por debajo del minimo
IF OBJECT_ID(N'dbo.VW_Producto_ConsultarStockActual', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Producto_ConsultarStockActual;
GO

CREATE VIEW dbo.VW_Producto_ConsultarStockActual
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

-- VW_Inventario_ConsultarValorTotal: suma el valor de todo el stock activo.
IF OBJECT_ID(N'dbo.VW_Inventario_ConsultarValorTotal', N'V') IS NOT NULL
    DROP VIEW dbo.VW_Inventario_ConsultarValorTotal;
GO

CREATE VIEW dbo.VW_Inventario_ConsultarValorTotal
AS
SELECT
    SUM(p.StockActual * p.PrecioVenta) AS ValorTotalInventarioDisponible
FROM Productos p
GO
