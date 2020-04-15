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
            message.InnerHtml = "Ship was successfully deleted.";
        else
        {
            message.InnerHtml = e.Exception.InnerException.Message;
            e.ExceptionHandled = true;
        }
    }

    protected void Grid_DeleteCommand(object sender, GridCommandEventArgs e)
    {
        int ID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["shipid"].ToString());
        try
        {
            Ship.Delete(ID);
            message.InnerHtml = "Ship was successfully deleted.";
        }
        catch (Exception ex)
        {
            message.InnerText = ex.Message;
        }
    }

    protected void Grid_ItemDataBound(object sender, GridItemEventArgs e)
    {
        //Is it a GridDataItem
        if (e.Item is GridDataItem)
        {
            //Get the instance of the right type
            GridDataItem dataBoundItem = e.Item as GridDataItem;

            //Check the formatting condition
            if (dataBoundItem["status"].Text == "Active")
            {
                dataBoundItem["status"].ForeColor = System.Drawing.Color.Green;
                dataBoundItem["status"].Font.Bold = true;
                //Customize more...
            }
            else
            {
                dataBoundItem["status"].ForeColor = System.Drawing.Color.Red;
                dataBoundItem["status"].Font.Bold = false;
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Cruise Ships</td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='ShipEdit.aspx?shipid=0';return false;" value="Add Cruise Ship" />
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

<telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource" RenderMode="Lightweight" CellPadding="0"
    OnDeleteCommand="Grid_DeleteCommand" OnItemDataBound="Grid_ItemDataBound" Width="800px" >
    <GroupingSettings CaseSensitive="false" />
    <MasterTableView AutoGenerateColumns="false" DataKeyNames="shipid" AllowFilteringByColumn="true" PageSize="50">
       <%-- <HeaderStyle Width="102px" />--%>
        <Columns>
            <telerik:GridHyperLinkColumn HeaderText="Ship Name" DataTextField="shipname" DataNavigateUrlFormatString="ShipEdit.aspx?shipid={0}" DataNavigateUrlFields="shipid" 
                AutoPostBackOnFilter="true" FilterControlWidth="200px" CurrentFilterFunction="Contains" ShowFilterIcon="true" AllowSorting="true" >
   
            </telerik:GridHyperLinkColumn>
            <telerik:GridBoundColumn DataField="shipid" UniqueName="shipid" AllowSorting="false" ReadOnly="true" Display="false"
                    HeaderText="shipid" SortExpression="shipid" DataType="System.Int32">   
            </telerik:GridBoundColumn>
             <telerik:GridBoundColumn DataField="provider" UniqueName="provider" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                    HeaderText="Provider Code" SortExpression="provider" DataType="System.String" ItemStyle-ForeColor="Black" 
                    AutoPostBackOnFilter="true" FilterControlWidth="80px" CurrentFilterFunction="Contains" ShowFilterIcon="true">
                   
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="vendorName" UniqueName="vendorName" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                    HeaderText="Provider Name" SortExpression="vendorName" DataType="System.String" ItemStyle-ForeColor="Black" 
                    AutoPostBackOnFilter="true" FilterControlWidth="160px" CurrentFilterFunction="Contains" ShowFilterIcon="true">
 
            </telerik:GridBoundColumn>
           <telerik:GridBoundColumn DataField="status" UniqueName="status" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                    HeaderText="Status" SortExpression="status" DataType="System.String" ItemStyle-ForeColor="Maroon" AllowFiltering="false" ItemStyle-Width="80px">
     
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn DataField="GroupsCounter" HeaderText="Groups Counter" HeaderStyle-HorizontalAlign="Left" 
                    SortExpression="GroupsCounter" Visible="true" ReadOnly="true" AllowFiltering="false" ItemStyle-Width="100px" />
            <telerik:GridBoundColumn DataField="FlyersCounter" HeaderText="Flyers Counter" HeaderStyle-HorizontalAlign="Left" 
                    SortExpression="FlyersCounter" Visible="true" ReadOnly="true" AllowFiltering="false" ItemStyle-Width="100px" />
            <telerik:GridButtonColumn CommandName="Delete" Text="Delete" UniqueName="DeleteColumn" ConfirmText="Are you sure you wish to delete?">
                <ItemStyle Width="60px" />
                <HeaderStyle Width="60px" />
            </telerik:GridButtonColumn>
            
        </Columns>
    </MasterTableView> 
</telerik:RadGrid>
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.Ship" />
</asp:Content>
