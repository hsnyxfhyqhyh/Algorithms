<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="TypeList.aspx.cs" Inherits="TypeList" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
    <script type="text/javascript">
        function confirmDelete(paxExist) {
                return confirm('Are you sure you wish to delete?');
        }

        // ENTER Key not allowed
        //function dumpEnter() {
        //    if(event.keyCode==13){
        //        event.keyCode = null;
        //        return;
        //    }
        //}

        //Stop Form Submission of Enter Key Press
        //    function stopRKey(evt) {
        //        var evt = (evt) ? evt : ((event) ? event : null);
        //        var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
        //        if ((evt.keyCode == 13) && (node.type == "text")) { return false; }
        //    }
        //document.onkeypress = stopRKey;    

    </script>

    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Task Types</td>
            <td align="right">
               <%--&nbsp;&nbsp;<asp:Button ID="bntQuestionSort" runat="server" Text="Sort Questions" OnClick="bntQuestionSort_Click" />--%>
                 &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='TypeListSort.aspx';return false;" value="Sort Type" />
               <%-- &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionEdit.aspx?questionid=0';return false;" value="Add Type" />--%>
                &nbsp;&nbsp;<asp:Button ID="btnAddType" runat="server" Text="Add Type" OnClick="btnAddType_Click" onkeydown="return(event.keyCode!=13);"  />
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
                <td>
                    <asp:Label runat="server" Text="Display Order:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="ntOrder" runat="server" BackColor="LightYellow" NumberFormat-DecimalDigits="0" Width="35px" ></telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label runat="server" Text="Type:" Font-Bold="true"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="tbType" runat="server" BackColor="LightYellow" TextMode="SingleLine" MaxLength="50" Width="350px"></telerik:RadTextBox>
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
    <asp:GridView ID="Grid" runat="server" Width="70%" CssClass="list" CellPadding="3" PageSize="100" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" 
        DataSourceID="gridSource" AutoGenerateColumns="False" DataKeyNames="TaskType" onrowdeleted="Grid_RowDeleted" OnRowCommand="Grid_RowCommand"> 
        <AlternatingRowStyle BackColor="#cccccc" ForeColor="Black" />
        <HeaderStyle CssClass="listhdr" />
        <Columns>
            <asp:BoundField DataField="TaskType" HeaderText="Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="TaskType" Visible="false" />
            <asp:TemplateField HeaderText="Display Order" HeaderStyle-HorizontalAlign="Left" SortExpression="TaskTypeOrder">
                <ItemTemplate>
		            <%# Eval("TaskTypeOrder") %>
		        </ItemTemplate> 
                <EditItemTemplate>
                    <telerik:RadMaskedTextBox RenderMode="Lightweight" runat="server" ID="TaskTypeOrder" Width="35px" Text='<%# Bind("TaskTypeOrder") %>' BackColor="LightPink" BorderColor="Black" Mask="###" >
                    </telerik:RadMaskedTextBox>
                </EditItemTemplate>
           </asp:TemplateField>
    
            <asp:TemplateField HeaderText="Type Name" HeaderStyle-HorizontalAlign="Left" SortExpression="TaskName">
                <ItemTemplate>
		            <%# Eval("TaskName") %>
		        </ItemTemplate> 
                <EditItemTemplate>
                        <telerik:RadTextBox ID="TaskName" runat="server" Width="350px" TextMode="SingleLine" Text='<%# Bind("TaskName") %>' BackColor="LightYellow" /> 
                </EditItemTemplate>
           </asp:TemplateField>
          
            <asp:TemplateField ShowHeader="False" HeaderStyle-Width="40px" >
                <EditItemTemplate>
                    <asp:LinkButton ID="LnkUpdate" ValidationGroup="Edit" runat="server" CausesValidation="true" CommandName="Update" Text="Update" CommandArgument="<%# ((GridViewRow) Container).RowIndex %>" />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:LinkButton ID="LnkEdit" runat="server" CausesValidation="true" CommandName="Edit" Text="Edit" />
                </ItemTemplate>
                <FooterTemplate>
                    <asp:Button ID="LnkSave" ValidationGroup="Insert"  runat="server" CausesValidation="false"  CommandName="Save" Text="Save" />
                </FooterTemplate>
            </asp:TemplateField>
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
        
    </asp:GridView>
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetTaskType" DeleteMethod="DeleteTaskType" TypeName="GM.GroupMaster" UpdateMethod="UpdateTaskType">
        <DeleteParameters>
            <asp:Parameter Name="TaskType" Type="Int32" />
        </DeleteParameters>
    </asp:ObjectDataSource>
    
</asp:Content>


