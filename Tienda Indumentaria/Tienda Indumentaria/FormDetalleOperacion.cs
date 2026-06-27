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
        private Button _botonEditar = null!;
        private Button _botonEliminar = null!;
        private Button _botonCerrar = null!;

        public bool HuboCambios { get; private set; }

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
            _grilla.SelectionChanged += (_, _) => ActualizarBotones();

            _etiquetaEstado = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                ForeColor = Color.DimGray
            };

            _botonEditar = new Button
            {
                Text = "Editar",
                Width = 100,
                Height = 30,
                Enabled = false,
                UseVisualStyleBackColor = true
            };
            _botonEditar.Click += (_, _) => EditarDetalleSeleccionado();

            _botonEliminar = new Button
            {
                Text = "Eliminar",
                Width = 100,
                Height = 30,
                Enabled = false,
                UseVisualStyleBackColor = true
            };
            _botonEliminar.Click += (_, _) => EliminarDetalleSeleccionado();

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
            panelBotones.Controls.Add(_botonEliminar);
            panelBotones.Controls.Add(_botonEditar);

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
                ActualizarBotones();
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

        private void ActualizarBotones()
        {
            bool haySeleccion = _grilla.CurrentRow != null;
            _botonEditar.Enabled = haySeleccion;
            _botonEliminar.Enabled = haySeleccion;
        }

        private void EditarDetalleSeleccionado()
        {
            DataGridViewRow? fila = _grilla.CurrentRow;
            if (fila == null ||
                !TryObtenerEnteroFila(fila, "IdProducto", out int idProducto) ||
                !TryObtenerEnteroFila(fila, "Cantidad", out int cantidad) ||
                !TryObtenerDecimalFila(fila, "PrecioUnitario", out decimal precioUnitario))
            {
                MessageBox.Show(
                    "No se pudo leer el detalle seleccionado.",
                    "Detalle requerido",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            using (var formulario = new FormEditarDetalleOperacion(
                _tipoRegistro,
                idProducto,
                cantidad,
                precioUnitario))
            {
                if (formulario.ShowDialog(this) != DialogResult.OK)
                    return;

                try
                {
                    bool actualizado = _tipoRegistro == TipoRegistro.Venta
                        ? ActualizarDetalleVenta(fila, formulario)
                        : ActualizarDetalleCompra(fila, formulario);

                    if (!actualizado)
                        return;

                    HuboCambios = true;
                    CargarDetalle();
                    _etiquetaEstado.Text = "Detalle actualizado correctamente.";
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
        }

        private void EliminarDetalleSeleccionado()
        {
            DataGridViewRow? fila = _grilla.CurrentRow;
            if (fila == null)
                return;

            DialogResult confirmacion = MessageBox.Show(
                "Seguro que desea eliminar el detalle seleccionado?",
                "Confirmar eliminacion",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (confirmacion != DialogResult.Yes)
                return;

            try
            {
                bool eliminado = _tipoRegistro == TipoRegistro.Venta
                    ? EliminarDetalleVenta(fila)
                    : EliminarDetalleCompra(fila);

                if (!eliminado)
                    return;

                HuboCambios = true;
                CargarDetalle();
                _etiquetaEstado.Text = "Detalle eliminado correctamente.";
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

        private static bool ActualizarDetalleCompra(
            DataGridViewRow fila,
            FormEditarDetalleOperacion formulario)
        {
            if (!TryObtenerEnteroFila(fila, "IdDetalleCompra", out int idDetalleCompra))
            {
                MostrarDetalleRequerido("No se pudo identificar el detalle de compra.");
                return false;
            }

            Conexion.EjecutarProcedimientoConValidacion(
                "dbo.SP_DetalleCompra_Actualizar",
                "Detalle de compra actualizado",
                ("@IdDetalleCompra", idDetalleCompra),
                ("@IdProducto", formulario.IdProducto),
                ("@Cantidad", formulario.Cantidad),
                ("@PrecioUnitario", formulario.PrecioUnitario));

            return true;
        }

        private static bool ActualizarDetalleVenta(
            DataGridViewRow fila,
            FormEditarDetalleOperacion formulario)
        {
            if (!TryObtenerEnteroFila(fila, "IdDetalleVenta", out int idDetalleVenta))
            {
                MostrarDetalleRequerido("No se pudo identificar el detalle de venta.");
                return false;
            }

            Conexion.EjecutarProcedimientoConValidacion(
                "dbo.SP_DetalleVenta_Actualizar",
                "Detalle de venta actualizado",
                ("@IdDetalleVenta", idDetalleVenta),
                ("@IdProducto", formulario.IdProducto),
                ("@Cantidad", formulario.Cantidad));

            return true;
        }

        private static bool EliminarDetalleCompra(DataGridViewRow fila)
        {
            if (!TryObtenerEnteroFila(fila, "IdDetalleCompra", out int idDetalleCompra))
            {
                MostrarDetalleRequerido("No se pudo identificar el detalle de compra.");
                return false;
            }

            Conexion.EjecutarProcedimientoConValidacion(
                "dbo.SP_DetalleCompra_Eliminar",
                "Detalle de compra eliminado",
                ("@IdDetalleCompra", idDetalleCompra));

            return true;
        }

        private static bool EliminarDetalleVenta(DataGridViewRow fila)
        {
            if (!TryObtenerEnteroFila(fila, "IdDetalleVenta", out int idDetalleVenta))
            {
                MostrarDetalleRequerido("No se pudo identificar el detalle de venta.");
                return false;
            }

            Conexion.EjecutarProcedimientoConValidacion(
                "dbo.SP_DetalleVenta_Eliminar",
                "Detalle de venta eliminado",
                ("@IdDetalleVenta", idDetalleVenta));

            return true;
        }

        private static void MostrarDetalleRequerido(string mensaje)
        {
            MessageBox.Show(
                mensaje,
                "Detalle requerido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
        }

        private static bool TryObtenerEnteroFila(DataGridViewRow fila, string columna, out int valor)
        {
            valor = 0;
            if (fila.DataGridView == null || !fila.DataGridView.Columns.Contains(columna))
                return false;

            object? dato = fila.Cells[columna].Value;
            if (dato == null || dato == DBNull.Value)
                return false;

            return int.TryParse(Convert.ToString(dato), out valor);
        }

        private static bool TryObtenerDecimalFila(DataGridViewRow fila, string columna, out decimal valor)
        {
            valor = 0;
            if (fila.DataGridView == null || !fila.DataGridView.Columns.Contains(columna))
                return false;

            object? dato = fila.Cells[columna].Value;
            if (dato == null || dato == DBNull.Value)
                return false;

            try
            {
                valor = Convert.ToDecimal(dato);
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
