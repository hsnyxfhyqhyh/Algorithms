<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int optionid
    {
        get { return Convert.ToInt32(ViewState["optionid"]); }
        set { ViewState["optionid"] = value.ToString(); }
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
            optionid = Util.parseInt(Request.QueryString["optionid"]);
            message.InnerHtml = Request.QueryString["msg"];
            string sOptionType = "";
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (optionid > 0)
            {
                GroupOption o = GroupOption.GetOption(optionid, groupid);
                if (o == null)
                    Response.Redirect(string.Format("GroupView.aspx?groupid={0}&tabindex=6", groupid));
                sOptionType = o.optionType;
                optioncd.Text = o.optionCode;
                optionType.Text = o.optionType;
                optionname.Text = o.optionName;

                singlerate.Text = o.singlerate.ToString("#0.00");
                doublerate.Text = o.doublerate.ToString("#0.00");
                triplerate.Text = o.triplerate.ToString("#0.00");
                quadrate.Text = o.quadrate.ToString("#0.00");
                singlecomm.Text = o.singlecommission.ToString("#0.00");
                doublecomm.Text = o.doublecommission.ToString("#0.00");
                triplecomm.Text = o.triplecommission.ToString("#0.00");
                quadcomm.Text = o.quadcommission.ToString("#0.00");
                quantity.Text = o.quantity.ToString();
                allocated.Text = o.allocated.ToString();
                isrequired.Checked = o.isRequired;

                hdr.InnerHtml = string.Format("Group # {0} - Edit Option With Inventory Control", groupid);
            }
            else
            {
                hdr.InnerHtml = string.Format("Group # {0} - Add Option With Inventory Control", groupid);
            }

            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupView.aspx?groupid={0}&tabindex=6';return false;", groupid);
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        GroupOption o = null;

        if (optionid > 0)
        {
            //existing option
            o = GroupOption.GetOption(optionid, groupid);
        } else
        {
            //new option
            o = new GroupOption(0, "", "", 0, false, "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        }

        if (o == null)
        {
            Response.Redirect(string.Format("GroupView.aspx?groupid={0}&tabindex=6", groupid));
        }

        o.optionCode= optioncd.Text;
        o.optionName = optionname.Text;
        o.optionType = optionType.Text;

        o.singlerate = ConvDec(singlerate.Text);
        o.doublerate = ConvDec(doublerate.Text);
        o.triplerate = ConvDec(triplerate.Text);
        o.quadrate = ConvDec(quadrate.Text);
        o.singlecommission = ConvDec(singlecomm.Text);
        o.doublecommission = ConvDec(doublecomm.Text);
        o.triplecommission = ConvDec(triplecomm.Text);
        o.quadcommission = ConvDec(quadcomm.Text);
        o.isRequired = isrequired.Checked;
        o.quantity = ConvInt(quantity.Text);
        o.allocated = ConvInt(allocated.Text);


        try
        {
            GroupOption.Update(groupid, o);

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
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Option Inventory</td>
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
            <td width="150" class="tdlabel">Option Type:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="optionType" runat="server" Width="50"  MaxLength="5"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="optionType" ErrorMessage="Option type is required">*</asp:requiredfieldvalidator>
            </td>              
            <td class="required">* Required Fields</td>
        </tr>
        <tr>
            <td class="tdlabel">Option Code:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="optioncd" runat="server" Width="50"  MaxLength="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="optioncd" ErrorMessage="Package code is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Option Name:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="optionname" runat="server" Width="300"  MaxLength="100"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator7" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="optionname" ErrorMessage="Package name is required">*</asp:requiredfieldvalidator>
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
        <tr>
            <td class="tdlabel">Triple Commission:</td>
            <td><asp:TextBox ID="triplecomm" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator4" runat="server" ControlToValidate="triplecomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Triple comm is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Quad Commission:</td>
            <td><asp:TextBox ID="quadcomm" runat="server" Width="100px"></asp:TextBox>
                <asp:CompareValidator ID="CompareValidator5" runat="server" ControlToValidate="quadcomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Quad comm is invalid" Type="Currency">*</asp:CompareValidator>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td class="tdlabel">Is Required</td>
            <td><asp:CheckBox ID="isrequired" runat="server" />
            </td>
            </tr>
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