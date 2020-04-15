<%@ Page Title="" Language="C#" MasterPageFile="~/Setup.master" AutoEventWireup="true" CodeFile="QuestionSort.aspx.cs" Inherits="QuestionSort" %>
<%@ Import Namespace="GM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">
   <table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Sort Questions</td>
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
                    Height="350px" Width="450px" 
                    DataTextField="QuestionName" 
                    DataValueField="QuestionID" 
                    DataSortField="QuestionSort"
                    DataSourceID="SqlDataSource1"
                    OnClientSelectedIndexChanged="OnClientSelectedIndexChanged"
                    SelectionMode="Single">
                </telerik:RadListBox>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:ConnectionString %>" 
                    SelectCommand="Select [QuestionID], [QuestionName] from grp_Question order by [QuestionSort], [QuestionName]"
                    UpdateCommand="UPDATE grp_Question SET [QuestionSort] = @QuestionSort WHERE [QuestionID] = @QuestionID">
                    <UpdateParameters>
                        <asp:Parameter Name="QuestionSort" Type="Int32"></asp:Parameter>
                        <asp:Parameter Name="QuestionID" Type="Int32"></asp:Parameter>
                    </UpdateParameters>
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
 

</asp:Content>

