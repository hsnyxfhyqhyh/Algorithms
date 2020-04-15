using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;
using System.Collections;

public partial class ThemeMaintenance : System.Web.UI.Page
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
            tbTheme.Text = "";
            pnlAdd.Visible = false;
            lblError.Visible = false;
        }

        //if (e.CommandName == "Delete")
        //{
        //    tbTask.Text = "";
        //    pnlAdd.Visible = false;
        //    lblError.Visible = false;
        //    if (Grid.Rows.Count > 0)
        //    {
        //        int index = Convert.ToInt32(e.CommandArgument);
        //        GridViewRow row = Grid.Rows[index];
        //        int iTaskID = Convert.ToInt32(Grid.DataKeys[row.RowIndex].Value.ToString());
        //        iReturn =  GroupMaster.DeleteTask(iTaskID);
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
        Grid.MasterTableView.ClearEditItems();
        Grid.Rebind();
        pnlAdd.Visible = true;
        lblError.Visible = false;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Grid.MasterTableView.ClearEditItems();
        Grid.Rebind();
        tbTheme.Text = "";
        pnlAdd.Visible = false;
        lblError.Visible = false;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        string stbTask = tbTheme.Text;
        //int iOrder = Convert.ToInt32(ntOrder.Text);
        Grid.MasterTableView.ClearEditItems();
        Grid.Rebind();
        try
        {
            iReturn = GroupMaster.AddTheme(stbTask);
        }
        catch (Exception ex)
        {
            lblError.Visible = true;
            lblError.Text = ex.Message;
        }

        if (iReturn == 1) //Success
        {
            tbTheme.Text = "";
            pnlAdd.Visible = false;
            Grid.DataBind();
        }
    }

    protected void Grid_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        Grid.DataSource = GroupMaster.GetTheme();
        Grid.DataBind();
        
    }

    protected void Grid_ItemDataBound(object sender, GridItemEventArgs e)
    {
        //if (e.Item.IsInEditMode)
        //{
        //    GridEditableItem editItem = (GridEditableItem)e.Item;
        //    Button updateButton = (Button)editItem.FindControl("UpdateButton");
        //    Button CancelButton = (Button)editItem.FindControl("CancelButton");
        //    updateButton.Text = "save";

        //    CancelButton.Visible = false;
        //}

        if (e.Item is GridDataItem)
        {
            GridDataItem item = e.Item as GridDataItem;
            if (item["GroupsCounter"].Text != "0" )
            {
                //LinkButton btn = (LinkButton)item["LnkDelete"].Controls[0]; 
                LinkButton btn = e.Item.FindControl("LnkDelete") as LinkButton;
                btn.Enabled = false;
                btn.ToolTip = "Item cannot be deleled";
            }
        }
    }

    protected void Grid_DeleteCommand(object sender, GridCommandEventArgs e)
    {
        pnlAdd.Visible = false;
        lblError.Visible = false;

        int ID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["TourID"].ToString());
        try
        {
            GroupMaster.DeleteTheme(ID);
            message.InnerHtml = "Theme was successfully deleted.";
        }
        catch (Exception ex)
        {
            message.InnerText = ex.Message;
        }
    }

    protected void Grid_EditCommand(object sender, GridCommandEventArgs e)
    {
        //int TourID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["TourID"].ToString());
        //string TourName = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["TourName"].ToString();

        //try
        //{
        //    GroupMaster.UpdateTheme(TourID, TourName);
        //    message.InnerHtml = "Theme was successfully updated.";
        //}
        //catch (Exception ex)
        //{
        //    message.InnerText = ex.Message;
        //}
    }

    protected void Grid_UpdateCommand(object sender, GridCommandEventArgs e)
    {
        pnlAdd.Visible = false;
        lblError.Visible = false;

        //Pre-update values
        int TourID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["TourID"].ToString());
        string TourName = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["TourName"].ToString();
        
        //Post-update values
        GridEditableItem editItem = e.Item as GridEditableItem;
        Hashtable newValues = new Hashtable();
        e.Item.OwnerTableView.ExtractValuesFromItem(newValues, editItem);
        TourName = newValues["TourName"].ToString();

        try
        {
            GroupMaster.UpdateTheme(TourID, TourName);
            message.InnerHtml = "Theme was successfully updated.";
        }
        catch (Exception ex)
        {
            message.InnerText = ex.Message;
        }
    }

   
}