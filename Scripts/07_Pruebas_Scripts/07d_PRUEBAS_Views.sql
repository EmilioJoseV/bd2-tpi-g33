------------------------------------------------------------------------------------------------
-- #14 - Consultar el historial de movimientos de stock de cada producto

-- Probar: dbo.VW_Producto_ConsultarHistorialStock
-- Caso: consultar historial de un producto
SELECT *
FROM dbo.VW_Producto_ConsultarHistorialStock
WHERE IdProducto = 1
ORDER BY FechaMovimiento, TipoMovimiento;
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.VW_Producto_ConsultarStockBajoMinimo
-- Caso: consultar productos bajo minimo
SELECT *
FROM dbo.VW_Producto_ConsultarStockBajoMinimo
ORDER BY IdProducto;
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.VW_Producto_ConsultarMasVendido
-- Caso: consultar mas vendidos
SELECT *
FROM dbo.VW_Producto_ConsultarMasVendido
ORDER BY CantidadVendida DESC, TotalFacturado DESC, NombreProducto;
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.VW_Venta_ConsultarMensual
-- Caso: consultar ventas mensuales
SELECT *
FROM dbo.VW_Venta_ConsultarMensual
ORDER BY Anio, Mes;
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.VW_Producto_ConsultarStockActual
-- Caso: consultar stock actual
SELECT *
FROM dbo.VW_Producto_ConsultarStockActual
ORDER BY StockActual, Nombre;
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.VW_Inventario_ConsultarValorTotal
-- Caso: consultar valor total del inventario
SELECT *
FROM dbo.VW_Inventario_ConsultarValorTotal;
GO
