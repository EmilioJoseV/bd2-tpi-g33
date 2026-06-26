using System;
using System.Collections.Generic;
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
        private MenuStrip _menuPrincipal = null!;
        private ToolStripMenuItem _menuPrincipalEditar = null!;
        private ToolStripMenuItem _menuPrincipalCambiarEstado = null!;
        private ContextMenuStrip _menuRegistro = null!;
        private ToolStripMenuItem _menuEditar = null!;
        private ToolStripMenuItem _menuCambiarEstado = null!;
        private DataGridViewRow? _filaSeleccionada;

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
                Padding = new Padding(0),
                ColumnCount = 1,
                RowCount = 4
            };
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 78));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));

            _menuPrincipal = CrearMenuPrincipal();

            var panelConsulta = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 3,
                RowCount = 2,
                Padding = new Padding(14, 8, 14, 0),
                Margin = new Padding(0, 0, 0, 8)
            };
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 78));
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 430));
            panelConsulta.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 112));
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

            _grilla = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                Margin = new Padding(14, 0, 14, 0)
            };
            _grilla.CellClick += Grilla_CellClick;

            _menuEditar = new ToolStripMenuItem("Editar");
            _menuEditar.Click += (_, _) => EditarRegistroSeleccionado();

            _menuCambiarEstado = new ToolStripMenuItem("Inactivar");
            _menuCambiarEstado.Click += (_, _) => CambiarEstadoRegistroSeleccionado();

            _menuRegistro = new ContextMenuStrip();
            _menuRegistro.Items.Add(_menuEditar);
            _menuRegistro.Items.Add(_menuCambiarEstado);

            _etiquetaEstado = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                ForeColor = Color.DimGray,
                Padding = new Padding(14, 0, 14, 0)
            };

            contenedor.Controls.Add(_menuPrincipal, 0, 0);
            contenedor.Controls.Add(panelConsulta, 0, 1);
            contenedor.Controls.Add(_grilla, 0, 2);
            contenedor.Controls.Add(_etiquetaEstado, 0, 3);
            Controls.Add(contenedor);
            MainMenuStrip = _menuPrincipal;
        }

        private MenuStrip CrearMenuPrincipal()
        {
            var menu = new MenuStrip
            {
                Dock = DockStyle.Fill,
                BackColor = Color.Gainsboro,
                Padding = new Padding(6, 3, 0, 3)
            };

            var operaciones = new ToolStripMenuItem("Operaciones");
            operaciones.DropDownItems.Add(CrearItemMenu("Nueva venta", () => AbrirFormularioRegistro(TipoRegistro.Venta)));
            operaciones.DropDownItems.Add(CrearItemMenu("Nueva compra", () => AbrirFormularioRegistro(TipoRegistro.Compra)));

            var registros = new ToolStripMenuItem("Registros");
            registros.DropDownItems.Add(CrearItemMenu("Nuevo proveedor", () => AbrirFormularioRegistro(TipoRegistro.Proveedor)));
            registros.DropDownItems.Add(CrearItemMenu("Nuevo cliente", () => AbrirFormularioRegistro(TipoRegistro.Cliente)));
            registros.DropDownItems.Add(CrearItemMenu("Nuevo empleado", () => AbrirFormularioRegistro(TipoRegistro.Empleado)));
            registros.DropDownItems.Add(new ToolStripSeparator());
            _menuPrincipalEditar = CrearItemMenu("Editar seleccionado", EditarRegistroSeleccionado);
            _menuPrincipalCambiarEstado = CrearItemMenu("Activar/Inactivar seleccionado", CambiarEstadoRegistroSeleccionado);
            registros.DropDownItems.Add(_menuPrincipalEditar);
            registros.DropDownItems.Add(_menuPrincipalCambiarEstado);
            registros.DropDownOpening += (_, _) => ActualizarMenuGestionSeleccion();

            var consultas = new ToolStripMenuItem("Consultas");
            consultas.DropDownItems.Add(CrearItemMenu("Proveedores", () => SeleccionarApartado("Proveedores")));
            consultas.DropDownItems.Add(CrearItemMenu("Clientes", () => SeleccionarApartado("Clientes")));
            consultas.DropDownItems.Add(CrearItemMenu("Empleados", () => SeleccionarApartado("Empleados")));
            consultas.DropDownItems.Add(CrearItemMenu("Productos", () => SeleccionarApartado("Productos")));
            consultas.DropDownItems.Add(CrearItemMenu("Ventas", () => SeleccionarApartado("Ventas")));
            consultas.DropDownItems.Add(CrearItemMenu("Compras", () => SeleccionarApartado("Compras")));

            var configuracion = new ToolStripMenuItem("Configuracion");
            configuracion.DropDownItems.Add(CrearItemMenu("Nueva categoria", () => AbrirFormularioRegistro(TipoRegistro.Categoria)));
            configuracion.DropDownItems.Add(CrearItemMenu("Nuevo talle", () => AbrirFormularioRegistro(TipoRegistro.Talle)));
            configuracion.DropDownItems.Add(CrearItemMenu("Nueva marca", () => AbrirFormularioRegistro(TipoRegistro.Marca)));
            configuracion.DropDownItems.Add(CrearItemMenu("Nuevo color", () => AbrirFormularioRegistro(TipoRegistro.Color)));
            configuracion.DropDownItems.Add(new ToolStripSeparator());
            configuracion.DropDownItems.Add(CrearItemMenu("Ver categorias", () => SeleccionarApartado("Categorias")));
            configuracion.DropDownItems.Add(CrearItemMenu("Ver talles", () => SeleccionarApartado("Talles")));
            configuracion.DropDownItems.Add(CrearItemMenu("Ver marcas", () => SeleccionarApartado("Marcas")));
            configuracion.DropDownItems.Add(CrearItemMenu("Ver colores", () => SeleccionarApartado("Colores")));

            menu.Items.Add(operaciones);
            menu.Items.Add(registros);
            menu.Items.Add(consultas);
            menu.Items.Add(configuracion);
            return menu;
        }

        private static ToolStripMenuItem CrearItemMenu(string texto, Action accion)
        {
            var item = new ToolStripMenuItem(texto);
            item.Click += (_, _) => accion();
            return item;
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

        private void CargarOpciones()
        {
            _comboConsultas.Items.Add(new OpcionConsulta(
                "Proveedores",
                "SELECT IdProveedor, RazonSocial, CUIT, Email, Telefono, Direccion, Activo " +
                "FROM Proveedores ORDER BY RazonSocial",
                "Proveedores",
                "IdProveedor",
                TipoRegistro.Proveedor));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Clientes",
                "SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, Activo " +
                "FROM Clientes ORDER BY Apellido, Nombre",
                "Clientes",
                "IdCliente",
                TipoRegistro.Cliente));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Empleados",
                "SELECT IdEmpleado, Apellido, Nombre, Documento, Email, Telefono, FechaAlta, Activo " +
                "FROM Empleados ORDER BY Apellido, Nombre",
                "Empleados",
                "IdEmpleado",
                TipoRegistro.Empleado));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Productos",
                "SELECT * FROM Productos",
                "Productos",
                "IdProducto",
                null));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Categorias",
                "SELECT IdCategoria, Nombre, Descripcion, Activo FROM Categorias ORDER BY Nombre",
                "Categorias",
                "IdCategoria",
                TipoRegistro.Categoria));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Talles",
                "SELECT IdTalle, Nombre, Descripcion, Activo FROM Talles ORDER BY Nombre",
                "Talles",
                "IdTalle",
                TipoRegistro.Talle));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Marcas",
                "SELECT IdMarca, Nombre, Descripcion, Activo FROM Marcas ORDER BY Nombre",
                "Marcas",
                "IdMarca",
                TipoRegistro.Marca));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Colores",
                "SELECT IdColor, Nombre, Activo FROM Colores ORDER BY Nombre",
                "Colores",
                "IdColor",
                TipoRegistro.Color));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Ventas",
                "SELECT IdVenta, IdCliente, IdEmpleado, IdMedioPago, IdEstadoVenta, FechaVenta, Total " +
                "FROM Ventas ORDER BY FechaVenta DESC",
                "Ventas",
                "IdVenta",
                TipoRegistro.Venta));

            _comboConsultas.Items.Add(new OpcionConsulta(
                "Compras",
                "SELECT IdCompra, IdProveedor, IdEmpleado, IdEstadoCompra, FechaCompra, NumeroComprobante, Total " +
                "FROM Compras ORDER BY FechaCompra DESC",
                "Compras",
                "IdCompra",
                TipoRegistro.Compra));

            if (_comboConsultas.Items.Count > 0)
                _comboConsultas.SelectedIndex = 0;
        }

        private void ComboConsultas_SelectedIndexChanged(object? sender, EventArgs e)
        {
            if (_comboConsultas.SelectedItem is not OpcionConsulta opcion)
                return;

            CargarVistasParaTabla(opcion);
            EjecutarConsultaSeleccionada();
        }

        private void CargarVistasParaTabla(OpcionConsulta opcion)
        {
            _comboVistas.Items.Clear();
            _comboVistas.Enabled = false;
            _comboVistas.Items.Add($"Sin vistas de {opcion.Entidad}");
            _comboVistas.SelectedIndex = 0;
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

        private void Grilla_CellClick(object? sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex < 0)
                return;

            _filaSeleccionada = _grilla.Rows[e.RowIndex];
            bool permiteGestion = PermiteGestionarSeleccion();
            bool estaActivo = ObtenerActivo(_filaSeleccionada);

            _menuEditar.Enabled = permiteGestion;
            _menuCambiarEstado.Enabled = permiteGestion;
            _menuCambiarEstado.Text = estaActivo ? "Inactivar" : "Activar";
            _menuRegistro.Show(_grilla, _grilla.PointToClient(Cursor.Position));
        }

        private bool PermiteGestionarSeleccion()
        {
            TipoRegistro? tipo = ObtenerOpcionActual()?.TipoRegistro;
            return tipo == TipoRegistro.Proveedor ||
                tipo == TipoRegistro.Empleado ||
                tipo == TipoRegistro.Categoria ||
                tipo == TipoRegistro.Talle ||
                tipo == TipoRegistro.Marca ||
                tipo == TipoRegistro.Color;
        }

        private void ActualizarMenuGestionSeleccion()
        {
            bool permiteGestion = _filaSeleccionada != null && PermiteGestionarSeleccion();
            bool estaActivo = _filaSeleccionada != null && ObtenerActivo(_filaSeleccionada);

            _menuPrincipalEditar.Enabled = permiteGestion;
            _menuPrincipalCambiarEstado.Enabled = permiteGestion;
            _menuPrincipalCambiarEstado.Text = estaActivo
                ? "Inactivar seleccionado"
                : "Activar seleccionado";
        }

        private void EditarRegistroSeleccionado()
        {
            OpcionConsulta? opcion = ObtenerOpcionActual();
            if (opcion == null || _filaSeleccionada == null || !PermiteGestionarSeleccion())
                return;

            if (!TryObtenerIdSeleccionado(opcion, out int idRegistro))
                return;

            TipoRegistro tipoRegistro = opcion.TipoRegistro!.Value;
            using (var formulario = new FormRegistro(
                tipoRegistro,
                modoEdicion: true,
                idRegistro: idRegistro,
                activoInicial: ObtenerActivo(_filaSeleccionada),
                valoresIniciales: ValoresParaEdicion(tipoRegistro, _filaSeleccionada)))
            {
                if (formulario.ShowDialog(this) != DialogResult.OK || formulario.Resultado == null)
                    return;

                MostrarDatos(formulario.Resultado, formulario.MensajeResultado);
            }
        }

        private void CambiarEstadoRegistroSeleccionado()
        {
            OpcionConsulta? opcion = ObtenerOpcionActual();
            if (opcion == null || _filaSeleccionada == null || !PermiteGestionarSeleccion())
                return;

            if (!TryObtenerIdSeleccionado(opcion, out int idRegistro))
                return;

            string entidad = NombreEntidad(opcion.TipoRegistro);
            bool estaActivo = ObtenerActivo(_filaSeleccionada);
            string accion = estaActivo ? "inactivar" : "activar";
            var confirmacion = MessageBox.Show(
                $"Se va a {accion} el {entidad} seleccionado. Desea continuar?",
                $"Confirmar {accion}",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (confirmacion != DialogResult.Yes)
                return;

            EjecutarOperacion(() =>
            {
                CambiarEstado(opcion.TipoRegistro, idRegistro, estaActivo);

                RefrescarConsultaActual($"{MayusculaInicial(entidad)} {(estaActivo ? "inactivado" : "activado")} correctamente.");
            });
        }

        private void AbrirFormularioRegistro(TipoRegistro tipoRegistro)
        {
            using (var formulario = new FormRegistro(tipoRegistro))
            {
                if (formulario.ShowDialog(this) != DialogResult.OK)
                    return;

                if (formulario.Resultado == null)
                {
                    _etiquetaEstado.Text = formulario.MensajeResultado;
                    return;
                }

                SeleccionarApartado(EntidadParaRegistro(tipoRegistro));
                MostrarDatos(formulario.Resultado, formulario.MensajeResultado);
            }
        }

        private void SeleccionarApartado(string entidad)
        {
            for (int i = 0; i < _comboConsultas.Items.Count; i++)
            {
                if (_comboConsultas.Items[i] is OpcionConsulta opcion && opcion.Entidad == entidad)
                {
                    _comboConsultas.SelectedIndex = i;
                    EjecutarConsultaSeleccionada();
                    return;
                }
            }
        }

        private static string EntidadParaRegistro(TipoRegistro tipoRegistro)
        {
            switch (tipoRegistro)
            {
                case TipoRegistro.Compra:
                    return "Compras";
                case TipoRegistro.Venta:
                    return "Ventas";
                case TipoRegistro.Proveedor:
                    return "Proveedores";
                case TipoRegistro.Empleado:
                    return "Empleados";
                case TipoRegistro.Categoria:
                    return "Categorias";
                case TipoRegistro.Talle:
                    return "Talles";
                case TipoRegistro.Marca:
                    return "Marcas";
                case TipoRegistro.Color:
                    return "Colores";
                default:
                    return "Clientes";
            }
        }

        private void MostrarDatos(DataTable datos, string mensaje)
        {
            _grilla.DataSource = datos;
            _filaSeleccionada = null;
            _etiquetaEstado.Text = mensaje;
        }

        private void RefrescarConsultaActual(string mensaje)
        {
            if (_comboConsultas.SelectedItem is not OpcionConsulta opcion)
                return;

            DataTable datos = Conexion.EjecutarConsulta(opcion.Sql);
            MostrarDatos(datos, mensaje);
        }

        private OpcionConsulta? ObtenerOpcionActual()
        {
            return _comboConsultas.SelectedItem as OpcionConsulta;
        }

        private bool TryObtenerIdSeleccionado(OpcionConsulta opcion, out int idRegistro)
        {
            idRegistro = 0;
            if (_filaSeleccionada == null)
                return false;

            string valor = Texto(_filaSeleccionada, opcion.ColumnaId);
            if (int.TryParse(valor, out idRegistro))
                return true;

            MessageBox.Show(
                "No se pudo identificar el registro seleccionado.",
                "Registro requerido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            return false;
        }

        private static Dictionary<string, string> ValoresParaEdicion(TipoRegistro tipoRegistro, DataGridViewRow fila)
        {
            if (tipoRegistro == TipoRegistro.Proveedor)
            {
                return new Dictionary<string, string>
                {
                    ["RazonSocial"] = Texto(fila, "RazonSocial"),
                    ["CUIT"] = Texto(fila, "CUIT"),
                    ["Email"] = Texto(fila, "Email"),
                    ["Telefono"] = Texto(fila, "Telefono"),
                    ["Direccion"] = Texto(fila, "Direccion")
                };
            }

            if (tipoRegistro == TipoRegistro.Categoria ||
                tipoRegistro == TipoRegistro.Talle ||
                tipoRegistro == TipoRegistro.Marca)
            {
                return new Dictionary<string, string>
                {
                    ["Nombre"] = Texto(fila, "Nombre"),
                    ["Descripcion"] = Texto(fila, "Descripcion")
                };
            }

            if (tipoRegistro == TipoRegistro.Color)
            {
                return new Dictionary<string, string>
                {
                    ["Nombre"] = Texto(fila, "Nombre")
                };
            }

            return new Dictionary<string, string>
            {
                ["Apellido"] = Texto(fila, "Apellido"),
                ["Nombre"] = Texto(fila, "Nombre"),
                ["Documento"] = Texto(fila, "Documento"),
                ["Email"] = Texto(fila, "Email"),
                ["Telefono"] = Texto(fila, "Telefono")
            };
        }

        private static bool ObtenerActivo(DataGridViewRow fila)
        {
            string valor = Texto(fila, "Activo");
            return valor == "1" ||
                valor.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                valor.Equals("si", StringComparison.OrdinalIgnoreCase);
        }

        private static string Texto(DataGridViewRow fila, string columna)
        {
            if (fila.DataGridView == null || !fila.DataGridView.Columns.Contains(columna))
                return string.Empty;

            object? valor = fila.Cells[columna].Value;
            if (valor == null || valor == DBNull.Value)
                return string.Empty;

            return Convert.ToString(valor) ?? string.Empty;
        }

        private static string MayusculaInicial(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto))
                return texto;

            return char.ToUpperInvariant(texto[0]) + texto.Substring(1);
        }

        private static string NombreEntidad(TipoRegistro? tipoRegistro)
        {
            switch (tipoRegistro)
            {
                case TipoRegistro.Proveedor:
                    return "proveedor";
                case TipoRegistro.Empleado:
                    return "empleado";
                case TipoRegistro.Categoria:
                    return "categoria";
                case TipoRegistro.Talle:
                    return "talle";
                case TipoRegistro.Marca:
                    return "marca";
                case TipoRegistro.Color:
                    return "color";
                default:
                    return "registro";
            }
        }

        private static void CambiarEstado(TipoRegistro? tipoRegistro, int idRegistro, bool estaActivo)
        {
            switch (tipoRegistro)
            {
                case TipoRegistro.Proveedor:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Proveedor_Desactivar" : "dbo.SP_Proveedor_Reactivar",
                        ("@IdProveedor", idRegistro));
                    break;

                case TipoRegistro.Empleado:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Empleado_Desactivar" : "dbo.SP_Empleado_Reactivar",
                        ("@IdEmpleado", idRegistro));
                    break;

                case TipoRegistro.Categoria:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Categoria_Desactivar" : "dbo.SP_Categoria_Reactivar",
                        ("@IdCategoria", idRegistro));
                    break;

                case TipoRegistro.Talle:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Talle_Desactivar" : "dbo.SP_Talle_Reactivar",
                        ("@IdTalle", idRegistro));
                    break;

                case TipoRegistro.Marca:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Marca_Desactivar" : "dbo.SP_Marca_Reactivar",
                        ("@IdMarca", idRegistro));
                    break;

                case TipoRegistro.Color:
                    Conexion.EjecutarProcedimiento(
                        estaActivo ? "dbo.SP_Color_Desactivar" : "dbo.SP_Color_Reactivar",
                        ("@IdColor", idRegistro));
                    break;
            }
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

        private sealed class OpcionConsulta
        {
            public string Texto { get; }
            public string Sql { get; }
            public string Entidad { get; }
            public string ColumnaId { get; }
            public TipoRegistro? TipoRegistro { get; }

            public OpcionConsulta(
                string texto,
                string sql,
                string entidad,
                string columnaId,
                TipoRegistro? tipoRegistro)
            {
                Texto = texto;
                Sql = sql;
                Entidad = entidad;
                ColumnaId = columnaId;
                TipoRegistro = tipoRegistro;
            }

            public override string ToString() => Texto;
        }
    }
}
