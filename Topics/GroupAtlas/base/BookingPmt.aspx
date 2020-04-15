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
            if (b == null)
                Response.Redirect("BookingView.aspx?bookingid="+bookingid);
            message.InnerHtml = Request.QueryString["msg"];
            // 
            Lookup.FillDropDown(pmttype, PickList.GetPickList("PMTTYPE"), "", " ");
            GroupMaster g = GroupMaster.GetGroupMaster(b.groupID);
            pmtdate.Text = DateTime.Today.ToShortDateString();
            group.Text = string.Format("{0} - {1}", b.groupID, g.GroupName);
            Passenger p = GroupBooking.GetPrimPassenger(bookingid);
            if (p != null)
                primpax.Text = p.Name;
            hdr.InnerHtml = string.Format("Booking ID: {0} - Post Payment", bookingid);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}';return false;", bookingid);
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        Payment p = new Payment(0, bookingid, ConvDec(amount.Text), Convert.ToDateTime(pmtdate.Text), pmttype.SelectedValue, "", refnum.Text, payername.Text, "Manual");
        try
        {
            GroupBooking.PostPayment(p);
            msg = HttpUtility.UrlEncode("Payment was successfully posted.");
            Response.Redirect("BookingView.aspx?bookingid=" + bookingid + "&msg=" + msg);
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    decimal ConvDec(string amt)
    {
        return (amt.Trim() == "") ? 0 : Convert.ToDecimal(amt);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

    <style type="text/css">
        .numr
        {
            text-align: right;
        }
    </style>

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Post Payment</td>
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
	<table cellspacing="0" cellpadding="2" border="0">
        <tr>
            <td width="150" class="tdlabel">Booking ID:</td>
            <td><%=bookingid %></td>
            <td class="required">* Required Fields</td>
        </tr>
        <tr>
            <td class="tdlabel">Group #:</td>
            <td><asp:Label ID="group" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Primary Individual:</td>
            <td><asp:Label ID="primpax" runat="server"></asp:Label></td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td width="150" class="tdlabel">Payment Date:&nbsp;<span class="required">*</span></td>
			<td><asp:textbox id="pmtdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=pmtdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="pmtdate" ErrorMessage="Payment date is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator4" runat="server" ControlToValidate="pmtdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Payment date is invalid" Type="Date">*</asp:CompareValidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Payment Type:&nbsp;<span class="required">*</span></td>
            <td><asp:DropDownList runat="server" ID="pmttype" Width="250px" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator5" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="pmttype" ErrorMessage="Payment type is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Paid By:</td>
            <td><asp:textbox id="payername" runat="server" Width="300"  MaxLength="100"></asp:textbox></td>
        </tr>
        <tr>
            <td class="tdlabel">Reference #:</td>
            <td><asp:textbox id="refnum" runat="server" Width="300"  MaxLength="100"></asp:textbox></td>
        </tr>
        <tr>
            <td class="tdlabel">Amount:&nbsp;<span class="required">*</span></td>
            <td><asp:TextBox ID="amount" runat="server" Width="100px"></asp:TextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="amount" ErrorMessage="Amount is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator30" runat="server" ControlToValidate="amount" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Amount is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text=" Save " OnClick="Save_Click" CssClass="button" Width="75px"></asp:button>&nbsp;&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False" Width="75px"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 