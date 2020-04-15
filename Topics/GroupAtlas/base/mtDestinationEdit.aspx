<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    int destinationcode
    {
        get { return Util.parseInt(ViewState["destinationcode"]); }
        set { ViewState["destinationcode"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            destinationcode = Util.parseInt(Request.QueryString["destinationcode"]);
            message.InnerHtml = Request.QueryString["msg"];
            if (destinationcode > 0)
            {
                mtDestination d = mtDestination.GetDestination(destinationcode);
                if (d == null)
                    Response.Redirect("mtDestinationList.aspx?msg=Destination not found");
                hdr.InnerHtml = "Edit Destination";
                destinationdescription.Text = d.destinationDescription;
            }
            else
            {
                hdr.InnerHtml = "Add Destination";
            }
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtDestinationList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtDestination d = new mtDestination();
            if (destinationcode > 0)
                d = mtDestination.GetDestination(destinationcode);
            d.destinationDescription = destinationdescription.Text;
            mtDestination.Update(d);
            msg = "\"" + destinationdescription.Text + "\" was updated.";
            Response.Redirect("mtDestinationList.aspx?msg=" + msg);
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Destination</td>
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
			<td class="tdlabel" width="150">Destination Name:</td>
			<td><asp:textbox id="destinationdescription" runat="server" Width="300"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="destinationdescription" ErrorMessage="Destination name is required">*</asp:requiredfieldvalidator>
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