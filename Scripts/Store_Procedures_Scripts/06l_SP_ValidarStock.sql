CREATE PROCEDURE sp_confirmarVenta
    @IdVenta    INT,
    @IdEmpleado INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoConfirmada INT;
    DECLARE @NombreEstadoActual VARCHAR(50);

    IF @IdVenta IS NULL OR @IdVenta <= 0
    BEGIN
        RAISERROR('El id de venta es inválido', 16, 1);
        RETURN;
    END

    IF @IdEmpleado IS NULL OR @IdEmpleado <= 0
    BEGIN
        RAISERROR('El id de empleado es inválido', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Ventas WHERE IdVenta = @IdVenta
    )
    BEGIN
        RAISERROR('No existe una venta con ese id', 16, 1);
        RETURN;
    END

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

    SELECT @NombreEstadoActual = UPPER(ev.Nombre)
    FROM Ventas v
    INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
    WHERE v.IdVenta = @IdVenta;

    IF @NombreEstadoActual = 'CONFIRMADA'
    BEGIN
        RAISERROR('La venta ya se encuentra confirmada', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM DetalleVentas WHERE IdVenta = @IdVenta
    )
    BEGIN
        RAISERROR('No se puede confirmar una venta sin detalle de productos', 16, 1);
        RETURN;
    END

    SELECT @IdEstadoConfirmada = IdEstadoVenta
    FROM EstadosVenta
    WHERE UPPER(Nombre) = 'CONFIRMADA';

    IF @IdEstadoConfirmada IS NULL
    BEGIN
        RAISERROR('No existe el estado CONFIRMADA en la base de datos', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

            IF EXISTS (
                SELECT 1
                FROM DetalleVentas dv
                INNER JOIN Productos p ON p.IdProducto = dv.IdProducto
                WHERE dv.IdVenta = @IdVenta
                  AND p.StockActual < dv.Cantidad
            )
            BEGIN
                RAISERROR('Stock insuficiente en uno o más productos. La venta no puede confirmarse.', 16, 1);
            END

            UPDATE Ventas
            SET IdEstadoVenta = @IdEstadoConfirmada,
                IdEmpleado    = @IdEmpleado
            WHERE IdVenta = @IdVenta;

        COMMIT;
        PRINT CONCAT('Venta #', @IdVenta, ' confirmada correctamente. Stock actualizado.');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH;
END;
GO

CREATE TRIGGER trg_validarStockAnteDetalleVenta
ON DetalleVentas
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Ventas v        ON v.IdVenta        = i.IdVenta
        INNER JOIN EstadosVenta ev ON ev.IdEstadoVenta = v.IdEstadoVenta
        WHERE UPPER(ev.Nombre) = 'CONFIRMADA'
    )
    BEGIN
        RAISERROR('No se puede modificar el detalle de una venta ya confirmada', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Productos p ON p.IdProducto = i.IdProducto
        WHERE p.StockActual < i.Cantidad
    )
    BEGIN
        RAISERROR('Stock insuficiente en uno o más productos del detalle de venta', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
