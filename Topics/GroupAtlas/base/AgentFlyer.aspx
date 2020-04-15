<%@ Page language="c#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>

<script language="C#" runat="server">

    mtGroup g;
    List<mtCancelPolicy> listCanc;
    List<mtItinerary> listItin;
    List<mtGroupCategory> listCat;
    DataTable dtMotorCoach; 
    DataTable dtAgentNotes; 
    DataTable dtSpecFeats; 
    DataTable dtPre; 
    DataTable dtPost; 
    DataTable dtAir;
    int count = 1;
    int sched = 1;
    bool showSingleRates = false;

	void Page_Load(object sender, System.EventArgs e)
	{
        string groupCode = Request.QueryString["groupcode"] + "";
        g = mtGroup.GetGroup(groupCode);
        if (g == null)
        {
            Response.Write("<p>Invalid Group Code</p>");
            Response.End();
        }
        listCanc = mtGroup.GetCancelPolicy(groupCode);
        listItin = mtGroup.GetItinerary(groupCode);
        listCat = mtGroup.GetCategory(groupCode);
        dtAir = mtGroup.GetAir(groupCode);
        dtMotorCoach = mtGroupInclude.GetList(groupCode, "motorcoach");
        dtAgentNotes = mtGroupInclude.GetList(groupCode, "agentnotes");
        dtSpecFeats = mtGroupInclude.GetList(groupCode, "specialfeatures");
        dtPre = mtGroupInclude.GetList(groupCode, "pre");
        dtPost = mtGroupInclude.GetList(groupCode, "post");
	}
    
    string FmtTime(object tm)
    {
	    string sTm = tm+"";
		sTm = sTm.Replace(":","");
		sTm = sTm.Replace("AM","A");
		sTm = sTm.Replace("PM","P");
		sTm = sTm.Replace(" ","");
        return sTm;
    }
    
</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html>
<head>
	<title>Agent Net Group Departures Calendar</title>
	<base href="http://<% = Request.ServerVariables["SERVER_NAME"] %>/">
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
	<meta name="description" content="AAA Group Departure Details">
	<meta name="keywords" content="travel, vacation, getaway, cruise, tour, group, depart, calendar">
    <style type="text/css">
        .text1 {FONT: 8pt ARIAL; font-weight: normal}
        .text2 {FONT: 8pt  ARIAL; font-weight: bold}
        .text3 {FONT: 10pt ARIAL; font-weight: normal}
        .text4 {FONT: 10pt ARIAL; font-weight: bold}
    </style>
</head>

<body bgcolor="#ffffff">

<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td align="center" valign="top">
			<BR>
			<p><font face="arial, helvetica"><b>Group Departures</font></b></p>

<!-- Group Department Contact information  -->
<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center">GROUP DEPARTMENT INFORMATION</td>
	</tr>
	<tr>
		<td class="text3" align="center">
			Should you have any questions, please feel free to contact us.<br/>
            Wilmington (302) 230-2957 (1362957)<br />
            Dayton (937) 294-5791<br />
            Toledo (419) 843-1212 (5403907)<br />
            IATA # 08640376 (Wilmington)<br />
            IATA # 36875672 (NWO)
		</td>
	</tr>
</table>
<!-- contact info ends -->

