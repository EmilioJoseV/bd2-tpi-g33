using System;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormEditarDetalleOperacion : Form
    {
        private readonly TipoRegistro _tipoRegistro;
        private readonly int _idProductoInicial;
        private readonly int _cantidadInicial;
        private readonly decimal _precioUnitarioInicial;
        private ComboBox _listaProductos = null!;
        private TextBox _textoCantidad = null!;
        private TextBox? _textoPrecioUnitario;
        private Button _botonConfirmar = null!;
        private Button _botonCancelar = null!;

        public int IdProducto { get; private set; }
        public int Cantidad { get; private set; }
        public decimal PrecioUnitario { get; private set; }

        public FormEditarDetalleOperacion(
            TipoRegistro tipoRegistro,
            int idProducto,
            int cantidad,
            decimal precioUnitario)
        {
            _tipoRegistro = tipoRegistro;
            _idProductoInicial = idProducto;
            _cantidadInicial = cantidad;
            _precioUnitarioInicial = precioUnitario;

            ConstruirInterfaz();
            CargarProductos();
            CargarValoresIniciales();
        }

        private void ConstruirInterfaz()
        {
            bool esCompra = _tipoRegistro == TipoRegistro.Compra;
            Text = esCompra ? "Editar detalle de compra" : "Editar detalle de venta";
            Width = 500;
            Height = esCompra ? 220 : 180;
            MinimumSize = new Size(500, Height);
            MaximumSize = new Size(500, Height);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(16),
                ColumnCount = 2,
                RowCount = esCompra ? 4 : 3
            };
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 130));
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            if (esCompra)
                contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            _listaProductos = new ComboBox
            {
                Dock = DockStyle.Fill,
                Margin = new Padding(0, 4, 0, 4)
            };

            _textoCantidad = new TextBox
            {
                Dock = DockStyle.Fill,
                BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(0, 4, 0, 4)
            };

            contenedor.Controls.Add(CrearEtiqueta("Producto", true), 0, 0);
            contenedor.Controls.Add(_listaProductos, 1, 0);
            contenedor.Controls.Add(CrearEtiqueta("Cantidad", true), 0, 1);
            contenedor.Controls.Add(_textoCantidad, 1, 1);

            int filaBotones = 2;
            if (esCompra)
            {
                _textoPrecioUnitario = new TextBox
                {
                    Dock = DockStyle.Fill,
                    BorderStyle = BorderStyle.FixedSingle,
                    Margin = new Padding(0, 4, 0, 4)
                };

                contenedor.Controls.Add(CrearEtiqueta("Precio unitario", true), 0, 2);
                contenedor.Controls.Add(_textoPrecioUnitario, 1, 2);
                filaBotones = 3;
            }

            _botonConfirmar = new Button
            {
                Text = "Guardar",
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

            contenedor.Controls.Add(panelBotones, 0, filaBotones);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConfirmar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarProductos()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdProducto, CodigoProducto + ' - ' + Nombre AS Producto " +
                "FROM Productos WHERE Activo = 1 ORDER BY Nombre");

            ComboBusqueda.Configurar(_listaProductos, datos, "IdProducto", "Producto");
        }

        private void CargarValoresIniciales()
        {
            _listaProductos.SelectedValue = _idProductoInicial;
            _textoCantidad.Text = _cantidadInicial.ToString(CultureInfo.CurrentCulture);

            if (_textoPrecioUnitario != null)
                _textoPrecioUnitario.Text = _precioUnitarioInicial.ToString("0.00", CultureInfo.CurrentCulture);
        }

        private void BtnConfirmar_Click(object? sender, EventArgs e)
        {
            if (_listaProductos.SelectedValue == null ||
                !int.TryParse(Convert.ToString(_listaProductos.SelectedValue), out int idProducto) ||
                idProducto <= 0)
            {
                MostrarDatoInvalido(_listaProductos, "Seleccione un producto valido.");
                return;
            }

            if (!int.TryParse(_textoCantidad.Text.Trim(), out int cantidad) || cantidad <= 0)
            {
                MostrarDatoInvalido(_textoCantidad, "Ingrese una cantidad mayor a cero.");
                return;
            }

            decimal precioUnitario = _precioUnitarioInicial;
            if (_tipoRegistro == TipoRegistro.Compra)
            {
                if (_textoPrecioUnitario == null ||
                    !TryParseDecimal(_textoPrecioUnitario.Text.Trim(), out precioUnitario) ||
                    precioUnitario < 0)
                {
                    MostrarDatoInvalido(_textoPrecioUnitario ?? _textoCantidad, "Ingrese un precio unitario valido.");
                    return;
                }
            }

            IdProducto = idProducto;
            Cantidad = cantidad;
            PrecioUnitario = precioUnitario;
            DialogResult = DialogResult.OK;
            Close();
        }

        private static bool TryParseDecimal(string entrada, out decimal valor)
        {
            return decimal.TryParse(entrada, NumberStyles.Number, CultureInfo.CurrentCulture, out valor) ||
                decimal.TryParse(entrada, NumberStyles.Number, CultureInfo.InvariantCulture, out valor) ||
                decimal.TryParse(entrada.Replace(',', '.'), NumberStyles.Number, CultureInfo.InvariantCulture, out valor);
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
