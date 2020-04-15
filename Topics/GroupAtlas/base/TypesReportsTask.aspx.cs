using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class TypesReportsTask : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            BindToDataTableTypes(ddlTypes);
            BindToDataTableReports(ddlReports);

            int R = Convert.ToInt32(ddlReports.SelectedValue.ToString());
            int T = Convert.ToInt32(ddlTypes.SelectedValue.ToString());

            Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
            Grid1.DataBind();

            if (Grid1.Rows.Count > 1)
            {
                btnSort.Visible = true;
            }
            else
            {
                btnSort.Visible = false;
            }
                  

            Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
            Grid2.DataBind();

            pnlSort.Visible = false;
        }

    }

    private void BindToDataTableTypes(Telerik.Web.UI.RadDropDownList dropdownlist)
    {
        DataTable links = new DataTable();

        links = GroupMaster.GetTaskType();

        dropdownlist.DataTextField = "TaskName";
        dropdownlist.DataValueField = "TaskType";
        dropdownlist.DataSource = links;
        dropdownlist.DataBind();
    }

    private void BindToDataTableReports(Telerik.Web.UI.RadDropDownList dropdownlist)
    {
        DataTable links = new DataTable();

        links = GroupMaster.GetReportsList();

        dropdownlist.DataTextField = "ReportName";
        dropdownlist.DataValueField = "ReportType";
        dropdownlist.DataSource = links;
        dropdownlist.DataBind();
    }

   
    protected void ddlTypes_ItemSelected(object sender, DropDownListEventArgs e)
    {
        int R = Convert.ToInt32(ddlReports.SelectedValue.ToString());
        int T = Convert.ToInt32(ddlTypes.SelectedValue.ToString());

        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }

        Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        Grid2.DataBind();

        pnlSort.Visible = false;
    }

    protected void ddlReports_ItemSelected(object sender, DropDownListEventArgs e)
    {
        int R = Convert.ToInt32(ddlReports.SelectedValue.ToString());
        int T = Convert.ToInt32(ddlTypes.SelectedValue.ToString());

        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }

        Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        Grid2.DataBind();

        pnlSort.Visible = false;
    }
    protected void Grid2_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Select")
        {
            lblError.Visible = false;
            pnlSort.Visible = false;
            int R, T;
            int iReturn = 0;
            R = Convert.ToInt32(ddlReports.SelectedValue);
            T = Convert.ToInt32(ddlTypes.SelectedValue);

            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = Grid2.Rows[index];
            int Task = Convert.ToInt32(Grid2.DataKeys[row.RowIndex].Value.ToString());
            int RowsCount = Grid1.Rows.Count;
            RowsCount++;
            //iReturn = GroupMaster.AddTaskTypeReport(Task, R, T, 0);
            iReturn = GroupMaster.AddTaskTypeReport(Task, R, T, RowsCount);
            if (iReturn == 0)
            {
                lblError.Visible = true;
                lblError.Text = "Item can't be added!";
            }
            else
            {
                lblError.Visible = false;

                Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
                Grid1.DataBind();

                Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
                Grid2.DataBind();

                if (Grid1.Rows.Count > 1)
                {
                    btnSort.Visible = true;
                }
                else
                {
                    btnSort.Visible = false;
                }
            }
        }
    }

    protected void Grid1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        message.Visible = false;
        if (e.CommandName == "Edit")
        {
            lblError.Visible = false;
            pnlSort.Visible = false;
        }

        if (e.CommandName == "Delete")
        {
            int R, T;
            R = Convert.ToInt32(ddlReports.SelectedValue);
            T = Convert.ToInt32(ddlTypes.SelectedValue);

            lblError.Visible = false;
            pnlSort.Visible = false;

            int iReturn = 0;
            if (Grid1.Rows.Count > 0)
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = Grid1.Rows[index];
                int Task = Convert.ToInt32(Grid1.DataKeys[row.RowIndex].Value.ToString());
                // Commented lines here are to not allow of removing row if item been used in the group
                //int iRowCount = GroupMaster.RowsCountTaskTypeReport(Task, R, T);
                //if (iRowCount == 0)
                //{
                    iReturn = GroupMaster.DeleteTaskTypeReport(Task, R, T);
                //}
                //else
                //{
                //    iReturn = 0;
                //}
            }

            //if (iReturn == 0)
            //{
            //    message.Visible = true;
            //    message.InnerText = "Item can't be removed! It is used by a Group.";
            //}
            //else
            //{
                message.Visible = false;
                Grid1.DataBind();
            //}
        }
        if (e.CommandName == "Update")
        {
            int R, T;
            R = Convert.ToInt32(ddlReports.SelectedValue);
            T = Convert.ToInt32(ddlTypes.SelectedValue);

            lblError.Visible = false;
            int index = Convert.ToInt32(e.CommandArgument);
            GridViewRow row = Grid1.Rows[index];
            int Task = Convert.ToInt32(Grid1.DataKeys[row.RowIndex].Value.ToString());
            RadMaskedTextBox RptOrder = Grid1.Rows[index].FindControl("RptOrder") as RadMaskedTextBox;
            int iRptOrder = Convert.ToInt32(RptOrder.Text);

            GroupMaster.UpdateTaskTypeReport(Task, R, T, iRptOrder);
        }
    }

    protected void Grid1_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        int R, T;
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);

        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }

        Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        Grid2.DataBind();

        Grid1.EditIndex = -1;
    }

    protected void Grid1_RowEditing(object sender, GridViewEditEventArgs e)
    {
        
        int R, T;
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);

        Grid1.EditIndex = e.NewEditIndex;
        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }

    }

    protected void Grid1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
    {
        Grid1.EditIndex = -1;
        int R, T;
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);
       
        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }
    }

    protected void Grid1_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        int R, T;
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);
        Grid1.EditIndex = -1;

        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        if (Grid1.Rows.Count > 1)
        {
            btnSort.Visible = true;
        }
        else
        {
            btnSort.Visible = false;
        }
    }


    protected void btnSort_Click(object sender, EventArgs e)
    {
        int R, T;
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);
        //Response.Redirect("TypesReportsTaskSort.aspx?Report="+R.ToString() + "&Type="+T.ToString());

        RadListBox1.DataSource = GroupMaster.GetTaskTypeReportSort(R, T);
        RadListBox1.DataTextField = "Task";
        RadListBox1.DataValueField = "ReportID";
        RadListBox1.DataSortField = "RptOrder";
        RadListBox1.DataBind();
        pnlSort.Visible = true;
    }

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
        R = Convert.ToInt32(ddlReports.SelectedValue);
        T = Convert.ToInt32(ddlTypes.SelectedValue);
        Grid1.DataSource = GroupMaster.GetReportTypesTasksList(R, T);
        Grid1.DataBind();

        //Grid2.DataSource = GroupMaster.GetReportTypesTasksList2(R, T);
        //Grid2.DataBind();
        pnlSort.Visible = false;
    }

    protected void cancel_Click(object sender, EventArgs e)
    {

        pnlSort.Visible = false;
    }
}