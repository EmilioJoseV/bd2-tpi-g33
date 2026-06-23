USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #1 - Clasificar los productos por categorías

-- Prueba de clasificacion general de productos por categoria
SELECT p.IdProducto, p.CodigoProducto, p.Nombre, c.Nombre AS Categoria
FROM Productos p
INNER JOIN Categorias c ON p.IdCategoria = c.IdCategoria
ORDER BY c.Nombre, p.Nombre;
GO

-- Prueba de filtro de productos por una categoria puntual
SELECT p.IdProducto, p.CodigoProducto, p.Nombre, c.Nombre AS Categoria
FROM Productos p
INNER JOIN Categorias c ON p.IdCategoria = c.IdCategoria
WHERE c.Nombre = 'Remeras'
ORDER BY p.Nombre;
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #2 - Asociar cada venta con un medio de pago

-- Prueba de la asociacion de ventas con su medio de pago
SELECT v.IdVenta, v.FechaVenta, v.Total, mp.Nombre AS MedioPago
FROM Ventas v
INNER JOIN MediosPago mp ON v.IdMedioPago = mp.IdMedioPago
ORDER BY v.IdVenta;
GO

-- Prueba de la asociacion de ventas con un medio de pago puntual
SELECT v.IdVenta, v.FechaVenta, v.Total, mp.Nombre AS MedioPago
FROM Ventas v
INNER JOIN MediosPago mp ON v.IdMedioPago = mp.IdMedioPago
WHERE mp.Nombre = 'Efectivo'
ORDER BY v.IdVenta;
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #3 - Registrar y administrar proveedores

-- Prueba de registro de proveedor nuevo.
EXEC sp_registrarProveedor
    @RazonSocial = 'Moda Nueva SRL',
    @CUIT = '30-12345678-3',
    @Email = 'contacto@modaNueva.com',
    @Telefono = '1133445566',
    @Direccion = 'Av. Santa Fe 4567, CABA';
GO

-- Prueba de validacion de CUIT repetido.
EXEC sp_registrarProveedor
    @RazonSocial = 'Moda Nuevaz SRL',
    @CUIT = '30-12345678-3',
    @Email = 'ventas@modaNuevaz.com',
    @Telefono = '1133445577',
    @Direccion = 'Av. Santa Fe 4567, CABA';

GO

-- Prueba de actualizacion de proveedor.
EXEC sp_actualizarProveedor
    @IdProveedor = 3,
    @RazonSocial = 'Moda Nueva SRL Actualizada',
    @CUIT = '30-12345678-3',
    @Email = 'proveedores@modaNueva.com',
    @Telefono = '1144556677',
    @Direccion = 'Av. Cabildo 1234, CABA',
    @Activo = 1;
GO

-- Consulta para verificar los datos del proveedor
SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
FROM Proveedores
WHERE CUIT = '30-12345678-3';
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #5 - Registrar y administrar clientes

-- Prueba de registro de cliente nuevo.
EXEC sp_registrarCliente
    @Apellido = 'Doe Gomez',
    @Nombre = 'John Alexander',
    @Documento = '12345678',
    @Email = 'johndoegomez@email.com',
    @Telefono = '1155667788';
GO

-- Prueba de validacion de documento repetido.
EXEC sp_registrarCliente
    @Apellido = 'Polo',
    @Nombre = 'Marco',
    @Documento = '12345678',
    @Email = 'marcopolo@email.com',
    @Telefono = '1166778899';
GO

-- Prueba de actualizacion de cliente.
EXEC sp_actualizarCliente
    @IdCliente = 3,
    @Apellido = 'Doe',
    @Nombre = 'John',
    @Documento = '12345678',
    @Email = 'johndoe@email.com',
    @Telefono = '1177889900',
    @Activo = 1;
GO

-- Consulta para verificar los datos del cliente
SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
FROM Clientes
WHERE Documento = '12345678';
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #7 - Registrar compras de mercadería realizadas a proveedores

-- Prueba de registro de compra nueva.
EXEC sp_registrarCompra
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @NumeroComprobante = NULL,
    @Total = 185000.00;
GO

-- Prueba de registro de otra compra nueva.
EXEC sp_registrarCompra
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @NumeroComprobante = 'COMP-0005',
    @Total = 99000.00;
GO

