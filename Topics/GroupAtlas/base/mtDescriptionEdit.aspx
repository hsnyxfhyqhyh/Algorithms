<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int id
    {
        get { return Util.parseInt(ViewState["id"]); }
        set { ViewState["id"] = value.ToString(); }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            id = Util.parseInt(Request.QueryString["id"]);
            message.InnerHtml = Request.QueryString["msg"];
            if (id > 0)
            {
                mtDescription d = mtDescription.GetDescription(id);
                if (d == null)
                    Response.Redirect("mtDescriptionList.aspx?msg=Description not found");
                hdr.InnerHtml = "Edit Description";
                txttitle.Text = d.title;
                description.Text = HttpUtility.HtmlDecode(d.description);
                rcbxStatus.Checked = d.status;
            }
            else
            {
                hdr.InnerHtml = "Add Description";
            }
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtDescriptionList.aspx';return false;";
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            mtDescription d = new mtDescription();
            if (id > 0)
                d = mtDescription.GetDescription(id);
            d.title = txttitle.Text;
            d.description = description.Text;
            if (rcbxStatus.Checked == true)
            {
                d.status = true;
            }
            else
            {
                d.status = false;
            }
             
            mtDescription.Update(d);
            msg = "\"" + txttitle.Text + "\" was updated.";
            Response.Redirect("mtDescriptionList.aspx?msg=" + msg);
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Description</td>
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
				<br/>
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:"
					CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
	<table cellspacing="1" cellpadding="3" border="0">
		<tr>
			<td class="tdlabel" width="150">Title:</td>
			<td><asp:textbox id="txttitle" runat="server" Width="450"  MaxLength="100"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="txttitle" ErrorMessage="Title is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
		<tr valign="top">
			<td class="tdlabel">Description:</td>
			<td><asp:textbox id="description" runat="server" Width="450"  MaxLength="1000" TextMode="MultiLine" Rows="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="description" ErrorMessage="Description is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr valign="top">
			<td class="tdlabel">Save for future use:</td>
			<td><asp:CheckBox id="rcbxStatus" runat="server"  Visible="true" ForeColor="black"></asp:CheckBox>
               <asp:Label runat="server" ID="lblDescription" Text="Active = checked / Inactive = unchecked" ForeColor="Blue" Font-Italic="true"></asp:Label>
            </td>
		</tr>

        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="  Save  " OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 