<%@ Page Language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
            message.InnerHtml  = Request.QueryString ["msg"];
    }

    //protected void Grid_RowDeleted(object sender, GridViewDeletedEventArgs e)
    //{
    //    if (e.Exception == null)
    //        message.InnerHtml = "Departure Point was successfully deleted.";
    //    else
    //    {
    //        message.InnerHtml = e.Exception.InnerException.Message;
    //        e.ExceptionHandled = true;
    //    }
    //}
    protected void Grid_DeleteCommand(object sender, GridCommandEventArgs e)
    {
        int ID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["departurecode"].ToString());
        try
        {
            mtDeparturePoint.Delete(ID);
            message.InnerHtml = "Departure Point was successfully deleted.";
        }
        catch (Exception ex)
        {
            message.InnerText = ex.Message;
        }
    }

    protected void Grid_ItemDeleted(object sender, GridDeletedEventArgs e)
    {

        if (e.Exception == null)
            message.InnerHtml = "Departure Point was successfully deleted.";
        else
        {
            message.InnerHtml = e.Exception.InnerException.Message;
            e.ExceptionHandled = true;
        }
    }

    protected void Grid_ItemDataBound(object sender, GridItemEventArgs e)
    {
        //when the Grid is in normal mode   
        if (e.Item is GridDataItem)
        {
            GridDataItem item = e.Item as GridDataItem;
            if (item["GroupCount"].Text != "0" || item["FlyerCount"].Text != "0")
            {
                //LinkButton btn = (LinkButton)item["LnkDelete"].Controls[0]; 
                LinkButton btn = e.Item.FindControl("LnkDelete") as LinkButton;
                btn.Enabled = false;
                btn.ToolTip = "Item cannot be deleled";
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Group Departure Points</td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='mtDeparturePointEdit.aspx?departurecode=0';return false;" value="Add Departure Point" />
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
    <%--</table>--%>
   <%-- <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="100" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource"
        AutoGenerateColumns="False" DataKeyNames="departurecode" onrowdeleted="Grid_RowDeleted">
        <HeaderStyle CssClass="listhdr" />
        <Columns>
	        <asp:HyperLinkField DataTextField="departurepoint" HeaderText="Departure Point" HeaderStyle-HorizontalAlign="Left" SortExpression="departurepoint" 
                DataNavigateUrlFormatString="mtDeparturePointEdit.aspx?departurecode={0}" DataNavigateUrlFields="departurecode" />  
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
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.mtDeparturePoint" />--%>
        <tr>
            <td align="left">
                <telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource" RenderMode="Lightweight" 
                    CellPadding="0" OnItemDeleted="Grid_ItemDeleted" OnItemDataBound="Grid_ItemDataBound" Width="600px" OnDeleteCommand="Grid_DeleteCommand">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView AutoGenerateColumns="false" DataKeyNames="departurecode" AllowFilteringByColumn="true" PageSize="50" TableLayout="Fixed">
                        <AlternatingItemStyle BackColor="LightGray" />
                        <Columns>
                            <telerik:GridHyperLinkColumn HeaderText="Departure Point" DataTextField="departurepoint" 
                                DataNavigateUrlFormatString="mtDeparturePointEdit.aspx?departurecode={0}" DataNavigateUrlFields="departurecode" 
                                AutoPostBackOnFilter="true" FilterControlWidth="260px" CurrentFilterFunction="Contains" ShowFilterIcon="true" SortExpression="departurepoint" >
                                <HeaderStyle Width="300px" />
                                <ItemStyle Width="300px" />
                            </telerik:GridHyperLinkColumn>
                            <telerik:GridBoundColumn DataField="GroupCount" UniqueName="GroupCount" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                                    HeaderText="Group Count" SortExpression="GroupCount" DataType="System.String" ItemStyle-ForeColor="Black" 
                                    AutoPostBackOnFilter="true" ShowFilterIcon="false" AllowFiltering="false">
                                <HeaderStyle Width="100px" />
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="FlyerCount" UniqueName="FlyerCount" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                                    HeaderText="Flyer Count" SortExpression="FlyerCount" DataType="System.String" ItemStyle-ForeColor="Black" 
                                    AutoPostBackOnFilter="true" ShowFilterIcon="false" AllowFiltering="false">
                                <HeaderStyle Width="100px" />
                            </telerik:GridBoundColumn>
                            <telerik:GridTemplateColumn HeaderText="Delete" HeaderStyle-Width="60px" ItemStyle-Width="60px" ShowFilterIcon="false" AllowFiltering="false" UniqueName="Delete" >
                                <ItemTemplate>
                                    <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete"  
                                        OnClientClick="return confirm('Are you sure you wish to delete?');" Text="Delete" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                           <%-- <telerik:GridButtonColumn CommandName="Delete" Text="Delete" UniqueName="DeleteColumn" ConfirmTextFields="Are you sure you wish to delete?" >
                                <ItemStyle Width="60px" />
                                <HeaderStyle Width="60px" />
                            </telerik:GridButtonColumn>--%>
                            </Columns>
                            <NoRecordsTemplate>
                                  <div>There are no records to display</div>
                            </NoRecordsTemplate>
                        </MasterTableView> 
                    </telerik:RadGrid>
                <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.mtDeparturePoint" />
            </td>
        </tr>
    </table>
</asp:Content>
