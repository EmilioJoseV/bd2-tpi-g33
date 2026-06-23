USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #15 - Detectar productos cuyo stock se encuentra por debajo del minimo definido
-- vw_productosStockBajoMinimo: muestra los productos que ya estan por debajo del minimo

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