<br/>
<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center" colspan="2">GROUP INFORMATION</td>
	</tr>
	<tr>
		<td class="text4" width="30%"><%=(g.Affinity) ? "AFFINITY" : "AAA"%> GROUP #:</td>
		<td class="text3" width="70%"><%=g.GroupCode%></td>
	</tr>
	<tr>
		<td class="text4">HEADING:</td>
		<td class="text3"><%=g.Heading%></td>
	</tr>
	<tr>
		<td class="text4">VENDOR NAME:</td>
		<td class="text3"><%=g.VendorName%></td>
	</tr>
	<%if (g.PackageType == "C" || g.PackageType == "CT") {%>
		<tr>
			<td class="text4">SHIP NAME:</td>
			<td class="text3"><%=g.ShipName%></td>
		</tr>
		<tr>
			<td class="text4">DEPARTURE PORT:</td>
			<td class="text3"><%=g.DeparturePointName%></td>
		</tr>
	<%}%>
	<%if (g.TourName != "") {%>
		<tr>
			<td class="text4">TOUR NAME:</td>
			<td class="text3"><%=g.TourName%></td>
		</tr>
	<%}%>
	<tr>
		<td class="text4">DEPARTURE DATE:</td>
		<td class="text3"><%=g.DepartureDate%></td>
	</tr>
	<tr>
		<td class="text4">RETURN DATE:</td>
		<td class="text3"><%=g.ReturnDate%></td>
	</tr>
	<tr>
		<td class="text4">VENDOR GROUP CODE:</td>
		<td class="text3"><%=g.VendorGroupCode%></td>
	</tr>
	<tr>
		<td class="text4">VENDOR GROUP #:</td>
		<td class="text3"><%=g.VendorGroupNumber%></td>
	</tr>
</table>
<br>
<%if (g.ContactInstr != "" || g.IATAInstr != "" || g.PhoneInstr != "" || g.AddlInstr != "") {%>
	<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
		<tr>
			<td class="text4" valign="top" align="center" colspan="2">BOOKING INSTRUCTIONS</td>
		</tr>
		<%if (g.ContactInstr != "") {%>
			<tr>
				<td class="text4" width="30%">CONTACT:</td>
				<td class="text3" width="70%">
					<%
                    string contactInstr = (g.ContactInstr == "Call Travel Product Development") ? "Call Group Department" : g.ContactInstr;
					if (g.ContactInstr.ToLower().IndexOf("vendor") > -1) {
                        mtVendor vend = mtVendor.GetVendor(g.VendorCode);
						if (vend != null) {
							if (vend.phone != "")
                                contactInstr = contactInstr.Replace("vendor", vend.vendorName + " at " + vend.phone + "<br>");
							else
								contactInstr = contactInstr.Replace("vendor", vend.vendorName);
						}
					}
					Response.Write(contactInstr);
					Response.Write(g.ContactInstrOther);
					%>
				</td>
			</tr>
		<%}%>
		<%if (g.IATAInstr != "") {%>
			<tr>
				<td class="text4" width="30%">REFERENCE IATA #:</td>
				<td class="text3" width="70%">
					<%=g.IATAInstr%>&nbsp;
                    <%=g.IATAInstrOther %>
				</td>
			</tr>
		<%}%>
		<%if (g.PhoneInstr != "") {%>
			<tr>
				<td class="text4" width="30%">REFERENCE PHONE #:</td>
				<td class="text3" width="70%">
					<%=g.PhoneInstr%>&nbsp;
    				<%=g.PhoneInstrOther%>
				</td>
			</tr>
		<%}%>
		<%if (g.AddlInstr != "") {
			string [] addlArray = g.AddlInstr.Split(new char[] {','});
			%>
			<tr>
				<td class="text4" width="30%" valign="top">ADDITIONAL INSTRUCTIONS:</td>
				<td class="text3" width="70%">
					<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
					<%
                        for (int i=0; i<addlArray.Length; i++) {
						    Response.Write("<li>");
                            Response.Write(addlArray[i]);
						    if (i == addlArray.GetUpperBound(0) && addlArray[i].ToLower() == "other" ) 
							    Response.Write(" - " + g.AddlInstrOther);
						    Response.Write("</li>");
					    }
					%>
					</ul>
				</td>
			</tr>
		<%}%>
	</table>
    <br />
<%}%>