-- Prueba de actualizacion de compra para completar numero, cambiar estado y total.
EXEC sp_actualizarCompra
    @IdCompra = 4,
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 2,
    @NumeroComprobante = 'COMP-0004',
    @Total = 210500.00;
GO

-- Prueba de validacion para no confirmar una compra sin detalle.
EXEC sp_actualizarCompra
    @IdCompra = (
        SELECT TOP 1 IdCompra
        FROM Compras
        WHERE NumeroComprobante IS NULL
        ORDER BY IdCompra DESC
    ),
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 1,
    @NumeroComprobante = NULL,
    @Total = 185000.00;
GO

-- Consulta para verificar los datos de la compra
SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total
FROM Compras
WHERE NumeroComprobante = 'COMP-0004'
ORDER BY IdCompra;
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #9 - Detallar los productos incluidos en cada compra y cada venta, indicando cantidad, precio unitario y subtotal

-- Dejar una venta en pendiente para poder tocar sus detalles.
UPDATE Ventas
SET IdEstadoVenta = 2
WHERE IdVenta = 4;
GO

-- Prueba de alta de detalle de compra.
EXEC sp_registrarDetalleCompra
    @IdCompra = (
        SELECT TOP 1 IdCompra
        FROM Compras
        WHERE NumeroComprobante = 'COMP-0005'
        ORDER BY IdCompra DESC
    ),
    @IdProducto = 1,
    @Cantidad = 2,
    @PrecioUnitario = 7000.00;
GO

-- Prueba de alta de detalle de compra repitiendo el articulo.
EXEC sp_registrarDetalleCompra
    @IdCompra = (
        SELECT TOP 1 IdCompra
        FROM Compras
        WHERE NumeroComprobante = 'COMP-0005'
        ORDER BY IdCompra DESC
    ),
    @IdProducto = 1,
    @Cantidad = 1,
    @PrecioUnitario = 7100.00;
GO

-- Prueba de actualizacion de detalle de compra.
EXEC sp_actualizarDetalleCompra
    @IdDetalleCompra = (
        SELECT TOP 1 IdDetalleCompra
        FROM DetalleCompras
        WHERE IdCompra = (
            SELECT TOP 1 IdCompra
            FROM Compras
            WHERE NumeroComprobante = 'COMP-0005'
            ORDER BY IdCompra DESC
        )
          AND IdProducto = 1
        ORDER BY IdDetalleCompra DESC
    ),
    @IdProducto = 1,
    @Cantidad = 3,
    @PrecioUnitario = 7200.00;
GO

-- Prueba de baja de detalle de compra.
EXEC sp_eliminarDetalleCompra
    @IdDetalleCompra = (
        SELECT TOP 1 IdDetalleCompra
        FROM DetalleCompras
        WHERE IdCompra = (
            SELECT TOP 1 IdCompra
            FROM Compras
            WHERE NumeroComprobante = 'COMP-0005'
            ORDER BY IdCompra DESC
        )
          AND IdProducto = 1
        ORDER BY IdDetalleCompra DESC
    );
GO

-- Consulta para verificar los detalles de la compra.
SELECT IdDetalleCompra, IdCompra, IdProducto, Cantidad, PrecioUnitario, Subtotal
FROM DetalleCompras
WHERE IdCompra = (
    SELECT TOP 1 IdCompra
    FROM Compras
    WHERE NumeroComprobante = 'COMP-0005'
    ORDER BY IdCompra DESC
)
ORDER BY IdDetalleCompra;
GO

-- Prueba de alta de detalle de venta.
EXEC sp_registrarDetalleVenta
    @IdVenta = 4,
    @IdProducto = 1,
    @Cantidad = 1;
GO

-- Prueba de alta de detalle de venta repitiendo el articulo.
EXEC sp_registrarDetalleVenta
    @IdVenta = 4,
    @IdProducto = 1,
    @Cantidad = 2;
GO

-- Prueba de actualizacion de detalle de venta.
EXEC sp_actualizarDetalleVenta
    @IdDetalleVenta = (
        SELECT TOP 1 IdDetalleVenta
        FROM DetalleVentas
        WHERE IdVenta = 4
          AND IdProducto = 1
        ORDER BY IdDetalleVenta DESC
    ),
    @IdProducto = 1,
    @Cantidad = 3;
GO

