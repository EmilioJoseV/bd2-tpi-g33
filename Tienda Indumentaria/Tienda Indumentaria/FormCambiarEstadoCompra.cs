using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormCambiarEstadoCompra : Form
    {
        private readonly int _idCompra;
        private readonly int _idProveedor;
        private readonly int _idEmpleado;
        private readonly int _idEstadoActual;
        private readonly string? _numeroComprobante;
        private readonly decimal _total;
        private ComboBox _listaEstados = null!;
        private Button _botonConfirmar = null!;
        private Button _botonCancelar = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormCambiarEstadoCompra(
            int idCompra,
            int idProveedor,
            int idEmpleado,
            int idEstadoActual,
            string? numeroComprobante,
            decimal total)
        {
            _idCompra = idCompra;
            _idProveedor = idProveedor;
            _idEmpleado = idEmpleado;
            _idEstadoActual = idEstadoActual;
            _numeroComprobante = numeroComprobante;
            _total = total;

            ConstruirInterfaz();
            CargarEstados();
        }

        private void ConstruirInterfaz()
        {
            Text = "Cambiar estado de compra";
            Width = 460;
            Height = 170;
            MinimumSize = new Size(460, 170);
            MaximumSize = new Size(460, 170);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(16),
                ColumnCount = 2,
                RowCount = 2
            };
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 115));
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            _listaEstados = new ComboBox
            {
                Dock = DockStyle.Fill,
                DropDownStyle = ComboBoxStyle.DropDownList,
                Margin = new Padding(0, 4, 0, 4)
            };

            contenedor.Controls.Add(CrearEtiqueta("Estado", true), 0, 0);
            contenedor.Controls.Add(_listaEstados, 1, 0);

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

            contenedor.Controls.Add(panelBotones, 0, 1);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConfirmar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void CargarEstados()
        {
            DataTable datos = Conexion.EjecutarConsulta(
                "SELECT IdEstadoCompra, Nombre FROM EstadosCompra ORDER BY Nombre");

            _listaEstados.DisplayMember = "Nombre";
            _listaEstados.ValueMember = "IdEstadoCompra";
            _listaEstados.DataSource = datos;
            _listaEstados.SelectedValue = _idEstadoActual;
        }

        private void BtnConfirmar_Click(object? sender, EventArgs e)
        {
            if (_listaEstados.SelectedValue == null ||
                !int.TryParse(Convert.ToString(_listaEstados.SelectedValue), out int idEstadoCompra) ||
                idEstadoCompra <= 0)
            {
                MostrarDatoInvalido(_listaEstados, "Seleccione un estado valido.");
                return;
            }

            try
            {
                Resultado = Conexion.EjecutarProcedimientoConValidacion(
                    "dbo.sp_actualizarCompra",
                    "Compra actualizada",
                    ("@IdCompra", _idCompra),
                    ("@IdProveedor", _idProveedor),
                    ("@IdEmpleado", _idEmpleado),
                    ("@IdEstadoCompra", idEstadoCompra),
                    ("@NumeroComprobante", (object?)_numeroComprobante ?? DBNull.Value),
                    ("@Total", _total));

                MensajeResultado = "Estado de compra actualizado correctamente.";
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