<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" width="30%">REQUIRED PASSENGER INFORMATION FOR VENDOR</td>
		<td class="text3" width="70%">
			<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
			<%
   			    string [] reqPassArray = g.RequiredPass.Split(new char[] {','});
			    foreach (string str in reqPassArray)
				    Response.Write("<li>" + str + "</li>");
			%>
			</ul>
		</td>
	</tr>

	<%if (g.DocReq != "" ) {%>
		<tr>
			<td class="text4" valign="top">DOCUMENTATION REQUIRED</td>
			<td class="text3">
				<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
				<%
       			    string [] docReqArray = g.DocReq.Split(new char[] {','});
				    foreach (string str in docReqArray) {
					    Response.Write("<li>");
					    Response.Write(str);
					    if (str.ToLower() == "visa")
					        if (g.Visa != "") Response.Write( " (" + g.Visa + ") ");
					    else if (str.ToLower() == "innoculation")
						    if (g.Innoculation != "") Response.Write(" (" + g.Innoculation + ")");
					    else if (str.ToLower() == "other")
						    if (g.DocOther != "") Response.Write(" (" + g.DocOther + ")");
					    else if (str.ToLower() == "proof of citizenship") {
						    Response.Write("<ul>");
						    Response.Write("<li>Original Birth Certificate with raised seal</li>");
						    Response.Write("<li>Government Issued Photo</li>");
						    Response.Write("</ul>");
					    }
					    Response.Write("</li>");
				    }
				%>
				</ul>
			</td>
		</tr>
	<%}%>

	<%if (g.AgentNotes.ToLower() == "yes" || g.Script331.ToLower() == "on") {%>
		<tr>
			<td class="text4" valign="top">AGENT NOTES</td>
			<td>
				<table width="100%" cellpadding="3" cellspacing="0" border="0">
					<tr>
						<td>&nbsp;</td>
						<td class="text3">
							<table width="100%" cellpadding="3" cellspacing="0" border="0">
								<%foreach (DataRow dr in dtAgentNotes.Rows) {%>
									<tr>
										<td class="text3"><%=dr["include"]%></td>
									</tr>
								<%}%>
							</table>
						</td>
					</tr>
					<%if (g.Script331.ToLower() == "on") {%>
						<tr>
							<td>&nbsp;</td>
							<td class="text4">Don't forget to run your 331 script.</td>
						</tr>
					<%}%>
				</table>
			</td>
		</tr>
	<%}%>
</table><br>

