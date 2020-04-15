using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;

public partial class mtGroupIncludeSort : System.Web.UI.Page
{
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string group_id = Request.QueryString["group_id"];
            Session["groupcode"] = group_id;
        }
    }

    protected void save_Click(object sender, EventArgs e)
    {
        string groupcode = Session["groupcode"].ToString();
        int iCount = RadListBox1.Items.Count();
        for (int i = 0; i < iCount; i++)
        {
            ListItem item = new ListItem();
            item.Text = RadListBox1.Items[i].Text;
            item.Value = RadListBox1.Items[i].Value;
            GM.mtGroupInclude.UpdateIncludeSort(groupcode, Convert.ToInt32(item.Value), i);
        }
        Response.Redirect("mtGroupInclude.aspx?groupcode="+groupcode+ "&placement=specialFeatures");
    }


    protected void cancel_Click(object sender, EventArgs e)
    {
        string groupcode = Session["groupcode"].ToString();

        //Response.Redirect("mtGroupInclude.aspx?groupcode=" + groupcode);
        Response.Redirect("mtGroupInclude.aspx?groupcode=" + groupcode + "&placement=specialFeatures");
    }
}