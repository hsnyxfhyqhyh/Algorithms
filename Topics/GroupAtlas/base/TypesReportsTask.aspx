<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="TypesReportsTask.aspx.cs" Inherits="TypesReportsTask" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
    <script type="text/javascript">
        function confirmDelete(paxExist) {
                return confirm('Are you sure you wish to delete?');
        }

        function OnClientSelectedIndexChanged(sender, args) {
            var items = sender.get_items();
            for (var i = 0; i < items.get_count(); i++) {
                if (sender.getItem(i).get_selected() == true) {
                    sender.getItem(i)._textElement.style.fontFamily = "Arial Black";
                }
                else {
                    sender.getItem(i)._textElement.style.fontFamily = "Segoe UI";
                }
            }
        }

    </script>
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Types - Reports - Tasks</td>
            <td align="right">
               
                Group: &nbsp;&nbsp;<telerik:RadDropDownList ID="ddlReports" runat="server" RenderMode="Lightweight" OnItemSelected="ddlReports_ItemSelected" AutoPostBack="true"></telerik:RadDropDownList>&nbsp;&nbsp;
                Type: &nbsp;&nbsp;<telerik:RadDropDownList ID="ddlTypes" runat="server" RenderMode="Lightweight" OnItemSelected="ddlTypes_ItemSelected" AutoPostBack="true"></telerik:RadDropDownList>
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
   <asp:Label ID="lblError" runat="server" ForeColor="Red" Visible="false"></asp:Label>
    <table>
        <tr>
            <td valign="top">
                <asp:gridview ID="Grid1" runat="server" CellPadding="3" DataKeyNames="TaskID, RptOrder" AutoGenerateColumns="False" 
                    OnRowCommand="Grid1_RowCommand" OnRowDeleting="Grid1_RowDeleting" OnRowEditing="Grid1_RowEditing" 
                    OnRowCancelingEdit="Grid1_RowCancelingEdit" OnRowUpdating="Grid1_RowUpdating">
                    <AlternatingRowStyle BackColor="Wheat" />
                    <HeaderStyle BorderStyle="Ridge" BackColor="DarkSlateGray" ForeColor="White" />
                    <Columns>
                        <asp:BoundField DataField="TaskID" HeaderText="Task ID" HeaderStyle-HorizontalAlign="Left"  SortExpression="TaskID" Visible="false" />
                       <%-- <asp:BoundField DataField="Task" HeaderText="Task" HeaderStyle-HorizontalAlign="Left"  SortExpression="Task" Visible="true" />--%>
                        <asp:TemplateField HeaderText="Task" HeaderStyle-HorizontalAlign="Left" SortExpression="Task">
                            <ItemTemplate>
		                        <%# Eval("Task") %>
		                    </ItemTemplate> 
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Order" HeaderStyle-HorizontalAlign="Left" SortExpression="RptOrder" Visible="false">
                            <ItemTemplate>
		                        <%# Eval("RptOrder") %>
		                    </ItemTemplate> 
                           <%-- <EditItemTemplate>
                                    <telerik:RadMaskedTextBox ID="RptOrder" runat="server" Width="50px" Mask="###" Text='<%# Bind("RptOrder") %>' BackColor="LightPink"  /> 
                            </EditItemTemplate>--%>
                       </asp:TemplateField>
          
                         <%--<asp:TemplateField ShowHeader="False" HeaderStyle-Width="40px" >
                            <EditItemTemplate>
                                <asp:LinkButton ID="LnkUpdate" ValidationGroup="Edit" runat="server" CausesValidation="false" CommandName="Update" Text="Update" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="LnkEdit" runat="server" CausesValidation="false" CommandName="Edit" Text="Edit"  CommandArgument='<%# Container.DataItemIndex %>'></asp:LinkButton>
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Button ID="LnkSave" ValidationGroup="Insert"  runat="server" CausesValidation="false"  CommandName="Save" Text="Save" />
                            </FooterTemplate>
                        </asp:TemplateField>--%>
                        <asp:TemplateField ShowHeader="False" HeaderStyle-Width="50px" >
                            <EditItemTemplate>
                                <asp:LinkButton ID="LnkCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure?');" Text="Delete" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
            <EmptyDataTemplate>
                <p class="message">
                    No records found....</p>
            </EmptyDataTemplate>
                       
                </asp:gridview>
                <asp:Button ID="btnSort" runat="server" Text="Sort Tasks" OnClick="btnSort_Click" Visible="false" />
            </td>
            <td>
                &nbsp;
            </td>
            <td valign="top">
                <asp:gridview ID="Grid2" runat="server" CellPadding="3"  DataKeyNames="TaskID" AutoGenerateColumns="False" OnRowCommand="Grid2_RowCommand" >
                    <AlternatingRowStyle BackColor="LightGray" />
                    <HeaderStyle BorderStyle="Ridge" BackColor="DarkOliveGreen" ForeColor="White" />
                    <Columns>
                        <asp:BoundField DataField="TaskID" HeaderText="Task ID" HeaderStyle-HorizontalAlign="Left"  SortExpression="TaskID" Visible="false" />
                        <asp:BoundField DataField="Task" HeaderText="Available Tasks" HeaderStyle-HorizontalAlign="Left" SortExpression="Task" Visible="true" />
                        <asp:TemplateField ShowHeader="False" HeaderStyle-Width="40px" >
                            <%--<EditItemTemplate>
                                <asp:LinkButton ID="LnkUpdate" runat="server" CommandName="Select" Text="Select" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                            </EditItemTemplate>--%>
                            <ItemTemplate>
                                <asp:LinkButton ID="Select" runat="server" CausesValidation="False" CommandName="Select"
                                    Text="Select"  CommandArgument='<%# Container.DataItemIndex %>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:gridview>
            </td>
            <td valign="top">
                <asp:Panel ID="pnlSort" runat="server" Visible="false">
                    <table>
                         <tr>
                            <td colspan="3">
                                <div class="demo-container size-thin">
                                    <telerik:RadListBox RenderMode="Lightweight" runat="server" ID="RadListBox1" AllowReorder="true" AllowDelete="false" 
                                        Height="350px" Width="450px" 
                                        OnClientSelectedIndexChanged="OnClientSelectedIndexChanged"
                                        SelectionMode="Single">
                                    </telerik:RadListBox>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <div>
                <table>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="Update" OnClick="save_Click" CssClass="button"></asp:button>
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False" OnClick="cancel_Click"></asp:button>
			</td>
		</tr>
	</table>
 </div>
 
       <telerik:RadAjaxManager runat="server" ID="RadAjaxManager1">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="ConfiguratorPanel1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadListBox1" LoadingPanelID="RadAjaxLoadingPanel1" />
                        <telerik:AjaxUpdatedControl ControlID="ConfiguratorPanel1" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
 
        <telerik:RadAjaxLoadingPanel runat="server" ID="RadAjaxLoadingPanel1" />
                </asp:Panel>
            </td>
        </tr>
    </table>
    

</asp:Content>

