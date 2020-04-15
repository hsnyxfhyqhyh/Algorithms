using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;

public partial class TaskList : System.Web.UI.Page
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
            tbTask.Text = "";
            pnlAdd.Visible = false;
            lblError.Visible = false;
        }

        if (e.CommandName == "Delete")
        {
            tbTask.Text = "";
            pnlAdd.Visible = false;
            lblError.Visible = false;
            if (Grid.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid.Rows[index];
                int iTaskID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());

                int iRowCount = GroupMaster.RowsCountTask(iTaskID);
                if (iRowCount == 0)
                {
                    iReturn = GroupMaster.DeleteTask(iTaskID);
                }
                else
                {
                    iReturn = 0;
                }
            }

            if (iReturn == 0)
            {
                message.Visible = true;
                message.InnerText = "Task can't be deleted! It is used in Group.";
            }
            else
            {
                message.Visible = false;
                Grid.DataBind();
            }
        }

    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        Grid.EditIndex = -1;
        pnlAdd.Visible = true;
        lblError.Visible = false;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        tbTask.Text = "";
        pnlAdd.Visible = false;
        lblError.Visible = false;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        string stbTask = tbTask.Text;
        //int iOrder = Convert.ToInt32(ntOrder.Text);
        try
        {
            iReturn = GroupMaster.AddTask(stbTask);
        }
        catch (Exception ex)
        {
            lblError.Visible = true;
            lblError.Text = ex.Message;
        }

        if (iReturn == 1) //Success
        {
            tbTask.Text = "";
            pnlAdd.Visible = false;
            Grid.DataBind();
        }
    }

    
}