------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.SP_MovimientoStock_Registrar', N'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_MovimientoStock_Registrar;
GO

CREATE PROCEDURE dbo.SP_MovimientoStock_Registrar
    @IdProducto            INT,
    @IdTipoMovimientoStock INT,
    @IdEmpleado            INT,
    @Cantidad              INT,
    @Motivo                VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StockActual     INT;
    DECLARE @NombreTipo      VARCHAR(50);
    DECLARE @StockResultante INT;

    IF @IdProducto IS NULL OR @IdProducto <= 0
    BEGIN
        RAISERROR('El id de producto es inválido', 16, 1);
        RETURN;
    END

    IF @IdTipoMovimientoStock IS NULL OR @IdTipoMovimientoStock <= 0
    BEGIN
        RAISERROR('El tipo de movimiento es inválido', 16, 1);
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        RAISERROR('El id de empleado es inválido', 16, 1);
        RETURN;
    END

    IF @Cantidad IS NULL OR @Cantidad = 0
    BEGIN
        RAISERROR('La cantidad no puede ser cero ni nula', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Productos WHERE IdProducto = @IdProducto
    )
    BEGIN
        RAISERROR('No existe un producto con ese id', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Productos WHERE IdProducto = @IdProducto AND Activo = 0
    )
    BEGIN
        RAISERROR('El producto no está activo', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM TiposMovimientoStock WHERE IdTipoMovimientoStock = @IdTipoMovimientoStock
    )
    BEGIN
        RAISERROR('No existe un tipo de movimiento con ese id', 16, 1);
        RETURN;
    END

    -- Validar que el empleado exista y esté activo
    IF NOT EXISTS (
        SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado
    )
    BEGIN
        RAISERROR('No existe un empleado con ese id', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Empleados WHERE IdEmpleado = @IdEmpleado AND Activo = 0
    )
    BEGIN
        RAISERROR('El empleado no está activo', 16, 1);
        RETURN;
    END

    SELECT @NombreTipo = UPPER(Nombre)
    FROM TiposMovimientoStock
    WHERE IdTipoMovimientoStock = @IdTipoMovimientoStock;

    IF @NombreTipo IN ('INGRESO POR COMPRA', 'EGRESO POR VENTA')
    BEGIN
        RAISERROR('Ese tipo de movimiento es gestionado automáticamente por el sistema. Use un tipo de ajuste manual.', 16, 1);
        RETURN;
    END

    SELECT @StockActual = StockActual
    FROM Productos
    WHERE IdProducto = @IdProducto;

    -- Calcular el stock resultante.
    -- Cantidad positiva = entrada; negativa = salida.
    SET @StockResultante = @StockActual + @Cantidad;

    -- Validar que el stock no quede negativo
    IF @StockResultante < 0
    BEGIN
        RAISERROR('Stock insuficiente para aplicar el ajuste solicitado', 16, 1);
        RETURN;
    END

    -- Todo validado: registrar el movimiento y actualizar el stock
    BEGIN TRY
        BEGIN TRANSACTION;

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
                NULLIF(LTRIM(RTRIM(@Motivo)), '')
            );

            UPDATE Productos
            SET StockActual = @StockResultante
            WHERE IdProducto = @IdProducto;

        COMMIT;
        PRINT CONCAT(
            'Movimiento registrado. Stock anterior: ', @StockActual,
            ' | Ajuste: ', @Cantidad,
            ' | Stock nuevo: ', @StockResultante
        );
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END;
GO
