USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

SET IDENTITY_INSERT Categorias ON;
INSERT INTO Categorias (IdCategoria, Nombre, Descripcion, Activo) VALUES
(1, 'Remeras', 'Prendas superiores', 1),
(2, 'Pantalones', 'Prendas inferiores', 1),
(3, 'Camperas', 'Abrigos y prendas para exteriores', 1),
(4, 'Camisas', 'Prendas superiores de manga larga o corta con botones', 1),
(5, 'Buzos', 'Prendas superiores de abrigo mas informal', 1),
(6, 'Shorts', 'Prendas inferiores de uso casual y enfocado al verano', 1);
SET IDENTITY_INSERT Categorias OFF;
GO

SET IDENTITY_INSERT Talles ON;
INSERT INTO Talles (IdTalle, Nombre, Descripcion, Activo) VALUES
(1, 'S', 'Talle pequenio', 1),
(2, 'M', 'Talle mediano', 1),
(3, 'L', 'Talle grande', 1),
(4, 'XL', 'Talle extra grande', 1),
(5, 'XXL', 'Talle extra extra grande', 1);
SET IDENTITY_INSERT Talles OFF;
GO

SET IDENTITY_INSERT Marcas ON;
INSERT INTO Marcas (IdMarca, Nombre, Descripcion, Activo) VALUES
(1, 'Levis', 'Marca urbana especializada en jeans', 1),
(2, 'Adidas', 'Marca orientada a indumentaria deportiva', 1),
(3, 'Nike', 'Marca especializada en indumentaria deportiva', 1),
(4, 'Reebok', 'Marca deportiva y funcional', 1),
(5, 'Calvin Klein', 'Marca especializada en ropa interior', 1);
SET IDENTITY_INSERT Marcas OFF;
GO

SET IDENTITY_INSERT Colores ON;
INSERT INTO Colores (IdColor, Nombre, Activo) VALUES
(1, 'Negro', 1),
(2, 'Blanco', 1),
(3, 'Azul', 1),
(4, 'Gris', 1),
(5, 'Verde', 1),
(6, 'Beige', 1);
SET IDENTITY_INSERT Colores OFF;
GO

SET IDENTITY_INSERT MediosPago ON;
INSERT INTO MediosPago (IdMedioPago, Nombre, Activo) VALUES
(1, 'Efectivo', 1),
(2, 'Tarjeta de debito', 1),
(3, 'Transferencia bancaria', 1),
(4, 'Tarjeta de credito', 1),
(5, 'Mercado Pago', 1);
SET IDENTITY_INSERT MediosPago OFF;
GO

SET IDENTITY_INSERT EstadosCompra ON;
INSERT INTO EstadosCompra (IdEstadoCompra, Nombre, Descripcion) VALUES
(1, 'Confirmada', 'Compra confirmada e incorporada al stock'),
(2, 'Pendiente', 'Compra cargada pero pendiente de recepcion'),
(3, 'Cancelada', 'Compra anulada'),
(4, 'Recibida parcial', 'Compra recibida solo en parte');
SET IDENTITY_INSERT EstadosCompra OFF;
GO

SET IDENTITY_INSERT EstadosVenta ON;
INSERT INTO EstadosVenta (IdEstadoVenta, Nombre, Descripcion) VALUES
(1, 'Confirmada', 'Venta confirmada y descontada del stock'),
(2, 'Pendiente', 'Venta pendiente de confirmacion'),
(3, 'Cancelada', 'Venta anulada'),
(4, 'Devuelta', 'Venta con devolucion total o parcial');
SET IDENTITY_INSERT EstadosVenta OFF;
GO

SET IDENTITY_INSERT TiposMovimientoStock ON;
INSERT INTO TiposMovimientoStock (IdTipoMovimientoStock, Nombre, Descripcion) VALUES
(1, 'Ingreso por compra', 'Movimiento que incrementa el stock por una compra'),
(2, 'Egreso por venta', 'Movimiento que disminuye el stock por una venta'),
(3, 'Ajuste manual', 'Movimiento manual por correccion de inventario'),
(4, 'Devolucion compra', 'Movimiento de reingreso por devolucion a proveedor'),
(5, 'Ajuste negativo', 'Movimiento manual que reduce stock');
SET IDENTITY_INSERT TiposMovimientoStock OFF;
GO

