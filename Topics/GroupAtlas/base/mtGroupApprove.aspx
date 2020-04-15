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
            packagetype.Text = g.TypeDescription;
            donotdisplay.Text = (g.DoNotDisplay) ? "Yes" : "No";
            template.Text = g.TemplateTitle;
            specialtygroup.Text = (g.SpecialtyGroup) ? "Yes" : "No";
            heading.Text = g.Heading;
            save.Attributes["onclick"] = string.Format("javascript:return confirm('Are you sure you wish to approve group# {0}?');", groupCode);
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtGroupList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        mtGroup g = mtGroup.GetGroup(groupCode);
        if (g.Status == "Approved" || g.Status == "Rejected")
        {
            message.InnerHtml = "Group was already approved or rejected";
            return;
        }
        try 
        {
            mtGroup.Approve(groupCode);
            Response.Redirect("mtGroupList.aspx?msg=Group " + groupCode + " was approved");
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
			<td class="hdr" id="hdr" valign="top">Approve Group# <%=groupCode%></td>
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
        <tr><td>&nbsp;</td></tr>
	</table>
	<table cellspacing="1" cellpadding="3" border="0">
        <tr>
            <td class="tdlabel" width="150">Pckage Type:</td>
            <td><asp:Label ID="packagetype" runat="server" /></td>
        </tr>
	    <tr>
		    <td class="tdlabel">AAA Group #:</td>
		    <td><%=groupCode%></td>
	    </tr>
        <tr>
            <td class="tdlabel">Template:</td>
		    <td><asp:Label id="template" runat="server" /></td>
        </tr>
        <tr>
            <td class="tdlabel">Heading:</td>
		    <td><asp:Label id="heading" runat="server" /></td>
        </tr>
        <tr>
            <td class="tdlabel">Do Not Display:</td>
		    <td><asp:Label id="donotdisplay" runat="server" /></td>
        </tr>
        <tr>
            <td class="tdlabel">Speciality Group:</td>
		    <td><asp:Label id="specialtygroup" runat="server" /></td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="    Approve    " OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>
</asp:Content> 