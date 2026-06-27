using System.Data;
using System.Windows.Forms;

namespace TiendaIndumentaria.App
{
    internal static class ComboBusqueda
    {
        public static void Configurar(
            ComboBox lista,
            DataTable datos,
            string columnaId,
            string columnaTexto)
        {
            lista.DropDownStyle = ComboBoxStyle.DropDown;
            lista.AutoCompleteMode = AutoCompleteMode.SuggestAppend;
            lista.AutoCompleteSource = AutoCompleteSource.ListItems;
            lista.DisplayMember = columnaTexto;
            lista.ValueMember = columnaId;
            lista.DataSource = datos;
        }
    }
}
