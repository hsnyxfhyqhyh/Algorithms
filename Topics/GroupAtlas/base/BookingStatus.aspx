<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int bookingid
    {
        get { return Convert.ToInt32(ViewState["bookingid"]); }
        set { ViewState["bookingid"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            bookingid = Util.parseInt(Request.QueryString["bookingid"]);
            GroupBooking b = GroupBooking.GetBooking(bookingid);
            GroupMaster g = GroupMaster.GetGroupMaster(b.groupID);
            if (b == null || g == null)
                Response.Redirect("BookingView.aspx?bookingid="+bookingid);
            message.InnerHtml = Request.QueryString["msg"];
            Lookup.FillDropDown(agentflexid, PickList.GetTravelAgent(b.agentFlexID), b.agentFlexID.ToString(), " ");
            Lookup.FillDropDown(status, PickList.GetBookingStatus(), b.status, "");
            //
            hdr.InnerHtml = string.Format("Update Status for Booking ID: {0}", bookingid);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}';return false;", bookingid);
        }
    }

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        //                
        try
        {
            GroupBooking.UpdateStatus(bookingid, Util.parseInt(agentflexid.SelectedValue), status.SelectedValue);
            msg = HttpUtility.UrlEncode("Status was successfully updated.");
            Response.Redirect("BookingView.aspx?bookingid=" + bookingid + "&msg=" + msg);
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Booking</td>
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
        <td class="tdlabel" width="150">Agent:</td>
        <td><asp:DropDownList runat="server" ID="agentflexid" Width="300px" /></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td class="tdlabel">Status:</td>
        <td><asp:DropDownList runat="server" ID="status" Width="150px" /></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
	<tr>
		<td colspan="5" align="center">
			<asp:button id="save" runat="server" Text=" Save " OnClick="Save_Click" CssClass="button" Width="75px"></asp:button>&nbsp;&nbsp;
			<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False" Width="75px"></asp:button>
		</td>
	</tr>
	</table>

</asp:Content> 