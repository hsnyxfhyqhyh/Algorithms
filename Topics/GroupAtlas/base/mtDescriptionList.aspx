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
            message.InnerHtml = "Description was successfully deleted.";
        else
        {
            message.InnerHtml = e.Exception.InnerException.Message;
            e.ExceptionHandled = true;
        }
    }

    protected void btnDeleteExpired_Click(object sender, EventArgs e)
    {
        int iReturn = 0;
        try
        {

            //Delete by Expired Date
            iReturn = mtDescription.DeleteAllByExpiredDate();
            if (iReturn >= 0)
            {
                //Delete by empty Date
                iReturn = mtDescription.DeleteAllByEmptyDate();
                if (iReturn >=0)
                {
                    Response.Redirect("mtDescriptionList.aspx");
                }
            }
        }
        catch(Exception ex)
        {
            throw ex;
        }


    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Group Descriptions</td>
            <td align="right">
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='mtDescriptionEdit.aspx?id=0';return false;" value="Add Description" />
             </td>
            <td align="right">
                &nbsp;&nbsp;<asp:Button ID="btnDeleteExpired" runat="server" Text="Delete Expired" OnClick="btnDeleteExpired_Click" OnClientClick="return confirm('Are you sure you wish to delete?');" />
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
        AutoGenerateColumns="False" DataKeyNames="id" onrowdeleted="Grid_RowDeleted">
        <HeaderStyle CssClass="listhdr" />
         <AlternatingRowStyle BackColor="LightYellow"/>
        <RowStyle VerticalAlign="Top" />
        <Columns>
	        <asp:HyperLinkField DataTextField="title" HeaderText="Title" HeaderStyle-HorizontalAlign="Left" SortExpression="title" DataNavigateUrlFormatString="mtDescriptionEdit.aspx?id={0}" DataNavigateUrlFields="id" ItemStyle-Width="25%" />  
            <asp:TemplateField HeaderText="Description"  HeaderStyle-HorizontalAlign="Left">
                <ItemTemplate>
                    <%# GM.Util.DisplayMemo((string)Eval("description")) %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="departuredate" HeaderText="Departure" HeaderStyle-HorizontalAlign="Left" SortExpression="departuredate" ItemStyle-Font-Bold="false" ItemStyle-ForeColor="Black"/>
            <asp:TemplateField HeaderText="Status"  HeaderStyle-HorizontalAlign="Left" SortExpression="Status">
                <ItemTemplate>  
                    <asp:Label ID="lblStatus" runat="server" 
                        Text='<%# Convert.ToBoolean(Eval("status")) == true ? "Active" : "Inactive" %>'
                        ForeColor='<%# Convert.ToBoolean(Eval("status")) == true ? System.Drawing.Color.Green: Convert.ToBoolean(Eval("status")) == false ? System.Drawing.Color.Red: System.Drawing.Color.Purple%>'>
                    </asp:Label>  
                </ItemTemplate>
            </asp:TemplateField>
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
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.mtDescription" />
</asp:Content>
