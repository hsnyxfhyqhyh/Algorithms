<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    int departurecode
    {
        get { return Util.parseInt(ViewState["departurecode"]); }
        set { ViewState["departurecode"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            departurecode = Util.parseInt(Request.QueryString["departurecode"]);
            message.InnerHtml = Request.QueryString["msg"];
            if (departurecode > 0)
            {
                mtDeparturePoint d = mtDeparturePoint.GetDeparturePoint(departurecode);
                if (d == null)
                    Response.Redirect("mtDeparturePointList.aspx?msg=Departure point not found");
                hdr.InnerHtml = "Edit Departure Point";
                departurepoint.Text = d.departurePoint;
            }
            else
            {
                hdr.InnerHtml = "Add Departure Point";
            }
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtDeparturePointList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtDeparturePoint d = new mtDeparturePoint();
            if (departurecode > 0)
                d = mtDeparturePoint.GetDeparturePoint(departurecode);
            d.departurePoint = departurepoint.Text;
            mtDeparturePoint.Update(d);
            msg = "\"" + departurepoint.Text + "\" was updated.";
            Response.Redirect("mtDeparturePointList.aspx?msg=" + msg);
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Departure Point</td>
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
			<td class="tdlabel" width="150">Departure Point:</td>
			<td><asp:textbox id="departurepoint" runat="server" Width="300"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="departurepoint" ErrorMessage="Departure point is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>

        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="  Save  " OnClick="Save_Click" CssClass="button"></asp:button>
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 