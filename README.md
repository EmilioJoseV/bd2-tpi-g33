# Explicacion del sistema de gestion de inventario y ventas de una tienda del tipo minorista de indumentaria

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
1. Clasificar los productos por categorías.
2. Asociar cada venta con un medio de pago.
3. Registrar y administrar proveedores.
4. Registrar y administrar productos de la tienda.
5. Registrar y administrar clientes para asociarlos a las ventas realizadas.
6. Registrar y administrar empleados responsables de cargar compras, ventas y movimientos de stock.
7. Registrar y administrar compras de mercadería realizadas a proveedores.
8. Registrar y administrar ventas realizadas a clientes.
9. Detallar los productos incluidos en cada compra y cada venta, indicando cantidad, precio unitario y subtotal.
10. Registrar movimientos de stock por entradas, salidas o ajustes manuales.
11. Validar operaciones críticas, como evitar ventas sin stock suficiente.
12. Aumentar automáticamente el stock cuando se registra una compra a un proveedor.
13. Disminuir automáticamente el stock cuando se registra una venta a un cliente.
14. Consultar el historial de movimientos de stock de cada producto.
15. Detectar productos cuyo stock se encuentra por debajo del mínimo definido.
16. Consultar ventas realizadas por fecha, cliente, empleado o medio de pago.
17. Consultar compras realizadas por proveedor o período.
18. Obtener reportes de productos más vendidos.
19. Obtener reportes de ventas mensuales.
20. Controlar el stock actual de cada producto.
21. Calcular el valor total del inventario disponible.

## Integrantes
Emilio Vera, Francisco Garcia, Jesus Farias
