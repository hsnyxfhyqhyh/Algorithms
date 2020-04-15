<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script language="C#" runat="server">

    int passengerid
    {
        get { return Convert.ToInt32(ViewState["passengerid"]); }
        set { ViewState["passengerid"] = value.ToString(); }
    }
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
    string revtype
    {
        get { return ViewState["revtype"].ToString(); }
        set { ViewState["revtype"] = value; }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            passengerid = Util.parseInt(Request.QueryString["passengerid"]);
            bookingid = Util.parseInt(Request.QueryString["bookingid"]);
            Passenger p = GroupBooking.GetPassenger(passengerid);
            GroupBooking b = GroupBooking.GetBooking(bookingid);
            GroupMaster g = GroupMaster.GetGroupMaster(b.groupID);
            if (b == null || p == null || g == null)
                Response.Redirect("BookingView.aspx?bookingid="+bookingid);
            message.InnerHtml = Request.QueryString["msg"];
            revtype = g.RevType;
            groupid = g.GroupID;
            // 
            firstname.Text = p.firstName;
            middlename.Text = p.middleName;
            lastname.Text = p.lastName;
            badgename.Text = p.badgeName;
            address.Text = p.address;
            city.Text = p.city;
            zip.Text = p.zip;
            email.Text = p.email;
            homephone.Text = p.homePhone;
            cellphone.Text = p.cellPhone;
            //birthdate.Text = p.birthDate;
            if (p.birthDate != null)
            {
                birthdate.MinDate = new System.DateTime();
                birthdate.SelectedDate = DateTime.Parse(p.birthDate);
            }

            emername.Text = p.emerName;
            emerphone.Text = p.emerPhone;
            emerrelation.Text = p.emerRelation;
            Lookup.FillDropDown(state, PickList.GetState(), p.state, " ");
            Lookup.FillDropDown(gender, PickList.GetGender(), p.gender, " ");
            //
            hdr.InnerHtml = string.Format("Booking ID: {0} - Edit Individual", bookingid);
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}';return false;", bookingid);
        }
        // Custom Fields - Questions
        List<Question> list = Question.GetPaxQuestions(passengerid, revtype, groupid);
        foreach (Question q in list)
        {
            customFields.Controls.Add(new LiteralControl(string.Format("<tr valign=top><td class=\"tdlabel\" width=\"150\">{0}:</td><td>", q.questionName)));
            Custom.AddControl(customFields, "QUES_" + q.questionID, q.answer, q.type, q.list, 250);
            customFields.Controls.Add(new LiteralControl("</td></tr>"));
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        //
        List<PaxQuestion> quesList = new List<PaxQuestion>();
        List<Question> list = Question.GetPaxQuestions(passengerid, revtype, groupid);
        foreach (Question q in list)
        {
            Control c = customFields.FindControl("QUES_" + q.questionID);
            string answer = Custom.CustomValue(c);
            PaxQuestion pq = new PaxQuestion(q.questionID, q.questionName, answer);
            quesList.Add(pq);
        }

        //                
        Passenger p = GroupBooking.GetPassenger(passengerid);
        p.firstName = firstname.Text;
        p.middleName = middlename.Text;
        p.lastName = lastname.Text;
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
        p.birthDate = Convert.ToString(birthdate.SelectedDate);
        p.emerName = emername.Text;
        p.emerPhone = emerphone.Text;
        p.emerRelation = emerrelation.Text;
        try
        {
            GroupBooking.UpdatePassenger(p);
            GroupBooking.UpdatePaxQuestion(passengerid, quesList);
            msg = HttpUtility.UrlEncode("Individual was successfully updated.");
            Response.Redirect("BookingView.aspx?bookingid=" + bookingid + "&msg=" + msg);
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void birthdate_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Passenger p = GroupBooking.GetPassenger(passengerid);
        p.birthDate = Convert.ToString(birthdate.SelectedDate);
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Individual</td>
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
    <table cellpadding="0" cellspacing="0" border="0" width="900">
        <tr valign="top">
            <td>
	            <table cellspacing="0" cellpadding="2" border="0">
                        <tr>
                            <td width="150" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
                            <td><asp:textbox id="firstname" runat="server" Width="300px"  MaxLength="50"></asp:textbox>
                                <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
                            </td>
                        </tr>
                         <tr>
                            <td class="tdlabel">Middle Name:&nbsp;</td>
                            <td><asp:textbox id="middlename" runat="server" Width="300px"  MaxLength="50"></asp:textbox>
                                <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>--%>
                            </td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
                            <td><asp:textbox id="lastname" runat="server" Width="300px"  MaxLength="50"></asp:textbox>
                                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Badge Name:&nbsp;</td>
                            <td><asp:textbox id="badgename" runat="server" Width="300px"  MaxLength="50"></asp:textbox></td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Gender:&nbsp;<span class="required">*</span></td>
                            <td><asp:DropDownList ID="gender" Width="150px" runat="server"></asp:DropDownList>
                                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="gender" ErrorMessage="Gender is required">*</asp:requiredfieldvalidator>
                            </td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Date of Birth:&nbsp;<span class="required">*</span></td>
                            <td>
                                <%--<asp:TextBox ID="birthdate" MaxLength="10" Width="150px" runat="server"></asp:TextBox>
                                &nbsp;<span class="remarks">(mm/dd/yyyy)</span>--%>
                                <telerik:radDatePicker RenderMode="Lightweight" ID="birthdate" Width="120px" runat="server" OnSelectedDateChanged="birthdate_SelectedDateChanged">
                                    <Calendar ShowRowHeaders="false"></Calendar>
                                </telerik:radDatePicker>&nbsp;<span class="remarks">(mm/dd/yyyy)</span>
                                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="birthdate" ErrorMessage="Date of Birth is required">*</asp:requiredfieldvalidator>
                                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="birthdate"
                                    CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Date of birth is invalid" Type="Date">*</asp:CompareValidator></td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Email Address:&nbsp;</td>
                            <td><asp:TextBox ID="email" MaxLength="100" Width="300" runat="server"></asp:TextBox>
                                <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ControlToValidate="email"
                                    CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
                        </tr>
                        <tr>
                            <td class="tdlabel">Address:</td>
                            <td><asp:TextBox ID="address" runat="server" Width="300px" MaxLength="100"></asp:TextBox></td>
                        </tr>
                        <tr>
                            <td class="tdlabel">City:</td>
                            <td><asp:TextBox ID="city" runat="server" Width="300px" MaxLength="50"></asp:TextBox></td>
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
                            <%--<asp:textbox id="homephone" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                            <telerik:RadMaskedTextBox id="homephone" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                            <asp:regularexpressionvalidator id="Regularexpressionvalidator3" runat="server" CssClass="error" Display="Dynamic"
								                ControlToValidate="homephone" ErrorMessage="Home phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*
                            </asp:regularexpressionvalidator>
		                </td>
	                </tr>
	                <tr>
		                <td class="tdlabel">Cell Phone:</td>
		                <td>
                           <%-- <asp:textbox id="cellphone" runat="server" MaxLength="20"  Width="150px"></asp:textbox>--%>
                            <telerik:RadMaskedTextBox id="cellphone" runat="server" MaxLength="20"  Width="110px" Mask="(###) ###-####"></telerik:RadMaskedTextBox>
                            <asp:regularexpressionvalidator id="Regularexpressionvalidator5" runat="server" CssClass="error" Display="Dynamic"
								                ControlToValidate="cellphone" ErrorMessage="Cell phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*
                            </asp:regularexpressionvalidator>
		                </td>
	                </tr>
                        <tr>
                            <td class="tdlabel">Emergency Name:</td>
                            <td><asp:TextBox ID="emername" runat="server" Width="300px" MaxLength="50"></asp:TextBox></td>
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
								                ControlToValidate="emerphone" ErrorMessage="Emergency phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*
                            </asp:regularexpressionvalidator>

		                </td>
	                </tr>
	            </table>

            </td>    
            <td width="30">&nbsp;</td>
            <td>
                <table cellpadding="2" cellspacing="0">
	                <asp:PlaceHolder ID="customFields" Runat="server"></asp:PlaceHolder>
                </table>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
	    <tr>
		    <td colspan="5" align="center">
			    <asp:button id="save" runat="server" Text=" Save " OnClick="Save_Click" CssClass="button" Width="75px"></asp:button>&nbsp;&nbsp;
			    <asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False" Width="75px"></asp:button>
		    </td>
	    </tr>
    </table>


</asp:Content> 