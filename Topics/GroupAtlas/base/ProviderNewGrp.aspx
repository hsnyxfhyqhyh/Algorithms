<%@ Page Language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
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
            td.Text = string.Format("Page {0} of {1}&nbsp;&nbsp;({2} results)", (Grid.PageIndex + 1), Grid.PageCount, Provider.GetPagedCount());
            e.Row.Cells[0].ColumnSpan --; 
            e.Row.Cells.Add(td);
         }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <span id="message" class="message" runat="server" enableviewstate="false"></span><br />
    <table cellpadding="0" cellspacing="0" width="100%">
        <tr valign="bottom">
        <td>
            <table cellpadding="0" cellspacing="0">
                <tr valign="bottom">
                    <td>
                        <asp:TextBox ID="searchstr" Width="200px" runat="server" />
                    </td>
                    <td>&nbsp;&nbsp;</td>
                    <td>
                        <asp:Button CssClass="topbutton" ID="searchbtn" OnClick="Search_Click" runat="server" Text="Search" />
                    </td>
                </tr>
            </table>
        </td>    
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='ProviderEdit.aspx';return false;" value="<< Back" />
             </td>
        </tr>
    </table>
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3"
        PageSize="50" GridLines="Horizontal" AllowPaging="true" 
        AllowSorting="true" DataSourceID="ProviderSource" DataKeyNames="provider" 
        AutoGenerateColumns="False" onrowcreated="Grid_RowCreated" >
        <HeaderStyle CssClass="listhdr" />
        <Columns>
	        <asp:BoundField DataField="provider" HeaderText="Provider Code" 
                HeaderStyle-HorizontalAlign="Left" SortExpression="provider"> 
                <HeaderStyle HorizontalAlign="Left" Width="150px"></HeaderStyle>
            </asp:BoundField>
            <asp:BoundField DataField="provname" HeaderText="Provider Name" 
                HeaderStyle-HorizontalAlign="Left"  SortExpression="provname" >
                <HeaderStyle HorizontalAlign="Left" Width="300px"></HeaderStyle>
            </asp:BoundField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" runat="server" Text="Create New Provider Group" NavigateUrl='<%# String.Format("ProviderEdit.aspx?action=newgroup&primprovider={0}", Convert.ToString(Eval("provider"))) %>' />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="ProviderSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.Provider" EnablePaging="True"  SortParameterName="sortExpression">
        <SelectParameters>
            <asp:Parameter Name="unassigned" DefaultValue="True" Type="Boolean" />
            <asp:ControlParameter Name="searchstr" ControlID="searchstr" DefaultValue="" PropertyName="Text" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
