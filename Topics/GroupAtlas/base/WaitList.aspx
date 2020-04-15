<%@ Page Language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script language="C#" runat="server">

	void Page_Load(object sender, System.EventArgs e)
	{
        if (!IsPostBack)
        {
            message.InnerHtml = Request.QueryString["msg"];
            searchstr.Text = Request.QueryString["searchstr"] + "";
            departfr.Text = DateTime.Today.ToShortDateString();
            departto.Text = "";
            if (Request.QueryString["clear"]+"" != "Y" && Request.Cookies["waitlist_departfr"] != null)
            {
                try
                {
                    departfr.Text = Request.Cookies["waitlist_departfr"].Value;
                    departto.Text = Request.Cookies["waitlist_departto"].Value;
                    grouptype.SelectedValue = Request.Cookies["waitlist_grouptype"].Value;
                    revtype.SelectedValue = Request.Cookies["waitlist_revtype"].Value;
                    searchstr.Text = Request.Cookies["waitlist_searchstr"].Value;
                    Grid.PageIndex = Util.parseInt(Request.Cookies["waitlist_pageindex"].Value);
                }
                catch { }
            }
        }
        // Save
        Response.Cookies["waitlist_departfr"].Value = departfr.Text;
        Response.Cookies["waitlist_departto"].Value = departto.Text;
        Response.Cookies["waitlist_grouptype"].Value = grouptype.SelectedValue;
        Response.Cookies["waitlist_revtype"].Value = revtype.SelectedValue;
        Response.Cookies["waitlist_searchstr"].Value = searchstr.Text;
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
        if (e.Row.RowType==DataControlRowType.Pager)
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
        Response.Cookies["waitlist_pageindex"].Value = Grid.PageIndex.ToString();
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
<br />
<h1>Waiting List</h1>

    <span id="message" class="message" runat="server" enableviewstate="false"></span><br />
    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="valsumry" HeaderText="Please correct the following:" DisplayMode="BulletList" ShowMessageBox="true" ShowSummary="false"></asp:ValidationSummary>
        
    <table cellpadding="0" cellspacing="0" width="100%">
    <tr valign="bottom">
        <td>
    <table cellpadding="0" cellspacing="0">
        <tr valign="bottom">
            <td class="small"><b>Depart From:</b>&nbsp;<br />
                <asp:TextBox ID="departfr" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departfr.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>To:</b>&nbsp;<br />
                <asp:TextBox ID="departto" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departto.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>Group Type:</b><br />
                <asp:DropDownList runat="server" ID="grouptype" Width="120px" DataSourceID="GroupTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <asp:ListItem Value="0">All </asp:ListItem>
                </asp:DropDownList>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>Travel Type:</b><br />
                <asp:DropDownList runat="server" ID="revtype" Width="100px" DataSourceID="RevTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true">
                    <asp:ListItem Value="">All </asp:ListItem>
                </asp:DropDownList>
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
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='GroupList.aspx?addwaitlist=Y';return false;" value="Add to Waiting List" />
             </td>
    </tr>
    </table>

    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="25" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" DataSourceID="WaitListSource" DataKeyNames="waitlistid" 
        AutoGenerateColumns="False" onrowcreated="Grid_RowCreated" ondatabound="Grid_DataBound">
        <HeaderStyle CssClass="listhdr" />
        <Columns>
	        <asp:HyperLinkField Text="Edit" HeaderText="Edit" HeaderStyle-HorizontalAlign="Left" DataNavigateUrlFormatString="WaitListEdit.aspx?waitlistid={0}" DataNavigateUrlFields="waitlistid" />  
            <asp:BoundField DataField="created" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Created Date" DataFormatString="{0:d}" SortExpression="w.created" />
            <asp:BoundField DataField="groupid" HeaderText="Group #" HeaderStyle-HorizontalAlign="Left"  SortExpression="m.groupid" />
            <asp:BoundField DataField="groupname" HeaderText="Group Name" HeaderStyle-HorizontalAlign="Left"  SortExpression="m.GroupName" />
            <asp:BoundField DataField="departdate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Depart" DataFormatString="{0:d}" SortExpression="m.departdate" />
            <asp:BoundField DataField="returndate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Return" DataFormatString="{0:d}" SortExpression="m.returndate" />
            <asp:BoundField DataField="grouptypedesc" HeaderText="Group Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p.PickDesc" />
            <asp:BoundField DataField="revtypedesc" HeaderText="Travel Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p2.PickDesc" />
            <asp:BoundField DataField="bookingagentname" HeaderText="Agent" HeaderStyle-HorizontalAlign="Left"  SortExpression="ga.Agent" />
            <asp:BoundField DataField="firstname" HeaderText="First Name" HeaderStyle-HorizontalAlign="Left"  SortExpression="w.FirstName" />
            <asp:BoundField DataField="lastname" HeaderText="Last Name" HeaderStyle-HorizontalAlign="Left"  SortExpression="w.LastName" />
            <asp:BoundField DataField="phone" HeaderText="Phone" HeaderStyle-HorizontalAlign="Left"  SortExpression="w.Phone" />
            <asp:BoundField DataField="email" HeaderText="Email" HeaderStyle-HorizontalAlign="Left"  SortExpression="w.Email" />
            <asp:BoundField DataField="paxcnt" HeaderText="Pax. Cnt" HeaderStyle-HorizontalAlign="Left"  SortExpression="w.paxcnt" />
            <asp:CheckBoxField DataField="isconverted" HeaderText="Converted?" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" SortExpression="w.isconverted" />
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="WaitListSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.WaitList" EnablePaging="True" SortParameterName="sortExpression">
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
