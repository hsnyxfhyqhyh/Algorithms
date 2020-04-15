<%@ Page language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    int questionid
    {
        get { return Util.parseInt(ViewState["questionid"]); }
        set { ViewState["questionid"] = value.ToString(); }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            questionid = Util.parseInt(Request.QueryString["questionid"]);
            message.InnerHtml = Request.QueryString["msg"];
            string sType = "";
            string sRevType = "";
            string sQuestionGroup = "";
            string sRadDisplayOrder = "";
            if (questionid > 0)
            {
                Question q = Question.GetQuestion(questionid);
                if (q == null)
                    Response.Redirect("QuestionList.aspx?msg=Question not found");
                hdr.InnerHtml = "Edit Question";
                questionname.Text = q.questionName;
                list.Text = q.list;
                groupidlist.Text = q.groupidList;
                sType = q.type;
                sRevType = q.revtype;
                sQuestionGroup = q.questiongroup;
                sRadDisplayOrder = Convert.ToString(q.displayorder);
                RadDisplayOrder.Text = sRadDisplayOrder;
            }
            else
            {
                hdr.InnerHtml = "Add Question";
                sRadDisplayOrder = Convert.ToString(Session["RowCount"]);
                RadDisplayOrder.Text = sRadDisplayOrder;
            }

            Lookup.FillDropDown(questiongroup, PickList.GetQuestionGroupType(), sQuestionGroup, " ");
            Lookup.FillDropDown(type, PickList.GetQuestionType(), sType, " ");
            Lookup.FillDropDown(revtype, PickList.GetPickList("REVTYPE"), sRevType, "All");
            type_SelectedIndexChanged(this, EventArgs.Empty);
            questiongroup_SelectedIndexChanged(this, EventArgs.Empty);
            cancel.Attributes["onclick"] = "javascript:window.location.href='QuestionList.aspx';return false;";
        }
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        string msg = "";
        try
        {
            Question q = new Question();
            if (questionid > 0)
                q = Question.GetQuestion(questionid);

            q.questiongroup = questiongroup.SelectedValue;
            q.questionName = questionname.Text;
            q.type = type.SelectedValue;
            q.list = list.Text;
            q.revtype = revtype.SelectedValue;
            q.groupidList = groupidlist.Text;
            q.displayorder = RadDisplayOrder.Text;
            Question.Update(q);
            msg = "\"" + questionname.Text + "\" was updated.";
            Response.Redirect("QuestionList.aspx?msg=" + msg);
        }
        catch (Exception ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void type_SelectedIndexChanged(object sender, EventArgs e)
    {
        trList.Visible = (type.SelectedValue.IndexOf("LIST") == -1) ? false : true;
    }

    protected void questiongroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        //trList.Visible = (type.SelectedValue.IndexOf("LIST") == -1) ? false : true;
    }
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Edit Question</td>
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
			<td class="tdlabel" width="200">Question Group Type:</td>
			<td>
                <asp:DropDownList runat="server" ID="questiongroup" Width="150px" 
                    OnSelectedIndexChanged="questiongroup_SelectedIndexChanged" AutoPostBack="True" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="questiongroup" ErrorMessage="Type is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
		<tr>
			<td class="tdlabel" width="200">Question Name:</td>
			<td><asp:textbox id="questionname" runat="server" Width="300"  MaxLength="50"></asp:textbox>
                <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="questionname" ErrorMessage="Question name is required">*</asp:requiredfieldvalidator>
            </td>
		</tr>
        <tr>
            <td class="tdlabel">Display Type:</td>
            <td>
                <asp:DropDownList runat="server" ID="type" Width="150px" 
                    onselectedindexchanged="type_SelectedIndexChanged" AutoPostBack="True" />
                <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="type" ErrorMessage="Type is required">*</asp:requiredfieldvalidator>
		    </td>
        </tr>
        <tr valign="top" runat="server" id="trList">
            <td class="tdlabel">List separated by semi-colon (;):</td>
            <td><asp:textbox id="list" runat="server" Width="400" TextMode="MultiLine"  Rows="4" MaxLength="1000"></asp:textbox></td>
        </tr>
        <tr>
            <td class="tdlabel">Travel Type:</td>
            <td><asp:DropDownList runat="server" ID="revtype" Width="150px" /></td>
        </tr>
        <tr valign="top">
            <td class="tdlabel">Group # List separated by semi-colon (;):</td>
            <td><asp:textbox id="groupidlist" runat="server" Width="400" TextMode="MultiLine"  Rows="4" MaxLength="1000"></asp:textbox></td>
        </tr>
        <tr valign="top">
            <td class="tdlabel" width="200">Display Order:</td>
            <td>
                <telerik:RadNumericTextBox RenderMode="Lightweight" runat="server" ID="RadDisplayOrder" Width="150px" Value="1" EmptyMessage="Enter Sort Order" MinValue="0" 
                    ShowSpinButtons="false" NumberFormat-DecimalDigits="0"></telerik:RadNumericTextBox><br />
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
		<tr>
			<td colspan="2" align="center">
				<asp:button id="save" runat="server" Text="  Save  " OnClick="Save_Click" CssClass="button"></asp:button>
				<asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" CausesValidation="False"></asp:button>
			</td>
		</tr>
	</table>

</asp:Content> 