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
-- #3 - Registrar proveedores y mantener sus datos de contacto

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
-- Prueba de actualizacion de datos de contacto.
EXEC sp_actualizarContactoProveedor
    @IdProveedor = 3,
    @Email = 'proveedores@modaNuevax.com',
    @Telefono = '1144556677',
    @Direccion = 'Av. Cabildo 1234, CABA';
GO

-- Consulta para verificar los datos del proveedor
SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
FROM Proveedores
WHERE CUIT = '30-12345678-3';
------------------------------------------------------------------------------------------------
GO

------------------------------------------------------------------------------------------------
-- #5 - Registrar clientes para asociarlos a las ventas realizadas

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
    @NumeroComprobante = NULL;
GO

-- Prueba de validacion de estado de compra no permitido para registrar.
EXEC sp_registrarCompra
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 3,
    @NumeroComprobante = 'COMP-0005';
GO

-- Prueba de actualizacion de compra para completar numero de comprobante y cambiar estado.
EXEC sp_actualizarCompra
    @IdCompra = 4,
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 2,
    @NumeroComprobante = 'COMP-0004';
GO

-- Consulta para verificar los datos de la compra
SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total
FROM Compras
WHERE NumeroComprobante = 'COMP-0004'
ORDER BY IdCompra;
------------------------------------------------------------------------------------------------
GO
