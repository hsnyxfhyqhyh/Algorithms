<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int packageid
    {
        get { return Convert.ToInt32(ViewState["packageid"]); }
        set { ViewState["packageid"] = value.ToString(); }
    }

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
            packageid = Util.parseInt(Request.QueryString["packageid"]);
            message.InnerHtml = Request.QueryString["msg"];
            string sPackageType = "";
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (packageid > 0)
            {
                GroupPackage p = GroupPackage.GetPackage(packageid, groupid);
                if (p == null)
                    Response.Redirect(string.Format("GroupView.aspx?groupid={0}&tabindex=6", groupid));
                packagecd.Text = p.packageCd;
                packagename.Text = p.packageName;
                singlerate.Text = p.singleRate.ToString("#0.00");
                doublerate.Text = p.doubleRate.ToString("#0.00");
                triplerate.Text = p.tripleRate.ToString("#0.00");
                quadrate.Text = p.quadRate.ToString("#0.00");
                singlecomm.Text = p.singleComm.ToString("#0.00");
                doublecomm.Text = p.doubleComm.ToString("#0.00");
                quantity.Text = p.quantity.ToString();
                allocated.Text = p.allocated.ToString();
                sPackageType = p.packageType;
                hdr.InnerHtml = string.Format("Group # {0} - Edit Package", groupid);
            }
            else
            {
                hdr.InnerHtml = string.Format("Group # {0} - Add Package", groupid);
            }
            Lookup.FillDropDown(packagetype, PickList.GetPackageType(g.RevType), sPackageType, " ");
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupView.aspx?groupid={0}&tabindex=6';return false;", groupid);
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";
        GroupPackage p = new GroupPackage();
        p.groupID = groupid;
        if (packageid > 0)
            p = GroupPackage.GetPackage(packageid, groupid);
        p.packageCd = packagecd.Text;
        p.packageName = packagename.Text;
        p.singleRate = ConvDec(singlerate.Text);
        p.doubleRate = ConvDec(doublerate.Text);
        p.tripleRate = ConvDec(triplerate.Text);
        p.quadRate = ConvDec(quadrate.Text);
        p.singleComm = ConvDec(singlecomm.Text);
        p.doubleComm = ConvDec(doublecomm.Text);
        p.quantity = ConvInt(quantity.Text);
        p.allocated = ConvInt(allocated.Text);
        p.packageType = packagetype.SelectedValue;
        try
        {
            if (packageid > 0)
                GroupPackage.Update(p);
            else
                GroupPackage.Add(p);
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

    <style type="text/css">
        .numr
        {
            text-align: right;
        }
    </style>

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Package</td>
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
            <td width="150" class="tdlabel">Package Type:&nbsp;<span class="required">*</span></td>
            <td>
				<asp:DropDownList Runat="server" Width="150px" ID="packagetype" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packagetype" ErrorMessage="Package type is required">*</asp:requiredfieldvalidator>
            </td>                
            <td class="required">* Required Fields</td>
        </tr>
        <tr>
            <td class="tdlabel">Package Code:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="packagecd" runat="server" Width="50"  MaxLength="3"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packagecd" ErrorMessage="Package code is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Package Name:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="packagename" runat="server" Width="300"  MaxLength="100"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator7" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packagename" ErrorMessage="Package name is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td class="tdlabel">Single Rate:</td>
            <td><asp:TextBox ID="singlerate" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator29" runat="server" ControlToValidate="singlerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Single rate is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Double Rate:&nbsp;<span class="required"></span></td>
            <td><asp:TextBox ID="doublerate" runat="server" Width="100px"></asp:TextBox>
                <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="doublerate" ErrorMessage="Double rate is required">*</asp:requiredfieldvalidator>--%>
                <asp:CompareValidator ID="CompareValidator30" runat="server" ControlToValidate="doublerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Double rate is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Triple Rate:</td>
            <td><asp:TextBox ID="triplerate" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator31" runat="server" ControlToValidate="triplerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Triple rate is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Quad Rate:</td>
            <td><asp:TextBox ID="quadrate" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator32" runat="server" ControlToValidate="quadrate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Quad rate is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td class="tdlabel">Single Commission:</td>
            <td><asp:TextBox ID="singlecomm" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="singlecomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Single comm is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
            </tr>
        <tr>
            <td class="tdlabel">Double Commission:</td>
            <td><asp:TextBox ID="doublecomm" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="doublecomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Double comm is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td class="tdlabel">Inventory Quantity:</td>
            <td><asp:TextBox ID="quantity" runat="server" Width="50px" MaxLength="5"></asp:TextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="quantity" ErrorMessage="Quantity is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator24" runat="server" ControlToValidate="quantity" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Quantity is invalid" Type="Integer">*</asp:CompareValidator>
            </td>
            </tr>
        <tr>
            <td class="tdlabel">Inventory Allocated:</td>
            <td><asp:TextBox ID="allocated" runat="server" Width="50px" MaxLength="5"></asp:TextBox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="quantity" ErrorMessage="Allocated quantity is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator3" runat="server" ControlToValidate="allocated" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Allocated quantity is invalid" Type="Integer">*</asp:CompareValidator>
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