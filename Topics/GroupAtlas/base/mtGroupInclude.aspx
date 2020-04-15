<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="GM" %>
<script runat="server">

    private bool IsEmpty
    {
        get { return (bool)(ViewState["IsEmpty"] ?? false); }
        set { ViewState["IsEmpty"] = value; }
    }
    string groupCode
    {
        get { return ViewState["groupcode"].ToString(); }
        set { ViewState["groupcode"] = value; }
    }
    string placement
    {
        get { return ViewState["placement"].ToString(); }
        set { ViewState["placement"] = value; }
    }
    string status
    {
        get { return ViewState["status"].ToString(); }
        set { ViewState["status"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            groupCode = Request.QueryString["groupcode"] + "";
            placement = Request.QueryString["placement"] + "";
            mtGroup g = mtGroup.GetGroup(groupCode);
            if (g == null)
                Response.End();
            status = g.Status;
            ObjectDS.SelectParameters["groupcode"].DefaultValue = groupCode;
            ObjectDS.SelectParameters["placement"].DefaultValue = placement;
        }
    }

    protected void ObjectDS_Selected(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.Exception != null)
            throw e.Exception;
        DataTable dataTable = (DataTable)e.ReturnValue;
        if (dataTable.Rows.Count == 0)
        {
            dataTable.Rows.Add(dataTable.NewRow());
            IsEmpty = true;
        }
        else
            IsEmpty = false;
    }

    protected void ObjectDS_Deleted(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.Exception != null)
        {
            message.InnerHtml = "Could not delete record";
            e.ExceptionHandled = true;
        }
    }

    protected void Grid_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (IsEmpty && e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Visible = false;
            e.Row.Controls.Clear();
        }
        //if (!Security.IsAdmin() && (status == "Approved" || status == "Rejected"))
        if (status == "Approved" || status == "Rejected")

        {
            //if (!IsEmpty && e.Row.RowType == DataControlRowType.DataRow)
            //{
            //    ((LinkButton)e.Row.FindControl("LnkEdit")).Enabled = false;
            //    ((LinkButton)e.Row.FindControl("LnkDelete")).Enabled = false;
            //}
            //if (e.Row.RowType == DataControlRowType.Footer)
            //    ((LinkButton)e.Row.FindControl("LnkSave")).Enabled = false;
        }
    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Save")
        {
            //string include = ((TextBox)Grid.FooterRow.FindControl("include")).Text;
            string include = ((RadTextBox)Grid.FooterRow.FindControl("include")).Text;
            mtGroupInclude.Add(groupCode, placement, include);
            Grid.DataBind();
        }
        if (e.CommandName == "Sort")
        {
            if (Grid.Rows.Count > 0)
            {
                GridViewRow row = Grid.Rows[0];
                string GroupID = Grid.DataKeys[row.RowIndex].Value.ToString();

                Response.Redirect("mtGroupIncludeSort.aspx?group_id=" + GroupID);
            }
        }
    }

    protected string title()
    {
        string  placementDs = placement.ToUpper();
        if (placement.ToUpper() == "SPECIALFEATURES")
            placementDs = "Special Features";
        else if (placement.ToUpper() == "PRE")
            placementDs = "Pre Package Details";
        else if (placement.ToUpper() == "POST")
            placementDs = "Post Package Details";
        else if (placement.ToUpper() == "MOTORCOACH")
            placementDs = "Motorcoach Instructions";
        else if (placement.ToUpper() == "AGENTNOTES")
            placementDs = "Agent Notes";
        return string.Format("{0} Bullets for Group# {1}", placementDs, groupCode);
    }

</script>  

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title><%=title()%></title>
    <link href="include/styles.css" rel="Stylesheet" />
