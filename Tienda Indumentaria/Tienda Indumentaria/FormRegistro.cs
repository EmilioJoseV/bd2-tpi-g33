using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    public enum TipoRegistro
    {
        Compra,
        Venta,
        Proveedor,
        Cliente,
        Empleado,
        Producto,
        Categoria,
        Talle,
        Marca,
        Color
    }

    public class FormRegistro : Form
    {
        private readonly TipoRegistro _tipoRegistro;
        private readonly bool _modoEdicion;
        private readonly int? _idRegistro;
        private readonly bool _activoInicial;
        private readonly IReadOnlyDictionary<string, string> _valoresIniciales;
        private readonly Dictionary<string, TextBox> _campos = new Dictionary<string, TextBox>();
        private readonly Dictionary<string, ComboBox> _listas = new Dictionary<string, ComboBox>();
        private TextBox? _textoTotal;
        private Button _botonConfirmar = null!;
        private Button _botonCancelar = null!;

        public DataTable? Resultado { get; private set; }
        public string MensajeResultado { get; private set; } = string.Empty;

        public FormRegistro(
            TipoRegistro tipoRegistro,
            bool modoEdicion = false,
            int? idRegistro = null,
            bool activoInicial = true,
            IReadOnlyDictionary<string, string>? valoresIniciales = null)
        {
            _tipoRegistro = tipoRegistro;
            _modoEdicion = modoEdicion;
            _idRegistro = idRegistro;
            _activoInicial = activoInicial;
            _valoresIniciales = valoresIniciales ?? new Dictionary<string, string>();
            ConstruirInterfaz();
            CargarValoresIniciales();
            ActualizarTotal();
        }

        private void ConstruirInterfaz()
        {
            Text = TituloFormulario();
            Width = 500;
            Height = AltoFormulario();
            MinimumSize = new Size(500, AltoFormulario());
            MaximumSize = new Size(500, AltoFormulario());
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            MinimizeBox = false;

            var campos = CamposFormulario();
            var contenedor = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                Padding = new Padding(16),
                ColumnCount = 2,
                RowCount = campos.Length + 1
            };

            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 155));
            contenedor.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

            for (int i = 0; i < campos.Length; i++)
                contenedor.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
            contenedor.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            for (int i = 0; i < campos.Length; i++)
                AgregarCampo(contenedor, i, campos[i].Clave, campos[i].Etiqueta, campos[i].SoloLectura);

            if (_campos.TryGetValue("Cantidad", out TextBox? textoCantidad))
                textoCantidad.TextChanged += (_, _) => ActualizarTotal();

            if (_campos.TryGetValue("PrecioUnitario", out TextBox? textoPrecio))
                textoPrecio.TextChanged += (_, _) => ActualizarTotal();

            _botonConfirmar = new Button
            {
                Text = _modoEdicion ? "Guardar" : "Confirmar",
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

            contenedor.Controls.Add(panelBotones, 0, campos.Length);
            contenedor.SetColumnSpan(panelBotones, 2);

            AcceptButton = _botonConfirmar;
            CancelButton = _botonCancelar;
            Controls.Add(contenedor);
        }

        private void AgregarCampo(
            TableLayoutPanel contenedor,
            int fila,
            string clave,
            string etiqueta,
            bool soloLectura)
        {
            if (EsCampoLista(clave))
            {
                var lista = new ComboBox
                {
                    Dock = DockStyle.Fill,
                    DropDownStyle = ComboBoxStyle.DropDownList,
                    Margin = new Padding(0, 4, 0, 4)
                };

                CargarLista(lista, clave);

                contenedor.Controls.Add(CrearEtiquetaCampo(etiqueta, EsCampoObligatorio(clave)), 0, fila);
                contenedor.Controls.Add(lista, 1, fila);
                _listas[clave] = lista;
                return;
            }

            var texto = new TextBox
            {
                Dock = DockStyle.Fill,
                BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(0, 4, 0, 4),
                ReadOnly = soloLectura
            };

            if (soloLectura)
                texto.BackColor = SystemColors.Control;

            contenedor.Controls.Add(CrearEtiquetaCampo(etiqueta, EsCampoObligatorio(clave)), 0, fila);

            contenedor.Controls.Add(texto, 1, fila);
            _campos[clave] = texto;

            if (clave == "Total")
                _textoTotal = texto;
        }

        private static Control CrearEtiquetaCampo(string etiqueta, bool obligatorio)
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
                Text = etiqueta,
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

        private void CargarValoresIniciales()
        {
            foreach ((string clave, string valor) in _valoresIniciales)
            {
                if (_campos.TryGetValue(clave, out TextBox? texto))
                {
                    texto.Text = valor;
                    continue;
                }

                if (_listas.TryGetValue(clave, out ComboBox? lista) &&
                    int.TryParse(valor, out int idSeleccionado))
                {
                    lista.SelectedValue = idSeleccionado;
                }
            }
        }

        private void BtnConfirmar_Click(object? sender, EventArgs e)
        {
            if (!ValidarCampos())
                return;

            if (_tipoRegistro == TipoRegistro.Proveedor)
            {
                if (_modoEdicion)
                    ActualizarProveedor();
                else
                    RegistrarProveedor();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Cliente)
            {
                if (_modoEdicion)
                    ActualizarCliente();
                else
                    RegistrarCliente();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Empleado)
            {
                if (_modoEdicion)
                    ActualizarEmpleado();
                else
                    RegistrarEmpleado();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Producto)
            {
                if (_modoEdicion)
                    ActualizarProducto();
                else
                    RegistrarProducto();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Categoria)
            {
                if (_modoEdicion)
                    ActualizarCategoria();
                else
                    RegistrarCategoria();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Talle)
            {
                if (_modoEdicion)
                    ActualizarTalle();
                else
                    RegistrarTalle();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Marca)
            {
                if (_modoEdicion)
                    ActualizarMarca();
                else
                    RegistrarMarca();
                return;
            }

            if (_tipoRegistro == TipoRegistro.Color)
            {
                if (_modoEdicion)
                    ActualizarColor();
                else
                    RegistrarColor();
                return;
            }

            ConfirmarSinPersistir();
        }

        private void RegistrarProveedor()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_Registrar",
                    ("@RazonSocial", ValorCampo("RazonSocial")),
                    ("@CUIT", ValorCampo("CUIT")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")),
                    ("@Direccion", ValorOpcional("Direccion")));

                MensajeResultado = "Proveedor registrado correctamente.";
            });
        }

        private void ActualizarProveedor()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Proveedor_Actualizar",
                    ("@IdProveedor", _idRegistro.Value),
                    ("@RazonSocial", ValorCampo("RazonSocial")),
                    ("@CUIT", ValorCampo("CUIT")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")),
                    ("@Direccion", ValorOpcional("Direccion")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Proveedor actualizado correctamente.";
            });
        }

        private void RegistrarCliente()
        {
            EjecutarRegistro(() =>
            {
                Conexion.EjecutarProcedimientoConValidacion(
                    "dbo.SP_Cliente_Registrar",
                    "Cliente registrado",
                    ("@Apellido", ValorCampo("Apellido")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Documento", ValorCampo("Documento")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")));

                Resultado = Conexion.EjecutarConsulta(
                    "SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, Activo " +
                    "FROM Clientes WHERE Documento = @Documento",
                    ("@Documento", ValorCampo("Documento")));

                MensajeResultado = "Cliente registrado correctamente.";
            });
        }

        private void ActualizarCliente()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Conexion.EjecutarProcedimientoConValidacion(
                    "dbo.SP_Cliente_Actualizar",
                    "Cliente actualizado",
                    ("@IdCliente", _idRegistro.Value),
                    ("@Apellido", ValorCampo("Apellido")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Documento", ValorCampo("Documento")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")),
                    ("@Activo", _activoInicial));

                Resultado = Conexion.EjecutarConsulta(
                    "SELECT IdCliente, Apellido, Nombre, Documento, Email, Telefono, Activo " +
                    "FROM Clientes WHERE IdCliente = @IdCliente",
                    ("@IdCliente", _idRegistro.Value));

                MensajeResultado = "Cliente actualizado correctamente.";
            });
        }

        private void RegistrarEmpleado()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Registrar",
                    ("@Apellido", ValorCampo("Apellido")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Documento", ValorCampo("Documento")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")));

                MensajeResultado = "Empleado registrado correctamente.";
            });
        }

        private void ActualizarEmpleado()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Empleado_Actualizar",
                    ("@IdEmpleado", _idRegistro.Value),
                    ("@Apellido", ValorCampo("Apellido")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Documento", ValorCampo("Documento")),
                    ("@Email", ValorOpcional("Email")),
                    ("@Telefono", ValorOpcional("Telefono")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Empleado actualizado correctamente.";
            });
        }

        private void RegistrarProducto()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Producto_Registrar",
                    ("@IdCategoria", EnteroCampo("IdCategoria")),
                    ("@IdMarca", EnteroCampo("IdMarca")),
                    ("@IdTalle", EnteroCampo("IdTalle")),
                    ("@IdColor", EnteroCampo("IdColor")),
                    ("@CodigoProducto", ValorCampo("CodigoProducto")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")),
                    ("@PrecioVenta", DecimalCampo("PrecioVenta")),
                    ("@StockActual", EnteroCampo("StockActual")),
                    ("@StockMinimo", EnteroCampo("StockMinimo")));

                MensajeResultado = "Producto registrado correctamente.";
            });
        }

        private void ActualizarProducto()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Producto_Actualizar",
                    ("@IdProducto", _idRegistro.Value),
                    ("@IdCategoria", EnteroCampo("IdCategoria")),
                    ("@IdMarca", EnteroCampo("IdMarca")),
                    ("@IdTalle", EnteroCampo("IdTalle")),
                    ("@IdColor", EnteroCampo("IdColor")),
                    ("@CodigoProducto", ValorCampo("CodigoProducto")),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")),
                    ("@PrecioVenta", DecimalCampo("PrecioVenta")),
                    ("@StockActual", EnteroCampo("StockActual")),
                    ("@StockMinimo", EnteroCampo("StockMinimo")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Producto actualizado correctamente.";
            });
        }

        private void RegistrarCategoria()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Categoria_Registrar",
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")));

                MensajeResultado = "Categoria registrada correctamente.";
            });
        }

        private void ActualizarCategoria()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Categoria_Actualizar",
                    ("@IdCategoria", _idRegistro.Value),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Categoria actualizada correctamente.";
            });
        }

        private void RegistrarTalle()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Talle_Registrar",
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")));

                MensajeResultado = "Talle registrado correctamente.";
            });
        }

        private void ActualizarTalle()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Talle_Actualizar",
                    ("@IdTalle", _idRegistro.Value),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Talle actualizado correctamente.";
            });
        }

        private void RegistrarMarca()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Marca_Registrar",
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")));

                MensajeResultado = "Marca registrada correctamente.";
            });
        }

        private void ActualizarMarca()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Marca_Actualizar",
                    ("@IdMarca", _idRegistro.Value),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Descripcion", ValorOpcional("Descripcion")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Marca actualizada correctamente.";
            });
        }

        private void RegistrarColor()
        {
            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Color_Registrar",
                    ("@Nombre", ValorCampo("Nombre")));

                MensajeResultado = "Color registrado correctamente.";
            });
        }

        private void ActualizarColor()
        {
            if (!_idRegistro.HasValue)
                return;

            EjecutarRegistro(() =>
            {
                Resultado = Conexion.EjecutarProcedimiento(
                    "dbo.SP_Color_Actualizar",
                    ("@IdColor", _idRegistro.Value),
                    ("@Nombre", ValorCampo("Nombre")),
                    ("@Activo", _activoInicial));

                MensajeResultado = "Color actualizado correctamente.";
            });
        }

        private void ConfirmarSinPersistir()
        {
            MensajeResultado = $"Formulario de {NombreRegistro()} cargado. No se guardo en la base de datos.";
            DialogResult = DialogResult.OK;
            Close();
        }

        private void EjecutarRegistro(Action registro)
        {
            try
            {
                registro();
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
            foreach ((string clave, TextBox texto) in _campos)
            {
                if (!EsCampoObligatorio(clave))
                    continue;

                if (string.IsNullOrWhiteSpace(texto.Text))
                {
                    MostrarDatoRequerido(texto, EtiquetaCampo(clave));
                    return false;
                }
            }

            if (EsOperacion())
            {
                if (!TryObtenerEntero("Cantidad", "cantidad", out int cantidad) || cantidad <= 0)
                {
                    MostrarDatoInvalido(_campos["Cantidad"], "Ingrese una cantidad mayor a cero.");
                    return false;
                }

                if (!TryObtenerDecimal("PrecioUnitario", out decimal precioUnitario) || precioUnitario <= 0)
                {
                    MostrarDatoInvalido(_campos["PrecioUnitario"], "Ingrese un precio unitario valido.");
                    return false;
                }
            }

            if (EsProducto())
            {
                if (!TryObtenerEntero("IdCategoria", "categoria", out int idCategoria) || idCategoria <= 0)
                {
                    MostrarDatoInvalido(_listas["IdCategoria"], "Seleccione una categoria valida.");
                    return false;
                }

                if (!TryObtenerEntero("IdMarca", "marca", out int idMarca) || idMarca <= 0)
                {
                    MostrarDatoInvalido(_listas["IdMarca"], "Seleccione una marca valida.");
                    return false;
                }

                if (!TryObtenerEntero("IdTalle", "talle", out int idTalle) || idTalle <= 0)
                {
                    MostrarDatoInvalido(_listas["IdTalle"], "Seleccione un talle valido.");
                    return false;
                }

                if (!TryObtenerEntero("IdColor", "color", out int idColor) || idColor <= 0)
                {
                    MostrarDatoInvalido(_listas["IdColor"], "Seleccione un color valido.");
                    return false;
                }

                if (!TryObtenerDecimal("PrecioVenta", out decimal precioVenta) || precioVenta < 0)
                {
                    MostrarDatoInvalido(_campos["PrecioVenta"], "Ingrese un precio de venta valido.");
                    return false;
                }

                if (!TryObtenerEntero("StockActual", "stock actual", out int stockActual) || stockActual < 0)
                {
                    MostrarDatoInvalido(_campos["StockActual"], "Ingrese un stock actual valido.");
                    return false;
                }

                if (!TryObtenerEntero("StockMinimo", "stock minimo", out int stockMinimo) || stockMinimo < 0)
                {
                    MostrarDatoInvalido(_campos["StockMinimo"], "Ingrese un stock minimo valido.");
                    return false;
                }
            }

            return true;
        }

        private static bool EsCampoObligatorio(string clave)
        {
            return clave != "Comprobante" &&
                clave != "Descripcion" &&
                clave != "Email" &&
                clave != "Telefono" &&
                clave != "Direccion" &&
                clave != "Total";
        }

        private void ActualizarTotal()
        {
            if (_textoTotal == null)
                return;

            if (TryObtenerEntero("Cantidad", "cantidad", out int cantidad) &&
                TryObtenerDecimal("PrecioUnitario", out decimal precioUnitario) &&
                cantidad > 0 &&
                precioUnitario > 0)
            {
                _textoTotal.Text = (cantidad * precioUnitario).ToString("0.00");
                return;
            }

            _textoTotal.Clear();
        }

        private bool TryObtenerEntero(string clave, string campo, out int valor)
        {
            valor = 0;
            if (_listas.TryGetValue(clave, out ComboBox? lista))
            {
                if (lista.SelectedValue == null)
                    return false;

                return int.TryParse(Convert.ToString(lista.SelectedValue), out valor);
            }

            return _campos.TryGetValue(clave, out TextBox? texto) &&
                int.TryParse(texto.Text.Trim(), out valor);
        }

        private bool TryObtenerDecimal(string clave, out decimal valor)
        {
            valor = 0;
            if (!_campos.TryGetValue(clave, out TextBox? texto))
                return false;

            string entrada = texto.Text.Trim();
            return decimal.TryParse(entrada, NumberStyles.Number, CultureInfo.CurrentCulture, out valor) ||
                decimal.TryParse(entrada, NumberStyles.Number, CultureInfo.InvariantCulture, out valor) ||
                decimal.TryParse(entrada.Replace(',', '.'), NumberStyles.Number, CultureInfo.InvariantCulture, out valor);
        }

        private string ValorCampo(string clave)
        {
            return _campos[clave].Text.Trim();
        }

        private object? ValorOpcional(string clave)
        {
            string valor = ValorCampo(clave);
            return string.IsNullOrWhiteSpace(valor) ? null : valor;
        }

        private int EnteroCampo(string clave)
        {
            TryObtenerEntero(clave, EtiquetaCampo(clave), out int valor);
            return valor;
        }

        private decimal DecimalCampo(string clave)
        {
            TryObtenerDecimal(clave, out decimal valor);
            return valor;
        }

        private void MostrarDatoRequerido(Control control, string campo)
        {
            MessageBox.Show(
                $"Ingrese {campo}.",
                "Dato requerido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            control.Focus();
        }

        private void MostrarDatoInvalido(Control control, string mensaje)
        {
            MessageBox.Show(
                mensaje,
                "Dato invalido",
                MessageBoxButtons.OK,
                MessageBoxIcon.Warning);
            control.Focus();
        }

        private static bool EsCampoLista(string clave)
        {
            return clave == "IdCategoria" ||
                clave == "IdMarca" ||
                clave == "IdTalle" ||
                clave == "IdColor";
        }

        private static void CargarLista(ComboBox lista, string clave)
        {
            (string Tabla, string ColumnaId) = DatosLista(clave);
            DataTable datos = Conexion.EjecutarConsulta(
                $"SELECT {ColumnaId} AS Id, Nombre FROM {Tabla} WHERE Activo = 1 ORDER BY Nombre");

            DataRow seleccion = datos.NewRow();
            seleccion["Id"] = 0;
            seleccion["Nombre"] = "Seleccione...";
            datos.Rows.InsertAt(seleccion, 0);

            ComboBusqueda.Configurar(lista, datos, "Id", "Nombre");
        }

        private static (string Tabla, string ColumnaId) DatosLista(string clave)
        {
            switch (clave)
            {
                case "IdCategoria":
                    return ("Categorias", "IdCategoria");
                case "IdMarca":
                    return ("Marcas", "IdMarca");
                case "IdTalle":
                    return ("Talles", "IdTalle");
                default:
                    return ("Colores", "IdColor");
            }
        }

        private (string Clave, string Etiqueta, bool SoloLectura)[] CamposFormulario()
        {
            switch (_tipoRegistro)
            {
                case TipoRegistro.Venta:
                    return new[]
                    {
                        ("IdCliente", "Id cliente", false),
                        ("IdEmpleado", "Id empleado", false),
                        ("IdMedioPago", "Id medio pago", false),
                        ("IdProducto", "Id producto", false),
                        ("Cantidad", "Cantidad", false),
                        ("PrecioUnitario", "Precio unitario", false),
                        ("Total", "Total", true)
                    };

                case TipoRegistro.Proveedor:
                    return new[]
                    {
                        ("RazonSocial", "Razon social", false),
                        ("CUIT", "CUIT", false),
                        ("Email", "Email", false),
                        ("Telefono", "Telefono", false),
                        ("Direccion", "Direccion", false)
                    };

                case TipoRegistro.Cliente:
                case TipoRegistro.Empleado:
                    return new[]
                    {
                        ("Apellido", "Apellido", false),
                        ("Nombre", "Nombre", false),
                        ("Documento", "Documento", false),
                        ("Email", "Email", false),
                        ("Telefono", "Telefono", false)
                    };

                case TipoRegistro.Producto:
                    return new[]
                    {
                        ("IdCategoria", "Categoria", false),
                        ("IdMarca", "Marca", false),
                        ("IdTalle", "Talle", false),
                        ("IdColor", "Color", false),
                        ("CodigoProducto", "Codigo", false),
                        ("Nombre", "Nombre", false),
                        ("Descripcion", "Descripcion", false),
                        ("PrecioVenta", "Precio venta", false),
                        ("StockActual", "Stock actual", false),
                        ("StockMinimo", "Stock minimo", false)
                    };

                case TipoRegistro.Categoria:
                case TipoRegistro.Talle:
                case TipoRegistro.Marca:
                    return new[]
                    {
                        ("Nombre", "Nombre", false),
                        ("Descripcion", "Descripcion", false)
                    };

                case TipoRegistro.Color:
                    return new[]
                    {
                        ("Nombre", "Nombre", false)
                    };

                default:
                    return Array.Empty<(string Clave, string Etiqueta, bool SoloLectura)>();
            }
        }

        private string TituloFormulario()
        {
            return _modoEdicion
                ? $"Editar {NombreRegistro()}"
                : $"Registrar {NombreRegistro()}";
        }

        private string NombreRegistro()
        {
            switch (_tipoRegistro)
            {
                case TipoRegistro.Compra:
                    return "compra";
                case TipoRegistro.Venta:
                    return "venta";
                case TipoRegistro.Proveedor:
                    return "proveedor";
                case TipoRegistro.Cliente:
                    return "cliente";
                case TipoRegistro.Producto:
                    return "producto";
                case TipoRegistro.Categoria:
                    return "categoria";
                case TipoRegistro.Talle:
                    return "talle";
                case TipoRegistro.Marca:
                    return "marca";
                case TipoRegistro.Color:
                    return "color";
                default:
                    return "empleado";
            }
        }

        private string EtiquetaCampo(string clave)
        {
            foreach ((string Clave, string Etiqueta, bool SoloLectura) campo in CamposFormulario())
            {
                if (campo.Clave == clave)
                    return campo.Etiqueta.ToLowerInvariant();
            }

            return "el dato requerido";
        }

        private bool EsOperacion()
        {
            return _tipoRegistro == TipoRegistro.Venta;
        }

        private bool EsProducto()
        {
            return _tipoRegistro == TipoRegistro.Producto;
        }

        private int AltoFormulario()
        {
            if (EsProducto())
                return 500;

            return EsOperacion() ? 390 : 315;
        }
    }
}
