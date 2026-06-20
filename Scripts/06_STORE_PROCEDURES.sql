USE BD2_TPI_TIENDA_INDUMENTARIA;
GO

------------------------------------------------------------------------------------------------
-- #3 - Registrar y administrar proveedores
-- sp_registrarProveedor: da de alta un proveedor y valida que el CUIT no se repita.

CREATE PROCEDURE sp_registrarProveedor
    @RazonSocial VARCHAR(150),
    @CUIT VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200)
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    -- Validar los datos obligatorios antes del insert.
    IF @RazonSocial IS NULL OR @RazonSocial = ''
    BEGIN
        PRINT 'Falta la razon social.';
        RETURN;
    END

    IF @CUIT IS NULL OR @CUIT = ''
    BEGIN
        PRINT 'Falta el CUIT.';
        RETURN;
    END

    -- Si vino vacio en los opcionales, se guarda como NULL.
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
    BEGIN
        PRINT 'Ya existe un proveedor con ese CUIT.';
        RETURN;
    END

    INSERT INTO Proveedores (RazonSocial, CUIT, Email, Telefono, Direccion, Activo)
    VALUES (@RazonSocial, @CUIT, @Email, @Telefono, @Direccion, 1);

    PRINT 'Proveedor registrado.';
END;
GO

-- sp_actualizarProveedor: actualiza los datos principales de un proveedor existente.

CREATE PROCEDURE sp_actualizarProveedor
    @IdProveedor INT,
    @RazonSocial VARCHAR(150),
    @CUIT VARCHAR(20),
    @Email VARCHAR(150),
    @Telefono VARCHAR(30),
    @Direccion VARCHAR(200),
    @Activo BIT
AS
BEGIN
    -- Limpiar espacios en blanco de los campos de texto.
    SET @RazonSocial = LTRIM(RTRIM(@RazonSocial));
    SET @CUIT = LTRIM(RTRIM(@CUIT));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Telefono = LTRIM(RTRIM(@Telefono));
    SET @Direccion = LTRIM(RTRIM(@Direccion));

    -- Validar que el id y los datos obligatorios vengan bien.
    IF @IdProveedor IS NULL OR @IdProveedor <= 0
    BEGIN
        PRINT 'IdProveedor invalido.';
        RETURN;
    END

    IF @RazonSocial IS NULL OR @RazonSocial = ''
    BEGIN
        PRINT 'Falta la razon social.';
        RETURN;
    END

    IF @CUIT IS NULL OR @CUIT = ''
    BEGIN
        PRINT 'Falta el CUIT.';
        RETURN;
    END

    IF @Email = ''
        SET @Email = NULL;

    IF @Telefono = ''
        SET @Telefono = NULL;

    IF @Direccion = ''
        SET @Direccion = NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE IdProveedor = @IdProveedor
    )
    BEGIN
        PRINT 'No existe un proveedor con ese id.';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Proveedores
        WHERE UPPER(CUIT) = UPPER(@CUIT)
          AND IdProveedor <> @IdProveedor
    )
    BEGIN
        PRINT 'Ya existe otro proveedor con ese CUIT.';
        RETURN;
    END

    UPDATE Proveedores
    SET RazonSocial = @RazonSocial,
        CUIT = @CUIT,
        Email = @Email,
        Telefono = @Telefono,
        Direccion = @Direccion,
        Activo = @Activo
    WHERE IdProveedor = @IdProveedor;

    PRINT 'Proveedor actualizado.';
END;
GO

------------------------------------------------------------------------------------------------
-- #5 - Registrar y administrar clientes
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

------------------------------------------------------------------------------------------------
-- #7 - Registrar compras de mercadería realizadas a proveedores
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

------------------------------------------------------------------------------------------------
-- #9 - Detallar los productos incluidos en cada compra y cada venta, indicando cantidad, precio unitario y subtotal
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
------------------------------------------------------------------------------------------------