<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center" colspan="2">PACKAGE INFORMATION</td>
	</tr>
	<%if (listItin.Count > 0) {%>
		<tr>
			<td class="text4" valign="top" width="30%">ITINERARY</td>
			<td class="text4" width="70%">
				<table width="100%" cellpadding="3" cellspacing="0" border="0">
					<%foreach (mtItinerary it in listItin) {%>
						<%if (it.itinerary != "") {%>
							<tr>
								<td width="30%" class="text3" valign="top">
									<%
									if (it.date != "")
										Response.Write (Convert.ToDateTime(it.date).ToString("MMMM dd"));
									%>
								</td>
								<td width="70%" class="text3">
									<%=it.itinerary%>
									<%
									if (it.detail != "")
										Response.Write ("<br><strong>Details:</strong> " + it.detail);
									%>
								</td>
							</tr>
						<%}%>
					<%}%>
				</table>
			</td>
		</tr>
	<%}%>
	<%if (g.SpecialFeatures.ToLower() =="yes") {%>
		<tr>
			<td class="text4" valign="top" width="30%">SPECIAL FEATURES</td>
			<td class="text3" width="70%">
				<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
				<%foreach (DataRow dr in dtSpecFeats.Rows) {%>
					<li><%=dr["include"]%></li>
				<%}%>
				</ul>
			</td>
		</tr>
	<%}%>
	<%if (g.AdditionalNotes != "") { %>
		<tr>
			<td class="text4" valign="top" width="30%">ADDITIONAL NOTES</td>
			<td class="text3" width="70%"><%=g.AdditionalNotes%></td>
		</tr>
	<%}%>

	<tr>
		<td class="text4" valign="top">RATES FROM</td>
		<td class="text3"><%=g.StartingRates.ToString("c")%> per person</td>
	</tr>
	<tr>
		<td class="text4" valign="top">CATEGORIES/RATES</td>
		<td>
			<table width="100%" cellpadding="3" cellspacing="0" border="0">
				<%if (!g.HideRates) { %>
					<% if (listCat.Count > 0) {%>
						<%
						 foreach (mtGroupCategory cat in listCat)
                         {
							if (cat.sng > 0) 
								showSingleRates = true;
						 }
						%>
						<tr>
							<td class="text3">
								<table width="100%" cellpadding="2" cellspacing="1" border="0">
									<tr bgcolor="#b2d3da">
										<td colspan="2" class="text3" bgcolor="#ffffff"></td>
										<td class="text2" <%if (showSingleRates) Response.Write ("colspan=\"2\""); %> align="center">Rates Per Person</td>
										<td class="text2" <%if (showSingleRates) Response.Write ("colspan=\"2\""); %> align="center">Commission</td>
									</tr>
									<tr bgcolor="#b2d3da">
										<td class="text2" align="center">Category</td>
										<td class="text2">Decription</td>
										<td class="text2" align="center">Double</td>
										<% if (showSingleRates) {%>
											<td class="text2" align="center">Single</td>
										<%}%>
										<td class="text2" align="center">Double</td>
										<% if (showSingleRates) {%>
											<td class="text2" align="center">Single</td>
										<%}%>
									</tr>
									<%foreach (mtGroupCategory cat in listCat) {%>
										<%if (cat.category != "") {%>
											<tr>
												<td class="text1" align="center"><%=cat.category%></td>
												<td class="text1"><%=cat.des%></td>
												<td class="text1" align="right">
													<%if (cat.dbl > 0) Response.Write(cat.dbl.ToString("c"));%>
												</td>
												<%if (showSingleRates) {%>
													<td class="tealtext1" align="right">
													    <%if (cat.sng > 0) Response.Write(cat.sng.ToString("c"));%>
													</td>
												<%}%>
												<td class="text1" align="right">
												    <%if (cat.commissionDbl > 0) Response.Write(cat.commissionDbl.ToString("c"));%>
												</td>
												<%if (showSingleRates) {%>
													<td class="tealtext1" align="right">
	    											    <%if (cat.commissionSng > 0) Response.Write(cat.commissionSng.ToString("c"));%>
													</td>
												<%}%>
											</tr>
										<%}%>
									<%}%>
								</table>
							</td>
						</tr>
					<%}%>
					<%if (g.SingleRate > 0) {%>
						<tr>
							<td class="text3">Single Rate: <%=g.SingleRate.ToString("c")%> per person</td>
                            <td class="text3"> <%=g.commissionSng.ToString("c")%> Commissions</td>
						</tr>
					<%}%>
					<%if (g.DoubleRate > 0) {%>
						<tr>
							<td class="text3">Double Rate: <%=g.DoubleRate.ToString("c")%> per person</td>
                            <td class="text3"> <%=g.commissionDbl.ToString("c")%> Commissions</td>
						</tr>
					<%}%>
					<%if (g.TripleRate > 0) {%>
						<tr>
							<td class="text3">Triple Rate: <%=g.TripleRate.ToString("c")%> per person</td>
                            <td class="text3"> <%=g.commissionTRPL.ToString("c")%> Commissions</td>
						</tr>
					<%}%>
					<%if (g.QuadRate > 0) {%>
						<tr>
							<td class="text3">Quad Rate: <%=g.QuadRate.ToString("c")%> per person</td>
                            <td class="text3"> <%=g.commissionQUAD.ToString("c")%> Commissions</td>
						</tr>
					<%}%>
					<%if (g.TrplQuad.ToLower() == "yes") {%>
						<tr>
							<td class="text3">
								Triple/Quad Rate:
								<%
                                    if (g.TrplQuadRate > 0) Response.Write (g.TrplQuadRate.ToString("c") + " per person<br />");
								    if (g.TrplQuadComments != "") Response.Write (g.TrplQuadComments);
                                %>
							</td>
						</tr>
					<%}%>
				<%} else {%>
					<tr>
						<td class="text3">
							Group space has been released. Continue to book as FIT. Please advise Travel Product Development of all new bookings.
						</td>
					</tr>
				<%} // hiderates = false %>
			</table>
		</td>
	</tr>
	<% if (g.PortCharges > 0) {%>
		<tr>
			<td class="text4" valign="top">NON-COMMISSIONABLE FARE</td>
			<td class="text3">
				<%=g.PortCharges.ToString("c")%> per person  
				<% 
                    if (g.PortChargesIncluded.ToLower() == "yes") 
                        Response.Write (" (included in rate)");
                    else if(g.PortChargesIncluded.ToLower() == "no")
                        Response.Write (" (not included in rate)");
                %>
			</td>
		</tr>
	<%}%>
	<%if (g.GovtFees > 0) {%>
		<tr>
			<td class="text4" valign="top">GOVERNMENT FEES</td>
			<td class="text3">
				<%=g.GovtFees.ToString("c")%> per person  
				<% 
                    if (g.GovtFeesIncluded.ToLower() == "yes") 
                        Response.Write (" (included in rate)");
                    else if(g.GovtFeesIncluded.ToLower() == "no")
                        Response.Write (" (not included in rate)");
                %>
			</td>
		</tr>
	<%}%>
	<%if (g.Taxes > 0) {%>
		<tr>
			<td class="text4" valign="top">TAXES</td>
			<td class="text3">
				<%=g.Taxes.ToString("c")%> per person  
				<% 
                    if (g.TaxesIncluded.ToLower() == "yes") 
                        Response.Write (" (included in rate)");
                    else if (g.TaxesIncluded.ToLower() == "no")
                        Response.Write (" (not included in rate)");
                %>
			</td>
		</tr>
	<%}%>
	<%if (g.Miscellaneous > 0) {%>
		<tr>
			<td class="text4" valign="top">MISCELLANEOUS CHARGES</td>
			<td class="text3">
				<% 
                    if (g.MiscComments != "") Response.Write(g.MiscComments + "&nbsp;");
				    Response.Write(g.Miscellaneous.ToString("c") + " per person ");
                    if (g.MiscIncluded.ToLower() == "yes") 
                        Response.Write (" (included in rate)");
                    else if (g.MiscIncluded.ToLower() == "no")
                        Response.Write (" (not included in rate)");
                %>
			</td>
		</tr>
	<%}%>
	<%if (g.Disclaimer != "") {%>
		<tr>
			<td class="text4" valign="top">DISCLAIMER</td>
			<td class="text3"><%=g.Disclaimer%></td>
		</tr>
	<%}%>
