using System.Data;
using Microsoft.Data.SqlClient;

namespace TiendaIndumentaria.App
{

    public static class Conexion
    {
    
        private const string CadenaConexion =
            @"Server=localhost;" +
            @"Database=BD2_TPI_TIENDA_INDUMENTARIA;" +
            @"Trusted_Connection=True;" +
            @"TrustServerCertificate=True;";

    
        public static DataTable EjecutarConsulta(
            string sql,
            params (string Nombre, object? Valor)[] parametros)
        {
            var tabla = new DataTable();
            using (var conexion = new SqlConnection(CadenaConexion))
            using (var comando = new SqlCommand(sql, conexion))
            using (var adaptador = new SqlDataAdapter(comando))
            {
                foreach (var (nombre, valor) in parametros)
                    comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

                adaptador.Fill(tabla);
            }
            return tabla;
        }

        public static DataTable EjecutarProcedimiento(
            string nombreSp,
            params (string Nombre, object? Valor)[] parametros)
        {
            var tabla = new DataTable();
            using (var conexion = new SqlConnection(CadenaConexion))
            using (var comando = new SqlCommand(nombreSp, conexion))
            {
                comando.CommandType = CommandType.StoredProcedure;
                foreach (var (nombre, valor) in parametros)
                    comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

                using (var adaptador = new SqlDataAdapter(comando))
                    adaptador.Fill(tabla);
            }
            return tabla;
        }

        public static DataTable EjecutarProcedimientoConValidacion(
            string nombreSp,
            string mensajeExito,
            params (string Nombre, object? Valor)[] parametros)
        {
            var tabla = new DataTable();
            var mensajesSp = new List<string>();
            using (var conexion = new SqlConnection(CadenaConexion))
            using (var comando = new SqlCommand(nombreSp, conexion))
            {
                conexion.InfoMessage += (_, e) =>
                {
                    if (!string.IsNullOrWhiteSpace(e.Message))
                        mensajesSp.Add(e.Message);
                };

                comando.CommandType = CommandType.StoredProcedure;
                foreach (var (nombre, valor) in parametros)
                    comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

                conexion.Open();
                using (var adaptador = new SqlDataAdapter(comando))
                    adaptador.Fill(tabla);
            }

            ValidarMensajeSp(mensajesSp, mensajeExito);
            return tabla;
        }

        public static DataTable RegistrarCompraConDetalle(
            int idProveedor,
            int idEmpleado,
            string? numeroComprobante,
            decimal total,
            IReadOnlyList<(int IdProducto, int Cantidad, decimal PrecioUnitario)> detalles)
        {
            using var conexion = new SqlConnection(CadenaConexion);
            var mensajesSp = new List<string>();
            conexion.InfoMessage += (_, e) =>
            {
                if (!string.IsNullOrWhiteSpace(e.Message))
                    mensajesSp.Add(e.Message);
            };

            conexion.Open();
            using var transaccion = conexion.BeginTransaction();
            try
            {
                DataTable compra = EjecutarSpTablaEnTransaccion(
                    conexion,
                    transaccion,
                    "SP_Compra_Registrar",
                    ("@IdProveedor", idProveedor),
                    ("@IdEmpleado", idEmpleado),
                    ("@NumeroComprobante", (object?)numeroComprobante ?? DBNull.Value),
                    ("@Total", total));

                ValidarMensajeSp(mensajesSp, "Compra registrada");
                mensajesSp.Clear();

                if (compra.Rows.Count == 0)
                    throw new InvalidOperationException("No se pudo obtener la compra registrada.");

                int idCompra = Convert.ToInt32(compra.Rows[0]["IdCompra"]);

                foreach ((int idProducto, int cantidad, decimal precioUnitario) in detalles)
                {
                    EjecutarSpEnTransaccion(
                        conexion,
                        transaccion,
                        "SP_DetalleCompra_Registrar",
                        ("@IdCompra", idCompra),
                        ("@IdProducto", idProducto),
                        ("@Cantidad", cantidad),
                        ("@PrecioUnitario", precioUnitario));

                    ValidarMensajeSp(mensajesSp, "Detalle de compra registrado");
                    mensajesSp.Clear();
                }

                transaccion.Commit();

                return EjecutarConsultaEnConexion(
                    conexion,
                    "SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total " +
                    "FROM Compras WHERE IdCompra = @IdCompra",
                    ("@IdCompra", idCompra));
            }
            catch
            {
                transaccion.Rollback();
                throw;
            }
        }

