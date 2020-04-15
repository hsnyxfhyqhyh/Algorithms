<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="GroupDescription.aspx.cs" Inherits="GroupDescription" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
<script type="text/javascript">
        function confirmDelete(paxExist) {
                return confirm('Are you sure you wish to delete?');
        }
    </script>

    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Group Description List</td>
            <td align="right">
                 &nbsp;&nbsp;<asp:Button ID="btnAdd" runat="server" Text="Add Description" OnClick="btnAdd_Click" />
             </td>
        </tr>
        <tr>
            <td width="100%" class="line" colspan="2" height="1"></td>
        </tr>
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span><br>
			</td>
		</tr>
    </table>
     <asp:Panel ID="pnlAdd" runat="server" Visible="false">
        <table>
            <tr>
                <td>
                    <asp:Label runat="server" Text="Code:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="tbCode" runat="server" BackColor="LightYellow" TextMode="SingleLine" MaxLength="100" Width="80px"></telerik:RadTextBox>
                    
                </td>
                <td>
                    <asp:Label runat="server" Text="Description:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="tbDesc" runat="server" BackColor="LightYellow" TextMode="SingleLine" MaxLength="100" Width="320px"></telerik:RadTextBox>
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
        OnEditCommand="Grid_EditCommand" OnUpdateCommand="Grid_UpdateCommand">
        <GroupingSettings CaseSensitive="false" />
        <MasterTableView AutoGenerateColumns="false" DataKeyNames="RID, DescCode, Description" AllowFilteringByColumn="true" EditMode="InPlace"
            PageSize="50" TableLayout="Fixed">
            <AlternatingItemStyle BackColor="Wheat" />
          <Columns>
            <telerik:GridBoundColumn  DataField="RID" HeaderText="RID" HeaderStyle-HorizontalAlign="Left" SortExpression="RID" Visible="false" />
            <telerik:GridBoundColumn  DataField="DescCode" HeaderText="Group Code" HeaderStyle-HorizontalAlign="Center" SortExpression="DescCode" 
                FilterControlWidth="100px" ShowFilterIcon="true">
                <HeaderStyle Width="150px" />
                <ItemStyle Width="150px" />
            </telerik:GridBoundColumn>
            <telerik:GridBoundColumn  DataField="Description" HeaderText="Group Description" HeaderStyle-HorizontalAlign="Center" SortExpression="Description" FilterControlWidth="260px" ShowFilterIcon="true">
                <HeaderStyle Width="300px" />
                <ItemStyle Width="300px" />
            </telerik:GridBoundColumn>
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
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetDescCode" DeleteMethod="DeleteDescCode" TypeName="GM.GroupMaster"  UpdateMethod="UpdateDescCode" />
</asp:Content>

