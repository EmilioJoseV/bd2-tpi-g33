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
    Nombre varchar(100),
    Descripcion varchar(255),
    Activo bit
);
GO

CREATE TABLE Talles (
    IdTalle int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(20),
    Descripcion varchar(100),
    Activo bit
);
GO

CREATE TABLE Marcas (
    IdMarca int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100),
    Descripcion varchar(255),
    Activo bit
);
GO

CREATE TABLE MediosPago (
    IdMedioPago int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100),
    Activo bit
);
GO

CREATE TABLE EstadosVenta (
    IdEstadoVenta int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE EstadosCompra (
    IdEstadoCompra int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE TiposMovimientoStock (
    IdTipoMovimientoStock int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE Colores (
    IdColor int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50),
    Activo bit
);
GO

CREATE TABLE Proveedores (
    IdProveedor int IDENTITY(1,1) PRIMARY KEY,
    RazonSocial varchar(150),
    CUIT varchar(20),
    Email varchar(150),
    Telefono varchar(30),
    Direccion varchar(200),
    Activo bit
);
GO

CREATE TABLE Clientes (
    IdCliente int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100),
    Nombre varchar(100),
    Documento varchar(20),
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date,
    Activo bit
);
GO

CREATE TABLE Empleados (
    IdEmpleado int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100),
    Nombre varchar(100),
    Documento varchar(20),
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date,
    Activo bit
);
GO

CREATE TABLE Productos (
    IdProducto int IDENTITY(1,1) PRIMARY KEY,
    IdCategoria int,
    IdMarca int,
    IdTalle int,
    IdColor int,
    CodigoProducto varchar(50),
    Nombre varchar(150),
    Descripcion varchar(255),
    PrecioVenta decimal(12,2),
    StockActual int,
    StockMinimo int,
    Activo bit,
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria) REFERENCES Categorias (IdCategoria),
    CONSTRAINT FK_Productos_Marcas FOREIGN KEY (IdMarca) REFERENCES Marcas (IdMarca),
    CONSTRAINT FK_Productos_Talles FOREIGN KEY (IdTalle) REFERENCES Talles (IdTalle),
    CONSTRAINT FK_Productos_Colores FOREIGN KEY (IdColor) REFERENCES Colores (IdColor)
);
GO

CREATE TABLE Compras (
    IdCompra int IDENTITY(1,1) PRIMARY KEY,
    IdProveedor int,
    IdEmpleado int,
    IdEstadoCompra int,
    FechaCompra datetime2,
    NumeroComprobante varchar(50),
    Total decimal(12,2),
    CONSTRAINT FK_Compras_Proveedores FOREIGN KEY (IdProveedor) REFERENCES Proveedores (IdProveedor),
    CONSTRAINT FK_Compras_Empleados FOREIGN KEY (IdEmpleado) REFERENCES Empleados (IdEmpleado),
    CONSTRAINT FK_Compras_EstadosCompra FOREIGN KEY (IdEstadoCompra) REFERENCES EstadosCompra (IdEstadoCompra)
);
GO

CREATE TABLE Ventas (
    IdVenta int IDENTITY(1,1) PRIMARY KEY,
    IdCliente int,
    IdEmpleado int,
    IdMedioPago int,
    IdEstadoVenta int,
    FechaVenta datetime2,
    Total decimal(12,2),
    CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (IdCliente) REFERENCES Clientes (IdCliente),
    CONSTRAINT FK_Ventas_Empleados FOREIGN KEY (IdEmpleado) REFERENCES Empleados (IdEmpleado),
    CONSTRAINT FK_Ventas_MediosPago FOREIGN KEY (IdMedioPago) REFERENCES MediosPago (IdMedioPago),
    CONSTRAINT FK_Ventas_EstadosVenta FOREIGN KEY (IdEstadoVenta) REFERENCES EstadosVenta (IdEstadoVenta)
);
GO

CREATE TABLE DetalleCompras (
    IdDetalleCompra int IDENTITY(1,1) PRIMARY KEY,
    IdCompra int,
    IdProducto int,
    Cantidad int,
    PrecioUnitario decimal(12,2),
    Subtotal decimal(12,2),
    CONSTRAINT FK_DetalleCompras_Compras FOREIGN KEY (IdCompra) REFERENCES Compras (IdCompra),
    CONSTRAINT FK_DetalleCompras_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
);
GO

CREATE TABLE DetalleVentas (
    IdDetalleVenta int IDENTITY(1,1) PRIMARY KEY,
    IdVenta int,
    IdProducto int,
    Cantidad int,
    PrecioUnitario decimal(12,2),
    Subtotal decimal(12,2),
    CONSTRAINT FK_DetalleVentas_Ventas FOREIGN KEY (IdVenta) REFERENCES Ventas (IdVenta),
    CONSTRAINT FK_DetalleVentas_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
);
GO

CREATE TABLE MovimientosStock (
    IdMovimientoStock int IDENTITY(1,1) PRIMARY KEY,
    IdProducto int,
    IdTipoMovimientoStock int,
    IdEmpleado int,
    IdCompra int,
    IdVenta int,
    FechaMovimiento datetime2,
    Cantidad int,
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
