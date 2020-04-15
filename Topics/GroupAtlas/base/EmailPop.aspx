<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EmailPop.aspx.cs" Inherits="EmailPop" %>
<%@ Import Namespace="GM" %>
 
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title></title>
        <style type="text/css">
            body
            {
                font-family: "segoe ui",arial,sans-serif;
                font-size: 12px;
            }
 
            a img
            {
                border: 0;
            }
        </style>
        <script src="scripts.js" type="text/javascript"></script>
    </head>
    <body onload="fixform()" >
   <%-- <body>--%>
        <form id="form1" runat="server">
            <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
            <telerik:RadSkinManager ID="RadSkinManager1" runat="server" ShowChooser="false" />
            
            <div class="demo-container">
                <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
                    <AjaxSettings>
                        <telerik:AjaxSetting AjaxControlID="ListViewPanel">
                            <UpdatedControls>
                                <telerik:AjaxUpdatedControl ControlID="ListViewPanel" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                            </UpdatedControls>
                        </telerik:AjaxSetting>
                    </AjaxSettings>
                </telerik:RadAjaxManager>
                <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server"></telerik:RadAjaxLoadingPanel>
                <telerik:RadListView runat="server" RenderMode="Lightweight" ID="GridListViewAgents" AllowPaging="false" DataKeyNames="groupID" >
                        <AlternatingItemTemplate>
                            <tr class="rlvA" style="background-color:cornsilk">
                                <td>
                                    <asp:Label ID="UnitPriceLabel" runat="server" Text='<%# Eval("EmailAgent") %>' ForeColor="Navy" ></asp:Label>
                                </td>
                            </tr>
                        </AlternatingItemTemplate>
                        <ItemTemplate>
                            <tr class="rlvI">
                                <td>
                                    <asp:Label ID="UnitPriceLabel" runat="server" Text='<%# Eval("EmailAgent") %>' ForeColor="Navy" ></asp:Label>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <div class="RadListView RadListView_<%# Container.Skin %>">
                                <div class="rlvEmpty">
                                    There are no items to be displayed.
                                </div>
                            </div>
                        </EmptyDataTemplate>
                        <LayoutTemplate>
                            <div class="RadListView RadListView_<%# Container.Skin %>">
                                <table class="gridMainTable">
                                    <thead>
                                        <tr class="rlvHeader">
                                            <th><b>Agents</b>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr id="itemPlaceholder" runat="server">
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </LayoutTemplate>
                    </telerik:RadListView>


                <telerik:RadListView runat="server" RenderMode="Lightweight" ID="GridListView" AllowPaging="false" DataKeyNames="groupID" >
                        <AlternatingItemTemplate>
                            <tr class="rlvA" style="background-color:cornsilk">
                               <%-- <td>
                                    <asp:Label ID="ProductIDLabel" runat="server" Text='<%# Eval("groupID") %>' ForeColor="Navy"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="ProductNameLabel" runat="server" Text='<%# Eval("BookingID") %>' ForeColor="Navy"></asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="QuantityPerUnitLabel" runat="server" Text='<%# Eval("Name") %>' ForeColor="Navy"></asp:Label>
                                </td>--%>
                                <td>
                                    <asp:Label ID="UnitPriceLabel" runat="server" Text='<%# Eval("Email") %>' ForeColor="Maroon" ></asp:Label>
                                </td>
                            </tr>
                        </AlternatingItemTemplate>
                        <ItemTemplate>
                            <tr class="rlvI">
                                <%--<td>
                                    <asp:Label ID="ProductIDLabel" runat="server" Text='<%# Eval("groupID") %>'></asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="ProductNameLabel" runat="server" Text='<%# Eval("BookingID") %>'></asp:Label>
                                </td>
                                <td>
                                    <asp:Label ID="QuantityPerUnitLabel" runat="server" Text='<%# Eval("Name") %>'></asp:Label>
                                </td>--%>
                                <td>
                                    <asp:Label ID="UnitPriceLabel" runat="server" Text='<%# Eval("Email") %>' ForeColor="Maroon" ></asp:Label>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <EmptyDataTemplate>
                            <div class="RadListView RadListView_<%# Container.Skin %>">
                                <div class="rlvEmpty">
                                    There are no items to be displayed.
                                </div>
                            </div>
                        </EmptyDataTemplate>
                        <LayoutTemplate>
                            <div class="RadListView RadListView_<%# Container.Skin %>">
                                <table class="gridMainTable">
                                    <thead>
                                        <%--<tr>
                                            <th>
                                                <h4>Group ID: <asp:Label ID="Label1" runat="server" ></asp:Label></h4>
                                            </th>
                                        </tr>--%>
                                        <tr class="rlvHeader">
                                            <%--<th><b>Group ID</b>
                                            </th>
                                            <th><b>Booking ID</b>
                                            </th>
                                            <th><b>Name</b>
                                            </th>--%>
                                            <th><b>Passengers</b>
                                            </th>
                                        </tr>
                                    </thead>
                                    <%--<tfoot>
                                        <tr>
                                            <td colspan="5">
                                                <telerik:RadDataPager RenderMode="Lightweight" ID="RadDataPager1" runat="server">
                                                    <Fields>
                                                        <telerik:RadDataPagerButtonField FieldType="Numeric"></telerik:RadDataPagerButtonField>
                                                    </Fields>
                                                </telerik:RadDataPager>
                                            </td>
                                        </tr>
                                    </tfoot>--%>
                                    <tbody>
                                        <tr id="itemPlaceholder" runat="server">
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </LayoutTemplate>
                    </telerik:RadListView>
                <%--<button onclick="myFunction()">Copy text</button>--%>
                <asp:Button ID="close" runat="server" OnClientClick="javascript:window.close()" Text="Close" />
            </div>

       

            <script type="text/javascript">
                function fixform() {
                    if (opener.document.getElementById("aspnetForm").target != "_blank") return;
                    opener.document.getElementById("aspnetForm").target = "";
                    opener.document.getElementById("aspnetForm").action = opener.location.href;
                }

                function myFunction() {
                var copyText = document.getElementById("GridListView");
                copyText.select();
                document.execCommand("copy");
                alert("Copied the text: " + copyText.value);
                }
            </script>
        </form>
    </body>
</html>
