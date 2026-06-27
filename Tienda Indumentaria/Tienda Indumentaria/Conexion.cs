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
                EjecutarSpEnTransaccion(
                    conexion,
                    transaccion,
                    "sp_registrarCompra",
                    ("@IdProveedor", idProveedor),
                    ("@IdEmpleado", idEmpleado),
                    ("@NumeroComprobante", (object?)numeroComprobante ?? DBNull.Value),
                    ("@Total", total));

                ValidarMensajeSp(mensajesSp, "Compra registrada");
                mensajesSp.Clear();

                int idCompra = ObtenerEscalarInt(
                    conexion,
                    transaccion,
                    "SELECT TOP 1 IdCompra FROM Compras " +
                    "WHERE IdProveedor = @IdProveedor AND IdEmpleado = @IdEmpleado AND Total = @Total " +
                    "ORDER BY IdCompra DESC",
                    ("@IdProveedor", idProveedor),
                    ("@IdEmpleado", idEmpleado),
                    ("@Total", total));

                foreach ((int idProducto, int cantidad, decimal precioUnitario) in detalles)
                {
                    EjecutarSpEnTransaccion(
                        conexion,
                        transaccion,
                        "sp_registrarDetalleCompra",
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