</table>
<br>

<%if (g.Pre.ToLower() == "yes") {%>
	<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
		<tr>
			<td class="text4" valign="top" align="center" colspan="2">PRE PACKAGE</td>
		</tr>
		<tr>
			<td class="text4" valign="top" width="30%">RATES FROM</td>
			<td class="text3" width="70%"><%=g.PreAmount.ToString("c")%> per person</td>
		</tr>
		<tr>
			<td class="text4" valign="top">INCLUSIONS</td>
			<td class="text3">
				<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
				    <%foreach (DataRow dr in dtPre.Rows) {%>
					    <li><%=dr["include"]%></li>
				    <%}%>
				</ul>
			</td>
		</tr>
	</table><br />
<%}%>

<%if (g.Post.ToLower() == "yes") {%>
	<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
		<tr>
			<td class="text4" valign="top" align="center" colspan="2">POST PACKAGE</td>
		</tr>
		<tr>
			<td class="text4" valign="top" width="30%">RATES FROM</td>
			<td class="text3" width="70%">
			    <%if (g.PostAmount > 0) Response.Write(g.PostAmount.ToString("c") + " per person");%> 
            </td>
		</tr>
		<tr>
			<td class="text4" valign="top">INCLUSIONS</td>
			<td class="text3">
				<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
				    <%foreach (DataRow dr in dtPost.Rows) {%>
					    <li><%=dr["include"]%></li>
				    <%}%>
				</ul>
			</td>
		</tr>
	</table><br />
<%}%>
	
