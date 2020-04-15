using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using GM;
using Telerik.Web.UI;


public partial class Vendor_Group : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            BindToDataTableGroups(ddlGroups);

            string sGroup = ddlGroups.SelectedValue.ToString();
            //int T = Convert.ToInt32(ddlTypes.SelectedValue.ToString());

            //Grid1.DataSource = mtVendor.GetUsedVendors(sGroup);
            //Grid1.DataBind();

            //if (Grid1.Rows.Count > 1)
            //{
            //    btnSort.Visible = true;
            //}
            //else
            //{
            //    btnSort.Visible = false;
            //}

            //Grid2.DataSource = mtVendor.GetNotUsedVendors(sGroup);
            //Grid2.DataBind();

            pnlSort.Visible = false;
        }

    }
   
    private void BindToDataTableGroups(Telerik.Web.UI.RadDropDownList dropdownlist)
    {
        DataTable links = new DataTable();
        links = mtVendor.GetVGroupCode();

        dropdownlist.DataTextField = "VGroupDescription";
        dropdownlist.DataValueField = "VGroupCode";
        dropdownlist.DefaultMessage = "Select group...";
        dropdownlist.Skin = "Black";
        dropdownlist.DataSource = links;
        dropdownlist.DataBind();
    }


    protected void ddlGroups_ItemSelected(object sender, DropDownListEventArgs e)
    {
        string sGroup = ddlGroups.SelectedValue.ToString();

        Grid1.DataSource = mtVendor.GetUsedVendors(sGroup);
        Grid1.DataBind();

        Grid2.DataSource = mtVendor.GetNotUsedVendors(sGroup);
        Grid2.DataBind();

        //if (Grid1.Rows.Count > 1)
        //{
        //    btnSort.Visible = true;
        //}
        //else
        //{
        //    btnSort.Visible = false;
        //}

        //Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        //Grid2.DataBind();

        pnlSort.Visible = false;
    }
    protected void Grid2_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Select")
        {
            lblError.Visible = false;
            pnlSort.Visible = false;
            //int R, T;
            int iReturn = 0;
            string sGroup = ddlGroups.SelectedValue.ToString();
            //T = Convert.ToInt32(ddlTypes.SelectedValue);

            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = Grid2.Rows[index];
            int ID = Convert.ToInt32(Grid2.DataKeys[row.RowIndex].Value.ToString());
            string sVcode = row.Cells[1].Text;

            iReturn = mtVendor.AddVendorsGroups(sVcode, sGroup);

            if (iReturn == 0)
            {
                lblError.Visible = true;
                lblError.Text = "Item can't be added!";
            }
            else
            {
                lblError.Text = "";
                lblError.Visible = false;

                Grid1.DataSource = mtVendor.GetUsedVendors(sGroup);
                Grid1.DataBind();

                Grid2.DataSource = mtVendor.GetNotUsedVendors(sGroup);
                Grid2.DataBind();

                //if (Grid1.Rows.Count > 1)
                //{
                //    btnSort.Visible = true;
                //}
                //else
                //{
                //    btnSort.Visible = false;
                //}
            }
        }
    }

    protected void Grid1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Edit")
        {
            lblError.Visible = false;
            pnlSort.Visible = false;
        }

        if (e.CommandName == "Delete")
        {
            string sGroup = ddlGroups.SelectedValue.ToString();

            lblError.Visible = false;
            pnlSort.Visible = false;

            int iReturn = 0;
            if (Grid1.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid1.Rows[index];
                int Task = Convert.ToInt32(Grid1.DataKeys[row.RowIndex].Value.ToString());
                string sVcode = row.Cells[1].Text;
                iReturn = mtVendor.DeleteVendorsGroups(sVcode, sGroup);
            }

            if (iReturn == 0)
            {
                lblError.Visible = true;
                lblError.Text = "Item can't be removed!";
            }
            else
            {
                lblError.Visible = false;
                Grid1.DataSource = mtVendor.GetUsedVendors(sGroup);
                Grid1.DataBind();

                Grid2.DataSource = mtVendor.GetNotUsedVendors(sGroup);
                Grid2.DataBind();
            }
        }
        //if (e.CommandName == "Update")
        //{
        //    //int R, T;
        //    string R = ddlGroups.SelectedValue.ToString();
        //    //T = Convert.ToInt32(ddlTypes.SelectedValue);

        //    lblError.Visible = false;
        //    int index = Convert.ToInt32(e.CommandArgument);
        //    GridViewRow row = Grid1.Rows[index];
        //    int Task = Convert.ToInt32(Grid1.DataKeys[row.RowIndex].Value.ToString());
        //    RadMaskedTextBox RptOrder = Grid1.Rows[index].FindControl("RptOrder") as RadMaskedTextBox;
        //    int iRptOrder = Convert.ToInt32(RptOrder.Text);

        //    //GroupMaster.UpdateTaskTypeReport(Task, R, T, iRptOrder);
        //}
    }

    protected void Grid1_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        //int R, T;
        string R = ddlGroups.SelectedValue.ToString();
        //R = Convert.ToInt32(ddlGroups.SelectedValue);
        //T = Convert.ToInt32(ddlTypes.SelectedValue);

        //Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        //Grid1.DataBind();

        //if (Grid1.Rows.Count > 1)
        //{
        //    btnSort.Visible = true;
        //}
        //else
        //{
        //    btnSort.Visible = false;
        //}

        //Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        //Grid2.DataBind();

        Grid1.EditIndex = -1;
    }

    protected void Grid1_RowEditing(object sender, GridViewEditEventArgs e)
    {

        //int R, T;
        string R = ddlGroups.SelectedValue.ToString();
        //T = Convert.ToInt32(ddlTypes.SelectedValue);

        Grid1.EditIndex = e.NewEditIndex;
        //Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        //Grid1.DataBind();

        //if (Grid1.Rows.Count > 1)
        //{
        //    btnSort.Visible = true;
        //}
        //else
        //{
        //    btnSort.Visible = false;
        //}

    }

    protected void Grid1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        Grid1.EditIndex = -1;
        //int R, T;
        string R = ddlGroups.SelectedValue.ToString();
        //T = Convert.ToInt32(ddlTypes.SelectedValue);

        //Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        //Grid1.DataBind();

        //if (Grid1.Rows.Count > 1)
        //{
        //    btnSort.Visible = true;
        //}
        //else
        //{
        //    btnSort.Visible = false;
        //}
    }

    protected void Grid1_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        //int R, T;
        string R = ddlGroups.SelectedValue.ToString();
        //T = Convert.ToInt32(ddlTypes.SelectedValue);
        Grid1.EditIndex = -1;

        //Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        //Grid1.DataBind();

        //if (Grid1.Rows.Count > 1)
        //{
        //    btnSort.Visible = true;
        //}
        //else
        //{
        //    btnSort.Visible = false;
        //}
    }


    //protected void btnSort_Click(object sender, EventArgs e)
    //{
    //    int R, T;
    //    R = Convert.ToInt32(ddlGroups.SelectedValue);
    //    //T = Convert.ToInt32(ddlTypes.SelectedValue);
    //    //Response.Redirect("TypesReportsTaskSort.aspx?Report="+R.ToString() + "&Type="+T.ToString());

    //    RadListBox1.DataSource = GroupMaster.GetTaskTypeReportSort(R, T);
    //    RadListBox1.DataTextField = "Task";
    //    RadListBox1.DataValueField = "ReportID";
    //    RadListBox1.DataSortField = "RptOrder";
    //    RadListBox1.DataBind();
    //    pnlSort.Visible = true;
    //}

    protected void save_Click(object sender, EventArgs e)
    {
        int iCount = RadListBox1.Items.Count();
        for (int i = 0; i < iCount; i++)
        {
            ListItem item = new ListItem();
            item.Text = RadListBox1.Items[i].Text;
            item.Value = RadListBox1.Items[i].Value;
            GM.GroupMaster.UpdateTaskTypeReportSort(Convert.ToInt32(item.Value), i);
        }

        int R, T;
        R = Convert.ToInt32(ddlGroups.SelectedValue);
        //T = Convert.ToInt32(ddlTypes.SelectedValue);
        //Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        //Grid1.DataBind();

        //Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        //Grid2.DataBind();
        pnlSort.Visible = false;
    }

    protected void cancel_Click(object sender, EventArgs e)
    {

        pnlSort.Visible = false;
    }
}