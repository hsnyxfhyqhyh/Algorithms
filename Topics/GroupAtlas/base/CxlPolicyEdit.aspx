<%@ Page Language="C#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    
    int policyid
    {
        get { return Convert.ToInt32(ViewState["policyid"]); }
        set { ViewState["policyid"] = value.ToString(); }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            message.InnerHtml = Request.QueryString["msg"];
            policyid = Util.parseInt(Request.QueryString["policyid"]);
            CxlPolicy p = CxlPolicy.GetPolicy(policyid, 5);
            policyname.Text = p.policyName;
            Lookup.FillDropDown(provider, PickList.GetProvider2(), p.provider, " ");
            policylist.DataSource = p.policyList;
            policylist.DataBind();
            cancel.Attributes["onclick"] = "javascript:window.location.href='CxlPolicyList.aspx';return false;";
        }
    }

    protected void save_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        List<CxlPolicyDet> list = new List<CxlPolicyDet>();
        string itmMsg = "";
        int cnt = 0;
        foreach (RepeaterItem itm in policylist.Items)
        {
            int dtlid = Convert.ToInt32(((HiddenField)itm.FindControl("dtlid")).Value);
            string rngStart = ((TextBox)itm.FindControl("rngstart")).Text;
            string rngEnd = ((TextBox)itm.FindControl("rngend")).Text;
            string valType = ((DropDownList)itm.FindControl("valtype")).SelectedValue;
            string cxlPolicy = ((TextBox)itm.FindControl("cxlpolicy")).Text;
            list.Add(new CxlPolicyDet(dtlid, cxlPolicy, valType, Util.parseInt(rngStart), Util.parseInt(rngEnd)));
            cnt++;
            if (!((rngStart == "" && rngEnd == "" && valType == "" && cxlPolicy == "") || (rngStart != "" && rngEnd != "" && valType != "" && cxlPolicy != "")))
                itmMsg += string.Format("Line #{0} is incomplete<br>", cnt);
        }
        if (itmMsg != "")
        {
            message.InnerHtml = itmMsg;
            return;
        }
        CxlPolicy p = CxlPolicy.GetPolicy(policyid);
        p.provider = provider.SelectedValue;
        p.policyName = policyname.Text;
        p.policyList = list;
        CxlPolicy.Update(p);
        Response.Redirect("CxlPolicyEdit.aspx?policyid=" + p.policyID + "&msg=Cancellation policy was updated");
    }

    protected void policylist_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            DropDownList dropdown = (DropDownList) e.Item.FindControl("valtype");
            TextBox rngStart = (TextBox)e.Item.FindControl("rngstart");
            TextBox rngEnd = (TextBox)e.Item.FindControl("rngend");
            CxlPolicyDet d = (CxlPolicyDet)e.Item.DataItem;
            if (dropdown != null)
            {
                if (dropdown.Items.FindByValue(d.valType) != null)
                    dropdown.SelectedValue = d.valType;
            }
            if (d.cxlPolicy == "" && d.valType == "")
            {
                if (d.rngStart == 0)
                    rngStart.Text = "";
                if (d.rngEnd == 0)
                    rngEnd.Text = "";
            }
        }
    }
</script>  

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Cancellation Policy</td>
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
    
   <table cellspacing="0" cellpadding="0" border="0">
        <tr>
            <td>
                <table cellpadding="2" cellspacing="0" border="0">
                <tr>
                    <td width="100" class="tdlabel">Provider: </td>                
                    <td><asp:DropDownList ID="provider" runat="server" Width="350px" ></asp:DropDownList>
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="provider" ErrorMessage="Provider is required">*</asp:requiredfieldvalidator>
                    </td>
                </tr>                
                <tr>
                    <td class="tdlabel">Policy Name: </td>                
                    <td><asp:TextBox ID="policyname" runat="server" Width="350px" ></asp:TextBox>
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="policyname" ErrorMessage="Policy name is required">*</asp:requiredfieldvalidator>                    
                    </td>
                </tr>                
                </table>
            </td>
        </tr>
        <tr>
           <td>
                <asp:Repeater ID="policylist" runat="server" onitemdatabound="policylist_ItemDataBound">
                    <HeaderTemplate>
                        <table cellpadding="1" cellspacing="0" border="0">
                            <tr>
                                <td colspan="2" align="center"><b>Days Out</b></td>
                                <td>&nbsp;</td>
                                <td colspan="2" align="center"><b></b></td>
                            </tr>
                            <tr>
                                <td align="center" width="75"><b>From</b></td>
                                <td align="center" width="75"><b>To</b></td>
                                <td width="35">&nbsp;</td>
                                <td width="200"><b>Type</b></td>
                                <td><b>Policy</b></td>
                            </tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:HiddenField ID="dtlid" runat="server" Value='<%# Eval("dtlid") %>' />
                        <tr valign="top">
                            <td align="center">
                                <asp:TextBox ID="rngstart" runat="server" Width="50px" Text='<%# Bind("rngstart") %>' />
                                <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="rngstart" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Days Out (From) is invalid" Type="Integer">*</asp:CompareValidator>                            
                            </td>                                        
                            <td align="center">
                                <asp:TextBox ID="rngend" runat="server" Width="50px" Text='<%# Bind("rngend") %>' />
                                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="rngend" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Days Out (To) is invalid" Type="Integer">*</asp:CompareValidator>                            
                            </td>                                        
                            <td>&nbsp;</td>
                            <td>
                                <asp:DropDownList ID="valtype" runat="server" Width="150px" >
                                    <asp:ListItem Value=""></asp:ListItem>
                                    <asp:ListItem Value="d">Deposit</asp:ListItem>
                                    <asp:ListItem Value="r">Percent</asp:ListItem>
                                    <asp:ListItem Value="v">Dollar Value</asp:ListItem>
                                    <asp:ListItem Value="m">Free Form</asp:ListItem>
                                </asp:DropDownList></td>
                            <td><asp:TextBox ID="cxlpolicy" runat="server" Width="150px" Text='<%# Bind("cxlpolicy") %>' /></td>                                        
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
        </tr>
        <tr>
            <td align="center"><br />
                <asp:Button ID="save" runat="server" Text="   Save   " OnClick="save_Click"></asp:Button>&nbsp;&nbsp;
                <asp:Button ID="cancel" runat="server" Text="Cancel" CausesValidation="False"></asp:Button>
            </td>
        </tr>
    </table>
</asp:Content> 