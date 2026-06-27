using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormDetalleOperacion : Form
    {
        private readonly TipoRegistro _tipoRegistro;
        private readonly int _idOperacion;
        private DataGridView _grilla = null!;
        private Label _etiquetaEstado = null!;
        private Button _botonCerrar = null!;

        public FormDetalleOperacion(TipoRegistro tipoRegistro, int idOperacion)
        {
            _tipoRegistro = tipoRegistro;
            _idOperacion = idOperacion;

            ConstruirInterfaz();
            CargarDetalle();
        }

        private void ConstruirInterfaz()
        {
            Text = _tipoRegistro == TipoRegistro.Venta
                ? $"Detalle de venta #{_idOperacion}"
                : $"Detalle de compra #{_idOperacion}";
            Width = 820;
            Height = 460;
            MinimumSize = new Size(760, 380);
            StartPosition = FormStartPosition.CenterParent;

            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 1,
                RowCount = 3,
                Padding = new Padding(14)
            };
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 42));

            _grilla = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false
            };

            _etiquetaEstado = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                ForeColor = Color.DimGray
            };

            _botonCerrar = new Button
            {
                Text = "Cerrar",
                Width = 100,
                Height = 30,
                DialogResult = DialogResult.OK,
                UseVisualStyleBackColor = true
            };

            var panelBotones = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.RightToLeft,
                WrapContents = false
            };
            panelBotones.Controls.Add(_botonCerrar);

            contenedor.Controls.Add(_grilla, 0, 0);
            contenedor.Controls.Add(_etiquetaEstado, 0, 1);
            contenedor.Controls.Add(panelBotones, 0, 2);
            Controls.Add(contenedor);

            AcceptButton = _botonCerrar;
            CancelButton = _botonCerrar;
        }

        private void CargarDetalle()
        {
            try
            {
                DataTable datos = _tipoRegistro == TipoRegistro.Venta
                    ? ObtenerDetalleVenta()
                    : ObtenerDetalleCompra();

                _grilla.DataSource = datos;
                OcultarColumnasInternas();
                AplicarTitulosColumnas();
                _etiquetaEstado.Text = $"{datos.Rows.Count} producto(s) en el detalle.";
            }
            catch (Exception ex)
            {
                _etiquetaEstado.Text = "Error al consultar el detalle.";
                MessageBox.Show(ex.Message, "Error de base de datos", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private DataTable ObtenerDetalleVenta()
        {
            return Conexion.EjecutarConsulta(
                "SELECT dv.IdDetalleVenta, dv.IdVenta, dv.IdProducto, p.CodigoProducto, p.Nombre AS Producto, " +
                "dv.Cantidad, dv.PrecioUnitario, dv.Subtotal " +
                "FROM DetalleVentas dv " +
                "INNER JOIN Productos p ON p.IdProducto = dv.IdProducto " +
                "WHERE dv.IdVenta = @IdVenta " +
                "ORDER BY p.Nombre",
                ("@IdVenta", _idOperacion));
        }

        private DataTable ObtenerDetalleCompra()
        {
            return Conexion.EjecutarConsulta(
                "SELECT dc.IdDetalleCompra, dc.IdCompra, dc.IdProducto, p.CodigoProducto, p.Nombre AS Producto, " +
                "dc.Cantidad, dc.PrecioUnitario, dc.Subtotal " +
                "FROM DetalleCompras dc " +
                "INNER JOIN Productos p ON p.IdProducto = dc.IdProducto " +
                "WHERE dc.IdCompra = @IdCompra " +
                "ORDER BY p.Nombre",
                ("@IdCompra", _idOperacion));
        }

        private void OcultarColumnasInternas()
        {
            foreach (DataGridViewColumn columna in _grilla.Columns)
            {
                if (columna.Name.StartsWith("Id", StringComparison.OrdinalIgnoreCase))
                    columna.Visible = false;
            }
        }

        private void AplicarTitulosColumnas()
        {
            AplicarTitulo("CodigoProducto", "Codigo");
            AplicarTitulo("PrecioUnitario", "Precio unitario");
        }

        private void AplicarTitulo(string columna, string titulo)
        {
            if (_grilla.Columns.Contains(columna))
                _grilla.Columns[columna].HeaderText = titulo;
        }
    }
}
