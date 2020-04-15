<%@ Page language="c#" MasterPageFile="Reports.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            cancel.Attributes["onclick"] = "javascript:window.location.href='Reports.aspx';return false;";
        }
	}

	void Submit_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        mtDownload.ExportGroupInfo(dltype.SelectedValue);
	}
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="reportContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Download Group Info</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span>
				<br>
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:"
					CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
	<table cellspacing="1" cellpadding="3" border="0">
        <tr valign="top">
            <td class="tdlabel" width="150">Package Type:</td>
            <td>
                <asp:RadioButtonList runat="server" ID="dltype">
                    <asp:ListItem Value="ATI">Download ATI Groups</asp:ListItem>
                    <asp:ListItem Value="CRU">Download Cruise Groups</asp:ListItem>
                    <asp:ListItem Value="CTG">Download Cruise/Tour Groups</asp:ListItem>
                    <asp:ListItem Value="TGD">Download TGD Groups</asp:ListItem>
                </asp:RadioButtonList> 
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="dltype" ErrorMessage="Download Type is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>

        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="  Submit  " OnClick="Submit_Click" CssClass="button"></asp:button>&nbsp;&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 