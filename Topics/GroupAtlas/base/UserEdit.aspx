<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            string sNTLogon = Request.QueryString["ntlogon"]+"";
            message.InnerHtml = Request.QueryString["msg"];
            string sSecLevel = "";
            if (sNTLogon != "")
            {
                SecurityDet s = Security.Get(sNTLogon);
                if (s == null)
                    Response.Redirect("UserList.aspx?msg=User not found");
                hdr.InnerHtml = "Edit User";
                ntlogon.Text = s.ntLogon;
                sSecLevel = s.secLevel.ToString();
                if (s.groupID_allow == null) s.groupID_allow = "";
                if (s.groupID_allow2 == null) s.groupID_allow2 = "";
                if (s.groupID_allow3 == null) s.groupID_allow3 = "";
                if (s.groupID_allow4 == null) s.groupID_allow4 = "";
                if (s.groupID_allow5 == null) s.groupID_allow5 = "";
                AllowedGroupID.Text = s.groupID_allow.ToString();
                AllowedGroupID2.Text = s.groupID_allow2.ToString();
                AllowedGroupID3.Text = s.groupID_allow3.ToString();
                AllowedGroupID4.Text = s.groupID_allow4.ToString();
                AllowedGroupID5.Text = s.groupID_allow5.ToString();
                ntlogon.Enabled = false;
            }
            else
            {
                hdr.InnerHtml = "New User";
            }
            Lookup.FillDropDown(seclevel, PickList.GetSecLevels(), sSecLevel, " ");
            cancel.Attributes["onclick"] = "javascript:window.location.href='UserList.aspx';return false;";
        }
        string val = seclevel.SelectedValue.ToString();
        if (val == "4")
        {
            trAllowedGroupID.Visible = true;
        }
        else
        {
            trAllowedGroupID.Visible = false;
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            SecurityDet s = new SecurityDet();
            s.ntLogon = ntlogon.Text;
            s.secLevel = Util.parseInt(seclevel.Text);
            if (s.secLevel == 4)
            {
                s.groupID_allow = AllowedGroupID.Text;
                s.groupID_allow2 = AllowedGroupID2.Text;
                s.groupID_allow3 = AllowedGroupID3.Text;
                s.groupID_allow4 = AllowedGroupID4.Text;
                s.groupID_allow5 = AllowedGroupID5.Text;
            }
            else
            {
                s.groupID_allow = "";
                s.groupID_allow2 = "";
                s.groupID_allow3 = "";
                s.groupID_allow4 = "";
                s.groupID_allow5 = "";
            }
            Security.Update(s);
            msg = "\"" + ntlogon.Text + "\" was updated.";
            Response.Redirect("UserList.aspx?msg=" + msg);
        }
        catch (ApplicationException ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void seclevel_SelectedIndexChanged(object sender, EventArgs e)
    {
        //Control c = (Control)sender;
        //DropDownList ddlSecLevel = c as DropDownList;
        if (seclevel.SelectedItem != null && seclevel.SelectedItem.Value == "4")
        {
            trAllowedGroupID.Visible = true;
        }
        else
        {
            trAllowedGroupID.Visible = false;
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit User</td>
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
			<td class="tdlabel" width="150">NT Logon:</td>
			<td><asp:textbox id="ntlogon" runat="server" Width="100"  MaxLength="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="ntlogon" ErrorMessage="NT Logon is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Security Level:</td>
            <td>
                <asp:DropDownList runat="server" ID="seclevel" Width="300px" AutoPostBack="true" OnSelectedIndexChanged="seclevel_SelectedIndexChanged" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="seclevel" ErrorMessage="Security Level is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>
        <tr id="trAllowedGroupID" runat="server" visible="false">
            <td class="tdlabel">Allowed Group ID:</td>
            <td>
                <asp:textbox runat="server" ID="AllowedGroupID" Width="50" MaxLength="6" BackColor="lightyellow"></asp:textbox>
                <asp:textbox runat="server" ID="AllowedGroupID2" Width="50" MaxLength="6" BackColor="lightyellow"></asp:textbox>
                <asp:textbox runat="server" ID="AllowedGroupID3" Width="50" MaxLength="6" BackColor="lightyellow"></asp:textbox>
                <asp:textbox runat="server" ID="AllowedGroupID4" Width="50" MaxLength="6" BackColor="lightyellow"></asp:textbox>
                <asp:textbox runat="server" ID="AllowedGroupID5" Width="50" MaxLength="6" BackColor="lightyellow"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="AllowedGroupID" ErrorMessage="Group ID is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text=" Save " OnClick="Save_Click" CssClass="button"></asp:button>
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>
   
</asp:Content> 



