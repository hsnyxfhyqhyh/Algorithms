<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            groupcode.Text = Request.QueryString["groupcode"] + "";
            string sPackageType = Request.QueryString["packagetype"] + "";
            Lookup.FillDropDown(packagetype, mtPickList.GetPackageType(), sPackageType, " ");
            Lookup.FillDropDown(template, mtPickList.GetTemplate(), "", " ");
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtGroupList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        mtGroup g = mtGroup.GetGroup(groupcode.Text);
        if (g != null)
        {
            message.InnerHtml = string.Format("Group # {0} already exist. <a href=\"mtGroupEdit.aspx?groupcode={0}\">Click here to view</a>", groupcode.Text);
            return;
        }
        try 
        {
            mtGroup.Add(groupcode.Text, packagetype.SelectedValue, template.SelectedValue);
            Response.Redirect("mtGroupEdit.aspx?groupcode=" + groupcode.Text);
        }
        catch (ApplicationException ex)
        {
            message.InnerHtml = ex.Message;
        }
	}
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" valign="top">Add a Group Flyer</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0">
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span>
				<br>
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:"
					CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
        <tr><td>&nbsp;</td></tr>
	</table>
	<table cellspacing="1" cellpadding="3" border="0">
        <tr>
            <td class="tdlabel" width="150">Package Type:</td>
            <td>
                <asp:DropDownList runat="server" ID="packagetype" Width="250px" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packagetype" ErrorMessage="Package type is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>
	    <tr>
		    <td class="tdlabel">AAA Group #:</td>
		    <td><asp:textbox id="groupcode" runat="server" Width="100"  MaxLength="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="groupcode" ErrorMessage="Group code is required">*</asp:requiredfieldvalidator>
            </td>
	    </tr>
        <tr>
            <td class="tdlabel">Template:</td>
            <td>
                <asp:DropDownList runat="server" ID="template" Width="250px" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="template" ErrorMessage="Template is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="Save & Continue >" OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 