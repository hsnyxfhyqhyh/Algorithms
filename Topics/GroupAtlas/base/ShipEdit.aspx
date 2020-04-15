<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    int shipid
    {
        get { return Util.parseInt(ViewState["shipid"]); }
        set { ViewState["shipid"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            shipid = Util.parseInt(Request.QueryString["shipid"]);
            message.InnerHtml = Request.QueryString["msg"];
            string sProvider = "";
            string sStatus = "Active";
            if (shipid > 0)
            {
                Ship s = Ship.GetShip(shipid);
                if (s == null)
                    Response.Redirect("ShipList.aspx?msg=Ship not found");
                hdr.InnerHtml = "Edit Ship";
                shipname.Text = s.shipName;
                sProvider = s.provider;
                sStatus = s.status;
            }
            else
            {
                hdr.InnerHtml = "Add Ship";
            }
            Lookup.FillDropDown(provider, PickList.GetProvider(sProvider), sProvider, " ");
            Lookup.FillDropDown(status, PickList.GetStatus(), sStatus, " ");
            cancel.Attributes["onclick"] = "javascript:window.location.href='ShipList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            Ship s = new Ship();
            if (shipid > 0)
                s = Ship.GetShip(shipid);
            s.shipName = shipname.Text;
            s.provider = provider.SelectedValue;
            s.status = status.SelectedValue;
            Ship.Update(s);
            msg = "\"" + shipname.Text + "\" was updated.";
            Response.Redirect("ShipList.aspx?msg=" + msg);
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Ship</td>
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
			<td class="tdlabel" width="150">Ship Name:</td>
			<td><asp:textbox id="shipname" runat="server" Width="300"  MaxLength="100"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="shipname" ErrorMessage="Ship name is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Provider:</td>
            <td>
                <asp:DropDownList runat="server" ID="provider" Width="300px" />
                <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="provider" ErrorMessage="Provider is required">*</asp:requiredfieldvalidator>--%>
		    </td>
        </tr>
        <tr>
            <td class="tdlabel">Status:</td>
            <td>
                <asp:DropDownList runat="server" ID="status" Width="300px" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="status" ErrorMessage="Status is required">*</asp:requiredfieldvalidator>
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