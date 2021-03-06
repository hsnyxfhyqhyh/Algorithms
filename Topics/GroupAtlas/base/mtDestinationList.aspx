<%@ Page Language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

	void Page_Load(object sender, System.EventArgs e)
	{
		if (!IsPostBack) 
			message.InnerHtml  = Request.QueryString ["msg"];
	}
    
    protected void Grid_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {
        if (e.Exception == null)
            message.InnerHtml = "Destination was successfully deleted.";
        else
        {
            message.InnerHtml = e.Exception.InnerException.Message;
            e.ExceptionHandled = true;
        }
    }
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Group Departure Destinations</td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='mtDestinationEdit.aspx?destinationcode=0';return false;" value="Add Destination" />
             </td>
        </tr>
        <tr>
            <td width="100%" class="line" colspan="2" height="1"></td>
        </tr>
        <tr>
            <td>
                <span id="message" class="message" runat="server" enableviewstate="false"></span>
                &nbsp;
            </td>
        </tr>
    </table>
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="100" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource"
        AutoGenerateColumns="False" DataKeyNames="destinationcode" onrowdeleted="Grid_RowDeleted">
        <HeaderStyle CssClass="listhdr" />
        <Columns>
	        <asp:HyperLinkField DataTextField="destinationdescription" HeaderText="Destination Name" HeaderStyle-HorizontalAlign="Left" SortExpression="destinationdescription" DataNavigateUrlFormatString="mtDestinationEdit.aspx?destinationcode={0}" DataNavigateUrlFields="destinationcode" />  
            <asp:TemplateField HeaderText="Delete" HeaderStyle-Width="25px"  ItemStyle-Width="25px" >
                <ItemTemplate>
                    <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure you wish to delete?');" Text="Delete" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.mtDestination" />
</asp:Content>
