using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public class FormPrincipal : Form
    {
        private ComboBox _comboConsultas = null!;
        private ComboBox _comboVistas = null!;
        private Button _botonEjecutar = null!;
        private DataGridView _grilla = null!;
        private Label _etiquetaEstado = null!;
        private GroupBox _grupoEntidad = null!;

        private Label[] _etiquetasCampos = null!;
        private TextBox[] _textosCampos = null!;
        private string[] _columnasCampos = Array.Empty<string>();

        private Button _botonRegistrar = null!;
        private Button _botonActualizar = null!;
        private Button _botonDesactivar = null!;
        private Button _botonActivar = null!;
        private Button _botonListar = null!;
        private Button _botonLimpiar = null!;

        private OpcionConsulta? _opcionActual;
        private string? _idRegistroSeleccionado;
        private bool? _activoRegistroSeleccionado;

        public FormPrincipal()
        {
            ConstruirInterfaz();
            CargarOpciones();
            EjecutarConsultaSeleccionada();
        }

        private void ConstruirInterfaz()
        {
            Text = "Tienda de Indumentaria - Demo BD2";
            Width = 1120;
            Height = 720;
            MinimumSize = new Size(1000, 640);
            StartPosition = FormStartPosition.CenterScreen;

            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(14),
                ColumnCount = 1,
                RowCount = 4
            };
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 78));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 205));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));

            var panelConsulta = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 4,
                RowCount = 2,
                Margin = new Padding(0, 0, 0, 8)
            };
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 78));
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 430));
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 112));
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            panelConsulta.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
            panelConsulta.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));

            _comboConsultas = new ComboBox
            {
                Dock = DockStyle.Fill,
                DropDownStyle = ComboBoxStyle.DropDownList,
                Margin = new Padding(0, 0, 12, 0)
            };
            _comboConsultas.SelectedIndexChanged += ComboConsultas_SelectedIndexChanged;

            _comboVistas = new ComboBox
            {
                Dock = DockStyle.Fill,
                DropDownStyle = ComboBoxStyle.DropDownList,
                Enabled = false,
                Margin = new Padding(0, 0, 12, 0)
            };

            _botonEjecutar = new Button
            {
                Text = "Ejecutar",
                Dock = DockStyle.Top,
                Height = 30,
                Margin = new Padding(0),
                UseVisualStyleBackColor = true
            };
            _botonEjecutar.Click += (_, _) => EjecutarConsultaSeleccionada();

            panelConsulta.Controls.Add(CrearEtiqueta("Tabla:"), 0, 0);
            panelConsulta.Controls.Add(_comboConsultas, 1, 0);
            panelConsulta.Controls.Add(_botonEjecutar, 2, 0);
            panelConsulta.SetRowSpan(_botonEjecutar, 2);
            panelConsulta.Controls.Add(CrearEtiqueta("Vista:"), 0, 1);
            panelConsulta.Controls.Add(_comboVistas, 1, 1);

            _grupoEntidad = new GroupBox
            {
                Text = "Entidad",
                Dock = DockStyle.Fill,
                Padding = new Padding(12, 10, 12, 12),
                Margin = new Padding(0, 0, 0, 10)
            };

            CrearCamposEntidad();
            CrearBotonesEntidad();

            _grilla = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                Margin = new Padding(0)
            };
            _grilla.CellClick += Grilla_CellClick;
            _grilla.MouseDown += Grilla_MouseDown;

            _etiquetaEstado = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                ForeColor = Color.DimGray
            };

            contenedor.Controls.Add(panelConsulta, 0, 0);
            contenedor.Controls.Add(_grupoEntidad, 0, 1);
            contenedor.Controls.Add(_grilla, 0, 2);
            contenedor.Controls.Add(_etiquetaEstado, 0, 3);
            Controls.Add(contenedor);
        }

        private void CrearCamposEntidad()
        {
            int[] lefts = { 22, 180, 548, 22, 360, 588 };
            int[] tops = { 27, 27, 27, 83, 83, 83 };
            int[] textTops = { 48, 48, 48, 104, 104, 104 };
            int[] widths = { 120, 330, 190, 300, 190, 420 };

            _etiquetasCampos = new Label[6];
            _textosCampos = new TextBox[6];

            for (int i = 0; i < 6; i++)
            {
                _etiquetasCampos[i] = CrearEtiquetaCampo(string.Empty, lefts[i], tops[i], widths[i]);
                _textosCampos[i] = CrearTexto(lefts[i], textTops[i], widths[i]);
                _grupoEntidad.Controls.Add(_etiquetasCampos[i]);
                _grupoEntidad.Controls.Add(_textosCampos[i]);
            }

        }

        private void CrearBotonesEntidad()
        {
            _botonRegistrar = CrearBoton("Registrar", 22, 148, 110);
            _botonRegistrar.Click += BtnRegistrar_Click;

            _botonActualizar = CrearBoton("Actualizar contacto", 144, 148, 150);
            _botonActualizar.Click += BtnActualizar_Click;

            _botonDesactivar = CrearBoton("Desactivar", 306, 148, 110);
            _botonDesactivar.Click += BtnDesactivar_Click;

            _botonActivar = CrearBoton("Activar", 428, 148, 90);
            _botonActivar.Click += BtnActivar_Click;

            _botonListar = CrearBoton("Listar", 530, 148, 90);
            _botonListar.Click += (_, _) => EjecutarConsultaSeleccionada();

            _botonLimpiar = CrearBoton("Limpiar", 632, 148, 90);
            _botonLimpiar.Click += (_, _) => LimpiarCampos();

            _grupoEntidad.Controls.Add(_botonRegistrar);
            _grupoEntidad.Controls.Add(_botonActualizar);
            _grupoEntidad.Controls.Add(_botonDesactivar);
            _grupoEntidad.Controls.Add(_botonActivar);
            _grupoEntidad.Controls.Add(_botonListar);
            _grupoEntidad.Controls.Add(_botonLimpiar);
        }

        private static Label CrearEtiqueta(string texto)
        {
            return new Label
            {
                Text = texto,
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                AutoSize = false,
                Margin = new Padding(0, 0, 8, 0)
            };
        }

        private static Label CrearEtiquetaCampo(string texto, int left, int top, int width)
        {
            return new Label
            {
                Text = texto,
                Left = left,
                Top = top,
                Width = width,
                Height = 18,
                TextAlign = ContentAlignment.MiddleLeft
            };
        }

        private static TextBox CrearTexto(int left, int top, int width)
        {
            return new TextBox
            {
                Left = left,
                Top = top,
                Width = width,
                Height = 24,
                BorderStyle = BorderStyle.FixedSingle,
                BackColor = Color.White
            };
        }

        private static Button CrearBoton(string texto, int left, int top, int width)
        {
            return new Button
            {
                Text = texto,
                Left = left,
                Top = top,
                Width = width,
                Height = 30,
                UseVisualStyleBackColor = true
            };
        }

        private void CargarOpciones()
        {
            _comboConsultas.Items.Add(new OpcionConsulta(
                "Proveedores",
                "SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo " +
                "FROM Proveedores ORDER BY RazonSocial",
                "Proveedores",
                "IdProveedor",
                true,
                ("Razon social", "RazonSocial"),
                ("CUIT", "CUIT"),
                ("Email", "Email"),
                ("Telefono", "Telefono"),
                ("Direccion", "Direccion"),
                ("", "")));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Empleados",
                "SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo " +
                "FROM Empleados ORDER BY Apellido, Nombre",
                "Empleados",
                "IdEmpleado",
                true,
                ("Apellido", "Apellido"),
                ("Nombre", "Nombre"),
                ("Documento", "Documento"),
                ("Email", "Email"),
                ("Telefono", "Telefono"),
                ("", "")));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Clientes activos",
                "SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, Activo " +
                "FROM Clientes WHERE Activo = 1 ORDER BY Apellido, Nombre",
                "Clientes",
                "IdCliente",
                false,
                ("Apellido", "Apellido"),
                ("Nombre", "Nombre"),
                ("Documento", "Documento"),
                ("Email", "Email"),
                ("Telefono", "Telefono"),
                ("", "")));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Productos (tabla completa)",
                "SELECT * FROM Productos",
                "Productos",
                "IdProducto",
                false,
                ("Codigo", "CodigoProducto"),
                ("Nombre", "Nombre"),
                ("Precio venta", "PrecioVenta"),
                ("Stock actual", "StockActual"),
                ("Stock minimo", "StockMinimo"),
                ("", "")));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Ventas",
                "SELECT IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total " +
                "FROM Ventas ORDER BY FechaVenta DESC",
                "Ventas",
                "IdVenta",
                false,
                ("Id cliente", "IdCliente"),
                ("Id empleado", "IdEmpleado"),
                ("Medio pago", "IdMedioPago"),
                ("Estado", "IdEstadoVenta"),
                ("Fecha", "FechaVenta"),
                ("Total", "Total")));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Compras",
                "SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total " +
                "FROM Compras ORDER BY FechaCompra DESC",
                "Compras",
                "IdCompra",
                false,
                ("Id proveedor", "IdProveedor"),
                ("Id empleado", "IdEmpleado"),
                ("Estado", "IdEstadoCompra"),
                ("Fecha", "FechaCompra"),
                ("Comprobante", "NumeroComprobante"),
                ("Total", "Total")));

            if (_comboConsultas.Items.Count > 0)
                _comboConsultas.SelectedIndex = 0;
        }

        private void ComboConsultas_SelectedIndexChanged(object? sender, EventArgs e)
        {
            if (_comboConsultas.SelectedItem is not OpcionConsulta opcion)
                return;

            _opcionActual = opcion;
            ConfigurarFormulario(opcion);
            CargarVistasParaTabla(opcion);
            LimpiarCampos();
        }

        private void CargarVistasParaTabla(OpcionConsulta opcion)
        {
            _comboVistas.Items.Clear();
            _comboVistas.Enabled = false;
            _comboVistas.Items.Add($"Sin vistas de {opcion.Entidad}");
            _comboVistas.SelectedIndex = 0;
        }

        private void ConfigurarFormulario(OpcionConsulta opcion)
        {
            _idRegistroSeleccionado = null;
            ActualizarTituloEntidad();
            _columnasCampos = new string[_textosCampos.Length];

            for (int i = 0; i < _textosCampos.Length; i++)
            {
                CampoFormulario campo = opcion.Campos[i];
                bool visible = !string.IsNullOrWhiteSpace(campo.Etiqueta);

                _etiquetasCampos[i].Text = campo.Etiqueta;
                _etiquetasCampos[i].Visible = visible;
                _textosCampos[i].Visible = visible;
                _textosCampos[i].ReadOnly = false;
                _columnasCampos[i] = campo.Columna;
            }

            _botonRegistrar.Enabled = opcion.PermiteAcciones;
            _botonActualizar.Enabled = opcion.PermiteAcciones;
            _botonDesactivar.Enabled = opcion.PermiteAcciones;
            _botonActivar.Enabled = opcion.PermiteAcciones;
            _botonActualizar.Text = EsFormularioProveedor() ? "Actualizar contacto" : "Actualizar";
        }

        private void EjecutarConsultaSeleccionada()
        {
            if (_comboConsultas.SelectedItem is not OpcionConsulta opcion)
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarConsulta(opcion.Sql);
                MostrarDatos(datos, $"{datos.Rows.Count} fila(s) devuelta(s).");
            });
        }

        private void BtnRegistrar_Click(object? sender, EventArgs e)
        {
            if (EsFormularioProveedor())
            {
                RegistrarProveedor();
                return;
            }

            if (EsFormularioEmpleado())
                RegistrarEmpleado();
        }

        private void RegistrarProveedor()
        {
            if (!ValidarObligatorio(_textosCampos[0], "La razon social es obligatoria."))
                return;

            if (!ValidarObligatorio(_textosCampos[1], "El CUIT es obligatorio."))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_Registrar",
                    ("@RazonSocial", _textosCampos[0].Text.Trim()),
                    ("@CUIT", _textosCampos[1].Text.Trim()),
                    ("@Email", ValorOpcional(_textosCampos[2].Text)),
                    ("@Telefono", ValorOpcional(_textosCampos[3].Text)),
                    ("@Direccion", ValorOpcional(_textosCampos[4].Text)));

                MostrarDatos(datos, "Proveedor registrado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void RegistrarEmpleado()
        {
            if (!ValidarObligatorio(_textosCampos[0], "El apellido es obligatorio."))
                return;

            if (!ValidarObligatorio(_textosCampos[1], "El nombre es obligatorio."))
                return;

            if (!ValidarObligatorio(_textosCampos[2], "El documento es obligatorio."))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Registrar",
                    ("@Apellido", _textosCampos[0].Text.Trim()),
                    ("@Nombre", _textosCampos[1].Text.Trim()),
                    ("@Documento", _textosCampos[2].Text.Trim()),
                    ("@Email", ValorOpcional(_textosCampos[3].Text)),
                    ("@Telefono", ValorOpcional(_textosCampos[4].Text)));

                MostrarDatos(datos, "Empleado registrado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void BtnActualizar_Click(object? sender, EventArgs e)
        {
            if (EsFormularioProveedor())
            {
                ActualizarContactoProveedor();
                return;
            }

            if (EsFormularioEmpleado())
                ActualizarEmpleado();
        }

        private void ActualizarContactoProveedor()
        {
            if (!TryObtenerIdSeleccionado("proveedor", out int idProveedor))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_ActualizarContacto",
                    ("@IdProveedor", idProveedor),
                    ("@Email", ValorOpcional(_textosCampos[2].Text)),
                    ("@Telefono", ValorOpcional(_textosCampos[3].Text)),
                    ("@Direccion", ValorOpcional(_textosCampos[4].Text)));

                MostrarDatos(datos, "Contacto actualizado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void ActualizarEmpleado()
        {
            if (!TryObtenerIdSeleccionado("empleado", out int idEmpleado))
                return;

            if (!ValidarObligatorio(_textosCampos[0], "El apellido es obligatorio."))
                return;

            if (!ValidarObligatorio(_textosCampos[1], "El nombre es obligatorio."))
                return;

            if (!ValidarObligatorio(_textosCampos[2], "El documento es obligatorio."))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Actualizar",
                    ("@IdEmpleado", idEmpleado),
                    ("@Apellido", _textosCampos[0].Text.Trim()),
                    ("@Nombre", _textosCampos[1].Text.Trim()),
                    ("@Documento", _textosCampos[2].Text.Trim()),
                    ("@Email", ValorOpcional(_textosCampos[3].Text)),
                    ("@Telefono", ValorOpcional(_textosCampos[4].Text)),
                    ("@Activo", _activoRegistroSeleccionado ?? true));

                MostrarDatos(datos, "Empleado actualizado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void BtnDesactivar_Click(object? sender, EventArgs e)
        {
            if (EsFormularioProveedor())
            {
                DesactivarProveedor();
                return;
            }

            if (EsFormularioEmpleado())
                DesactivarEmpleado();
        }

        private void BtnActivar_Click(object? sender, EventArgs e)
        {
            if (EsFormularioProveedor())
            {
                ActivarProveedor();
                return;
            }

            if (EsFormularioEmpleado())
                ActivarEmpleado();
        }

        private void DesactivarProveedor()
        {
            if (!TryObtenerIdSeleccionado("proveedor", out int idProveedor))
                return;

            var confirmacion = MessageBox.Show(
                "Se marcara el proveedor como inactivo. Desea continuar?",
                "Confirmar baja logica",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (confirmacion != DialogResult.Yes)
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_Desactivar",
                    ("@IdProveedor", idProveedor));

                MostrarDatos(datos, "Proveedor desactivado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void DesactivarEmpleado()
        {
            if (!TryObtenerIdSeleccionado("empleado", out int idEmpleado))
                return;

            var confirmacion = MessageBox.Show(
                "Se marcara el empleado como inactivo. Desea continuar?",
                "Confirmar baja logica",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (confirmacion != DialogResult.Yes)
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Desactivar",
                    ("@IdEmpleado", idEmpleado));

                MostrarDatos(datos, "Empleado desactivado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void ActivarProveedor()
        {
            if (!TryObtenerIdSeleccionado("proveedor", out int idProveedor))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_Reactivar",
                    ("@IdProveedor", idProveedor));

                MostrarDatos(datos, "Proveedor activado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private void ActivarEmpleado()
        {
            if (!TryObtenerIdSeleccionado("empleado", out int idEmpleado))
                return;

            EjecutarOperacion(() =>
            {
                DataTable datos = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Reactivar",
                    ("@IdEmpleado", idEmpleado));

                MostrarDatos(datos, "Empleado activado correctamente.");
                CargarCamposDesdePrimeraFila(datos);
            });
        }

        private bool EsFormularioProveedor()
        {
            return _opcionActual?.Entidad == "Proveedores";
        }

        private bool EsFormularioEmpleado()
        {
            return _opcionActual?.Entidad == "Empleados";
        }

        private void MostrarDatos(DataTable datos, string mensaje)
        {
            _grilla.DataSource = datos;
            _etiquetaEstado.Text = mensaje;
        }

        private void EjecutarOperacion(Action operacion)
        {
            try
            {
                operacion();
            }
            catch (Exception ex)
            {
                _etiquetaEstado.Text = "Error al ejecutar la operacion.";
                MessageBox.Show(
                    ex.Message,
                    "Error de base de datos",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }

        private bool ValidarObligatorio(TextBox texto, string mensaje)
        {
            if (!string.IsNullOrWhiteSpace(texto.Text))
                return true;

            MessageBox.Show(mensaje, "Dato requerido", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            texto.Focus();
            return false;
        }

        private bool TryObtenerIdSeleccionado(string entidad, out int id)
        {
            if (int.TryParse(_idRegistroSeleccionado, out id))
                return true;

            MessageBox.Show(
                $"Seleccione un {entidad} de la grilla antes de continuar.",
                "Registro requerido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            return false;
        }

        private static object? ValorOpcional(string texto)
        {
            return string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
        }

        private void Grilla_CellClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;

            CargarCamposDesdeFila(_grilla.Rows[e.RowIndex]);
        }

        private void Grilla_MouseDown(object? sender, MouseEventArgs e)
        {
            DataGridView.HitTestInfo hit = _grilla.HitTest(e.X, e.Y);
            if (hit.Type == DataGridViewHitTestType.Cell && hit.RowIndex >= 0)
                return;

            _grilla.ClearSelection();
            LimpiarCampos();
        }

        private void CargarCamposDesdePrimeraFila(DataTable datos)
        {
            if (datos.Rows.Count == 0)
                return;

            DataRow fila = datos.Rows[0];
            CargarIdSeleccionado(fila);
            for (int i = 0; i < _textosCampos.Length; i++)
                _textosCampos[i].Text = Texto(fila, _columnasCampos[i]);
        }

        private void CargarCamposDesdeFila(DataGridViewRow fila)
        {
            CargarIdSeleccionado(fila);
            for (int i = 0; i < _textosCampos.Length; i++)
                _textosCampos[i].Text = Texto(fila, _columnasCampos[i]);
        }

        private void CargarIdSeleccionado(DataRow fila)
        {
            _idRegistroSeleccionado = _opcionActual == null
                ? null
                : Texto(fila, _opcionActual.ColumnaId);
            _activoRegistroSeleccionado = ObtenerActivoSeleccionado(Texto(fila, "Activo"));
            ActualizarTituloEntidad();
        }

        private void CargarIdSeleccionado(DataGridViewRow fila)
        {
            _idRegistroSeleccionado = _opcionActual == null
                ? null
                : Texto(fila, _opcionActual.ColumnaId);
            _activoRegistroSeleccionado = ObtenerActivoSeleccionado(Texto(fila, "Activo"));
            ActualizarTituloEntidad();
        }

        private static bool? ObtenerActivoSeleccionado(string valor)
        {
            if (string.IsNullOrWhiteSpace(valor))
                return null;

            if (valor == "1" ||
                valor.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                valor.Equals("si", StringComparison.OrdinalIgnoreCase))
                return true;

            if (valor == "0" ||
                valor.Equals("false", StringComparison.OrdinalIgnoreCase) ||
                valor.Equals("no", StringComparison.OrdinalIgnoreCase))
                return false;

            return null;
        }

        private void ActualizarTituloEntidad()
        {
            if (_opcionActual == null)
            {
                _grupoEntidad.Text = "Entidad";
                return;
            }

            _grupoEntidad.Text = string.IsNullOrWhiteSpace(_idRegistroSeleccionado)
                ? _opcionActual.Entidad
                : $"{_opcionActual.Entidad} - seleccionado #{_idRegistroSeleccionado}";
        }

        private static string Texto(DataRow fila, string columna)
        {
            if (string.IsNullOrWhiteSpace(columna) ||
                !fila.Table.Columns.Contains(columna) ||
                fila[columna] == DBNull.Value)
                return string.Empty;

            return Convert.ToString(fila[columna]) ?? string.Empty;
        }

        private static string Texto(DataGridViewRow fila, string columna)
        {
            if (string.IsNullOrWhiteSpace(columna) ||
                fila.DataGridView == null ||
                !fila.DataGridView.Columns.Contains(columna))
                return string.Empty;

            object? valor = fila.Cells[columna].Value;
            if (valor == null || valor == DBNull.Value)
                return string.Empty;

            return Convert.ToString(valor) ?? string.Empty;
        }

        private void LimpiarCampos()
        {
            foreach (TextBox texto in _textosCampos)
                texto.Clear();

            _idRegistroSeleccionado = null;
            _activoRegistroSeleccionado = null;
            ActualizarTituloEntidad();

            if (_textosCampos.Length > 0 && _textosCampos[0].Visible)
                _textosCampos[0].Focus();
        }

        private sealed class OpcionConsulta
        {
            public string Texto { get; }
            public string Sql { get; }
            public string Entidad { get; }
            public string ColumnaId { get; }
            public bool PermiteAcciones { get; }
            public CampoFormulario[] Campos { get; }

            public OpcionConsulta(
                string texto,
                string sql,
                string entidad,
                string columnaId,
                bool permiteAcciones,
                params (string Etiqueta, string Columna)[] campos)
            {
                Texto = texto;
                Sql = sql;
                Entidad = entidad;
                ColumnaId = columnaId;
                PermiteAcciones = permiteAcciones;
                Campos = new CampoFormulario[6];

                for (int i = 0; i < Campos.Length; i++)
                {
                    var campo = i < campos.Length ? campos[i] : (string.Empty, string.Empty);
                    Campos[i] = new CampoFormulario(campo.Item1, campo.Item2);
                }
            }

            public override string ToString() => Texto;
        }

        private sealed class CampoFormulario
        {
            public string Etiqueta { get; }
            public string Columna { get; }

            public CampoFormulario(string etiqueta, string columna)
            {
                Etiqueta = etiqueta;
                Columna = columna;
            }
        }
    }
}
