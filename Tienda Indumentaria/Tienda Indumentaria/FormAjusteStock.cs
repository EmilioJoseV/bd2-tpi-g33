using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormAjusteStock : Form
    {
        private ComboBox _listaProductos = null!;
        private ComboBox _listaEmpleados = null!;
        private RadioButton _opcionSumar = null!;
        private RadioButton _opcionRestar = null!;
        private TextBox _textoCantidad = null!;
        private TextBox _textoMotivo = null!;
        private Button _botonConfirmar = null!;
        private Button _botonCancelar = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormAjusteStock()
        {
            ConstruirInterfaz();
            CargarProductos();
            CargarEmpleados();
        }

        private void ConstruirInterfaz()
        {
            Text = "Ajustar stock";
            Width = 560;
            Height = 330;
            MinimumSize = new Size(560, 330);
            MaximumSize = new Size(560, 330);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(16),
                ColumnCount = 2,
                RowCount = 6
            };
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 145));
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

            for (int i = 0; i < 5; i++)
                contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            _listaProductos = CrearLista();
            _listaEmpleados = CrearLista();
            _textoCantidad = CrearTexto();
            _textoMotivo = CrearTexto();

            var panelOperacion = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.LeftToRight,
                WrapContents = false,
                Margin = new Padding(0, 4, 0, 4)
            };

            _opcionSumar = new RadioButton
            {
                Text = "Sumar",
                Checked = true,
                AutoSize = true,
                Margin = new Padding(0, 6, 18, 0)
            };

            _opcionRestar = new RadioButton
            {
                Text = "Restar",
                AutoSize = true,
                Margin = new Padding(0, 6, 0, 0)
            };

            panelOperacion.Controls.Add(_opcionSumar);
            panelOperacion.Controls.Add(_opcionRestar);

            contenedor.Controls.Add(CrearEtiqueta("Producto", true), 0, 0);
            contenedor.Controls.Add(_listaProductos, 1, 0);
            contenedor.Controls.Add(CrearEtiqueta("Operacion", true), 0, 1);
            contenedor.Controls.Add(panelOperacion, 1, 1);
            contenedor.Controls.Add(CrearEtiqueta("Cantidad", true), 0, 2);
            contenedor.Controls.Add(_textoCantidad, 1, 2);
            contenedor.Controls.Add(CrearEtiqueta("Empleado", false), 0, 3);
            contenedor.Controls.Add(_listaEmpleados, 1, 3);
            contenedor.Controls.Add(CrearEtiqueta("Motivo", false), 0, 4);
            contenedor.Controls.Add(_textoMotivo, 1, 4);

            _botonConfirmar = new Button
            {
                Text = "Confirmar",
                Width = 105,
                Height = 30,
                UseVisualStyleBackColor = true
            };
            _botonConfirmar.Click += BtnConfirmar_Click;

            _botonCancelar = new Button
            {
                Text = "Cancelar",
                Width = 105,
                Height = 30,
                DialogResult = DialogResult.Cancel,
                UseVisualStyleBackColor = true
            };

            var panelBotones = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.RightToLeft,
                WrapContents = false,
                Margin = new Padding(0, 12, 0, 0)
            };
            panelBotones.Controls.Add(_botonConfirmar);
            panelBotones.Controls.Add(_botonCancelar);

            contenedor.Controls.Add(panelBotones, 0, 5);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConfirmar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarProductos()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdProducto, CodigoProducto, Nombre, StockActual " +
                "FROM Productos WHERE Activo = 1 ORDER BY Nombre");

            datos.Columns.Add("DescripcionLista", typeof(string));
            foreach (DataRow fila in datos.Rows)
            {
                fila["DescripcionLista"] =
                    $"{fila["CodigoProducto"]} - {fila["Nombre"]} (Stock: {fila["StockActual"]})";
            }

            DataRow seleccion = datos.NewRow();
            seleccion["IdProducto"] = 0;
            seleccion["CodigoProducto"] = string.Empty;
            seleccion["Nombre"] = string.Empty;
            seleccion["StockActual"] = 0;
            seleccion["DescripcionLista"] = "Seleccione...";
            datos.Rows.InsertAt(seleccion, 0);

            _listaProductos.DisplayMember = "DescripcionLista";
            _listaProductos.ValueMember = "IdProducto";
            _listaProductos.DataSource = datos;
        }

        private void CargarEmpleados()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdEmpleado, Apellido + ', ' + Nombre AS NombreCompleto " +
                "FROM Empleados WHERE Activo = 1 ORDER BY Apellido, Nombre");

            DataRow seleccion = datos.NewRow();
            seleccion["IdEmpleado"] = 0;
            seleccion["NombreCompleto"] = "Sin empleado";
            datos.Rows.InsertAt(seleccion, 0);

            _listaEmpleados.DisplayMember = "NombreCompleto";
            _listaEmpleados.ValueMember = "IdEmpleado";
            _listaEmpleados.DataSource = datos;
        }

        private void BtnConfirmar_Click(object? sender, EventArgs e)
        {
            if (!ValidarCampos())
                return;

            try
            {
                int idEmpleado = Convert.ToInt32(_listaEmpleados.SelectedValue);
                object? empleadoParametro = idEmpleado == 0 ? null : idEmpleado;
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Producto_AjustarStock",
                    ("@IdProducto", Convert.ToInt32(_listaProductos.SelectedValue)),
                    ("@Operacion", _opcionSumar.Checked ? "SUMAR" : "RESTAR"),
                    ("@Cantidad", Convert.ToInt32(_textoCantidad.Text.Trim())),
                    ("@IdEmpleado", empleadoParametro),
                    ("@Motivo", string.IsNullOrWhiteSpace(_textoMotivo.Text) ? null : _textoMotivo.Text.Trim()));

                MensajeResultado = _opcionSumar.Checked
                    ? "Stock incrementado correctamente."
                    : "Stock reducido correctamente.";

                DialogResult = DialogResult.OK;
                Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    ex.Message,
                    "Error de base de datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private bool ValidarCampos()
        {
            if (_listaProductos.SelectedValue == null ||
                !int.TryParse(Convert.ToString(_listaProductos.SelectedValue), out int idProducto) ||
                idProducto <= 0)
            {
                MostrarDatoInvalido(_listaProductos, "Seleccione un producto.");
                return false;
            }

            if (!int.TryParse(_textoCantidad.Text.Trim(), out int cantidad) || cantidad <= 0)
            {
                MostrarDatoInvalido(_textoCantidad, "Ingrese una cantidad mayor a cero.");
                return false;
            }

            return true;
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

        private static TextBox CrearTexto()
        {
            return new TextBox
            {
                Dock = DockStyle.Fill,
                BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(0, 4, 0, 4)
            };
        }

        private static Control CrearEtiqueta(string texto, bool obligatorio)
        {
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.LeftToRight,
                WrapContents = false,
                AutoSize = false,
                Padding = new Padding(0, 9, 0, 0),
                Margin = new Padding(0, 0, 8, 0)
            };

            panel.Controls.Add(new Label
            {
                Text = texto,
                AutoSize = true,
                Margin = new Padding(0, 0, 2, 0)
            });

            if (obligatorio)
            {
                panel.Controls.Add(new Label
                {
                    Text = "*",
                    ForeColor = Color.Red,
                    Font = new Font(SystemFonts.DefaultFont, FontStyle.Bold),
                    AutoSize = true,
                    Margin = new Padding(0)
                });
            }

            return panel;
        }

        private static void MostrarDatoInvalido(Control control, string mensaje)
        {
            MessageBox.Show(
                mensaje,
                "Dato invalido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            control.Focus();
        }
    }
}
