<%@ Page Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="AgentsHelper.aspx.cs" Inherits="AgentsHelper" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
        <div>
            <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Employee Listing</td>
            <td align="right">
               <%--&nbsp;&nbsp;<asp:Button ID="bntQuestionSort" runat="server" Text="Sort Questions" OnClick="bntQuestionSort_Click" />--%>
                <%-- &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionSort.aspx';return false;" value="Sort Type" />
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionEdit.aspx?questionid=0';return false;" value="Add Type" />--%>
                 &nbsp;&nbsp;<asp:Button ID="BtnClose" runat="server" OnClick="BtnClose_Click" Text="Close" />
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
            <telerik:RadGrid ID="Grid" runat="server" AllowPaging="true" AllowSorting="true" RenderMode="Lightweight" CellPadding="0" AutoPostBackOnFilter="true" PageSize="100" Width="800px" Height="450px">
                <GroupingSettings CaseSensitive="false" />
                <MasterTableView AutoGenerateColumns="false" DataKeyNames="lastname, firstname, Title" AllowFilteringByColumn="true" >
                        <AlternatingItemStyle BackColor="Snow"/>
                        <Columns>
                            <telerik:GridBoundColumn HeaderText="Last Name" DataField="lastname" SortExpression="lastname" ItemStyle-Width="150px" FilterControlWidth="85%" CurrentFilterFunction="Contains" 
                                ShowFilterIcon="true">
                                <ItemStyle Width="200px" />
                                <HeaderStyle Width="200px" />
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="First Name" DataField="firstname" SortExpression="firstname" ItemStyle-Width="150px" FilterControlWidth="85%" CurrentFilterFunction="Contains" 
                                ShowFilterIcon="true">
                                <ItemStyle Width="200px" />
                                <HeaderStyle Width="200px" />
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="Title" DataField="Title" SortExpression="Title" ItemStyle-Width="200px" FilterControlWidth="85%" CurrentFilterFunction="Contains" 
                                ShowFilterIcon="true" ItemStyle-Wrap="false">
                                <ItemStyle Width="400px" />
                                <HeaderStyle Width="400px" />
                            </telerik:GridBoundColumn>
                        </Columns>
                    </MasterTableView> 
                    <ClientSettings EnableRowHoverStyle="true" AllowGroupExpandCollapse="true">
                    <Resizing AllowColumnResize="true" />
                    <Selecting AllowRowSelect="true" />
                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                </ClientSettings>
            </telerik:RadGrid>
            </div>
          
</asp:Content>
