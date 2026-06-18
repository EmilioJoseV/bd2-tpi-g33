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

    
        public static DataTable EjecutarConsulta(string sql)
        {
            var tabla = new DataTable();
            using (var conexion = new SqlConnection(CadenaConexion))
            using (var comando = new SqlCommand(sql, conexion))
            using (var adaptador = new SqlDataAdapter(comando))
            {
                adaptador.Fill(tabla);
            }
            return tabla;
        }

        public static DataTable EjecutarProcedimiento(
            string nombreSp,
            params (string Nombre, object Valor)[] parametros)
        {
            var tabla = new DataTable();
            using (var conexion = new SqlConnection(CadenaConexion))
            using (var comando = new SqlCommand(nombreSp, conexion))
            {
                comando.CommandType = CommandType.StoredProcedure;
                foreach (var (nombre, valor) in parametros)
                    comando.Parameters.AddWithValue(nombre, valor);

                using (var adaptador = new SqlDataAdapter(comando))
                    adaptador.Fill(tabla);
            }
            return tabla;
        }

        public static void ProbarConexion()
        {
            using (var conexion = new SqlConnection(CadenaConexion))
            {
                conexion.Open();
            }
        }
    }
}
