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
    @IdEstadoCompra = 1,
    @NumeroComprobante = NULL,
    @Total = 185000.00;
GO

-- Prueba de validacion de estado de compra no permitido para registrar.
EXEC sp_registrarCompra
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 3,
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

-- Consulta para verificar los datos de la compra
SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total
FROM Compras
WHERE NumeroComprobante = 'COMP-0004'
ORDER BY IdCompra;
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #9 - Detallar los productos incluidos en cada compra y cada venta, indicando cantidad, precio unitario y subtotal

-- Prueba de alta de detalle de compra.
EXEC sp_registrarDetalleCompra
    @IdCompra = 1,
    @IdProducto = 1,
    @Cantidad = 2,
    @PrecioUnitario = 7000.00;
GO

-- Prueba de alta de detalle de compra repitiendo el articulo.
EXEC sp_registrarDetalleCompra
    @IdCompra = 1,
    @IdProducto = 1,
    @Cantidad = 1,
    @PrecioUnitario = 7100.00;
GO

-- Prueba de actualizacion de detalle de compra.
EXEC sp_actualizarDetalleCompra
    @IdDetalleCompra = 6,
    @IdCompra = 1,
    @IdProducto = 1,
    @Cantidad = 3,
    @PrecioUnitario = 7200.00;
GO

-- Prueba de baja de detalle de compra.
EXEC sp_eliminarDetalleCompra
    @IdDetalleCompra = 7;
GO

-- Consulta para verificar los detalles de la compra.
SELECT IdDetalleCompra, IdCompra, IdProducto, Cantidad, PrecioUnitario, Subtotal
FROM DetalleCompras
WHERE IdCompra = 1
ORDER BY IdDetalleCompra;
GO

-- Prueba de alta de detalle de venta.
EXEC sp_registrarDetalleVenta
    @IdVenta = 1,
    @IdProducto = 1,
    @Cantidad = 1;
GO

-- Prueba de alta de detalle de venta repitiendo el articulo.
EXEC sp_registrarDetalleVenta
    @IdVenta = 1,
    @IdProducto = 1,
    @Cantidad = 2;
GO

-- Prueba de actualizacion de detalle de venta.
EXEC sp_actualizarDetalleVenta
    @IdDetalleVenta = 8,
    @IdVenta = 1,
    @IdProducto = 1,
    @Cantidad = 3;
GO

-- Prueba de baja de detalle de venta.
EXEC sp_eliminarDetalleVenta
    @IdDetalleVenta = 9;
GO

-- Consulta para verificar los detalles de la venta.
SELECT IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal
FROM DetalleVentas
WHERE IdVenta = 1
ORDER BY IdDetalleVenta;
GO

-- Consulta para verificar el total recalculado de la venta.
SELECT IdVenta, Total
FROM Ventas
WHERE IdVenta = 1;
------------------------------------------------------------------------------------------------
GO