SET IDENTITY_INSERT Proveedores ON;
INSERT INTO Proveedores (IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo) VALUES
(1, 'Textil del Tigre SRL', '30-1234567-8', 'contacto@textilprueba.com', '1145551200', 'Av. Corrientes 1234, CABA', 1),
(2, 'Indumentaria Microcentro SA', '30-7654321-1', 'ventas@indumentariaprueba.com', '1146663400', '25 de Mayo 1234, CABA', 1);
SET IDENTITY_INSERT Proveedores OFF;
GO

SET IDENTITY_INSERT Clientes ON;
INSERT INTO Clientes (IdCliente, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo) VALUES
(1, 'Perez', 'Juan', '30111222', 'juanperez@mail.com', '1144441001', '2026-01-05', 1),
(2, 'Vera', 'Emilio', '28999888', 'emiliovera@mail.com', '1144441002', '2026-02-02', 1),
(3, 'Perez', 'Maria', '33777111', 'mariaperez@mail.com', '1144441003', '2026-02-20', 1);
SET IDENTITY_INSERT Clientes OFF;
GO

SET IDENTITY_INSERT Empleados ON;
INSERT INTO Empleados (IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo) VALUES
(1, 'Wonder', 'Stevie', '20123456', 'steviewonder@tienda.com', '1140000001', '2025-11-10', 1),
(2, 'Perez', 'Manuel', '23111222', 'manuelperez@tienda.com', '1140000002', '2025-11-10', 1);
SET IDENTITY_INSERT Empleados OFF;
GO

SET IDENTITY_INSERT Productos ON;
INSERT INTO Productos
    (IdProducto, IdCategoria, IdMarca, IdTalle, IdColor, CodigoProducto, Nombre, Descripcion, PrecioVenta, StockActual, StockMinimo, Activo)
VALUES
(1, 1, 1, 2, 1, 'CAM-S-NEGR-ALG', 'Remera basica negra', 'Remera de algodon liso', 15000.00, 14, 5, 1),
(2, 1, 2, 1, 2, 'CAM-S-BLA-ALG', 'Remera oversize blanca', 'Remera amplia de algodon premium', 22000.00, 8, 4, 1),
(3, 2, 3, 2, 3, 'JEA-S-AZU-DEN', 'Jean azul clasico', 'Jean recto de denim', 28000.00, 6, 3, 1),
(4, 3, 2, 3, 4, 'CAM-S-AZU-POL', 'Campera gris', 'Campera liviana de media estacion', 35000.00, 2, 4, 1),
(5, 2, 1, 2, 3, 'PAN-S-AZU-DEN', 'Pantalon clasico azul', 'Pantalon de gabardina', 40000.00, 11, 6, 1),
(6, 4, 5, 4, 2, 'CAM-S-AZU-ALG', 'Camisa clasica blanca', 'Camisa de vestir con corte recto', 32000.00, 7, 3, 1),
(7, 5, 4, 5, 4, 'BUZ-S-AZU-POL', 'Buzo deportivo gris', 'Buzo de friza con capucha', 48000.00, 5, 2, 1),
(8, 6, 3, 2, 3, 'SHO-S-AZU-DEN', 'Short denim azul', 'Short casual de verano', 25000.00, 9, 4, 1),
(9, 1, 4, 3, 5, 'REM-S-AZU-ALG', 'Remera manga larga verde', 'Remera basica de manga larga', 20000.00, 4, 2, 1);
SET IDENTITY_INSERT Productos OFF;
GO

SET IDENTITY_INSERT Compras ON;
INSERT INTO Compras
    (IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total)
VALUES
(1, 1, 1, 1, '2026-01-10T09:30:00', 'COMP-0001', 295000.00),
(2, 2, 2, 1, '2026-02-05T10:15:00', 'COMP-0002', 312000.00),
(3, 1, 1, 1, '2026-02-20T11:45:00', 'COMP-0003', 300000.00);
SET IDENTITY_INSERT Compras OFF;
GO