-- Prueba de baja de detalle de venta.
EXEC sp_eliminarDetalleVenta
    @IdDetalleVenta = (
        SELECT TOP 1 IdDetalleVenta
        FROM DetalleVentas
        WHERE IdVenta = 4
          AND IdProducto = 1
        ORDER BY IdDetalleVenta DESC
    );
GO

-- Consulta para verificar los detalles de la venta.
SELECT IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal
FROM DetalleVentas
WHERE IdVenta = 4
ORDER BY IdDetalleVenta;
GO

-- Consulta para verificar el total recalculado de la venta.
SELECT IdVenta, Total
FROM Ventas
WHERE IdVenta = 4;
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #13 - Disminuir automáticamente el stock cuando se registra una venta a un cliente

-- Ver stock antes de confirmar una compra pendiente.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Confirmar la compra para sumar stock.
UPDATE Compras
SET IdEstadoCompra = 1
WHERE IdCompra = (
    SELECT TOP 1 IdCompra
    FROM Compras
    WHERE NumeroComprobante = 'COMP-0005'
    ORDER BY IdCompra DESC
);
GO

-- Ver stock luego de confirmar la compra.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Intentar tocar detalle de una compra confirmada.
EXEC sp_registrarDetalleCompra
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

-- Ver stock despues del intento sobre compra confirmada.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 1;
GO

-- Ver stock antes de cambiar el estado de la venta.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto IN (1, 2, 4)
ORDER BY IdProducto;
GO

-- Confirmar la venta para descontar stock.
UPDATE Ventas
SET IdEstadoVenta = 1
WHERE IdVenta = 4;
GO

-- Ver stock luego de confirmar la venta.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto IN (1, 2, 4)
ORDER BY IdProducto;
GO

-- Intentar tocar detalle de una venta confirmada.
EXEC sp_registrarDetalleVenta
    @IdVenta = 4,
    @IdProducto = 2,
    @Cantidad = 1;
GO

-- Pasar la venta a pendiente para poder agregar mas detalle.
UPDATE Ventas
SET IdEstadoVenta = 2
WHERE IdVenta = 4;
GO

-- Agregar un detalle grande para provocar falta de stock al confirmar.
EXEC sp_registrarDetalleVenta
    @IdVenta = 4,
    @IdProducto = 4,
    @Cantidad = 10;
GO

-- Intentar confirmar una venta sin stock suficiente.
UPDATE Ventas
SET IdEstadoVenta = 1
WHERE IdVenta = 4;
GO

-- Verificar que el stock no haya quedado en negativo.
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 4;
------------------------------------------------------------------------------------------------
GO
------------------------------------------------------------------------------------------------
-- #14 - Consultar el historial de movimientos de stock de cada producto

-- Ver el historial completo de movimientos del producto 1.
SELECT *
FROM vw_historialMovimientosStock
WHERE IdProducto = 1
ORDER BY FechaMovimiento, TipoMovimiento;
GO

------------------------------------------------------------------------------------------------
-- #15 - Detectar productos cuyo stock se encuentra por debajo del minimo definido

-- Ver los productos que ya estan por debajo del minimo.
SELECT *
FROM vw_productosStockBajoMinimo
ORDER BY IdProducto;
GO

------------------------------------------------------------------------------------------------
-- #16 - Consultar ventas realizadas por fecha, cliente, empleado o medio de pago

-- Prueba de ventas por rango de fechas.
EXEC sp_consultarVentas
    @FechaDesde = '2026-01-01',
    @FechaHasta = '2026-02-28';
GO

-- Prueba de ventas de un cliente con un medio de pago puntual.
EXEC sp_consultarVentas
    @IdCliente = 1,
    @IdMedioPago = 1;
GO

------------------------------------------------------------------------------------------------
-- #17 - Consultar compras realizadas por proveedor o período

-- Prueba de compras por rango de fechas.
EXEC sp_consultarCompras
    @FechaDesde = '2026-01-01',
    @FechaHasta = '2026-02-28';
GO

-- Prueba de compras de un proveedor puntual.
EXEC sp_consultarCompras
    @IdProveedor = 1;
GO

------------------------------------------------------------------------------------------------
-- #18 - Obtener reportes de productos mas vendidos

-- Ver el ranking de productos mas vendidos.
SELECT *
FROM vw_productosMasVendidos
ORDER BY CantidadVendida DESC, TotalFacturado DESC, NombreProducto;
GO
