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

SELECT 'Carga de los datos iniciales para pruebas OK...' AS Resultado;
GO
