<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

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
            message.InnerHtml = Request.QueryString["msg"];
            optionlist.DataSource = GroupOption.GetOption(groupid, true);
            optionlist.DataBind();
            hdr.InnerHtml = string.Format("Group # {0} - Edit Options", groupid);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupView.aspx?groupid={0}&tabindex=6';return false;", groupid);
        }
	}

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        string msg = "";

        // Validate & Build Option List
        List<GroupOption> list = new List<GroupOption>();
        int cnt = 0;
        foreach (RepeaterItem itm in optionlist.Items)
        {
            int iOptionID = Convert.ToInt32(((HiddenField)itm.FindControl("optionid")).Value);
            string sOptionName = ((TextBox)itm.FindControl("optionname")).Text;
            string sRateType = ((DropDownList)itm.FindControl("ratetype")).SelectedValue;
            decimal dRate = ConvDec(((TextBox)itm.FindControl("rate")).Text);
            bool bIsRequired = ((CheckBox)itm.FindControl("isrequired")).Checked;
            list.Add(new GroupOption(iOptionID, sOptionName, sRateType, dRate, bIsRequired, "OTH"));
            cnt++;
        }
        try
        {
            GroupOption.Update(groupid, list);
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

    protected void optionlist_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            TextBox rate = (TextBox)e.Item.FindControl("rate");
            TextBox optionname = (TextBox)e.Item.FindControl("optionname");
            GroupOption o = (GroupOption)e.Item.DataItem;
            if (o.optionName == "")
            {
                if (o.rate == 0)
                    rate.Text = "";
            }
            if (o.optionType=="FEE" || o.optionType=="TAX" || o.optionType=="MSC")
                optionname.ReadOnly = true;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Options</td>
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
   <table cellpadding="0" cellspacing="0">
        <tr>
            <td>
                <asp:Repeater ID="optionlist" runat="server" onitemdatabound="optionlist_ItemDataBound">
                    <HeaderTemplate>
                        <table cellpadding="2" cellspacing="0" border="0">
                            <tr>
                                <td>&nbsp;</td>
                                <td class="tdlabel">Description</td>
                                <td class="tdlabel" width="150">&nbsp;&nbsp;Rate</td>
                                <td class="tdlabel" width="125">Rate Type</td>
                                <td class="tdlabel" align="center" width="100">Is Required</td>
                            </tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr valign="top">
                            <td><asp:HiddenField ID="optionid" runat="server" Value='<%# Eval("optionid") %>' />&nbsp;</td>
                            <td width="350"><asp:TextBox ID="optionname" runat="server" Width="300px" MaxLength="100" Text='<%# Bind("optionname") %>' /></td>  
                            <td>
                                $<asp:TextBox ID="rate" runat="server" Width="80px" Text='<%# Bind("rate","{0:###.00}") %>' MaxLength="8" />
                                <asp:CompareValidator id="comv2" runat="server" ControlToValidate="rate" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                            </td>                                        
                            <td>
					            <asp:DropDownList Runat="server" Width="100px" ID="ratetype" DataSource='<%# GM.PickList.GetRateType() %>' DataTextField="desc" DataValueField="code" SelectedValue='<%#Bind("ratetype")%>' AppendDataBoundItems="true" >
                                    <asp:ListItem></asp:ListItem>
					            </asp:DropDownList>
                            </td>                
                            <td align="center">
                                <asp:CheckBox ID="isrequired" runat="server" Checked='<%# Bind("isrequired") %>' />
                            </td>                
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
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