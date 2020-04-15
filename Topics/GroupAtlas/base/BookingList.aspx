<%@ Page Language="c#" MasterPageFile="MasterPage.master"%>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>



<script language="C#" runat="server">
    void Page_Load(object sender, System.EventArgs e)
    {
        DateTime dt;
        if (!IsPostBack)
        {
            message.InnerHtml = Request.QueryString["msg"];
            searchstr.Text = Request.QueryString["searchstr"] + "";
            //departfr.Text = DateTime.Today.ToShortDateString();
            Ddepartfr.SelectedDate = DateTime.Today;
            dt = Convert.ToDateTime(Ddepartfr.SelectedDate);
            departfr.Text = dt.ToShortDateString();
            Ddepartto.SelectedDate = null;
            departto.Text = "";
            if (Request.QueryString["clear"] + "" != "Y" && Request.Cookies["bookinglist_departfr"] != null)
            {
                try
                {
                    departfr.Text = Request.Cookies["bookinglist_departfr"].Value;
                    departto.Text = Request.Cookies["bookinglist_departto"].Value;
                    Ddepartfr.SelectedDate = Convert.ToDateTime(Request.Cookies["bookinglist_departfr"].Value);
                    Ddepartto.SelectedDate = Convert.ToDateTime(Request.Cookies["bookinglist_departto"].Value);
                    grouptype.SelectedValue = Request.Cookies["bookinglist_grouptype"].Value;
                    revtype.SelectedValue = Request.Cookies["bookinglist_revtype"].Value;
                    searchstr.Text = Request.Cookies["bookinglist_searchstr"].Value;
                    Grid.PageIndex = Util.parseInt(Request.Cookies["bookinglist_pageindex"].Value);
                }
                catch { }
            }
        }
        // Save
        dt = Convert.ToDateTime(Ddepartfr.SelectedDate);
        departfr.Text = dt.ToShortDateString();
        if (departfr.Text == "1/1/0001")
        {
            //departfr.Text = "1/1/1901";
            departfr.Text = "";
        }
        Response.Cookies["bookinglist_departfr"].Value = departfr.Text;

        dt = Convert.ToDateTime(Ddepartto.SelectedDate);
        departto.Text = dt.ToShortDateString();
        if (departto.Text == "1/1/0001")
        {
            //departto.Text = "1/1/1901";
            departto.Text = "";
        }
        Response.Cookies["bookinglist_departto"].Value = departto.Text;
        Response.Cookies["bookinglist_grouptype"].Value = grouptype.SelectedValue;
        Response.Cookies["bookinglist_revtype"].Value = revtype.SelectedValue;
        Response.Cookies["bookinglist_searchstr"].Value = searchstr.Text;
    }

    protected void Search_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid)
            return;
        Grid.PageIndex = 0;
        Grid.DataBind();
    }

    protected void Grid_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Pager)
        {
            TableCell td = new TableCell();
            td.Style.Add("text-align", "right");
            td.Text = string.Format("Page {0} of {1}&nbsp;&nbsp;({2} results)", (Grid.PageIndex + 1), Grid.PageCount, GroupMaster.GetPagedCount());
            e.Row.Cells[0].ColumnSpan = e.Row.Cells[0].ColumnSpan - 2;
            e.Row.Cells.Add(td);
            e.Row.Cells[1].ColumnSpan = e.Row.Cells[1].ColumnSpan + 2;
        }
    }

    protected void Grid_DataBound(object sender, EventArgs e)
    {
        Response.Cookies["bookinglist_pageindex"].Value = Grid.PageIndex.ToString();
    }

    protected void Export_Click(object sender, EventArgs e)
    {
        GroupBooking.Export(departfr.Text, departto.Text, Util.parseInt(grouptype.SelectedValue), revtype.SelectedValue, searchstr.Text);
    }

    protected void Grid_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView drv = e.Row.DataItem as DataRowView;
            if (drv.Row.ItemArray[16].ToString().Equals("W"))
            {
                e.Row.BackColor = System.Drawing.Color.Yellow;
                e.Row.ForeColor = System.Drawing.Color.DarkRed;
            }
        }
    }

    protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Email")
        {
            int row = Convert.ToInt32(e.CommandArgument);
            GridViewRow Index = Grid.Rows[row];
            string GroupID = Grid.DataKeys[Index.RowIndex].Values[1].ToString();
            string BookingID = Grid.DataKeys[Index.RowIndex].Values[0].ToString();

            Session["GroupId"] = GroupID;
            //Response.Redirect("~/EmailPop.aspx");
            //ScriptManager.RegisterStartupScript(Page, typeof(Page), "OpenWindow", "window.open('EmailPop.aspx');", true);
            ScriptManager.RegisterStartupScript(Page, typeof(Page), "OpenWindow", "findEmails();", true);

        }
    }

    protected void departto_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        DateTime dt = Convert.ToDateTime(Ddepartfr.SelectedDate);
        departfr.Text = dt.ToShortDateString();
        if (departfr.Text == "1/1/0001")
        {
            //departfr.Text = "1/1/1901";
            departfr.Text = "";
        }
        Response.Cookies["bookinglist_departfr"].Value = departfr.Text;
    }

    protected void departfr_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        DateTime dt = Convert.ToDateTime(Ddepartto.SelectedDate);
        departto.Text = dt.ToShortDateString();
        if (departto.Text == "1/1/0001")
        {
            //departto.Text = "1/1/1901";
            departto.Text = "";
        }
        Response.Cookies["bookinglist_departto"].Value = departto.Text;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <script type="text/javascript">
        function findEmails() {var url = "EmailPop.aspx"; popupWin(url);}
    </script>

    <span id="message" class="message" runat="server" enableviewstate="false"></span><br />
    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="valsumry" HeaderText="Please correct the following:" DisplayMode="BulletList" ShowMessageBox="true" ShowSummary="false"></asp:ValidationSummary>
        
    <table cellpadding="0" cellspacing="0" width="100%">
    <tr valign="bottom">
        <td>
    <table cellpadding="0" cellspacing="0">
        <tr valign="bottom">
            <td class="small"><b>Depart From:</b>&nbsp;<br />
                <%--<asp:TextBox ID="departfr" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departfr.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <asp:TextBox ID="departfr" Width="80px" runat="server" MaxLength="12" Visible="false" />
                <telerik:RadDatePicker RenderMode="Lightweight" ID="Ddepartfr" width="100px" runat="server" OnSelectedDateChanged="departfr_SelectedDateChanged" AutoPostBack="true" >
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>To:</b>&nbsp;<br />
                <%--<asp:TextBox ID="departto" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departto.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <asp:TextBox ID="departto" Width="80px" runat="server" MaxLength="12" Visible="false"/>
                <telerik:RadDatePicker RenderMode="Lightweight" ID="Ddepartto" width="100px" runat="server" OnSelectedDateChanged="departto_SelectedDateChanged" AutoPostBack="true">
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
            </td>
            <td>&nbsp;&nbsp;</td>
            <%--<td class="small"><b>Group Type:</b><br />
                <asp:DropDownList runat="server" ID="grouptype" Width="120px" DataSourceID="GroupTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <asp:ListItem Value="0">All </asp:ListItem>
                </asp:DropDownList>
            </td>--%>
            <td class="small"><b>Group Type:</b><br />
                <telerik:RadDropDownList runat="server" ID="grouptype" Width="120px" DataSourceID="GroupTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <Items>
                        <telerik:DropDownListItem Value="0" Text="All"/>
                    </Items>
                </telerik:RadDropDownList>
            </td>
            <td>&nbsp;&nbsp;</td>
            <%--<td class="small"><b>Travel Type:</b><br />
                <asp:DropDownList runat="server" ID="revtype" Width="100px" DataSourceID="RevTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <asp:ListItem Value="">All </asp:ListItem>
                </asp:DropDownList>
            </td>--%>
            <td class="small"><b>Travel Type:</b><br />
                <telerik:RadDropDownList runat="server" ID="revtype" Width="100px" DataSourceID="RevTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <Items>
                        <telerik:DropDownListItem Value="" Text="All"/>
                    </Items>
                </telerik:RadDropDownList>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>Keyword:</b><br />
                <asp:TextBox ID="searchstr" Width="150px" runat="server" MaxLength="25" />
            </td>
            <td>&nbsp;&nbsp;</td>
            <td>
                <asp:Button CssClass="topbutton" ID="searchbtn" OnClick="Search_Click" runat="server" Text="Search" />
            </td>
            <td>&nbsp;&nbsp;</td>
            <td>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="departfr" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure start date is invalid" Type="Date">*</asp:CompareValidator>
                <asp:RequiredFieldValidator ID="ReqExpFrom" runat="server" ControlToValidate="departfr"  CssClass="error" Display="Dynamic" ErrorMessage="Departure start date is required">*</asp:RequiredFieldValidator>
                <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="departto" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure end date is invalid" Type="Date">*</asp:CompareValidator>
            </td>

        </tr>
    </table>
        </td>    
            <td align="right">
                &nbsp;&nbsp;<input type="button" style="width: 85px" onclick="javascript:window.location.href='GroupList.aspx?newbooking=Y';return false;" value="New Booking" />&nbsp;
            <!--    <input type="button" style="width: 100px" onclick="javascript:window.location.href='GroupList.aspx?addwaitlist=Y';return false;" value="Add to Wait List" />&nbsp; -->
            <!--    <input type="button"style="width: 75px" onclick="javascript:window.location.href='WaitList.aspx';return false;" value="Waiting List" />&nbsp;  -->
                <asp:Button CssClass="button" ID="export" Width="60px" OnClick="Export_Click" runat="server" Text="Export" />
             </td>
    </tr>
    </table>
    <hr />
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="25" GridLines="Both" AllowPaging="true" AllowSorting="true" DataSourceID="BookingSource" DataKeyNames="bookingid, groupid" 
        AutoGenerateColumns="False" onrowcreated="Grid_RowCreated" ondatabound="Grid_DataBound" OnRowDataBound="Grid_RowDataBound" OnRowCommand="Grid_RowCommand">
        <HeaderStyle CssClass="listhdr" />
        <AlternatingRowStyle BackColor="Lightblue" />
        <Columns>
	        <asp:HyperLinkField DataTextField="bookingid" HeaderText="Booking ID" HeaderStyle-HorizontalAlign="Left" SortExpression="b.bookingid" DataNavigateUrlFormatString="BookingView.aspx?bookingid={0}" DataNavigateUrlFields="bookingid" />  
            <asp:BoundField DataField="bookingdate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Booking Date" DataFormatString="{0:d}" SortExpression="b.bookingdate" />
            <%--<asp:BoundField DataField="statusdesc" HeaderText="Status" HeaderStyle-HorizontalAlign="Left"  SortExpression="b.StatusDesc" />--%>
            <asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" HeaderText="Status" HeaderStyle-HorizontalAlign="Left" SortExpression="statusdesc" >
                <ItemTemplate>  
                    <asp:Label ID="lblStatus" runat="server" 
                        Text='<%# Eval("statusdesc") %>'
                        ForeColor='<%# Convert.ToString(Eval("statusdesc")) == "Canceled" ? System.Drawing.Color.Red: 
                            Convert.ToString(Eval("statusdesc")) == "Active" ? System.Drawing.Color.Green: 
                            Convert.ToString(Eval("statusdesc")) == "Wait List" ? System.Drawing.Color.Navy: 
                            System.Drawing.Color.Purple%>'>
                    </asp:Label>  
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="groupid" HeaderText="Group #" HeaderStyle-HorizontalAlign="Left"  SortExpression="m.groupid" />
            <asp:BoundField DataField="groupname" HeaderText="Group Name" HeaderStyle-HorizontalAlign="Left"  SortExpression="m.GroupName" />
            <asp:BoundField DataField="departdate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Depart" DataFormatString="{0:d}" SortExpression="m.departdate" />
            <asp:BoundField DataField="grouptypedesc" HeaderText="Group Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p.PickDesc" />
            <asp:BoundField DataField="revtypedesc" HeaderText="Travel Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p2.PickDesc" />
            <asp:BoundField DataField="bookingagentname" HeaderText="Agent" HeaderStyle-HorizontalAlign="Left"  SortExpression="ga.Agent" />
            <asp:BoundField DataField="paxname" HeaderText="Primary Passenger" HeaderStyle-HorizontalAlign="Left"  SortExpression="px.LastName" />
            <asp:ButtonField ImageUrl="~/images/Email.png" CommandName="Email" ButtonType="Image" HeaderText="Email" />
            <asp:BoundField DataField="paxcnt" HeaderText="# Pax" HeaderStyle-HorizontalAlign="Left"  SortExpression="b.paxcnt" />
            <asp:BoundField DataField="billamount" HeaderText="Billed" HeaderStyle-HorizontalAlign="Left" DataFormatString="{0:c}" SortExpression="b.billamount" />
            <asp:BoundField DataField="pmtamount" HeaderText="Paid" HeaderStyle-HorizontalAlign="Left"  DataFormatString="{0:c}" SortExpression="b.pmtamount" />
            <asp:BoundField DataField="dueamount" HeaderText="Due" HeaderStyle-HorizontalAlign="Left"  DataFormatString="{0:c}" SortExpression="b.billamount-b.pmtamount" />
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="BookingSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.GroupBooking" EnablePaging="True" SortParameterName="sortExpression">
        <SelectParameters>
            <asp:ControlParameter Name="departfr" ControlID="departfr" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="departto" ControlID="departto" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="grouptype" ControlID="grouptype" DefaultValue="0" PropertyName="SelectedValue" Type="Int32" />
            <asp:ControlParameter Name="revtype" ControlID="revtype" DefaultValue="" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter Name="searchstr" ControlID="searchstr" DefaultValue="" PropertyName="Text" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="GroupTypeSource" runat="server" SelectMethod="GetPickList" TypeName="GM.PickList">
        <SelectParameters>
            <asp:Parameter Name="pickType" DefaultValue="GROUPTYPE" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="RevTypeSource" runat="server" SelectMethod="GetPickList" TypeName="GM.PickList">
        <SelectParameters>
            <asp:Parameter Name="pickType" DefaultValue="REVTYPE" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>

</asp:Content>
