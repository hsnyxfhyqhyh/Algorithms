using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;

public partial class typeListSort : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void save_Click(object sender, EventArgs e)
    {
        int iCount = RadListBox1.Items.Count();
        for (int i = 0; i < iCount; i++)
        {
            ListItem item = new ListItem();
            item.Text = RadListBox1.Items[i].Text;
            item.Value = RadListBox1.Items[i].Value;
            GM.GroupMaster.UpdateTypesSort(Convert.ToInt32(item.Value), i);
        }
        Response.Redirect("TypeList.aspx");
    }

    protected void cancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("TypeList.aspx");
    }
}