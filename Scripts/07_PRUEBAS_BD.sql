USE BD2_TPI_TIENDA_INDUMENTARIA;
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
