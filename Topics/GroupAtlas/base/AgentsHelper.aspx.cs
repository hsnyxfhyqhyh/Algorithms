using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class AgentsHelper : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string Title = Request.QueryString["Title"];
        Grid.DataSource = Employee.GetAGentNames(Title);
        Grid.DataBind();
    }

    protected void BtnClose_Click(object sender, EventArgs e)
    {
        Response.Redirect("Agents.aspx");
    }
}