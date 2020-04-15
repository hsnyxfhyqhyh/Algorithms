<%@ Page language="c#" MasterPageFile="MasterPage.master"  %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="Telerik.Web.UI" %>
<%@ Register Assembly="CKEditor.NET" Namespace="CKEditor.NET" TagPrefix="CKEditor" %>

<script language="C#" runat="server">

    const int idxGroupInfo = 0;
    const int idxItinerary = 1;
    const int idxCategory = 2;
    const int idxCancPolicy = 3;
    const int idxDisclaimer = 4;
    const int idxInstruction = 5;

    string groupCode
    {
        get { return ViewState["groupcode"].ToString(); }
        set { ViewState["groupcode"] = value; }
    }
    string packageType
    {
        get { return ViewState["packagetype"].ToString(); }
        set { ViewState["packagetype"] = value; }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            //rdpFrom.SelectedDate =  DateTime.Now;
            //rdpTo.SelectedDate =  DateTime.Now.AddDays(1);

            ddlInstructionType.DataSource = GroupMaster.GetInstructionSort("Contact Instructions");
            ddlInstructionType.DataBind();
            ddlInstructionType.Items.Insert(0, new ListItem ("", ""));

            ddlInstructionIATA.DataSource = GroupMaster.GetInstructionSort("IATA Instructions");
            ddlInstructionIATA.DataBind();
            ddlInstructionIATA.Items.Insert(0, new ListItem ("", ""));

            Page.Form.Attributes.Add("enctype", "multipart/form-data");
            groupCode = Request.QueryString["groupcode"] + "";
            message.InnerHtml = Request.QueryString["msg"];
            mtGroup g = mtGroup.GetGroup(groupCode);
            if (g == null)
                Response.Redirect("mtGroupList.aspx?msg=Group Flyer not found");
            packageType = g.PackageType;

            // Header
            typedescription.Text = g.TypeDescription;
            currtemplate.Text = g.TemplateTitle;
            status.Text = g.StatusDescription;

            // Group Info Tab
            if (g.DepartureDate != null && g.DepartureDate != "")
            {
                //departuredate.Text = g.DepartureDate;
                departuredate.SelectedDate = Convert.ToDateTime(g.DepartureDate);
            }

            if (g.ReturnDate != null && g.ReturnDate != "")
            {
                //returndate.Text = g.ReturnDate;
                returndate.SelectedDate = Convert.ToDateTime(g.ReturnDate);
            }

            //Vendor Name DDL
            //vendorname.DataSource = mtVendor.GetListVcode(g.VGroupCode);
            vendorname.DataSource = mtVendor.GeVendor();
            vendorname.DataBind();
            vendorname.SelectedValue = g.VendorGroupCode;

            //Vendor Group Code DDL
            VgroupCode.DataSource = mtVendor.GetVGroupCode();
            VgroupCode.DataBind();
            VgroupCode.SelectedValue = g.VGroupCode;

            //Secondary Vendor Code
            //ddlSecondVendorCode.DataSource = mtVendor.GetSecondaryVendorCode(g.VGroupCode);
            ddlSecondVendorCode.DataSource = mtVendor.GeVendor();
            ddlSecondVendorCode.DataBind();
            ddlSecondVendorCode.SelectedValue = g.VendorGroupCode2;

            vendorgroupcode.Text = g.VendorGroupCode;

            //shipname.DataSource = mtShip.GetList();
            shipname.DataSource = mtShip.GetListByVendor(g.VendorGroupCode);
            shipname.DataBind();

            ////shipname.DataSource = mtShip.GetList();
            ////shipname.DataBind();

            RadComboBoxItem RCBitem = new RadComboBoxItem();
            RCBitem =  shipname.FindItemByText(g.ShipName);
            //item1.Value = g.ShipName;
            if (RCBitem != null)
            {
                RCBitem.Selected = true;
            }
            
            //shipname.SelectedValue = g.ShipName;
            //shipname.FindItemByText(g.ShipName);

            agentname.Text = g.AgentName;
            heading.Text = g.Heading;

            vendorgroupnumber.Text = g.VendorGroupNumber;
            regiondescription.Text = g.RegionDescription;
            departurepointname.Text = g.DeparturePointName;

            affinity.Checked = g.Affinity;
            specialitygroup.Checked = g.SpecialtyGroup;
            donotdisplay.Checked = g.DoNotDisplay;

            chkUseDate.Checked = g.useDateRange;
            if (g.dateFrom != null)
            {
                rdpFrom.SelectedDate = g.dateFrom;
            }
            else
            {
                rdpFrom.SelectedDate = DateTime.Now;
            }

            if (g.dateTo != null)
            {
                rdpTo.SelectedDate = g.dateTo;
            }
            else
            {
                rdpTo.SelectedDate = DateTime.Now;
            }

            description.Value = g.Description.ToString();
            descriptiontitle.Text = g.DescriptionTitle;
            vendorcode.Value = g.VendorCode;
            vendorname.SelectedText = g.VendorName;

            string sCode = g.VendorGroupCode;
            if (sCode == "EXPTUR")
            {
                trVengorGroupCode.Visible = true;
                //VgroupCode.ClearSelection();
            }
            else
            {
                trVengorGroupCode.Visible = false;
            }

            //vendorname.Text = g.VendorName;
            Lookup.FillDropDown(template, mtPickList.GetTemplate(), g.Template, "");
            template_SelectedIndexChanged(this, EventArgs.Empty);
            if (g.SellingTip != "")
                lblsellingtip.Text = string.Format("<a href=\"tipsFiles/{0}\" target=\"tips\">[...]</a>", g.SellingTip);
            if (g.PrintVersion != "")
                lblprintversion.Text = string.Format("<a href=\"printFiles/{0}\" target=\"print\">[...]</a>", g.PrintVersion);
            trShip.Visible = (g.PackageType != "T") ? true : false;
            trDeparturePoint.Visible = (g.PackageType != "T") ? true : false;

            // Itinerary Tab
            itinerarylist.DataSource = mtGroup.GetItinerary(groupCode, true);
            itinerarylist.DataBind();

            // Category Tab -- Fees & Rates
            string sCurrncy = (g.DepositAmount.IndexOf("%") == -1) ? "$" : "%";
            categorylist.DataSource = mtGroup.GetCategory(groupCode, true);
            categorylist.DataBind();
            startingrates.Text = g.StartingRates.ToString("###.00");
            doublerate.Text = g.DoubleRate.ToString("###.00");
            singlerate.Text = g.SingleRate.ToString("###.00");
            triplerate.Text = g.TripleRate.ToString("###.00");
            quadrate.Text = g.QuadRate.ToString("###.00");

            commissionsngA.Text = g.commissionSng.ToString("###.00");
            commissiondblA.Text = g.commissionDbl.ToString("###.00");
            commissionTRPL.Text = g.commissionTRPL.ToString("###.00");
            commissionQUAD.Text = g.commissionQUAD.ToString("###.00");

            hiderates.Checked = g.HideRates;
            trplquadrate.Text = g.TrplQuadRate.ToString("###.##");
            trplquadcomments.Text = g.TrplQuadComments;
            portcharges.Text = g.PortCharges.ToString("###.##");
            govtfees.Text = g.GovtFees.ToString("###.##");
            taxes.Text = g.Taxes.ToString("###.##");
            miscellaneous.Text = g.Miscellaneous.ToString("###.##");
            misccomments.Text = g.MiscComments;
            depositamount.Text = g.DepositAmount.Replace("$", "").Replace("%", "").Trim();
            finalpmtdate.Text = g.FinalPmtDate;
            firstdepositdate.Text = g.FirstDepositDate;

            seconddepositdate.Text = g.SecondDepositDate;
            recalldate.Text = g.RecallDate;
            Lookup.FillRadioList(trplquad, mtPickList.GetYesNo(), g.TrplQuad);
            Lookup.FillRadioList(portchargesincluded, mtPickList.GetYesNo(), g.PortChargesIncluded);
            Lookup.FillRadioList(govtfeesincluded, mtPickList.GetYesNo(), g.GovtFeesIncluded);
            Lookup.FillRadioList(taxesincluded, mtPickList.GetYesNo(), g.TaxesIncluded);
            Lookup.FillRadioList(miscincluded, mtPickList.GetYesNo(), g.MiscIncluded);
            Lookup.FillDropDown(depunit, mtPickList.GetDepUnit(), g.DepUnit.ToString(), "");

            Lookup.FillDropDown(currncy, mtPickList.GetCurrencyPerc(), sCurrncy, "");
            trDoubleRate.Visible = (g.PackageType == "T") ? true : false;
            trSingleRate.Visible = (g.PackageType == "T") ? true : false;
            trTripleRate.Visible = (g.PackageType == "T") ? true : false;
            trQuadRate.Visible = (g.PackageType == "T") ? true : false;
            //trHideRates.Visible = (g.PackageType != "T") ? true : false;
            trHideRates.Visible = true;
            categorylist.Visible = (g.PackageType != "T") ? true : false;
            trTrplQuadRate.Visible = (g.PackageType != "T") ? true : false;
            trPortCharges.Visible = (g.PackageType != "T") ? true : false;

            // Canc. policy Tab
            processdepositother.Text = g.ProcessDepositOther;
            processpaymentother.Text = g.ProcessPaymentOther;
            cancpolicylist.DataSource = mtGroup.GetCancelPolicy(groupCode, true);
            cancpolicylist.DataBind();
            processdeposit.DataSource = mtPickList.GetProcessing();
            processdeposit.DataBind();
            foreach (ListItem li in processdeposit.Items)
                li.Selected = (g.ProcessDeposit.IndexOf(li.Value) == -1) ? false : true;
            processpayment.DataSource = mtPickList.GetProcessing();
            processpayment.DataBind();
            foreach (ListItem li in processpayment.Items)
                li.Selected = (g.ProcessPayment.IndexOf(li.Value) == -1) ? false : true;

            // Disclaimer Tab
            Lookup.FillRadioList(specialfeatures, mtPickList.GetYesNo(), g.SpecialFeatures);
            Lookup.FillRadioList(customair, mtPickList.GetYesNo(), g.CustomAir);
            Lookup.FillRadioList(pre, mtPickList.GetYesNo(), g.Pre);
            Lookup.FillRadioList(post, mtPickList.GetYesNo(), g.Post);
            Lookup.FillRadioList(agentnotes, mtPickList.GetYesNo(), g.AgentNotes);
            additionalnotes.Text = g.AdditionalNotes;
            suggestcustomair.Text = g.SuggestCustomAir;
            travelinsurance.Text = g.TravelInsurance;
            disclaimer.Text = g.Disclaimer;
            flyerdisclaimer.Text = g.FlyerDisclaimer;
            calltoaction.Text = g.CallToAction;
            customairamount.Text = g.CustomAirAmount.ToString("###.##");
            preamount.Text = g.PreAmount.ToString("###.##");
            postamount.Text = g.PostAmount.ToString("###.##");
            requiredpass.DataSource = mtPickList.GetRequiredPass();
            requiredpass.DataBind();
            foreach (ListItem li in requiredpass.Items)
                li.Selected = (g.RequiredPass.IndexOf(li.Value) == -1) ? false : true;
            if (g.Script331 == "on")
                script331.Checked = true;
            docreq.DataSource = mtPickList.GetDocReq();
            docreq.DataBind();
            foreach (ListItem li in docreq.Items)
                li.Selected = (g.DocReq.IndexOf(li.Value) == -1) ? false : true;
            visa.Text = g.Visa;
            innoculation.Text = g.Innoculation;
            docother.Text = g.DocOther;
            trCustomAir.Visible = (g.PackageType != "T" && g.PackageType != "CT") ? true : false;
            trSuggCustomAir.Visible = (g.PackageType != "T" && g.PackageType != "CT") ? true : false;

            // Instruction Tab
            string sTransferOption = (g.TransfersCost.IndexOf("One-Way") != -1) ? "One-Way" : ((g.TransfersCost.IndexOf("Roundtrip") != -1) ? "Roundtrip" : "");
            Lookup.FillRadioList(motorcoach, mtPickList.GetYesNo(), g.MotorCoach);

            //Lookup.FillRadioList(contactinstr, mtPickList.GetContactInstr(g.VendorGroupNumber), g.ContactInstr);

            lblContactInstruction.Text = g.ContactInstr;

            //Lookup.FillRadioList(iatainstr, mtPickList.GetIATAInstr(), g.IATAInstr);

            lblReferenceIATA.Text = g.IATAInstr;

            Lookup.FillRadioList(phoneinstr, mtPickList.GetPhoneInstr(), g.PhoneInstr);
            addlinstr.DataSource = mtPickList.GetAddlInstr();
            addlinstr.DataBind();
            foreach (ListItem li in addlinstr.Items)
                li.Selected = (g.AddlInstr.IndexOf(li.Value) == -1) ? false : true;
            contactinstrother.Text = g.ContactInstrOther;
            iatainstrother.Text = g.IATAInstrOther;
            phoneinstrother.Text = g.PhoneInstrOther;
            addlinstrother.Text = g.AddlInstrOther;
            Lookup.FillRadioList(addair, mtPickList.GetYesNo(), g.AddAir);
            Lookup.FillRadioList(transfersincluded, mtPickList.GetYesNo(), g.TransfersIncluded);
            Lookup.FillDropDown(transferoption, mtPickList.GetTransferOption(), sTransferOption, " ");
            transferscost.Text = g.TransfersCost.Replace("One-Way", "").Replace("Roundtrip", "").Trim();

            //
            GroupInfo_Click(this, EventArgs.Empty);
            hdr.InnerHtml = string.Format("Group # {0} - {1}", g.GroupCode, g.TypeDescription);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='mtGroupList.aspx';return false;", groupCode);
            back.Attributes["onclick"] = string.Format("javascript:window.location.href='mtGroupList.aspx';return false;", groupCode);
            flyer.Attributes["onclick"] = string.Format("javascript:popupFlyer('Flyer.aspx?groupcode={0}&overrideDisplay=Y');return false;", groupCode);
            agentflyer.Attributes["onclick"] = string.Format("javascript:popupFlyer('AgentFlyer.aspx?groupcode={0}');return false;", groupCode);

            bannertitle_top.Attributes.Add("readonly", "readonly");
            bannertitle_center.Attributes.Add("readonly", "readonly");
            bannertitle_bottom.Attributes.Add("readonly", "readonly");
            descriptiontitle.Attributes.Add("readonly", "readonly");
            vendorname.Attributes.Add("readonly", "readonly");
            if (!Security.IsAdmin() && (g.Status == "Approved" || g.Status == "Rejected"))
                save.Enabled = false;

        }
        shipname.Filter = RadComboBoxFilter.StartsWith;
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";

        // Validate & Build Basic Tab
        string sSellingTip = "";
        string sPrintVersion = "";
        List<mtGroupBanner> listBanner = new List<mtGroupBanner>();
        if (bannerid_top.Value != "")
            listBanner.Add(new mtGroupBanner(Convert.ToInt32(bannerid_top.Value), "Top"));
        if (bannerid_center.Value != "")
            listBanner.Add(new mtGroupBanner(Convert.ToInt32(bannerid_center.Value), "Center"));
        if (bannerid_bottom.Value != "")
            listBanner.Add(new mtGroupBanner(Convert.ToInt32(bannerid_bottom.Value), "Bottom"));
        if (sellingtip.HasFile && sellingtip.PostedFile.ContentLength > 0)
        {
            sSellingTip = groupCode + "_"+ Path.GetFileName(sellingtip.PostedFile.FileName);
            sellingtip.PostedFile.SaveAs(HttpContext.Current.Server.MapPath("~/tipsFiles/") + sSellingTip);
        }
        if (printversion.HasFile && printversion.PostedFile.ContentLength > 0)
        {
            sPrintVersion = groupCode + "_" + Path.GetFileName(printversion.PostedFile.FileName);
            printversion.PostedFile.SaveAs(HttpContext.Current.Server.MapPath("~/printFiles/") + sPrintVersion);
        }


        // Validate & Build Itinerary List
        List<mtItinerary> listItin = new List<mtItinerary>();
        int cnt = 0;
        foreach (RepeaterItem itm in itinerarylist.Items)
        {
            int iItineraryID = Convert.ToInt32(((HiddenField)itm.FindControl("itineraryid")).Value);
            string sDate = ((TextBox)itm.FindControl("date")).Text;
            string sItinerary = ((RadTextBox)itm.FindControl("itinerary")).Text;
            string sDetail = ((RadTextBox)itm.FindControl("detail")).Text;
            listItin.Add(new mtItinerary(iItineraryID, sItinerary, sDate, sDetail));
            cnt++;
            if (cnt == 1)
            {
                if (sDate == "" || sItinerary == "")
                    msg += "First itinerary detail is required<br>";
            }
        }

        // Validate & Build Category List
        List<mtGroupCategory> listCat = new List<mtGroupCategory>();
        cnt = 0;
        foreach (RepeaterItem itm in categorylist.Items)
        {
            int iCategoryID = Convert.ToInt32(((HiddenField)itm.FindControl("categoryid")).Value);
            string sCategory = ((TextBox)itm.FindControl("category")).Text;
            string sDes = ((TextBox)itm.FindControl("des")).Text;
            decimal dDbl = ConvDec(((RadNumericTextBox)itm.FindControl("dbl")).Text);
            decimal dCommissionDbl = ConvDec(((RadNumericTextBox)itm.FindControl("commissiondbl")).Text);
            decimal dSng = ConvDec(((RadNumericTextBox)itm.FindControl("sng")).Text);
            decimal dCommissionSng = ConvDec(((RadNumericTextBox)itm.FindControl("commissionsng")).Text);

            listCat.Add(new mtGroupCategory(iCategoryID, sCategory, sDes, dSng, dDbl, dCommissionSng, dCommissionDbl));
            cnt++;
            if (cnt == 1 && packageType != "T")
            {
                if (sCategory == "")
                    msg += "First Category/Rate detail is required<br>";
            }
        }

        // Validate & Build Canc. Policy List
        string sProcessDeposit = "";
        string sProcessPayment = "";
        List<mtCancelPolicy> listCanc = new List<mtCancelPolicy>();
        cnt = 0;
        foreach (RepeaterItem itm in cancpolicylist.Items)
        {
            int iCancPolicyID = Convert.ToInt32(((HiddenField)itm.FindControl("cancpolicyid")).Value);
            string sDateFr = ((TextBox)itm.FindControl("datefr")).Text;
            string sDateTo = ((TextBox)itm.FindControl("dateto")).Text;
            string sPolicy = ((TextBox)itm.FindControl("policy")).Text;
            listCanc.Add(new mtCancelPolicy(iCancPolicyID, sPolicy, sDateFr, sDateTo, ""));
            cnt++;
            if (cnt == 1)
            {
                if (sDateFr == "" || sDateTo == "" || sPolicy == "")
                    msg += "First cancellation policy is required<br>";
            }
        }
        foreach (ListItem itm in processdeposit.Items)
        {
            if (itm.Selected)
            {
                if (sProcessDeposit != "")
                    sProcessDeposit += ",";
                sProcessDeposit += itm.Text;
            }
        }
        foreach (ListItem itm in processpayment.Items)
        {
            if (itm.Selected)
            {
                if (sProcessPayment != "")
                    sProcessPayment += ",";
                sProcessPayment += itm.Text;
            }
        }

        // Validate & Build Disclaimer Items
        string sRequiredPass = "";
        string sDocReq = "";
        foreach (ListItem itm in requiredpass.Items)
        {
            if (itm.Selected)
            {
                if (sRequiredPass != "")
                    sRequiredPass += ",";
                sRequiredPass += itm.Text;
            }
        }
        foreach (ListItem itm in docreq.Items)
        {
            if (itm.Selected)
            {
                if (sDocReq != "")
                    sDocReq += ",";
                sDocReq += itm.Text;
            }
        }

        // Validate & Build Instructions Items
        string sAddlInstr = "";
        foreach (ListItem itm in addlinstr.Items)
        {
            if (itm.Selected)
            {
                if (sAddlInstr != "")
                    sAddlInstr += ",";
                sAddlInstr += itm.Text;
            }
        }

        // Check Message
        if (msg != "")
        {
            message.InnerHtml = msg;
            return;
        }


        // Update
        mtGroup g = mtGroup.GetGroup(groupCode);

        // Group Info Tab
        //////mtVendorGroup.Check(vendorgroupcode.Text);
        //g.DepartureDate = departuredate.Text;
        g.DepartureDate = Convert.ToString(departuredate.SelectedDate);

        //g.ReturnDate = returndate.Text;
        g.ReturnDate = Convert.ToString(returndate.SelectedDate);

        g.Affinity = affinity.Checked;
        g.SpecialtyGroup = specialitygroup.Checked;
        g.DoNotDisplay = donotdisplay.Checked;

        g.useDateRange = chkUseDate.Checked;
        g.dateFrom = rdpFrom.SelectedDate.Value;
        g.dateTo = rdpTo.SelectedDate.Value.AddHours(23).AddMinutes(59).AddSeconds(59);

        g.AgentName = agentname.Text;
        g.Heading = heading.Text;
        //g.VendorCode = vendorcode.Value;
        g.VendorCode = vendorgroupcode.Text;
        //g.VendorGroupCode = vendorgroupcode.Text;
        g.VendorGroupCode = vendorname.SelectedValue.ToString();
        if (g.VendorGroupCode == "")
        {
            message.InnerHtml = "Vendor name is required";
            return;
        }
        g.VGroupCode = VgroupCode.SelectedValue;
        //g.VendorGroupCode2 = ddlSecondVendorCode.SelectedText;
        g.VendorGroupCode2 = ddlSecondVendorCode.SelectedValue.ToString();
        g.VendorGroupNumber = vendorgroupnumber.Text;
        g.RegionCode = mtRegion.GetRegionCode(regiondescription.Text);
        g.DeparturePoint = mtDeparturePoint.GetDepartureCode(departurepointname.Text);
        g.Description = ConvInt(description.Value);
        g.ShipCode = mtShip.GetShipCode(shipname.Text);
        //g.ShipCode = mtShip.GetShipCode(shipname.SelectedText);
        g.Template = template.SelectedValue;
        if (sSellingTip != "")
            g.SellingTip = sSellingTip;
        if (sPrintVersion != "")
            g.PrintVersion = sPrintVersion;

        // Category Tab
        g.StartingRates = ConvDec(startingrates.Text);
        g.DoubleRate = ConvDec(doublerate.Text);
        g.SingleRate = ConvDec(singlerate.Text);
        g.TripleRate = ConvDec(triplerate.Text);
        g.QuadRate = ConvDec(quadrate.Text);

        g.commissionSng = ConvDec(commissionsngA.Text);
        g.commissionDbl = ConvDec(commissiondblA.Text);
        g.commissionTRPL = ConvDec(commissionTRPL.Text);
        g.commissionQUAD = ConvDec(commissionQUAD.Text);

        g.HideRates = hiderates.Checked;
        g.TrplQuadRate = ConvDec(trplquadrate.Text);
        g.TrplQuadComments = trplquadcomments.Text;
        g.PortCharges = ConvDec(portcharges.Text);
        g.GovtFees = ConvDec(govtfees.Text);
        g.Taxes = ConvDec(taxes.Text);
        g.Miscellaneous = ConvDec(miscellaneous.Text);
        g.MiscComments = misccomments.Text;
        g.DepositAmount = ((currncy.SelectedValue == "%") ? "" : "$") + depositamount.Text + ((currncy.SelectedValue == "%") ? "%" : "");
        g.FinalPmtDate = finalpmtdate.Text;
        g.FirstDepositDate = firstdepositdate.Text;

        g.SecondDepositDate = seconddepositdate.Text;
        g.RecallDate = recalldate.Text;
        g.TrplQuad = trplquad.SelectedValue;
        g.PortChargesIncluded = portchargesincluded.SelectedValue;
        g.GovtFeesIncluded = govtfeesincluded.SelectedValue;
        g.TaxesIncluded = taxesincluded.SelectedValue;
        g.MiscIncluded = miscincluded.SelectedValue;
        g.DepUnit = ConvInt(depunit.SelectedValue);

        // Canc. Policy Tab
        g.ProcessDeposit = sProcessDeposit;
        g.ProcessPayment = sProcessPayment;
        g.ProcessDepositOther = processdepositother.Text;
        g.ProcessPaymentOther = processpaymentother.Text;

        // Disclaimer Tab
        g.RequiredPass = sRequiredPass;
        g.DocReq = sDocReq;
        g.SpecialFeatures = specialfeatures.SelectedValue;
        g.CustomAir = customair.SelectedValue;
        g.Pre = pre.SelectedValue;
        g.Post = post.SelectedValue;
        g.AdditionalNotes = additionalnotes.Text;
        g.SuggestCustomAir = suggestcustomair.Text;
        g.TravelInsurance = travelinsurance.Text;
        g.Disclaimer = disclaimer.Text;
        g.FlyerDisclaimer = flyerdisclaimer.Text;
        g.CallToAction = calltoaction.Text;
        g.CustomAirAmount = ConvDec(customairamount.Text);
        g.PreAmount = ConvDec(preamount.Text);
        g.PostAmount = ConvDec(postamount.Text);
        g.Script331 = (script331.Checked) ? "on" : "";
        g.AgentNotes = agentnotes.SelectedValue;
        g.Visa = visa.Text;
        g.Innoculation = innoculation.Text;
        g.DocOther = docother.Text;

        // Instruction Tab
        g.AddlInstr = sAddlInstr;
        g.MotorCoach = motorcoach.SelectedValue;

        //g.ContactInstr = contactinstr.SelectedValue;
        g.ContactInstr = lblContactInstruction.Text;

        //g.IATAInstr = iatainstr.SelectedValue;
        g.IATAInstr = lblReferenceIATA.Text;

        g.PhoneInstr = phoneinstr.SelectedValue;
        g.ContactInstrOther = contactinstrother.Text;
        g.IATAInstrOther = iatainstrother.Text;
        g.PhoneInstrOther = phoneinstrother.Text;
        g.AddlInstrOther = addlinstrother.Text;
        g.AddAir = addair.SelectedValue;
        g.TransfersIncluded = transfersincluded.SelectedValue;
        g.TransfersCost = (transferscost.Text == "") ? "" : transferscost.Text + " " + transferoption.SelectedValue;

        // Update
        try
        {
            mtGroup.Update(g);
            mtGroup.UpdateItinerary(groupCode, listItin);
            mtGroup.UpdateCategory(groupCode, listCat);
            mtGroup.UpdateCancelPolicy(groupCode, listCanc);
            mtGroup.UpdateBanner(groupCode, listBanner);
            mtGroup.UpdateDoNotDisplay();
            msg = HttpUtility.UrlEncode("Group #" + groupCode + " was updated.");
            Response.Redirect("mtGroupEdit.aspx?groupcode=" + groupCode + "&msg=" + msg);
        }
        catch (ApplicationException ex)
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

    protected void Itinerary_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabItinerary.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxItinerary;
    }

    protected void Category_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabCategory.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxCategory;
    }

    protected void CancPolicy_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabCancPolicy.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxCancPolicy;
    }

    protected void Disclaimer_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabDisclaimer.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxDisclaimer;
    }

    protected void Instruction_Click(object sender, EventArgs e)
    {
        InitTabs();
        tabInstruction.CssClass = "grpTabSel";
        MainView.ActiveViewIndex = idxInstruction;
    }

    void InitTabs()
    {
        tabGroupInfo.CssClass = "grpTab";
        tabItinerary.CssClass = "grpTab";
        tabCategory.CssClass = "grpTab";
        tabCancPolicy.CssClass = "grpTab";
        tabDisclaimer.CssClass = "grpTab";
        tabInstruction.CssClass = "grpTab";
    }

    decimal ConvDec(string amt)
    {
        return (amt.Trim() == "") ? 0 : Convert.ToDecimal(amt);
    }

    int ConvInt(string num)
    {
        return (num.Trim() == "") ? 0 : Convert.ToInt32(num);
    }

    protected void categorylist_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            RadNumericTextBox sng = (RadNumericTextBox)e.Item.FindControl("sng");
            RadNumericTextBox dbl = (RadNumericTextBox)e.Item.FindControl("dbl");
            RadNumericTextBox commissionSng = (RadNumericTextBox)e.Item.FindControl("commissionSng");
            RadNumericTextBox commissionDbl = (RadNumericTextBox)e.Item.FindControl("commissionDbl");
            mtGroupCategory c = (mtGroupCategory)e.Item.DataItem;
            if (c.category == "" && c.des == "")
            {
                if (c.sng == 0)
                    sng.Text = "";
                if (c.dbl == 0)
                    dbl.Text = "";
                if (c.commissionSng == 0)
                    commissionSng.Text = "";
                if (c.commissionDbl == 0)
                    commissionDbl.Text = "";
            }
        }
    }

    protected void template_SelectedIndexChanged(object sender, EventArgs e)
    {
        string sTemplate = template.SelectedValue;
        trBannerTop.Visible = false;
        trBannerCenter.Visible = false;
        trBannerBottom.Visible = false;
        List<mtGroupBanner> listB = mtGroup.GetBanner(groupCode, template.SelectedValue);
        foreach (mtGroupBanner b in listB)
        {
            if (b.bannerPosition.ToLower() == "top")
            {
                trBannerTop.Visible = true;
                bannertitle_top.Text = mtPickList.GetDesc(mtPickList.GetBanner(sTemplate, b.bannerPosition), b.bannerID.ToString());
                bannerid_top.Value = (bannertitle_top.Text == "") ? "" : b.bannerID.ToString();
            }
            else if (b.bannerPosition.ToLower() == "center")
            {
                trBannerCenter.Visible = true;
                bannertitle_center.Text = mtPickList.GetDesc(mtPickList.GetBanner(sTemplate, b.bannerPosition), b.bannerID.ToString());
                bannerid_center.Value = (bannertitle_center.Text == "") ? "" : b.bannerID.ToString();
            }
            else if (b.bannerPosition.ToLower() == "bottom")
            {
                trBannerBottom.Visible = true;
                bannertitle_bottom.Text = mtPickList.GetDesc(mtPickList.GetBanner(sTemplate, b.bannerPosition), b.bannerID.ToString());
                bannerid_bottom.Value = (bannertitle_bottom.Text == "") ? "" : b.bannerID.ToString();
            }
        }
    }


    protected void chkUseDate_CheckedChanged(object sender, EventArgs e)
    {
        if (chkUseDate.Checked == true)
        {
            //rdpFrom.SelectedDate = DateTime.Now;
            //rdpTo.SelectedDate = DateTime.Now.AddDays(1);
            donotdisplay.Checked = true;
        }
    }

    protected void ddlInstructionType_SelectedIndexChanged(object sender, EventArgs e)
    {
        lblContactInstruction.Text = ddlInstructionType.SelectedValue;
        chkContact.Checked = false;
    }

    protected void chkContact_CheckedChanged(object sender, EventArgs e)
    {
        string s;
        if(chkContact.Checked == true)
        {
            s = ddlInstructionType.SelectedValue + " " + vendorgroupnumber.Text;
        }
        else
        {
            s = ddlInstructionType.SelectedValue;
        }

        lblContactInstruction.Text = s;
    }

    protected void ddlInstructionIATA_SelectedIndexChanged(object sender, EventArgs e)
    {
        lblReferenceIATA.Text = ddlInstructionIATA.SelectedValue;
        //chkReferenceIATA.Checked = false;
    }

    //protected void chkReferenceIATA_CheckedChanged(object sender, EventArgs e)
    //{
    //    string s;
    //    if(chkReferenceIATA.Checked == true)
    //    {
    //        s = ddlInstructionIATA.SelectedValue + " " + vendorgroupnumber.Text;
    //    }
    //    else
    //    {
    //        s = ddlInstructionIATA.SelectedValue;
    //    }

    //    lblReferenceIATA.Text = s;
    //}


    protected void vendorname_ItemSelected(object sender, DropDownListEventArgs e)
    {

        string sCode = vendorname.SelectedValue.ToString();
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

        vendorgroupcode.Text = vendorname.SelectedValue.ToString();
    }

    protected void VgroupCode_ItemSelected(object sender, DropDownListEventArgs e)
    {
        ddlSecondVendorCode.DataSource = mtVendor.GetSecondaryVendorCode(VgroupCode.SelectedValue);
        ddlSecondVendorCode.DataBind();
        //ddlSecondVendorCode.SelectedValue = g.VendorGroupCode2;
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

    protected void vendorname_ItemDataBound(object sender, DropDownListItemEventArgs e)
    {
        var listitem = (RadDropDownList)sender;
        int counter = listitem.Items.Count();
        if (counter == 1)
        {
            listitem.Items.Insert(0, new DropDownListItem("Select vendor...", string.Empty));
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

    protected void donotdisplay_CheckedChanged(object sender, EventArgs e)
    {
        //if (donotdisplay.Checked == true)
        //{
        //    chkUseDate.Enabled = true;
        //    chkUseDate.Checked = false;
        //    rdpFrom.Enabled = false;
        //    rdpTo.Enabled = false;
        //}
        //else
        //{
        //    chkUseDate.Enabled = false;
        //}
    }
</script>
           
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <script type="text/javascript">
        function findRegion() {var url = "mtFindRegion.aspx?idregiondescription=<%=regiondescription.ClientID%>"; popupWin(url);}
        <%--function findShip() {var url = "mtFindShip.aspx?idshipname=<%=shipname.ClientID%>"; popupWin(url);}--%>
        function findDeparturePoint() {var url = "mtFindDeparturePoint.aspx?iddeparturepointname=<%=departurepointname.ClientID%>"; popupWin(url);}
        function findDescription() {var url = "mtFindDescription.aspx?iddescription=<%=description.ClientID%>&iddescriptiontitle=<%=descriptiontitle.ClientID%>"; popupWin(url);}
        function findVendor() { var url = "mtFindVendor.aspx?idvendorcode=<%=vendorcode.ClientID%>&idvendorname=<%=vendorname.ClientID%>"; popupWin(url); }
        function findVendorGroup() { var url = "mtFindVendorGroup.aspx?idvendorgroupcode=<%=vendorgroupcode.ClientID%>"; popupWin(url); }
        function findBanner(pos, idB, idT) { var url = "mtFindBanner.aspx?template=<%=template.SelectedValue%>&bannerposition=" + pos + "&idbannerid=" + idB + "&idbannertitle=" + idT; popupWin(url); }
        function includes(placement) { var url = "mtGroupInclude.aspx?groupcode=<%=groupCode%>&placement=" + placement; popupWin(url); }
    </script>
<%--    <script>
          
</script>--%>

    <style type="text/css">
        .grpTab {display: block; padding: 4px 8px 4px 8px; float: left; background: url("Images/tab.png") no-repeat right top; color: Black; font-weight: bold;}
        .grpTab:hover {color: Yellow; background: url("Images/tabselhover.png") no-repeat right top; cursor: pointer}
        .grpTabSel {float: left; display: block; background: url("Images/tabsel.png") no-repeat right top; padding: 4px 8px 4px 8px; color: Black; font-weight: bold; color: White;}
        .numr {text-align: right;}
    </style>

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Group</td>
			<td align="right">
                <asp:button id="flyer" runat="server" Text="View Flyer" Width="75px" CssClass="button" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="agentflyer" runat="server" Text="View Agent Flyer" Width="100px" CssClass="button" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="back" runat="server" Text="&lt;&lt; Back To List" Width="100px" CssClass="button" CausesValidation="False"></asp:button>&nbsp;
            </td>
		</tr>
		<tr><td width="100%" colspan="2" class="line" height="1"></td></tr>
	</table>
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span><br>
				<asp:validationsummary id="valS" runat="server" ForeColor="red" HeaderText="Please correct the following:" CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
   <table width="900" align="left">
        <tr>
            <td>
	            <table cellspacing="1" cellpadding="2" border="0" width="100%">
                    <tr>
                        <td><span class="tdlabel">Package:</span>&nbsp;<asp:Label runat="server" ID="typedescription" /></td>
                        <td><span class="tdlabel">Template:</span>&nbsp;<asp:Label runat="server" ID="currtemplate" /></td>
                        <td><span class="tdlabel">Status:</span>&nbsp;<asp:Label runat="server" ID="status" /></td>
                        <td><span class="tdlabel">Do Not Display:</span>&nbsp;<asp:checkbox runat="server" ID="donotdisplay" AutoPostBack="true" OnCheckedChanged="donotdisplay_CheckedChanged"/></td>
                        <td align="right" class="required">* Required Fields</td>
                    </tr>
                    <tr>
                        <td>

                        </td>
                        <td>
                            <span class="tdlabel">To Display Flyer Use Date Range:</span>&nbsp;<asp:checkbox ID="chkUseDate" runat="server" AutoPostBack="true" OnCheckedChanged="chkUseDate_CheckedChanged"/>
                        </td>
                        <td>
                            <span class="tdlabel">From:</span>&nbsp;<telerik:RadDatePicker ID="rdpFrom" runat="server"  Width="100px" Enabled="true" MinDate="1901-01-01" MaxDate="2999-01-01" AutoPostBack="false"> 
                                <Calendar ShowRowHeaders="false"></Calendar>
                                </telerik:RadDatePicker>
                            <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="rdpFrom" CssClass="error" Display="Dynamic" ControlToCompare="rdpTo" Operator="LessThanEqual" ErrorMessage="From date must be < To date" Type="Date">*</asp:CompareValidator>
                        </td>
                        <td>
                            <span class="tdlabel">To:</span>&nbsp;<telerik:RadDatePicker ID="rdpTo" runat="server" Width="100px" Enabled="true" MinDate="1901-01-01" MaxDate="2999-01-01" AutoPostBack="false" >
                                <Calendar ShowRowHeaders="false"></Calendar>
                                </telerik:RadDatePicker>
                            <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="rdpTo" CssClass="error" Display="Dynamic" ControlToCompare="rdpFrom" Operator="GreaterThanEqual" ErrorMessage="To date must be > From date" Type="Date">*</asp:CompareValidator>
                        </td>
                    </tr>
	            </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Button Text="Basic Info" BorderStyle="None" ID="tabGroupInfo" CssClass="grpTab" runat="server" OnClick="GroupInfo_Click" />
                <asp:Button Text="Itinerary" BorderStyle="None" ID="tabItinerary" CssClass="grpTab" runat="server" OnClick="Itinerary_Click" />
                <asp:Button Text="Fees & Rates" BorderStyle="None" ID="tabCategory" CssClass="grpTab" runat="server" OnClick="Category_Click" />
                <asp:Button Text="Canc. Policy" BorderStyle="None" ID="tabCancPolicy" CssClass="grpTab" runat="server" OnClick="CancPolicy_Click" />
                <asp:Button Text="Miscellaneous" BorderStyle="None" ID="tabDisclaimer" CssClass="grpTab" runat="server" OnClick="Disclaimer_Click" />
                <asp:Button Text="Instructions" BorderStyle="None" ID="tabInstruction" CssClass="grpTab" runat="server" OnClick="Instruction_Click" />
                <asp:Panel runat="server" ID="pnlView" ScrollBars="Vertical" Height="500px" width="860px" BorderColor="#666666" BorderWidth="1px" BorderStyle="Solid">
                <asp:MultiView ID="MainView" runat="server">
                    <asp:View ID="viewGroupInfo" runat="server">
                        <asp:HiddenField ID="description" runat="server" />
                        <asp:HiddenField ID="vendorcode" runat="server" />
                        <asp:HiddenField ID="bannerid_top" runat="server" />
                        <asp:HiddenField ID="bannerid_center" runat="server" />
                        <asp:HiddenField ID="bannerid_bottom" runat="server" />
                        <table cellpadding="5" width="840" cellspacing="0">
                            <tr>
                                <td colspan="2">
	                                <table cellspacing="1" cellpadding="3" border="0">
                                        <tr valign="top">
                                            <td width="125" class="tdlabel">Heading:&nbsp;<span class="required">*</span></td>
                                            <td>
		                                        <CKEditor:CKEditorControl ID="heading" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                                    Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|"
                                                     DisableNativeSpellChecker="false">
		                                        </CKEditor:CKEditorControl>
                                                <asp:requiredfieldvalidator id="reqv28" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="heading" ErrorMessage="Heading is required">*</asp:requiredfieldvalidator>                                            
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td width="60%">
	                                <table cellspacing="1" cellpadding="3" border="0">
                                        <tr>
                                            <td class="tdlabel">Vendor Name:&nbsp;<span class="required">*</span></td>
                                            <td>
                                                <%--<asp:textbox id="vendorname" runat="server" Width="330px"></asp:textbox>--%>
                                                <%--<input type="button" value="..." onclick="findVendor();" />--%>
                                                <telerik:RadDropDownList id="vendorname" runat="server" Width="350px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="true"
                                                        DefaultMessage="Select a vendor" OnItemSelected="vendorname_ItemSelected"
                                                        DataValueField="vendorcode" DataTextField="vendorname" OnItemDataBound="vendorname_ItemDataBound"  ></telerik:RadDropDownList>
                                                <asp:requiredfieldvalidator id="reqv21" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorname" ErrorMessage="Vendor name is required">*</asp:requiredfieldvalidator>
                                            </td>
                                        </tr>
                                        <tr id="trVengorGroupCode" runat="server">
                                            <td class="tdlabel">Vendor Group:&nbsp;</td>
                                            <td>
                                                <telerik:RadDropDownList ID="VgroupCode" runat="server" Width="350px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="false"
                                                        DefaultMessage="Select group..." DataValueField="VGroupCode" DataTextField="VGroupDescription" Skin="Black" 
                                                    OnItemSelected="VgroupCode_ItemSelected" OnItemDataBound="VgroupCode_ItemDataBound">
                                                </telerik:RadDropDownList>
                                                <%--<asp:requiredfieldvalidator id="reqval1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="VgroupCode" ErrorMessage="Vendor Group Code is required">*</asp:requiredfieldvalidator>--%>
                                            </td>
                                        </tr>
                                        <tr runat="server" id="trShip">
                                            <td class="tdlabel">Ship Name:&nbsp;<span class="required">*</span></td>
                                            <td>
                                              <%--<asp:textbox id="shipname" runat="server" Width="330px">
                                                </asp:textbox><input type="button" value="..." onclick="findShip();" />    --%>  
                                            <%--<telerik:RadDropDownList id="shipname" runat="server" Width="350px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostnBack="false"
                                                        DefaultMessage="Select a ship" 
                                                        DataValueField="ShipCode" DataTextField="ShipName" ></telerik:RadDropDownList>--%>
                                                <telerik:RadComboBox id="shipname" runat="server" Width="350px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostnBack="false"
                                                        DefaultMessage="Select a ship" 
                                                        DataValueField="ShipCode" DataTextField="ShipName"></telerik:RadComboBox>
                                                <asp:requiredfieldvalidator id="reqv22" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="shipname" ErrorMessage="Ship name is required">*</asp:requiredfieldvalidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="tdlabel">Description:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="descriptiontitle" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findDescription();" />                                            
                                                <asp:requiredfieldvalidator id="reqv20" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="descriptiontitle" ErrorMessage="Description is required">*</asp:requiredfieldvalidator>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="tdlabel">Region:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="regiondescription" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findRegion();" />
                                                <asp:requiredfieldvalidator id="reqv23" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="regiondescription" ErrorMessage="Region is required">*</asp:requiredfieldvalidator>                                            
                                             </td>
                                        </tr>
                                        <tr runat="server" id="trDeparturePoint">
                                            <td class="tdlabel">Departure Point:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="departurepointname" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findDeparturePoint();" />
                                                <asp:requiredfieldvalidator id="reqv24" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="departurepointname" ErrorMessage="Departure Point is required">*</asp:requiredfieldvalidator>                                            
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="125" class="tdlabel">Affinity Agent Name:</td>
                                            <td><asp:textbox id="agentname" runat="server" Width="350px" MaxLength="200" /></td>
                                        </tr>
                                        <tr>
                                            <td class="tdlabel">Template:&nbsp;<span class="required">*</span></td>
                                            <td><asp:DropDownList runat="server" ID="template" Width="350px" AutoPostBack="True" onselectedindexchanged="template_SelectedIndexChanged" />
                                                <asp:requiredfieldvalidator id="reqv25" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="template" ErrorMessage="Template is required">*</asp:requiredfieldvalidator>                                            
                                            </td>
                                        </tr>
                                        <tr runat="server" id="trBannerTop">
                                            <td class="tdlabel">Flyer Banner Top:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="bannertitle_top" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findBanner('Top','<%=bannerid_top.ClientID%>','<%=bannertitle_top.ClientID%>');" />                                            
                                                <asp:requiredfieldvalidator id="reqv13" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="bannertitle_top" ErrorMessage="Flyer Banner Top is required">*</asp:requiredfieldvalidator>
			                                </td>
                                        </tr>
                                        <tr runat="server" id="trBannerCenter">
                                            <td class="tdlabel">Flyer Banner Center:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="bannertitle_center" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findBanner('Center','<%=bannerid_center.ClientID%>','<%=bannertitle_center.ClientID%>');" />                                            
                                                <asp:requiredfieldvalidator id="reqv14" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="bannertitle_center" ErrorMessage="Flyer Banner Center is required">*</asp:requiredfieldvalidator>
			                                </td>
                                        </tr>
                                        <tr runat="server" id="trBannerBottom">
                                            <td class="tdlabel">Flyer Banner Bottom:&nbsp;<span class="required">*</span></td>
                                            <td><asp:textbox id="bannertitle_bottom" runat="server" Width="330px"></asp:textbox><input type="button" value="..." onclick="findBanner('Bottom','<%=bannerid_bottom.ClientID%>','<%=bannertitle_bottom.ClientID%>');" />                                            
                                                <asp:requiredfieldvalidator id="reqv15" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="bannertitle_bottom" ErrorMessage="Flyer Banner Bottom is required">*</asp:requiredfieldvalidator>
			                                </td>
                                        </tr>
                                        <tr valign="top">
		                                    <td class="tdlabel">Selling Tips:</td>
		                                    <td>
                                                <asp:FileUpload id="sellingtip" runat="server" Width="350px" />&nbsp;<asp:Label ID="lblsellingtip" runat="server" />
                                                <asp:regularexpressionvalidator id="Regularexpressionvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="sellingtip" ValidationExpression="^.+(.doc|DOC|.docx|.DOCX|.pdf|.PDF)$" ErrorMessage="Only Word or PDF document are allowed for Selling Tips">*</asp:regularexpressionvalidator>
	                                        </td>
                                        </tr>
                                        <tr valign="top">
		                                    <td class="tdlabel">Print Version:</td>
		                                    <td>
                                                <asp:FileUpload id="printversion" runat="server" Width="350px" />&nbsp;<asp:Label ID="lblprintversion" runat="server" />
                                                <asp:regularexpressionvalidator id="regexpr1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="printversion" ValidationExpression="^.+(.pdf|.PDF)$" ErrorMessage="Only PDF document is allowed for Print version">*</asp:regularexpressionvalidator>
	                                        </td>
                                        </tr>
	                                </table>
                                </td>      
                                <td width="40%">
	                                <table cellspacing="1" cellpadding="3" border="0">
                                         
                                        <tr>
			                                <td class="tdlabel">Vendor Code:&nbsp;</td>
			                                <td><asp:Label id="vendorgroupcode" runat="server" Width="100" MaxLength="25" ForeColor="Navy" ></asp:Label>
                                               <%-- <input type="button" value="..." onclick="findVendorGroup();" />--%>
                                                <%--<asp:requiredfieldvalidator id="reqv26" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorgroupcode" ErrorMessage="Vendor Group Code is required">*</asp:requiredfieldvalidator> --%>                                           
                                            </td>
		                                </tr>
		                                <tr>
			                                <td class="tdlabel">Vendor Group #:&nbsp;<span class="required">*</span></td>
			                                <td><asp:textbox id="vendorgroupnumber" runat="server" Width="100"  MaxLength="10"></asp:textbox>
                                                <asp:requiredfieldvalidator id="reqv27" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorgroupnumber" ErrorMessage="Vendor Group # is required">*</asp:requiredfieldvalidator>                                            
                                            </td>
		                                </tr>
                                        <tr>
                                            <td class="tdlabel">2nd Vendor:&nbsp;<span class="required"></span></td>
                                            <td>
                                                <telerik:RadDropDownList ID="ddlSecondVendorCode" runat="server" Width="180px" RenderMode="Lightweight" DropDownHeight="200px" AutoPostBack="false"
                                                        DefaultMessage="Select 2nd vendor..." DataValueField="vendorCode" DataTextField="vendorName" Skin="Telerik" OnItemDataBound="ddlSecondVendorCode_ItemDataBound" >

                                                </telerik:RadDropDownList>
                                                <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="vendorname" ErrorMessage="Vendor name is required">*</asp:requiredfieldvalidator>--%>
                                            </td>
                                        </tr>
		                                <tr>
			                                <td class="tdlabel" width="125">Departure Date:&nbsp;<span class="required">*</span></td>
			                                <td>
                                                <%--<asp:textbox id="departuredate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=departuredate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a> --%>
                                                <telerik:RadDatePicker id="departuredate" runat="server" Width="80">
                                                    <Calendar ShowRowHeaders="false"></Calendar>
                                                </telerik:RadDatePicker>
                                                <asp:requiredfieldvalidator id="reqv2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="departuredate" ErrorMessage="Departure date is required">*</asp:requiredfieldvalidator>
                                                <asp:CompareValidator id="comv1" runat="server" ControlToValidate="departuredate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure date is invalid" Type="Date">*</asp:CompareValidator>
                                            </td>
		                                </tr>
		                                <tr>
			                                <td class="tdlabel">Return Date:&nbsp;<span class="required">*</span></td>
			                                <td>
                                                <%--<asp:textbox id="returndate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=returndate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                                                <telerik:RadDatePicker id="returndate" runat="server" Width="80">
                                                    <Calendar ShowRowHeaders="false"></Calendar>
                                                </telerik:RadDatePicker>
                                                <asp:requiredfieldvalidator id="reqv3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="returndate" ErrorMessage="Return date is required">*</asp:requiredfieldvalidator>
                                                <asp:CompareValidator id="comv2" runat="server" ControlToValidate="returndate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Return date is invalid" Type="Date">*</asp:CompareValidator>
                                                <asp:CompareValidator ID="comv26" runat="server" ControlToValidate="returndate" CssClass="error" Display="Dynamic" ControlToCompare="departuredate" Operator="GreaterThanEqual" ErrorMessage="Return date must be >= Departure date" Type="Date">*</asp:CompareValidator>
                                            </td>
		                                </tr>
                                        <tr>
                                            <td class="tdlabel">Speciality Group:</td>
                                            <td><asp:checkbox  runat="server" ID="specialitygroup" /></td>
                                        </tr>
		                                <tr>
                                            <td class="tdlabel">Affinity Group:</td>
                                            <td><asp:checkbox  runat="server" ID="affinity" /></td>
                                        </tr>
	                                </table>
                                </td>                              
                            </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewItinerary" runat="server">
                        <asp:Repeater ID="itinerarylist" runat="server">
                            <HeaderTemplate>
                                <table cellpadding="3" cellspacing="0" border="0">
                                    <tr>
                                        <td width="5">&nbsp;</td>
                                        <td width="100" class="tdlabel">Date&nbsp;<span class="required">*</span></td>
                                        <td width="470" class="tdlabel">Destination&nbsp;<span class="required">*</span></td>
                                        <td class="tdlabel">Details</td>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr valign="top">
                                    <td width="5"><asp:HiddenField ID="itineraryid" runat="server" Value='<%# Eval("itineraryid") %>' />&nbsp;</td>
                                    <td>
                                        <asp:textbox id="date" runat="server" Width="80px"  MaxLength="12" Text='<%# Bind("date") %>' ></asp:textbox>
                                        <asp:CompareValidator id="comv3" runat="server" ControlToValidate="date" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Itinerary date is invalid" Type="Date">*</asp:CompareValidator>
                                    </td>                                        
                                    <td>
                                        <%--<asp:TextBox ID="itinerary" runat="server" Width="450px" MaxLength="500" Text='<%# Bind("itinerary") %>' />--%>
                                        <telerik:RadTextBox ID="itinerary" runat="server" Width="450px" MaxLength="500" TextMode="MultiLine" BackColor="LightYellow" ForeColor="Navy" Text='<%# Bind("itinerary") %>'></telerik:RadTextBox>
                                    </td>                                        
                                    <td>
                                        <%--<asp:TextBox ID="detail" runat="server" Width="200px" MaxLength="500" Text='<%# Bind("detail") %>' />--%>
                                        <telerik:RadTextBox ID="detail" runat="server" Width="250px" TextMode="MultiLine" BackColor="LightYellow" MaxLength="500" ForeColor="Navy" Text='<%# Bind("detail") %>'></telerik:RadTextBox>

                                    </td>                                        
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </asp:View>
                    <asp:View ID="viewCategory" runat="server">
                        <table cellpadding="2" cellspacing="1" border="0">
                            <tr>
                                <td></td>
                                <td>
                                    <table>
                                        <tr>
                                            <td align="left" style="width:100px"><b>Per Person</b></td>
                                            <td align="left" style="width:100px"><b>Commission</b></td>
                                        </tr>
                                    </table>
                                </td>
                                <%--<td align="left" style="width:100px">Per Person</td>--%>
                            </tr>
                            <tr>
                                <td class="tdlabel" width="180">Starting Rates From:&nbsp;<span class="required">*</span></td>
                                <td width="675">
                                   <%-- $<asp:TextBox ID="startingrates" runat="server" Width="70px" MaxLength="8" />--%>
                                    $<telerik:RadNumericTextBox ID="startingrates" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                    <asp:requiredfieldvalidator id="reqv4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="startingrates" ErrorMessage="Starting rate is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator id="comv7" runat="server" ControlToValidate="startingrates" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Starting rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
                            </tr>
                            <tr runat="server" id="trDoubleRate" valign="top">
                                <td class="tdlabel">Double Rate:&nbsp;<span class="required">*</span></td>
                                <td>
                                    <%--$<asp:TextBox ID="doublerate" runat="server" Width="70px" MaxLength="8" />--%>
                                    $<telerik:RadNumericTextBox ID="doublerate" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                    <asp:requiredfieldvalidator id="reqv1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="doublerate" ErrorMessage="Double rate is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator id="comv6" runat="server" ControlToValidate="doublerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Double rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    <%--$<asp:TextBox ID="commissiondblA" runat="server" Width="70px" MaxLength="8" />Commission--%>
                                    $<telerik:RadNumericTextBox ID="commissiondblA" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox> <%--Commission--%>
                                    <asp:CompareValidator id="CompareValidatorA" runat="server" ControlToValidate="commissiondblA" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Double commission is invalid" Type="Currency">*</asp:CompareValidator>
                                </td>
                            </tr>
                            <tr runat="server" id="trSingleRate">
                                <td class="tdlabel">Single Rate:&nbsp;<span class="required">*</span></td>
                                <td>
                                   <%-- $<asp:TextBox ID="singlerate" runat="server" Width="70px" MaxLength="8" />--%>
                                    $<telerik:RadNumericTextBox ID="singlerate" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                    <asp:requiredfieldvalidator id="reqv5" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="singlerate" ErrorMessage="Single rate is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator id="comv8" runat="server" ControlToValidate="singlerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Single rate is invalid" Type="Currency">*</asp:CompareValidator> 
                                    <%--$<asp:TextBox ID="commissionsngA" runat="server" Width="70px" MaxLength="8" />Commission--%>
                                    $<telerik:RadNumericTextBox ID="commissionsngA" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox> <%--Commission--%>
                                    <asp:CompareValidator id="comv5A" runat="server" ControlToValidate="commissionsngA" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Single commission is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
                            </tr>
                            <tr runat="server" id="trTripleRate">
                                <td class="tdlabel">Triple Rate:</td>
                                <td>
                                    <%--$<asp:TextBox ID="triplerate" runat="server" Width="70px" MaxLength="8" />--%>
                                    $<telerik:RadNumericTextBox ID="triplerate" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>&nbsp; 
                                    <asp:CompareValidator id="comv9" runat="server" ControlToValidate="triplerate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Triple rate is invalid" Type="Currency">*</asp:CompareValidator>
                                    <%--$<asp:TextBox ID="commissionTRPL" runat="server" Width="70px" MaxLength="8" />Commission--%>
                                    $<telerik:RadNumericTextBox ID="commissionTRPL" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox> <%--Commission--%>
                                    <asp:CompareValidator id="comv6a" runat="server" ControlToValidate="commissionTRPL" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Triple commission is invalid" Type="Currency">*</asp:CompareValidator>
                                </td>
                            </tr>
                            <tr runat="server" id="trQuadRate">
                                <td class="tdlabel">Quad Rate:</td>
                                <td>
                                    <%--$<asp:TextBox ID="quadrate" runat="server" Width="70px" MaxLength="8" />--%>
                                    $<telerik:RadNumericTextBox ID="quadrate" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>&nbsp; 
                                    <asp:CompareValidator id="comv10" runat="server" ControlToValidate="quadrate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Quad rate is invalid" Type="Currency">*</asp:CompareValidator>  
                                    <%--$<asp:TextBox ID="commissionQUAD" runat="server" Width="70px" MaxLength="8" />Commission--%>
                                    $<telerik:RadNumericTextBox ID="commissionQUAD" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox> <%--Commission--%>
                                    <asp:CompareValidator id="com7a" runat="server" ControlToValidate="commissionQUAD" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Quad commission is invalid" Type="Currency">*</asp:CompareValidator>
                                </td>
                            </tr>
                            <tr runat="server" id="trHideRates">
                                <td colspan="2">
                                    <asp:CheckBox runat="server" ID="hiderates" />
                                    Check here to hide Category/Rates, Non-Commissionable Fares, Gov't Fees, Taxes, and Misc. Charges on Flyers
                                </td>
                            </tr>
                        </table>
                        <asp:Repeater ID="categorylist" runat="server" onitemdatabound="categorylist_ItemDataBound">
                            <HeaderTemplate>
                                <table cellpadding="2" cellspacing="0" border="0">
                                    <tr>
                                        <td>&nbsp;</td>
                                        <td class="tdlabel">Category/</td>
                                        <td>&nbsp;</td>
                                        <td class="tdlabel" colspan="2" align="center">Double</td>
                                        <td>&nbsp;</td>
                                        <td class="tdlabel" colspan="2" align="center">Single</td>
                                    </tr>
                                    <tr>
                                        <td>&nbsp;</td>
                                        <td class="tdlabel">Rates&nbsp;<span class="required">*</span></td>
                                        <td class="tdlabel">Description</td>
                                        <td class="tdlabel" align="center" width="100">Per Person</td>
                                        <td class="tdlabel" align="center" width="100">Commission</td>
                                        <td>&nbsp;</td>
                                        <td class="tdlabel" align="center" width="100">Per Person</td>
                                        <td class="tdlabel" align="center" width="100">Commission</td>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr valign="top">
                                    <td><asp:HiddenField ID="categoryid" runat="server" Value='<%# Eval("categoryid") %>' />&nbsp;</td>
                                    <td width="75"><asp:TextBox ID="category" runat="server" Width="40px" MaxLength="3" Text='<%# Bind("category") %>' /></td>                                        
                                    <td width="275"><asp:TextBox ID="des" runat="server" Width="250px" MaxLength="100" Text='<%# Bind("des") %>' /></td>  
                                    <td align="center">
                                        <%--$<asp:TextBox ID="dbl" runat="server" Width="70px" Text='<%# Bind("dbl","{0:###.00}") %>' MaxLength="8" />--%>
                                        $<telerik:RadNumericTextBox ID="dbl" runat="server" Width="80px" MaxLength="8" Text='<%# Bind("dbl","{0:###.00}") %>' >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                        <asp:CompareValidator id="comv2" runat="server" ControlToValidate="dbl" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Double rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    </td>                                        
                                    <td align="center">
                                        <%--$<asp:TextBox ID="commissiondbl" runat="server" Width="70px" Text='<%# Bind("commissiondbl","{0:###.00}") %>' MaxLength="8" />--%>
                                        $<telerik:RadNumericTextBox ID="commissiondbl" runat="server" Width="80px" MaxLength="8" Text='<%# Bind("commissiondbl","{0:###.00}") %>' >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                        <asp:CompareValidator id="comv1" runat="server" ControlToValidate="commissiondbl" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Double commission is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    </td>                
                                    <td width="20">&nbsp;</td>                        
                                    <td align="center">
                                        <%--$<asp:TextBox ID="sng" runat="server" Width="70px" Text='<%# Bind("sng","{0:###.00}") %>' MaxLength="8" />--%>
                                         $<telerik:RadNumericTextBox ID="sng" runat="server" Width="80px" MaxLength="8" Text='<%# Bind("sng","{0:###.00}") %>' >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                        <asp:CompareValidator id="comv4" runat="server" ControlToValidate="sng" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Double rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    </td>                                        
                                    <td align="center">
                                        <%--$<asp:TextBox ID="commissionsng" runat="server" Width="70px" Text='<%# Bind("commissionsng","{0:###.00}") %>' MaxLength="8" />--%>
                                         $<telerik:RadNumericTextBox ID="commissionsng" runat="server" Width="80px" MaxLength="8" Text='<%# Bind("commissionsng","{0:###.00}") %>' >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>
                                        <asp:CompareValidator id="comv5" runat="server" ControlToValidate="commissionsng" CssClass="error" Display="Static" Operator="DataTypeCheck" ErrorMessage="Double commission is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    </td>                
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                          <table cellpadding="2" cellspacing="1" border="0">
                            <tr><td>&nbsp;</td></tr>
                            <tr runat="server" id="trTrplQuadRate">
                                <td class="tdlabel">Triple & Quad:</td>
                                <td>
                                    <%--$<asp:TextBox ID="trplquadrate" runat="server" Width="70px" MaxLength="8" />per person--%>
                                     $<telerik:RadNumericTextBox ID="trplquadrate" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                     </telerik:RadNumericTextBox> per person
                                    <asp:CompareValidator id="comv11" runat="server" ControlToValidate="trplquadrate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Triple/Quad rate is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
				                <td width="25">&nbsp;</td>
                                <td>Triple/Quad Rates?</td>
                                <td><asp:RadioButtonList runat="server" ID="trplquad" RepeatDirection="Horizontal" /></td>
				                <td width="25">&nbsp;</td>
                                <td>Comments:</td>
                                <td><asp:TextBox ID="trplquadcomments" runat="server" Width="150px" MaxLength="250" /></td>
                            </tr>
                            <tr runat="server" id="trPortCharges">
                                <td class="tdlabel">Non-Commissionable Fare:</td>
                                <td>
                                   <%-- $<asp:TextBox ID="portcharges" runat="server" Width="70px" MaxLength="8" />per person--%>
                                    $<telerik:RadNumericTextBox ID="portcharges" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                     </telerik:RadNumericTextBox> per person
                                    <asp:CompareValidator id="comv12" runat="server" ControlToValidate="portcharges" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Non-Commissionable Fare is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
				                <td>&nbsp;</td>
                                <td>Included in Rate:</td>
                                <td><asp:RadioButtonList runat="server" ID="portchargesincluded" RepeatDirection="Horizontal" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel"  width="175">Taxes, fees & port expenses:</td>
                                <td>
                                    <%--$<asp:TextBox ID="govtfees" runat="server" Width="70px" MaxLength="8" />per person--%>
                                    $<telerik:RadNumericTextBox ID="govtfees" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>&nbsp;per person
                                    <asp:CompareValidator id="comv13" runat="server" ControlToValidate="govtfees" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Taxes, fees and port expenses is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
				                <td>&nbsp;</td>
                                <td>Included in Rate:</td>
                                <td><asp:RadioButtonList runat="server" ID="govtfeesincluded" RepeatDirection="Horizontal" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Taxes:</td>
                                <td>
                                    <%--$<asp:TextBox ID="taxes" runat="server" Width="70px" MaxLength="8" />per person--%>
                                    $<telerik:RadNumericTextBox ID="taxes" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>&nbsp;per person
                                    <asp:CompareValidator id="comv14" runat="server" ControlToValidate="taxes" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Taxes is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
				                <td>&nbsp;</td>
                                <td>Included in Rate:</td>
                                <td><asp:RadioButtonList runat="server" ID="taxesincluded" RepeatDirection="Horizontal" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Miscellaneous:</td>
                                <td>
                                    <%--$<asp:TextBox ID="miscellaneous" runat="server" Width="70px" MaxLength="8" />per person--%>
                                    $<telerik:RadNumericTextBox ID="miscellaneous" runat="server" Width="80px" MaxLength="8" >
                                        <NumberFormat DecimalDigits="2" AllowRounding="true" />
                                        <ClientEvents OnKeyPress="preventMoreDecimalPlaces" />
                                    </telerik:RadNumericTextBox>&nbsp;per person
                                    <asp:CompareValidator id="comv15" runat="server" ControlToValidate="miscellaneous" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Miscellaneous is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
				                <td>&nbsp;</td>
                                <td>Included in Rate:</td>
                                <td><asp:RadioButtonList runat="server" ID="miscincluded" RepeatDirection="Horizontal" /></td>
                                <td></td>
                                <td>Comments:</td>
                                <td><asp:TextBox ID="misccomments" runat="server" Width="150px" MaxLength="50" /></td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr>
                                <td class="tdlabel">Deposit Amount:&nbsp;<span class="required">*</span></td>
                                <td colspan="7" valign="top">
                                    <asp:DropDownList runat="server" ID="currncy" />
                                    <asp:TextBox ID="depositamount" runat="server" Width="75px" MaxLength="8"/>
                                    <asp:DropDownList runat="server" ID="depunit" />
                                    <asp:requiredfieldvalidator id="reqv6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="depositamount" ErrorMessage="Deposit amount is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator id="comv16" runat="server" ControlToValidate="depositamount" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Deposit amount is invalid" Type="Double">*</asp:CompareValidator>                            
                                </td>
                            </tr>
		                    <tr>
			                    <td class="tdlabel">Final Payment Date:&nbsp;<span class="required">*</span></td>
			                    <td colspan="7">
                                    <asp:textbox id="finalpmtdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=finalpmtdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>

                                    <asp:requiredfieldvalidator id="reqv7" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="finalpmtdate" ErrorMessage="Final payment date is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator id="comv17" runat="server" ControlToValidate="finalpmtdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Final payment date is invalid" Type="Date">*</asp:CompareValidator>
                                </td>
		                    </tr>
		                    <tr>
			                    <td class="tdlabel">First Deposit Date:</td>
			                    <td colspan="7">
                                    <asp:textbox id="firstdepositdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=firstdepositdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                    
                                    <asp:CompareValidator id="comv18" runat="server" ControlToValidate="firstdepositdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="First deposit date is invalid" Type="Date">*</asp:CompareValidator>
                                </td>
		                    </tr>
		                    <tr>
			                    <td class="tdlabel">Second Deposit Date:</td>
			                    <td colspan="7">
                                    <asp:textbox id="seconddepositdate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=seconddepositdate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                    <asp:CompareValidator id="comv19" runat="server" ControlToValidate="seconddepositdate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Second deposit date is invalid" Type="Date">*</asp:CompareValidator>
                                </td>
		                    </tr>
		                    <tr>
			                    <td class="tdlabel">Recall Date:</td>
			                    <td colspan="7">
                                    <asp:textbox id="recalldate" runat="server" Width="100"  MaxLength="12"></asp:textbox><a onclick="setLastPos(event)" href="javascript:calendar('<%=recalldate.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
                                    <asp:CompareValidator id="comv20" runat="server" ControlToValidate="recalldate" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Recall date is invalid" Type="Date">*</asp:CompareValidator>
                                </td>
		                    </tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewCancPolicy" runat="server">
                        <asp:Repeater ID="cancpolicylist" runat="server">
                            <HeaderTemplate>
                                <table cellpadding="3" cellspacing="0" border="0">
                                    <tr>
                                        <td width="5">&nbsp;</td>
                                        <td width="100" class="tdlabel">From&nbsp;<span class="required">*</span></td>
                                        <td width="100" class="tdlabel">To&nbsp;<span class="required">*</span></td>
                                        <td class="tdlabel">Cancellation Policy&nbsp;<span class="required">*</span></td>
                                    </tr>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr valign="top">
                                    <td width="5"><asp:HiddenField ID="cancpolicyid" runat="server" Value='<%# Eval("cancpolicyid") %>' />&nbsp;</td>
                                    <td>
                                        <asp:textbox id="datefr" runat="server" Width="80px"  MaxLength="12" Text='<%# Bind("datefr") %>' />
                                        <asp:CompareValidator id="comv3" runat="server" ControlToValidate="datefr" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Canc. policy starting date is invalid" Type="Date">*</asp:CompareValidator>
                                    </td>                                        
                                    <td>
                                        <asp:textbox id="dateto" runat="server" Width="80px"  MaxLength="12" Text='<%# Bind("dateto") %>' />
                                        <asp:CompareValidator id="comv21" runat="server" ControlToValidate="dateto" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Canc. policy ending date is invalid" Type="Date">*</asp:CompareValidator>
                                    </td>                                        
                                    <td><asp:TextBox ID="policy" runat="server" Width="500px" MaxLength="500" Text='<%# Bind("policy") %>' /></td>                                        
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                        <table cellpadding="2" cellspacing="1" border="0">
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td width="5">&nbsp;</td>
                                <td class="tdlabel" width="200">Processing of Deposit:&nbsp;<span class="required">*</span><br /><span class="remark">(Check all that apply)</span></td>
                                <td width="600">
                                    <asp:CheckBoxList runat="server" ID="processdeposit" DataTextField="code" />
                                    &nbsp;&nbsp;<asp:TextBox ID="processdepositother" runat="server" Width="300px" MaxLength="50" />
                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td>&nbsp;</td>
                                <td class="tdlabel">Processing of Final Payment:&nbsp;<span class="required">*</span><br /><span class="remark">(Check all that apply)</span></td>
                                <td>
                                    <asp:CheckBoxList runat="server" ID="processpayment" DataTextField="code" />
                                    &nbsp;&nbsp;<asp:TextBox ID="processpaymentother" runat="server" Width="300px" MaxLength="50" />
                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                        </table>
                    </asp:View>
                    <asp:View ID="viewDisclaimer" runat="server">
	                    <table cellspacing="1" cellpadding="3" width="840"  border="0">
                            <tr>
                                <td width="175" class="tdlabel">Special Features:</td>
                                <td width="650">
                                    <asp:RadioButtonList runat="server" ID="specialfeatures" RepeatDirection="Horizontal" RepeatLayout="Flow" />&nbsp;&nbsp;
                                    <a href="javascript:includes('specialFeatures');" >[Edit Special Features]</a>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td width="150" class="tdlabel">Additional Notes:</td>
                                <td width="650">
		                            <CKEditor:CKEditorControl ID="additionalnotes" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <br />
                                </td>
                            </tr>
                            <tr runat="server" id="trCustomAir">
                                <td class="tdlabel">Custom Air:</td>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="customair" RepeatDirection="Horizontal" RepeatLayout="Flow" />&nbsp;&nbsp;&nbsp;
                                    Amount&nbsp;&nbsp;&nbsp;$<asp:TextBox ID="customairamount" runat="server" Width="70px" MaxLength="8" />per person
                                    <asp:CompareValidator id="comv22" runat="server" ControlToValidate="customairamount" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Custom Air amount is invalid" Type="Currency">*</asp:CompareValidator>                            
                                </td>
                            </tr>
                            <tr valign="top" runat="server" id="trSuggCustomAir">
                                <td class="tdlabel">Suggested Custom Air:&nbsp;<span class="required">*</span></td>
                                <td>
		                            <CKEditor:CKEditorControl ID="suggestcustomair" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <asp:requiredfieldvalidator id="reqv8" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="suggestcustomair" ErrorMessage="Suggested custom air is required">*</asp:requiredfieldvalidator>
                                     <br />
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Travel Insurance:&nbsp;<span class="required">*</span></td>
                                <td>
		                            <CKEditor:CKEditorControl ID="travelinsurance" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <asp:requiredfieldvalidator id="reqv9" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="travelinsurance" ErrorMessage="Travel insurance is required">*</asp:requiredfieldvalidator>
                                     <br />
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Disclaimer:&nbsp;<span class="required">*</span></td>
                                <td>
		                            <CKEditor:CKEditorControl ID="disclaimer" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <asp:requiredfieldvalidator id="reqv10" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="disclaimer" ErrorMessage="Disclaimer is required">*</asp:requiredfieldvalidator>
                                     <br />
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Flyer Disclaimer:&nbsp;<span class="required">*</span></td>
                                <td>
		                            <CKEditor:CKEditorControl ID="flyerdisclaimer" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <asp:requiredfieldvalidator id="reqv11" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="flyerdisclaimer" ErrorMessage="Flyer Disclaimer is required">*</asp:requiredfieldvalidator>
                                     <br />
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Call to Action:&nbsp;<span class="required">*</span></td>
                                <td>
		                            <CKEditor:CKEditorControl ID="calltoaction" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                     <asp:requiredfieldvalidator id="reqv12" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="calltoaction" ErrorMessage="Call To Action is required">*</asp:requiredfieldvalidator>
                                     <br />
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Pre:</td>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="pre" RepeatDirection="Horizontal" RepeatLayout="Flow" />
                                    &nbsp;&nbsp;&nbsp;$<asp:TextBox ID="preamount" runat="server" Width="70px" MaxLength="8" />per person
                                    <asp:CompareValidator id="comv23" runat="server" ControlToValidate="preamount" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Pre amount is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    &nbsp;&nbsp;<a href="javascript:includes('pre');" >[Edit Pre-Package Details]</a>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Post:</td>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="post" RepeatDirection="Horizontal" RepeatLayout="Flow" />
                                    &nbsp;&nbsp;&nbsp;$<asp:TextBox ID="postamount" runat="server" Width="70px" MaxLength="8" />per person
                                    <asp:CompareValidator id="comv24" runat="server" ControlToValidate="postamount" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Post amount is invalid" Type="Currency">*</asp:CompareValidator>                            
                                    &nbsp;&nbsp;<a href="javascript:includes('post');" >[Edit Post-Package Details]</a>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Required Passenger Information for Vendor:&nbsp;<span class="required">*</span><br /><span class="remark">(Check all that apply)</span></td>
                                <td><asp:CheckBoxList runat="server" ID="requiredpass" DataTextField="code" /></td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">If Applicable Run 331-day script:</td>
                                <td><asp:CheckBox runat="server" ID="script331" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Agent Notes:</td>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="agentnotes" RepeatDirection="Horizontal" RepeatLayout="Flow" />&nbsp;&nbsp;
                                    <a href="javascript:includes('agentnotes');" >[Edit Agent Notes]</a>
                                </td>
                            </tr>
                            <tr valign="top">
                                <td class="tdlabel">Documentation Required By Traveler For Travel:&nbsp;<span class="required">*</span><br /><span class="remark">(Check all that apply)</span></td>
                                <td>
                                        <table cellpadding="0" cellspacing="0" border="0">
                                        <tr>
                                            <td width="375"><asp:CheckBoxList runat="server" ID="docreq" DataTextField="desc" DataValueField="code" /></td>
                                            <td> <br /><br /><br /><br /><br />
                                                    <asp:textbox id="visa" runat="server" Width="100"  MaxLength="50" /><span class="remark">(Visa Notes)</span><br />
                                                    <asp:textbox id="innoculation" runat="server" Width="100"  MaxLength="50" /><span class="remark">(Innoculation Notes)</span><br />
                                                    <asp:textbox id="docother" runat="server" Width="100"  MaxLength="50" /><span class="remark">(Other Notes)</span><br />
                                            </td>
                                        </tr>
                                        </table>    
                                </td>
                            </tr>
	                    </table>
                    </asp:View>
                    <asp:View ID="viewInstruction" runat="server">
	                    <table cellspacing="1" cellpadding="3" width="840"  border="0">
                            <tr>
                                <td width="175" class="tdlabel">Motor Coach instructions:</td>
                                <td width="650">
                                    <asp:RadioButtonList runat="server" ID="motorcoach" RepeatDirection="Horizontal" RepeatLayout="Flow" />&nbsp;&nbsp;
                                    <a href="javascript:includes('motorCoach');" >[Edit Motor Coach]</a>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Add Air:</td>
                                <td><asp:RadioButtonList runat="server" ID="addair" RepeatDirection="Horizontal" RepeatLayout="Flow" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Transfers Included:</td>
                                <td><asp:RadioButtonList runat="server" ID="transfersincluded" RepeatDirection="Horizontal" RepeatLayout="Flow" /></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Transfer Cost:</td>
                                <td>
                                    <asp:TextBox ID="transferscost" runat="server" Width="75px" MaxLength="8" />
                                    <asp:DropDownList runat="server" ID="transferoption" />
                                    <asp:CompareValidator id="comv25" runat="server" ControlToValidate="transferscost" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Transfer cost is invalid" Type="Double">*</asp:CompareValidator>                            
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2"><br /><b><u>BOOKING INSTRUCTIONS</u></b></td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td class="tdlabel">Contact: </td>
                                <td>
                                    <Telerik:RadLabel ID="lblContactInstruction" runat="server" BackColor="LightGray" ForeColor="Maroon" Width="100%"></Telerik:RadLabel>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:DropDownList runat="server" ID="ddlInstructionType" DataTextField="InstructionCode" OnSelectedIndexChanged="ddlInstructionType_SelectedIndexChanged"
                                        DataValueField="InstructionCode" AutoPostBack="true" Width="400px" ForeColor="GrayText">
                                    </asp:DropDownList>
                                    <asp:CheckBox ID="chkContact" runat="server" Text="Check to Include Vendor Code" AutoPostBack="true" OnCheckedChanged="chkContact_CheckedChanged"/>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                   <%-- <asp:RadioButtonList runat="server" ID="contactinstr" RepeatDirection="Vertical" RepeatLayout="Flow" /><br />--%>
                                    <span class="remark">Other Notes:</span><br />
		                            <CKEditor:CKEditorControl ID="contactinstrother" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td class="tdlabel">Reference IATA #:</td>
                                <td>
                                    <Telerik:RadLabel ID="lblReferenceIATA" runat="server" BackColor="LightGray" ForeColor="Maroon" Width="100%"></Telerik:RadLabel>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:DropDownList runat="server" ID="ddlInstructionIATA" DataTextField="InstructionCode" OnSelectedIndexChanged="ddlInstructionIATA_SelectedIndexChanged"
                                        DataValueField="InstructionCode" AutoPostBack="true" Width="400px" ForeColor="GrayText">
                                    </asp:DropDownList>
                                    <%--<asp:CheckBox ID="chkReferenceIATA" runat="server" Text="Check to Include Vendor Code" AutoPostBack="true" OnCheckedChanged="chkReferenceIATA_CheckedChanged"/>--%>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <%--<asp:RadioButtonList runat="server" ID="iatainstr" RepeatDirection="Vertical" RepeatLayout="Flow" /><br />--%>
                                    <span class="remark">Other Notes:</span><br />
		                            <CKEditor:CKEditorControl ID="iatainstrother" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td class="tdlabel">Reference Phone #:</td>
                                <td><asp:RadioButtonList runat="server" ID="phoneinstr" RepeatDirection="Vertical" RepeatLayout="Flow" /><br />
                                    <span class="remark">Other Notes:</span><br />
                                    <asp:TextBox ID="phoneinstrother" runat="server" Width="625" MaxLength="200" />
                                </td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr valign="top">
                                <td class="tdlabel">Additional Instructions:</td>
                                <td><asp:CheckBoxList runat="server" ID="addlinstr" DataTextField="desc" DataValueField="code" RepeatLayout="Flow" /><br />
                                    <span class="remark">Other Notes:</span><br />
		                            <CKEditor:CKEditorControl ID="addlinstrother" runat="server" Width="650px" Height="65px" BasePath="~/ckeditor" ToolbarCanCollapse="false" ResizeEnabled="false" RemovePlugins="elementspath"
                                        DisableNativeSpellChecker="false"
                                        Toolbar="|Source|-|Bold|Italic|Underline|-|JustifyLeft|JustifyCenter|JustifyRight|-|NumberedList|BulletedList|-|Outdent|Indent|-|Font|FontSize|TextColor|BGColor|-|Link|">
		                            </CKEditor:CKEditorControl>
                                </td>
                            </tr>
                        </table>
                    </asp:View>
                </asp:MultiView>
                </asp:Panel>
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

<script type="text/javascript">
function preventMoreDecimalPlaces(sender, args)
{
        var separatorPos = sender._textBoxElement.value.indexOf(sender.get_numberFormat().DecimalSeparator);
        if (args.get_keyCharacter().match(/[0-9]/) &&
            separatorPos != -1 &&
            sender.get_caretPosition() > separatorPos + sender.get_numberFormat().DecimalDigits)
            {
                args.set_cancel(true);
            }
        }

    function FromAndToDateValidate()
    {
        try
        {
            var StartDate = $find("<%=rdpFrom.SelectedDate.Value%>")
            var EndDate = $find("<%=rdpTo.SelectedDate.Value%>")

                
            args.IsValid = (StartDate < EndDate);
        }
        catch (ex)
        {
           alert(ex);
        }
    }



</script>

</asp:Content> 