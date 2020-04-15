<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int waitlistid
    {
        get { return Convert.ToInt32(ViewState["waitlistid"]); }
        set { ViewState["waitlistid"] = value.ToString(); }
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
            message.InnerHtml = Request.QueryString["msg"];
            waitlistid = Util.parseInt(Request.QueryString["waitlistid"]);
            int iPaxCnt = 2;
            int iAgentFlexID = 0;
            if (waitlistid > 0)
            {
                WaitList w = WaitList.GetWaitList(waitlistid);
                if (w == null)
                    Response.Redirect("WaitList.aspx?msg=Record not found");
                groupid = w.groupID;
                firstname.Text = w.firstName;
                lastname.Text = w.lastName;
                phone.Text = w.phone;
                email.Text = w.email;
                isconverted.Checked = w.isConverted;
                iAgentFlexID = w.agentFlexID;
            }
            else
            {
                groupid = Request.QueryString["groupid"] + "";
            }
            GroupMaster g = GroupMaster.GetGroupMaster(groupid);
            if (g == null)
                Response.Redirect("WaitList.aspx?msg=Group record not found");
            //
            Lookup.FillNumber(paxcnt, iPaxCnt, 1, 4, "");
            Lookup.FillDropDown(agentflexid, PickList.GetTravelAgent(iAgentFlexID), iAgentFlexID.ToString(), " ");
            string strDate = (g.DepartDate == g.ReturnDate) ? g.DepartDate : string.Format("{0} to {1}", g.DepartDate, g.ReturnDate);
            string strGroup = string.Format("{0} - {1} &nbsp;&nbsp;&nbsp;[{2}]", g.GroupID, g.GroupName, strDate);
            hdr.InnerHtml = ((waitlistid == 0) ? "Add to Waiting List" : "Edit Waiting List") + "&nbsp;&nbsp;&nbsp;" + strGroup;
            cancel.Attributes["onclick"] = string.Format("javascript:window.location.href='WaitList.aspx?searchstr={0}';return false;", groupid);
        }
    }

	void Save_Click(object sender, System.EventArgs e)
	{
        if (!Page.IsValid) return;
        //                
        WaitList w = new WaitList();
        w.waitListID = waitlistid;
        w.groupID = groupid;
        if (waitlistid > 0)
           w =  WaitList.GetWaitList(waitlistid);
        w.firstName = firstname.Text;
        w.lastName = lastname.Text;
        w.email = email.Text;
        w.phone = phone.Text;
        w.paxCnt = Convert.ToInt32(paxcnt.SelectedValue);
        w.agentFlexID = Util.parseInt(agentflexid.SelectedValue);
        w.isConverted = isconverted.Checked;
        try
        {
            if (waitlistid > 0)
                WaitList.Update(w);
            else
                WaitList.Add(w);
            Response.Redirect("WaitList.aspx?searchstr=" + groupid + "&msg=Waiting list was updated");
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Waiting List</td>
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
            <td width="150" class="tdlabel">First Name:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="firstname" runat="server" Width="300px"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator6" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="firstname" ErrorMessage="First name is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Last Name:&nbsp;<span class="required">*</span></td>
            <td><asp:textbox id="lastname" runat="server" Width="300px"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lastname" ErrorMessage="Last name is required">*</asp:requiredfieldvalidator>
            </td>
        </tr>
        <tr>
            <td class="tdlabel">Agent:&nbsp;</td>
            <td><asp:DropDownList ID="agentflexid" Width="300px" runat="server"></asp:DropDownList></td>
        </tr>
        <tr>
            <td class="tdlabel">Passenger Count:&nbsp;</td>
            <td><asp:DropDownList ID="paxcnt" Width="150px" runat="server"></asp:DropDownList></td>
        </tr>
        <tr>
            <td class="tdlabel">Email Address:&nbsp;</td>
            <td><asp:TextBox ID="email" MaxLength="100" Width="300" runat="server"></asp:TextBox>
                <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ControlToValidate="email"
                    CssClass="error" Display="Dynamic" ErrorMessage="Email address is invalid" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*">*</asp:RegularExpressionValidator></td>
        </tr>
	    <tr>
		    <td class="tdlabel">Phone:</td>
		    <td><asp:textbox id="phone" runat="server" MaxLength="20"  Width="150px"></asp:textbox><asp:regularexpressionvalidator id="Regularexpressionvalidator3" runat="server" CssClass="error" Display="Dynamic"
								    ControlToValidate="phone" ErrorMessage="Phone is invalid" ValidationExpression=" *\(?\d{3}[\)\.\-]?\s?\d{3}\s?[\-\.]?\s?\d{4} *">*</asp:regularexpressionvalidator></td>
	    </tr>
	    <tr>
		    <td class="tdlabel">Converted:</td>
		    <td><asp:CheckBox id="isconverted" runat="server" /></td>
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