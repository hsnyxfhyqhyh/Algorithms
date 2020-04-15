using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using GM;
using Telerik.Web.UI;
using System.Configuration;
using System.Text;
using System.Runtime.InteropServices.ComTypes;

public partial class EmailPop : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string groupid = Session["GroupId"].ToString();
        if (!Page.IsPostBack)
        {
            //string groupid = Request.QueryString["groupID"];
            //string groupid = Session["GroupId"].ToString();

            //lbl_groupid.Text = "Group Id is: " + groupid;
            GridListView.DataSource = GroupBooking.GetEmails(groupid);
            GridListView.DataBind();

            GridListViewAgents.DataSource = GroupBooking.GetEmailsAgents(groupid);
            GridListViewAgents.DataBind();
        }
    }
}