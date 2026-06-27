------------------------------------------------------------------------------------------------
-- Probar: dbo.SP_Proveedor_Registrar
-- Caso: registrar proveedor
EXEC dbo.SP_Proveedor_Registrar
    @RazonSocial = 'Moda Nueva SRL',
    @CUIT = '30-12345678-3',
    @Email = 'contacto@modaNueva.com',
    @Telefono = '1133445566',
    @Direccion = 'Av. Santa Fe 4567, CABA';
GO

-- Probar: dbo.SP_Proveedor_Registrar
-- Caso: registrar proveedor con CUIT repetido
EXEC dbo.SP_Proveedor_Registrar
    @RazonSocial = 'Moda Nuevaz SRL',
    @CUIT = '30-12345678-3',
    @Email = 'ventas@modaNuevaz.com',
    @Telefono = '1133445577',
    @Direccion = 'Av. Santa Fe 4567, CABA';
GO

-- Probar: dbo.SP_Proveedor_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Proveedor_Actualizar
    @IdProveedor = 3,
    @RazonSocial = 'Moda Nueva SRL Actualizada',
    @CUIT = '30-12345678-3',
    @Email = 'general@modanueva.com',
    @Telefono = '1144556699',
    @Direccion = 'Av. Cabildo 2222, CABA',
    @Activo = 1;
GO

-- Probar: dbo.SP_Proveedor_Desactivar y dbo.SP_Proveedor_Reactivar
-- Caso: desactivar y reactivar proveedor
EXEC dbo.SP_Proveedor_Desactivar
    @IdProveedor = 3;
GO

EXEC dbo.SP_Proveedor_Reactivar
    @IdProveedor = 3;
GO

-- Probar que el proveedor queda bien
SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
FROM Proveedores
WHERE CUIT = '30-12345678-3';
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.SP_Empleado_Registrar
-- Caso: registrar empleado
EXEC dbo.SP_Empleado_Registrar
    @Apellido = 'Lopez',
    @Nombre = 'Ana',
    @Documento = '30999111',
    @Email = 'ana.lopez@tienda.com',
    @Telefono = '1133004400';
GO

-- Probar: dbo.SP_Empleado_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Empleado_Actualizar
    @IdEmpleado = 3,
    @Apellido = 'Lopez',
    @Nombre = 'Ana Maria',
    @Documento = '30999111',
    @Email = 'ana.maria@tienda.com',
    @Telefono = '1133004411',
    @Activo = 1;
GO

-- Probar: dbo.SP_Empleado_Desactivar
-- Caso: desactivar empleado
EXEC dbo.SP_Empleado_Desactivar
    @IdEmpleado = 3;
GO

-- Probar: dbo.SP_Empleado_Reactivar
-- Caso: reactivar empleado
EXEC dbo.SP_Empleado_Reactivar
    @IdEmpleado = 3;
GO

-- Probar que el empleado queda bien
SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, Activo
FROM Empleados
WHERE Documento = '30999111';
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.SP_Cliente_Registrar
-- Caso: registrar cliente
EXEC dbo.SP_Cliente_Registrar
    @Apellido = 'Doe Gomez',
    @Nombre = 'John Alexander',
    @Documento = '12345678',
    @Email = 'johndoegomez@email.com',
    @Telefono = '1155667788';
GO

-- Probar: dbo.SP_Cliente_Registrar
-- Caso: registrar cliente con documento repetido
EXEC dbo.SP_Cliente_Registrar
    @Apellido = 'Polo',
    @Nombre = 'Marco',
    @Documento = '12345678',
    @Email = 'marcopolo@email.com',
    @Telefono = '1166778899';
GO

-- Probar: dbo.SP_Cliente_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Cliente_Actualizar
    @IdCliente = 3,
    @Apellido = 'Doe',
    @Nombre = 'John',
    @Documento = '12345678',
    @Email = 'johndoe@email.com',
    @Telefono = '1177889900',
    @Activo = 1;
GO

-- Probar que el cliente queda bien
SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
FROM Clientes
WHERE Documento = '12345678';
GO

------------------------------------------------------------------------------------------------
-- Probar: dbo.SP_Categoria_Registrar
-- Caso: registrar categoria
EXEC dbo.SP_Categoria_Registrar
    @Nombre = 'Accesorios',
    @Descripcion = 'Complementos y accesorios';
GO

-- Probar: dbo.SP_Categoria_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Categoria_Actualizar
    @IdCategoria = 7,
    @Nombre = 'Accesorios premium',
    @Descripcion = 'Complementos premium',
    @Activo = 1;
