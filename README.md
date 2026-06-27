# Explicación del sistema

Se desarrolló un sistema de base de datos orientado a la gestión de inventario
y ventas de una tienda del tipo minorista de indumentaria con la finalidad de
almacenar, gestionar la información principal del negocio y controlar los
productos disponibles, las compras a proveedores así como también las ventas
efectuadas a clientes y movimientos de stocks generados por operaciones.

El diseño de la base de datos permite almacenar información de forma
consistente y confiable de productos, categorías, proveedores, clientes,
empleados, compras, ventas, medios de pago, movimientos de inventario,
para que de esta forma la tienda pueda registrar los ingresos de la
mercadería, controlar las salidas de las mismas a través de ventas, consultar
stock en tiempo real de cada producto, así como también detectar cuando un
artículo está cerca de la reposición.

Como procesos principales el sistema está enfocado en operaciones como la
compra de productos a proveedores y venta de los mismos a clientes. Cada
compra va permitir registrar qué proveedor entregó la mercadería, como
también que empleado cargo la operación, que productos ingresaron a stock.

También permite que una venta pueda registrar a un cliente, conocer el
empleado responsable de las operaciones, el medio de pago utilizado, y
detalles de productos vendidos.

Como procesos secundarios pero no menos importantes, se permitirá
conservar trazabilidad sobre el inventario, como las modificaciones de stock
que permitirá registrar un movimiento que ayudará a conocer si se trata de
una entrada por compra, salida por venta o un ajuste manual, como también
consultar el historial de movimiento de cada producto y validar la fluctuación
del stock a lo largo de los datos registrados en el tiempo.

## Funcionalidades principales

El usuario tendrá la posibilidad de:

- Registrar y administrar productos de la tienda.
- Clasificar los productos por categorías.
- Registrar proveedores y mantener sus datos de contacto.
- Registrar clientes para asociarlos a las ventas realizadas.
- Registrar empleados responsables de cargar compras, ventas y movimientos
de stock.
- Registrar compras de mercadería realizadas a proveedores.
- Detallar los productos incluidos en cada compra y cada venta, indicando
cantidad, precio unitario y subtotal.
- Registrar ventas realizadas a clientes.
- Asociar cada venta con un medio de pago.
- Controlar el stock actual de cada producto.
- Aumentar automáticamente el stock cuando se registra una compra a un
proveedor.
- Disminuir automáticamente el stock cuando se registra una venta a un cliente.
- Registrar movimientos de stock por entradas, salidas o ajustes manuales.
- Consultar el historial de movimientos de stock de cada producto.
- Detectar productos cuyo stock se encuentra por debajo del mínimo definido.
- Consultar ventas realizadas por fecha, cliente, empleado o medio de pago.
- Consultar compras realizadas por proveedor o período.
- Obtener reportes de productos más vendidos.
- Obtener reportes de ventas mensuales.
- Calcular el valor total del inventario disponible.
- Validar operaciones críticas, como evitar ventas sin stock suficiente.

Notas:
- Para ejecutar todos los scripts TSQL en SQL Server ejecutar el comando en Powershell: 'sqlcmd -S . -E -i "Scripts\00_EJECUTAR_TODO.sql"'

## Integrantes

Emilio Vera, Francisco Garcia, Jesus Farias
