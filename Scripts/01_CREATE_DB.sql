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
    Nombre varchar(100) NOT NULL,
    Descripcion varchar(255),
    Activo bit NOT NULL
);
GO

CREATE TABLE Talles (
    IdTalle int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(20) NOT NULL,
    Descripcion varchar(100),
    Activo bit NOT NULL
);
GO

CREATE TABLE Marcas (
    IdMarca int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    Descripcion varchar(255),
    Activo bit NOT NULL
);
GO

CREATE TABLE MediosPago (
    IdMedioPago int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(100) NOT NULL,
    Activo bit NOT NULL
);
GO

CREATE TABLE EstadosVenta (
    IdEstadoVenta int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL,
    Descripcion varchar(255)
);
GO

CREATE TABLE EstadosCompra (
    IdEstadoCompra int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL,
    Descripcion varchar(255)
);
GO

CREATE TABLE TiposMovimientoStock (
    IdTipoMovimientoStock int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL,
    Descripcion varchar(255)
);
GO

CREATE TABLE Colores (
    IdColor int IDENTITY(1,1) PRIMARY KEY,
    Nombre varchar(50) NOT NULL,
    Activo bit NOT NULL
);
GO

CREATE TABLE Proveedores (
    IdProveedor int IDENTITY(1,1) PRIMARY KEY,
    RazonSocial varchar(150) NOT NULL,
    CUIT varchar(20) NOT NULL,
    Email varchar(150),
    Telefono varchar(30),
    Direccion varchar(200),
    Activo bit NOT NULL
);
GO

CREATE TABLE Clientes (
    IdCliente int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100) NOT NULL,
    Nombre varchar(100) NOT NULL,
    Documento varchar(20) NOT NULL,
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date NOT NULL,
    Activo bit NOT NULL
);
GO

CREATE TABLE Empleados (
    IdEmpleado int IDENTITY(1,1) PRIMARY KEY,
    Apellido varchar(100) NOT NULL,
    Nombre varchar(100) NOT NULL,
    Documento varchar(20) NOT NULL,
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date NOT NULL,
    Activo bit NOT NULL
);
GO

CREATE TABLE Productos (
    IdProducto int IDENTITY(1,1) PRIMARY KEY,
    IdCategoria int NOT NULL,
    IdMarca int NOT NULL,
    IdTalle int NOT NULL,
    IdColor int NOT NULL,
    CodigoProducto varchar(50) NOT NULL,
    Nombre varchar(150) NOT NULL,
    Descripcion varchar(255),
    PrecioVenta decimal(12,2) NOT NULL,
    StockActual int NOT NULL,
    StockMinimo int NOT NULL,
    Activo bit NOT NULL,
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
    FechaCompra datetime2 NOT NULL,
    NumeroComprobante varchar(50),
    Total decimal(12,2) NOT NULL,
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
    FechaVenta datetime2 NOT NULL,
    Total decimal(12,2) NOT NULL,
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
    Cantidad int NOT NULL,
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
    Cantidad int NOT NULL,
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
    FechaMovimiento datetime2 NOT NULL,
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
