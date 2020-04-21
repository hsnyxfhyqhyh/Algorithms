<%@ Page language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>

<script language="C#" runat="server">

    GroupBooking b;

    int bookingid
    {
        get { return Convert.ToInt32(ViewState["bookingid"]); }
        set { ViewState["bookingid"] = value; }
    }
    decimal totDue
    {
        get { return Util.parseDec(ViewState["totdue"]); }
        set { ViewState["totdue"] = value; }
    }

    string commissionshow
    {
        get { return Convert.ToString(ViewState["commissionshow"]); }
        set { ViewState["commissionshow"] = value; }
    }

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            bookingid = Util.parseInt(Request.QueryString["bookingid"]);

            message.InnerHtml = Request.QueryString["msg"];
            b = GroupBooking.GetBooking(bookingid);
            if (b == null)
                Response.Redirect("BookingList.aspx?msg=Booking not found");
            GroupMaster g = GroupMaster.GetGroupMaster(b.groupID);
            string strDate = (g.DepartDate == g.ReturnDate) ? g.DepartDate : string.Format("{0} to {1}", g.DepartDate, g.ReturnDate);
            group.Text = string.Format("{0} - {1}&nbsp;&nbsp;&nbsp;[{2}]", g.GroupID, g.GroupName, strDate);
            paxcnt.Text = b.paxCnt.ToString();
            source.Text = b.source;
            status.Text = b.statusDesc;
            DataTable  dtAvailable = GroupMaster.GetBookingQuantity(g.GroupID, bookingid);
            int iAvailable = 0;
            Object a = dtAvailable.Rows[0]["Available"];
            iAvailable = Convert.ToInt32(a);

            agentname.Text = b.agentName;
            bookingdate.Text = b.bookingDate.ToShortDateString();
            finaldue2.Text = g.FinalDue2;

            billlist.Visible = true;
            billlist.DataSource = b.billList;
            billlist.DataBind();

            billlistcommission.Visible = false;
            billlistcommission.DataSource = b.billList;
            billlistcommission.DataBind();

            pmtlist.DataSource = b.pmtList;
            pmtlist.DataBind();
            paxlist.DataSource = b.paxList;
            paxlist.DataBind();

            hdr.InnerHtml = string.Format("Booking ID: {0} - {1}", bookingid, g.GroupName);
            agentbookingview.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}&commissionshow=Y';return false;", bookingid);
            edit.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingEdit.aspx?bookingid={0}';return false;", bookingid);
            postpmt.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingPmt.aspx?bookingid={0}';return false;", bookingid);
            updatestatus.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingStatus.aspx?bookingid={0}';return false;", bookingid);
            cancel.Attributes["onclick"] = "javascript:window.location.href='BookingList.aspx';return false;";
            if (status.Text == "Wait List")
            {
                if (iAvailable > 0)
                {
                    updatestatus.Enabled = true;
                }
                else
                {
                    updatestatus.Enabled = false;
                }
            }
            else
            {
                updatestatus.Enabled = true;
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

                if (iRole == 4)
                {
                    // Check for allowed Group
                    if (sGroupID1 == b.groupID || sGroupID2 == b.groupID || sGroupID3 == b.groupID || sGroupID4 == b.groupID || sGroupID5 == b.groupID)
                    {
                        agentbookingview.Enabled = true;
                        agentbookingview.Visible = true;
                        postpmt.Enabled = true;
                        edit.Enabled = true;
                        updatestatus.Enabled = true;

                        
                    }
                    else
                    {
                        agentbookingview.Enabled = false;
                        postpmt.Enabled = false;
                        edit.Enabled = false;
                        updatestatus.Enabled = false;
                    }
                }

                if (Request.QueryString["commissionshow"] !=null && Request.QueryString["commissionshow"].ToString().Equals("Y"))
                {
                    commissionshow = "Y";
                } else
                {
                    commissionshow = "N";
                }

                if (commissionshow.Equals("Y"))
                {
                    billlistcommission.Visible = true;
                    billlist.Visible = false;
                    agentbookingview.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}&commissionshow=N';return false;", bookingid);
                    agentbookingview.Text = "Invoice";
                }
                else
                {
                    billlistcommission.Visible = false;
                    billlist.Visible = true;
                    agentbookingview.Attributes["onclick"] = string.Format("javascript:window.location.href='BookingView.aspx?bookingid={0}&commissionshow=Y';return false;", bookingid);
                    agentbookingview.Text = "Agent Invoice";
                }
            }
        }
    }

 </script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <style type="text/css">
        .list2
            {
                border-width:1px;
                border-style:Solid;
                border-collapse:collapse;
                display: table-row;
                color: #666666;
            }
    </style>

	<table cellpadding="0" cellspacing="0" id="printinclude" style="display: none" >
		<tr>
			<td>
				<img src="Images/aaa-logo.png" height="50" alt="" />
			</td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">View Booking</td>
			<td align="right" id="printexclude">
                <asp:button id="agentbookingview" runat="server" Text="Agent Invoice" Width="85px" CssClass="button" TabIndex="-1" CausesValidation="False" Visible="true" Enabled="true"></asp:button>&nbsp;
                <asp:button id="postpmt" runat="server" Text="Post Payment" Width="100px" CssClass="button" TabIndex="-1" ToolTip="Post payment for booking" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="edit" runat="server" Text="Edit" Width="75px" CssClass="button" TabIndex="-1" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="updatestatus" runat="server" Text="Update Status" Width="100px" CssClass="button" TabIndex="-1" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="cancel" runat="server" Text="&lt;&lt; Back To List" Width="100px" CssClass="button" CausesValidation="False"></asp:button>&nbsp;
            </td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span><br>
			</td>
		</tr>
	</table>
    <br />

    <table cellpadding="2" cellspacing="1">
        <tr>
            <td class="tdlabel">Group #:</td>
            <td colspan="4"><asp:Label ID="group" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel" width="150">Booking ID:</td>
            <td><%=bookingid%></td>
            <td width="50">&nbsp;</td>
            <td class="tdlabel" width="100">Booking Date:</td>
            <td><asp:Label id="bookingdate" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Agent:</td>
            <td><asp:Label id="agentname" runat="server"></asp:Label></td>
            <td></td>
            <td class="tdlabel">Source:</td>
            <td><asp:Label ID="source" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">No. of Individuals:</td>
            <td><asp:Label ID="paxcnt" runat="server"></asp:Label></td>
            <td></td>
            <td class="tdlabel">Status:</td>
            <td><asp:Label ID="status" runat="server"></asp:Label></td>
        </tr>
        <tr>
            <td class="tdlabel">Final Payment Date:</td>
            <td><asp:Label ID="finaldue2" runat="server"></asp:Label></td>
            <td></td>
            <td class="tdlabel"></td>
            <td> </td>
        </tr>
    </table>
    <br />

    <h1>Individuals</h1>
    <asp:Repeater ID="paxlist" runat="server">
    <HeaderTemplate>
        <table cellpadding="2" cellspacing="1" border="0" class="list2" width="900">
            <tr class="listhdr">
                <td><b>Name</b></td>
                <td><b>Badge Name</b></td>
                <td><b>Email</b></td>
                <td><b>Home Phone</b></td>
                <td><b>Cell Phone</b></td>
                <td><b>Primary</b></td>
            </tr>
    </HeaderTemplate>
    <ItemTemplate>
        <tr>
            <td><a href="BookingPaxEdit.aspx?passengerid=<%# Eval("passengerid") %>&bookingid=<%=bookingid%>"><%# Eval("name") %></a></td>                                        
            <td><%# Eval("badgename") %></td>                                        
            <td><%# Eval("email") %></td>                                        
            <%--<td><%# Eval("homephone") %></td> --%>
            <td>
                <asp:Label ID="Label3" runat="server" Text=""><%# !String.IsNullOrEmpty(Convert.ToString(Eval("homephone"))) ? String.Format("{0:(###) ###-####}", Convert.ToInt64(Eval("homephone").ToString())) : String.Empty%></asp:Label>
            </td>
            <td>
                <asp:Label ID="Label2" runat="server" Text=""><%# !String.IsNullOrEmpty(Convert.ToString(Eval("cellphone"))) ? String.Format("{0:(###) ###-####}", Convert.ToInt64(Eval("cellphone").ToString())) : String.Empty%></asp:Label>
            </td>
            <%--<td><%# Eval("cellphone") %></td>--%>
            <td>
                <asp:Label ID="Label1" runat="server" Text=""><%# !String.IsNullOrEmpty(Convert.ToString(Eval("cellphone"))) ? String.Format("{0:(###) ###-####}", Convert.ToInt64(Eval("cellphone").ToString())) : String.Empty%></asp:Label>
            </td>
            <td><%# ((bool)Eval("isprimary")) ? "Yes" : "No" %></td>                                        
        </tr>
    </ItemTemplate>
    <FooterTemplate>
    </table>
    </FooterTemplate>
    </asp:Repeater>
    <br />

    <h1>Charges</h1>
    <asp:Repeater ID="billlist" runat="server">
    <HeaderTemplate>
        <table cellpadding="2" cellspacing="1" border="0" class="list2" width="900">
            <tr class="listhdr">
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
            <td colspan="3" class="hdr"></td>                                        
            <td align="right" class="hdr"><b><%=b.billAmt.ToString("c")%></b></td>                                        
            
        </tr>
    </table>
    </FooterTemplate>
    </asp:Repeater>

    <asp:Repeater ID="billlistcommission" runat="server" Visible="false">
    <HeaderTemplate>
        <table cellpadding="2" cellspacing="1" border="0" class="list2" width="900">
            <tr class="listhdr">
                <td><b>Description</b></td>
                <td align="right"><b>Rate</b></td>
                <td align="right"><b>Qty</b></td>
                <td align="right"><b>Amount</b></td>
                <td align="right"><b>Commission</b></td>
            </tr>
    </HeaderTemplate>
    <ItemTemplate>
        <tr>
            <td><%# Eval("description") %></td>                                        
            <td align="right"><%# Eval("rate","{0:c}") %></td>                                        
            <td align="right"><%# Eval("qty") %></td>                                        
            <td align="right"><%# Eval("amount", "{0:c}")%></td>                                        
            <td align="right"><%# Eval("commission", "{0:c}")%></td>    
        </tr>
    </ItemTemplate>
    <FooterTemplate>
        <tr>
            <td colspan="3"></td>
            <td align="right">---------------</td>
        </tr>
        <tr>
            <td colspan="3" class="hdr"></td>                                        
            <td align="right" class="hdr"><b><%=b.billAmt.ToString("c")%></b></td>                                        
            <td align="right" class="hdr"><b><%=b.billCommission.ToString("c")%></b></td>
        </tr>
    </table>
    </FooterTemplate>
    </asp:Repeater>
    <br />

    <h1>Payments</h1>
    <asp:Repeater ID="pmtlist" runat="server">
    <HeaderTemplate>
        <table cellpadding="2" cellspacing="1" border="0" class="list2" width="900">
            <tr class="listhdr">
                <td><b>Payment Date</b></td>
                <td><b>Type</b></td>
                <td><b>Ref #</b></td>
                <td><b>Paid By</b></td>
                <td><b>Source</b></td>
                <td align="right"><b>Amount</b></td>
            </tr>
    </HeaderTemplate>
    <ItemTemplate>
        <tr>
            <td><%# Eval("pmtdate", "{0:d}")%></td>                                        
            <td><%# Eval("pmttypedesc") %></td>                                        
            <td><%# Eval("refnum") %></td>                                        
            <td><%# Eval("payername") %></td>                                        
            <td><%# Eval("source") %></td>                                        
            <td align="right"><%# Eval("amount", "{0:c}")%></td>                                        
        </tr>
    </ItemTemplate>
    <FooterTemplate>
        <tr>
            <td colspan="5"></td>
            <td align="right">---------------</td>
        </tr>
        <tr>
            <td colspan="5" class="hdr"></td>                                        
            <td align="right" class="hdr"><b><%=b.pmtAmt.ToString("c")%></b></td>                                        
        </tr>
    </table>
    </FooterTemplate>
    </asp:Repeater>
    <br /><br />
    <table cellpadding="3" cellspacing="1" border="0" width="900">
        <tr>
            <td align="right" class="hdr">Balance: &nbsp;&nbsp;<%=b.dueAmt.ToString("c")%></td>                                        
        </tr>
    </table>

</asp:Content> 