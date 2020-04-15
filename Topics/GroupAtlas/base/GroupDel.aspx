<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    string groupID
    {
        get { return ViewState["groupid"].ToString(); }
        set { ViewState["groupid"] = value; }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            groupID = Request.QueryString["groupid"] + "";
            GroupMaster g = GroupMaster.GetGroupMaster(groupID);
            if (g == null)
                Response.Redirect("GroupList.aspx?msg=Group not found");
            grouptype.Text = g.GroupTypeDesc;
            revtype.Text = g.RevTypeDesc;
            groupid.Text = g.GroupID;
            departdate.Text = g.DepartDate;
            returndate.Text = g.ReturnDate;
            provider.Text = g.ProvName;
            hdr.InnerHtml = "Delete Group# " + groupID;
            save.Attributes["onclick"] = string.Format("javascript:return confirm('Are you sure you wish to delete group# {0}?');", groupID);
            cancel.Attributes["onclick"] = "javascript:window.location.href='GroupList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        try 
        {
            GroupMaster.Delete(groupID);
            Response.Redirect("GroupList.aspx?clear=Y&msg=Group " + groupID + " was successfully deleted.");
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
		    <td class="tdlabel" width="150">Group #:</td>
		    <td><asp:Label id="groupid" runat="server"></asp:Label></td>
	    </tr>
	    <tr>
		    <td class="tdlabel">Provider:</td>
		    <td><asp:Label id="provider" runat="server"></asp:Label></td>
	    </tr>
        <tr>
            <td class="tdlabel">Departure Date:</td>
            <td><asp:Label runat="server" ID="departdate"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel"">Return Date:</td>
            <td><asp:Label runat="server" ID="returndate"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Group Type:</td>
            <td><asp:Label id="grouptype" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Travel Type:</td>
            <td><asp:Label id="revtype" runat="server"></asp:Label></td>
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