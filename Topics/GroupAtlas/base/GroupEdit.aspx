<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    const int idxGroupInfo = 0;
    const int idxRevenue = 1;

    string groupid
    {
        get { return ViewState["groupid"].ToString(); }
        set { ViewState["groupid"] = value; }
    }

    int grouptype
    {
        get { return Convert.ToInt32(ViewState["grouptype"]); }
        set { ViewState["grouptype"] = value; }
    }

    int tabindex
    {
        get { return Convert.ToInt32(ViewState["tabindex"]); }
        set { ViewState["tabindex"] = value.ToString(); }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            groupid = Request.QueryString["groupid"] + "";
            tabindex = Util.parseInt(Request.QueryString["tabindex"]);
            message.InnerHtml = Request.QueryString["msg"];
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (g == null)
                Response.Redirect("GroupList.aspx?msg=Group not found");
            //
            grouptype = g.GroupType;
            departdate.Text = g.DepartDate;
            returndate.Text = g.ReturnDate;
            recall_1.Text = g.Recall_1;
            recall_2.Text = g.Recall_2;
            recall_3.Text = g.Recall_3;
            hardstopdate.Text = g.HardStopDate;
            deposit_2.Text = g.Deposit_2;
            finaldue.Text = g.FinalDue;
            providergroupid.Text = g.ProviderGroupID;
            berths.Text = g.Berths.ToString();
            finaldue2.Text = g.FinalDue2;
            cancelled.Checked = g.Cancelled;
            canceldate.Text = g.CancelDate;
            air_inc.Checked = g.Air_Inc;
            affinitygroupname.Text = g.AffinityGroupName;
            tourname.Text = g.TourName;
            groupname.Text = g.GroupName;
            //
            Lookup.FillDropDown(groupagentflxid, PickList.GetGroupAgent(g.GroupAgentFlxID), g.GroupAgentFlxID.ToString(), " ");
            Lookup.FillDropDown(affinityagentflxid, PickList.GetAffinityAgent(g.AffinityAgentFlxID), g.AffinityAgentFlxID.ToString(), " ");
            Lookup.FillDropDown(portcity, PickList.GetPortCity(g.PortCity), g.PortCity, " ");
            //Lookup.FillDropDown(provider, PickList.GetProvider(g.Provider), g.Provider, " ");
            provider.DataSource = mtVendor.GetList();
            provider.DataBind();
            provider.SelectedValue = g.Provider;

            //Vendor Group Code DDL
            VgroupCode.DataSource = mtVendor.GetVGroupCode();
            VgroupCode.DataBind();
            VgroupCode.SelectedValue = g.VGroupCode;

            string sCode = g.Provider;
            if (sCode == "EXPTUR")
            {
                trVengorGroupCode.Visible = true;
                //VgroupCode.ClearSelection();

            }
            else
            {
                trVengorGroupCode.Visible = false;
            }

            ////Secondary Vendor Code
            //ddlSecondVendorCode.DataSource = mtVendor.GetSecondaryVendorCode(g.VGroupCode);
            //ddlSecondVendorCode.DataBind();
            //ddlSecondVendorCode.SelectedValue = g.VendorGroupCode2;
            ////vendorgroupcode.Text = g.VendorGroupCode;

            //Secondary Vendor Code
            ddlSecondVendorCode.DataSource =  mtVendor.GetList();
            ddlSecondVendorCode.DataBind();
            ddlSecondVendorCode.SelectedValue = g.VendorGroupCode2;
            //vendorgroupcode.Text = g.VendorGroupCode;

            Lookup.FillDropDown(revtype, PickList.GetPickList("REVTYPE"), g.RevType, " ");
            Lookup.FillDropDown(itinid, PickList.GetItinerary(g.Provider, g.ItinID), g.ItinID.ToString(), " ");
            Lookup.FillDropDown(shipid, PickList.GetShip(g.Provider, g.ShipID), g.ShipID.ToString(), " ");
            //Lookup.FillDropDown(destination, PickList.GetLocation(), g.Destination, " ");
            //Lookup.FillDropDown(adddetails, PickList.GetAddlDetails(), g.AddDetails, " ");

            ////provider_SelectedIndexChanged(this, EventArgs.Empty);

            //
            //tdAffinityGroupName.InnerHtml = (g.GroupType == 4) ? "Affinity Group:" : "Description";
            //if (g.GroupType != 4)
            //    trAffinityAgent.Visible = false;

            tdAffinityGroupName.InnerHtml = (g.GType == 4) ? "Affinity Group:" : "Description";
            if (g.GType != 4)
            {
                trAffinityAgent.Visible = false;
                trIATA.Visible = false;
                //lblDepartment.Visible = false;
            }
            else
            {
                trAffinityAgent.Visible = true;
                trIATA.Visible = true;
                //lblDepartment.Visible = true;
                if (affinityagentflxid.SelectedValue != "")
                {
                    int sflxID = Convert.ToInt32(affinityagentflxid.SelectedValue.ToString());
                    string sDepartment = "";
                    sDepartment = GroupMaster.GetAffinityLocationByFlxID(sflxID);
                    lblDepartment.Text = sDepartment;
                }
            }

            // Status
            bool enStatus = true;
            activetravel.Text = (DateTime.Today >= Convert.ToDateTime((g.DepartDate == "") ? "01/01/9999" : g.DepartDate)) ? "Travelled" : "Active";
            activetravel.Checked = (g.Cancelled) ? false : true;
            if (Security.SecClear(1))
                enStatus = true;
            else if (g.DepartDate != "" && DateTime.Today >= Convert.ToDateTime(g.DepartDate))
                enStatus = false;
            canceldate.Visible = (cancelled.Checked) ? true : false;
            activetravel.Enabled = enStatus;
            cancelled.Enabled = enStatus;
            canceldate.Enabled = enStatus;
            //

            // Revenue Tab
            finalgrosssales.Text = g.FinalGrossSales.ToString("#0.00");
            closedsales.Text = g.ClosedSales.ToString("#0.00");
            closednotes.Text = g.ClosedNotes;
            premium.Text = g.Premium.ToString("#0.00");
            premium2.Text = g.Premium2.ToString("#0.00");
            finalcomm.Text = g.FinalComm.ToString("#0.00");
            closedcomm.Text = g.ClosedComm.ToString("#0.00");
            finalbonuscomm.Text = g.FinalBonusComm.ToString("#0.00");
            closedbonuscomm.Text = g.ClosedBonusComm.ToString("#0.00");
            finalnettourconductor.Text = g.FinalNetTourConductor.ToString("#0.00");
            closedtourconductor.Text = g.ClosedTourConductor.ToString("#0.00");
            finaltourconused.Text = g.FinalTourConUsed.ToString("#0.00");
            closedtourconused.Text = g.ClosedTourConUsed.ToString("#0.00");
            finalgrossexpense.Text = g.FinalGrossExpense.ToString("#0.00");
            closedgrossexpense.Text = g.ClosedGrossExpense.ToString("#0.00");
            finalpax.Text = g.FinalPax.ToString();
            closedpax.Text = g.ClosedPax.ToString();
            date2accounting.Text = g.Date2Accounting;
            dateclosed.Text = g.DateClosed;
            rmtIATA.Text = g.IATA;
            //
            hdr.InnerHtml = string.Format("Edit Group # {0} - {1}&nbsp;&nbsp;[{2}]", g.GroupID, g.GroupName, g.GroupTypeDesc);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupView.aspx?groupid={0}&tabindex={1}';return false;", groupid, tabindex);
            if (tabindex == idxRevenue)
                Revenue_Click(this, EventArgs.Empty);
            else
                GroupInfo_Click(this, EventArgs.Empty);
            //
            if (!Security.IsAdmin())
            {
                closedsales.Enabled = false;
                premium2.Enabled = false;
                closedcomm.Enabled = false;
                closedbonuscomm.Enabled = false;
                closedtourconductor.Enabled = false;
                closedtourconused.Enabled = false;
                closedgrossexpense.Enabled = false;
                closedpax.Enabled = false;
                dateclosed.Enabled = false;
            }
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        int iTourID = Tour.GetTourID(tourname.Text);
        GroupMaster g = GroupMaster.GetGroupMaster(groupid);
        g.DepartDate = departdate.Text;
        g.ReturnDate = returndate.Text;
        g.Recall_1 = recall_1.Text;
        g.Recall_2 = recall_2.Text;
        g.Recall_3 = recall_3.Text;
        g.HardStopDate = hardstopdate.Text;
        g.Deposit_2 = deposit_2.Text;
        g.FinalDue = finaldue.Text;
        g.ProviderGroupID = providergroupid.Text;
        g.Berths = Util.parseInt(berths.Text);
        g.Cancelled = cancelled.Checked;
        g.CancelDate = (cancelled.Checked) ? canceldate.Text : "";
        g.Air_Inc = air_inc.Checked;
        g.GroupAgentFlxID = Util.parseInt(groupagentflxid.SelectedValue);
        g.AffinityAgentFlxID = Util.parseInt(affinityagentflxid.SelectedValue);
        g.PortCity = portcity.SelectedValue;
        g.ItinID = Util.parseInt(itinid.SelectedValue);
        g.ShipID = Util.parseInt(shipid.SelectedValue);
        g.TourID = iTourID;
        g.Provider = provider.SelectedValue;
        if (g.Provider == "")
        {
            message.InnerHtml = "Vendor name is required";
            return;
        }
        g.RevType = revtype.SelectedValue;
        g.AffinityGroupName = affinitygroupname.Text;
        g.GroupName = groupname.Text;
        //  g.Destination = destination.SelectedValue;
        // g.AddDetails = adddetails.SelectedValue;
        // Revenue Tab
        g.FinalGrossSales = ConvDec(finalgrosssales.Text);
        g.ClosedSales = ConvDec(closedsales.Text);
        g.ClosedNotes = closednotes.Text;
        g.Premium = ConvDec(premium.Text);
        g.Premium2 = ConvDec(premium2.Text);
        g.FinalComm = ConvDec(finalcomm.Text);
        g.ClosedComm = ConvDec(closedcomm.Text);
        g.FinalBonusComm = ConvDec(finalbonuscomm.Text);
        g.ClosedBonusComm = ConvDec(closedbonuscomm.Text);
        g.FinalNetTourConductor = ConvDec(finalnettourconductor.Text);
        g.ClosedTourConductor = ConvDec(closedtourconductor.Text);
        g.FinalTourConUsed = ConvDec(finaltourconused.Text);
        g.ClosedTourConUsed = ConvDec(closedtourconused.Text);
        g.FinalGrossExpense = ConvDec(finalgrossexpense.Text);
        g.ClosedGrossExpense = ConvDec(closedgrossexpense.Text);
        g.FinalPax = ConvInt(finalpax.Text);
        g.ClosedPax = ConvInt(closedpax.Text);
        g.Date2Accounting = date2accounting.Text;
        g.DateClosed = dateclosed.Text;
        g.VendorGroupCode2 = ddlSecondVendorCode.SelectedValue;
        g.VGroupCode = VgroupCode.SelectedValue;
        if (g.GType == 4)
        {
            g.IATA = rmtIATA.Text;
        }
        else
        {
            g.IATA = "";
        }

        try
        {
            GroupMaster.Update(g);
            mtGroup.UpdateFlyer(g.GroupID, g.Provider, g.ShipID); //As per Amy on 8/20/2019
            if (cancelled.Checked == true)
            {
                GroupMaster.UpdateDoNotDisplay(g.GroupID);
            }
            msg = HttpUtility.UrlEncode("Group #" + groupid + " was updated.");
            Response.Redirect("GroupView.aspx?groupid=" + groupid + "&tabindex=" + tabindex + "&msg=" + msg);


        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void GroupInfo_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabGroupInfo.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxGroupInfo;
    }

    protected void Revenue_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabRevenue.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxRevenue;
    }

    void InitTabs()
    {
        tabGroupInfo.CssClass = "grpTab";
        tabRevenue.CssClass = "grpTab";
    }

    protected void activetravel_CheckedChanged(object sender, EventArgs e)
    {
        if (activetravel.Checked)
        {
            cancelled.Checked = false;
            canceldate.Visible = false;
        }
    }

    protected void cancelled_CheckedChanged(object sender, EventArgs e)
    {
        if (cancelled.Checked)
        {
            activetravel.Checked = false;
            canceldate.Visible = true;
            if (canceldate.Text == "")
                canceldate.Text = DateTime.Today.ToShortDateString();
        }

    }

    //protected void provider_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    Lookup.FillDropDown(itinid, PickList.GetItinerary(provider.SelectedValue, Util.parseInt(itinid.SelectedValue)), itinid.SelectedValue, " ");
    //    Lookup.FillDropDown(shipid, PickList.GetShip(provider.SelectedValue, Util.parseInt(shipid.SelectedValue)), shipid.SelectedValue, " ");
    //}

    decimal ConvDec(string amt)
    {
        return (amt.Trim() == "") ? 0 : Convert.ToDecimal(amt);
    }

    int ConvInt(string num)
    {
        return (num.Trim() == "") ? 0 : Convert.ToInt32(num);
    }

    protected void affinityagentflxid_SelectedIndexChanged(object sender, EventArgs e)
    {
        int sflxID = 0;
        string sDepartment = "";
        string sIATA = "";
        if (affinityagentflxid.SelectedValue.ToString() != "" )
        {
            sflxID = Convert.ToInt32(affinityagentflxid.SelectedValue.ToString());
            sDepartment = GroupMaster.GetAffinityLocationByFlxID(sflxID);
            sIATA = GroupMaster.GetAffinityIATA(sflxID);
        }

        lblDepartment.Text = sDepartment;
        rmtIATA.Text = sIATA;

        //int sflxID = Convert.ToInt32(affinityagentflxid.SelectedValue.ToString());
        
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
    }

    protected void provider_SelectedIndexChanged(object sender, DropDownListEventArgs e)
    {
        Lookup.FillDropDown(itinid, PickList.GetItinerary(provider.SelectedValue, Util.parseInt(itinid.SelectedValue)), itinid.SelectedValue, " ");
        Lookup.FillDropDown(shipid, PickList.GetShip(provider.SelectedValue, Util.parseInt(shipid.SelectedValue)), shipid.SelectedValue, " ");
    }

    protected void VgroupCode_ItemSelected(object sender, DropDownListEventArgs e)
    {
        //ddlSecondVendorCode.DataSource = mtVendor.GetSecondaryVendorCode(VgroupCode.SelectedValue);
        //ddlSecondVendorCode.DataBind();
        //ddlSecondVendorCode.ClearSelection();
    }

    protected void VgroupCode_DataBound(object sender, EventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select group...", string.Empty));
        }
    }

    protected void ddlSecondVendorCode_ItemDataBound(object sender, DropDownListItemEventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select 2nd vendor...", string.Empty));
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <script type="text/javascript">
        function findAffinityGroup() {
            var url = "FindAffinityGroup.aspx?idaffinitygroupname=<%=affinitygroupname.ClientID%>&grouptype=<%=grouptype%>"
            popupWin(url);
        }
        function findTour() {
            var url = "FindTour.aspx?idtourname=<%=tourname.ClientID%>&provider=<%=provider.SelectedValue%>&tourname=<%=tourname.Text%>"
            popupWin(url);
        }
    </script>

    <style type="text/css">
        .grpTab
        {
            display: block;
            padding: 4px 18px 4px 18px;
            float: left;
            background: url("Images/tab.png") no-repeat right top;
            color: Black;
            font-weight: bold;
        }
        .grpTab:hover
        {
            color: White;
            background: url("Images/tabsel.png") no-repeat right top;
            cursor: pointer;
        }
        .grpTabSel
        {
            float: left;
            display: block;
            background: url("Images/tabsel.png") no-repeat right top;
            padding: 4px 18px 4px 18px;
            color: Black;
            font-weight: bold;
            color: White;
        }
        .numr
        {
            text-align: right;
        }
    </style>

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Group</td>
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
   <table width="900" align="left">
        <tr>
            <td>
	            <table cellspacing="1" cellpadding="3" border="0">
                    <tr>
                        <td class="tdlabel">Group Coordinator:</td>
                        <td><asp:DropDownList runat="server" ID="groupagentflxid" Width="300px" /></td>
                        <td width="300"></td>
                        <td class="required">* Required Fields</td>
                    </tr>
                    <tr runat="server" id="trAffinityAgent">
                        <td class="tdlabel">Affinity Agent:</td>
                        <td><asp:DropDownList runat="server" ID="affinityagentflxid" Width="300px" AutoPostBack="true" OnSelectedIndexChanged="affinityagentflxid_SelectedIndexChanged" /></td>
                        <td align="left" class="tdlabel">&nbsp;&nbsp;&nbsp;&nbsp;Location:&nbsp;&nbsp;<asp:Label runat="server" ID="lblDepartment" ForeColor="Navy"></asp:Label></td>
                    </tr>
	            </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Button Text="Group Info" BorderStyle="None" ID="tabGroupInfo" CssClass="grpTab" runat="server" OnClick="GroupInfo_Click" />
                <asp:Button Text="Revenue" BorderStyle="None" ID="tabRevenue" CssClass="grpTab" runat="server" OnClick="Revenue_Click" />
                <asp:MultiView ID="MainView" runat="server">
                    <asp:View ID="viewGroupInfo" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr valign="top">
                                <td>
                                    <table cellpadding="5" width="850" cellspacing="0">
                                    <tr valign="top">
                                         <td width="45%">
                                         <asp:Panel ID ="pnlTripInfo" runat="server" GroupingText=" Trip Info " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
		                                        <tr>
			                                        <td class="tdlabel" width="100">Departs:&nbsp;<span class="required">*</span></td>
			                                        <td><asp:textbox id="departdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=departdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="departdate" ErrorMessage="Departure date is required">*</asp:requiredfieldvalidator>
                                                        <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="departdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Returns:&nbsp;<span class="required">*</span></td>
			                                        <td><asp:textbox id="returndate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=returndate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="returndate" ErrorMessage="Return date is required">*</asp:requiredfieldvalidator>
                                                        <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="returndate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Return date is invalid" Type="Date">*</asp:CompareValidator>
                                                        <asp:CompareValidator ID="CompareValidator28" runat="server" ControlToValidate="returndate" CssClass="error" Display="Dynamic" ControlToCompare="departdate" Operator="GreaterThanEqual" ErrorMessage="Return date must be >= Departure date" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
                                                <tr>
                                                    <td class="tdlabel">Port City:</td>
                                                    <td><asp:DropDownList runat="server" ID="portcity" Width="250px" /></td>
                                                </tr>
                                                <!--
                                                <tr>
                                                    <td class="tdlabel">1st Stop:</td>
                                                    <td><asp:DropDownList runat="server" ID="destination" Width="250px" /></td>
                                                </tr>
                                                -->
                                                <tr>
                                                    <td class="tdlabel">Itinerary:</td>
                                                    <td><asp:DropDownList runat="server" ID="itinid" Width="250px" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Ship Name:</td>
                                                    <td><asp:DropDownList runat="server" ID="shipid" Width="250px" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Trip Theme:</td>
                                                    <td>
                                                        <asp:textbox id="tourname" runat="server" Width="230px"></asp:textbox><input type="button" value="..." onclick="findTour();" />
                                                       
                                                    </td>
                                                </tr>
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                            <asp:Panel ID ="pnlDates" runat="server" GroupingText=" Dates " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
		                                        <tr>
			                                        <td class="tdlabel" width="100">Recall 1:</td>
			                                        <td><asp:textbox id="recall_1" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=recall_1.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:CompareValidator ID="CompareValidator3" runat="server" ControlToValidate="recall_1" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Recall 1 date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel" width="100">Recall 2:</td>
			                                        <td><asp:textbox id="recall_2" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=recall_2.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:CompareValidator ID="CompareValidator5" runat="server" ControlToValidate="recall_2" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Recall 2 date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel" width="100">Recall 3:</td>
			                                        <td><asp:textbox id="recall_3" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=recall_3.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:CompareValidator ID="CompareValidator6" runat="server" ControlToValidate="recall_3" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Recall 3 date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Hard Stop:</td>
			                                        <td><asp:textbox id="hardstopdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=hardstopdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:CompareValidator ID="CompareValidator4" runat="server" ControlToValidate="hardstopdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Hard stop date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Deposit 2:</td>
			                                        <td><asp:textbox id="deposit_2" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=deposit_2.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:CompareValidator ID="CompareValidator8" runat="server" ControlToValidate="deposit_2" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Deposit 2 date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Vendor Due: <span class="required">*</span></td>
			                                        <td><asp:textbox id="finaldue" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=finaldue.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                                        <asp:requiredfieldvalidator id="RFV_VendorDue" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="finaldue" ErrorMessage="Vendor Due Date is required">*</asp:requiredfieldvalidator>
                                                        <asp:CompareValidator ID="CompareValidator7" runat="server" ControlToValidate="finaldue" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Vendor due date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Final Due:</td>
			                                        <td><asp:Label ID="finaldue2" runat="server"></asp:Label>
                                                    </td>
		                                        </tr>
	                                        </table>
                                            </asp:Panel>
                                         </td>      
                                         <td width="5%">&nbsp;</td>
                                         <td width="45%">
                                         
                                         <asp:Panel ID ="pnlGroupInfo" runat="server" GroupingText=" Group Info " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
		                                        <tr>
			                                        <td class="tdlabel" width="100px">Group Name:&nbsp;<span class="required">*</span></td>
			                                        <td><asp:textbox id="groupname" runat="server" Width="280px"  MaxLength="100"></asp:textbox>
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="groupname" ErrorMessage="Group name is required">*</asp:requiredfieldvalidator>
                                                    </td>
		                                        </tr>
                                                <tr>
                                                    <td class="tdlabel" width="100px">Vendor:&nbsp;<span class="required">*</span></td>
                                                    <td>
                                                        <%--<asp:DropDownList runat="server" ID="provider" Width="250px" 
                                                            onselectedindexchanged="provider_SelectedIndexChanged" AutoPostBack="true" />--%>
                                                        <telerik:RadDropDownList id="provider" runat="server" Width="280px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="true"
                                                        DefaultMessage="Select a vendor" OnItemDataBound="provider_ItemDataBound" OnItemSelected="provider_ItemSelected" 
                                                            OnSelectedIndexChanged="provider_SelectedIndexChanged" DataValueField="VendorCode" DataTextField="VendorName"></telerik:RadDropDownList>
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="provider" ErrorMessage="Vendor is required">*</asp:requiredfieldvalidator>
                                                    </td>
                                                </tr>
                                                <tr id="trVengorGroupCode" runat="server">
                                                    <td class="tdlabel" width="100px">Vendor Group:&nbsp;</td>
                                                    <td>
                                                        <telerik:RadDropDownList ID="VgroupCode" runat="server" Width="280px" RenderMode="Lightweight" DropDownHeight="200px" DropDownWidth="280px" AutoPostBack="false"
                                                                DefaultMessage="Select group..." DataValueField="VGroupCode" DataTextField="VGroupDescription" Skin="Black" OnItemSelected="VgroupCode_ItemSelected"
                                                             OnDataBound="VgroupCode_DataBound">
                                                            
                                                        </telerik:RadDropDownList>
                                                        <%--<asp:requiredfieldvalidator id="reqval1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="VgroupCode" ErrorMessage="Vendor Group Code is required">*</asp:requiredfieldvalidator>--%>
                                                    </td>
                                                </tr>
                                                <tr>
			                                        <td class="tdlabel" width="100px">Vendor Grp #:&nbsp;<span class="required">*</span></td>
			                                        <td><asp:textbox id="providergroupid" runat="server" Width="150"  MaxLength="100"></asp:textbox>
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="providergroupid" ErrorMessage="Vendor Group # is required">*</asp:requiredfieldvalidator>
                                                    </td>
		                                        </tr>
                                                <tr>
                                                    <td class="tdlabel" width="100px">2nd Vendor:&nbsp;</td>
                                                    <td>
                                                        <telerik:RadDropDownList ID="ddlSecondVendorCode" runat="server" Width="280px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="false"
                                                                DefaultMessage="Select 2nd vendor..." DataValueField="vendorCode" DataTextField="VendorName" Skin="Telerik" OnItemDataBound="ddlSecondVendorCode_ItemDataBound" >

                                                        </telerik:RadDropDownList>
                                                        <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorname" ErrorMessage="Vendor name is required">*</asp:requiredfieldvalidator>--%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" width="100px">Travel Type:&nbsp;<span class="required">*</span></td>
                                                    <td><asp:DropDownList runat="server" ID="revtype" Width="250px" />
                                                        <asp:requiredfieldvalidator id="Requiredfieldvalidator5" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="revtype" ErrorMessage="Travel type is required">*</asp:requiredfieldvalidator>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" width="100px">Berths:</td>
			                                        <td><asp:textbox id="berths" runat="server" Width="100"  MaxLength="5"></asp:textbox></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" runat="server" id="tdAffinityGroupName">Affinity Group:</td>
                                                    <td>
                                                        <asp:textbox id="affinitygroupname" runat="server" Width="230px"></asp:textbox>
                                                        <input type="button" value="..." onclick="findAffinityGroup();" />
                                                     </td>
                                                </tr>
                                                <tr id="trIATA" runat="server">
                                                    <td class="tdlabel" runat="server" id="tdAffinityIATA">IATA Number:</td>
                                                    <td>
                                                        <telerik:RadMaskedTextBox ID="rmtIATA" runat="server" Mask="########" Width="80px"></telerik:RadMaskedTextBox>
                                                     </td>
                                                </tr>
                                                <!--
                                                <tr>
                                                    <td class="tdlabel">Add. Details:</td>
                                                    <td><asp:DropDownList runat="server" ID="adddetails" Width="250px" /></td>
                                                </tr>
                                                -->
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                            <asp:Panel ID ="pnlMisc" runat="server" GroupingText=" Misc. Info " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
                                                <tr>
                                                    <td class="tdlabel" width="100">Status:</td>
                                                    <td>
                                                        <asp:radiobutton  runat="server" ID="activetravel" AutoPostBack="true" oncheckedchanged="activetravel_CheckedChanged" />
                                                        &nbsp;
                                                        <asp:radiobutton  runat="server" ID="cancelled" AutoPostBack="true" Text="Cancelled" oncheckedchanged="cancelled_CheckedChanged" />
                                                        <asp:textbox id="canceldate" runat="server" Width="100px"></asp:textbox>
                                                        <asp:CompareValidator ID="CompareValidator9" runat="server" ControlToValidate="canceldate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Cancel date is invalid" Type="Date">*</asp:CompareValidator>
                                                    </td>
                                                    <td>&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td>Air Included:</td>
                                                    <td><asp:checkbox  runat="server" ID="air_inc" /></td>
                                                </tr>
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                         </td>                              
                                    </tr>
                                    </table>

                                </td>
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewRevenue" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr>
                                <td>
                                    <table cellpadding="2" width="850" cellspacing="0">
                                    <tr>
                                        <td width="175"></td>
                                        <td width="175"><b>Finalized</b></td>
                                        <td width="175"><b>Closed</b></td>
                                        <td><b>Closing Notes</b></td>
                                    </tr>
                                    <tr>
                                        <td class="tdlabel">Sales:</td>
                                        <td><asp:TextBox ID="finalgrosssales" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator11" runat="server" ControlToValidate="finalgrosssales" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized sales is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedsales" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator10" runat="server" ControlToValidate="closedsales" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed sales is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td rowspan="99" valign="top">
                                            <asp:TextBox ID="closednotes" runat="server" TextMode="MultiLine" Rows="20" Width="275px"></asp:TextBox>
                                        </td>
                                     </tr>
                                     <tr>
                                        <td colspan="2">&nbsp;</td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Premium:</td>
                                        <td><asp:TextBox ID="premium" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator12" runat="server" ControlToValidate="premium" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized premium is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="premium2" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator13" runat="server" ControlToValidate="premium2" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed premium is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Commission:</td>
                                        <td><asp:TextBox ID="finalcomm" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator14" runat="server" ControlToValidate="finalcomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized commission is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedcomm" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator15" runat="server" ControlToValidate="closedcomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed commission is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Bonus Commission:</td>
                                        <td><asp:TextBox ID="finalbonuscomm" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator16" runat="server" ControlToValidate="finalbonuscomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized bonus commission is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedbonuscomm" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator17" runat="server" ControlToValidate="closedbonuscomm" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed bonus commission is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Tour Conductor:</td>
                                        <td><asp:TextBox ID="finalnettourconductor" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator18" runat="server" ControlToValidate="finalnettourconductor" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized tour conductor amount is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedtourconductor" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator19" runat="server" ControlToValidate="closedtourconductor" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed tour conductor amount is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Tour Con. Used:</td>
                                        <td><asp:TextBox ID="finaltourconused" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator20" runat="server" ControlToValidate="finaltourconused" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized tour con. used amount is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedtourconused" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator21" runat="server" ControlToValidate="closedtourconused" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed tour con. used amount is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Expense:</td>
                                        <td><asp:TextBox ID="finalgrossexpense" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator22" runat="server" ControlToValidate="finalgrossexpense" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized expense is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedgrossexpense" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator23" runat="server" ControlToValidate="closedgrossexpense" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed expense is invalid" Type="Currency">*</asp:CompareValidator>
                                        </td>
                                     </tr>
                                     <tr>
                                        <td colspan="2">&nbsp;</td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Passengers:</td>
                                        <td><asp:TextBox ID="finalpax" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator24" runat="server" ControlToValidate="finalpax" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized passengers is invalid" Type="Integer">*</asp:CompareValidator>
                                        </td>
                                        <td><asp:TextBox ID="closedpax" runat="server" Width="100px" CssClass="numr"></asp:TextBox>
                                            <asp:CompareValidator ID="CompareValidator25" runat="server" ControlToValidate="closedpax" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed passengers is invalid" Type="Integer">*</asp:CompareValidator>
                                        </td>
                                     </tr>
		                            <tr>
			                            <td class="tdlabel">Date:</td>
			                            <td><asp:textbox id="date2accounting" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=date2accounting.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                            <asp:CompareValidator ID="CompareValidator26" runat="server" ControlToValidate="date2accounting" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Finalized date is invalid" Type="Date">*</asp:CompareValidator>
                                        </td>
			                            <td><asp:textbox id="dateclosed" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=dateclosed.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                            <asp:CompareValidator ID="CompareValidator27" runat="server" ControlToValidate="dateclosed" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Closed date is invalid" Type="Date">*</asp:CompareValidator>
                                        </td>
		                            </tr>
                                     </table>
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                </asp:MultiView>
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