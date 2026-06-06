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
    IdCategoria int IDENTITY(1,1),
    Nombre varchar(100),
    Descripcion varchar(255),
    Activo bit
);
GO

CREATE TABLE Talles (
    IdTalle int IDENTITY(1,1),
    Nombre varchar(20),
    Descripcion varchar(100),
    Activo bit
);
GO

CREATE TABLE Marcas (
    IdMarca int IDENTITY(1,1),
    Nombre varchar(100),
    Descripcion varchar(255),
    Activo bit
);
GO

CREATE TABLE MediosPago (
    IdMedioPago int IDENTITY(1,1),
    Nombre varchar(100),
    Activo bit
);
GO

CREATE TABLE EstadosVenta (
    IdEstadoVenta int IDENTITY(1,1),
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE EstadosCompra (
    IdEstadoCompra int IDENTITY(1,1),
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE TiposMovimientoStock (
    IdTipoMovimientoStock int IDENTITY(1,1),
    Nombre varchar(50),
    Descripcion varchar(255)
);
GO

CREATE TABLE Colores (
    IdColor int IDENTITY(1,1),
    Nombre varchar(50),
    Activo bit
);
GO

CREATE TABLE Proveedores (
    IdProveedor int IDENTITY(1,1),
    RazonSocial varchar(150),
    CUIT varchar(20),
    Email varchar(150),
    Telefono varchar(30),
    Direccion varchar(200),
    Activo bit
);
GO

CREATE TABLE Clientes (
    IdCliente int IDENTITY(1,1),
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
    IdProducto int IDENTITY(1,1),
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
    Activo bit
);
GO

CREATE TABLE Compras (
    IdCompra int IDENTITY(1,1),
    IdProveedor int,
    IdEmpleado int,
    IdEstadoCompra int,
    FechaCompra datetime2,
    NumeroComprobante varchar(50),
    Total decimal(12,2)
);
GO

CREATE TABLE DetalleCompras (
    IdDetalleCompra int IDENTITY(1,1),
    IdCompra int,
    IdProducto int,
    Cantidad int,
    PrecioUnitario decimal(12,2),
    Subtotal decimal(12,2)
);
GO

CREATE TABLE Ventas (
    IdVenta int IDENTITY(1,1),
    IdCliente int,
    IdEmpleado int,
    IdMedioPago int,
    IdEstadoVenta int,
    FechaVenta datetime2,
    Total decimal(12,2)
);
GO

CREATE TABLE DetalleVentas (
    IdDetalleVenta int IDENTITY(1,1),
    IdVenta int,
    IdProducto int,
    Cantidad int,
    PrecioUnitario decimal(12,2),
    Subtotal decimal(12,2)
);
GO

CREATE TABLE MovimientosStock (
    IdMovimientoStock int IDENTITY(1,1),
    IdProducto int,
    IdTipoMovimientoStock int,
    IdEmpleado int,
    IdCompra int,
    IdVenta int,
    FechaMovimiento datetime2,
    Cantidad int,
    Motivo varchar(255)
);
GO

CREATE TABLE Empleados (
    IdEmpleado int IDENTITY(1,1),
    Apellido varchar(100),
    Nombre varchar(100),
    Documento varchar(20),
    Email varchar(150),
    Telefono varchar(30),
    FechaAlta date,
    Activo bit
);
GO

SELECT 'BD creada OK...' AS Resultado;
GO
