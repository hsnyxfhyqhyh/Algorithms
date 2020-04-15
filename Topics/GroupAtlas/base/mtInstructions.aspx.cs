using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class mtInstructions : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ddlInstructionType.DataSource = mtPickList.GetInstructionType();
            ddlInstructionType.DataBind();
            BindData();
        }
    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        Grid.EditIndex = -1;
        pnlAddType.Visible = true;
        lblError.Visible = false;
        Grid.Enabled = false;
        btnSort.Enabled = false;
        btnAdd.Enabled = false;
        ddlInstructionType.Enabled = true;
    }

    protected void Grid_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //ntOrder.Text = "";
        tbGroupName.Text = "";
        pnlAddType.Visible = false;
        lblError.Visible = false;
        Grid.Enabled = true;
        btnSort.Enabled = true;
        btnAdd.Enabled = true;
        ddlInstructionType.Enabled = true;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;

        string InstructionType = ddlInstructionType.SelectedValue;
        string InstructionCode = tbGroupName.Text;
        try
        {
            iReturn = GroupMaster.AddInstruction(InstructionType, InstructionCode, 0);
        }
        catch (Exception ex)
        {
            lblError.Visible = true;
            lblError.Text = ex.Message;
        }

        if (iReturn == 1) //Success
        {
            //ntOrder.Text = "";
            tbGroupName.Text = "";
            pnlAddType.Visible = false;
            Grid.Enabled = true;
            btnSort.Enabled = true;
            btnAdd.Enabled = true;
            ddlInstructionType.Enabled = true;
            BindData();
        }
    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int iReturn = 0;
        if (e.CommandName == "Edit")
        {
            //ntOrder.Text = "";
            tbGroupName.Text = "";
            pnlAddType.Visible = false;
            lblError.Visible = false;
            btnSort.Enabled = false;
            btnAdd.Enabled = false;
        }

        if (e.CommandName == "Cancel")
        {
            btnSort.Enabled = true;
            btnAdd.Enabled = true;
        }
        
        if (e.CommandName == "Update")
        {
            btnSort.Enabled = true;
            btnAdd.Enabled = true;
            
            if (Grid.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid.Rows[index];
                int RID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
                RadTextBox InstructionCode = (RadTextBox)Grid.Rows[index].FindControl("InstructionCode");
                string Code = InstructionCode.Text;

                GroupMaster.UpdatetInstruction(RID, Code);
                
                //Grid.DataBind();
                Grid.EditIndex = -1;
                BindData();
            }
        }
        if (e.CommandName == "Delete")
        {
            //ntOrder.Text = "";
            //tbType.Text = "";
            pnlAddType.Visible = false;
            lblError.Visible = false;
            if (Grid.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid.Rows[index];
                int RID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
                iReturn = GroupMaster.DeleteInstruction(RID);
            }

            if (iReturn == 0)
            {
                lblError.Text = "Item can't be deleted!";
            }
            else
            {
                BindData();
            }

        }
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {
        string InstructionType = ddlInstructionType.SelectedValue;

        RadListBox1.DataSource = GroupMaster.GetInstructionSort(InstructionType);
        RadListBox1.DataTextField = "InstructionCode";
        RadListBox1.DataValueField = "RID";
        RadListBox1.DataSortField = "InstructionSort";
        RadListBox1.DataBind();
        pnlSort.Visible = true;
        Grid.Enabled = false;
        ddlInstructionType.Enabled = false;
    }

    protected void save_Click(object sender, EventArgs e)
    {
        int iCount = RadListBox1.Items.Count();
        for (int i = 0; i < iCount; i++)
        {
            ListItem item = new ListItem();
            item.Text = RadListBox1.Items[i].Text;
            item.Value = RadListBox1.Items[i].Value;
            GroupMaster.UpdateInstructionSort(Convert.ToInt32(item.Value), i);
        }
        pnlSort.Visible = false;
        Grid.Enabled = true;
        ddlInstructionType.Enabled = true;
        BindData();
    }

    protected void cancel_Click(object sender, EventArgs e)
    {
        pnlSort.Visible = false;
        Grid.Enabled = true;
        ddlInstructionType.Enabled = true;
    }

    protected void ddlInstructionType_SelectedIndexChanged(object sender, Telerik.Web.UI.DropDownListEventArgs e)
    {
        BindData();
    }

    protected void BindData()
    {
        DataTable dt = new DataTable();
        string sInstruction = ddlInstructionType.SelectedValue;
        dt = GroupMaster.GetInstructions(sInstruction);
        Grid.DataSource = dt;
        Grid.DataBind();
    }

    protected void Grid_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {

    }

    protected void Grid_RowEditing(object sender, GridViewEditEventArgs e)
    {
        Grid.EditIndex = e.NewEditIndex;
        BindData();
    }



    protected void Grid_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        Grid.EditIndex = -1;
        BindData();
    }

    protected void Grid_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {

    }
}