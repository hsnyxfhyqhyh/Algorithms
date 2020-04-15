<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="GroupTypeList.aspx.cs" Inherits="GroupTypeList" %>

<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="Server">
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
            <td class="hdr" valign="bottom">Group Type</td>
            <td align="right">
                <%--&nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='TypeListSort.aspx';return false;" value="Sort Group" />--%>
                &nbsp;&nbsp;<asp:Button ID="btnSort" runat="server" OnClick="btnSort_Click" Text="Sort Group" />
                &nbsp;&nbsp;<asp:Button ID="btnAdd" runat="server" Text="Add Group" OnClick="btnAdd_Click" />

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
    <asp:Panel ID="pnlAddType" runat="server" Visible="false">
        <table>
            <tr>
                <%--<td>
                    <asp:Label runat="server" Text="Display Order:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="ntOrder" runat="server" BackColor="LightYellow" NumberFormat-DecimalDigits="0" Width="35px"></telerik:RadNumericTextBox>
                </td>--%>
                <td>
                    <asp:Label runat="server" Text="Group Type:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="tbGroupName" runat="server" BackColor="LightYellow" TextMode="SingleLine" MaxLength="50" Width="350px"></telerik:RadTextBox>
                </td>
                <td>
                    <telerik:RadDropDownList runat="server" ID="ddlAffinity" RenderMode="Lightweight" DefaultMessage="Select Imitation Type...">
                        <Items>
                            <telerik:DropDownListItem Text="Affinity" Value="4" />
                            <telerik:DropDownListItem Text="Non Affinity" Value="1" />
                        </Items>
                    </telerik:RadDropDownList>
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
    <table>
        <tr>
            <td>
                <asp:Label ID="lblError" runat="server" ForeColor="Red" Visible="false"></asp:Label>
            </td>
        </tr>
        <tr>
            <td valign="top" colspan="5">

                <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="100" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource"
                    AutoGenerateColumns="False" DataKeyNames="RID, PickCode, PickDesc" OnRowDeleted="Grid_RowDeleted" OnRowCommand="Grid_RowCommand" OnRowUpdating="Grid_RowUpdating">
                    <AlternatingRowStyle BackColor="#cccccc" ForeColor="Black" />
                    <HeaderStyle CssClass="listhdr" />
                    <Columns>
                        <asp:BoundField DataField="RID" HeaderText="RID" HeaderStyle-HorizontalAlign="Left" SortExpression="RID" Visible="false" />
                        <asp:BoundField DataField="PickCode" HeaderText="Code" HeaderStyle-HorizontalAlign="Left" SortExpression="PickCode" Visible="false" />
                        <%--<asp:TemplateField HeaderText="Display Order" HeaderStyle-HorizontalAlign="Left" SortExpression="Sort" HeaderStyle-Width="100px">
                            <ItemTemplate>
		                        <%# Eval("Sort") %>
		                    </ItemTemplate> 
                            <EditItemTemplate>
                                <telerik:RadMaskedTextBox RenderMode="Lightweight" runat="server" ID="Sort" Width="35px" Text='<%# Bind("Sort") %>' BackColor="LightPink" BorderColor="Black" Mask="###" >
                                </telerik:RadMaskedTextBox>
                            </EditItemTemplate>
                       </asp:TemplateField>--%>
                        <asp:TemplateField HeaderText="Group Description" HeaderStyle-HorizontalAlign="Left" SortExpression="PickDesc" ItemStyle-ForeColor="Black" ItemStyle-Font-Bold="true" ItemStyle-Width="200px">
                            <ItemTemplate>
                                <%# Eval("PickDesc") %>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <telerik:RadTextBox ID="PickDesc" runat="server" Width="350px" TextMode="SingleLine" Text='<%# Bind("PickDesc") %>' BackColor="LightYellow" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Imitates" HeaderStyle-HorizontalAlign="Left" SortExpression="GroupDesc" HeaderStyle-Width="100px" ItemStyle-ForeColor="Maroon">
                            <ItemTemplate>
                                <%# Eval("GroupDesc") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <%-- <asp:BoundField DataField="GroupDesc" HeaderText="Imitates" HeaderStyle-HorizontalAlign="Left"  SortExpression="GroupDesc" Visible="true" />--%>
                        <asp:TemplateField ShowHeader="False" HeaderStyle-Width="40px">
                            <EditItemTemplate>
                                <asp:LinkButton ID="LnkUpdate" ValidationGroup="Edit" runat="server" CausesValidation="true" CommandName="Update" Text="Update" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="LnkEdit" runat="server" CausesValidation="true" CommandName="Edit" Text="Edit" />
                            </ItemTemplate>
                            <FooterTemplate>
                                <asp:Button ID="LnkSave" ValidationGroup="Insert" runat="server" CausesValidation="false" CommandName="Save" Text="Save" />
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ShowHeader="False" HeaderStyle-Width="50px">
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
                            No records found....
                        </p>
                    </EmptyDataTemplate>
                </asp:GridView>
                <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetGroupList" DeleteMethod="DeleteGroupType" TypeName="GM.GroupMaster" UpdateMethod="UpdateGroupType1">
                    <SelectParameters>
                        <%--<asp:Parameter Name="RID" DefaultValue="RID" Type="Int32" />--%>
                        <asp:Parameter Name="PickType" DefaultValue="GROUPTYPE" Type="String" />
                        <asp:Parameter Name="StatusVisible" DefaultValue="YES" Type="String" />
                    </SelectParameters>
                    <DeleteParameters>
                        <asp:Parameter Name="PickType" DefaultValue="GROUPTYPE" Type="String" />
                        <asp:Parameter Name="PickCode" Type="String" />
                        <asp:Parameter Name="RID" Type="Int32" />
                        <asp:Parameter Name="PickDesc" Type="String" />
                    </DeleteParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="RID" Type="Int32" />
                        <asp:Parameter Name="PickType" DefaultValue="GROUPTYPE" Type="String" />
                        <asp:Parameter Name="PickCode" Type="String" />
                        <asp:Parameter Name="PickDesc" Type="String" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
            </td>
            <td valign="top">
                <asp:Panel ID="pnlSort" runat="server" Visible="false" Width="320px">
                    <table>
                        <tr>
                            <td colspan="3">
                                <div class="demo-container size-thin">
                                    <telerik:RadListBox RenderMode="Lightweight" runat="server" ID="RadListBox1" AllowReorder="true" AllowDelete="false"
                                        Height="250px" Width="300px"
                                        OnClientSelectedIndexChanged="OnClientSelectedIndexChanged"
                                        SelectionMode="Single">
                                    </telerik:RadListBox>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <div>
                        <table>
                            <tr>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="2" align="center">
                                    <asp:Button ID="save" runat="server" Text="Update" OnClick="save_Click" CssClass="button"></asp:Button>
                                    <asp:Button ID="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False" OnClick="cancel_Click"></asp:Button>
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

