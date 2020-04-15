<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="ThemeMaintenance.aspx.cs" Inherits="ThemeMaintenance" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
     <script type="text/javascript">
        function confirmDelete(paxExist) {
                return confirm('Are you sure you wish to delete?');
        }
    </script>

    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Theme List</td>
            <td align="right">
               <%--&nbsp;&nbsp;<asp:Button ID="bntQuestionSort" runat="server" Text="Sort Questions" OnClick="bntQuestionSort_Click" />--%>
                <%-- &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionSort.aspx';return false;" value="Sort Type" />
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionEdit.aspx?questionid=0';return false;" value="Add Type" />--%>
                 &nbsp;&nbsp;<asp:Button ID="btnAdd" runat="server" Text="Add Theme" OnClick="btnAdd_Click" />
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
     <asp:Panel ID="pnlAdd" runat="server" Visible="false">
        <table>
            <tr>
                <td>
                    <asp:Label runat="server" Text="Theme:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="tbTheme" runat="server" BackColor="LightYellow" TextMode="SingleLine" MaxLength="100" Width="500px"></telerik:RadTextBox>
                </td>
                <td>
                    <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click"></asp:Button>
                </td>
                <td>
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click"></asp:Button>
                </td>
            </tr>
        </table>
    </asp:Panel>
    <asp:Label ID="lblError" runat="server" ForeColor="Red" Visible="false"></asp:Label>
    <telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource" RenderMode="Lightweight" Width="600px"
        CellPadding="0" OnNeedDataSource="Grid_NeedDataSource" OnItemDataBound="Grid_ItemDataBound" OnDeleteCommand="Grid_DeleteCommand"
        OnEditCommand="Grid_EditCommand" OnUpdateCommand="Grid_UpdateCommand" AutoPostBackOnFilter="true">
        <GroupingSettings CaseSensitive="false" />
        <MasterTableView AutoGenerateColumns="false" DataKeyNames="TourID, TourName" AllowFilteringByColumn="true" EditMode="InPlace"
            PageSize="50" TableLayout="Fixed">
            <AlternatingItemStyle BackColor="LightGray" />
          <Columns>
            <telerik:GridBoundColumn  DataField="TourID" HeaderText="TourID" HeaderStyle-HorizontalAlign="Left" SortExpression="TourID" Visible="false" />
            <telerik:GridBoundColumn  DataField="TourName" HeaderText="Theme Name" HeaderStyle-HorizontalAlign="Center" SortExpression="TourName" FilterControlWidth="260px" ShowFilterIcon="true" AutoPostBackOnFilter="true">
                <HeaderStyle Width="300px" />
                <ItemStyle Width="300px" />
            </telerik:GridBoundColumn>
            
            <telerik:GridBoundColumn DataField="GroupsCounter" HeaderText="Groups Counter" HeaderStyle-HorizontalAlign="Left" 
                SortExpression="GroupsCounter" Visible="true" ReadOnly="true" AllowFiltering="false" ItemStyle-Width="80px" />
            <telerik:GridEditCommandColumn ButtonType="LinkButton" HeaderStyle-Width="100px"></telerik:GridEditCommandColumn>
            <telerik:GridTemplateColumn HeaderStyle-Width="60px" ItemStyle-Width="60px" ShowFilterIcon="false" AllowFiltering="false" UniqueName="Delete" >
                <ItemTemplate>
                    <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete"  
                        OnClientClick="return confirm('Are you sure you wish to delete?');" Text="Delete" />
                </ItemTemplate>
            </telerik:GridTemplateColumn>     

        </Columns>
        <NoRecordsTemplate>
                <div>There are no records to display</div>
        </NoRecordsTemplate>
    </MasterTableView> 
 </telerik:RadGrid>
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetTheme" DeleteMethod="DeleteTask" TypeName="GM.GroupMaster"  UpdateMethod="UpdateTheme" />
</asp:Content>
