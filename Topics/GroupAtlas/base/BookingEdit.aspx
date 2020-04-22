<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script language="C#" runat="server">

    int bookingid
    {
        get { return Convert.ToInt32(ViewState["bookingid"]); }
        set { ViewState["bookingid"] = value.ToString(); }
    }
    string groupid
    {
        get { return ViewState["groupid"].ToString(); }
        set { ViewState["groupid"] = value; }
    }
    decimal totDue
    {
        get { return Util.parseDec(ViewState["totdue"]); }
        set { ViewState["totdue"] = value; }
    }
    string packageType
    {
        get { return ViewState["packagetype"].ToString(); }
        set { ViewState["packagetype"] = value; }
    }
    string packageType2
    {
        get { return ViewState["packagetype2"].ToString(); }
        set { ViewState["packagetype2"] = value; }
    }
    string revtype
    {
        get { return ViewState["revtype"].ToString(); }
        set { ViewState["revtype"] = value; }
    }
    int passengerid
    {
        get { return Convert.ToInt32(ViewState["passengerid"]); }
        set { ViewState["passengerid"] = value.ToString(); }
    }
    int passengerid2
    {
        get { return Convert.ToInt32(ViewState["passengerid2"]); }
        set { ViewState["passengerid2"] = value.ToString(); }
    }
    int passengerid3
    {
        get { return Convert.ToInt32(ViewState["passengerid3"]); }
        set { ViewState["passengerid3"] = value.ToString(); }
    }
    int passengerid4
    {
        get { return Convert.ToInt32(ViewState["passengerid4"]); }
        set { ViewState["passengerid4"] = value.ToString(); }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            // Init
            bookingid = Util.parseInt(Request.QueryString["bookingid"]);
            GroupBooking b = GroupBooking.GetBooking(bookingid);
            if (b == null)
                Response.Redirect("BookingList.aspx?msg=Booking not found");
            groupid = b.groupID;
            if (b.status == Convert.ToString('W'))
            {
                chkWaitList.Checked = true;
            }

            message.InnerHtml = Request.QueryString["msg"];
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            revtype = g.RevType;

            // Package/Options
            Lookup.FillDropDown(agentflexid, PickList.GetTravelAgent(b.agentFlexID), b.agentFlexID.ToString(), " ");
            Lookup.FillNumber(paxcnt, b.paxCnt, 1, 4, "");
            InitPackageType();
            paxcnt_SelectedIndexChanged(null, EventArgs.Empty);
            foreach (Bill l in b.billList)
            {
                if (l.packageid > 0)
                {
                    if (packageid.Items.FindByValue(l.packageid.ToString()) != null)
                        packageid.Items.FindByValue(l.packageid.ToString()).Selected = true;
                    if (packageid2.Items.FindByValue(l.packageid.ToString()) != null)
                        packageid2.Items.FindByValue(l.packageid.ToString()).Selected = true;
                }
            }
            List<GroupOption> optList = GroupOption.GetOption(groupid);
            optionlist.Items.Clear();
            foreach (GroupOption o in optList)
            {
                decimal rate = GroupPackage.GetOptionRate(o, b.paxCnt);
                decimal commission = GroupPackage.GetOptionCommission(o, b.paxCnt);
                string strOption = string.Format("{0}&nbsp;&nbsp;</td><td align=\"right\">{1}&nbsp;&nbsp;per person", o.optionName, rate.ToString("c"));
                ListItem itm = new ListItem(strOption, o.optionID.ToString());
                if (o.isRequired)
                {
                    itm.Selected = true;
                    itm.Enabled = false;
                }
                foreach (Bill l in b.billList)
                {
                    if (l.optionid == o.optionID)
                        itm.Selected = true;
                }
                optionlist.Items.Add(itm);
            }

            // Pax #1
            passengerid = 0;
            string sState = "";
            string sGender = "";
            if (b.paxList.Count > 0)
            {
                passengerid = b.paxList[0].passengerID;
                firstname.Text = b.paxList[0].firstName;
                txtMiddleName.Text = b.paxList[0].middleName;
                lastname.Text = b.paxList[0].lastName;
                badgename.Text = b.paxList[0].badgeName;
                address.Text = b.paxList[0].address;
                city.Text = b.paxList[0].city;
                zip.Text = b.paxList[0].zip;
                email.Text = b.paxList[0].email;
                homephone.Text = b.paxList[0].homePhone;
                cellphone.Text = b.paxList[0].cellPhone;
                //birthdate.Text = b.paxList[0].birthDate;
                birthdate.SelectedDate = Convert.ToDateTime(b.paxList[0].birthDate);
                emername.Text = b.paxList[0].emerName;
                emerphone.Text = b.paxList[0].emerPhone;
                emerrelation.Text = b.paxList[0].emerRelation;
                sState = b.paxList[0].state;
                sGender = b.paxList[0].gender;
            }
            Lookup.FillDropDown(state, PickList.GetState(), sState, " ");
            Lookup.FillDropDown(gender, PickList.GetGender(), sGender, " ");

            // Pax #2
            passengerid2 = 0;
            string sState2 = "";
            string sGender2 = "";
            if (b.paxList.Count > 1)
            {
                passengerid2 = b.paxList[1].passengerID;
                firstname2.Text = b.paxList[1].firstName;
                txtMiddleName2.Text = b.paxList[1].middleName;
                lastname2.Text = b.paxList[1].lastName;
                badgename2.Text = b.paxList[1].badgeName;
                address2.Text = b.paxList[1].address;
                city2.Text = b.paxList[1].city;
                zip2.Text = b.paxList[1].zip;
                email2.Text = b.paxList[1].email;
                homephone2.Text = b.paxList[1].homePhone;
                cellphone2.Text = b.paxList[1].cellPhone;
                //birthdate2.Text = b.paxList[1].birthDate;
                birthdate2.SelectedDate = Convert.ToDateTime(b.paxList[1].birthDate);
                emername2.Text = b.paxList[1].emerName;
                emerphone2.Text = b.paxList[1].emerPhone;
                emerrelation2.Text = b.paxList[1].emerRelation;
                sState2 = b.paxList[1].state;
                sGender2 = b.paxList[1].gender;
            }
            Lookup.FillDropDown(state2, PickList.GetState(), sState2, " ");
            Lookup.FillDropDown(gender2, PickList.GetGender(), sGender2, " ");

            // Pax #3
            passengerid3 = 0;
            string sState3 = "";
            string sGender3 = "";
            if (b.paxList.Count > 2)
            {
                passengerid3 = b.paxList[2].passengerID;
                firstname3.Text = b.paxList[2].firstName;
                txtMiddleName3.Text = b.paxList[2].middleName;
                lastname3.Text = b.paxList[2].lastName;
                badgename3.Text = b.paxList[2].badgeName;
                address3.Text = b.paxList[2].address;
                city3.Text = b.paxList[2].city;
                zip3.Text = b.paxList[2].zip;
                email3.Text = b.paxList[2].email;
                homephone3.Text = b.paxList[2].homePhone;
                cellphone3.Text = b.paxList[2].cellPhone;
                //birthdate3.Text = b.paxList[2].birthDate;
                birthdate3.SelectedDate = Convert.ToDateTime(b.paxList[2].birthDate);
                emername3.Text = b.paxList[2].emerName;
                emerphone3.Text = b.paxList[2].emerPhone;
                emerrelation3.Text = b.paxList[2].emerRelation;
                sState3 = b.paxList[2].state;
                sGender3 = b.paxList[2].gender;
            }
            Lookup.FillDropDown(state3, PickList.GetState(), sState3, " ");
            Lookup.FillDropDown(gender3, PickList.GetGender(), sGender3, " ");

            // Pax #4
            passengerid4 = 0;
            string sState4 = "";
            string sGender4 = "";
            if (b.paxList.Count > 3)
            {
                passengerid4 = b.paxList[3].passengerID;
                firstname4.Text = b.paxList[3].firstName;
                txtMiddleName4.Text = b.paxList[3].middleName;
                lastname4.Text = b.paxList[3].lastName;
                badgename4.Text = b.paxList[3].badgeName;
                address4.Text = b.paxList[3].address;
                city4.Text = b.paxList[3].city;
                zip4.Text = b.paxList[3].zip;
                email4.Text = b.paxList[3].email;
                homephone4.Text = b.paxList[3].homePhone;
                cellphone4.Text = b.paxList[3].cellPhone;
                //birthdate4.Text = b.paxList[3].birthDate;
                birthdate4.SelectedDate = Convert.ToDateTime(b.paxList[3].birthDate);
                emername4.Text = b.paxList[3].emerName;
                emerphone4.Text = b.paxList[3].emerPhone;
                emerrelation4.Text = b.paxList[3].emerRelation;
                sState4 = b.paxList[3].state;
                sGender4 = b.paxList[3].gender;
            }
            Lookup.FillDropDown(state4, PickList.GetState(), sState4, " ");
            Lookup.FillDropDown(gender4, PickList.GetGender(), sGender4, " ");

            // Header
            string strDate = (g.DepartDate == g.ReturnDate) ? g.DepartDate : string.Format("{0} to {1}", g.DepartDate, g.ReturnDate);
            hdr.InnerHtml = string.Format("Edit Booking ID: {0} &nbsp;&nbsp;&nbsp;{1}-{2} &nbsp;&nbsp;&nbsp;[{3}]", bookingid, g.GroupID, g.GroupName, strDate);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}';return false;", bookingid);
        }
        // Passenger Questions
        List<Question> queslist = Question.GetPaxQuestions(passengerid, revtype, groupid);
        foreach (Question q in queslist)
        {
            customFields.Controls.Add(new LiteralControl(string.Format("<tr valign=top><td class=\"tdlabel\" width=\"125\">{0}:</td><td>", q.questionName)));
            Custom.AddControl(customFields, "QUES_" + q.questionID, q.answer, q.type, q.list, 200);
            customFields.Controls.Add(new LiteralControl("</td></tr>"));
        }
        queslist = Question.GetPaxQuestions(passengerid2, revtype, groupid);
        foreach (Question q in queslist)
        {
            customFields2.Controls.Add(new LiteralControl(string.Format("<tr valign=top><td class=\"tdlabel\" width=\"125\">{0}:</td><td>", q.questionName)));
            Custom.AddControl(customFields2, "QUES2_" + q.questionID, q.answer, q.type, q.list, 200);
            customFields2.Controls.Add(new LiteralControl("</td></tr>"));
        }
        queslist = Question.GetPaxQuestions(passengerid3, revtype, groupid);
        foreach (Question q in queslist)
        {
            customFields3.Controls.Add(new LiteralControl(string.Format("<tr valign=top><td class=\"tdlabel\" width=\"125\">{0}:</td><td>", q.questionName)));
            Custom.AddControl(customFields3, "QUES3_" + q.questionID, q.answer, q.type, q.list, 200);
            customFields3.Controls.Add(new LiteralControl("</td></tr>"));
        }
        queslist = Question.GetPaxQuestions(passengerid4, revtype, groupid);
        foreach (Question q in queslist)
        {
            customFields4.Controls.Add(new LiteralControl(string.Format("<tr valign=top><td class=\"tdlabel\" width=\"125\">{0}:</td><td>", q.questionName)));
            Custom.AddControl(customFields4, "QUES4_" + q.questionID, q.answer, q.type, q.list, 200);
            customFields4.Controls.Add(new LiteralControl("</td></tr>"));
        }
    }

    protected void InitPackageType()
    {
        List<PickList> list = GroupPackage.GetPackageTypeList(groupid);
        packageType = (list.Count > 0) ? list[0].code : "";
        packageType2 = (list.Count > 1) ? list[1].code : "";
        tdpackagetype.InnerHtml = (list.Count > 0) ? list[0].desc : "Package:";
        tdpackagetype2.InnerHtml = (list.Count > 1) ? list[1].desc : "Package 2:";
        trpackagetype2.Visible = (packageType2 == "") ? false : true;
    }

    protected void paxcnt_SelectedIndexChanged(object sender, EventArgs e)
    {
        int iPaxCnt = Util.parseInt(paxcnt.SelectedValue);
        // Package #1
        string strPackageID = packageid.SelectedValue;
        List<GroupPackage> pkgList = GroupPackage.GetPackage(groupid, packageType);
        packageid.Items.Clear();
        foreach (GroupPackage p in pkgList)
        {
            decimal rate = GroupPackage.GetTotalRate(p, iPaxCnt);
            string strPkg = string.Format("{0}&nbsp;&nbsp;</td><td align=\"right\">{1}&nbsp;&nbsp;&nbsp;({2} available)", p.packageName, rate.ToString("c"), p.available);
            ListItem itm = new ListItem(strPkg, p.packageID.ToString());
            packageid.Items.Add(itm);
        }
        if (packageid.Items.FindByValue(strPackageID) != null)
            packageid.Items.FindByValue(strPackageID).Selected = true;

        //. Package #2
        string strPackageID2 = packageid2.SelectedValue;
        List<GroupPackage> pkgList2 = GroupPackage.GetPackage(groupid, packageType2);
        packageid2.Items.Clear();
        foreach (GroupPackage p in pkgList2)
        {
            decimal rate = GroupPackage.GetTotalRate(p, iPaxCnt);
            string strPkg = string.Format("{0}&nbsp;&nbsp;</td><td align=\"right\">{1}&nbsp;&nbsp;&nbsp;({2} available)", p.packageName, rate.ToString("c"), p.available);
            ListItem itm = new ListItem(strPkg, p.packageID.ToString());
            packageid2.Items.Add(itm);
        }
        if (packageid2.Items.FindByValue(strPackageID2) != null)
            packageid2.Items.FindByValue(strPackageID2).Selected = true;

        //reset the option items.
        List<GroupOption> optList = GroupOption.GetOption(groupid);
        optionlist.Items.Clear();
        foreach (GroupOption o in optList)
        {
            decimal rate = GroupPackage.GetOptionRate(o, iPaxCnt);
            decimal commission = GroupPackage.GetOptionCommission(o, iPaxCnt);

            string strOption = string.Format("{0}&nbsp;&nbsp;</td><td align=\"right\">{1}&nbsp;&nbsp;&nbsp;per person", o.optionName, rate.ToString("c"));
            ListItem itm = new ListItem(strOption, o.optionID.ToString());
            if (o.isRequired)
            {
                itm.Selected = true;
                itm.Enabled = false;
            }
            optionlist.Items.Add(itm);
        }
    }

    protected void BookingWizard_ActiveStepChanged(object sender, EventArgs e)
    {
        if (BookingWizard.ActiveStep.Equals(stepSumry))
        {
            // Bill
            List<Bill> bilList = BuildBill();
            billlist.DataSource = bilList;
            billlist.DataBind();
            totDue = 0;
            foreach (Bill b in bilList)
                totDue += b.amount;

            // Passengers
            List<Passenger> paxList = BuildPax();
            paxlist.DataSource = paxList;
            paxlist.DataBind();
        }
    }

    protected void BookingWizard_FinishButtonClick(object sender, WizardNavigationEventArgs e)
    {
        GroupBooking b = GroupBooking.GetBooking(bookingid);
        b.paxCnt = Util.parseInt(paxcnt.SelectedValue);
        b.agentFlexID = Util.parseInt(agentflexid.SelectedValue);
        b.paxList = BuildPax();
        b.billList = BuildBill();
        GroupBooking.Update(b);
        if (chkWaitList.Checked == true)
        {
            GroupBooking.UpdateStatus(bookingid, b.agentFlexID, Convert.ToString('W'));
        }
        else
        {
            GroupBooking.UpdateStatus(bookingid, b.agentFlexID, Convert.ToString('A'));
        }

        Response.Redirect("BookingView.aspx?bookingid=" + bookingid);
    }

    protected void BookingWizard_NextButtonClick(object sender, WizardNavigationEventArgs e)
    {
        if (!Page.IsValid)
        {
            e.Cancel = true;
            return;
        }
        Wizard w = (Wizard)sender;
        int iPaxCnt = Util.parseInt(paxcnt.SelectedValue);
        if (w.ActiveStepIndex == w.WizardSteps.IndexOf(stepPax1) && iPaxCnt < 2)    // Pax1 moving to Pax2
            w.ActiveStepIndex = w.WizardSteps.IndexOf(stepSumry);
        else if (w.ActiveStepIndex == w.WizardSteps.IndexOf(stepPax2) && iPaxCnt < 3)    // Pax2 moving to Pax3
            w.ActiveStepIndex = w.WizardSteps.IndexOf(stepSumry);
        else if (w.ActiveStepIndex == w.WizardSteps.IndexOf(stepPax3) && iPaxCnt < 4)    // Pax3 moving to Pax4
            w.ActiveStepIndex = w.WizardSteps.IndexOf(stepSumry);
    }

    private List<Bill> BuildBill()
    {
        List<Bill> list = new List<Bill>();
        int iPaxCnt = Util.parseInt(paxcnt.SelectedValue);

        // Package #1
        int iPackageID = Util.parseInt(packageid.SelectedValue);
        GroupPackage p = GroupPackage.GetPackage(iPackageID, groupid);
        for (int i=0; i < iPaxCnt; i++)
        {
            int iPaxNum = i + 1;
            decimal rate = GroupPackage.GetPaxRate(p, iPaxCnt, iPaxNum);
            decimal commission = GroupPackage.GetCommission(p, iPaxCnt, iPaxNum);
            string sDesc = string.Format("{0} - Individual #{1}", p.packageName, iPaxNum);
            list.Add(new Bill(0, 0, sDesc, rate, 1, iPackageID, 0, commission));
        }

        // Package #2
        if (packageType2 != "")
        {
            iPackageID = Util.parseInt(packageid2.SelectedValue);
            p = GroupPackage.GetPackage(iPackageID, groupid);
            for (int i=0; i < iPaxCnt; i++)
            {
                int iPaxNum = i + 1;
                decimal rate = GroupPackage.GetPaxRate(p, iPaxCnt, iPaxNum);
                decimal commission = GroupPackage.GetCommission(p, iPaxCnt, iPaxNum);
                string sDesc = string.Format("{0} - Individual #{1}", p.packageName, iPaxNum);
                list.Add(new Bill(0, 0, sDesc, rate, 1, iPackageID, 0, commission));
            }
        }

        // Options
        foreach (ListItem itm in optionlist.Items)
        {
            if (itm.Selected)
            {
                int optionid = Convert.ToInt32(itm.Value);
                GroupOption o = GroupOption.GetOption(optionid, groupid);

                decimal rate = GroupPackage.GetOptionRate(o, iPaxCnt);
                decimal commission = GroupPackage.GetOptionCommission(o, iPaxCnt);

                list.Add(new Bill(0, 0, o.optionName, rate, iPaxCnt, 0, o.optionID, commission));
            }
        }
        return list;
    }


    private List<Passenger> BuildPax()
    {
        int iPaxCnt = Util.parseInt(paxcnt.SelectedValue);
        List<Passenger> list = new List<Passenger>();

        // Primary Pax
        Passenger p = new Passenger();
        p.firstName = firstname.Text;
        p.lastName = lastname.Text;
        p.middleName = txtMiddleName.Text;
        p.badgeName = badgename.Text;
        p.address = address.Text;
        p.city = city.Text;
        p.state = state.SelectedValue;
        p.zip = zip.Text;
        p.email = email.Text;
        p.homePhone = homephone.Text;
        p.cellPhone = cellphone.Text;
        p.gender = gender.SelectedValue;
        //p.birthDate = birthdate.Text;
        p.birthDate =  Convert.ToString(birthdate.SelectedDate);
        p.isPrimary = true;
        p.emerName = emername.Text;
        p.emerPhone = emerphone.Text;
        p.emerRelation = emerrelation.Text;
        p.paxQuestions = BuildPaxQues("QUES_");
        list.Add(p);

        // Pax #2
        if (iPaxCnt > 1)
        {
            p = new Passenger();
            p.firstName = firstname2.Text;
            p.middleName = txtMiddleName2.Text;
            p.lastName = lastname2.Text;
            p.badgeName = badgename2.Text;
            p.address = address2.Text;
            p.city = city2.Text;
            p.state = state2.SelectedValue;
            p.zip = zip2.Text;
            p.email = email2.Text;
            p.homePhone = homephone2.Text;
            p.cellPhone = cellphone2.Text;
            p.gender = gender2.SelectedValue;
            //p.birthDate = birthdate2.Text;
            p.birthDate =  Convert.ToString(birthdate2.SelectedDate);
            p.isPrimary = false;
            p.emerName = emername2.Text;
            p.emerPhone = emerphone2.Text;
            p.emerRelation = emerrelation2.Text;
            p.paxQuestions = BuildPaxQues("QUES2_");
            list.Add(p);
        }

        // Pax #3
        if (iPaxCnt > 2)
        {
            p = new Passenger();
            p.firstName = firstname3.Text;
            p.middleName = txtMiddleName3.Text;
            p.lastName = lastname3.Text;
            p.badgeName = badgename3.Text;
            p.address = address3.Text;
            p.city = city3.Text;
            p.state = state3.SelectedValue;
            p.zip = zip3.Text;
            p.email = email3.Text;
            p.homePhone = homephone3.Text;
            p.cellPhone = cellphone3.Text;
            p.gender = gender3.SelectedValue;
            //p.birthDate = birthdate3.Text;
            p.birthDate =  Convert.ToString(birthdate3.SelectedDate);
            p.isPrimary = false;
            p.emerName = emername3.Text;
            p.emerPhone = emerphone3.Text;
            p.emerRelation = emerrelation3.Text;
            p.paxQuestions = BuildPaxQues("QUES3_");
            list.Add(p);
        }

        // Pax #4
        if (iPaxCnt > 3)
        {
            p = new Passenger();
            p.firstName = firstname4.Text;
            p.middleName = txtMiddleName3.Text;
            p.lastName = lastname4.Text;
            p.badgeName = badgename4.Text;
            p.address = address4.Text;
            p.city = city4.Text;
            p.state = state4.SelectedValue;
            p.zip = zip4.Text;
            p.email = email4.Text;
            p.homePhone = homephone4.Text;
            p.cellPhone = cellphone4.Text;
            p.gender = gender4.SelectedValue;
            //p.birthDate = birthdate4.Text;
            p.birthDate =  Convert.ToString(birthdate4.SelectedDate);
            p.isPrimary = false;
            p.emerName = emername4.Text;
            p.emerPhone = emerphone4.Text;
            p.emerRelation = emerrelation4.Text;
            p.paxQuestions = BuildPaxQues("QUES4_");
            list.Add(p);
        }

        return list;
    }

    private List<PaxQuestion> BuildPaxQues(string prefix)
    {
        List<PaxQuestion> quesList = new List<PaxQuestion>();
        List<Question> list = Question.GetPaxQuestions(0, revtype, groupid);
        foreach (Question q in list)
        {
            Control c = customFields.FindControl(prefix + q.questionID);
            string answer = Custom.CustomValue(c);
            PaxQuestion pq = new PaxQuestion(q.questionID, q.questionName, answer);
            quesList.Add(pq);
        }
        return quesList;
    }

    protected void CustomValidator1_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = true;
        GroupMaster g = GroupMaster.GetGroupMaster(groupid);
        if (g.IsSellOverAlloc)
            return;
        //Commented by Vlad - based on request to be able to edit if limit has been reached.
        if (g.MaxPassengers > 0)
        {
            int bookedPax = GroupBooking.GetPaxBooked(groupid);
            if ((bookedPax + Convert.ToInt32(paxcnt.SelectedValue)) > g.MaxPassengers)
            {
                if (chkWaitList.Checked == false)
                {
                    args.IsValid = false;
                    CustomValidator1.ErrorMessage = string.Format("Cannot proceed! The maximum number of passengers available for this group is {0}", g.MaxPassengers);
                    return;
                }
            }
        }

        GroupPackage p = GroupPackage.GetPackage(Util.parseInt(packageid.SelectedValue), groupid);
        if (p == null)
        {
            args.IsValid = false;
            //CustomValidator1.ErrorMessage = "There are no packages defined for the selected group";
            return;
        }
        if (p.available < 1)
        {
            if (chkWaitList.Checked == false)
            {
                args.IsValid = false;
                CustomValidator1.ErrorMessage = "There are no availability for the selected package";
                return;
            }
        }
        if (packageid2.Visible)
        {
            p = GroupPackage.GetPackage(Util.parseInt(packageid2.SelectedValue), groupid);
            if (p.available < 1)
            {
                if (chkWaitList.Checked == false)
                {
                    args.IsValid = false;
                    CustomValidator1.ErrorMessage = "There are no availability for the selected package";
                }
            }
        }

    }

    protected void birthdate_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Passenger p = new Passenger();
        p.birthDate = Convert.ToString(birthdate.SelectedDate);
    }
    protected void birthdate2_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Passenger p = new Passenger();
        p.birthDate = Convert.ToString(birthdate2.SelectedDate);
    }
    protected void birthdate3_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Passenger p = new Passenger();
        p.birthDate = Convert.ToString(birthdate3.SelectedDate);
    }
    protected void birthdate4_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Passenger p = new Passenger();
        p.birthDate = Convert.ToString(birthdate4.SelectedDate);
    }

    protected void CustomValidator2_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = true;
        GroupMaster g = GroupMaster.GetGroupMaster(groupid);
        if (g.IsSellOverAlloc)
            return;

        if (g.MaxPassengers > 0)
        {
            int bookedPax = GroupBooking.GetPaxBooked(groupid);
            if ((bookedPax + Convert.ToInt32(paxcnt.SelectedValue)) > g.MaxPassengers)
            {
                if (chkWaitList.Checked == false)
                {
                    args.IsValid = false;
                    CustomValidator2.ErrorMessage = string.Format("Select and add passengers to [Wait List] to continue.", g.MaxPassengers);
                    return;
                }
            }
        }
        GroupPackage p = GroupPackage.GetPackage(Util.parseInt(packageid.SelectedValue), groupid);
        if (p == null)
        {
            //if (chkWaitList.Checked == false)
            //{
            args.IsValid = false;
            //CustomValidator2.ErrorMessage = "Select and add passengers to [Wait List] to continue.";
            return;
            //}
        }
        if (p.available < 1)
        {
            if (chkWaitList.Checked == false)
            {
                args.IsValid = false;
                CustomValidator2.ErrorMessage = "Select and add passengers to [Wait List] to continue.";
                return;
            }
        }
        if (packageid2.Visible)
        {
            p = GroupPackage.GetPackage(Util.parseInt(packageid2.SelectedValue), groupid);
            if (p.available < 1)
            {
                if (chkWaitList.Checked == false)
                {
                    args.IsValid = false;
                    CustomValidator2.ErrorMessage = "Select and add passengers to [Wait List] to continue.";
                }
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Booking</td>
			<td align="right"><asp:button id="cancel" runat="server" Text="Cancel" UseSubmitBehavior="false" CssClass="button" CausesValidation="False"></asp:button>&nbsp;</td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span><br>
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:"
					CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
    <br />
    <asp:Wizard ID="BookingWizard" runat="server" ActiveStepIndex="0" BackColor="#EFF3FB"  
        BorderColor="#B5C7DE" BorderWidth="1px" Font-Names="Verdana" 
        CellPadding="5" Width="950px"
        Font-Size="0.8em" onfinishbuttonclick="BookingWizard_FinishButtonClick" 
        onactivestepchanged="BookingWizard_ActiveStepChanged" 
        onnextbuttonclick="BookingWizard_NextButtonClick">
        <HeaderStyle BackColor="#284E98" BorderColor="#EFF3FB" BorderStyle="Solid" BorderWidth="2px" Font-Bold="True" Font-Size="0.9em" ForeColor="White" HorizontalAlign="Center" />
        <NavigationButtonStyle BackColor="Black" BorderColor="#507CD1" BorderStyle="Solid" BorderWidth="1px" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#284E98" />
        <SideBarButtonStyle BackColor="Maroon" Font-Names="Verdana" ForeColor="Black" Height="25px" />
        <SideBarStyle BackColor="#ffcc66" Font-Size="0.9em" VerticalAlign="Top" Width="150px" />
        <StepStyle Font-Size="1em" ForeColor="#333333" VerticalAlign="Top" />
        <SideBarTemplate>
    	    <asp:DataList ID="SideBarList" runat="server">
    		    <ItemTemplate>
    			    <asp:LinkButton ID="SideBarButton" runat="server"  Enabled="false" />
    		    </ItemTemplate>
    		    <SelectedItemTemplate>
                    <asp:LinkButton ID="SideBarButton" runat="server" Enabled="false" Font-Bold="true" BackColor="Maroon" Width="125px" />
    		    </SelectedItemTemplate>
    	    </asp:DataList>
        </SideBarTemplate>
        <StartNavigationTemplate>
             <table cellpadding="3" cellspacing="3">
                 <tr>
                        <td>
                            <asp:Button ID="btnNext" runat="server" Text="Next >>"  Width="100px" CausesValidation="true" CommandName="MoveNext"  />
                         </td>
                 </tr>
             </table>
         </StartNavigationTemplate>
         <StepNavigationTemplate>
             <table cellpadding="3" cellspacing="3">
                 <tr>
                     <td>
                            <asp:Button ID="btnPrevious" runat="server" Text="<< Previous"  Width="100px" CausesValidation="false" CommandName="MovePrevious" />
                            <asp:Button ID="btnNext" runat="server" Text="Next >>"  Width="100px" CausesValidation="true" CommandName="MoveNext" />
                     </td>
                 </tr>
             </table>
         </StepNavigationTemplate>
         <FinishNavigationTemplate>
             <table cellpadding="3" cellspacing="3">
                 <tr>
                     <td>
                          <asp:Button ID="btnPrevious" runat="server" Text="<< Previous"  Width="100px" CausesValidation="false" CommandName="MovePrevious" />
                          <asp:Button ID="btnFinish" runat="server" Text="Save"  Width="100px" CausesValidation="true" CommandName="MoveComplete" />
                     </td>
                 </tr>
             </table>
         </FinishNavigationTemplate>

        <WizardSteps>
            <asp:WizardStep ID="stepPackage" runat="server" title="Package / Options"  StepType="Start">
                <h1>Package / Options</h1>
                <table cellpadding="3" cellspacing="1">
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td class="tdlabel" width="150">Agent:</td>
                        <td><asp:DropDownList runat="server" ID="agentflexid" Width="300px" /></td>
                        <td>
                            <asp:CheckBox ID="chkWaitList" runat="server" Text="Wait List" />
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="tdlabel">No. of Passengers:</td>
                        <td>
                            <asp:DropDownList ID="paxcnt" runat="server" Width="100px" OnSelectedIndexChanged="paxcnt_SelectedIndexChanged" AutoPostBack="True" />
                            <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="paxcnt" ErrorMessage="Number of passengers is required">*</asp:requiredfieldvalidator>
                            <asp:CustomValidator ID="CustomValidator1" runat="server" Display="Dynamic" CssClass="error"  ControlToValidate="paxcnt"
                                 OnServerValidate="CustomValidator1_ServerValidate">*</asp:CustomValidator>
                            <asp:CustomValidator ID="CustomValidator2" runat="server" Display="None" CssClass="error"  ControlToValidate="paxcnt"
                                OnServerValidate="CustomValidator2_ServerValidate"></asp:CustomValidator>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="tdlabel" runat="server" id="tdpackagetype">Package:</td>
                        <td>
                            <asp:RadioButtonList ID="packageid" runat="server" CellPadding="3" CellSpacing="0" ></asp:RadioButtonList>
                            <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packageid" ErrorMessage="Package is required">*</asp:requiredfieldvalidator>
                        </td>
                    </tr>
                    <tr valign="top" runat="server" id="trpackagetype2" visible="false">
                        <td class="tdlabel" runat="server" id="tdpackagetype2">Package 2:</td>
                        <td>
                            <asp:RadioButtonList ID="packageid2" runat="server" CellPadding="3" CellSpacing="0" ></asp:RadioButtonList>
                            <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="packageid2" ErrorMessage="Package #2 is required">*</asp:requiredfieldvalidator>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="tdlabel">Options:</td>
                        <td>
                            <asp:CheckBoxList ID="optionlist" runat="server" CellPadding="3" CellSpacing="0" ></asp:CheckBoxList>
                        </td>
                    </tr>
                </table>
                <p>&nbsp;</p>
                <p>&nbsp;</p>
                <p>&nbsp;</p>
            </asp:WizardStep>
            <asp:WizardStep ID="stepPax1" runat="server" title="Primary Passenger" StepType="Step">
                <h1>Primary Passenger</h1>
                <table cellpadding="0" cellspacing="0" border="0">
                <tr><td>&nbsp;</td></tr>
                <tr valign="top">
                    <td>
	                    <table cellspacing="0" cellpadding="3" border="0">
                            <tr>
                                <td width="125" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="firstname" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Middle Name:&nbsp;</td>
                                <td><asp:textbox id="txtMiddleName" runat="server" Width="250px"  MaxLength="50"></asp:textbox>                            
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="lastname" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator5" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Badge Name:&nbsp;</td>
                                <td><asp:textbox id="badgename" runat="server" Width="250px"  MaxLength="50"></asp:textbox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Gender:&nbsp;<span class="required">*</span></td>
                                <td><asp:DropDownList ID="gender" Width="150px" runat="server"></asp:DropDownList>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator9" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="gender" ErrorMessage="Gender is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Date of Birth:&nbsp;<span class="required">*</span></td>
                                <td>
                                    <%--<asp:TextBox ID="birthdate" MaxLength="10" Width="150px" runat="server"></asp:TextBox>
                                    &nbsp;<span class="remarks">(mm/dd/yyyy)</span>--%>
                                    <telerik:radDatePicker RenderMode="Lightweight" ID="birthdate" Width="120px" runat="server" OnSelectedDateChanged="birthdate_SelectedDateChanged" SkipMinMaxDateValidationOnServer="false"
                                       MinDate="01/01/1901 00:00:00">
                                        <Calendar ShowRowHeaders="false"></Calendar>
                                    </telerik:radDatePicker>&nbsp;<span class="remarks">(mm/dd/yyyy)</span>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator7" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="birthdate" ErrorMessage="Date of Birth is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="birthdate"
                                        CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Date of birth is invalid" Type="Date">*</asp:CompareValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Email Address:&nbsp;</td>
                                <td><asp:TextBox ID="email" MaxLength="100" Width="250px" runat="server"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ControlToValidate="email"
                                        CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Address:</td>
                                <td><asp:TextBox ID="address" runat="server" Width="250px" MaxLength="100"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">City:</td>
                                <td><asp:TextBox ID="city" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">State:&nbsp;</td>
                                <td class="tdtext"><asp:DropDownList ID="state" Width="150px" runat="server"></asp:DropDownList></td>
                            </tr>
	                    <tr>
	                         <td class="tdlabel">Zip Code:</td>
	                         <td><asp:textbox id="zip" runat="server" MaxLength="10" Width="150px" ></asp:textbox>
			                    <asp:regularexpressionvalidator id="Regularexpressionvalidator2" runat="server" CssClass="error" Display="Dynamic"
		                    ControlToValidate="zip" ErrorMessage="Zip Code is invalid" ValidationExpression=" *\d{5}(-?\d{4})? *">*</asp:regularexpressionvalidator>
		                    </td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Home Phone:</td>
		                    <td>
                               <%-- <asp:textbox id="homephone" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="homephone" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator3" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="homephone" ErrorMessage="Home phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Cell Phone:</td>
		                    <td>
                                <%--<asp:textbox id="cellphone" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="cellphone" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator5" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="cellphone" ErrorMessage="Cell phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
                            <tr>
                                <td class="tdlabel">Emergency Name:</td>
                                <td><asp:TextBox ID="emername" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Emergency Relation:</td>
                                <td><asp:TextBox ID="emerrelation" runat="server" Width="150px" MaxLength="25"></asp:TextBox></td>
                            </tr>
	                    <tr>
		                    <td class="tdlabel">Emergency Phone:</td>
		                    <td>
                                <%--<asp:textbox id="emerphone" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="emerphone" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator7" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="emerphone" ErrorMessage="Emergency phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    </table>
                    </td>    
                    <td width="25">&nbsp;</td>
                    <td>
                        <table cellpadding="2" cellspacing="0">
	                        <asp:PlaceHolder ID="customFields" Runat="server"></asp:PlaceHolder>
                        </table>
                    </td>
                </tr>
                </table>
                <p>&nbsp;</p>
            </asp:WizardStep>
            <asp:WizardStep ID="stepPax2" runat="server" title="Passenger #2" StepType="Step">
                <h1>Passenger #2</h1>
                <table cellpadding="0" cellspacing="0" border="0">
                <tr><td>&nbsp;</td></tr>
                <tr valign="top">
                    <td>
	                    <table cellspacing="0" cellpadding="3" border="0">
                            <tr>
                                <td width="125" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="firstname2" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator62" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname2" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Middle Name:&nbsp;</td>
                                <td><asp:textbox id="txtMiddleName2" runat="server" Width="250px"  MaxLength="50"></asp:textbox>                            
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="lastname2" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator52" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname2" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Badge Name:&nbsp;</td>
                                <td><asp:textbox id="badgename2" runat="server" Width="250px"  MaxLength="50"></asp:textbox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Gender:&nbsp;<span class="required">*</span></td>
                                <td><asp:DropDownList ID="gender2" Width="150px" runat="server"></asp:DropDownList>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator10" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="gender2" ErrorMessage="Gender is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Date of Birth:&nbsp;<span class="required">*</span></td>
                                <td>
                                    <%--<asp:TextBox ID="birthdate2" MaxLength="10" Width="150px" runat="server"></asp:TextBox>
                                    &nbsp;<span class="remarks">(mm/dd/yyyy)</span>--%>
                                    <telerik:radDatePicker RenderMode="Lightweight" ID="birthdate2" Width="120px" runat="server" OnSelectedDateChanged="birthdate2_SelectedDateChanged" SkipMinMaxDateValidationOnServer="false" 
                                        MinDate="01/01/1800 00:00:00" Calendar-RangeMinDate="01/01/1800 00:00:00" Calendar-RangeSelectionStartDate="01/01/1800 00:00:00" 
                                        Calendar-FocusedDate="01/01/1800 00:00:00" DateInput-MinDate="01/01/1800 00:00:00" FocusedDate="01/01/1800 00:00:00">
                                        <Calendar ShowRowHeaders="false"></Calendar>
                                    </telerik:radDatePicker>&nbsp;<span class="remarks">(mm/dd/yyyy)</span>
                                   <asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="birthdate2" ErrorMessage="Date of Birth is required">*</asp:requiredfieldvalidator>
                                   <asp:CompareValidator ID="CompareValidator12" runat="server" ControlToValidate="birthdate2"
                                        CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Date of birth is invalid" Type="Date">*</asp:CompareValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Email Address:&nbsp;</td>
                                <td><asp:TextBox ID="email2" MaxLength="100" Width="250px" runat="server"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator12" runat="server" ControlToValidate="email2"
                                        CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Address:</td>
                                <td><asp:TextBox ID="address2" runat="server" Width="250px" MaxLength="100"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">City:</td>
                                <td><asp:TextBox ID="city2" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">State:&nbsp;</td>
                                <td class="tdtext"><asp:DropDownList ID="state2" Width="150px" runat="server"></asp:DropDownList></td>
                            </tr>
	                    <tr>
	                         <td class="tdlabel">Zip Code:</td>
	                         <td><asp:textbox id="zip2" runat="server" MaxLength="10" Width="150px" ></asp:textbox>
			                    <asp:regularexpressionvalidator id="Regularexpressionvalidator22" runat="server" CssClass="error" Display="Dynamic"
		                    ControlToValidate="zip2" ErrorMessage="Zip Code is invalid" ValidationExpression=" *\d{5}(-?\d{4})? *">*</asp:regularexpressionvalidator>
		                    </td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Home Phone:</td>
		                    <td>
                                <%--<asp:textbox id="homephone2" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="homephone2" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator32" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="homephone2" ErrorMessage="Home phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Cell Phone:</td>
		                    <td>
                                <%--<asp:textbox id="cellphone2" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="cellphone2" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator52" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="cellphone2" ErrorMessage="Cell phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
                            <tr>
                                <td class="tdlabel">Emergency Name:</td>
                                <td><asp:TextBox ID="emername2" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Emergency Relation:</td>
                                <td><asp:TextBox ID="emerrelation2" runat="server" Width="150px" MaxLength="25"></asp:TextBox></td>
                            </tr>
	                    <tr>
		                    <td class="tdlabel">Emergency Phone:</td>
		                    <td>
                                <%--<asp:textbox id="emerphone2" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="emerphone2" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator72" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="emerphone2" ErrorMessage="Emergency phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    </table>
                    </td>    
                    <td width="25">&nbsp;</td>
                    <td>
                        <table cellpadding="2" cellspacing="0">
	                        <asp:PlaceHolder ID="customFields2" Runat="server"></asp:PlaceHolder>
                        </table>
                    </td>
                </tr>
                </table>
                <p>&nbsp;</p>
            </asp:WizardStep>
            <asp:WizardStep ID="stepPax3" runat="server" title="Passenger #3" StepType="Step">
                <h1>Passenger #3</h1>
                <table cellpadding="0" cellspacing="0" border="0">
                <tr><td>&nbsp;</td></tr>
                <tr valign="top">
                    <td>
	                    <table cellspacing="0" cellpadding="3" border="0">
                            <tr>
                                <td width="125" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="firstname3" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator63" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname3" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Middle Name:&nbsp;</td>
                                <td><asp:textbox id="txtMiddleName3" runat="server" Width="250px"  MaxLength="50"></asp:textbox>                            
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="lastname3" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator53" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname3" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Badge Name:&nbsp;</td>
                                <td><asp:textbox id="badgename3" runat="server" Width="250px"  MaxLength="50"></asp:textbox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Gender:&nbsp;<span class="required">*</span></td>
                                <td><asp:DropDownList ID="gender3" Width="150px" runat="server"></asp:DropDownList>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator11" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="gender3" ErrorMessage="Gender is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Date of Birth:&nbsp;<span class="required">*</span></td>
                                <td>
                                    <%--<asp:TextBox ID="birthdate3" MaxLength="10" Width="150px" runat="server"></asp:TextBox>
                                    &nbsp;<span class="remarks">(mm/dd/yyyy)</span>--%>
                                     <telerik:radDatePicker RenderMode="Lightweight" ID="birthdate3" Width="120px" runat="server" OnSelectedDateChanged="birthdate3_SelectedDateChanged" SkipMinMaxDateValidationOnServer="false"
                                          MinDate="01/01/1800 00:00:00" Calendar-RangeMinDate="01/01/1800 00:00:00" Calendar-RangeSelectionStartDate="01/01/1800 00:00:00" 
                                        Calendar-FocusedDate="01/01/1800 00:00:00" DateInput-MinDate="01/01/1800 00:00:00" FocusedDate="01/01/1800 00:00:00">
                                         <Calendar ShowRowHeaders="false"></Calendar>
                                     </telerik:radDatePicker>&nbsp;<span class="remarks">(mm/dd/yyyy)</span>
                                   <asp:requiredfieldvalidator id="Requiredfieldvalidator8" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="birthdate3" ErrorMessage="Date of Birth is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator ID="CompareValidator13" runat="server" ControlToValidate="birthdate3"
                                        CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Date of birth is invalid" Type="Date">*</asp:CompareValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Email Address:&nbsp;</td>
                                <td><asp:TextBox ID="email3" MaxLength="100" Width="250px" runat="server"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator13" runat="server" ControlToValidate="email3"
                                        CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Address:</td>
                                <td><asp:TextBox ID="address3" runat="server" Width="250px" MaxLength="100"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">City:</td>
                                <td><asp:TextBox ID="city3" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">State:&nbsp;</td>
                                <td class="tdtext"><asp:DropDownList ID="state3" Width="150px" runat="server"></asp:DropDownList></td>
                            </tr>
	                    <tr>
	                         <td class="tdlabel">Zip Code:</td>
	                         <td><asp:textbox id="zip3" runat="server" MaxLength="10" Width="150px" ></asp:textbox>
			                    <asp:regularexpressionvalidator id="Regularexpressionvalidator23" runat="server" CssClass="error" Display="Dynamic"
		                    ControlToValidate="zip3" ErrorMessage="Zip Code is invalid" ValidationExpression=" *\d{5}(-?\d{4})? *">*</asp:regularexpressionvalidator>
		                    </td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Home Phone:</td>
		                    <td>
                                <%--<asp:textbox id="homephone3" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="homephone3" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator33" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="homephone3" ErrorMessage="Home phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Cell Phone:</td>
		                    <td>
                                <%--<asp:textbox id="cellphone3" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="cellphone3" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator53" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="cellphone3" ErrorMessage="Cell phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
                            <tr>
                                <td class="tdlabel">Emergency Name:</td>
                                <td><asp:TextBox ID="emername3" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Emergency Relation:</td>
                                <td><asp:TextBox ID="emerrelation3" runat="server" Width="150px" MaxLength="25"></asp:TextBox></td>
                            </tr>
	                    <tr>
		                    <td class="tdlabel">Emergency Phone:</td>
		                    <td>
                                <%--<asp:textbox id="emerphone3" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="emerphone3" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator73" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="emerphone3" ErrorMessage="Emergency phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    </table>
                    </td>    
                    <td width="25">&nbsp;</td>
                    <td>
                        <table cellpadding="2" cellspacing="0">
	                        <asp:PlaceHolder ID="customFields3" Runat="server"></asp:PlaceHolder>
                        </table>
                    </td>
                </tr>
                </table>
                <p>&nbsp;</p>
            </asp:WizardStep>
            <asp:WizardStep ID="stepPax4" runat="server" title="Passenger #4" StepType="Step">
                <h1>Passenger #4</h1>
                <table cellpadding="0" cellspacing="0" border="0">
                <tr><td>&nbsp;</td></tr>
                <tr valign="top">
                    <td>
	                    <table cellspacing="0" cellpadding="3" border="0">
                            <tr>
                                <td width="125" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="firstname4" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator12" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname4" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Middle Name:&nbsp;</td>
                                <td><asp:textbox id="txtMiddleName4" runat="server" Width="250px"  MaxLength="50"></asp:textbox>                            
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
                                <td><asp:textbox id="lastname4" runat="server" Width="250px"  MaxLength="50"></asp:textbox>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator13" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname4" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Badge Name:&nbsp;</td>
                                <td><asp:textbox id="badgename4" runat="server" Width="250px"  MaxLength="50"></asp:textbox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Gender:&nbsp;<span class="required">*</span></td>
                                <td><asp:DropDownList ID="gender4" Width="150px" runat="server"></asp:DropDownList>
                                    <asp:requiredfieldvalidator id="Requiredfieldvalidator14" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="gender4" ErrorMessage="Gender is required">*</asp:requiredfieldvalidator>
                                </td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Date of Birth:&nbsp;<span class="required">*</span></td>
                                <td>
                                    <%--<asp:TextBox ID="birthdate4" MaxLength="10" Width="150px" runat="server"></asp:TextBox>
                                    &nbsp;<span class="remarks">(mm/dd/yyyy)</span>--%>
                                    <telerik:radDatePicker RenderMode="Lightweight" ID="birthdate4" Width="120px" runat="server" OnSelectedDateChanged="birthdate4_SelectedDateChanged" SkipMinMaxDateValidationOnServer="false"
                                         MinDate="01/01/1800 00:00:00" Calendar-RangeMinDate="01/01/1800 00:00:00" Calendar-RangeSelectionStartDate="01/01/1800 00:00:00" 
                                        Calendar-FocusedDate="01/01/1800 00:00:00" DateInput-MinDate="01/01/1800 00:00:00" FocusedDate="01/01/1800 00:00:00">
                                        <Calendar ShowRowHeaders="false"></Calendar>
                                    </telerik:radDatePicker>&nbsp;<span class="remarks">(mm/dd/yyyy)</span>
                                   <asp:requiredfieldvalidator id="Requiredfieldvalidator15" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="birthdate4" ErrorMessage="Date of Birth is required">*</asp:requiredfieldvalidator>
                                    <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="birthdate4"
                                        CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Date of birth is invalid" Type="Date">*</asp:CompareValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Email Address:&nbsp;</td>
                                <td><asp:TextBox ID="email4" MaxLength="100" Width="250px" runat="server"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="RegularExpressionValidator4" runat="server" ControlToValidate="email4"
                                        CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Address:</td>
                                <td><asp:TextBox ID="address4" runat="server" Width="250px" MaxLength="100"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">City:</td>
                                <td><asp:TextBox ID="city4" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">State:&nbsp;</td>
                                <td class="tdtext"><asp:DropDownList ID="state4" Width="150px" runat="server"></asp:DropDownList></td>
                            </tr>
	                    <tr>
	                         <td class="tdlabel">Zip Code:</td>
	                         <td><asp:textbox id="zip4" runat="server" MaxLength="10" Width="150px" ></asp:textbox>
			                    <asp:regularexpressionvalidator id="Regularexpressionvalidator6" runat="server" CssClass="error" Display="Dynamic"
		                    ControlToValidate="zip4" ErrorMessage="Zip Code is invalid" ValidationExpression=" *\d{5}(-?\d{4})? *">*</asp:regularexpressionvalidator>
		                    </td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Home Phone:</td>
		                    <td>
                                <%--<asp:textbox id="homephone4" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="homephone4" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator8" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="homephone4" ErrorMessage="Home phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    <tr>
		                    <td class="tdlabel">Cell Phone:</td>
		                    <td>
                                <%--<asp:textbox id="cellphone4" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="cellphone4" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator9" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="cellphone4" ErrorMessage="Cell phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
                            <tr>
                                <td class="tdlabel">Emergency Name:</td>
                                <td><asp:TextBox ID="emername4" runat="server" Width="250px" MaxLength="50"></asp:TextBox></td>
                            </tr>
                            <tr>
                                <td class="tdlabel">Emergency Relation:</td>
                                <td><asp:TextBox ID="emerrelation4" runat="server" Width="150px" MaxLength="25"></asp:TextBox></td>
                            </tr>
	                    <tr>
		                    <td class="tdlabel">Emergency Phone:</td>
		                    <td>
                                <%--<asp:textbox id="emerphone4" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                                <telerik:RadMaskedTextBox id="emerphone4" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                                <asp:regularexpressionvalidator id="Regularexpressionvalidator10" runat="server" CssClass="error" Display="Dynamic"
								                    ControlToValidate="emerphone4" ErrorMessage="Emergency phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	                    </tr>
	                    </table>
                    </td>    
                    <td width="25">&nbsp;</td>
                    <td>
                        <table cellpadding="2" cellspacing="0">
	                        <asp:PlaceHolder ID="customFields4" Runat="server"></asp:PlaceHolder>
                        </table>
                    </td>
                </tr>
                </table>
                <p>&nbsp;</p>
            </asp:WizardStep>
            <asp:WizardStep ID="stepSumry" runat="server" title="Summary"  StepType="Finish">
                <h1>Summary</h1>
                <table cellpadding="3" cellspacing="1">
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td class="tdlabel" width="150">Agent:</td>
                        <td><%=agentflexid.SelectedItem.Text%></td>
                    </tr>
                    <tr valign="top">
                        <td class="tdlabel">No. of Passengers:</td>
                        <td><%=paxcnt.SelectedItem.Text%></td>
                    </tr>
                </table>
                <br /><br />
                <h1>Individuals</h1>
                <asp:Repeater ID="paxlist" runat="server">
                <HeaderTemplate>
                    <table cellpadding="3" cellspacing="0" border="0" width="600px">
                        <tr>
                            <td><b><u>Name</u></b></td>
                            <td><b><u>Badge Name</u></b></td>
                            <td><b><u>Email</u></b></td>
                        </tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("firstname") %>&nbsp; <%# Eval("middlename") %>&nbsp; <%# Eval("lastname") %></td>                                        
                        <td><%# Eval("badgename") %></td>                                        
                        <td><%# Eval("email") %></td>                                        
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                </table>
                </FooterTemplate>
                </asp:Repeater>
                <br /><br />
                <h1>Charges</h1>
                <asp:Repeater ID="billlist" runat="server">
                <HeaderTemplate>
                    <table cellpadding="3" cellspacing="0" border="0" width="600px">
                        <tr>
                            <td><b>Description</b></td>
                            <td align="right"><b>Rate</b></td>
                            <td align="right"><b>Qty</b></td>
                            <td align="right"><b>Amount</b></td>
                        </tr>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("description") %></td>                                        
                        <td align="right"><%# Eval("rate","{0:c}") %></td>                                        
                        <td align="right"><%# Eval("qty") %></td>                                        
                        <td align="right"><%# Eval("amount", "{0:c}")%></td>                                        
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    <tr>
                        <td colspan="3"></td>
                        <td align="right">---------------</td>
                    </tr>
                    <tr>
                        <td colspan="3" class="hdr">Total Amount Due:</td>                                        
                        <td align="right" class="hdr"><%=totDue.ToString("c")%></td>                                        
                    </tr>
                </table>
                </FooterTemplate>
                </asp:Repeater>


                <p>&nbsp;</p>
                <p>&nbsp;</p>
                <p>&nbsp;</p>
            </asp:WizardStep>
        </WizardSteps>
    </asp:Wizard>

</asp:Content> 