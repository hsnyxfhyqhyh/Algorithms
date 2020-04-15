<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="Agents.aspx.cs" Inherits="Agents" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Agents</td>
            <td align="right">
               
               <%-- Group: &nbsp;&nbsp;<telerik:RadDropDownList ID="ddlReports" runat="server" RenderMode="Lightweight" OnItemSelected="ddlReports_ItemSelected" AutoPostBack="true"></telerik:RadDropDownList>&nbsp;&nbsp;
                Type: &nbsp;&nbsp;<telerik:RadDropDownList ID="ddlTypes" runat="server" RenderMode="Lightweight" OnItemSelected="ddlTypes_ItemSelected" AutoPostBack="true"></telerik:RadDropDownList>--%>
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
            <td valign="top" width="60%">
                <telerik:RadGrid ID="Grid1" runat="server" AllowPaging="true" AllowSorting="true" RenderMode="Lightweight" CellPadding="0" OnDeleteCommand="Grid1_DeleteCommand" OnItemDataBound="Grid1_ItemDataBound" OnItemCommand="Grid1_ItemCommand"
                    DataSourceID="gridSource1" AutoPostBackOnFilter="true">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView AutoGenerateColumns="false" DataKeyNames="RID,flxid,title" AllowFilteringByColumn="true" PageSize="25">
                        <AlternatingItemStyle BackColor="AliceBlue" />
                        <Columns>
                            <telerik:GridBoundColumn HeaderText="RID" DataField="RID"  CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" SortExpression="RID" Visible="false"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="flxid" DataField="flxid" CurrentFilterFunction="Contains" ShowFilterIcon="false" AutoPostBackOnFilter="true" SortExpression="flxid" Visible="false"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="Name" DataField="name" FilterControlWidth="85%"  CurrentFilterFunction="Contains" ShowFilterIcon="true" SortExpression="name" AutoPostBackOnFilter="true"></telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="Location" DataField="location" FilterControlWidth="85%" CurrentFilterFunction="Contains" ShowFilterIcon="true" AutoPostBackOnFilter="true" SortExpression="location"></telerik:GridBoundColumn> 
                            <telerik:GridBoundColumn HeaderText="Title" DataField="title" FilterControlWidth="85%"  CurrentFilterFunction="Contains" ShowFilterIcon="true" AutoPostBackOnFilter="true" SortExpression="title"></telerik:GridBoundColumn>        
                            <telerik:GridButtonColumn CommandName="Employee" Text="Employee" UniqueName="Employee" HeaderText="Delete">
                                <ItemStyle Width="80px" />
                                <HeaderStyle Width="80px" />
                            </telerik:GridButtonColumn>
                            <telerik:GridButtonColumn CommandName="Department" Text="Department" UniqueName="Department" HeaderText="Delete">
                                <ItemStyle Width="80px" />
                                <HeaderStyle Width="80px" />
                            </telerik:GridButtonColumn>
                        </Columns>
                    </MasterTableView> 
                    <ClientSettings EnableRowHoverStyle="true">
                    <Resizing AllowColumnResize="false" />
                    <Selecting AllowRowSelect="false" />
                    <Scrolling AllowScroll="false" />
                </ClientSettings>
                </telerik:RadGrid>
                <asp:ObjectDataSource ID="gridSource1" runat="server" SelectMethod="GetEmployee" TypeName="GM.Employee" />
            <td>
                &nbsp;
            </td>
            <td valign="top" width="40%">
                <telerik:RadGrid ID="Grid2" runat="server" AllowPaging="true" AllowSorting="true" RenderMode="Lightweight" CellPadding="0" OnItemCommand="Grid2_ItemCommand" OnItemDataBound="Grid2_ItemDataBound"
                    DataSourceID="gridSource" AutoPostBackOnFilter="true" PageSize="5000">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView AutoGenerateColumns="false" DataKeyNames="Title" AllowFilteringByColumn="true" >
                        <AlternatingItemStyle BackColor="BlanchedAlmond"/>
                        <Columns>
                            <telerik:GridBoundColumn HeaderText="Title" DataField="Title" FilterControlWidth="85%" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true"
                                ShowFilterIcon="true" SortExpression="Title">
                                <ItemStyle Width="50%" />
                                <HeaderStyle Width="50%" />
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn HeaderText="Count" DataField="count" ShowFilterIcon="false" CurrentFilterFunction="Contains" AutoPostBackOnFilter="true">
                               <%-- <ItemStyle Width="50px" />
                                <HeaderStyle Width="50px" />--%>
                            </telerik:GridBoundColumn>
                            <telerik:GridButtonColumn CommandName="Select" Text="Select" UniqueName="Select" >
                                <%--<ItemStyle Width="60px" />
                                <HeaderStyle Width="60px" />--%>
                            </telerik:GridButtonColumn>
                            <telerik:GridButtonColumn CommandName="View" Text="View" UniqueName="View" ButtonType="PushButton" >
                                <%--<ItemStyle Width="60px" />
                                <HeaderStyle Width="60px" />--%>
                            </telerik:GridButtonColumn>   
                        </Columns>
                    </MasterTableView> 
                    <ClientSettings EnableRowHoverStyle="true" AllowGroupExpandCollapse="true">
                    <Resizing AllowColumnResize="true" />
                    <Selecting AllowRowSelect="true" />
                    <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                </ClientSettings>
                </telerik:RadGrid>
                <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetTitle" TypeName="GM.Employee" />
            </td>
        </tr>
    </table>
     
</asp:Content>