GO

-- Probar: dbo.SP_Categoria_Desactivar
-- Caso: desactivar categoria
EXEC dbo.SP_Categoria_Desactivar
    @IdCategoria = 7;
GO

-- Probar: dbo.SP_Categoria_Reactivar
-- Caso: reactivar categoria
EXEC dbo.SP_Categoria_Reactivar
    @IdCategoria = 7;
GO

-- Probar: dbo.SP_Talle_Registrar
-- Caso: registrar talle
EXEC dbo.SP_Talle_Registrar
    @Nombre = 'XS',
    @Descripcion = 'Talle extra chico';
GO

-- Probar: dbo.SP_Talle_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Talle_Actualizar
    @IdTalle = 6,
    @Nombre = 'XS',
    @Descripcion = 'Talle extra chico actualizado',
    @Activo = 1;
GO

-- Probar: dbo.SP_Talle_Desactivar
-- Caso: desactivar talle
EXEC dbo.SP_Talle_Desactivar
    @IdTalle = 6;
GO

-- Probar: dbo.SP_Talle_Reactivar
-- Caso: reactivar talle
EXEC dbo.SP_Talle_Reactivar
    @IdTalle = 6;
GO

-- Probar: dbo.SP_Marca_Registrar
-- Caso: registrar marca
EXEC dbo.SP_Marca_Registrar
    @Nombre = 'Puma',
    @Descripcion = 'Marca deportiva';
GO

-- Probar: dbo.SP_Marca_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Marca_Actualizar
    @IdMarca = 6,
    @Nombre = 'Puma',
    @Descripcion = 'Marca deportiva actualizada',
    @Activo = 1;
GO

-- Probar: dbo.SP_Marca_Desactivar
-- Caso: desactivar marca
EXEC dbo.SP_Marca_Desactivar
    @IdMarca = 6;
GO

-- Probar: dbo.SP_Marca_Reactivar
-- Caso: reactivar marca
EXEC dbo.SP_Marca_Reactivar
    @IdMarca = 6;
GO

-- Probar: dbo.SP_Color_Registrar
-- Caso: registrar color
EXEC dbo.SP_Color_Registrar
    @Nombre = 'Rojo';
GO

-- Probar: dbo.SP_Color_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Color_Actualizar
    @IdColor = 7,
    @Nombre = 'Rojo intenso',
    @Activo = 1;
GO

-- Probar: dbo.SP_Color_Desactivar
-- Caso: desactivar color
EXEC dbo.SP_Color_Desactivar
    @IdColor = 7;
GO

-- Probar: dbo.SP_Color_Reactivar
-- Caso: reactivar color
EXEC dbo.SP_Color_Reactivar
    @IdColor = 7;
GO

-- Probar que los datos quedan bien
SELECT IdCategoria, Nombre, Activo FROM Categorias WHERE IdCategoria = 7;
SELECT IdTalle, Nombre, Activo FROM Talles WHERE IdTalle = 6;
SELECT IdMarca, Nombre, Activo FROM Marcas WHERE IdMarca = 6;
SELECT IdColor, Nombre, Activo FROM Colores WHERE IdColor = 7;
GO


-- Probar: dbo.SP_Compra_Registrar
-- Caso: registrar compra sin comprobante
EXEC dbo.SP_Compra_Registrar
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @NumeroComprobante = NULL,
    @Total = 185000.00;
GO

-- Probar: dbo.SP_Compra_Registrar
-- Caso: registrar compra con comprobante
EXEC dbo.SP_Compra_Registrar
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @NumeroComprobante = 'COMP-0005',
    @Total = 99000.00;
GO

-- Probar: dbo.SP_Compra_Actualizar
-- Caso: modificar los datos
EXEC dbo.SP_Compra_Actualizar
    @IdCompra = 4,
    @IdProveedor = 1,
    @IdEmpleado = 1,
    @IdEstadoCompra = 2,
    @NumeroComprobante = 'COMP-0004',
    @Total = 210500.00;
GO

-- Probar: dbo.SP_Compra_Actualizar
-- Caso: confirmar compra sin detalle
EXEC dbo.SP_Compra_Actualizar
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

-- Probar que la compra queda bien
SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total
FROM Compras
WHERE NumeroComprobante = 'COMP-0004'
ORDER BY IdCompra;
GO

