using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using GM;
using Telerik.Web.UI;

public partial class Agents : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {


        }

    }

    public void BindData()
    {
        Grid2.DataSource = Employee.GetTitle();
        Grid2.DataBind();
        Grid1.DataSource = Employee.GetEmployee();
        Grid1.DataBind();
    }

   
    protected void Grid1_ItemDataBound(object sender, GridItemEventArgs e)
    {
        if (e.Item is GridDataItem)
        {
            //Get the instance of the right type
            GridDataItem dataBoundItem = e.Item as GridDataItem;
        }
    }

    protected void Grid1_ItemCommand(object sender, GridCommandEventArgs e)
    {
        if (e.CommandName == "Employee")
        {
            int flxid = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["flxid"].ToString());
            try
            {
                Employee.DeleteEmployee(flxid);
                Grid1.DataBind();
                Grid2.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Visible = true;
                lblError.Text = ex.Message;
            }
        }
        else if (e.CommandName == "Department")
        {
            string Title = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["title"].ToString();
            try
            {
                Employee.DeleteTitle(Title);
                Grid1.DataBind();
                Grid2.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Visible = true;
                lblError.Text = ex.Message;
            }
        }
    }

    protected void Grid1_DeleteCommand(object sender, GridCommandEventArgs e)
    {

    }

    protected void Grid2_ItemDataBound(object sender, GridItemEventArgs e)
    {
       
        //Is it a GridDataItem
        if (e.Item is GridDataItem)
        {
            //Get the instance of the right type
            GridDataItem dataBoundItem = e.Item as GridDataItem;
        }
    }

    protected void Grid2_ItemCommand(object sender, GridCommandEventArgs e)
    {
        if (e.CommandName == "Select")
        {
            string Title = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["Title"].ToString();
            try
            {
                Employee.InsertTitle(Title);
                Grid2.DataBind();
                Grid1.DataBind();
            }
            catch (Exception ex)
            {
                lblError.Visible = true;
                lblError.Text = ex.Message;
            }
        }
        if (e.CommandName == "View")
        {
            string Title = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["Title"].ToString();
            Response.Redirect("AgentsHelper.aspx?Title=" + Title);
        }
    }

   

   
}