using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;

public partial class ReportsList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void Grid_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {

    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int iReturn = 0;
        if (e.CommandName == "Edit")
        {
            //ntOrder.Text = "";
            tbReport.Text = "";
            pnlAdd.Visible = false;
            lblError.Visible = false;
        }
        //if (e.CommandName == "Delete")
        //{
        //    tbReport.Text = "";
        //    pnlAdd.Visible = false;
        //    lblError.Visible = false;
        //    if (Grid.Rows.Count > 0)
        //    {
        //        int index = Convert.ToInt32(e.CommandArgument);
        //        GridViewRow row = Grid.Rows[index];
        //        int ReportType = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
        //        iReturn = GroupMaster.DeleteReport(ReportType);
        //    }

        //    if (iReturn == 0)
        //    {
        //        lblError.Text = "Item can't be deleted!";
        //    }
        //    else
        //    {
        //        Grid.DataBind();
        //    }
        //}
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        Grid.EditIndex = -1;
        pnlAdd.Visible = true;
        lblError.Visible = false;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //ntOrder.Text = "";
        tbReport.Text = "";
        pnlAdd.Visible = false;
        lblError.Visible = false;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        string sReportName = tbReport.Text;
        //int iOrder = Convert.ToInt32(ntOrder.Text);
        try
        {
            iReturn = GroupMaster.AddReport(sReportName);
        }
        catch (Exception ex)
        {
            lblError.Visible = true;
            lblError.Text = ex.Message;
        }

        if (iReturn == 1) //Success
        {
            //ntOrder.Text = "";
            tbReport.Text = "";
            pnlAdd.Visible = false;
            Grid.DataBind();
        }
    }
}