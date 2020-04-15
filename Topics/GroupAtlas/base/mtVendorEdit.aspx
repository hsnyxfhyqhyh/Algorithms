<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {

        if (!IsPostBack)
        {
            string sVendorCd = Request.QueryString["vendorcode"];
            //string sGroupCode = Convert.ToString(Request.QueryString["VGroupCode"]);
            int iRID = Convert.ToInt32(Request.QueryString["RID"]);
            Session["RID"] = iRID;
            message.InnerHtml = Request.QueryString["msg"];
            if (sVendorCd == "")
            {
                Session["New"] = "YES";
                hdr.InnerHtml = "New Vendor";
                vendorcode.Enabled = true;
            }
            else if (sVendorCd != "")
            {
                Session["New"] = "NO";
                vendorcode.Enabled = false;
                mtVendor t = mtVendor.GetVendor(sVendorCd);
                if (t == null)
                    Response.Redirect("mtVendorList.aspx?msg=Vendor not found");
                hdr.InnerHtml = "Edit Vendor";
                vendorcode.Text = t.vendorCode;
                vendorname.Text = t.vendorName;
                phonearea.Text = t.phoneArea;
                phoneprefix.Text = t.phonePrefix;
                phonesuffix.Text = t.phoneSuffix;
                ext.Text = t.ext;
                
            }
           
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtVendorList.aspx';return false;";
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        string Status = Session["New"].ToString();
        try
        {
            mtVendor v = new mtVendor();
            int iReturn = 0;
            v.vendorCode = vendorcode.Text;
            v.vendorName = vendorname.Text;
            v.phoneArea = phonearea.Text;
            v.phonePrefix = phoneprefix.Text;
            v.phoneSuffix = phonesuffix.Text;
            v.ext = ext.Text;
            v.RID = Convert.ToInt32(Session["RID"]);

            if (Status == "YES")
            {
                iReturn = mtVendor.GetVendorVendor(v.vendorCode);
                if (iReturn == 1)
                {
                    message.InnerHtml = "Duplicate entry is not allowed.";
                }
                else
                {
                    mtVendor.Insert(v);
                    msg = "\"" + v.vendorCode + " - " + v.vendorName + "\" was created.";
                    Response.Redirect("mtVendorList.aspx?msg=" + msg);
                }
            }
            else if(Status == "NO")
            {
                //iReturn = mtVendor.GetVendorVendor(v.vendorCode);
                //if (iReturn == 1)
                //{
                //    message.InnerHtml = "Duplicate entry is not allowed.";
                //}
                //else
                //{
                mtVendor.Update(v);
                msg = "\"" + v.vendorCode + " - " + v.vendorName + "\" was updated.";
                Response.Redirect("mtVendorList.aspx?msg=" + msg);
                //}
            }
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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Vendor</td>
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
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:" CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
	<table cellspacing="1" cellpadding="3" border="0">
		<tr>
			<td class="tdlabel" width="150">Vendor Code:</td>
			<td>
                <telerik:RadTextBox id="vendorcode" runat="server" Width="100px" MaxLength="10" BackColor="#ffffcc"></telerik:RadTextBox>
                
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorcode" ErrorMessage="Vendor code is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
		<tr>
			<td class="tdlabel">Vendor Name:</td>
			<td><telerik:RadTextBox id="vendorname" runat="server" Width="300" MaxLength="50" BackColor="#ffffcc"></telerik:RadTextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorname" ErrorMessage="Vendor name is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
		<tr>
			<td class="tdlabel">Phone:</td>
			<td>
                <asp:textbox id="phonearea" runat="server" Width="40"  MaxLength="3"></asp:textbox>&nbsp;-&nbsp;<asp:textbox id="phoneprefix" runat="server" Width="40"  MaxLength="3"></asp:textbox>&nbsp;-&nbsp;<asp:textbox id="phonesuffix" runat="server" Width="50"  MaxLength="4"></asp:textbox>
            </td>
		</tr>
		<tr>
			<td class="tdlabel">Ext:</td>
			<td><asp:textbox id="ext" runat="server" Width="100"  MaxLength="10"></asp:textbox></td>
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