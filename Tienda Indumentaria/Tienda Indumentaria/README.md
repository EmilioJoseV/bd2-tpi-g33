# Plantilla App - Tienda de Indumentaria (BD2)

App de escritorio en C# / WinForms (.NET 8) para demostrar la funcionalidad
del sistema: ejecuta consultas, vistas y procedimientos almacenados sobre
la base `BD2_TPI_TIENDA_INDUMENTARIA` y muestra los resultados en una grilla.

## Estructura

- `Conexion.cs` — único punto de acceso a la base. Cadena de conexión y los
  métodos `EjecutarConsulta`, `EjecutarProcedimiento` y `ProbarConexion`.
- `FormPrincipal.cs` — la pantalla: combo de consultas + botón + grilla.
- `Program.cs` — arranque de la aplicación.
- `Tienda Indumentaria.csproj` — proyecto WinForms y dependencia de SqlClient.

## Requisitos

- .NET 8 SDK (o abrir directo con Visual Studio 2022).
- SQL Server con la base ya creada (correr antes `Creacion.sql` y `Datos.sql`).

## Cómo correrla

Desde la carpeta raíz de la solución:

```
dotnet run --project "Tienda Indumentaria/Tienda Indumentaria.csproj"
```

O abriendo el `.csproj` en Visual Studio y presionando F5.

## Antes de la primera ejecución

Revisar la cadena de conexión en `Conexion.cs`. Según la instalación de cada
uno puede necesitar `localhost\SQLEXPRESS` en lugar de `localhost`.

## Cómo agregar una consulta o vista

En `FormPrincipal.cs`, método `CargarOpciones()`, agregar una línea:

```csharp
_comboConsultas.Items.Add(new OpcionConsulta(
    "Texto que ve el usuario",
    "SELECT * FROM VW_MiVista"));
```

No hace falta tocar nada más: el botón ya ejecuta lo que esté seleccionado.

## Cómo llamar a un procedimiento almacenado

Usar `Conexion.EjecutarProcedimiento` directamente, por ejemplo:

```csharp
var datos = Conexion.EjecutarProcedimiento(
    "SP_VentasPorCliente",
    ("@IdCliente", 5));
_grilla.DataSource = datos;
```

## Nota

La aplicación es **opcional** según las instrucciones del TP. Toda la
funcionalidad se puede demostrar también desde SSMS. Esta plantilla existe
solo como "cara visible" de los objetos de base de datos.
