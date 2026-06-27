using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormConsultaVentas : Form
    {
        private DateTimePicker _fechaDesde = null!;
        private DateTimePicker _fechaHasta = null!;
        private ComboBox _listaClientes = null!;
        private ComboBox _listaEmpleados = null!;
        private ComboBox _listaMediosPago = null!;
        private Button _botonConsultar = null!;
        private Button _botonCancelar = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormConsultaVentas()
        {
            ConstruirInterfaz();
            CargarClientes();
            CargarEmpleados();
            CargarMediosPago();
        }

        private void ConstruirInterfaz()
        {
            Text = "Consultar ventas";
            Width = 560;
            Height = 300;
            MinimumSize = new Size(560, 300);
            MaximumSize = new Size(560, 300);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var contenedor = CrearContenedor(6);
            _fechaDesde = CrearFecha();
            _fechaHasta = CrearFecha();
            _listaClientes = CrearLista();
            _listaEmpleados = CrearLista();
            _listaMediosPago = CrearLista();

            contenedor.Controls.Add(CrearEtiqueta("Desde"), 0, 0);
            contenedor.Controls.Add(_fechaDesde, 1, 0);
            contenedor.Controls.Add(CrearEtiqueta("Hasta"), 0, 1);
            contenedor.Controls.Add(_fechaHasta, 1, 1);
            contenedor.Controls.Add(CrearEtiqueta("Cliente"), 0, 2);
            contenedor.Controls.Add(_listaClientes, 1, 2);
            contenedor.Controls.Add(CrearEtiqueta("Empleado"), 0, 3);
            contenedor.Controls.Add(_listaEmpleados, 1, 3);
            contenedor.Controls.Add(CrearEtiqueta("Medio pago"), 0, 4);
            contenedor.Controls.Add(_listaMediosPago, 1, 4);

            _botonConsultar = new Button { Text = "Consultar", Width = 105, Height = 30, UseVisualStyleBackColor = true };
            _botonConsultar.Click += BtnConsultar_Click;
            _botonCancelar = new Button { Text = "Cancelar", Width = 105, Height = 30, DialogResult = DialogResult.Cancel, UseVisualStyleBackColor = true };

            var panelBotones = CrearPanelBotones();
            panelBotones.Controls.Add(_botonConsultar);
            panelBotones.Controls.Add(_botonCancelar);
            contenedor.Controls.Add(panelBotones, 0, 5);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConsultar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarClientes()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdCliente, Apellido + ', ' + Nombre AS NombreCompleto FROM Clientes ORDER BY Apellido, Nombre");
            AgregarOpcionTodos(datos, "IdCliente", "NombreCompleto");
            ConfigurarLista(_listaClientes, datos, "NombreCompleto", "IdCliente");
        }

        private void CargarEmpleados()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdEmpleado, Apellido + ', ' + Nombre AS NombreCompleto FROM Empleados ORDER BY Apellido, Nombre");
            AgregarOpcionTodos(datos, "IdEmpleado", "NombreCompleto");
            ConfigurarLista(_listaEmpleados, datos, "NombreCompleto", "IdEmpleado");
        }

        private void CargarMediosPago()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdMedioPago, Nombre FROM MediosPago ORDER BY Nombre");
            AgregarOpcionTodos(datos, "IdMedioPago", "Nombre");
            ConfigurarLista(_listaMediosPago, datos, "Nombre", "IdMedioPago");
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
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Venta_Consultar",
                    ("@FechaDesde", _fechaDesde.Checked ? (object)_fechaDesde.Value.Date : DBNull.Value),
                    ("@FechaHasta", _fechaHasta.Checked ? (object)_fechaHasta.Value.Date : DBNull.Value),
                    ("@IdCliente", IdSeleccionado(_listaClientes)),
                    ("@IdEmpleado", IdSeleccionado(_listaEmpleados)),
                    ("@IdMedioPago", IdSeleccionado(_listaMediosPago)));

                MensajeResultado = $"{Resultado.Rows.Count} venta(s) encontrada(s).";
                DialogResult = DialogResult.OK;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error de base de datos", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static object IdSeleccionado(ComboBox lista)
        {
            int id = Convert.ToInt32(lista.SelectedValue);
            return id == 0 ? DBNull.Value : (object)id;
        }

        private static void AgregarOpcionTodos(DataTable datos, string columnaId, string columnaTexto)
        {
            DataRow fila = datos.NewRow();
            fila[columnaId] = 0;
            fila[columnaTexto] = "Todos";
            datos.Rows.InsertAt(fila, 0);
        }

        private static void ConfigurarLista(ComboBox lista, DataTable datos, string displayMember, string valueMember)
        {
            ComboBusqueda.Configurar(lista, datos, valueMember, displayMember);
            lista.SelectedIndex = 0;
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