-- Probar: dbo.SP_Compra_Consultar
-- Caso: consultar por fechas
EXEC dbo.SP_Compra_Consultar
    @FechaDesde = '2026-01-01',
    @FechaHasta = '2026-02-28';
GO

-- Probar: dbo.SP_Compra_Consultar
-- Caso: consultar por proveedor
EXEC dbo.SP_Compra_Consultar
    @IdProveedor = 1;
GO

-- Probar: dbo.SP_DetalleCompra_Registrar
-- Caso: registrar detalle de compra
EXEC dbo.SP_DetalleCompra_Registrar
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

-- Probar: dbo.SP_DetalleCompra_Registrar
-- Caso: registrar producto repetido
EXEC dbo.SP_DetalleCompra_Registrar
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

-- Probar: dbo.SP_DetalleCompra_Actualizar
-- Caso: modificar el detalle
EXEC dbo.SP_DetalleCompra_Actualizar
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

-- Probar: dbo.SP_DetalleCompra_Eliminar
-- Caso: eliminar detalle
EXEC dbo.SP_DetalleCompra_Eliminar
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

-- Probar que el detalle de compra queda bien
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

-- Preparar venta
-- Caso: dejar venta 4 pendiente
UPDATE Ventas
SET IdEstadoVenta = 2
WHERE IdVenta = 4;
GO

-- Probar: dbo.SP_DetalleVenta_Registrar
-- Caso: registrar detalle de venta
EXEC dbo.SP_DetalleVenta_Registrar
    @IdVenta = 4,
    @IdProducto = 1,
    @Cantidad = 1;
GO

-- Probar: dbo.SP_DetalleVenta_Registrar
-- Caso: registrar producto repetido
EXEC dbo.SP_DetalleVenta_Registrar
    @IdVenta = 4,
    @IdProducto = 1,
    @Cantidad = 2;
GO

-- Probar: dbo.SP_DetalleVenta_Actualizar
-- Caso: modificar el detalle
EXEC dbo.SP_DetalleVenta_Actualizar
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

-- Probar: dbo.SP_DetalleVenta_Eliminar
-- Caso: eliminar detalle
EXEC dbo.SP_DetalleVenta_Eliminar
    @IdDetalleVenta = (
        SELECT TOP 1 IdDetalleVenta
        FROM DetalleVentas
        WHERE IdVenta = 4
          AND IdProducto = 1
        ORDER BY IdDetalleVenta DESC
    );
GO

-- Probar que el detalle de venta queda bien
SELECT IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal
FROM DetalleVentas
WHERE IdVenta = 4
ORDER BY IdDetalleVenta;
GO

-- Probar que el total de venta queda bien
SELECT IdVenta, Total
FROM Ventas
WHERE IdVenta = 4;
GO

-- Probar que se ve el stock inicial
-- Caso: ver stock antes del ajuste manual
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 3;
GO

-- Probar: dbo.SP_MovimientoStock_Registrar
-- Caso: ajuste manual positivo
EXEC dbo.SP_MovimientoStock_Registrar
    @IdProducto = 3,
    @IdTipoMovimientoStock = 3,
    @IdEmpleado = 1,
    @Cantidad = 2,
    @Motivo = 'Ajuste manual positivo por control de inventario';
GO

-- Probar: dbo.SP_MovimientoStock_Registrar
-- Caso: ajuste manual negativo
EXEC dbo.SP_MovimientoStock_Registrar
    @IdProducto = 3,
    @IdTipoMovimientoStock = 5,
    @IdEmpleado = 1,
    @Cantidad = -1,
    @Motivo = 'Ajuste manual negativo por merma detectada';
GO

-- Probar que cambia el stock con los ajustes
SELECT IdProducto, Nombre, StockActual
FROM Productos
WHERE IdProducto = 3;
GO

-- Probar que se registran los movimientos
SELECT TOP 5 IdMovimientoStock, IdProducto, IdTipoMovimientoStock, Cantidad, Motivo
FROM MovimientosStock
WHERE IdProducto = 3
ORDER BY IdMovimientoStock DESC;
GO

-- Probar: dbo.SP_Venta_Consultar
-- Caso: consultar por fechas
EXEC dbo.SP_Venta_Consultar
    @FechaDesde = '2026-01-01',
    @FechaHasta = '2026-02-28';
GO

-- Probar: dbo.SP_Venta_Consultar
-- Caso: consultar por cliente y medio de pago
EXEC dbo.SP_Venta_Consultar
    @IdCliente = 1,
    @IdMedioPago = 1;
GO
