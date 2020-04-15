<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script language="C#" runat="server">


    bool confirmed
    {
        get { return Convert.ToBoolean(ViewState["confirmed"]); }
        set { ViewState["confirmed"] = value.ToString(); }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            Lookup.FillDropDown(grouptype, PickList.GetPickList("GROUPTYPE"), "", " ");
            //Lookup.FillDropDown(provider, PickList.GetProvider(""), "", " ");
            provider.DataSource = mtVendor.GeVendor();
            provider.DataBind();
            //Vendor Group Code DDL
            VgroupCode.DataSource = mtVendor.GetVGroupCode();
            VgroupCode.DataBind();
            //Lookup.FillDropDown(shipid, PickList.GetShip("", 0), "0", " ");
            save.Attributes["onclick"] = "javascript:return confirm('Are you sure you wish to create a new group?');";
            cancel.Attributes["onclick"] = "javascript:window.location.href='GroupList.aspx';return false;";
            //
            confirmed = false;
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        //DateTime dtDepartDate = Convert.ToDateTime(departdate.Text);
        //DateTime dtDepartDate = Convert.ToDateTime(departdate.SelectedDate.Value);
        DateTime dtDepartDate;
        string sDepartdate = Convert.ToString(departdate.SelectedDate.Value);
        var sDapartDate = sDepartdate.Replace("{", "");
        var sDepartDate =  sDepartdate.Replace("}", "");
        dtDepartDate = Convert.ToDateTime(sDepartDate);



        string sGroupType = grouptype.SelectedValue;
        //int iShipID = Util.parseInt(shipid.SelectedValue);
        int iShipID = Util.parseInt(shipname.SelectedValue);
        string sProvider = provider.SelectedValue;
        string sprovidergroupid = providergroupid.Text;
        string sVGroupCode = VgroupCode.SelectedValue;

        if (!confirmed)
        {
            List<string> list = GroupMaster.GetGroupIDList(dtDepartDate, sGroupType, sProvider, iShipID);
            if (list.Count > 0)
            {
                string strList = "";
                foreach (string s in list)
                    strList +=  ((strList == "") ? "" : ", ") + s;
                message.InnerHtml = string.Format("The following groups have the same departure date: {0} <br>Click \"Save & Continue\" to proceed!", strList);
                confirmed = true;
                return;
            }
        }

        try
        {
            string sGroupID = GroupMaster.GetGroupNumber(sGroupType, sDepartDate);
            if (sGroupID != "")
            {
                GroupMaster.Add(sGroupType, dtDepartDate, sProvider, iShipID, sprovidergroupid, sGroupID, sVGroupCode);
                mtGroup mtG = mtGroup.GetGroup(sGroupID);
                string msg = (mtG == null) ? "" : string.Format("PLEASE NOTE: Flyer for group {0} already exists. If necessary, please delete and recreate flyer", sGroupID);
                Response.Redirect("GroupEdit.aspx?groupid=" + sGroupID + "&msg=" + msg);
            }

        }
        catch (ApplicationException ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void provider_SelectedIndexChanged(object sender, EventArgs e)
    {
        //Lookup.FillDropDown(shipid, PickList.GetShip(provider.SelectedValue, Util.parseInt(shipid.SelectedValue)), shipid.SelectedValue, " ");
        //Lookup.FillDropDown(shipid, PickList.GetShip(provider.SelectedValue, Util.parseInt(shipid.SelectedValue)), shipid.SelectedValue, " ");
    }

    protected void departdate_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        //Response.Cookies["grouplist_departfr"].Value = departfr.SelectedDate.ToString();
        //DateTime dtDepartDate = Convert.ToDateTime(departdate.SelectedDate);
    }

    protected void provider_ItemSelected(object sender, DropDownListEventArgs e)
    {
        string sCode = provider.SelectedValue.ToString();
        if (sCode == "EXPTUR")
        {
            trVengorGroupCode.Visible = true;
            VgroupCode.ClearSelection();
        }
        else
        {
            trVengorGroupCode.Visible = false;
            VgroupCode.SelectedValue = "";
        }

        string sProvider = provider.SelectedValue.ToString();
        shipname.ClearSelection();
        shipname.DataSource = mtShip.GetListByVendor(sProvider);
        shipname.DataBind();
        shipname.SelectedIndex = -1;

    }

    protected void provider_ItemDataBound(object sender, DropDownListItemEventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select vendor...", string.Empty));
        }
    }

    protected void VgroupCode_ItemSelected(object sender, DropDownListEventArgs e)
    {

    }

    protected void VgroupCode_ItemDataBound(object sender, DropDownListItemEventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select group...", string.Empty));
        }
    }

    protected void shipname_ItemDataBound1(object sender, DropDownListItemEventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select Ship...", string.Empty));
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" valign="top">Create a New Group</td>
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
            <td class="tdlabel" width="150">Group Type:</td>
            <td>
                <asp:DropDownList runat="server" ID="grouptype" Width="200px" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="grouptype" ErrorMessage="Group type is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>
	    <tr>
		    <td class="tdlabel">Departure Date:</td>
		    <td>
                <%--<asp:textbox id="departdate" runat="server" Width="100"  MaxLength="12"></asp:textbox>
                <a onclick="setLastPos(event)" href="javascript:calendar('<%=departdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <telerik:RadDatePicker RenderMode="Lightweight" ID="departdate" width="100px" runat="server" OnSelectedDateChanged="departdate_SelectedDateChanged">
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="departdate" ErrorMessage="Departure date is required">*</asp:requiredfieldvalidator>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="departdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure date is invalid" Type="Date">*</asp:CompareValidator>
            </td>
	    </tr>
        <tr>
			<td class="tdlabel">Vendor Group #:&nbsp;<span class="required"></span></td>
			<td><asp:textbox id="providergroupid" runat="server" Width="150"  MaxLength="10"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="providergroupid" ErrorMessage="Vendor Group # is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Vendor Name:</td>
            <td>
                <%--<asp:DropDownList runat="server" ID="provider" Width="250px" onselectedindexchanged="provider_SelectedIndexChanged" AutoPostBack="true" />--%>
                <telerik:RadDropDownList id="provider" runat="server" Width="250px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="true"
                        DefaultMessage="Select a vendor" OnItemSelected="provider_ItemSelected"
                        DataValueField="vendorcode" DataTextField="vendorname" OnItemDataBound="provider_ItemDataBound" ></telerik:RadDropDownList>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="provider" ErrorMessage="Vendor is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr id="trVengorGroupCode" runat="server" visible="false">
            <td class="tdlabel">Vendor Group:&nbsp;</td>
            <td>
                <telerik:RadDropDownList ID="VgroupCode" runat="server" Width="250px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="false"
                        DefaultMessage="Select group..." DataValueField="VGroupCode" DataTextField="VGroupDescription" Skin="Black" 
                    OnItemSelected="VgroupCode_ItemSelected" OnItemDataBound="VgroupCode_ItemDataBound">
                </telerik:RadDropDownList>
                <%--<asp:requiredfieldvalidator id="reqval1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="VgroupCode" ErrorMessage="Vendor Group Code is required">*</asp:requiredfieldvalidator>--%>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Ship Name:</td>
            <td>
                <%--<asp:DropDownList runat="server" ID="shipid" Width="250px" />--%>
                <%--<telerik:RadComboBox id="shipname" runat="server" Width="250px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostnBack="false"--%>
                    <telerik:RadDropDownList id="shipname" runat="server" Width="250px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostnBack="false" Skin="Sunset"
                    DefaultMessage="Select a ship..." DataValueField="ShipCode" DataTextField="ShipName" OnItemDataBound="shipname_ItemDataBound1"></telerik:RadDropDownList>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="Save & Continue >" OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 