        public static DataTable RegistrarVentaConDetalle(
            int idCliente,
            int idEmpleado,
            int idMedioPago,
            IReadOnlyList<(int IdProducto, int Cantidad)> detalles)
        {
            using var conexion = new SqlConnection(CadenaConexion);
            var mensajesSp = new List<string>();
            conexion.InfoMessage += (_, e) =>
            {
                if (!string.IsNullOrWhiteSpace(e.Message))
                    mensajesSp.Add(e.Message);
            };

            conexion.Open();
            using var transaccion = conexion.BeginTransaction();
            try
            {
                DataTable venta = EjecutarSpTablaEnTransaccion(
                    conexion,
                    transaccion,
                    "SP_Venta_Registrar",
                    ("@IdCliente", idCliente),
                    ("@IdEmpleado", idEmpleado),
                    ("@IdMedioPago", idMedioPago));

                if (venta.Rows.Count == 0)
                    throw new InvalidOperationException("No se pudo obtener la venta registrada.");

                int idVenta = Convert.ToInt32(venta.Rows[0]["IdVenta"]);
                mensajesSp.Clear();

                foreach ((int idProducto, int cantidad) in detalles)
                {
                    EjecutarSpEnTransaccion(
                        conexion,
                        transaccion,
                        "SP_DetalleVenta_Registrar",
                        ("@IdVenta", idVenta),
                        ("@IdProducto", idProducto),
                        ("@Cantidad", cantidad));

                    ValidarMensajeSp(mensajesSp, "Detalle de venta registrado");
                    mensajesSp.Clear();
                }

                transaccion.Commit();

                return EjecutarConsultaEnConexion(
                    conexion,
                    "SELECT IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total " +
                    "FROM Ventas WHERE IdVenta = @IdVenta",
                    ("@IdVenta", idVenta));
            }
            catch
            {
                transaccion.Rollback();
                throw;
            }
        }

        public static void ProbarConexion()
        {
            using (var conexion = new SqlConnection(CadenaConexion))
            {
                conexion.Open();
            }
        }

        private static void EjecutarSpEnTransaccion(
            SqlConnection conexion,
            SqlTransaction transaccion,
            string nombreSp,
            params (string Nombre, object? Valor)[] parametros)
        {
            using var comando = new SqlCommand(nombreSp, conexion, transaccion)
            {
                CommandType = CommandType.StoredProcedure
            };

            foreach (var (nombre, valor) in parametros)
                comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

            comando.ExecuteNonQuery();
        }

        private static DataTable EjecutarSpTablaEnTransaccion(
            SqlConnection conexion,
            SqlTransaction transaccion,
            string nombreSp,
            params (string Nombre, object? Valor)[] parametros)
        {
            var tabla = new DataTable();
            using var comando = new SqlCommand(nombreSp, conexion, transaccion)
            {
                CommandType = CommandType.StoredProcedure
            };

            foreach (var (nombre, valor) in parametros)
                comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

            using var adaptador = new SqlDataAdapter(comando);
            adaptador.Fill(tabla);
            return tabla;
        }

        private static int ObtenerEscalarInt(
            SqlConnection conexion,
            SqlTransaction transaccion,
            string sql,
            params (string Nombre, object? Valor)[] parametros)
        {
            using var comando = new SqlCommand(sql, conexion, transaccion);
            foreach (var (nombre, valor) in parametros)
                comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

            object? resultado = comando.ExecuteScalar();
            if (resultado == null || resultado == DBNull.Value)
                throw new InvalidOperationException("No se pudo obtener el identificador de la compra registrada.");

            return Convert.ToInt32(resultado);
        }

        private static DataTable EjecutarConsultaEnConexion(
            SqlConnection conexion,
            string sql,
            params (string Nombre, object? Valor)[] parametros)
        {
            var tabla = new DataTable();
            using var comando = new SqlCommand(sql, conexion);
            foreach (var (nombre, valor) in parametros)
                comando.Parameters.AddWithValue(nombre, valor ?? DBNull.Value);

            using var adaptador = new SqlDataAdapter(comando);
            adaptador.Fill(tabla);
            return tabla;
        }

        private static void ValidarMensajeSp(IReadOnlyList<string> mensajes, string mensajeExito)
        {
            if (mensajes.Any(m => m.Contains(mensajeExito, StringComparison.OrdinalIgnoreCase)))
                return;

            string detalle = mensajes.LastOrDefault(m => !string.IsNullOrWhiteSpace(m)) ?? string.Empty;
            throw new InvalidOperationException(
                string.IsNullOrWhiteSpace(detalle)
                    ? "La operacion no se completo en la base de datos."
                    : detalle);
        }
    }
}
