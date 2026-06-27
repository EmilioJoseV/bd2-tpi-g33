USE master;
GO

IF DB_ID(N'BD2_TPI_TIENDA_INDUMENTARIA') IS NOT NULL
BEGIN
    ALTER DATABASE BD2_TPI_TIENDA_INDUMENTARIA SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BD2_TPI_TIENDA_INDUMENTARIA;
END
GO

CREATE DATABASE BD2_TPI_TIENDA_INDUMENTARIA;
GO

USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

CREATE TABLE Categorias (
    IdCategoria int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL UNIQUE,
    Descripcion varchar(255),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Talles (
    IdTalle int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(20) NOT NULL UNIQUE,
    Descripcion varchar(100),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Marcas (
    IdMarca int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL UNIQUE,
    Descripcion varchar(255),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE MediosPago (
    IdMedioPago int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL UNIQUE,
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE EstadosVenta (
    IdEstadoVenta int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL UNIQUE,
    Descripcion varchar(255)
);
GO

CREATE TABLE EstadosCompra (
    IdEstadoCompra int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL UNIQUE,
    Descripcion varchar(255)
);
GO

CREATE TABLE TiposMovimientoStock (
    IdTipoMovimientoStock int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL UNIQUE,
    Descripcion varchar(255)
);
GO

CREATE TABLE Colores (
    IdColor int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL UNIQUE,
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Proveedores (
    IdProveedor int IDENTITY(1,1) PRIMARY KEY,
    RazonSocial varchar(150) NOT NULL,
    CUIT varchar(20) NOT NULL UNIQUE,
    Email varchar(150),
    Telefono varchar(30),
    Direccion varchar(200),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Clientes (
    IdCliente int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100) NOT NULL,
    Nombre varchar(100) NOT NULL,
    Documento varchar(20) NOT NULL UNIQUE,
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date NOT NULL DEFAULT GETDATE(),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Empleados (
    IdEmpleado int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100) NOT NULL,
    Nombre varchar(100) NOT NULL,
    Documento varchar(20) NOT NULL UNIQUE,
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date NOT NULL DEFAULT GETDATE(),
    Activo bit NOT NULL DEFAULT 1
);
GO

CREATE TABLE Productos (
    IdProducto int IDENTITY(1,1) PRIMARY KEY,
    IdCategoria int NOT NULL,
    IdMarca int NOT NULL,
    IdTalle int NOT NULL,
    IdColor int NOT NULL,
    CodigoProducto varchar(50) NOT NULL UNIQUE,
    Nombre varchar(150) NOT NULL,
    Descripcion varchar(255),
    PrecioVenta decimal(12,2) NOT NULL,
    StockActual int NOT NULL DEFAULT 0,
    StockMinimo int NOT NULL DEFAULT 0,
    Activo bit NOT NULL DEFAULT 1,
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria) REFERENCES Categorias (IdCategoria),
    CONSTRAINT FK_Productos_Marcas FOREIGN KEY (IdMarca) REFERENCES Marcas (IdMarca),
    CONSTRAINT FK_Productos_Talles FOREIGN KEY (IdTalle) REFERENCES Talles (IdTalle),
    CONSTRAINT FK_Productos_Colores FOREIGN KEY (IdColor) REFERENCES Colores (IdColor)
);
GO

CREATE TABLE Compras (
    IdCompra int IDENTITY(1,1) PRIMARY KEY,
    IdProveedor int NOT NULL,
    IdEmpleado int NOT NULL,
    IdEstadoCompra int NOT NULL,
    FechaCompra datetime2 NOT NULL DEFAULT SYSDATETIME(),
    NumeroComprobante varchar(50),
    Total decimal(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Compras_Proveedores FOREIGN KEY (IdProveedor) REFERENCES Proveedores (IdProveedor),
    CONSTRAINT FK_Compras_Empleados FOREIGN KEY (IdEmpleado) REFERENCES Empleados (IdEmpleado),
    CONSTRAINT FK_Compras_EstadosCompra FOREIGN KEY (IdEstadoCompra) REFERENCES EstadosCompra (IdEstadoCompra)
);
GO

CREATE TABLE Ventas (
    IdVenta int IDENTITY(1,1) PRIMARY KEY,
    IdCliente int NOT NULL,
    IdEmpleado int NOT NULL,
    IdMedioPago int NOT NULL,
    IdEstadoVenta int NOT NULL,
    FechaVenta datetime2 NOT NULL DEFAULT SYSDATETIME(),
    Total decimal(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (IdCliente) REFERENCES Clientes (IdCliente),
    CONSTRAINT FK_Ventas_Empleados FOREIGN KEY (IdEmpleado) REFERENCES Empleados (IdEmpleado),
    CONSTRAINT FK_Ventas_MediosPago FOREIGN KEY (IdMedioPago) REFERENCES MediosPago (IdMedioPago),
    CONSTRAINT FK_Ventas_EstadosVenta FOREIGN KEY (IdEstadoVenta) REFERENCES EstadosVenta (IdEstadoVenta)
);
GO

CREATE TABLE DetalleCompras (
    IdDetalleCompra int IDENTITY(1,1) PRIMARY KEY,
    IdCompra int NOT NULL,
    IdProducto int NOT NULL,
    Cantidad int NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario decimal(12,2) NOT NULL,
    Subtotal decimal(12,2) NOT NULL,
    CONSTRAINT FK_DetalleCompras_Compras FOREIGN KEY (IdCompra) REFERENCES Compras (IdCompra),
    CONSTRAINT FK_DetalleCompras_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
);
GO

CREATE TABLE DetalleVentas (
    IdDetalleVenta int IDENTITY(1,1) PRIMARY KEY,
    IdVenta int NOT NULL,
    IdProducto int NOT NULL,
    Cantidad int NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario decimal(12,2) NOT NULL,
    Subtotal decimal(12,2) NOT NULL,
    CONSTRAINT FK_DetalleVentas_Ventas FOREIGN KEY (IdVenta) REFERENCES Ventas (IdVenta),
    CONSTRAINT FK_DetalleVentas_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
);
GO

CREATE TABLE MovimientosStock (
    IdMovimientoStock int IDENTITY(1,1) PRIMARY KEY,
    IdProducto int NOT NULL,
    IdTipoMovimientoStock int NOT NULL,
    IdEmpleado int,
    IdCompra int,
    IdVenta int,
    FechaMovimiento datetime2 NOT NULL DEFAULT SYSDATETIME(),
    Cantidad int NOT NULL,
    Motivo varchar(255),
    CONSTRAINT FK_MovimientosStock_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto),
    CONSTRAINT FK_MovimientosStock_TiposMovimientoStock FOREIGN KEY (IdTipoMovimientoStock) REFERENCES TiposMovimientoStock (IdTipoMovimientoStock),
    CONSTRAINT FK_MovimientosStock_Empleados FOREIGN KEY (IdEmpleado) REFERENCES Empleados (IdEmpleado),
    CONSTRAINT FK_MovimientosStock_Compras FOREIGN KEY (IdCompra) REFERENCES Compras (IdCompra),
    CONSTRAINT FK_MovimientosStock_Ventas FOREIGN KEY (IdVenta) REFERENCES Ventas (IdVenta)
);
GO

SELECT 'BD creada OK...' AS Resultado;
GO

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

GO

GO

USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #13 - Disminuir automáticamente el stock cuando se registra una venta a un cliente
-- trg_actualizarStockPorEstadoVenta: toca el stock si la venta pasa a confirmada o deja de estarlo.

CREATE TRIGGER trg_actualizarStockPorEstadoVenta
ON Ventas
AFTER UPDATE
AS
BEGIN
    DECLARE @VentasQueSeConfirmaron TABLE (
        IdVenta INT
    );

    DECLARE @VentasQueSeDesconfirmaron TABLE (
        IdVenta INT
    );

    DECLARE @MovimientosStock TABLE (
        IdProducto INT,
        CantidadAAjustar INT
    );

    -- Aca guardamos las ventas que antes no estaban confirmadas y ahora si.
    INSERT INTO @VentasQueSeConfirmaron (IdVenta)
    SELECT i.IdVenta
    FROM inserted i
    INNER JOIN deleted d ON d.IdVenta = i.IdVenta
    INNER JOIN EstadosVenta evAnterior ON evAnterior.IdEstadoVenta = d.IdEstadoVenta
    INNER JOIN EstadosVenta evNuevo ON evNuevo.IdEstadoVenta = i.IdEstadoVenta
    WHERE i.IdEstadoVenta <> d.IdEstadoVenta
      AND UPPER(evAnterior.Nombre) <> 'CONFIRMADA'
      AND UPPER(evNuevo.Nombre) = 'CONFIRMADA';

    -- Aca guardamos las ventas que antes estaban confirmadas y ahora no.
    INSERT INTO @VentasQueSeDesconfirmaron (IdVenta)
    SELECT i.IdVenta
    FROM inserted i
    INNER JOIN deleted d ON d.IdVenta = i.IdVenta
    INNER JOIN EstadosVenta evAnterior ON evAnterior.IdEstadoVenta = d.IdEstadoVenta
    INNER JOIN EstadosVenta evNuevo ON evNuevo.IdEstadoVenta = i.IdEstadoVenta
    WHERE i.IdEstadoVenta <> d.IdEstadoVenta
      AND UPPER(evAnterior.Nombre) = 'CONFIRMADA'
      AND UPPER(evNuevo.Nombre) <> 'CONFIRMADA';

    -- Si una venta se confirma, el stock baja.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dv.IdProducto,
           SUM(dv.Cantidad) * -1
    FROM DetalleVentas dv
    INNER JOIN @VentasQueSeConfirmaron vc ON vc.IdVenta = dv.IdVenta
    GROUP BY dv.IdProducto;

    -- Si una venta deja de estar confirmada, el stock vuelve.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dv.IdProducto,
           SUM(dv.Cantidad)
    FROM DetalleVentas dv
    INNER JOIN @VentasQueSeDesconfirmaron vd ON vd.IdVenta = dv.IdVenta
    GROUP BY dv.IdProducto;

    -- Antes de actualizar nada, revisamos si algun stock quedaria negativo.
    IF EXISTS (
        SELECT 1
        FROM Productos p
        INNER JOIN (
            SELECT IdProducto,
                   SUM(CantidadAAjustar) AS CantidadAAjustar
            FROM @MovimientosStock
            GROUP BY IdProducto
        ) m ON m.IdProducto = p.IdProducto
        WHERE p.StockActual + m.CantidadAAjustar < 0
    )
    BEGIN
        RAISERROR ('Stock insuficiente', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Si esta todo bien, aplicamos el movimiento final al stock.
    UPDATE p
    SET p.StockActual = p.StockActual + m.CantidadAAjustar
    FROM Productos p
    INNER JOIN (
        SELECT IdProducto,
               SUM(CantidadAAjustar) AS CantidadAAjustar
        FROM @MovimientosStock
        GROUP BY IdProducto
    ) m ON m.IdProducto = p.IdProducto;
END;
GO

-- trg_actualizarStockPorEstadoCompra: toca el stock si la compra pasa a confirmada o deja de estarlo.

CREATE TRIGGER trg_actualizarStockPorEstadoCompra
ON Compras
AFTER UPDATE
AS
BEGIN
    DECLARE @ComprasQueSeConfirmaron TABLE (
        IdCompra INT
    );

    DECLARE @ComprasQueSeDesconfirmaron TABLE (
        IdCompra INT
    );

    DECLARE @MovimientosStock TABLE (
        IdProducto INT,
        CantidadAAjustar INT
    );

    -- Aca guardamos las compras que antes no estaban confirmadas y ahora si.
    INSERT INTO @ComprasQueSeConfirmaron (IdCompra)
    SELECT i.IdCompra
    FROM inserted i
    INNER JOIN deleted d ON d.IdCompra = i.IdCompra
    INNER JOIN EstadosCompra ecAnterior ON ecAnterior.IdEstadoCompra = d.IdEstadoCompra
    INNER JOIN EstadosCompra ecNuevo ON ecNuevo.IdEstadoCompra = i.IdEstadoCompra
    WHERE i.IdEstadoCompra <> d.IdEstadoCompra
      AND UPPER(ecAnterior.Nombre) <> 'CONFIRMADA'
      AND UPPER(ecNuevo.Nombre) = 'CONFIRMADA';

    -- Aca guardamos las compras que antes estaban confirmadas y ahora no.
    INSERT INTO @ComprasQueSeDesconfirmaron (IdCompra)
    SELECT i.IdCompra
    FROM inserted i
    INNER JOIN deleted d ON d.IdCompra = i.IdCompra
    INNER JOIN EstadosCompra ecAnterior ON ecAnterior.IdEstadoCompra = d.IdEstadoCompra
    INNER JOIN EstadosCompra ecNuevo ON ecNuevo.IdEstadoCompra = i.IdEstadoCompra
    WHERE i.IdEstadoCompra <> d.IdEstadoCompra
      AND UPPER(ecAnterior.Nombre) = 'CONFIRMADA'
      AND UPPER(ecNuevo.Nombre) <> 'CONFIRMADA';

    -- Si una compra se confirma, el stock sube.
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dc.IdProducto,
           SUM(dc.Cantidad)
    FROM DetalleCompras dc
    INNER JOIN @ComprasQueSeConfirmaron cc ON cc.IdCompra = dc.IdCompra
    GROUP BY dc.IdProducto;

    -- Si una compra deja de estar confirmada, el stock vuelve para atras
    INSERT INTO @MovimientosStock (IdProducto, CantidadAAjustar)
    SELECT dc.IdProducto,
           SUM(dc.Cantidad) * -1
    FROM DetalleCompras dc
    INNER JOIN @ComprasQueSeDesconfirmaron cd ON cd.IdCompra = dc.IdCompra
    GROUP BY dc.IdProducto;

    -- Antes de actualizar nada, revisamos si algun stock quedaria negativo
    IF EXISTS (
        SELECT 1
        FROM Productos p
        INNER JOIN (
            SELECT IdProducto,
                   SUM(CantidadAAjustar) AS CantidadAAjustar
            FROM @MovimientosStock
            GROUP BY IdProducto
        ) m ON m.IdProducto = p.IdProducto
        WHERE p.StockActual + m.CantidadAAjustar < 0
    )
    BEGIN
        RAISERROR ('Stock insuficiente', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Si esta todo bien, aplicamos el movimiento final al stock.
    UPDATE p
    SET p.StockActual = p.StockActual + m.CantidadAAjustar
    FROM Productos p
    INNER JOIN (
        SELECT IdProducto,
               SUM(CantidadAAjustar) AS CantidadAAjustar
        FROM @MovimientosStock
        GROUP BY IdProducto
    ) m ON m.IdProducto = p.IdProducto;
END;
GO

-- Proveedores

-- SP_Proveedor_Registrar (Procedimiento para registrar un nuevo proveedor y mantener sus datos de contacto)
IF OBJECT_ID(N'dbo.SP_Proveedor_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Registrar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Registrar
    @RazonSocial varchar(150),
    @CUIT        varchar(20),
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    IF @RazonSocial IS NULL OR @RazonSocial = ''
        THROW 50001, 'La razon social es obligatoria.', 1;

    IF @CUIT IS NULL OR @CUIT = ''
        THROW 50002, 'El CUIT es obligatorio.', 1;

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
    )
        THROW 50003, 'Ya existe un proveedor con ese CUIT.', 1;

    BEGIN TRY
        INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
        VALUES (
            @RazonSocial,
            @CUIT,
            @Email,
            @Telefono,
            @Direccion,
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50003, 'Ya existe un proveedor con ese CUIT.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = SCOPE_IDENTITY();
END;
GO


-- SP_Proveedor_Actualizar (Actualiza los datos principales de un proveedor existente.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Actualizar
    @IdProveedor int,
    @RazonSocial varchar(150),
    @CUIT        varchar(20),
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

    IF @RazonSocial IS NULL OR @RazonSocial = ''
        THROW 50001, 'La razon social es obligatoria.', 1;

    IF @CUIT IS NULL OR @CUIT = ''
        THROW 50002, 'El CUIT es obligatorio.', 1;

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
          AND IdProveedor <> @IdProveedor
    )
        THROW 50003, 'Ya existe otro proveedor con ese CUIT.', 1;

    BEGIN TRY
        UPDATE Proveedores
        SET RazonSocial = @RazonSocial,
            CUIT        = @CUIT,
            Email       = @Email,
            Telefono    = @Telefono,
            Direccion   = @Direccion,
            Activo      = @Activo
        WHERE IdProveedor = @IdProveedor;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50003, 'Ya existe otro proveedor con ese CUIT.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO


-- SP_Proveedor_ActualizarContacto (Mantener sus datos de contacto: solo Email, Telefono y Direccion.)
IF OBJECT_ID(N'dbo.SP_Proveedor_ActualizarContacto', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_ActualizarContacto;
GO

CREATE PROCEDURE dbo.SP_Proveedor_ActualizarContacto
    @IdProveedor int,
    @Email       varchar(150) = NULL,
    @Telefono    varchar(30)  = NULL,
    @Direccion   varchar(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Email     = @Email,
        Telefono  = @Telefono,
        Direccion = @Direccion
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO


-- SP_Proveedor_Desactivar (Baja logica.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Desactivar
    @IdProveedor int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Activo = 0
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO


-- SP_Proveedor_Reactivar (Reactivacion de un proveedor desactivado.)
IF OBJECT_ID(N'dbo.SP_Proveedor_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Proveedor_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Proveedor_Reactivar
    @IdProveedor int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
        THROW 50005, 'El IdProveedor es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Proveedores WHERE IdProveedor = @IdProveedor)
        THROW 50004, 'El proveedor indicado no existe.', 1;

    UPDATE Proveedores
    SET Activo = 1
    WHERE IdProveedor = @IdProveedor;

    SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo
    FROM Proveedores
    WHERE IdProveedor = @IdProveedor;
END;
GO

-- Empleados

-- SP_Empleado_Registrar
IF OBJECT_ID(N'dbo.SP_Empleado_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Registrar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Registrar
    @Apellido  varchar(100),
    @Nombre    varchar(100),
    @Documento varchar(20),
    @Email     varchar(150) = NULL,
    @Telefono  varchar(30)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Apellido, ''))) = ''
        THROW 50011, 'El apellido es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50012, 'El nombre es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Documento, ''))) = ''
        THROW 50013, 'El documento es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Empleados WHERE Documento = LTRIM(RTRIM(@Documento)))
        THROW 50014, 'Ya existe un empleado con ese documento.', 1;

    BEGIN TRY
        INSERT INTO Empleados (Apellido, Nombre, Documento, Email, Telefono, Activo)
        VALUES (
            LTRIM(RTRIM(@Apellido)),
            LTRIM(RTRIM(@Nombre)),
            LTRIM(RTRIM(@Documento)),
            NULLIF(LTRIM(RTRIM(@Email)), ''),
            NULLIF(LTRIM(RTRIM(@Telefono)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50014, 'Ya existe un empleado con ese documento.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = SCOPE_IDENTITY();
END;
GO


-- SP_Empleado_Actualizar
IF OBJECT_ID(N'dbo.SP_Empleado_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Actualizar
    @IdEmpleado int,
    @Apellido   varchar(100),
    @Nombre     varchar(100),
    @Documento  varchar(20),
    @Email      varchar(150) = NULL,
    @Telefono   varchar(30)  = NULL,
    @Activo     bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Apellido, ''))) = ''
        THROW 50011, 'El apellido es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50012, 'El nombre es obligatorio.', 1;

    IF LTRIM(RTRIM(ISNULL(@Documento, ''))) = ''
        THROW 50013, 'El documento es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Empleados
        WHERE Documento = LTRIM(RTRIM(@Documento))
          AND IdEmpleado <> @IdEmpleado
    )
        THROW 50014, 'Ya existe otro empleado con ese documento.', 1;

    BEGIN TRY
        UPDATE Empleados
        SET Apellido  = LTRIM(RTRIM(@Apellido)),
            Nombre    = LTRIM(RTRIM(@Nombre)),
            Documento = LTRIM(RTRIM(@Documento)),
            Email     = NULLIF(LTRIM(RTRIM(@Email)), ''),
            Telefono  = NULLIF(LTRIM(RTRIM(@Telefono)), ''),
            Activo    = @Activo
        WHERE IdEmpleado = @IdEmpleado;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50014, 'Ya existe otro empleado con ese documento.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO


-- SP_Empleado_Desactivar
IF OBJECT_ID(N'dbo.SP_Empleado_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Desactivar
    @IdEmpleado int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    UPDATE Empleados
    SET Activo = 0
    WHERE IdEmpleado = @IdEmpleado;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO


-- SP_Empleado_Reactivar
IF OBJECT_ID(N'dbo.SP_Empleado_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Empleado_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Empleado_Reactivar
    @IdEmpleado int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado)
        THROW 50015, 'El empleado indicado no existe.', 1;

    UPDATE Empleados
    SET Activo = 1
    WHERE IdEmpleado = @IdEmpleado;

    SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo
    FROM Empleados
    WHERE IdEmpleado = @IdEmpleado;
END;
GO

-- Talles

-- SP_Talle_Registrar
IF OBJECT_ID(N'dbo.SP_Talle_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Registrar;
GO

CREATE PROCEDURE dbo.SP_Talle_Registrar
    @Nombre      varchar(20),
    @Descripcion varchar(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50051, 'El nombre del talle es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Talles WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50052, 'Ya existe un talle con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Talles (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50052, 'Ya existe un talle con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = SCOPE_IDENTITY();
END;
GO


-- SP_Talle_Actualizar
IF OBJECT_ID(N'dbo.SP_Talle_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Talle_Actualizar
    @IdTalle     int,
    @Nombre      varchar(20),
    @Descripcion varchar(100) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50051, 'El nombre del talle es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Talles
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdTalle <> @IdTalle
    )
        THROW 50052, 'Ya existe otro talle con ese nombre.', 1;

    BEGIN TRY
        UPDATE Talles
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdTalle = @IdTalle;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50052, 'Ya existe otro talle con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO


-- SP_Talle_Desactivar
IF OBJECT_ID(N'dbo.SP_Talle_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Talle_Desactivar
    @IdTalle int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    UPDATE Talles
    SET Activo = 0
    WHERE IdTalle = @IdTalle;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO


-- SP_Talle_Reactivar
IF OBJECT_ID(N'dbo.SP_Talle_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Talle_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Talle_Reactivar
    @IdTalle int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Talles WHERE IdTalle = @IdTalle)
        THROW 50053, 'El talle indicado no existe.', 1;

    UPDATE Talles
    SET Activo = 1
    WHERE IdTalle = @IdTalle;

    SELECT IdTalle, Nombre, Descripcion, Activo
    FROM Talles
    WHERE IdTalle = @IdTalle;
END;
GO

-- Marcas

-- SP_Marca_Registrar
IF OBJECT_ID(N'dbo.SP_Marca_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Registrar;
GO

CREATE PROCEDURE dbo.SP_Marca_Registrar
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50021, 'El nombre de la marca es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Marcas WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50022, 'Ya existe una marca con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Marcas (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50022, 'Ya existe una marca con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = SCOPE_IDENTITY();
END;
GO


-- SP_Marca_Actualizar
IF OBJECT_ID(N'dbo.SP_Marca_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Marca_Actualizar
    @IdMarca     int,
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50021, 'El nombre de la marca es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Marcas
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdMarca <> @IdMarca
    )
        THROW 50022, 'Ya existe otra marca con ese nombre.', 1;

    BEGIN TRY
        UPDATE Marcas
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdMarca = @IdMarca;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50022, 'Ya existe otra marca con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO


-- SP_Marca_Desactivar
IF OBJECT_ID(N'dbo.SP_Marca_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Marca_Desactivar
    @IdMarca int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    UPDATE Marcas
    SET Activo = 0
    WHERE IdMarca = @IdMarca;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO


-- SP_Marca_Reactivar
IF OBJECT_ID(N'dbo.SP_Marca_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Marca_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Marca_Reactivar
    @IdMarca int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Marcas WHERE IdMarca = @IdMarca)
        THROW 50023, 'La marca indicada no existe.', 1;

    UPDATE Marcas
    SET Activo = 1
    WHERE IdMarca = @IdMarca;

    SELECT IdMarca, Nombre, Descripcion, Activo
    FROM Marcas
    WHERE IdMarca = @IdMarca;
END;
GO

-- Colores

-- SP_Color_Registrar
IF OBJECT_ID(N'dbo.SP_Color_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Registrar;
GO

CREATE PROCEDURE dbo.SP_Color_Registrar
    @Nombre varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50031, 'El nombre del color es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Colores WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50032, 'Ya existe un color con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Colores (Nombre, Activo)
        VALUES (LTRIM(RTRIM(@Nombre)), 1);
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50032, 'Ya existe un color con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = SCOPE_IDENTITY();
END;
GO


-- SP_Color_Actualizar
IF OBJECT_ID(N'dbo.SP_Color_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Color_Actualizar
    @IdColor int,
    @Nombre  varchar(50),
    @Activo  bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50031, 'El nombre del color es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Colores
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdColor <> @IdColor
    )
        THROW 50032, 'Ya existe otro color con ese nombre.', 1;

    BEGIN TRY
        UPDATE Colores
        SET Nombre = LTRIM(RTRIM(@Nombre)),
            Activo = @Activo
        WHERE IdColor = @IdColor;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50032, 'Ya existe otro color con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO


-- SP_Color_Desactivar
IF OBJECT_ID(N'dbo.SP_Color_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Color_Desactivar
    @IdColor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    UPDATE Colores
    SET Activo = 0
    WHERE IdColor = @IdColor;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO


-- SP_Color_Reactivar
IF OBJECT_ID(N'dbo.SP_Color_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Color_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Color_Reactivar
    @IdColor int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Colores WHERE IdColor = @IdColor)
        THROW 50033, 'El color indicado no existe.', 1;

    UPDATE Colores
    SET Activo = 1
    WHERE IdColor = @IdColor;

    SELECT IdColor, Nombre, Activo
    FROM Colores
    WHERE IdColor = @IdColor;
END;
GO

-- Clientes

-- sp_registrarCliente: da de alta un cliente y valida que el documento no se repita.
CREATE PROCEDURE sp_registrarCliente
    @Apellido VARCHAR(100),
    @Nombre VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30)
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Documento = LTRIM(RTRIM(@Documento));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF @Apellido IS NULL OR @Apellido = ''
    BEGIN
        PRINT 'Falta el apellido';
        RETURN;
    END

    IF @Nombre IS NULL OR @Nombre = ''
    BEGIN
        PRINT 'Falta el nombre';
        RETURN;
    END

    IF @Documento IS NULL OR @Documento = ''
    BEGIN
        PRINT 'Falta el documento';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE UPPER(Documento) = UPPER(@Documento)
    )
    BEGIN
        PRINT 'Ya existe un cliente con ese documento';
        RETURN;
    END

    INSERT INTO Clientes (Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo)
    VALUES (@Apellido, @Nombre, @Documento, @Email, @Telefono, GETDATE(), 1);

    PRINT 'Cliente registrado';
END;
GO

-- sp_actualizarCliente: actualiza los datos principales de un cliente existente.
CREATE PROCEDURE sp_actualizarCliente
    @IdCliente INT,
    @Apellido VARCHAR(100),
    @Nombre VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Activo BIT
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Documento = LTRIM(RTRIM(@Documento));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));

    IF @IdCliente IS NULL OR @IdCliente <= 0
    BEGIN
        PRINT 'IdCliente invalido';
        RETURN;
    END

    IF @Apellido IS NULL OR @Apellido = ''
    BEGIN
        PRINT 'Falta el apellido';
        RETURN;
    END

    IF @Nombre IS NULL OR @Nombre = ''
    BEGIN
        PRINT 'Falta el nombre';
        RETURN;
    END

    IF @Documento IS NULL OR @Documento = ''
    BEGIN
        PRINT 'Falta el documento';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM Clientes
        WHERE IdCliente = @IdCliente
    )
    BEGIN
        PRINT 'No existe un cliente con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Clientes
        WHERE UPPER(Documento) = UPPER(@Documento)
          AND IdCliente <> @IdCliente
    )
    BEGIN
        PRINT 'Ya existe otro cliente con ese documento';
        RETURN;
    END

    UPDATE Clientes
    SET Apellido = @Apellido,
        Nombre = @Nombre,
        Documento = @Documento,
        Email = @Email,
        Telefono = @Telefono,
        Activo = @Activo
    WHERE IdCliente = @IdCliente;

    PRINT 'Cliente actualizado';
END;
GO

-- Compras

-- sp_registrarCompra: registra una compra validando bien los datos de entrada.
CREATE PROCEDURE sp_registrarCompra
    @IdProveedor INT,
    @IdEmpleado INT,
    @NumeroComprobante VARCHAR(50),
    @Total DECIMAL(12,2)
AS
BEGIN
    DECLARE @IdEstadoPendiente INT;

-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'El proveedor es invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'El empleado es invalido';
        RETURN;
    END

    IF @Total IS NULL OR @Total < 0
    BEGIN
        PRINT 'El total es invalido';
        RETURN;
    END
    
-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado no esta activo';
        RETURN;
    END

-- Iniciamos la compra siempre con estado pendiente, por lo que buscamos el id de ese estado para asignarlo a la compra. 
-- Si no existe el estado pendiente, se muestra un mensaje de error y se cancela el registro de la compra.
    SELECT @IdEstadoPendiente = IdEstadoCompra
    FROM EstadosCompra
    WHERE UPPER(Nombre) = 'PENDIENTE';

    IF @IdEstadoPendiente IS NULL
    BEGIN
        PRINT 'No existe el estado pendiente registrado en la bd';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

-- Registrar la compra arrancando siempre en pendiente.
    INSERT INTO Compras (IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total)
    VALUES (@IdProveedor, @IdEmpleado, @IdEstadoPendiente, SYSDATETIME(), @NumeroComprobante, @Total);

    PRINT 'Compra registrada';
END;
GO

-- sp_actualizarCompra: actualiza los datos principales de una compra existente.
CREATE PROCEDURE sp_actualizarCompra
    @IdCompra INT,
    @IdProveedor INT,
    @IdEmpleado INT,
    @IdEstadoCompra INT,
    @NumeroComprobante VARCHAR(50),
    @Total DECIMAL(12,2)
AS
BEGIN
-- Limpiar espacios en blanco del numero de comprobante
    SET @NumeroComprobante = LTRIM(RTRIM(@NumeroComprobante));

-- Validar datos ingresados para la actualizacion de la compra.
    IF @IdCompra IS NULL OR @IdCompra <= 0
    BEGIN
        PRINT 'El id de la compra es invalido';
        RETURN;
    END

    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'El proveedor es invalido';
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        PRINT 'El empleado es invalido';
        RETURN;
    END

    IF @IdEstadoCompra IS NULL OR @IdEstadoCompra <= 0
    BEGIN
        PRINT 'El estado de la compra es invalido';
        RETURN;
    END

    IF @Total IS NULL OR @Total < 0
    BEGIN
        PRINT 'El total es invalido';
        RETURN;
    END

-- Validar existencia y datos de los registros relacionados.
    IF NOT EXISTS (
        SELECT 1
        FROM Compras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No existe una compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
          AND Activo = 0
    )
    BEGIN
        PRINT 'El proveedor no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        PRINT 'No existe un empleado con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 0
    )
    BEGIN
        PRINT 'El empleado no esta activo';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
    )
    BEGIN
        PRINT 'No existe un estado de compra con ese id';
        RETURN;
    END

    IF @NumeroComprobante = ''
        SET @NumeroComprobante = NULL;

    IF EXISTS (
        SELECT 1
        FROM EstadosCompra
        WHERE IdEstadoCompra = @IdEstadoCompra
          AND UPPER(Nombre) = 'CONFIRMADA'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No se puede confirmar una compra sin detalle';
        RETURN;
    END

-- Actualizar la compra con los nuevos datos ingresados.
    UPDATE Compras
    SET IdProveedor = @IdProveedor,
        IdEmpleado = @IdEmpleado,
        IdEstadoCompra = @IdEstadoCompra,
        NumeroComprobante = @NumeroComprobante,
        Total = @Total
    WHERE IdCompra = @IdCompra;

    PRINT 'Compra actualizada';
END;
GO

-- Detalle de compras

-- sp_registrarDetalleCompra: agrega un registro de detalle a una compra.
CREATE PROCEDURE sp_registrarDetalleCompra
    @IdCompra INT,
    @IdProducto INT,
    @Cantidad INT,
    @PrecioUnitario DECIMAL(12,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(12,2);

    IF @IdCompra IS NULL OR @IdCompra <= 0
    BEGIN
        PRINT 'El id de compra es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF @PrecioUnitario IS NULL OR @PrecioUnitario < 0
    BEGIN
        PRINT 'El precio unitario es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Compras
        WHERE IdCompra = @IdCompra
    )
    BEGIN
        PRINT 'No existe una compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    INSERT INTO DetalleCompras (IdCompra, IdProducto, Cantidad, PrecioUnitario, Subtotal)
    VALUES (@IdCompra, @IdProducto, @Cantidad, @PrecioUnitario, @Subtotal);

    PRINT 'Detalle de compra registrado';
END;
GO

-- sp_actualizarDetalleCompra: actualiza una linea de detalle de compra.
CREATE PROCEDURE sp_actualizarDetalleCompra
    @IdDetalleCompra INT,
    @IdProducto INT,
    @Cantidad INT,
    @PrecioUnitario DECIMAL(12,2)
AS
BEGIN
    DECLARE @Subtotal DECIMAL(12,2);
    DECLARE @IdCompra INT;

    IF @IdDetalleCompra IS NULL OR @IdDetalleCompra <= 0
    BEGIN
        PRINT 'El id de detalle de compra es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF @PrecioUnitario IS NULL OR @PrecioUnitario < 0
    BEGIN
        PRINT 'El precio unitario es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdDetalleCompra = @IdDetalleCompra
    )
    BEGIN
        PRINT 'No existe un detalle de compra con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

    SELECT @IdCompra = IdCompra
    FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

-- Valiamdos que la compra no este confirmada, ya que no se puede modificar el detalle de una compra confirmada.
    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    UPDATE DetalleCompras
    SET IdProducto = @IdProducto,
        Cantidad = @Cantidad,
        PrecioUnitario = @PrecioUnitario,
        Subtotal = @Subtotal
    WHERE IdDetalleCompra = @IdDetalleCompra;

    PRINT 'Detalle de compra actualizado';
END;
GO

-- sp_eliminarDetalleCompra: elimina una linea de detalle de compra.
CREATE PROCEDURE sp_eliminarDetalleCompra
    @IdDetalleCompra INT
AS
BEGIN
    DECLARE @IdCompra INT;

    IF @IdDetalleCompra IS NULL OR @IdDetalleCompra <= 0
    BEGIN
        PRINT 'El id de detalle de compra es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleCompras
        WHERE IdDetalleCompra = @IdDetalleCompra
    )
    BEGIN
        PRINT 'No existe un detalle de compra con ese id';
        RETURN;
    END

    SELECT @IdCompra = IdCompra
    FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

-- Validamos que la compra no este confirmada, ya que no se puede modificar el detalle de una compra confirmada.
    IF EXISTS (
        SELECT 1
        FROM Compras c
        INNER JOIN EstadosCompra ec ON ec.IdEstadoCompra = c.IdEstadoCompra
        WHERE c.IdCompra = @IdCompra
          AND UPPER(ec.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una compra confirmada';
        RETURN;
    END

    DELETE FROM DetalleCompras
    WHERE IdDetalleCompra = @IdDetalleCompra;

    PRINT 'Detalle de compra eliminado';
END;
GO

-- Detalle de ventas

-- sp_registrarDetalleVenta: agrega un registro de detalle a una venta.
CREATE PROCEDURE sp_registrarDetalleVenta
    @IdVenta INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @PrecioUnitario DECIMAL(12,2);
    DECLARE @Subtotal DECIMAL(12,2);

    IF @IdVenta IS NULL OR @IdVenta <= 0
    BEGIN
        PRINT 'El id de venta es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Ventas
        WHERE IdVenta = @IdVenta
    )
    BEGIN
        PRINT 'No existe una venta con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

-- Validamos que la venta no este confirmada, ya que no se puede modificar el detalle de una venta confirmada.
    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SELECT @PrecioUnitario = PrecioVenta
    FROM Productos
    WHERE IdProducto = @IdProducto;

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    INSERT INTO DetalleVentas (IdVenta, IdProducto, Cantidad, PrecioUnitario, Subtotal)
    VALUES (@IdVenta, @IdProducto, @Cantidad, @PrecioUnitario, @Subtotal);

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta registrado';
END;
GO

-- sp_actualizarDetalleVenta: actualiza un registro de detalle de venta.
CREATE PROCEDURE sp_actualizarDetalleVenta
    @IdDetalleVenta INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    DECLARE @PrecioUnitario DECIMAL(12,2);
    DECLARE @Subtotal DECIMAL(12,2);
    DECLARE @IdVenta INT;

    IF @IdDetalleVenta IS NULL OR @IdDetalleVenta <= 0
    BEGIN
        PRINT 'El id de detalle de venta es invalido';
        RETURN;
    END

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        PRINT 'El id de producto es invalido';
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        PRINT 'La cantidad es invalida';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleVentas
        WHERE IdDetalleVenta = @IdDetalleVenta
    )
    BEGIN
        PRINT 'No existe un detalle de venta con ese id';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
    )
    BEGIN
        PRINT 'No existe un producto con ese id';
        RETURN;
    END

    SELECT @IdVenta = IdVenta
    FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 0
    )
    BEGIN
        PRINT 'El producto no esta activo';
        RETURN;
    END

    SELECT @PrecioUnitario = PrecioVenta
    FROM Productos
    WHERE IdProducto = @IdProducto;

    SET @Subtotal = @Cantidad * @PrecioUnitario;

    UPDATE DetalleVentas
    SET IdProducto = @IdProducto,
        Cantidad = @Cantidad,
        PrecioUnitario = @PrecioUnitario,
        Subtotal = @Subtotal
    WHERE IdDetalleVenta = @IdDetalleVenta;

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta actualizado';
END;
GO

-- sp_eliminarDetalleVenta: elimina una linea de detalle de venta.
CREATE PROCEDURE sp_eliminarDetalleVenta
    @IdDetalleVenta INT
AS
BEGIN
    DECLARE @IdVenta INT;

    IF @IdDetalleVenta IS NULL OR @IdDetalleVenta <= 0
    BEGIN
        PRINT 'El id de detalle de venta es invalido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM DetalleVentas
        WHERE IdDetalleVenta = @IdDetalleVenta
    )
    BEGIN
        PRINT 'No existe un detalle de venta con ese id';
        RETURN;
    END

    SELECT @IdVenta = IdVenta
    FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    IF EXISTS (
        SELECT 1
        FROM Ventas v
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE v.IdVenta = @IdVenta
          AND UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        PRINT 'No se puede tocar el detalle de una venta confirmada';
        RETURN;
    END

    DELETE FROM DetalleVentas
    WHERE IdDetalleVenta = @IdDetalleVenta;

    UPDATE Ventas
    SET Total = ISNULL((
        SELECT SUM(dv.Subtotal)
        FROM DetalleVentas dv
        WHERE dv.IdVenta = @IdVenta
    ), 0)
    WHERE IdVenta = @IdVenta;

    PRINT 'Detalle de venta eliminado';
END;
GO

-- Categorias

-- SP_Categoria_Registrar
IF OBJECT_ID(N'dbo.SP_Categoria_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Registrar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Registrar
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50041, 'El nombre de la categoria es obligatorio.', 1;

    IF EXISTS (SELECT 1 FROM Categorias WHERE Nombre = LTRIM(RTRIM(@Nombre)))
        THROW 50042, 'Ya existe una categoria con ese nombre.', 1;

    BEGIN TRY
        INSERT INTO Categorias (Nombre, Descripcion, Activo)
        VALUES (
            LTRIM(RTRIM(@Nombre)),
            NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50042, 'Ya existe una categoria con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = SCOPE_IDENTITY();
END;
GO


-- SP_Categoria_Actualizar
IF OBJECT_ID(N'dbo.SP_Categoria_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Actualizar
    @IdCategoria int,
    @Nombre      varchar(100),
    @Descripcion varchar(255) = NULL,
    @Activo      bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        THROW 50041, 'El nombre de la categoria es obligatorio.', 1;

    IF EXISTS (
        SELECT 1 FROM Categorias
        WHERE Nombre = LTRIM(RTRIM(@Nombre))
          AND IdCategoria <> @IdCategoria
    )
        THROW 50042, 'Ya existe otra categoria con ese nombre.', 1;

    BEGIN TRY
        UPDATE Categorias
        SET Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = NULLIF(LTRIM(RTRIM(@Descripcion)), ''),
            Activo      = @Activo
        WHERE IdCategoria = @IdCategoria;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50042, 'Ya existe otra categoria con ese nombre.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO


-- SP_Categoria_Desactivar
IF OBJECT_ID(N'dbo.SP_Categoria_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Desactivar
    @IdCategoria int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    UPDATE Categorias
    SET Activo = 0
    WHERE IdCategoria = @IdCategoria;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO


-- SP_Categoria_Reactivar
IF OBJECT_ID(N'dbo.SP_Categoria_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Categoria_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Categoria_Reactivar
    @IdCategoria int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Categorias WHERE IdCategoria = @IdCategoria)
        THROW 50043, 'La categoria indicada no existe.', 1;

    UPDATE Categorias
    SET Activo = 1
    WHERE IdCategoria = @IdCategoria;

    SELECT IdCategoria, Nombre, Descripcion, Activo
    FROM Categorias
    WHERE IdCategoria = @IdCategoria;
END;
GO

-- Productos

-- SP_Producto_Registrar
IF OBJECT_ID(N'dbo.SP_Producto_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Registrar;
GO

CREATE PROCEDURE dbo.SP_Producto_Registrar
    @IdCategoria     int,
    @IdMarca         int,
    @IdTalle         int,
    @IdColor         int,
    @CodigoProducto  varchar(50),
    @Nombre          varchar(150),
    @Descripcion     varchar(255) = NULL,
    @PrecioVenta     decimal(12,2),
    @StockActual     int = 0,
    @StockMinimo     int = 0
AS
BEGIN
    SET NOCOUNT ON;

    SET @CodigoProducto = LTRIM(RTRIM(@CodigoProducto));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Descripcion = LTRIM(RTRIM(@Descripcion));

    IF @CodigoProducto IS NULL OR @CodigoProducto = ''
        THROW 50061, 'El codigo del producto es obligatorio.', 1;

    IF @Nombre IS NULL OR @Nombre = ''
        THROW 50063, 'El nombre del producto es obligatorio.', 1;

    IF @Descripcion = ''
        SET @Descripcion = NULL;

    IF @PrecioVenta IS NULL OR @PrecioVenta < 0
        THROW 50064, 'El precio de venta es invalido.', 1;

    IF @StockActual IS NULL OR @StockActual < 0
        THROW 50065, 'El stock actual es invalido.', 1;

    IF @StockMinimo IS NULL OR @StockMinimo < 0
        THROW 50065, 'El stock minimo es invalido.', 1;

    IF @IdCategoria IS NULL OR @IdCategoria <= 0
        THROW 50066, 'La categoria indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Categorias
        WHERE IdCategoria = @IdCategoria
          AND Activo = 1
    )
        THROW 50066, 'La categoria indicada no existe o no esta activa.', 1;

    IF @IdMarca IS NULL OR @IdMarca <= 0
        THROW 50067, 'La marca indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE IdMarca = @IdMarca
          AND Activo = 1
    )
        THROW 50067, 'La marca indicada no existe o no esta activa.', 1;

    IF @IdTalle IS NULL OR @IdTalle <= 0
        THROW 50068, 'El talle indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Talles
        WHERE IdTalle = @IdTalle
          AND Activo = 1
    )
        THROW 50068, 'El talle indicado no existe o no esta activo.', 1;

    IF @IdColor IS NULL OR @IdColor <= 0
        THROW 50069, 'El color indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Colores
        WHERE IdColor = @IdColor
          AND Activo = 1
    )
        THROW 50069, 'El color indicado no existe o no esta activo.', 1;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE CodigoProducto = @CodigoProducto
    )
        THROW 50062, 'Ya existe un producto con ese codigo.', 1;

    BEGIN TRY
        INSERT INTO Productos (
            IdCategoria,
            IdMarca,
            IdTalle,
            IdColor,
            CodigoProducto,
            Nombre,
            Descripcion,
            PrecioVenta,
            StockActual,
            StockMinimo,
            Activo
        )
        VALUES (
            @IdCategoria,
            @IdMarca,
            @IdTalle,
            @IdColor,
            @CodigoProducto,
            @Nombre,
            @Descripcion,
            @PrecioVenta,
            @StockActual,
            @StockMinimo,
            1
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50062, 'Ya existe un producto con ese codigo.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = SCOPE_IDENTITY();
END;
GO


-- SP_Producto_AjustarStock
IF OBJECT_ID(N'dbo.SP_Producto_AjustarStock', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_AjustarStock;
GO

CREATE PROCEDURE dbo.SP_Producto_AjustarStock
    @IdProducto int,
    @Operacion varchar(10),
    @Cantidad int,
    @IdEmpleado int = NULL,
    @Motivo varchar(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdTipoMovimientoStock int;
    DECLARE @CantidadAAjustar int;

    SET @Operacion = UPPER(LTRIM(RTRIM(@Operacion)));
    SET @Motivo = LTRIM(RTRIM(@Motivo));

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND Activo = 1
    )
        THROW 50070, 'El producto indicado no existe o no esta activo.', 1;

    IF @Operacion IS NULL OR @Operacion NOT IN ('SUMAR', 'RESTAR')
        THROW 50072, 'La operacion de stock debe ser SUMAR o RESTAR.', 1;

    IF @Cantidad IS NULL OR @Cantidad <= 0
        THROW 50073, 'La cantidad del ajuste debe ser mayor a cero.', 1;

    IF @IdEmpleado IS NOT NULL AND NOT EXISTS (
        SELECT 1
        FROM Empleados
        WHERE IdEmpleado = @IdEmpleado
          AND Activo = 1
    )
        THROW 50074, 'El empleado indicado no existe o no esta activo.', 1;

    IF @Motivo = ''
        SET @Motivo = NULL;

    SET @CantidadAAjustar = CASE
        WHEN @Operacion = 'SUMAR' THEN @Cantidad
        ELSE -@Cantidad
    END;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE IdProducto = @IdProducto
          AND StockActual + @CantidadAAjustar < 0
    )
        THROW 50075, 'El ajuste no puede dejar stock negativo.', 1;

    SELECT @IdTipoMovimientoStock = IdTipoMovimientoStock
    FROM TiposMovimientoStock
    WHERE Nombre = CASE
        WHEN @Operacion = 'SUMAR' THEN 'Ajuste manual'
        ELSE 'Ajuste negativo'
    END;

    IF @IdTipoMovimientoStock IS NULL
        THROW 50076, 'No existe el tipo de movimiento de stock requerido.', 1;

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE Productos
        SET StockActual = StockActual + @CantidadAAjustar
        WHERE IdProducto = @IdProducto;

        INSERT INTO MovimientosStock (
            IdProducto,
            IdTipoMovimientoStock,
            IdEmpleado,
            IdCompra,
            IdVenta,
            FechaMovimiento,
            Cantidad,
            Motivo
        )
        VALUES (
            @IdProducto,
            @IdTipoMovimientoStock,
            @IdEmpleado,
            NULL,
            NULL,
            SYSDATETIME(),
            @Cantidad,
            COALESCE(@Motivo, 'Ajuste manual de stock')
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Actualizar
IF OBJECT_ID(N'dbo.SP_Producto_Actualizar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Actualizar;
GO

CREATE PROCEDURE dbo.SP_Producto_Actualizar
    @IdProducto      int,
    @IdCategoria     int,
    @IdMarca         int,
    @IdTalle         int,
    @IdColor         int,
    @CodigoProducto  varchar(50),
    @Nombre          varchar(150),
    @Descripcion     varchar(255) = NULL,
    @PrecioVenta     decimal(12,2),
    @StockActual     int,
    @StockMinimo     int,
    @Activo          bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @CodigoProducto = LTRIM(RTRIM(@CodigoProducto));
    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Descripcion = LTRIM(RTRIM(@Descripcion));

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    IF @CodigoProducto IS NULL OR @CodigoProducto = ''
        THROW 50061, 'El codigo del producto es obligatorio.', 1;

    IF @Nombre IS NULL OR @Nombre = ''
        THROW 50063, 'El nombre del producto es obligatorio.', 1;

    IF @Descripcion = ''
        SET @Descripcion = NULL;

    IF @PrecioVenta IS NULL OR @PrecioVenta < 0
        THROW 50064, 'El precio de venta es invalido.', 1;

    IF @StockActual IS NULL OR @StockActual < 0
        THROW 50065, 'El stock actual es invalido.', 1;

    IF @StockMinimo IS NULL OR @StockMinimo < 0
        THROW 50065, 'El stock minimo es invalido.', 1;

    IF @IdCategoria IS NULL OR @IdCategoria <= 0
        THROW 50066, 'La categoria indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Categorias
        WHERE IdCategoria = @IdCategoria
          AND Activo = 1
    )
        THROW 50066, 'La categoria indicada no existe o no esta activa.', 1;

    IF @IdMarca IS NULL OR @IdMarca <= 0
        THROW 50067, 'La marca indicada es invalida.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Marcas
        WHERE IdMarca = @IdMarca
          AND Activo = 1
    )
        THROW 50067, 'La marca indicada no existe o no esta activa.', 1;

    IF @IdTalle IS NULL OR @IdTalle <= 0
        THROW 50068, 'El talle indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Talles
        WHERE IdTalle = @IdTalle
          AND Activo = 1
    )
        THROW 50068, 'El talle indicado no existe o no esta activo.', 1;

    IF @IdColor IS NULL OR @IdColor <= 0
        THROW 50069, 'El color indicado es invalido.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM Colores
        WHERE IdColor = @IdColor
          AND Activo = 1
    )
        THROW 50069, 'El color indicado no existe o no esta activo.', 1;

    IF EXISTS (
        SELECT 1
        FROM Productos
        WHERE CodigoProducto = @CodigoProducto
          AND IdProducto <> @IdProducto
    )
        THROW 50062, 'Ya existe otro producto con ese codigo.', 1;

    BEGIN TRY
        UPDATE Productos
        SET IdCategoria    = @IdCategoria,
            IdMarca        = @IdMarca,
            IdTalle        = @IdTalle,
            IdColor        = @IdColor,
            CodigoProducto = @CodigoProducto,
            Nombre         = @Nombre,
            Descripcion    = @Descripcion,
            PrecioVenta    = @PrecioVenta,
            StockActual    = @StockActual,
            StockMinimo    = @StockMinimo,
            Activo         = @Activo
        WHERE IdProducto = @IdProducto;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50062, 'Ya existe otro producto con ese codigo.', 1;
        ELSE
            THROW;
    END CATCH;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Desactivar
IF OBJECT_ID(N'dbo.SP_Producto_Desactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Desactivar;
GO

CREATE PROCEDURE dbo.SP_Producto_Desactivar
    @IdProducto int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    UPDATE Productos
    SET Activo = 0
    WHERE IdProducto = @IdProducto;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO


-- SP_Producto_Reactivar
IF OBJECT_ID(N'dbo.SP_Producto_Reactivar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_Producto_Reactivar;
GO

CREATE PROCEDURE dbo.SP_Producto_Reactivar
    @IdProducto int
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdProducto IS NULL OR @IdProducto <= 0
        THROW 50071, 'El IdProducto es invalido.', 1;

    IF NOT EXISTS (SELECT 1 FROM Productos WHERE IdProducto = @IdProducto)
        THROW 50070, 'El producto indicado no existe.', 1;

    UPDATE Productos
    SET Activo = 1
    WHERE IdProducto = @IdProducto;

    SELECT
        IdProducto,
        IdCategoria,
        IdMarca,
        IdTalle,
        IdColor,
        CodigoProducto,
        Nombre,
        Descripcion,
        PrecioVenta,
        StockActual,
        StockMinimo,
        Activo
    FROM Productos
    WHERE IdProducto = @IdProducto;
END;
GO

SELECT 'Script completo ejecutado correctamente.' AS Resultado;
GO
