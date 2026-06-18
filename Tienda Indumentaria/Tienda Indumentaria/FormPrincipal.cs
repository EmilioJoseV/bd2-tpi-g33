using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    /// <summary>
    /// Pantalla principal. Tiene un combo para elegir qué consultar,
    /// un botón para ejecutar, y una grilla donde se muestran los datos.
    ///
    /// Para agregar una vista/consulta nueva: sumar una entrada en el combo
    /// (método CargarOpciones) y manejar su caso en el botón (BtnEjecutar_Click).
    /// La idea es que toda la lógica de datos viva en consultas/objetos de la base,
    /// y la app solo los invoque.
    /// </summary>
    public class FormPrincipal : Form
    {
        private ComboBox _comboConsultas = null!;
        private Button _botonEjecutar = null!;
        private DataGridView _grilla = null!;
        private Label _etiquetaEstado = null!;

        public FormPrincipal()
        {
            ConstruirInterfaz();
            CargarOpciones();
        }

        private void ConstruirInterfaz()
        {
            Text = "Tienda de Indumentaria - Demo BD2";
            Width = 900;
            Height = 600;
            StartPosition = FormStartPosition.CenterScreen;

            var etiquetaTitulo = new Label
            {
                Text = "Seleccione una consulta:",
                Left = 15,
                Top = 18,
                Width = 160,
                AutoSize = true
            };

            _comboConsultas = new ComboBox
            {
                Left = 180,
                Top = 14,
                Width = 400,
                Height = 28,
                DropDownStyle = ComboBoxStyle.DropDownList
            };

            _botonEjecutar = new Button
            {
                Text = "Ejecutar",
                Left = 600,
                Top = 13,
                Width = 100,
                Height = 30,
                UseVisualStyleBackColor = true
            };
            _botonEjecutar.Click += BtnEjecutar_Click;

            _grilla = new DataGridView
            {
                Left = 15,
                Top = 55,
                Width = 855,
                Height = 460,
                Anchor = AnchorStyles.Top | AnchorStyles.Bottom
                       | AnchorStyles.Left | AnchorStyles.Right,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect
            };

            _etiquetaEstado = new Label
            {
                Left = 15,
                Top = 525,
                Width = 855,
                Height = 20,
                Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right,
                ForeColor = Color.DimGray
            };

            Controls.Add(etiquetaTitulo);
            Controls.Add(_comboConsultas);
            Controls.Add(_botonEjecutar);
            Controls.Add(_grilla);
            Controls.Add(_etiquetaEstado);
        }

        /// <summary>
        /// Las opciones del combo. Cada item tiene un texto visible y la
        /// consulta SQL (o nombre de SP) que se ejecuta.
        /// Cuando tengan sus vistas reales, reemplazar estos ejemplos.
        /// </summary>
        private void CargarOpciones()
        {
            _comboConsultas.Items.Add(new OpcionConsulta(
                "Productos (tabla completa)",
                "SELECT * FROM Productos"));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Clientes activos",
                "SELECT IdCliente, Apellido, Nombre, Documento " +
                "FROM Clientes WHERE Activo = 1"));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Últimas ventas",
                "SELECT TOP (50) IdVenta, IdCliente, FechaVenta, Total " +
                "FROM Ventas ORDER BY FechaVenta DESC"));

            // Ejemplo de cómo quedaría una vista propia una vez creada:
            // _comboConsultas.Items.Add(new OpcionConsulta(
            //     "Reporte: stock bajo mínimo",
            //     "SELECT * FROM VW_ProductosBajoStock"));

            if (_comboConsultas.Items.Count > 0)
                _comboConsultas.SelectedIndex = 0;
        }

        private void BtnEjecutar_Click(object? sender, EventArgs e)
        {
            if (_comboConsultas.SelectedItem is not OpcionConsulta opcion)
                return;

            try
            {
                DataTable datos = Conexion.EjecutarConsulta(opcion.Sql);
                _grilla.DataSource = datos;
                _etiquetaEstado.Text = $"{datos.Rows.Count} fila(s) devuelta(s).";
            }
            catch (Exception ex)
            {
                _etiquetaEstado.Text = "Error al ejecutar la consulta.";
                MessageBox.Show(
                    ex.Message,
                    "Error de base de datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        /// <summary>
        /// Representa una opción del combo: lo que ve el usuario + el SQL a correr.
        /// </summary>
        private sealed class OpcionConsulta
        {
            public string Texto { get; }
            public string Sql { get; }

            public OpcionConsulta(string texto, string sql)
            {
                Texto = texto;
                Sql = sql;
            }

            // El combo muestra esto como texto del item.
            public override string ToString() => Texto;
        }
    }
}
