<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            string sVendorGroupCd = Request.QueryString["vendorgroupcode"]+"";
            message.InnerHtml = Request.QueryString["msg"];
            if (sVendorGroupCd != "")
            {
                mtVendorGroup t = mtVendorGroup.GetVendorGroup(sVendorGroupCd);
                if (t == null)
                    Response.Redirect("mtVendorGroupList.aspx?msg=Vendor group code not found");
                hdr.InnerHtml = "Edit Vendor Group Code";
                vendorgroupcode.Text = t.vendorGroupCode;
                vendorgroupcode.Enabled = false;
            }
            else
            {
                hdr.InnerHtml = "New Vendor Group Code";
            }
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtVendorGroupList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtVendorGroup t = new mtVendorGroup();
            t.vendorGroupCode = vendorgroupcode.Text;
            mtVendorGroup.Update(t);
            msg = "\"" + vendorgroupcode.Text + "\" was updated.";
            Response.Redirect("mtVendorGroupList.aspx?msg=" + msg);
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
	}
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Vendor Group Code</td>
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
		<tr>
			<td class="tdlabel" width="150">Vendor Group Code:</td>
			<td><asp:textbox id="vendorgroupcode" runat="server" Width="300"  MaxLength="25"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorgroupcode" ErrorMessage="Vendor group code is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text=" Save " OnClick="Save_Click" CssClass="button"></asp:button>
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 