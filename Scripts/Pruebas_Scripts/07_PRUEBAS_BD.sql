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
