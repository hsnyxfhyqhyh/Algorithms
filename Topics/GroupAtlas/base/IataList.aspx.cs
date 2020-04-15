﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;
using GM;
using System.Collections;

public partial class IataList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Edit")
        {
            tbCode.Text = "";
            tbDesc.Text = "";
            pnlAdd.Visible = false;
            lblError.Visible = false;
        }
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
        tbCode.Text = "";
        tbDesc.Text = "";
        pnlAdd.Visible = false;
        lblError.Visible = false;
        message.InnerHtml = "";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        lblError.Visible = false;
        int iReturn = 0;
        string stbCode = tbCode.Text;
        string stbDesc = tbDesc.Text;
        //int iOrder = Convert.ToInt32(ntOrder.Text);
        Grid.MasterTableView.ClearEditItems();
        Grid.Rebind();
        if (stbCode != "" && stbDesc != "")
        {
            try
            {
                iReturn = GroupMaster.AddVGroupCode(stbCode, stbDesc);
            }
            catch (Exception ex)
            {
                lblError.Visible = true;
                lblError.Text = ex.Message;
            }

            if (iReturn == 1) //Success
            {
                tbCode.Text = "";
                tbDesc.Text = "";
                pnlAdd.Visible = false;
                Grid.DataBind();
                message.InnerHtml = "Group Code was successfully added.";
            }
        }
        else
        {
            message.InnerHtml = "Group Code and/or Descriptoin cannot be empty.";
        }
    }

    protected void Grid_NeedDataSource(object sender, GridNeedDataSourceEventArgs e)
    {
        Grid.DataSource = GroupMaster.GetGroupCode();
        Grid.DataBind();

    }

    protected void Grid_ItemDataBound(object sender, GridItemEventArgs e)
    {
        if (e.Item is GridDataItem)
        {
            GridDataItem item = e.Item as GridDataItem;
        }
    }

    protected void Grid_DeleteCommand(object sender, GridCommandEventArgs e)
    {
        pnlAdd.Visible = false;
        lblError.Visible = false;
        message.InnerHtml = "";

        int RID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["RID"].ToString());
        try
        {
            GroupMaster.DeleteVGroupCode(RID);
            message.InnerHtml = "Group Code was successfully deleted.";
        }
        catch (Exception ex)
        {
            message.InnerText = ex.Message;
        }
    }

    protected void Grid_EditCommand(object sender, GridCommandEventArgs e)
    {
        pnlAdd.Visible = false;
        lblError.Visible = false;
        message.InnerHtml = "";
    }

    protected void Grid_UpdateCommand(object sender, GridCommandEventArgs e)
    {
        pnlAdd.Visible = false;
        lblError.Visible = false;
        message.InnerHtml = "";
        //Pre-update values
        //int TourID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["RID"].ToString());
        string Location = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["Location"].ToString();
        string IATA = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["IATA"].ToString();

        //Post-update values
        GridEditableItem editItem = e.Item as GridEditableItem;
        Hashtable newValues = new Hashtable();
        e.Item.OwnerTableView.ExtractValuesFromItem(newValues, editItem);
        //Location = Convert.ToString(newValues["Location"]);

        IATA = Convert.ToString(newValues["IATA"]);
        //if (Location != "")
        //{
        //    if (IATA != "")
        //    {
                try
                {
                    GroupMaster.UpdateIATAList(Location, IATA);
                    message.InnerHtml = "IATA Code was successfully updated.";
                }
                catch (Exception ex)
                {
                    message.InnerText = ex.Message;
                }
        //}
        //    else
        //    {
        //        message.InnerHtml = "IATA cannot be empty.";
        //    }
        //}
        //else
        //{
        //    message.InnerHtml = "Location cannot be empty.";
        //}

    }
}