using System;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormVenta : Form
    {
        private ComboBox _listaClientes = null!;
        private ComboBox _listaEmpleados = null!;
        private ComboBox _listaMediosPago = null!;
        private ComboBox _listaProductos = null!;
        private TextBox _textoCantidad = null!;
        private DataGridView _grillaDetalle = null!;
        private Label _etiquetaTotal = null!;
        private Button _botonAgregar = null!;
        private Button _botonQuitar = null!;
        private Button _botonConfirmar = null!;
        private Button _botonCancelar = null!;
        private readonly BindingList<LineaDetalleVenta> _detalle = new BindingList<LineaDetalleVenta>();
        private DataTable _productos = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormVenta()
        {
            ConstruirInterfaz();
            CargarClientes();
            CargarEmpleados();
            CargarMediosPago();
            CargarProductos();
        }

        private void ConstruirInterfaz()
        {
            Text = "Registrar venta";
            Width = 820;
            Height = 620;
            MinimumSize = new Size(820, 620);
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
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 44));

            _listaClientes = CrearListaBusqueda();
            _listaEmpleados = CrearListaBusqueda();
            _listaMediosPago = CrearListaBusqueda();
            _listaProductos = CrearListaBusqueda();
            _textoCantidad = CrearTexto();

            contenedor.Controls.Add(CrearEtiqueta("Cliente", true), 0, 0);
            contenedor.Controls.Add(_listaClientes, 1, 0);
            contenedor.Controls.Add(CrearEtiqueta("Empleado", true), 0, 1);
            contenedor.Controls.Add(_listaEmpleados, 1, 1);
            contenedor.Controls.Add(CrearEtiqueta("Medio pago", true), 0, 2);
            contenedor.Controls.Add(_listaMediosPago, 1, 2);

            var panelProducto = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 4,
                RowCount = 1,
                Margin = new Padding(0)
            };
            panelProducto.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            panelProducto.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 78));
            panelProducto.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 86));
            panelProducto.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 112));

            panelProducto.Controls.Add(_listaProductos, 0, 0);
            panelProducto.Controls.Add(CrearEtiquetaInline("Cantidad"), 1, 0);
            panelProducto.Controls.Add(_textoCantidad, 2, 0);

            _botonAgregar = new Button
            {
                Text = "Agregar",
                Dock = DockStyle.Fill,
                Margin = new Padding(4, 4, 0, 4),
                UseVisualStyleBackColor = true
            };
            _botonAgregar.Click += (_, _) => AgregarProducto();
            panelProducto.Controls.Add(_botonAgregar, 3, 0);

            contenedor.Controls.Add(CrearEtiqueta("Producto", true), 0, 3);
            contenedor.Controls.Add(panelProducto, 1, 3);

            _grillaDetalle = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                AutoGenerateColumns = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                RowHeadersVisible = false,
                Margin = new Padding(0, 8, 0, 8)
            };
            _grillaDetalle.Columns.Add(new DataGridViewTextBoxColumn
            {
                DataPropertyName = nameof(LineaDetalleVenta.Producto),
                HeaderText = "Producto",
                AutoSizeMode = DataGridViewAutoSizeColumnMode.Fill
            });
            _grillaDetalle.Columns.Add(new DataGridViewTextBoxColumn
            {
                DataPropertyName = nameof(LineaDetalleVenta.Cantidad),
                HeaderText = "Cantidad",
                Width = 90
            });
            _grillaDetalle.Columns.Add(new DataGridViewTextBoxColumn
            {
                DataPropertyName = nameof(LineaDetalleVenta.PrecioUnitario),
                HeaderText = "Precio unit.",
                Width = 110,
                DefaultCellStyle = new DataGridViewCellStyle { Format = "N2" }
            });
            _grillaDetalle.Columns.Add(new DataGridViewTextBoxColumn
            {
                DataPropertyName = nameof(LineaDetalleVenta.Subtotal),
                HeaderText = "Subtotal",
                Width = 110,
                DefaultCellStyle = new DataGridViewCellStyle { Format = "N2" }
            });
            _grillaDetalle.DataSource = _detalle;

            contenedor.Controls.Add(CrearEtiqueta("Detalle", true), 0, 4);
            contenedor.Controls.Add(_grillaDetalle, 1, 4);

            _etiquetaTotal = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleRight,
                Font = new Font(SystemFonts.DefaultFont, FontStyle.Bold),
                Text = "Total: $ 0,00"
            };

            _botonQuitar = new Button
            {
                Text = "Quitar producto",
                Width = 120,
                Height = 30,
                UseVisualStyleBackColor = true
            };
            _botonQuitar.Click += (_, _) => QuitarProductoSeleccionado();

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

            var panelInferior = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 3,
                RowCount = 1
            };
            panelInferior.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 140));
            panelInferior.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            panelInferior.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 230));
            panelInferior.Controls.Add(_botonQuitar, 0, 0);
            panelInferior.Controls.Add(_etiquetaTotal, 1, 0);

            var panelBotones = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.RightToLeft,
                WrapContents = false
            };
            panelBotones.Controls.Add(_botonConfirmar);
            panelBotones.Controls.Add(_botonCancelar);
            panelInferior.Controls.Add(panelBotones, 2, 0);

            contenedor.Controls.Add(panelInferior, 0, 5);
            contenedor.SetColumnSpan(panelInferior, 2);

            AcceptButton = _botonConfirmar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarClientes()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdCliente, Apellido + ', ' + Nombre AS NombreCompleto, Documento " +
                "FROM Clientes WHERE Activo = 1 ORDER BY Apellido, Nombre");

            datos.Columns.Add("DescripcionLista", typeof(string));
            foreach (DataRow fila in datos.Rows)
            {
                fila["DescripcionLista"] = $"{fila["NombreCompleto"]} - {fila["Documento"]}";
            }

            AgregarOpcionSeleccion(datos, "IdCliente", "DescripcionLista", "Seleccione cliente...");
            ConfigurarLista(_listaClientes, datos, "DescripcionLista", "IdCliente");
        }

        private void CargarEmpleados()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdEmpleado, Apellido + ', ' + Nombre AS NombreCompleto " +
                "FROM Empleados WHERE Activo = 1 ORDER BY Apellido, Nombre");

            AgregarOpcionSeleccion(datos, "IdEmpleado", "NombreCompleto", "Seleccione empleado...");
            ConfigurarLista(_listaEmpleados, datos, "NombreCompleto", "IdEmpleado");
        }

        private void CargarMediosPago()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdMedioPago, Nombre FROM MediosPago WHERE Activo = 1 ORDER BY Nombre");

            AgregarOpcionSeleccion(datos, "IdMedioPago", "Nombre", "Seleccione medio de pago...");
            ConfigurarLista(_listaMediosPago, datos, "Nombre", "IdMedioPago");
        }

        private void CargarProductos()
        {
            _productos = Conexion.EjecutarConsulta(
                "SELECT IdProducto, CodigoProducto, Nombre, PrecioVenta, StockActual " +
                "FROM Productos WHERE Activo = 1 ORDER BY Nombre");

            _productos.Columns.Add("DescripcionLista", typeof(string));
            foreach (DataRow fila in _productos.Rows)
            {
                fila["DescripcionLista"] =
                    $"{fila["CodigoProducto"]} - {fila["Nombre"]} (Stock: {fila["StockActual"]})";
            }

            AgregarOpcionSeleccion(_productos, "IdProducto", "DescripcionLista", "Seleccione producto...");
            ConfigurarLista(_listaProductos, _productos, "DescripcionLista", "IdProducto");
        }

        private void AgregarProducto()
        {
            if (_listaProductos.SelectedItem is not DataRowView producto ||
                !TryObtenerIdSeleccionado(_listaProductos, out int idProducto))
            {
                MostrarDatoInvalido(_listaProductos, "Seleccione un producto.");
                return;
            }

            if (!int.TryParse(_textoCantidad.Text.Trim(), out int cantidad) || cantidad <= 0)
            {
                MostrarDatoInvalido(_textoCantidad, "Ingrese una cantidad mayor a cero.");
                return;
            }

            decimal precioUnitario = Convert.ToDecimal(producto["PrecioVenta"]);
            string descripcion = Convert.ToString(producto["DescripcionLista"]) ?? string.Empty;
            LineaDetalleVenta? existente = _detalle.FirstOrDefault(d => d.IdProducto == idProducto);
            if (existente != null)
            {
                existente.Cantidad += cantidad;
                _grillaDetalle.Refresh();
            }
            else
            {
                _detalle.Add(new LineaDetalleVenta
                {
                    IdProducto = idProducto,
                    Producto = descripcion,
                    Cantidad = cantidad,
                    PrecioUnitario = precioUnitario
                });
            }

            _textoCantidad.Clear();
            _listaProductos.SelectedIndex = 0;
            ActualizarTotal();
        }

        private void QuitarProductoSeleccionado()
        {
            if (_grillaDetalle.CurrentRow?.DataBoundItem is not LineaDetalleVenta linea)
            {
                MessageBox.Show(
                    "Seleccione un producto del detalle para quitar.",
                    "Detalle requerido",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            _detalle.Remove(linea);
            ActualizarTotal();
        }

        private void BtnConfirmar_Click(object? sender, EventArgs e)
        {
            if (!TryObtenerIdSeleccionado(_listaClientes, out int idCliente))
            {
                MostrarDatoInvalido(_listaClientes, "Seleccione un cliente.");
                return;
            }

            if (!TryObtenerIdSeleccionado(_listaEmpleados, out int idEmpleado))
            {
                MostrarDatoInvalido(_listaEmpleados, "Seleccione un empleado.");
                return;
            }

            if (!TryObtenerIdSeleccionado(_listaMediosPago, out int idMedioPago))
            {
                MostrarDatoInvalido(_listaMediosPago, "Seleccione un medio de pago.");
                return;
            }

            if (_detalle.Count == 0)
            {
                MessageBox.Show(
                    "Agregue al menos un producto a la venta.",
                    "Detalle requerido",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            var lineas = _detalle
                .Select(d => (d.IdProducto, d.Cantidad))
                .ToList();

            try
            {
                Resultado = Conexion.RegistrarVentaConDetalle(
                    idCliente,
                    idEmpleado,
                    idMedioPago,
                    lineas);

                MensajeResultado = "Venta registrada correctamente.";
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

        private void ActualizarTotal()
        {
            decimal total = _detalle.Sum(d => d.Subtotal);
            _etiquetaTotal.Text = $"Total: $ {total.ToString("N2", CultureInfo.CurrentCulture)}";
        }

        private static void AgregarOpcionSeleccion(
            DataTable datos,
            string columnaId,
            string columnaTexto,
            string textoSeleccion)
        {
            DataRow seleccion = datos.NewRow();
            seleccion[columnaId] = 0;
            seleccion[columnaTexto] = textoSeleccion;
            datos.Rows.InsertAt(seleccion, 0);
        }

        private static void ConfigurarLista(
            ComboBox lista,
            DataTable datos,
            string displayMember,
            string valueMember)
        {
            ComboBusqueda.Configurar(lista, datos, valueMember, displayMember);
            lista.SelectedIndex = 0;
        }

        private static ComboBox CrearListaBusqueda()
        {
            return new ComboBox
            {
                Dock = DockStyle.Fill,
                DropDownStyle = ComboBoxStyle.DropDown,
                AutoCompleteMode = AutoCompleteMode.SuggestAppend,
                AutoCompleteSource = AutoCompleteSource.ListItems,
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

        private static Label CrearEtiquetaInline(string texto)
        {
            return new Label
            {
                Text = texto,
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleRight,
                Margin = new Padding(0, 4, 4, 4)
            };
        }

        private static bool TryObtenerIdSeleccionado(ComboBox lista, out int id)
        {
            id = 0;
            if (lista.SelectedValue == null)
                return false;

            if (!int.TryParse(Convert.ToString(lista.SelectedValue), out id) || id <= 0)
                return false;

            return true;
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

        private sealed class LineaDetalleVenta
        {
            public int IdProducto { get; set; }
            public string Producto { get; set; } = string.Empty;
            public int Cantidad { get; set; }
            public decimal PrecioUnitario { get; set; }
            public decimal Subtotal => Cantidad * PrecioUnitario;
        }
    }
}
