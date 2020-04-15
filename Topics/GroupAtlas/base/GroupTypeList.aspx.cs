using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class GroupTypeList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        Grid.EditIndex = -1;
        pnlAddType.Visible = true;
        lblError.Visible = false;
        Grid.Enabled = false;
        btnSort.Enabled = false;
        btnAdd.Enabled = false;
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
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        string sGroupType = tbGroupName.Text;
        //int iOrder = Convert.ToInt32(ntOrder.Text);
        int GroupType;
        int RowCount = 0;
        string StatusVisible = "YES";
        string sPickType = "GROUPTYPE";
        string GroupDesc = ddlAffinity.SelectedText.ToString();
        if (sGroupType.Trim() != "")
        {
            if (GroupDesc != "")
            {
                GroupType = Convert.ToInt32(ddlAffinity.SelectedValue);
                //RowCount = Grid.Rows.Count;
                RowCount = GroupMaster.RowsCount(sPickType);
                
                RowCount++;
                try
                {
                    iReturn = GroupMaster.AddGroupType(sPickType, sGroupType, StatusVisible, RowCount);
                    if (iReturn == 1)
                    {
                        iReturn = GroupMaster.AddGroupTypeAffinity(GroupType, GroupDesc, RowCount);
                    }
                }
                catch (Exception ex)
                {
                    lblError.Visible = true;
                    lblError.Text = ex.Message;
                }
            }
            else
            {
                lblError.Visible = true;
                lblError.Text = "Please, select Imitation Type.";
            }
        }
        else
        {
            lblError.Visible = true;
            lblError.Text = "Please, type Group Type.";
        }

        if (iReturn == 1) //Success
        {
            //ntOrder.Text = "";
            tbGroupName.Text = "";
            pnlAddType.Visible = false;
            Grid.DataBind();
            Grid.Enabled = true;
            btnSort.Enabled = true;
            btnAdd.Enabled = true;
            lblError.Visible = false;
            lblError.Text = "";
        }
    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //int iReturn = 0;
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
        //if (e.CommandName == "Delete")
        //{
        //    ntOrder.Text = "";
        //    tbType.Text = "";
        //    pnlAddType.Visible = false;
        //    lblError.Visible = false;
        //    if (Grid.Rows.Count > 0)
        //    {
        //        int index = Convert.ToInt32(e.CommandArgument);
        //        GridViewRow row = Grid.Rows[index];
        //        int TypeID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
        //        iReturn = GroupMaster.DeleteTaskType(TypeID);
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
        if (e.CommandName == "Update")
        {
            btnSort.Enabled = true;
            btnAdd.Enabled = true;
            // This section works, but not needed **************************** 
            //if (Grid.Rows.Count > 0)
            //{
            //    int index = Convert.ToInt32(e.CommandArgument);
            //    GridViewRow row = Grid.Rows[index];
            //    int TypeID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
            //    RadTextBox PickDesc = (RadTextBox)Grid.Rows[index].FindControl("PickDesc");
            //    string pickdesc = PickDesc.Text;

            //    //string TaskTypeOrder = Convert.ToString((RadMaskedTextBox)Grid.Rows[index].FindControl("TaskTypeOrder"));
            //    //RadMaskedTextBox TaskTypeOrder = (RadMaskedTextBox)Grid.Rows[index].FindControl("TaskTypeOrder");
            //    //int taskTypeOrder = Convert.ToInt32(TaskTypeOrder.Text);
            //    //GroupMaster.UpdateGroupType(TypeID, taskName, taskTypeOrder);
            //    //Grid.DataBind();
            //}

        }
    }

    protected void btnSort_Click(object sender, EventArgs e)
    {

        string PickType = "GROUPTYPE";
        string StatusVisible = "YES";

        RadListBox1.DataSource = GroupMaster.GetGroupTypeSort(PickType, StatusVisible);
        RadListBox1.DataTextField = "PickDesc";
        RadListBox1.DataValueField = "PickCode";
        RadListBox1.DataSortField = "Sort";
        RadListBox1.DataBind();
        pnlSort.Visible = true;
        Grid.Enabled = false;
    }

    protected void save_Click(object sender, EventArgs e)
    {
        string PickType = "GROUPTYPE";
        int iCount = RadListBox1.Items.Count();
        for (int i = 0; i < iCount; i++)
        {
            ListItem item = new ListItem();
            item.Text = RadListBox1.Items[i].Text;
            item.Value = RadListBox1.Items[i].Value;
            GM.GroupMaster.UpdatetGroupTypeSort(Convert.ToString(item.Value), i, PickType);
        }
        pnlSort.Visible = false;
        Grid.DataBind();
        Grid.Enabled = true;
    }

    protected void cancel_Click(object sender, EventArgs e)
    {
        pnlSort.Visible = false;
        Grid.Enabled = true;
    }

    protected void Grid_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        if (Grid.Rows.Count > 0)
        {
            int index = Convert.ToInt32(e.RowIndex);
            GridViewRow row = Grid.Rows[index];
            int RowID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
            RadTextBox PickDesc = (RadTextBox)Grid.Rows[index].FindControl("PickDesc");
            string pickDesc = PickDesc.Text;
            string pickType = "GROUPTYPE";

            GroupMaster.UpdateGroupTypeList(RowID, pickType, pickDesc);
            Grid.DataBind();
        }
    }
}