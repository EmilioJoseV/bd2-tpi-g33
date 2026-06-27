using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormConsultaCompras : Form
    {
        private DateTimePicker _fechaDesde = null!;
        private DateTimePicker _fechaHasta = null!;
        private ComboBox _listaProveedores = null!;
        private Button _botonConsultar = null!;
        private Button _botonCancelar = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormConsultaCompras()
        {
            ConstruirInterfaz();
            CargarProveedores();
        }

        private void ConstruirInterfaz()
        {
            Text = "Consultar compras";
            Width = 540;
            Height = 230;
            MinimumSize = new Size(540, 230);
            MaximumSize = new Size(540, 230);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var contenedor = CrearContenedor(4);
            _fechaDesde = CrearFecha();
            _fechaHasta = CrearFecha();
            _listaProveedores = CrearLista();

            contenedor.Controls.Add(CrearEtiqueta("Desde"), 0, 0);
            contenedor.Controls.Add(_fechaDesde, 1, 0);
            contenedor.Controls.Add(CrearEtiqueta("Hasta"), 0, 1);
            contenedor.Controls.Add(_fechaHasta, 1, 1);
            contenedor.Controls.Add(CrearEtiqueta("Proveedor"), 0, 2);
            contenedor.Controls.Add(_listaProveedores, 1, 2);

            _botonConsultar = new Button { Text = "Consultar", Width = 105, Height = 30, UseVisualStyleBackColor = true };
            _botonConsultar.Click += BtnConsultar_Click;
            _botonCancelar = new Button { Text = "Cancelar", Width = 105, Height = 30, DialogResult = DialogResult.Cancel, UseVisualStyleBackColor = true };

            var panelBotones = CrearPanelBotones();
            panelBotones.Controls.Add(_botonConsultar);
            panelBotones.Controls.Add(_botonCancelar);
            contenedor.Controls.Add(panelBotones, 0, 3);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConsultar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarProveedores()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdProveedor, RazonSocial FROM Proveedores ORDER BY RazonSocial");

            DataRow fila = datos.NewRow();
            fila["IdProveedor"] = 0;
            fila["RazonSocial"] = "Todos";
            datos.Rows.InsertAt(fila, 0);

            ComboBusqueda.Configurar(_listaProveedores, datos, "IdProveedor", "RazonSocial");
            _listaProveedores.SelectedIndex = 0;
        }

        private void BtnConsultar_Click(object? sender, EventArgs e)
        {
            if (_fechaDesde.Checked && _fechaHasta.Checked && _fechaDesde.Value.Date > _fechaHasta.Value.Date)
            {
                MostrarDatoInvalido(_fechaHasta, "La fecha hasta no puede ser anterior a la fecha desde.");
                return;
            }

            try
            {
                int idProveedor = Convert.ToInt32(_listaProveedores.SelectedValue);
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Compra_Consultar",
                    ("@FechaDesde", _fechaDesde.Checked ? (object)_fechaDesde.Value.Date : DBNull.Value),
                    ("@FechaHasta", _fechaHasta.Checked ? (object)_fechaHasta.Value.Date : DBNull.Value),
                    ("@IdProveedor", idProveedor == 0 ? DBNull.Value : (object)idProveedor));

                MensajeResultado = $"{Resultado.Rows.Count} compra(s) encontrada(s).";
                DialogResult = DialogResult.OK;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error de base de datos", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static TableLayoutPanel CrearContenedor(int filas)
        {
            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(16),
                ColumnCount = 2,
                RowCount = filas
            };
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            for (int i = 0; i < filas - 1; i++)
                contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            return contenedor;
        }

        private static DateTimePicker CrearFecha()
        {
            return new DateTimePicker
            {
                Dock = DockStyle.Fill,
                Format = DateTimePickerFormat.Short,
                ShowCheckBox = true,
                Checked = false,
                Margin = new Padding(0, 4, 0, 4)
            };
        }

        private static ComboBox CrearLista()
        {
            return new ComboBox
            {
                Dock = DockStyle.Fill,
                DropDownStyle = ComboBoxStyle.DropDownList,
                Margin = new Padding(0, 4, 0, 4)
            };
        }

        private static Label CrearEtiqueta(string texto)
        {
            return new Label { Text = texto, Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleLeft };
        }

        private static FlowLayoutPanel CrearPanelBotones()
        {
            return new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.RightToLeft,
                WrapContents = false,
                Margin = new Padding(0, 12, 0, 0)
            };
        }

        private static void MostrarDatoInvalido(Control control, string mensaje)
        {
            MessageBox.Show(mensaje, "Dato invalido", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            control.Focus();
        }
    }
}
