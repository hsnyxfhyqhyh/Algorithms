<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script language="C#" runat="server">
    
	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            message.InnerHtml = Request.QueryString["msg"];
            string sPrimProvider = Request.QueryString["primprovider"] + "";
            string action = Request.QueryString["action"] + "";
            if (action == "newgroup")
                Provider.CreateGroup(sPrimProvider, sPrimProvider);
            primprovider.DataSource = Provider.GetPrimaryList();
            primprovider.DataBind();
            if (sPrimProvider != "" && primprovider.Items.FindByValue(sPrimProvider) != null)
                primprovider.Items.FindByValue(sPrimProvider).Selected = true;
            primary.Attributes["onclick"] = "return confirm('Are you sure you wish to change primary?');";
            remove.Attributes["onclick"] = "return confirm('Are you sure you wish to remove selected members?');";
            //
            primprovider_SelectedIndexChanged(this, EventArgs.Empty);
        }
	}

    protected void remove_Click(object sender, EventArgs e)
    {
        int selCnt = 0;
        int itmCnt = 0;
        bool selPrim = false;
        List<string> list = new List<string>();
        foreach (DataListItem itm in provList.Items)
        {
            string sProvider = ((HtmlInputHidden)itm.Controls[1].FindControl("provider")).Value;
            bool selected = ((HtmlInputCheckBox)itm.Controls[1].FindControl("selected")).Checked;
            if (selected)
            {
                list.Add(sProvider);
                selCnt++;
                if (sProvider == primprovider.SelectedValue)
                    selPrim = true;
            }
            itmCnt++;
        }
        if (selCnt == 0)
        {
            message.InnerHtml = "At least one(1) member must be selected";
            return;
        }
        if (selPrim && (itmCnt != selCnt))
        {
            message.InnerHtml = "All items for group must be removed before removing the primary member";
            return;
        }
        Provider.RemoveMember(list);
        Response.Redirect("ProviderEdit.aspx?primprovider=" + primprovider.SelectedValue);
    }

    protected void primary_Click(object sender, EventArgs e)
    {
        int selCnt = 0;
        string newProvider = "";
        foreach (DataListItem itm in provList.Items)
        {
            bool selected = ((HtmlInputCheckBox)itm.Controls[1].FindControl("selected")).Checked;
            if (selected)
            {
                selCnt++;
                newProvider = ((HtmlInputHidden)itm.Controls[1].FindControl("provider")).Value;
            }
        }
        if (selCnt == 0 || selCnt > 1)
        {
            message.InnerHtml = "Only one(1) member must be selected for primary";
            return;
        }
        if (primprovider.SelectedValue == newProvider)
        {
            message.InnerHtml = "Already selected as the primary member";
            return;
        }
        Provider.ChangePrimary(primprovider.SelectedValue, newProvider);
        Response.Redirect("ProviderEdit.aspx?primprovider=" + newProvider + "&msg=Primary was successfully changed");
    }
  
    protected void primprovider_SelectedIndexChanged(object sender, EventArgs e)
    {
        provList.DataSource = Provider.GetMemberList(primprovider.SelectedValue);
        provList.DataBind();
        //
        remove.Enabled = false;
        primary.Enabled = false;
        add.Visible = true;
        int rowcnt = provList.Items.Count;
        if (rowcnt > 0)
            remove.Enabled = true;
        if (rowcnt > 1)
            primary.Enabled = true;
        if (primprovider.SelectedValue == "")
            add.Visible = false;
    }

    /* Add Member Section */
    protected void add_Click(object sender, EventArgs e)
    {
        tabManage.Visible = false;
        tabAdd.Visible = true;
        lblprim.Text = primprovider.SelectedItem.Text;
        searchstr.Text = "";
        provListA.DataSource = null;
        provListA.DataBind();
    }

    protected void addsrch_Click(object sender, EventArgs e)
    {
        provListA.DataSource = Provider.GetList(true, searchstr.Text);
        provListA.DataBind();
        if (provListA.Items.Count >= 500)
            message.InnerHtml = "Result exceeds 500 rows. Please refine search keyword.";
    }

    protected void additem_Click(object sender, EventArgs e)
    {
        int selCnt = 0;
        List<string> list = new List<string>();
        foreach (DataListItem itm in provListA.Items)
        {
            string sProvider = ((HtmlInputHidden)itm.Controls[1].FindControl("provider")).Value;
            bool selected = ((HtmlInputCheckBox)itm.Controls[1].FindControl("selected")).Checked;
            if (selected)
            {
                list.Add(sProvider);
                selCnt++;
            }
        }
        if (selCnt == 0)
        {
            message.InnerHtml = "At least one(1) item must be selected";
            return;
        }
        Provider.AddMembers(primprovider.SelectedValue, list);
        addcanc_Click(this, EventArgs.Empty);
    }

    protected void addcanc_Click(object sender, EventArgs e)
    {
        tabAdd.Visible = false;
        tabManage.Visible = true;
        primprovider_SelectedIndexChanged(this, EventArgs.Empty);
    }

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Manage Provider Group</td>
			<td align="right">&nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='ProviderNewGrp.aspx';return false;" value="New Providor Group" />&nbsp;</td>
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
			</td>
		</tr>
	</table>
	<table id="tabManage" runat="server" cellspacing="1" cellpadding="3" border="0">
        <tr>
            <td class="tdlabel">Primary Member<br />
                <asp:DropDownList runat="server" ID="primprovider" Width="500px" 
                    DataValueField="provider" DataTextField="provdesc" AppendDataBoundItems="true" 
                    onselectedindexchanged="primprovider_SelectedIndexChanged" AutoPostBack="true" >
                    <asp:ListItem Value="">Select Primary Member</asp:ListItem>
                </asp:DropDownList>
		    </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" border="0" width="500">
                <tr>
                    <td class="tdlabel">All Members</td>                    
                    <td align="right"><asp:button id="add" runat="server" Text="Add Member" Visible="false" CssClass="button" onclick="add_Click"  /></td>
                </tr>
                </table>
   		        <asp:Panel ID="Panel2" runat="server" Width="500px" ScrollBars="Vertical" Height="350px" BorderColor="#CCCCCC" BorderStyle="Ridge" BorderWidth="1px">
			        <asp:datalist id="provList" runat="server"  CellPadding="1" CellSpacing="0">
                        <HeaderTemplate>
                            <table cellpadding="0" cellspacing="0" border="0">
                        </HeaderTemplate>
				        <ItemTemplate>
					        <tr>
						        <input type="hidden" id="provider" value='<%# Eval("provider") %>' runat="server" />
						        <td width="50" align="center"><input type="CheckBox"  id="selected" runat="server" />&nbsp;</td>
						        <td width="100" class="label"><%# Eval("provider")%>&nbsp;</td>
						        <td class="label"><%# Eval("provname")%>&nbsp;</td>
					        </tr>
				        </ItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
			        </asp:datalist>
		        </asp:Panel>    
            </td>
        </tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="remove" runat="server" Text="Remove Selected Items" Enabled="false" CssClass="button" 
                    onclick="remove_Click"></asp:button>&nbsp;
				<asp:button id="primary" runat="server" Text="Make Primary" Enabled="false" CssClass="button" 
                    onclick="primary_Click"></asp:button>&nbsp;
			</td>
		</tr>
	</table>

	<table id="tabAdd" runat="server" visible="false" cellspacing="1" cellpadding="3" border="0">
        <tr>
            <td class="hdr">Add Members to - <asp:Label ID="lblprim" runat="server" CssClass="hdr"></asp:Label>
		    </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td>
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr valign="bottom">
                        <td class="small"><asp:TextBox ID="searchstr" Width="150px" runat="server" MaxLength="25" /></td>
                        <td>&nbsp;&nbsp;</td>
                        <td>
                            <asp:Button CssClass="topbutton" ID="searchbtn" OnClick="addsrch_Click" runat="server" Text="Search" />
                        </td>
                    </tr>
                </table>
   		        <asp:Panel ID="Panel1" runat="server" Width="500px" ScrollBars="Vertical" Height="350px" BorderColor="#CCCCCC" BorderStyle="Ridge" BorderWidth="1px">
			        <asp:datalist id="provListA" runat="server"  CellPadding="1" CellSpacing="0">
                        <HeaderTemplate>
                            <table cellpadding="0" cellspacing="0" border="0">
                        </HeaderTemplate>
				        <ItemTemplate>
					        <tr>
						        <input type="hidden" id="provider" value='<%# Eval("provider") %>' runat="server" />
						        <td width="50" align="center"><input type="CheckBox"  id="selected" runat="server" />&nbsp;</td>
						        <td width="100" class="label"><%# Eval("provider")%>&nbsp;</td>
						        <td class="label"><%# Eval("provname")%>&nbsp;</td>
					        </tr>
				        </ItemTemplate>
                        <FooterTemplate>
                            </table>
                        </FooterTemplate>
			        </asp:datalist>
		        </asp:Panel>    
            </td>
        </tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="additem" runat="server" Text="Add Selected Items to Group" 
                    CssClass="button" onclick="additem_Click"></asp:button>&nbsp;
				<asp:button id="addcanc" runat="server" Text="Cancel" CssClass="button" 
                    onclick="addcanc_Click"></asp:button>
			</td>
		</tr>
	</table>


</asp:Content> 