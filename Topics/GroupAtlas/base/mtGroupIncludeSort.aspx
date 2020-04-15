<%@ Page Language="C#" AutoEventWireup="true" CodeFile="mtGroupIncludeSort.aspx.cs" Inherits="mtGroupIncludeSort" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="GM" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
         <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
        <div>

             <table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Sort Special Features Bullets </td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>

    <script type="text/javascript">
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
<table>
    <tr>
        <td colspan="6">
            <div class="demo-container size-thin">
                <telerik:RadListBox RenderMode="Lightweight" runat="server" ID="RadListBox1" AllowReorder="true" AllowDelete="false" 
                    Height="250px" Width="450px" 
                    DataTextField="include" 
                    DataValueField="includeid" 
                    DataSortField="incl_num"
                    DataSourceID="SqlDataSource1"
                    OnClientSelectedIndexChanged="OnClientSelectedIndexChanged"
                    SelectionMode="Single">
                </telerik:RadListBox>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:ConnectionString %>" 
                    SelectCommand="Select [includeid], [include] from mt_Includes where group_id = @group_id order by [incl_num], [include]"
                    UpdateCommand="UPDATE mt_include SET [incl_num] = @incl_num WHERE group_id = @group_id and [includeid] = @includeid">
                    <UpdateParameters>
                        <asp:Parameter Name="group_id" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="incl_num" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="includeid" Type="Int32"></asp:Parameter>
                    </UpdateParameters>
                    <SelectParameters>
                        <asp:QueryStringParameter Name="group_id" DbType = "String" Direction = "Input" QueryStringField="group_id" DefaultValue="" ConvertEmptyStringToNull="True" />
                    </SelectParameters>
                </asp:SqlDataSource>
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

        </div>
    </form>
</body>
</html>
