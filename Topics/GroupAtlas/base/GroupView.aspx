<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    const int idxGroupInfo = 0;
    const int idxRevenue = 1;
    const int idxNotes = 2;
    const int idxFileMaint = 3;
    const int idxPaxList = 4;
    const int idxInvoiced = 5;
    const int idxRates = 6;
    //const int idxFiles = 7;

    string groupid
    {
        get { return ViewState["groupid"].ToString(); }
        set { ViewState["groupid"] = value; }
    }

    private bool IsEmptyNoteList
    {
        get { return (bool)(ViewState["IsEmptyNoteList"] ?? false); }
        set { ViewState["IsEmptyNoteList"] = value; }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Check current Security level
        if (Session["Security"] != null)
        {
            int s = Convert.ToInt32(Session["Security"].ToString());

            if (s == 4)
            {
                Files.Visible = false;
                flyer.Visible = false;
            }
            else
            {
                Files.Visible = true;
                flyer.Visible = true;
            }
        }
    }
    void Page_Load(object sender, System.EventArgs e)
    {
        // Check current Security level
        //if (Session["Security"] != null)
        //{
        //    int s = Convert.ToInt32(Session["Security"].ToString());
        //    if (s > 1) tabFileMaint.Enabled = false;
        //}
        //int s = Convert.ToInt32(Session["Security"].ToString());
        //if (s > 1) tabFileMaint.Enabled = false;

        if (!IsPostBack)
        {
            groupid = Request.QueryString["groupid"] + "";
            int tabindex = Util.parseInt(Request.QueryString["tabindex"]);
            message.InnerHtml = Request.QueryString["msg"];
            //Define Hyperlinks
            aGroupInvEdit.NavigateUrl = "~/GroupInvEdit.aspx?groupid=" + groupid;
            aGroupPackageEdit.NavigateUrl = "~/GroupPackageEdit.aspx?groupid=" + groupid;
            aGroupOptionEdit.NavigateUrl = "~/GroupOptionInvControl.aspx?groupid=" + groupid;

            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (g == null)
                Response.Redirect("GroupList.aspx?msg=Group not found");
            //
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
            canceldate.Text = g.CancelDate;
            air_inc_desc.Text = (g.Air_Inc) ? "Yes" : "No";
            groupagentname.Text = g.GroupAgentName;
            affinityagentname.Text = g.AffinityAgentName;
            //destination.Text = g.DestinationName;
            if (affinityagentname.Text != "")
            {
                string sDepartment = "";
                sDepartment = GroupMaster.GetAffinityLocationByName(affinityagentname.Text);
                lblDepartment.Text = sDepartment;
            }
            portcity.Text = g.PortCityName;
            itinerary.Text = g.Itinerary;
            shipname.Text = g.ShipName;
            tourname.Text = g.TourName;
            provider.Text = g.ProvName;
            string sCode = g.Provider;
            if (sCode == "EXPTUR")
            {
                trVendorGroupName.Visible = true;
            }
            else
            {
                trVendorGroupName.Visible = false;
            }
            //lblVGroupCode.Text = g.VGroupCode;
            lblVGroupCode.Text = g.VGroupDescription;
            //lblVendorGroupCode2.Text = g.VendorGroupCode2;
            lblVendorGroupCode2.Text = g.vendorName2;
            revtype.Text = g.RevTypeDesc;
            affinitygroupname.Text = g.AffinityGroupName;
            groupname.Text = g.GroupName;
            affinityIATA.Text = g.IATA;
            //adddetails.Text = g.AddDetails;

            //tdAffinityGroupName.InnerHtml = (g.GroupType == 4) ? "Affinity Group:" : "Description:";
            //if (g.GroupType != 4)
            //    trAffinityAgent.Visible = false;
            tdAffinityGroupName.InnerHtml = (g.GType == 4) ? "Affinity Group:" : "Description:";
            if (g.GType != 4)
            {
                trAffinityAgent.Visible = false;
                tdAffinityIATA.Visible = false;
            }
            else
            {
                tdAffinityIATA.Visible = true;
                trAffinityAgent.Visible = true;
            }


            // Status
            status.Text = (g.Cancelled) ? "Cancelled" : ((DateTime.Today >= Convert.ToDateTime((g.DepartDate == "") ? "01/01/9999" : g.DepartDate)) ? "Travelled" : "Active");
            canceldate.Visible = (g.Cancelled) ? true : false;

            // Revenue Tab
            decimal saleslesspremF = g.FinalGrossSales - g.Premium;
            decimal saleslesspremC = g.ClosedSales - g.Premium2;
            decimal revenueF = g.Premium + g.FinalComm + g.FinalBonusComm + g.FinalNetTourConductor - g.FinalTourConUsed - g.FinalGrossExpense;
            decimal revenueC = g.Premium2 + g.ClosedComm + g.ClosedBonusComm + g.ClosedTourConductor - g.ClosedTourConUsed - g.ClosedGrossExpense;
            decimal percF = (saleslesspremF == 0) ? 0 : (revenueF / saleslesspremF);
            decimal percC = (saleslesspremC == 0) ? 0 : (revenueC / saleslesspremC);
            finalgrosssales.Text = g.FinalGrossSales.ToString("#0.00");
            closedsales.Text = g.ClosedSales.ToString("#0.00");
            closednotes.Text = g.ClosedNotes;
            disppremF.Text = g.Premium.ToString("#0.00");
            disppremC.Text = g.Premium2.ToString("#0.00");
            dispsalesF.Text = saleslesspremF.ToString("#0.00");
            dispsalesC.Text = saleslesspremC.ToString("#0.00");
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
            disprevenueF.Text = revenueF.ToString("#0.00");
            disprevenueC.Text = revenueC.ToString("#0.00");
            disppercF.Text = percF.ToString("#0.0%");
            disppercC.Text = percC.ToString("#0.0%");
            finalpax.Text = g.FinalPax.ToString();
            closedpax.Text = g.ClosedPax.ToString();
            date2accounting.Text = g.Date2Accounting;
            dateclosed.Text = g.DateClosed;
            //
            NoteDS.SelectParameters["groupid"].DefaultValue = groupid;
            //
            TaskDS.SelectParameters["groupid"].DefaultValue = groupid;
            Lookup.FillDropDown(cxlpolicyid, PickList.GetCxlPolicy(g.Provider), g.CxlPolicyID.ToString(), " ");
            policyList.DataSource = CxlPolicy.GetDetails(g.CxlPolicyID, g.DepartDate);
            policyList.DataBind();
            TaskType.DataSource = PickList.GetTaskType();
            TaskType.DataBind();
            if (TaskType.Items.Count > 0)
                TaskType.SelectedIndex = 0;

            // Rates & Inventory Tab
            isselloveralloc.Text = (g.IsSellOverAlloc) ? "Yes" : "No";
            maxpassengers.Text = g.MaxPassengers.ToString();
            minpassengers.Text = g.MinPassengers.ToString();

            PackageDS.SelectParameters["groupid"].DefaultValue = groupid;
            OptionDS.SelectParameters["groupid"].DefaultValue = groupid;
            //
            hdr.InnerHtml = string.Format("Group # {0} - {1}&nbsp;&nbsp;[{2}]", g.GroupID, g.GroupName, g.GroupTypeDesc);
            cancel.Attributes["onclick"] = "javascript:window.location.href='GroupList.aspx';return false;";
            if (tabindex == idxNotes)
                Notes_Click(this, EventArgs.Empty);
            else if (tabindex == idxPaxList)
                PaxList_Click(this, EventArgs.Empty);
            else if (tabindex == idxRevenue)
                Revenue_Click(this, EventArgs.Empty);
            else if (tabindex == idxRates)
                Rates_Click(this, EventArgs.Empty);
            else
                GroupInfo_Click(this, EventArgs.Empty);
            //
            editgrp.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupEdit.aspx?groupid={0}&tabindex=0';return false;", groupid);
            editrev.Attributes["onclick"] = string.Format("javascript:window.location.href='GroupEdit.aspx?groupid={0}&tabindex=1';return false;", groupid);
            newbooking.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingNew.aspx?groupid={0}';return false;", groupid);
            bookings.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingList.aspx?searchstr={0}&clear=Y';return false;", groupid);
            //
            mtGroup mtG = mtGroup.GetGroup(groupid);
            if (mtG == null)
            {
                flyer.Text = "Create Flyer";
                flyer.Attributes["onclick"] = string.Format("javascript:window.location.href='mtGroupAdd.aspx?groupcode={0}&packagetype={1}';return false;", groupid, PackageType(g.RevType));
            }
            else
            {
                flyer.Text = "Flyer Details";
                flyer.Attributes["onclick"] = string.Format("javascript:window.location.href='mtGroupEdit.aspx?groupcode={0}';return false;", groupid);
            }
        }
        // Check current Security level
        if (Session["Security"] != null)
        {
            int iRole = Convert.ToInt32(Session["Security"].ToString());
            string sGroupID1 = Session["GroupID1"].ToString();
            string sGroupID2 = Session["GroupID2"].ToString();
            string sGroupID3 = Session["GroupID3"].ToString();
            string sGroupID4 = Session["GroupID4"].ToString();
            string sGroupID5 = Session["GroupID5"].ToString();
            if (iRole == 3) // Reporting people can't access
            {
                //tabFileMaint.Enabled = false;
                TaskList.Enabled = false;
                pnlCxlPolicy.Enabled = false;
                pnlTaskType.Enabled = false;
            }

            if (iRole == 4)
            {
                Files.Visible = false;
                flyer.Visible = false;
                // Check for allowed Group
                if (sGroupID1 == groupid || sGroupID2 == groupid || sGroupID3 == groupid || sGroupID4 == groupid || sGroupID5 == groupid)
                //if (sGroupID == groupid)
                {
                    newbooking.Enabled = true;
                    bookings.Enabled = true;
                    editgrp.Enabled = false;
                    editrev.Enabled = false;
                    NoteList.Enabled = false;
                    TaskList.Enabled = false;
                    TaskType.Enabled = false;
                    CreateFileMaint.Enabled = false;
                    cxlpolicyid.Enabled = false;
                    PackageList.Enabled = false;
                    foreach (GridViewRow row in PackageList.Rows)
                    {
                        ((LinkButton)row.Cells[1].FindControl("LnkDelete")).Enabled = false;
                        LinkButton lnk = ((LinkButton)row.Cells[1].FindControl("LnkDelete"));
                        lnk.Attributes.Remove("OnClientClick");
                        lnk.Enabled = false;
                        lnk.Visible = false;
                    }
                    OptionList.Enabled = false;
                    foreach (GridViewRow row in OptionList.Rows)
                    {
                        ((LinkButton)row.Cells[0].FindControl("LnkDelete")).Enabled = false;
                        LinkButton lnk = ((LinkButton)row.Cells[0].FindControl("LnkDelete"));
                        lnk.Attributes.Remove("OnClientClick");
                        lnk.Enabled = false;
                        lnk.Visible = false;
                    }
                    aGroupInvEdit.Enabled = false;
                    aGroupPackageEdit.Enabled = false;
                    aGroupOptionEdit.Enabled = false;
                }
                else
                {
                    newbooking.Enabled = false;
                    bookings.Enabled = false;
                    editgrp.Enabled = false;
                    editrev.Enabled = false;
                    NoteList.Enabled = false;
                    TaskList.Enabled = false;
                    TaskType.Enabled = false;
                    CreateFileMaint.Enabled = false;
                    cxlpolicyid.Enabled = false;
                    PackageList.Enabled = false;
                    foreach (GridViewRow row in PackageList.Rows)
                    {
                        ((LinkButton)row.Cells[1].FindControl("LnkDelete")).Enabled = false;
                        LinkButton lnk = ((LinkButton)row.Cells[1].FindControl("LnkDelete"));
                        lnk.Attributes.Remove("OnClientClick");
                        lnk.Enabled = false;
                        lnk.Visible = false;
                    }
                    OptionList.Enabled = false;
                    foreach (GridViewRow row in OptionList.Rows)
                    {
                        ((LinkButton)row.Cells[0].FindControl("LnkDelete")).Enabled = false;
                        LinkButton lnk = ((LinkButton)row.Cells[0].FindControl("LnkDelete"));
                        lnk.Attributes.Remove("OnClientClick");
                        lnk.Enabled = false;
                        lnk.Visible = false;
                    }
                    aGroupInvEdit.Enabled = false;
                    aGroupPackageEdit.Enabled = false;
                    aGroupOptionEdit.Enabled = false;
                }
            }
            else
            {
                Files.Visible = true;
                flyer.Visible = true;
            }
        }
    }

    string PackageType(string revType)
    {
        if (revType.ToUpper() == "S") return "C";
        else if (revType.ToUpper() == "ST") return "CT";
        else return revType.ToUpper();
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

    protected void Notes_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabNotes.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxNotes;
    }

    protected void FileMaint_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabFileMaint.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxFileMaint;
    }

    protected void PaxList_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabPaxList.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxPaxList;
        listPax.DataSource = GW.GetPaxList(groupid);
        listPax.DataBind();
        activepax.Text = GW.GetActivePax(groupid).ToString();
        activeparty.Text = GW.GetActiveParty(groupid).ToString();
        activephone.Text = GW.GetActivePhone(groupid).ToString();
    }

    protected void Invoiced_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabInvoiced.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxInvoiced;
        listInvoiced.DataSource = GW.GetInvoicedList(groupid);
        listInvoiced.DataBind();
        totalinvoiced.Text = GW.GetTotalInvoiced(groupid).ToString("c");
        totalbooked.Text = GW.GetTotalBooked(groupid).ToString("c");
    }

    protected void Rates_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabRates.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxRates;
        //
        GroupOption.InsertDefOptions(groupid);
    }

    protected void Files_Click(object sender, EventArgs e)
    {
        //InitTabs();
        //TabFiles.CssClass = "grpTabSel"; 
        //MainView.ActiveViewIndex = idxFiles;
        //
        //GroupOption.InsertDefOptions(groupid);
        Response.Redirect("GroupFile.aspx?GroupID=" + groupid);
        //System.Diagnostics.Process.Start("explorer.exe", "c:\\test");
    }

    void InitTabs()
    {
        tabGroupInfo.CssClass = "grpTab";
        tabRevenue.CssClass = "grpTab";
        tabNotes.CssClass = "grpTab";
        tabFileMaint.CssClass = "grpTab";
        tabPaxList.CssClass = "grpTab";
        tabInvoiced.CssClass = "grpTab";
        tabRates.CssClass = "grpTab";
        //TabFiles.CssClass = "grpTab";
    }

    protected void TaskType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void CreateFileMaint_Click(object sender, EventArgs e)
    {
        GroupMaster.CreateFileMaintCheckList(groupid);
        TaskList.DataBind();
    }

    protected void cxlpolicyid_SelectedIndexChanged(object sender, EventArgs e)
    {
        int policyID = Util.parseInt(cxlpolicyid.SelectedValue);
        policyList.DataSource = CxlPolicy.GetDetails(policyID, departdate.Text);
        policyList.DataBind();
        //
        GroupMaster.UpdatePolicyID(groupid, policyID);
    }
    protected void LoadNotes(string groupid)
    {
        DataTable dt = new DataTable();
        dt = GroupMaster.GetNotesList(groupid);

    }

    protected void NoteList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Save")
        {
            string notes = ((RadTextBox)NoteList.FooterRow.FindControl("notes")).Text;
            GroupMaster.AddNotes(groupid, notes);
            NoteList.DataBind();
        }
        else if (e.CommandName == "Delete")
        {
            int rowIndex = Convert.ToInt32(e.CommandArgument);
            int noteid = Convert.ToInt32(NoteList.DataKeys[Convert.ToInt32(e.CommandArgument)].Value.ToString());
            string groupid = ViewState["groupid"].ToString();
            GroupMaster.DeleteNotes(noteid,  groupid);
            NoteList.DeleteRow(rowIndex);
        }
        else if (e.CommandName == "Cancel")
        {
            //NoteList.DataBind();
        }
        else if (e.CommandName == "Edit")
        {
        }
        else if (e.CommandName == "Update")
        {
            try
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                string notes = ((RadTextBox)NoteList.Rows[rowIndex].FindControl("rdnotes")).Text;
                string groupid = ViewState["groupid"].ToString();
                int noteid = Convert.ToInt32(NoteList.DataKeys[Convert.ToInt32(e.CommandArgument)].Value.ToString());
                GroupMaster.UpdateNotes(groupid, notes, noteid);
                NoteList.EditIndex = -1;
                NoteList.DataBind();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

    }

    protected void NoteList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (IsEmptyNoteList && e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Visible = false;
            e.Row.Controls.Clear();
        }
    }

    protected void NoteList_RowEditing(object sender, GridViewEditEventArgs e)
    {
        NoteList.EditIndex = e.NewEditIndex;

    }

    protected void NoteDS_Selected(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.Exception != null)
            throw e.Exception;
        DataTable dataTable = (DataTable)e.ReturnValue;
        if (dataTable.Rows.Count == 0)
        {
            dataTable.Rows.Add(dataTable.NewRow());
            IsEmptyNoteList = true;
        }
        else
            IsEmptyNoteList = false;
    }

    protected void PackageDS_Deleted(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.Exception != null)
        {
            message.InnerHtml = "Could not delete record";
            e.ExceptionHandled = true;
        }
    }

    protected void OptionDS_Deleted(object sender, ObjectDataSourceStatusEventArgs e)
    {
        if (e.Exception != null)
        {
            message.InnerHtml = "Could not delete record";
            e.ExceptionHandled = true;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <style type="text/css">
        .grpTab
        {
            display: block;
            padding: 4px 10px 4px 10px;
            float: left;
            background: url("Images/tab.png") no-repeat right top;
            color: Black;
            font-weight: bold;
        }
        .grpTab:hover
        {
            color: Yellow;
            background: url("Images/tabselhover.png") no-repeat right top;
            cursor: pointer;
        }
        .grpTabSel
        {
            float: left;
            display: block;
            background: url("Images/tabsel.png") no-repeat right top;
            padding: 4px 10px 4px 10px;
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
			<td class="hdr" id="hdr" runat="server" valign="top">View Group</td>
			<td align="right">
                <asp:button id="Files" runat="server" Text="Documents" Width="85px" CssClass="button" TabIndex="-1" CausesValidation="False" OnClick="Files_Click"></asp:button>&nbsp;
                <asp:button id="flyer" runat="server" Text="Flyer Detail" Width="85px" CssClass="button" TabIndex="-1" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="newbooking" runat="server" Text="New Booking" Width="85px" CssClass="button" TabIndex="-1" ToolTip="New booking for group" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="bookings" runat="server" Text="Bookings" Width="75px" CssClass="button" TabIndex="-1" ToolTip="Bookings for group" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="cancel" runat="server" Text="&lt;&lt;Back To List" Width="95px" CssClass="button" CausesValidation="False"></asp:button>&nbsp;
            </td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td><span id="message" class="message" runat="server" EnableViewState="false"></span><br></td>
            <td align="right">
               <!-- <a href="WaitListEdit.aspx?groupid=<%=groupid%>">[Add to Waiting List]</a> -->
            </td>
		</tr>
	</table>
   <table width="900" align="left">
        <tr>
            <td>
	            <table cellspacing="1" cellpadding="3" border="0">
                    <tr>
                        <td class="tdlabel">Group Coordinator:</td>
                        <td><asp:Label runat="server" ID="groupagentname" /></td>
                    </tr>
                    <tr runat="server" id="trAffinityAgent">
                        <td class="tdlabel">Affinity Agent:</td>
                        <td><asp:Label runat="server" ID="affinityagentname" /></td>
                        <td align="left" class="tdlabel">&nbsp;&nbsp;&nbsp;&nbsp;Location:&nbsp;&nbsp;<asp:Label runat="server" ID="lblDepartment" ForeColor="Navy"></asp:Label></td>
                    </tr>
	            </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Button Text="Group Info" ToolTip="General Group information" BorderStyle="None" ID="tabGroupInfo" CssClass="grpTab" runat="server" OnClick="GroupInfo_Click" />
                <asp:Button Text="Revenue" ToolTip="Revenue details" BorderStyle="None" ID="tabRevenue" CssClass="grpTab" runat="server" OnClick="Revenue_Click" />
                <asp:Button Text="Notes" ToolTip="Notes" BorderStyle="None" ID="tabNotes" CssClass="grpTab" runat="server" OnClick="Notes_Click" />
                <asp:Button Text="File Maint" ToolTip="File Maintenance" BorderStyle="None" ID="tabFileMaint" CssClass="grpTab" runat="server" OnClick="FileMaint_Click" />
                <asp:Button Text="Pax List" ToolTip="Passenger List from Globalware" BorderStyle="None" ID="tabPaxList" CssClass="grpTab" runat="server" OnClick="PaxList_Click" />
                <asp:Button Text="Invoiced" ToolTip="Invoices from Globalware" BorderStyle="None" ID="tabInvoiced" CssClass="grpTab" runat="server" OnClick="Invoiced_Click" />
                <asp:Button Text="Rates & Inv" ToolTip="Rates & Inventory" BorderStyle="None" ID="tabRates" CssClass="grpTab" runat="server" OnClick="Rates_Click" />
                <%--<asp:Button Text="Files" ToolTip="Upload/Download Files" BorderStyle="None" ID="TabFiles" CssClass="grpTab" runat="server" OnClick="Files_Click" />--%>
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
			                                        <td class="tdlabel" width="100">Departs:</td>
			                                        <td><asp:Label id="departdate" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Returns:</td>
			                                        <td><asp:Label id="returndate" runat="server" /></td>
		                                        </tr>
                                                <tr>
                                                    <td class="tdlabel">Port City:</td>
                                                    <td><asp:Label runat="server" ID="portcity" /></td>
                                                </tr>
                                                <!-- 
                                                <tr>
                                                    <td class="tdlabel">1st Stop:</td>
                                                    <td><asp:Label runat="server" ID="destination" /></td>
                                                </tr> 
                                                -->
                                                <tr>
                                                    <td class="tdlabel">Itinerary:</td>
                                                    <td><asp:Label runat="server" ID="itinerary" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Ship Name:</td>
                                                    <td><asp:Label runat="server" ID="shipname" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Trip Theme:</td>
                                                    <td><asp:Label runat="server" ID="tourname" /></td>
                                                </tr>
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                            <asp:Panel ID ="pnlDates" runat="server" GroupingText=" Dates " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
		                                        <tr>
			                                        <td class="tdlabel" width="100">Recall 1:</td>
			                                        <td><asp:Label id="recall_1" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Recall 2:</td>
			                                        <td><asp:Label id="recall_2" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Recall 3:</td>
			                                        <td><asp:Label id="recall_3" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Hard Stop:</td>
			                                        <td><asp:Label id="hardstopdate" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Deposit 2:</td>
			                                        <td><asp:Label id="deposit_2" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Vendor Due:</td>
			                                        <td><asp:Label id="finaldue" runat="server" /></td>
		                                        </tr>
		                                        <tr>
			                                        <td class="tdlabel">Final Due:</td>
			                                        <td><asp:Label ID="finaldue2" runat="server" /></td>
		                                        </tr>
	                                        </table>
                                            </asp:Panel>
                                         </td>      
                                         <td width="5%">&nbsp;</td>
                                         <td width="45%">
                                         
                                         <asp:Panel ID ="pnlGroupInfo" runat="server" GroupingText=" Group Info " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
                                                <tr valign="top">
                                                    <td class="tdlabel">Group Name:</td>
                                                    <td><asp:Label runat="server" ID="groupname" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" width="100">Vendor:</td>
                                                    <td><asp:Label runat="server" ID="provider" /></td>
                                                </tr>
                                                 <tr id="trVendorGroupName" runat="server">
			                                        <td class="tdlabel">Vendor Group:</td>
			                                        <td><asp:Label id="lblVGroupCode" runat="server" /></td>
		                                        </tr>
                                                <tr>
			                                        <td class="tdlabel">Vendor Group #:</td>
			                                        <td><asp:Label id="providergroupid" runat="server" /></td>
		                                        </tr>
                                                 <tr>
			                                        <td class="tdlabel">2nd Vendor:</td>
			                                        <td><asp:Label id="lblVendorGroupCode2" runat="server" /></td>
		                                        </tr>
                                                <tr>
                                                    <td class="tdlabel">Travel Type:</td>
                                                    <td><asp:Label runat="server" ID="revtype" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Berths:</td>
			                                        <td><asp:Label id="berths" runat="server" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" runat="server" id="tdAffinityGroupName">Affinity Group:</td>
                                                    <td><asp:Label runat="server" ID="affinitygroupname" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel" runat="server" id="tdAffinityIATA">IATA Number:</td>
                                                    <td><asp:Label runat="server" ID="affinityIATA" /></td>
                                                </tr>
                                                <!--
                                                <tr>
                                                    <td class="tdlabel">Add. Details:</td>
                                                    <td><asp:Label runat="server" ID="adddetails" /></td>
                                                </tr>
                                                -->
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                            <asp:Panel ID ="pnlMisc" runat="server" GroupingText=" Misc. Info " Font-Bold="true"  Width="400px">
	                                        <table cellspacing="1" cellpadding="2" border="0">
                                                <tr>
                                                    <td width="100" class="tdlabel">Status:</td>
			                                        <td>
                                                        <asp:Label ID="status" runat="server" />
                                                        <asp:Label ID="canceldate" runat="server" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Air Included:</td>
                                                    <td><asp:Label  runat="server" ID="air_inc_desc" /></td>
                                                </tr>
	                                        </table>
                                            </asp:Panel>
                                            <br />
                                         </td>                              
                                    </tr>
                                    </table>

                                </td>
                            </tr>
                            <tr>
                                <td  align="center">
                                    <asp:button id="editgrp" runat="server" Text=" Edit " CssClass="button" Width="75px"></asp:button>&nbsp;
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
                                        <td width="175" align="center"><b>Finalized</b></td>
                                        <td width="175" align="center"><b>Closed</b></td>
                                        <td><b>Closing Notes</b></td>
                                    </tr>
                                    <tr>
                                        <td class="tdlabel">Sales:</td>
                                        <td><asp:Label ID="finalgrosssales" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedsales" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td rowspan="99" valign="top">
                                            <asp:Label ID="closednotes" runat="server" ></asp:Label>
                                        </td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Less Premium:</td>
                                        <td><asp:Label ID="disppremF" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="disppremC" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Actual Sales:</td>
                                        <td><asp:Label ID="dispsalesF" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="dispsalesC" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                     <tr>
                                        <td colspan="2">&nbsp;</td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Premium:</td>
                                        <td><asp:Label ID="premium" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="premium2" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Commission:</td>
                                        <td><asp:Label ID="finalcomm" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedcomm" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Bonus Commission:</td>
                                        <td><asp:Label ID="finalbonuscomm" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedbonuscomm" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Tour Conductor:</td>
                                        <td><asp:Label ID="finalnettourconductor" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedtourconductor" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Tour Con. Used:</td>
                                        <td><asp:Label ID="finaltourconused" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedtourconused" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Expense:</td>
                                        <td><asp:Label ID="finalgrossexpense" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedgrossexpense" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Total Revenue:</td>
                                        <td><asp:Label ID="disprevenueF" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="disprevenueC" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">% of Actual Sales:</td>
                                        <td><asp:Label ID="disppercF" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="disppercC" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
                                     <tr>
                                        <td colspan="2">&nbsp;</td>
                                     </tr>
                                    <tr>
                                        <td class="tdlabel">Passengers:</td>
                                        <td><asp:Label ID="finalpax" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                        <td><asp:Label ID="closedpax" runat="server" Width="100px" CssClass="numr"></asp:Label></td>
                                     </tr>
		                            <tr>
			                            <td class="tdlabel">Date:</td>
			                            <td><asp:Label id="date2accounting" runat="server" Width="100"  MaxLength="12"></asp:Label></td>
			                            <td><asp:Label id="dateclosed" runat="server" Width="100"  MaxLength="12"></asp:Label></td>
		                            </tr>
                                     </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center">
                                    <asp:button id="editrev" runat="server" Text=" Edit " CssClass="button" Width="75px"></asp:button>&nbsp;
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewNotes" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr>
                                <td>
                       				<asp:validationsummary id="ValidationAddNotes" ValidationGroup="AddNotes" runat="server" ForeColor="red" HeaderText="Please correct the following:" ShowMessageBox="true" ShowSummary="false" />
                                    <asp:GridView ID="NoteList" DataKeyNames="noteid" Width="850px"  runat="server" AutoGenerateColumns="False" CellPadding="3" PageSize="100" GridLines="Both" ShowFooter="True" 
                                        OnRowCreated="NoteList_RowCreated" OnRowCommand="NoteList_RowCommand" OnRowEditing="NoteList_RowEditing" DataSourceID="NoteDS" AllowSorting="false" AllowPaging="false">
                                        <FooterStyle CssClass="listhdr" /> 
                                        <RowStyle  VerticalAlign="Top" />
                                        <AlternatingRowStyle ForeColor="GrayText"/>
                                        <Columns>
                                            <asp:BoundField DataField="NoteiD" Visible="false" />
                                            <asp:TemplateField HeaderText="Date" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="100px" HeaderStyle-Font-Bold="true" ItemStyle-ForeColor="Navy">
                                                <ItemTemplate><%# Eval("NoteDate", "{0:d}") %></ItemTemplate> 
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Notes" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="650px" HeaderStyle-Font-Bold="true" ItemStyle-Font-Italic="true">
                                                <ItemTemplate>
                                                    <asp:Label ID="notes" runat="server" Text='<%# Eval("notes") %>' />
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <telerik:RadTextBox ID="rdnotes" runat="server" Width="600px" TextMode="MultiLine" RenderMode="Lightweight" BackColor="LightYellow" Text='<%# Eval("notes") %>' ></telerik:RadTextBox>
                                                </EditItemTemplate>
                                                <FooterTemplate>
                                                    <%--<asp:TextBox ID="notes" runat="server" Width="575px" /> --%>
                                                     <telerik:RadTextBox ID="notes" runat="server" Width="575px" TextMode="MultiLine" RenderMode="Lightweight"></telerik:RadTextBox>
                                                    <asp:RequiredFieldValidator id="valnotes" ValidationGroup="AddNotes" runat="server" CssClass="error" ErrorMessage="Notes are required" ControlToValidate="notes" Display="Dynamic">*</asp:RequiredFieldValidator>
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="By" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="100px" HeaderStyle-Font-Bold="true" ItemStyle-ForeColor="Navy">
                                                <ItemTemplate><%# Eval("noteby") %></ItemTemplate> 
                                            </asp:TemplateField>
                                            <asp:TemplateField ShowHeader="false" HeaderStyle-Width="250px" ItemStyle-Width="250px">
                                                <EditItemTemplate>
                                                    <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="True" CommandName="Update"
                                                        Text="Update" ValidationGroup="EditSectionsGroup" CommandArgument='<%# Container.DataItemIndex %>'>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel"
                                                        Text="Cancel"></asp:LinkButton>
                                                </EditItemTemplate>
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit"
                                                        Text="Edit"></asp:LinkButton>
                                                   <%-- <asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Select"
                                                        Text="Select"></asp:LinkButton>--%>
                                                    <asp:LinkButton ID="LinkButton3" runat="server" CausesValidation="False" CommandName="Delete"
                                                        Text="Delete"  CommandArgument='<%# Container.DataItemIndex %>'></asp:LinkButton>
                                                </ItemTemplate>
                                                <FooterTemplate>
                                                    <asp:LinkButton ID="LnkSave" ValidationGroup="AddNotes" runat="server" CausesValidation="true" CommandName="Save" Text="Save" />
                                                </FooterTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:ObjectDataSource ID="NoteDS" runat="server" TypeName="GM.GroupMaster" OnSelected="NoteDS_Selected" SelectMethod="GetNotesList" InsertMethod="AddNotes" UpdateMethod="UpdateNotes" DeleteMethod="DeleteNotes">
                                        <SelectParameters>
                                            <asp:Parameter Name="groupid" Type="String" />
                                        </SelectParameters>
                                        <InsertParameters>
                                            <asp:Parameter Name="notes" Type="String" />
                                        </InsertParameters>
                                        <UpdateParameters> 
                                            <asp:Parameter Name="groupID" Type="String" />
                                            <asp:Parameter Name="notes" Type="String" />
                                            <asp:Parameter Name="noteID" Type="Int32" />
                                        </UpdateParameters>
                                        <DeleteParameters>
                                            <asp:Parameter Name="noteid" Type="Int32" />
                                            <asp:Parameter Name="groupID" Type="String" />
                                        </DeleteParameters>
                                    </asp:ObjectDataSource>
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewFileMaintInfo" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr valign="top">
                                <td>
                      				<asp:validationsummary id="Validationsummary2" ValidationGroup="EditTask" runat="server" ForeColor="red" HeaderText="Please correct the following:" ShowMessageBox="true" ShowSummary="false" />
                                    <table cellpadding="5" width="850" cellspacing="0">
                                    <tr valign="top">
                                         <td width="55%">
                                            <asp:GridView ID="TaskList" DataKeyNames="GroupID, TaskID" Width="500px" CssClass="list" runat="server" AutoGenerateColumns="False" CellPadding="3" PageSize="100" GridLines="Horizontal" ShowFooter="False" 
                                                DataSourceID="TaskDS" AllowSorting="false" AllowPaging="false" ShowHeader="true" Enabled="true">
                                                <HeaderStyle CssClass="listhdr" /> 
                                                <AlternatingRowStyle BackColor="LightYellow" />
                                                <Columns>
                                                    <asp:TemplateField HeaderText="Task" HeaderStyle-HorizontalAlign="Left"  HeaderStyle-Width="275px">
                                                        <ItemTemplate><%# Eval("task") %></ItemTemplate> 
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Date Completed" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="100px" >
                                                        <ItemTemplate><%# Eval("datecomplete", "{0:d}") %></ItemTemplate> 
                                                        <EditItemTemplate>
                                                            <%--<asp:TextBox ID="datecomplete" runat="server" Width="75px" Text='<%# Bind("datecomplete", "{0:d}") %>' />--%>
                                                            <telerik:RadDatePicker RenderMode="Lightweight" ID="datecomplete" width="100px" runat="server" MinDate="1901/1/1" DbSelectedDate='<%# Bind("datecomplete") %>'>
                                                                <Calendar ShowRowHeaders="false"></Calendar>
                                                            </telerik:RadDatePicker>
                                                            <asp:CompareValidator id="valdatecomplete" ValidationGroup="EditTask" runat="server" CssClass="error" ErrorMessage="Date completed is invalid" ControlToValidate="datecomplete" Type="Date" Operator="DataTypeCheck" Display="Dynamic">*</asp:CompareValidator>
                                                        </EditItemTemplate>
                                                        
                                                    </asp:TemplateField>
                                                    <asp:TemplateField HeaderText="Updated By" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="75px">
                                                        <ItemTemplate><%# Eval("completeby") %></ItemTemplate> 
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ShowHeader="False" HeaderStyle-Width="30px" >
                                                        <EditItemTemplate>
                                                            <asp:LinkButton ID="LnkUpdate" runat="server" ValidationGroup="EditTask" CausesValidation="true" CommandName="Update" Text="Save" />
                                                        </EditItemTemplate>
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="LnkEdit" runat="server" CausesValidation="False" CommandName="Edit" Text="Edit" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:TemplateField ShowHeader="False" HeaderStyle-Width="30px" >
                                                        <EditItemTemplate>
                                                            <asp:LinkButton ID="LnkCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                                                        </EditItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    Task - Select Task Type to display task list.
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                            <asp:ObjectDataSource ID="TaskDS" runat="server" TypeName="GM.GroupMaster" SelectMethod="GetTaskList" UpdateMethod="UpdateTask">
                                                <SelectParameters>
                                                    <asp:Parameter Name="groupid" Type="String" />
                                                    <asp:ControlParameter name="tasktype" ControlID="TaskType" Type="Int32" />
                                                </SelectParameters>
                                                <UpdateParameters>
                                                    <asp:Parameter Name="groupid" Type="Object" />
                                                    <asp:Parameter Name="taskid" Type="Object" />
                                                    <asp:Parameter Name="datecomplete" Type="String" />
                                                </UpdateParameters>
                                            </asp:ObjectDataSource>
                                         </td>      
                                         <td width="5%">&nbsp;</td>
                                         <td width="40%">
                                         
                                         <asp:Panel ID ="pnlTaskType" runat="server" GroupingText=" Task Type " Font-Bold="true" width="350px" Enabled="true">
	                                        <table cellspacing="1" cellpadding="2" border="0">
                                                <tr>
                                                    <td class="tdlabel" width="250">
							                            <asp:RadioButtonList ID="TaskType" DataValueField="code" DataTextField="desc" runat="server" AutoPostBack="True" 
                                                            onselectedindexchanged="TaskType_SelectedIndexChanged" />
							                        </td>
                                                    <td align="right"> 
                                                        <asp:Button ID="CreateFileMaint" runat="server" 
                                                            Text="Create File&#010;Maintenance&#010;Check List" Height="75px" Width="125px" 
                                                            CausesValidation="false" onclick="CreateFileMaint_Click"></asp:Button>
							                        </td>
                                                </tr>
	                                        </table>
                                            </asp:Panel>
                                            <br /><br />
                                            <asp:Panel ID ="pnlCxlPolicy" runat="server" GroupingText=" Cancellation Policy " Font-Bold="true" width="350px" Enabled="true" >
	                                        <table cellspacing="1" cellpadding="2" border="0">
                                                <tr>
                                                    <td><br />
                                                <asp:DropDownList ID="cxlpolicyid" runat="server" Width="300px" 
                                                    AutoPostBack="true" onselectedindexchanged="cxlpolicyid_SelectedIndexChanged" /><br /><br />
                                                    <asp:Repeater ID="policyList" runat="server">
                                                        <HeaderTemplate>
                                                            <table cellpadding="3" cellspacing="0" border="0" width="100%">
                                                                <tr>
                                                                    <td><b>Days Prior</b></td>
                                                                    <td><b>Cust. Loss</b></td>
                                                                    <td><b>Date Range</b></td>
                                                                </tr>
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <tr valign="top">
                                                                <td><%# Eval("daysPrior") %></td>                                        
                                                                <td><%# Eval("custLoss") %></td>                                        
                                                                <td><%# Eval("dateRange") %></td>                                        
                                                            </tr>
                                                        </ItemTemplate>
                                                        <FooterTemplate>
                                                            </table>
                                                        </FooterTemplate>
                                                    </asp:Repeater>
                                                </td>
                                                </tr>
                                                </table>
                                            </asp:Panel>
                                            <br />
                                         </td>                              
                                    </tr>
                                    </table>

                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
		                    <tr>
			                    <td colspan="3" align="center">
			                    </td>
		                    </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewPaxList" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr>
                                <td>
                                    <table cellpadding=0 cellspacing=0>
                                    <tr valign="top">
                                    <td>
                                    <asp:Repeater ID="listPax" runat="server">
                                    <HeaderTemplate>
                                        <table cellpadding="3" cellspacing="0" border="0" width="650px">
                                            <tr>
                                                <td><b>Party ID</b></td>
                                                <td><b>Traveler</b></td>
                                                <td><b>Statement Name</b></td>
                                                <td><b>Phone</b></td>
                                                <td><b>Status</b></td>
                                            </tr>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr>
                                            <td><%# Eval("PartyID") %></td>                                        
                                            <td><%# Eval("Traveler") %></td>                                        
                                            <td><%# Eval("StatementName") %></td>                                        
                                            <td><%# Eval("Phone") %></td>                                        
                                            <td><%# Eval("StatusDesc") %></td>                                        
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                    </table>
                                    </FooterTemplate>

                                    </asp:Repeater>
                                    </td>   
                                    <td width="25">&nbsp;</td>                                 
                                    <td>
                                       <asp:Panel ID ="Panel1" runat="server" GroupingText=" Active Counts " Font-Bold="true"  Width="175px">
                                        <table cellspacing="1" cellpadding="4" border="0">
                                                <tr>
                                                    <td class="tdlabel" width="100">Passengers:</td>
			                                        <td><asp:Label ID="activepax" runat="server" CssClass="numr" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Party IDs:</td>
			                                        <td><asp:Label ID="activeparty" runat="server" CssClass="numr" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Phone #'s:</td>
			                                        <td><asp:Label ID="activephone" runat="server" CssClass="numr" /></td>
                                                </tr>
	                                        </table>
                                        </asp:Panel>
                                    </td>
                                    </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewInvoiced" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr>
                                <td>
                                    <table cellpadding=0 cellspacing=0>
                                    <tr valign="top">
                                    <td>
                                    <asp:Repeater ID="listInvoiced" runat="server">
                                    <HeaderTemplate>
                                        <table cellpadding="3" cellspacing="0" border="0" width="650px">
                                            <tr>
                                                <td><b>Party ID</b></td>
                                                <td><b>Invoiced #</b></td>
                                                <td><b>Invoice Date</b></td>
                                                <td><b>Traveler</b></td>
                                                <td><b>Invoiced</b></td>
                                            </tr>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr>
                                            <td><%# Eval("PartyID") %></td>                                        
                                            <td><%# Eval("InvoiceNumber") %></td>                                        
                                            <td><%# Eval("InvoiceDate", "{0:d}") %></td>                                        
                                            <td><%# Eval("Traveler") %></td>                                        
                                            <td><%# Eval("TotalCost","{0:c}") %></td>                                        
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                    </table>
                                    </FooterTemplate>
                                    </asp:Repeater>
                                    </td>   
                                    <td width="25">&nbsp;</td>                                 
                                    <td>
                                       <asp:Panel ID ="pnlInvAcitvity" runat="server" GroupingText=" Activity To Date " Font-Bold="true"  Width="175px">
                                        <table cellspacing="1" cellpadding="4" border="0">
                                                <tr>
                                                    <td class="tdlabel" width="75">Invoiced:</td>
			                                        <td><asp:Label ID="totalinvoiced" runat="server" CssClass="numr" /></td>
                                                </tr>
                                                <tr>
                                                    <td class="tdlabel">Booked:</td>
			                                        <td><asp:Label ID="totalbooked" runat="server" CssClass="numr" /></td>
                                                </tr>
	                                        </table>
                                        </asp:Panel>
                                    </td>
                                    </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewRateInfo" runat="server">
                        <table style="width: 100%; border-width: 1px; border-color: #666; border-style: solid">
                            <tr valign="top">
                                <td>
                                    <table cellpadding="5" cellspacing="0">
				                       <tr valign="top">
					                   <td colspan="1">
                                            <table class="list">
                                                <tr class="listhdr">
                                                    <td width="25"></td>
                                                    <td align="center">Sell Over Allocated?</td>
                                                    <td align="center">Min. Passengers</td>
                                                    <td align="center">Max. Passengers</td>
                                                </tr>
                                                <tr>
                                                    <td width="25"><asp:HyperLink id="aGroupInvEdit" runat="server" Text="Edit"/></td>
                                                    <%--<td width="25"><a href="GroupInvEdit.aspx?groupid=<%=groupid%>">Edit</a> </td>--%>
                                                    <td align="center"><asp:Label runat="server" ID="isselloveralloc" /></td>
                                                    <td align="center"><asp:Label runat="server" ID="minpassengers" /></td>
                                                    <td align="center"><asp:Label runat="server" ID="maxpassengers" /></td>
                                                </tr>
                                            </table>
                                            <br />
                                          </td>
                                        </tr>
				                        <tr valign="top">
					                    <td colspan="3">
                                           <%-- <b>Packages</b>&nbsp;&nbsp;<a href="GroupPackageEdit.aspx?groupid=<%=groupid%>">[ Add ]</a><br />--%>
                                            <b>Packages</b>&nbsp;&nbsp;<asp:HyperLink id="aGroupPackageEdit" runat="server" Text="[ Add ]"/><br />   
                                            <asp:GridView ID="PackageList" DataKeyNames="GroupID, PackageID" Width="850px" CssClass="list" runat="server" AutoGenerateColumns="False" CellPadding="3" PageSize="100" GridLines="Horizontal" ShowFooter="False" 
                                                DataSourceID="PackageDS" AllowSorting="false" AllowPaging="false" ShowHeader="true">
                                                <HeaderStyle CssClass="listhdr" VerticalAlign="Bottom" /> 
                                                <Columns>
	                                                <asp:HyperLinkField Text="Edit" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="25px" DataNavigateUrlFormatString="GroupPackageEdit.aspx?packageid={0}&groupid={1}" DataNavigateUrlFields="packageid,groupid" />  
                                                    <asp:TemplateField ShowHeader="False" HeaderStyle-Width="25px" >
                                                        <ItemTemplate>
                                                            <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure you would like to delete this row?');" Text="Del" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
            						                <asp:BoundField DataField="packagetypename" HeaderText="Type" HeaderStyle-HorizontalAlign="Left" />
            						                <asp:BoundField DataField="packagecd" HeaderText="Code" HeaderStyle-HorizontalAlign="Left" />
            						                <asp:BoundField DataField="packagename" HeaderText="Package Name" HeaderStyle-HorizontalAlign="Left" />
            						                <asp:BoundField DataField="singlerate" HeaderText="Single" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                <asp:BoundField DataField="doublerate" HeaderText="Double" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                <asp:BoundField DataField="triplerate" HeaderText="Triple" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                <asp:BoundField DataField="quadrate" HeaderText="Quad" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                <asp:BoundField DataField="singlecomm" HeaderText="Sng<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
            						                <asp:BoundField DataField="doublecomm" HeaderText="Dbl<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
                                                    <asp:BoundField DataField="triplecomm" HeaderText="Tri<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
                                                    <asp:BoundField DataField="quadcomm" HeaderText="Quad<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
            						                <asp:BoundField DataField="quantity" HeaderText="Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                <asp:BoundField DataField="allocated" HeaderText="Allocated" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                <asp:BoundField DataField="sold" HeaderText="Sold" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                <asp:BoundField DataField="avail" HeaderText="Avail" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                <asp:BoundField DataField="soldpax" HeaderText="Bkd<br>Pax" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" HtmlEncode="false" />
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    Click "Add" above to a Package option
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                            <asp:ObjectDataSource ID="PackageDS" runat="server" TypeName="GM.GroupPackage" 
                                                 SelectMethod="GetList" DeleteMethod="Delete" ondeleted="PackageDS_Deleted">
                                                <SelectParameters>
                                                    <asp:Parameter Name="groupid" Type="String" />
                                                </SelectParameters>
                                                <DeleteParameters>
                                                    <asp:Parameter Name="groupid" Type="Object" />
                                                    <asp:Parameter Name="packageid" Type="Object" />
                                                </DeleteParameters>
                                            </asp:ObjectDataSource>
                                            <br />
					                </td>
				                   </tr>	
                                    <tr valign="top">
                                         <td width="55%">
                                                <%--<b>Options</b>&nbsp;&nbsp;<a href="GroupOptionEdit.aspx?groupid=<%=groupid%>">[ Edit ]</a><br />--%>
                                              <b>Options</b>&nbsp;&nbsp;<asp:HyperLink id="aGroupOptionEdit" runat="server" Text="[ Add ]"/><br />
                                                <asp:GridView ID="OptionList" DataKeyNames="GroupID, OptionID" Width="500px" CssClass="list" runat="server" AutoGenerateColumns="False" CellPadding="3" PageSize="100" GridLines="Horizontal" ShowFooter="False" 
                                                    DataSourceID="OptionDS" AllowSorting="false" AllowPaging="false" ShowHeader="true">
                                                    <HeaderStyle CssClass="listhdr" /> 
                                                    <Columns>
                                                        <asp:HyperLinkField Text="Edit" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="25px" DataNavigateUrlFormatString="GroupOptionInvControl.aspx?optionid={0}&groupid={1}" DataNavigateUrlFields="optionid,groupid" />  
                                                        <asp:TemplateField ShowHeader="False" HeaderStyle-Width="25px" >
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure you would like to delete this row?');" Text="Del" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
            						                    <asp:BoundField DataField="optionname" HeaderText="Option Name" HeaderStyle-HorizontalAlign="Left" />
                                                        <asp:BoundField DataField="optioncode" HeaderText="Code" HeaderStyle-HorizontalAlign="Left" />
                                                        <asp:BoundField DataField="optiontype" HeaderText="Type" HeaderStyle-HorizontalAlign="Left" />
                                                        <asp:BoundField DataField="singlerate" HeaderText="Single" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                    <asp:BoundField DataField="doublerate" HeaderText="Double" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                    <asp:BoundField DataField="triplerate" HeaderText="Triple" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                    <asp:BoundField DataField="quadrate" HeaderText="Quad" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" />
            						                    <asp:BoundField DataField="singlecomm" HeaderText="Sng<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
            						                    <asp:BoundField DataField="doublecomm" HeaderText="Dbl<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
                                                        <asp:BoundField DataField="triplecomm" HeaderText="Tri<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
                                                        <asp:BoundField DataField="quadcomm" HeaderText="Quad<br>Comm" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" DataFormatString="{0:c}" HtmlEncode="false" />
                                                        <asp:BoundField DataField="quantity" HeaderText="Qty" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                    <asp:BoundField DataField="allocated" HeaderText="Allocated" HeaderStyle-HorizontalAlign="Right" ItemStyle-HorizontalAlign="Right" />
            						                    <asp:CheckBoxField DataField="isrequired" HeaderText="Required?" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                    <EmptyDataTemplate>
                                                        Click "Add" above to add options
                                                    </EmptyDataTemplate>
                                                </asp:GridView>
                                                <asp:ObjectDataSource ID="OptionDS" runat="server" TypeName="GM.GroupOption" 
                                                     SelectMethod="GetList" DeleteMethod="Delete" ondeleted="OptionDS_Deleted">
                                                    <SelectParameters>
                                                        <asp:Parameter Name="groupid" Type="String" />
                                                    </SelectParameters>
                                                    <DeleteParameters>
                                                        <asp:Parameter Name="groupid" Type="Object" />
                                                        <asp:Parameter Name="optionid" Type="Object" />
                                                    </DeleteParameters>
                                                </asp:ObjectDataSource>
                                             </td>      
                                             <td width="5%">&nbsp;</td>
                                             <td width="40%">
                                                &nbsp;
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

    </table>


</asp:Content> 