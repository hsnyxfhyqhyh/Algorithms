<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    
    int regioncode
    {
        get { return Util.parseInt(ViewState["regioncode"]); }
        set { ViewState["regioncode"] = value.ToString(); }
    }

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            regioncode = Util.parseInt(Request.QueryString["regioncode"]);
            message.InnerHtml = Request.QueryString["msg"];
            if (regioncode > 0)
            {
                mtRegion r = mtRegion.GetRegion(regioncode);
                if (r == null)
                    Response.Redirect("mtRegionList.aspx?msg=Region not found");
                hdr.InnerHtml = "Edit Region";
                regiondescription.Text = r.regionDescription;
            }
            else
            {
                hdr.InnerHtml = "Add Region";
            }
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtRegionList.aspx';return false;";
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtRegion r = new mtRegion();
            if (regioncode > 0)
                r = mtRegion.GetRegion(regioncode);
            r.regionDescription = regiondescription.Text;
            mtRegion.Update(r);
            msg = "\"" + regiondescription.Text + "\" was updated.";
            Response.Redirect("mtRegionList.aspx?msg=" + msg);
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Region</td>
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
			<td class="tdlabel" width="150">Region Name:</td>
			<td><asp:textbox id="regiondescription" runat="server" Width="300"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="regiondescription" ErrorMessage="Region name is required">*</asp:requiredfieldvalidator>
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