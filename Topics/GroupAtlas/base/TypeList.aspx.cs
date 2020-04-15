using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class TypeList : System.Web.UI.Page
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
            ntOrder.Text = "";
            tbType.Text = "";
            pnlAddType.Visible = false;
            lblError.Visible = false;
        }
        if (e.CommandName == "Delete")
        {
            ntOrder.Text = "";
            tbType.Text = "";
            pnlAddType.Visible = false; 
            lblError.Visible = false;
            if (Grid.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid.Rows[index];
                int TypeID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());

                int iRowCount = GroupMaster.RowsCountTaskType(TypeID);
                if (iRowCount == 0)
                {
                    iReturn = GroupMaster.DeleteTaskType(TypeID);
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
        if (e.CommandName == "Update")
        {   
            // This section works, but not needed **************************** 
            //if (Grid.Rows.Count > 0)  
            //{
            //    int index = Convert.ToInt32(e.CommandArgument);
            //    GridViewRow row = Grid.Rows[index];
            //    int TypeID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
            //    RadTextBox TaskName = (RadTextBox)Grid.Rows[index].FindControl("TaskName");
            //    string taskName = TaskName.Text;

            //    //string TaskTypeOrder = Convert.ToString((RadMaskedTextBox)Grid.Rows[index].FindControl("TaskTypeOrder"));
            //    RadMaskedTextBox TaskTypeOrder = (RadMaskedTextBox)Grid.Rows[index].FindControl("TaskTypeOrder");
            //    int taskTypeOrder = Convert.ToInt32(TaskTypeOrder.Text);
            //    GroupMaster.UpdateTaskType(TypeID, taskName, taskTypeOrder);
            //    Grid.DataBind();
            //}
        }
    }

    protected void btnAddType_Click(object sender, EventArgs e)
    {
        int rowCount = Grid.Rows.Count;
        Grid.EditIndex = -1;
        pnlAddType.Visible = true;
        lblError.Visible = false;
        ntOrder.Text = Convert.ToString(rowCount);
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ntOrder.Text = "";
        tbType.Text = "";
        pnlAddType.Visible = false;
        lblError.Visible = false;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        int rowCount = Grid.Rows.Count;
        string sTaskName = tbType.Text;

        if (ntOrder.Text == "")
        {
            ntOrder.Text = Convert.ToString(rowCount);
        }

        if (sTaskName == "")
        {
            lblError.Visible = true;
            lblError.Text = "Type Description cannot be empty.";
        }
        else
        {
            try
            {
                int iOrder = Convert.ToInt32(ntOrder.Text);
                iReturn = GroupMaster.AddTypes(sTaskName, iOrder);
            }
            catch (Exception ex)
            {
                lblError.Visible = true;
                lblError.Text = ex.Message;
            }
        }

        if (iReturn == 1) //Success
        {
            ntOrder.Text = "";
            tbType.Text = "";
            pnlAddType.Visible = false;
            Grid.DataBind();
        }
    }
}