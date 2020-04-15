<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    string groupid
    {
        get { return ViewState["groupid"].ToString(); }
        set { ViewState["groupid"] = value; }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            groupid = Request.QueryString["groupid"] + "";
            message.InnerHtml = Request.QueryString["msg"];
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (g == null)
                Response.Redirect(string.Format("GroupView.aspx?groupid={0}&tabindex=6", groupid));
            isselloveralloc.Checked = g.IsSellOverAlloc;
            maxpassengers.Text = g.MaxPassengers.ToString();
            minpassengers.Text = g.MinPassengers.ToString();
            hdr.InnerHtml = string.Format("Group # {0} - Edit Group Inventory", groupid);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupView.aspx?groupid={0}&tabindex=6';return false;", groupid);
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            GroupMaster.UpdateInv(groupid, isselloveralloc.Checked, ConvInt(maxpassengers.Text), ConvInt(minpassengers.Text));
            msg = HttpUtility.UrlEncode("Group #" + groupid + " was updated.");
            Response.Redirect("GroupView.aspx?groupid=" + groupid + "&tabindex=6&msg=" + msg);
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

    int ConvInt(string num)
    {
        return (num.Trim() == "") ? 0 : Convert.ToInt32(num);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Group Inventory</td>
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
            <td width="200" class="tdlabel">Sell Over Allocated Inventory:</td>
            <td><asp:CheckBox ID="isselloveralloc" runat="server" /></td>
        </tr>
        <tr>
            <td class="tdlabel">Minimum Passengers:</td>
            <td><asp:TextBox ID="minpassengers" runat="server" Width="75px"></asp:TextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="minpassengers" ErrorMessage="Min Passengers is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="minpassengers" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Min Passengers is invalid" Type="Integer">*</asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Maximum Passengers:</td>
            <td><asp:TextBox ID="maxpassengers" runat="server" Width="75px"></asp:TextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="maxpassengers" ErrorMessage="Max Passengers is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator30" runat="server" ControlToValidate="maxpassengers" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Max Passengers is invalid" Type="Integer">*</asp:CompareValidator>
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