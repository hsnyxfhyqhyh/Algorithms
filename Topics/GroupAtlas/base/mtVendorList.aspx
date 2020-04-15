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
        //if (e.Exception == null)
        //    message.InnerHtml = "Vendor was successfully deleted.";
        //else
        //{
        //    message.InnerHtml = e.Exception.InnerException.Message;
        //    e.ExceptionHandled = true;
        //}
    }

    protected void Grid_DeleteCommand(object sender, GridCommandEventArgs e)
    {
        string vendorcode = e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["vendorcode"].ToString();
        int RID = Convert.ToInt32(e.Item.OwnerTableView.DataKeyValues[e.Item.ItemIndex]["RID"]);
        try
        {
            //mtVendor v = new mtVendor();
            //v = mtVendor.GetVendor(ID);
            //if (v.vendorCode == ID)
            //{
            //    message.InnerHtml = "Vendor was successfully deleted.";
            //}
            int iReturn = 0;


            iReturn = mtVendor.GetVendorFlyers(vendorcode);
            if (iReturn == 0)
            {
                iReturn = mtVendor.GetVendorGroups(vendorcode);
                if (iReturn == 0)
                {
                    mtVendor.Delete(RID);
                    message.InnerHtml = "Vendor was successfully deleted.";
                }
                else
                {
                    message.InnerHtml = "Vendor exists in Groups Tab and can't be deleted.";
                }
            }
            else
            {
                message.InnerHtml = "Vendor exists in Flyers Tab and can't be deleted.";
            }
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
            GridDataItem item = e.Item as GridDataItem;
            if (item["GroupsCounter"].Text != "0" )
            {
                LinkButton lbutton = item["DeleteColumn"].Controls[0] as LinkButton;
                lbutton.Enabled = false;
                lbutton.ToolTip = "Item cannot be deleled";
            }
            if (item["FlyersCounter"].Text != "0" )
            {
                LinkButton lbutton = item["DeleteColumn"].Controls[0] as LinkButton;
                lbutton.Enabled = false;
                lbutton.ToolTip = "Item cannot be deleled";

            }

        }
        ////Check the formatting condition
        //if (dataBoundItem["status"].Text == "Active")
        //{
        //    dataBoundItem["status"].ForeColor = System.Drawing.Color.Green;
        //    dataBoundItem["status"].Font.Bold = true;
        //    //Customize more...
        //}
        //else
        //{
        //    dataBoundItem["status"].ForeColor = System.Drawing.Color.Red;
        //    dataBoundItem["status"].Font.Bold = false;
        //}

    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {

    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Vendors</td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='mtVendorEdit.aspx?vendorcode=';return false;" value="Add Vendor" />
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
        <tr>
            <td align="left">
                <telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource" RenderMode="Lightweight" 
                    CellPadding="0" OnDeleteCommand="Grid_DeleteCommand" OnItemDataBound="Grid_ItemDataBound" Width="700px">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView AutoGenerateColumns="false" DataKeyNames="vendorcode,RID" AllowFilteringByColumn="true" PageSize="50" TableLayout="Fixed">
                        <AlternatingItemStyle BackColor="LightGray" />
                        <Columns>
                            <telerik:GridBoundColumn DataField="RID" UniqueName="RID" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                                    HeaderText="RID" SortExpression="RID" DataType="System.Int32" ItemStyle-ForeColor="Black" 
                                    AutoPostBackOnFilter="false" ShowFilterIcon="false" Visible="false">
                            </telerik:GridBoundColumn>
                            <telerik:GridHyperLinkColumn HeaderText="Vendor Code" DataTextField="vendorcode" 
                                DataNavigateUrlFormatString="mtVendorEdit.aspx?vendorcode={0}&RID={1}" DataNavigateUrlFields="vendorcode, RID" 
                                AutoPostBackOnFilter="true" FilterControlWidth="100px" CurrentFilterFunction="Contains" ShowFilterIcon="true" SortExpression="vendorcode" >
                                <HeaderStyle Width="140px" />
                                <ItemStyle Width="140px" />
                            </telerik:GridHyperLinkColumn>
                            <telerik:GridBoundColumn DataField="vendorName" UniqueName="vendorName" ItemStyle-Font-Bold="false" ItemStyle-Font-Italic="false" 
                                    HeaderText="Vendor Name" SortExpression="vendorName" DataType="System.String" ItemStyle-ForeColor="Black" 
                                    AutoPostBackOnFilter="true" FilterControlWidth="220px" CurrentFilterFunction="Contains" ShowFilterIcon="true">
                                <HeaderStyle Width="260px" />
                                <ItemStyle Width="260px" />
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
                <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" TypeName="GM.mtVendor">
                    <%--<SelectParameters>
                        <asp:Parameter Name="vendorcode" Type="String" />
                        <asp:Parameter Name="VGroupCode" Type="String" />
                    </SelectParameters>--%>
                </asp:ObjectDataSource>
            </td>
        </tr>
    </table>
    
      
    
<%--    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.mtVendor" />--%>
</asp:Content>
