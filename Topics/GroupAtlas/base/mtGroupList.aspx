<%@ Page Language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script language="C#" runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        DateTime dt;
        if (!IsPostBack)
        {
            message.InnerHtml = Request.QueryString["msg"];
            //departfr.Text = DateTime.Today.ToShortDateString();
            Ddepartfr.SelectedDate = DateTime.Today;
            dt = Convert.ToDateTime(Ddepartfr.SelectedDate);
            departfr.Text = dt.ToShortDateString();
            //departto.Text = "";
            Ddepartto.SelectedDate = null;
            departto.Text = "";

            if (Request.QueryString["clear"]+"" != "Y" && Request.Cookies["mtgrouplist_departfr"] != null)
            {
                try
                {
                    departfr.Text = Request.Cookies["mtgrouplist_departfr"].Value;
                    departto.Text = Request.Cookies["mtgrouplist_departto"].Value;
                    Ddepartfr.SelectedDate = Convert.ToDateTime(Request.Cookies["mtgrouplist_departfr"].Value);
                    Ddepartto.SelectedDate = Convert.ToDateTime(Request.Cookies["mtgrouplist_departto"].Value);
                    status.SelectedValue = Request.Cookies["mtgrouplist_status"].Value;
                    searchstr.Text = Request.Cookies["mtgrouplist_searchstr"].Value;
                    Grid.PageIndex = Util.parseInt(Request.Cookies["mtgrouplist_pageindex"].Value);
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
        Response.Cookies["mtgrouplist_departfr"].Value = departfr.Text;

        dt = Convert.ToDateTime(Ddepartto.SelectedDate);
        departto.Text = dt.ToShortDateString();
        if (departto.Text == "1/1/0001")
        {
            //departto.Text = "1/1/1901";
            departto.Text = "";
        }
        Response.Cookies["mtgrouplist_departto"].Value = departto.Text;

        Response.Cookies["mtgrouplist_status"].Value = status.SelectedValue;
        Response.Cookies["mtgrouplist_searchstr"].Value = searchstr.Text;
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
            e.Row.Cells[0].ColumnSpan --;
            e.Row.Cells.Add(td);
        }
    }

    protected void Grid_DataBound(object sender, EventArgs e)
    {
        Response.Cookies["mtgrouplist_pageindex"].Value = Grid.PageIndex.ToString();
    }

    protected string Action(object container)
    {
        string ret = "";
        DataRowView dr = (DataRowView)container;
        string groupCode = dr["groupcode"]+"";
        string mode = (Security.IsAdmin() || ("Approved|Rejected".IndexOf(dr["status"] + "") == -1)) ? "Edit" : "View";
        ret += string.Format("<a class=\"slnk\" href=\"mtGroupEdit.aspx?groupcode={0}\">{1}</a>", groupCode, mode);
        if (Security.IsAdmin())
            ret += string.Format("&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" {1} href=\"mtGroupDel.aspx?groupcode={0}\">Delete</a>", groupCode, (Security.IsAdmin()) ? "" : "disabled='disabled'");
        else
            ret += "&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" disabled='disabled' onclick=\"javascript:return false\" href=\"\">Delete</a>";
        ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"\" onclick=\"javascript:popupFlyer('AgentFlyer.aspx?groupcode={0}');return false;\">View Agent Flyer</a>", groupCode);
        ret += string.Format("<br><a class=\"slnk\" href=\"\" onclick=\"javascript:popupFlyer('Flyer.aspx?groupcode={0}&overrideDisplay=Y');return false;\">View Flyer</a>&nbsp;&nbsp;&nbsp;&nbsp;", groupCode);
        if (dr["status"] + "" == "In Development")
            ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"\" onclick=\"javascript:requestApproval('{0}');return false;\">Request Approval</a>", groupCode);
        else if (dr["status"] + "" == "Pending Approval")
        {
            if (Security.IsAdmin())
            {
                ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"mtGroupApprove.aspx?groupcode={0}\">Approve</a>", groupCode);
                ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"mtGroupReject.aspx?groupcode={0}\">Reject</a>", groupCode);
            }
            else
            {
                ret += "&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" disabled='disabled' onclick=\"javascript:return false\" href=\"\">Approve</a>";
                ret += "&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" disabled='disabled' onclick=\"javascript:return false\" href=\"\">Reject</a>";
            }
        }
        else if ("Approved|Rejected".IndexOf(dr["status"] + "") > -1)
        {
            ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"\" onclick=\"javascript:reOpen('{0}');return false;\">Reopen</a>", groupCode);
        }
        ret += "<br>&nbsp;";
        return ret;
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
        Response.Cookies["mtgrouplist_departfr"].Value = departfr.Text;
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
        Response.Cookies["mtgrouplist_departto"].Value = departto.Text;
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">

    <script type="text/javascript">
        function requestApproval(groupcode) {
            if (confirm('Are you sure you want to request approval of this group?')) {
                window.location.href = "mtGroupRequestAprv.aspx?groupcode=" + groupcode;
            }
        }
        function reOpen(groupcode) {
            if (confirm('Reopen will allow users to edit and re-submit for approval\r\nAre you sure you want to re-open group #'+groupcode+'?')) {
                window.location.href = "mtGroupReopen.aspx?groupcode=" + groupcode;
            }
        }
    </script>

    <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr>
            <td> <span id="message" class="message" runat="server" enableviewstate="false"></span></td>
            <%--<td align="right" class="message">NB. Migrated from Manager Tool</td>--%>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
    </table>
    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="valsumry" HeaderText="Please correct the following:" DisplayMode="BulletList" ShowMessageBox="true" ShowSummary="false"></asp:ValidationSummary>
        
    <table cellpadding="0" cellspacing="0" width="100%">
    <tr valign="bottom">
        <td>
    <table cellpadding="0" cellspacing="0">
        <tr valign="bottom">
            <td class="small"><b>Depart From:</b>&nbsp;<br />
                <%--<asp:TextBox ID="departfr" Width="80px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departfr.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <asp:TextBox ID="departfr" Width="80px" runat="server" MaxLength="12" Visible="false" />
                <telerik:RadDatePicker RenderMode="Lightweight" ID="Ddepartfr" width="100px" runat="server" OnSelectedDateChanged="departfr_SelectedDateChanged" AutoPostBack="true" >
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td class="small"><b>To:</b>&nbsp;<br />
                <%--<asp:TextBox ID="departto" Width="80px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departto.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <asp:TextBox ID="departto" Width="80px" runat="server" MaxLength="12" Visible="false"/>
                <telerik:RadDatePicker RenderMode="Lightweight" ID="Ddepartto" width="100px" runat="server" OnSelectedDateChanged="departto_SelectedDateChanged" AutoPostBack="true">
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td class="small"><b>Status:</b><br />
               <%-- <asp:DropDownList runat="server" ID="status" Width="150px">
                    <asp:ListItem Value="">All </asp:ListItem>
                    <asp:ListItem>In Development</asp:ListItem>
                    <asp:ListItem>Pending Approval</asp:ListItem>
                    <asp:ListItem>Approved</asp:ListItem>
                    <asp:ListItem>Rejected</asp:ListItem>
                </asp:DropDownList>--%>
                <telerik:RadDropDownList runat="server" ID="status" Width="150px" AppendDataBoundItems="true" Skin="Telerik">
                    <Items>
                        <telerik:DropDownListItem Value="" Text="All"/>
                        <telerik:DropDownListItem Value="Approved" Text="Approved"/>
                        <telerik:DropDownListItem Value="In Development" Text="In Development"/>
                        <telerik:DropDownListItem Value="Pending Approval" Text="Pending Approval"/>
                        <telerik:DropDownListItem Value="Rejected" Text="Rejected"/>
                    </Items>
                </telerik:RadDropDownList>
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
            <td class="small"><b>Keyword:</b><br />
                <asp:TextBox ID="searchstr" Width="150px" runat="server" MaxLength="25" />
            </td>
            <td>&nbsp;&nbsp;&nbsp;</td>
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
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='mtGroupAdd.aspx';return false;" style="width: 100px" value="   Add   " />
             </td>
    </tr>
    </table>
    <hr />
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="25" GridLines="Both" AllowPaging="true" 
        AllowSorting="true" DataSourceID="GroupSource" DataKeyNames="groupcode" AutoGenerateColumns="False" onrowcreated="Grid_RowCreated" ondatabound="Grid_DataBound">
        <HeaderStyle CssClass="listhdr" />
        <RowStyle VerticalAlign="Top" />
        <AlternatingRowStyle BackColor="Lightgreen" />
        <Columns>
	        <asp:HyperLinkField DataTextField="groupcode" HeaderText="Group#" HeaderStyle-HorizontalAlign="Left" SortExpression="groupcode" DataNavigateUrlFormatString="mtGroupEdit.aspx?groupcode={0}" DataNavigateUrlFields="groupcode" />  
            <asp:BoundField DataField="departuredate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Depart" DataFormatString="{0:d}" SortExpression="departuredate" />
            <asp:BoundField DataField="returndate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Return" DataFormatString="{0:d}" SortExpression="returndate" />
            <asp:BoundField DataField="typedescription" HeaderText="Pkg. Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="typedescription" />
            <asp:BoundField DataField="heading" HeaderText="Heading" HeaderStyle-HorizontalAlign="Left" HtmlEncode="false" SortExpression="heading" />
            <asp:BoundField DataField="templatetitle" HeaderText="Template" HeaderStyle-HorizontalAlign="Left" HtmlEncode="false" SortExpression="i.template" />
            <asp:CheckBoxField DataField="SpecialtyGroup" HeaderText="Specialty Group" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"  SortExpression="SpecialtyGroup" />
            <asp:CheckBoxField DataField="DoNotDisplay" HeaderText="Don't Display" HeaderStyle-HorizontalAlign="Center"  ItemStyle-HorizontalAlign="Center" SortExpression="DoNotDisplay" />
            <%--<asp:BoundField DataField="status" HeaderText="Status" HeaderStyle-HorizontalAlign="Left"  SortExpression="status" />--%>
            <asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" HeaderText="Status" HeaderStyle-HorizontalAlign="Left" SortExpression="status" >
                <ItemTemplate>  
                    <asp:Label ID="lblStatus" runat="server" 
                        Text='<%# Eval("status") %>'
                        ForeColor='<%# Convert.ToString(Eval("status")) == "Canceled" ? System.Drawing.Color.Red: 
                            Convert.ToString(Eval("status")) == "Approved" ? System.Drawing.Color.Blue: 
                            Convert.ToString(Eval("status")) == "In Development" ? System.Drawing.Color.Black: 
                            Convert.ToString(Eval("status")) == "Pending Approval" ? System.Drawing.Color.Maroon: 
                            Convert.ToString(Eval("status")) == "Rejected" ? System.Drawing.Color.Red: 
                            System.Drawing.Color.Purple%>'>
                    </asp:Label>  
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-Width="175px" ItemStyle-Width="175px" HeaderText="Action" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <%# Action(Container.DataItem) %>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="GroupSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.mtGroup" EnablePaging="True" SortParameterName="sortExpression">
        <SelectParameters>
            <asp:ControlParameter Name="departfr" ControlID="departfr" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="departto" ControlID="departto" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="status" ControlID="status" DefaultValue="" PropertyName="SelectedValue" Type="String" />
            <asp:ControlParameter Name="searchstr" ControlID="searchstr" DefaultValue="" PropertyName="Text" Type="String" />
        </SelectParameters>
    </asp:ObjectDataSource>
</asp:Content>