SET IDENTITY_INSERT DetalleCompras ON;
INSERT INTO DetalleCompras
    (IdDetalleCompra, IdCompra, IdProducto, Cantidad, PrecioUnitario, Subtotal)
VALUES
(1, 1, 1, 20, 8000.00, 160000.00),
(2, 1, 2, 15, 9000.00, 135000.00),
(3, 2, 3, 8, 12000.00, 96000.00),
(4, 2, 4, 12, 18000.00, 216000.00),
(5, 3, 5, 10, 30000.00, 300000.00);
SET IDENTITY_INSERT DetalleCompras OFF;
GO

SET IDENTITY_INSERT Ventas ON;
INSERT INTO Ventas
    (IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total)
VALUES
(1, 1, 1, 1, 1, '2026-01-15T17:20:00', 134000.00),
(2, 2, 2, 2, 1, '2026-02-10T18:05:00', 231000.00),
(3, 1, 1, 3, 1, '2026-02-25T12:10:00', 40000.00),
(4, 3, 2, 1, 1, '2026-03-05T19:40:00', 285000.00);
SET IDENTITY_INSERT Ventas OFF;
GO

SET IDENTITY_INSERT DetalleVentas ON;
INSERT INTO DetalleVentas
    (IdDetalleVenta, IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal)
VALUES
(1, 1, 1, 6, 15000.00, 90000.00),
(2, 1, 2, 2, 22000.00, 44000.00),
(3, 2, 3, 2, 28000.00, 56000.00),
(4, 2, 4, 5, 35000.00, 175000.00),
(5, 3, 5, 1, 40000.00, 40000.00),
(6, 4, 2, 5, 22000.00, 110000.00),
(7, 4, 4, 5, 35000.00, 175000.00);
SET IDENTITY_INSERT DetalleVentas OFF;
GO

SET IDENTITY_INSERT MovimientosStock ON;
INSERT INTO MovimientosStock
    (IdMovimientoStock, IdProducto, IdTipoMovimientoStock, IdEmpleado, IdCompra, IdVenta, FechaMovimiento, Cantidad, Motivo)
VALUES
(1, 1, 1, 1, 1, NULL, '2026-01-10T09:45:00', 20, 'Ingreso por compra COMP-0001'),
(2, 2, 1, 1, 1, NULL, '2026-01-10T09:45:00', 15, 'Ingreso por compra COMP-0001'),
(3, 3, 1, 2, 2, NULL, '2026-02-05T10:30:00', 8, 'Ingreso por compra COMP-0002'),
(4, 4, 1, 2, 2, NULL, '2026-02-05T10:30:00', 12, 'Ingreso por compra COMP-0002'),
(5, 5, 1, 1, 3, NULL, '2026-02-20T12:00:00', 10, 'Ingreso por compra COMP-0003'),
(6, 1, 2, 1, NULL, 1, '2026-01-15T17:25:00', 6, 'Salida por venta VTA-0001'),
(7, 2, 2, 1, NULL, 1, '2026-01-15T17:25:00', 2, 'Salida por venta VTA-0001'),
(8, 3, 2, 2, NULL, 2, '2026-02-10T18:10:00', 2, 'Salida por venta VTA-0002'),
(9, 4, 2, 2, NULL, 2, '2026-02-10T18:10:00', 5, 'Salida por venta VTA-0002'),
(10, 5, 2, 1, NULL, 3, '2026-02-25T12:15:00', 1, 'Salida por venta VTA-0003'),
(11, 2, 2, 2, NULL, 4, '2026-03-05T19:45:00', 5, 'Salida por venta VTA-0004'),
(12, 4, 2, 2, NULL, 4, '2026-03-05T19:45:00', 5, 'Salida por venta VTA-0004'),
(13, 5, 3, 1, NULL, NULL, '2026-03-20T08:00:00', 2, 'Ajuste manual de inventario');
SET IDENTITY_INSERT MovimientosStock OFF;
GO

SELECT 'Carga de los datos iniciales para pruebas OK...' AS Resultado;
GO