</head>
<body style="margin: 3px;">
    <form id="form1" runat="server">	
        <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
    <table cellspacing="0" cellpadding="0" width="100%">
		<tr>
			<td class="hdr" valign="bottom"><%=title()%></td>
			<td align="right">
			</td>
		</tr>
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span><br />
				<asp:validationsummary id="ValidationSummary1" ValidationGroup="Insert"  runat="server" ForeColor="red" HeaderText="Please correct the following:" />
				<asp:validationsummary id="ValidationSummary2" ValidationGroup="Edit"  runat="server" ForeColor="red" HeaderText="Please correct the following:" />
			</td>
		</tr>
	</table>
    <asp:GridView ID="Grid" DataKeyNames="groupcode, placement, includeid" Width="525px" CssClass="list" runat="server" AutoGenerateColumns="False" CellPadding="3" PageSize="100" GridLines="Horizontal" ShowFooter="True" 
        OnRowCreated="Grid_RowCreated" OnRowCommand="Grid_RowCommand" DataSourceID="ObjectDS" AllowSorting="false" AllowPaging="false" ShowHeader="False">
        <HeaderStyle CssClass="listhdr" /> 
   	    <FooterStyle CssClass="listftr" /> 
        <RowStyle VerticalAlign="Top" />
        <FooterStyle VerticalAlign="Top" />
        <Columns>
            <%--<asp:BoundField DataField="incl_num" Visible="false"/>--%>
            <ASP:TemplateField ItemStyle-Width="5px" Visible="true" ItemStyle-ForeColor ="white">
		        <ItemTemplate>
		            <%# Eval("incl_num") %>
		        </ItemTemplate> 
                <EditItemTemplate>
                    <telerik:RadMaskedTextBox RenderMode="Lightweight" runat="server" ID="incl_num" Width="35px" Text='<%# Bind("incl_num") %>' BackColor="LightPink" BorderColor="Black" Mask="##"  Visible="false">
                    </telerik:RadMaskedTextBox>
                </EditItemTemplate>
	        </ASP:TemplateField> 
            <asp:TemplateField>
                <EditItemTemplate>
                    <%--<asp:TextBox ID="include" runat="server" Width="350px" TextMode="MultiLine" Rows="2" Text='<%# Bind("include") %>' />--%>
                    <telerik:RadTextBox ID="include" runat="server" Width="350px" TextMode="MultiLine" Rows="2" Text='<%# Bind("include") %>' BackColor="LightYellow" />
                    <asp:RequiredFieldValidator ValidationGroup="Edit"  id="valinclude" runat="server" CssClass="error" ErrorMessage="Bullet text is required" ControlToValidate="include" Display="Dynamic">*</asp:RequiredFieldValidator>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="include" runat="server" Text='<%# Eval("include") %>' />
                </ItemTemplate>
                <FooterTemplate>
                    <%--<asp:TextBox ID="include" runat="server" Width="350px" TextMode="MultiLine" Rows="2" /> --%>
                    <telerik:RadTextBox ID="include" runat="server" Width="350px" TextMode="MultiLine" Rows="2" /> 
                    <asp:RequiredFieldValidator ValidationGroup="Insert"  id="valinclude" runat="server" CssClass="error" ErrorMessage="Bullet text is required" ControlToValidate="include" Display="Dynamic">*</asp:RequiredFieldValidator>
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField ShowHeader="False" HeaderStyle-Width="40px" >
                <EditItemTemplate>
                    <asp:LinkButton ID="LnkUpdate" ValidationGroup="Edit" runat="server" CausesValidation="true" CommandName="Update" Text="Update" />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:LinkButton ID="LnkEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit" />
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Button ID="LnkSave" ValidationGroup="Insert"  runat="server" CausesValidation="true"  CommandName="Save" Text="Save" />
                </FooterTemplate>
            </asp:TemplateField>
            <asp:TemplateField ShowHeader="False" HeaderStyle-Width="50px" >
                <EditItemTemplate>
                    <asp:LinkButton ID="LnkCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure?');" Text="Delete" />
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Button ID="LinkSort" ValidationGroup="Sort"  runat="server" CausesValidation="true"  CommandName="Sort" Text="Sort" />
                </FooterTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:ObjectDataSource ID="ObjectDS" runat="server" TypeName="GM.mtGroupInclude" OnSelected="ObjectDS_Selected" SelectMethod="GetList" InsertMethod="Add" UpdateMethod="Update" DeleteMethod="Delete" ondeleted="ObjectDS_Deleted">
        <SelectParameters>
            <asp:Parameter Name="groupcode" Type="String" />
            <asp:Parameter Name="placement" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="groupcode" Type="Object" />
            <asp:Parameter Name="placement" Type="Object" />
            <asp:Parameter Name="includeid" Type="Object" />
            <asp:Parameter Name="include" Type="String" />
             <asp:Parameter Name="incl_num" Type="String" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="groupcode" Type="Object" />
            <asp:Parameter Name="placement" Type="Object" />
            <asp:Parameter Name="includeid" Type="Object" />
        </DeleteParameters>
    </asp:ObjectDataSource>

    </form>
</body>
</html>