<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center" colspan="2">AIR RATES AND SCHEDULE</td>
	</tr>
	<tr>
		<td class="text4" valign="top" width="30%">COMMENTS</td>
		<td class="text3" width="70%">
			<%if (dtAir.Rows.Count == 0) {%>
                Most air schedules are available 30-45 days prior to departure. Contact the vendor for schedule, and airline for seat assignments. 
            <%}%>
            Air Itinerary subject to change.
		</td>
	</tr>
	<%if (g.SuggestCustomAir != "") {%>
		<tr>
			<td class="text4" valign="top">RECOMMEND</td>
			<td class="text3"><%=g.SuggestCustomAir%></td>
		</tr>
	<%}%>
	<%if (g.CustomAirAmount > 0) {%>
		<tr>
			<td class="text4">CUSTOM AIR FEE:</td>
			<td class="text3"><%=g.CustomAirAmount.ToString("c")%> per person</td>
		</tr>
	<%}%>

    <!-- AIR Starts -->
	<%if (dtAir.Rows.Count > 0) {%>
		  <%foreach (DataRow dr in dtAir.Rows) {%>
			<%if ((dr["Direction"]+"" != "Return") || (sched == 1)) {%>
				<%if (sched > 1) {%></td></tr><%}%>
				<tr>
				<td class="text4" colspan="2">
				Air Schedule # <%=sched %><br />
				<% sched = sched + 1; %>
			<%}%>
					<table width="100%" cellpadding="1" cellspacing="1" border="0">
						<tr>
							<td class="text4">
								<%=dr["Direction"] %>
							</td>
							<%if (dr["City"]+"" != "") {%>
								<td class="text3" align="center" bgcolor="#b2d3da" width="15%"><span class="vtext4">Air City:</span><br /> <% = dr["City"] %></td>
							<%}%>
							<%if (dr["Rate"] != DBNull.Value) {%>
								<td class="text3" align="center" bgcolor="#b2d3da" width="15%"><span class="vtext4">Air Rate:</span><br /> <% = Convert.ToDecimal(dr["Rate"]).ToString("c") %></td>
							<%}%>
							<%if (dr["Tax"] != DBNull.Value) {%>
								<td class="text3" align="center" bgcolor="#b2d3da" width="15%"><span class="vtext4">Air Tax:</span><br /> <% = Convert.ToDecimal(dr["Tax"]).ToString("c") %></td>
							<%}%>
							<%if (dr["surcharge"] != DBNull.Value) { %>
								<td class="text3" align="center" bgcolor="#b2d3da" width="20%"><span class="vtext4">Air Surcharge:</span><br /> <% = Convert.ToDecimal(dr["surcharge"]).ToString("c") %></td>
							<%}%>
							<%if (dr["other"] != DBNull.Value) { %>
								<td class="text3" align="center" bgcolor="#b2d3da" width="15%"><span class="vtext4"><% = dr["other"] %>:</span><br /> <% = Convert.ToDecimal(dr["otherAmount"]).ToString("c") %></td>
							<%}%>
						</tr>
					</table>
					<table width="100%" cellpadding="1" cellspacing="1" border="0">
						<%for (int x = 1; x < 3; x++) {%>
							<%if ((x == 1) || (x == 2 && (bool) dr["anotherflight"])) {%>
								<tr>
									<td class="text3" width="16%"><% = dr["airline" + x] %></td>
									<td class="text3" width="14%"><% = dr["flight" + x] %></td>
									<td class="text3" width="14%">
										<%
                                            if (Util.isValidDate(dr["departureDate"+x]+""))
                                                Response.Write (Convert.ToDateTime(dr["departureDate"+x]).ToString("dd MMM"));
										%>
									</td>
									<td class="text3" width="14%"><% = dr["FromCity" + x] %></td>
									<td class="text3" width="14%"><% = dr["ToCity" + x] %></td>
									<td class="text3" width="14%">
										<%Response.Write(FmtTime(dr["departureTime" + x]));%>
									</td>
									<td class="text3" width="14%">
										<%Response.Write(FmtTime(dr["arrivalTime" + x]));%>
									</td>
								</tr>
							<%}%>
						<%}%>
					</table>
				</td>
			</tr>
		<%}%>
    <%}%>
    <!-- AIR Ends -->
