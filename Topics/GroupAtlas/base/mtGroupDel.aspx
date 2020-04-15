<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    string groupCode
    {
        get { return ViewState["groupcode"].ToString(); }
        set { ViewState["groupcode"] = value; }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            groupCode = Request.QueryString["groupcode"] + "";
            mtGroup g = mtGroup.GetGroup(groupCode);
            if (g == null)
                Response.Redirect("mtGroupList.aspx?msg=Group Flyer not found");
            heading.Text = g.Heading;
            packagetype.Text = g.TypeDescription;
            groupcode.Text = g.GroupCode;
            template.Text = g.TemplateTitle;
            hdr.InnerHtml = "Delete Flyer with Group# " + groupCode;
            save.Attributes["onclick"] = string.Format("javascript:return confirm('Are you sure you wish to delete group# {0}?');", groupCode);
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtGroupList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        try 
        {
            mtGroup.Delete(groupCode);
            Response.Redirect("mtGroupList.aspx?clear=Y&msg=Group " + groupCode + " was successfully deleted.");
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
			<td runat="server" class="hdr" id="hdr" valign="top">Delete Group</td>
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
		    <td class="tdlabel" width="150">AAA Group #:</td>
		    <td><asp:Label id="groupcode" runat="server"></asp:Label></td>
	    </tr>
        <tr>
            <td class="tdlabel">Heading:</td>
            <td><asp:Label runat="server" ID="heading"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel"">Package Type:</td>
            <td><asp:Label runat="server" ID="packagetype"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Template:</td>
            <td><asp:Label id="template" runat="server"></asp:Label></td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text=" Delete " Width="75px" OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 