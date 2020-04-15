<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    int shipcode
    {
        get { return Util.parseInt(ViewState["shipcode"]); }
        set { ViewState["shipcode"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            shipcode = Util.parseInt(Request.QueryString["shipcode"]);
            message.InnerHtml = Request.QueryString["msg"];
            string sVendorCode = "";
            if (shipcode > 0)
            {
                mtShip s = mtShip.GetShip(shipcode);
                if (s == null)
                    Response.Redirect("mtShipList.aspx?msg=Ship not found");
                hdr.InnerHtml = "Edit Ship";
                shipname.Text = s.shipName;
                sVendorCode = s.vendorCode;
            }
            else
            {
                hdr.InnerHtml = "Add Ship";
            }
            Lookup.FillDropDown(vendorcode, mtPickList.GetVendor(), sVendorCode, " ");
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtShipList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtShip s = new mtShip();
            if (shipcode > 0)
                s = mtShip.GetShip(shipcode);
            s.shipName = shipname.Text;
            s.vendorCode = vendorcode.SelectedValue;
            mtShip.Update(s);
            msg = "\"" + shipname.Text + "\" was updated.";
            Response.Redirect("mtShipList.aspx?msg=" + msg);
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
			<td><asp:textbox id="shipname" runat="server" Width="300"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="shipname" ErrorMessage="Ship name is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Vendor:</td>
            <td>
                <asp:DropDownList runat="server" ID="vendorcode" Width="300px" />
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