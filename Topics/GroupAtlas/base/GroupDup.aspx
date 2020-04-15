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
            provider.Text = g.ProvName;
            hdr.InnerHtml = "Duplicate Group# " + groupID;
            save.Attributes["onclick"] = string.Format("javascript:return confirm('Are you sure you wish to duplicate group# {0}?');", groupID);
            cancel.Attributes["onclick"] = "javascript:window.location.href='GroupList.aspx';return false;";
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        try
        {
            string sprovidergroupid = providergroupid.Text;
            //string newGroupID = GroupMaster.Duplicate(groupID, Convert.ToDateTime(newdepartdate.Text));
            string newGroupID = GroupMaster.Duplicate(groupID, Convert.ToDateTime(newdepartdate.SelectedDate), sprovidergroupid);

            string msg = string.Format("New Group {0} was sucessfully duplicated from Original Group {1}", newGroupID, groupID);
            Response.Redirect("GroupView.aspx?groupid=" + newGroupID + "&msg=" + msg);
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
		    <td class="tdlabel" width="150">Group to Duplicate:</td>
		    <td><asp:Label id="groupid" runat="server"></asp:Label></td>
	    </tr>
	    <tr>
		    <td class="tdlabel">Provider:</td>
		    <td><asp:Label id="provider" runat="server"></asp:Label></td>
	    </tr>
        <tr>
            <td class="tdlabel">Group Type:</td>
            <td><asp:Label id="grouptype" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Travel Type:</td>
            <td><asp:Label id="revtype" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Original Departure Date:</td>
            <td><asp:Label runat="server" ID="departdate"></asp:Label></td>
        </tr>
	    <tr>
		    <td class="tdlabel">New Departure Date:</td>
		    <td>
                <telerik:RadDatePicker ID="newdepartdate" runat="server" MinDate="1901-01-01" Width="120px">
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
                <%--<asp:textbox id="newdepartdate" runat="server" Width="100"  MaxLength="12"></asp:textbox>
                <a onclick="setLastPos(event)" href="javascript:calendar('<%=newdepartdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="newdepartdate" ErrorMessage="New Departure date is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="newdepartdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="New Departure date is invalid" Type="Date">*</asp:CompareValidator>
            </td>
	    </tr>
        <tr>
			<td class="tdlabel">Vendor Group #:&nbsp;<span class="required"></span></td>
			<td><asp:textbox id="providergroupid" runat="server" Width="150"  MaxLength="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="providergroupid" ErrorMessage="Vendor Group # is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text=" Duplicate " Width="75px" OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 