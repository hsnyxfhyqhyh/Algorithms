<%@ Page Language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            string action = Request.QueryString["action"] + "";
            int flxID = Util.parseInt(Request.QueryString["flxid"] + "");
            if (action == "newcoordinator")
            {
                if (flxID > 0)
                    Coordinator.Add(flxID);
                Response.Redirect("CoordinatorList.aspx");
            }
            message.InnerHtml = Request.QueryString["msg"];
        }
    }
    
	protected void Search_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid)
            return;
        Grid.PageIndex = 0;
        Grid.DataBind();
	}

    protected void Grid_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType==DataControlRowType.Pager)
        {
            TableCell td = new TableCell();
            td.Style.Add("text-align", "right");
            td.Text = string.Format("Page {0} of {1}&nbsp;&nbsp;({2} results)", (Grid.PageIndex + 1), Grid.PageCount, Employee.GetPagedCount());
            e.Row.Cells[0].ColumnSpan --; 
            e.Row.Cells.Add(td);
         }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <span id="message" class="message" runat="server" enableviewstate="false"></span>
    <table cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td valign="bottom"><span class="hdr">Add Coordinator - </span><span class="message">Select from list below</span></td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='CoordinatorList.aspx';return false;" value="<< Back" />
             </td>
        </tr>
        <tr>
            <td width="100%" class="line" colspan="2" height="1"></td>
        </tr>
        <tr valign="bottom">
        <td colspan="2">
            <table cellpadding="0" cellspacing="0">
                <tr valign="bottom">
                    <td >
                        <asp:TextBox ID="searchstr" Width="200px" runat="server" />
                    </td>
                    <td>&nbsp;&nbsp;</td>
                    <td>
                        <asp:Button CssClass="topbutton" ID="searchbtn" OnClick="Search_Click" runat="server" Text="Search" />
                    </td>
                </tr>
            </table>
        </td>    
        </tr>
    </table>
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="50" GridLines="Horizontal" AllowPaging="true"  AllowSorting="true" 
        DataSourceID="EmployeeSource" DataKeyNames="flxid" AutoGenerateColumns="False" onrowcreated="Grid_RowCreated">
        <HeaderStyle CssClass="listhdr" />
        <Columns>
            <asp:TemplateField HeaderStyle-Width="25px">
                <ItemTemplate>
                    <asp:HyperLink ID="add" runat="server" Text=" Add " NavigateUrl='<%# String.Format("CoordinatorAdd.aspx?action=newcoordinator&flxid={0}", Convert.ToString(Eval("flxid"))) %>' />
                </ItemTemplate>
            </asp:TemplateField>
	        <asp:BoundField DataField="flxid" HeaderText="Flex ID" HeaderStyle-HorizontalAlign="Left" SortExpression="flxid" /> 
            <asp:BoundField DataField="firstname" HeaderText="First Name" HeaderStyle-HorizontalAlign="Left" SortExpression="firstname" />
            <asp:BoundField DataField="lastname" HeaderText="Last Name" HeaderStyle-HorizontalAlign="Left" SortExpression="lastname" />
            <asp:BoundField DataField="title" HeaderText="Title" HeaderStyle-HorizontalAlign="Left" SortExpression="title" />
            <asp:BoundField DataField="cidescrip" HeaderText="Department" HeaderStyle-HorizontalAlign="Left" SortExpression="cidescrip" />
            <asp:BoundField DataField="status" HeaderText="Status" HeaderStyle-HorizontalAlign="Left" SortExpression="status" />
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="EmployeeSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.Employee" EnablePaging="True"  SortParameterName="sortExpression">
        <SelectParameters>
            <asp:ControlParameter Name="searchstr" ControlID="searchstr" DefaultValue="" PropertyName="Text" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