</table>
<br />

<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center" colspan="2">TRANSFERS/COSTS</td>
	</tr>
	<tr>
		<td class="text4" valign="top" width="30%">TRANSFERS INCLUDED</td>
		<td class="text3" width="70%"><%=g.TransfersIncluded%></td>
	</tr>
	<%if (g.TransfersCost != "") {%>
		<tr>
			<td class="text4">TRANSFERS COST</td>
			<td class="text3">$<% =g.TransfersCost%></td>
		</tr>
	<%}%>
</table><br />

<%if (g.MotorCoach.ToLower() == "yes") {%>
	<% count = count + 1; %>
	<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
		<tr>
			<td class="text4" valign="top" width="30%">MOTORCOACH INSTRUCTIONS</td>
			<td class="text3" width="70%">
				<table width="100%" cellpadding="3" cellspacing="0" border="0">
				    <%foreach (DataRow dr in dtMotorCoach.Rows) {%>
						<tr>
							<td class="text3"><% =dr["include"] %></td>
						</tr>
				    <%}%>
				</table>
			</td>
		</tr>
	</table><br />
<%}%>

<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" align="center" colspan="2">PAYMENT</td>
	</tr>
	<tr>
		<td class="text4" width="30%">DEPOSIT AMOUNT</td>
		<td class="text3" width="70%"><% = g.DepositAmount %> <%=g.DepUnitDescription%></td>
	</tr>
	
	<tr>
		<td class="text4" valign="top">PROCESSING OF DEPOSIT</td>
		<td class="text3">
			<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
			<%
   			    string [] procDepArray = g.ProcessDeposit.Split(new char[] {','});
			    foreach (string str in procDepArray)
				    Response.Write("<li>" + str + "<br></li>");
			    if (g.ProcessDepositOther != "") 
				    Response.Write("<li>" + g.ProcessDepositOther + "</li>");
			%>
			</ul>
		</td>
	</tr>
	<tr>
		<td class="text4">FINAL PAYMENT DATE</td>
		<td class="text3"><% =g.FinalPmtDate %></td>
	</tr>
	<tr>
		<td class="text4" valign="top">PROCESSING OF FINAL PAYMENT</td>
		<td class="text3">
			<ul style="margin-left:15px; padding-left:5px; margin-right:0px; padding-right:5px; margin-bottom:0px">
			<%
   			    string [] procPayArray = g.ProcessPayment.Split(new char[] {','});
			    foreach (string str in procPayArray)
				    Response.Write("<li>" + str + "<br></li>");
			    if (g.ProcessPaymentOther != "") 
				    Response.Write("<li>" + g.ProcessPaymentOther + "</li>");
			%>
			</ul>
		</td>
	</tr>
</table>
<br>
<table width="100%" cellpadding="3" cellspacing="0" border="1" bordercolor="#03809e">
	<tr>
		<td class="text4" valign="top" width="30%">CANCELLATION POLICY</td>
		<td width="70%">
			<table width="100%" cellpadding="3" cellspacing="0" border="0">
				<tr>
					<td class="text3">
						<table width="100%" cellpadding="2" cellspacing="1" border="0">
							<tr bgcolor="#b2d3da">
								<td class="text4" align="center" width="15%">From</td>
								<td class="text4" align="center" width="15%">To</td>
								<td class="text4" width="70%">Policy</td>
							</tr>
							<%foreach (mtCancelPolicy canc in listCanc) {%>
								<%if (canc.dateFr != "") {%>
									<tr>
										<td class="text3" align="center"><% = canc.dateFr %></td>
										<td class="text3" align="center"><% = canc.dateTo %></td>
										<td class="text3"><% = canc.policy %></td>
									</tr>
								<%}%>
							<%}%>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>

</table>
			<br /><br />
		</td>
	</tr>	
</table>
</body>
</html>