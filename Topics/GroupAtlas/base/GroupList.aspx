<%@ Page Language="c#" MasterPageFile="MasterPage.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>


<script language="C#" runat="server">
    void Page_Load(object sender, System.EventArgs e)
    {
        //string abc = "";
        //abc = Session["FirstTime"].ToString();
        //int s = Convert.ToInt32(Session["Security"].ToString());
        //if (s > 1) tabFileMaint.Enabled = false;
        if (!IsPostBack)
        {
            Session["PostBack"] = 0;
            message.InnerHtml = Request.QueryString["msg"];
            //if (abc == "1")
            //{
            //    departfr.Text = DateTime.Today.ToShortDateString();
            //}
            ////departfr.Text = DateTime.Today.ToShortDateString();
            //else
            //{
            //departto.Text = "";
            departto.SelectedDate = null;
            //}

            ////Vendor Group Code DDL
            //VgroupCode.DataSource = mtVendor.GetVGroupCode();
            //VgroupCode.DataBind();
            if (Request.QueryString["clear"] + "" != "Y" && Request.Cookies["grouplist_departfr"] != null)
            {
                try
                {
                    //departfr.Text = Request.Cookies["grouplist_departfr"].Value;
                    if (Request.Cookies["grouplist_departfr"].Value == "")
                    {
                        departfr.SelectedDate = null;
                    }
                    else
                    {
                        departfr.SelectedDate = Convert.ToDateTime(Request.Cookies["grouplist_departfr"].Value);
                    }

                    //departto.Text = Request.Cookies["grouplist_departto"].Value;
                    if (Request.Cookies["grouplist_departto"].Value == "")
                    {
                        departto.SelectedDate = null;
                    }
                    else
                    {
                        departto.SelectedDate = Convert.ToDateTime(Request.Cookies["grouplist_departto"].Value);
                    }
                    Session["PostBack"] = 1;
                    grouptype.SelectedValue = Request.Cookies["grouplist_grouptype"].Value;
                    revtype.SelectedValue = Request.Cookies["grouplist_revtype"].Value;

                    searchstr.Text = Request.Cookies["grouplist_searchstr"].Value;
                    Grid.PageIndex = Util.parseInt(Request.Cookies["grouplist_pageindex"].Value);
                }
                catch (Exception ex)
                {
                    ex.Message.ToString();
                }
            }

            if (Request.QueryString["newbooking"] + "" == "Y")
                message.InnerHtml = "TO ENTER A NEW BOOKING: 1) Select the Group; 2) Click \"New Booking\"";
            else if (Request.QueryString["addwaitlist"] + "" == "Y")
                message.InnerHtml = "TO ADD TO WAITING LIST: 1) Select the Group; 2) Click \"Add to Waiting List\"";

            //if (departfr.SelectedDate.ToString() == "" && departto.SelectedDate.ToString() == "" && grouptype.SelectedValue == "0" && revtype.SelectedValue == "" && searchstr.Text == "")
            //{
            //    Grid.Visible = false;
            //}
        }
        else
        {
            // Save
            //Response.Cookies["grouplist_departfr"].Value = departfr.Text;
            Response.Cookies["grouplist_departfr"].Value = departfr.SelectedDate.ToString();
            //Response.Cookies["grouplist_departto"].Value = departto.Text;
            Response.Cookies["grouplist_departto"].Value = departto.SelectedDate.ToString();
            Response.Cookies["grouplist_grouptype"].Value = grouptype.SelectedValue;
            Response.Cookies["grouplist_revtype"].Value = revtype.SelectedValue;
            Response.Cookies["grouplist_searchstr"].Value = searchstr.Text;
            Session["PostBack"] = 1;

        }
        //if (departfr.Text == "" && departto.Text == "" && grouptype.SelectedValue == "0" && revtype.SelectedValue == "" && searchstr.Text == "")
        if (Session["PostBack"].ToString() == "0")
        {
            Grid.Visible = false;
        }
        else
        {
            Grid.Visible = true;
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Check current Security level
        if (Session["Security"] != null)
        {
            int s = Convert.ToInt32(Session["Security"].ToString());
            if (s == 4)
            {
                AddGroup.Visible = false;
            }
            else
            {
                AddGroup.Visible = true;
            }
        }
    }

    protected void Search_Click(object sender, System.EventArgs e)
    {
        //if (!Page.IsValid)
        //    return;
        Grid.PageIndex = 0;
        Grid.DataBind();
        Session["PostBack"] = 1;
        Grid.Visible = true;
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
        Response.Cookies["grouplist_pageindex"].Value = Grid.PageIndex.ToString();
    }


    protected string Action(object container)
    {
        string ret = "";
        DataRowView dr = (DataRowView)container;
        string groupId = dr["groupid"] + "";
        //if (Security.IsAdmin())
        //{
        //    ret += string.Format("<a class=\"slnk\" href=\"GroupDel.aspx?groupid={0}\">Delete</a>", groupId);
        //    ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"GroupDup.aspx?groupid={0}\">Duplicate</a>", groupId);
        //}
        //else
        //{
        //    ret += "<a class=\"slnk\" disabled='disabled' onclick=\"javascript:return false\" href=\"\">Delete</a>";
        //    ret += "&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" disabled='disabled' onclick=\"javascript:return false\" href=\"\">Duplicate</a>";
        //}
        ret += string.Format("<a class=\"slnk\" href=\"GroupDel.aspx?groupid={0}\">Delete</a>", groupId);
        ret += string.Format("&nbsp;&nbsp;|&nbsp;&nbsp;<a class=\"slnk\" href=\"GroupDup.aspx?groupid={0}\">Duplicate</a>", groupId);

        return ret;
    }

    protected void departfr_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Response.Cookies["grouplist_departfr"].Value = departfr.SelectedDate.ToString();
    }

    protected void departto_SelectedDateChanged(object sender, Telerik.Web.UI.Calendar.SelectedDateChangedEventArgs e)
    {
        Response.Cookies["grouplist_departto"].Value = departto.SelectedDate.ToString();
    }

    //protected void VgroupCode_ItemDataBound(object sender, DropDownListItemEventArgs e)
    //{
    //    var listitem = (RadDropDownList)sender;
    //    int counter = listitem.Items.Count();
    //    if (counter == 1)
    //    {
    //        listitem.Items.Insert(0, new DropDownListItem("Select group...", string.Empty));
    //    }
    //}

    protected void AddGroup_Click(object sender, EventArgs e)
    {
        Response.Redirect("GroupAdd.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" runat="server">
    <span id="message" class="message" runat="server" enableviewstate="false"></span><br />
    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="valsumry" HeaderText="Please correct the following:" DisplayMode="BulletList" ShowMessageBox="true" ShowSummary="false"></asp:ValidationSummary>
        
    <table cellpadding="0" cellspacing="0" width="100%">
    <tr valign="bottom">
        <td>
    <table cellpadding="0" cellspacing="0">
        <tr valign="bottom">
            <td class="small"><b>Depart From:</b>&nbsp;<br />
                <%--<asp:TextBox ID="departfr" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departfr.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <telerik:RadDatePicker RenderMode="Lightweight" ID="departfr" width="100px" runat="server" OnSelectedDateChanged="departfr_SelectedDateChanged" ShowRowHeaders="false">
                    <Calendar ShowRowHeaders="false"></Calendar>
                </telerik:RadDatePicker>
            </td>
            <td>&nbsp;&nbsp;</td>
            <td class="small"><b>To:</b>&nbsp;<br />
               <%-- <asp:TextBox ID="departto" Width="75px" runat="server" MaxLength="12" /><a onclick="setLastPos(event)" href="javascript:calendar('<%=departto.ClientID%>');" ><img src="images/calendar.gif" border="0" /></a>--%>
                <telerik:RadDatePicker RenderMode="Lightweight" ID="departto" width="100px" runat="server" OnSelectedDateChanged="departto_SelectedDateChanged">
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
                <telerik:RadDropDownList runat="server" ID="grouptype" Width="120px" DataSourceID="GroupTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true" Skin="Sunset">
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
                <telerik:RadDropDownList runat="server" ID="revtype" Width="100px" DataSourceID="RevTypeSource" DataValueField="code" DataTextField="desc" AppendDataBoundItems="true" Skin="Sunset">
                    <Items>
                        <telerik:DropDownListItem Value="" Text="All"/>
                    </Items>
                </telerik:RadDropDownList>
            </td>
            <td>&nbsp;&nbsp;</td>
            <%--<td class="small"><b>Group Code Type:</b><br />
                <telerik:RadDropDownList ID="VgroupCode" runat="server" Width="120px" RenderMode="Lightweight" AutoPostBack="false"
                        DefaultMessage="Select group..." DataValueField="VGroupCode" DataTextField="VGroupCode" Skin="Black" OnItemDataBound="VgroupCode_ItemDataBound" >
                </telerik:RadDropDownList>
             </td>
            <td>&nbsp;&nbsp;</td>--%>
            <td class="small"><b>Keyword:</b><br />
                <asp:TextBox ID="searchstr" Width="150px" runat="server" MaxLength="25" />
            </td>
            <td>&nbsp;&nbsp;</td>
            <td>
                <asp:Button CssClass="topbutton" ID="searchbtn" OnClick="Search_Click" runat="server" Text="Search" />
            </td>
            <td>&nbsp;&nbsp;</td>
            <%--<td>
                <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="departfr" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure start date is invalid" Type="Date">*</asp:CompareValidator>
                <asp:RequiredFieldValidator ID="ReqExpFrom" runat="server" ControlToValidate="departfr"  CssClass="error" Display="Dynamic" ErrorMessage="Departure start date is required">*</asp:RequiredFieldValidator>
                <asp:CompareValidator ID="CompareValidator2" runat="server" ControlToValidate="departto" CssClass="error" Display="Dynamic" Operator="DataTypeCheck" ErrorMessage="Departure end date is invalid" Type="Date">*</asp:CompareValidator>
            </td>--%>

        </tr>
    </table>
        </td>    
            <td align="right">
                &nbsp;&nbsp;
                <asp:Button runat="server" ID="AddGroup" Text="Add a Group" OnClick="AddGroup_Click" />
                <%--<input type="button" onclick="javascript:window.location.href='GroupAdd.aspx';return false;" value="Add a Group" id="AddGroup" runat="server" />--%>
             </td>
    </tr>
    </table>
    <hr />
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="25" GridLines="Both" AllowPaging="true" AllowSorting="true" DataSourceID="GroupSource" DataKeyNames="groupid" 
        AutoGenerateColumns="False" onrowcreated="Grid_RowCreated" ondatabound="Grid_DataBound" >
        <HeaderStyle CssClass="listhdr" />
        <AlternatingRowStyle BackColor="Wheat" />
        <RowStyle VerticalAlign="Top" />
        <Columns>
	        <asp:HyperLinkField DataTextField="GroupID" HeaderText="Group#" HeaderStyle-HorizontalAlign="Left" SortExpression="m.GroupID" DataNavigateUrlFormatString="GroupView.aspx?groupid={0}" DataNavigateUrlFields="groupid" />  
            <asp:BoundField DataField="groupname" HeaderText="Group Name" HeaderStyle-HorizontalAlign="Left" HeaderStyle-Width="250px" ItemStyle-Width="250px" SortExpression="groupname" />
            <asp:BoundField DataField="departdate" HtmlEncode="false" HeaderStyle-HorizontalAlign="Left" HeaderText="Depart" DataFormatString="{0:d}" SortExpression="departdate" />
            <asp:BoundField DataField="grouptypedesc" HeaderText="Group Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p.PickDesc" />
            <asp:BoundField DataField="revtypedesc" HeaderText="Travel Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="p2.PickDesc" />
            <asp:BoundField DataField="portcitydesc" HeaderText="Port City" HeaderStyle-HorizontalAlign="Left"  SortExpression="pc.PortCityName" />
            <asp:BoundField DataField="groupagentname" HeaderText="Group Coordinator" HeaderStyle-HorizontalAlign="Left"  SortExpression="ga.Agent" />
            <asp:BoundField DataField="affinityagentname" HeaderText="Affinity Agent" HeaderStyle-HorizontalAlign="Left"  SortExpression="aa.Agent" />
            <asp:BoundField DataField="ShipName" HeaderText="Ship Name" HeaderStyle-HorizontalAlign="Left"  SortExpression="ShipName" />
            <asp:BoundField DataField="ProvName" HeaderText="Provider" HeaderStyle-HorizontalAlign="Left"  SortExpression="vendorName" />
            <%--<asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" HeaderText="Status" HeaderStyle-HorizontalAlign="Left" SortExpression="Cancelled" >
                <ItemTemplate>  
                    <asp:Label ID="lblStatus" runat="server" 
                        Text='<%# Convert.ToBoolean(Eval("Cancelled")) == true ? "Cancelled" : "Active" %>'
                        ForeColor='<%# Convert.ToBoolean(Eval("Cancelled")) == true ? System.Drawing.Color.Red: Convert.ToBoolean(Eval("Cancelled")) == false ? System.Drawing.Color.Green: System.Drawing.Color.Purple%>'>
                    </asp:Label>  
                </ItemTemplate>
            </asp:TemplateField>--%>
            <asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" HeaderText="Status" HeaderStyle-HorizontalAlign="Left" SortExpression="NewStatus" >
                <ItemTemplate>  
                    <asp:Label ID="lblStatus" runat="server" 
                        Text='<%# Eval("NewStatus") %>'
                        ForeColor='<%# Convert.ToString(Eval("NewStatus")) == "Canceled" ? System.Drawing.Color.Red: 
                            Convert.ToString(Eval("NewStatus")) == "Active" ? System.Drawing.Color.Green: 
                            Convert.ToString(Eval("NewStatus")) == "Pending" ? System.Drawing.Color.Blue: 
                            Convert.ToString(Eval("NewStatus")) == "Expired" ? System.Drawing.Color.Maroon: 
                            Convert.ToString(Eval("NewStatus")) == "Inactive" ? System.Drawing.Color.DeepPink: 
                            Convert.ToString(Eval("NewStatus")) == "No Pending" ? System.Drawing.Color.Black: 
                            System.Drawing.Color.Purple%>'>
                    </asp:Label>  
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-Width="90px" ItemStyle-Width="90px" HeaderText="Action" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
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
    <asp:ObjectDataSource ID="GroupSource" runat="server" SelectMethod="GetPagedList" SelectCountMethod="GetPagedCount" TypeName="GM.GroupMaster" EnablePaging="True" SortParameterName="sortExpression">
        <SelectParameters>
            <%--<asp:ControlParameter Name="departfr" ControlID="departfr" PropertyName="Text" Type="String" />--%>
            <asp:ControlParameter Name="departfr" ControlID="departfr" PropertyName="SelectedDate" Type="DateTime" />
            <%--<asp:ControlParameter Name="departto" ControlID="departto" PropertyName="Text" Type="String" />--%>
            <asp:ControlParameter Name="departto" ControlID="departto" PropertyName="SelectedDate" Type="DateTime" />
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
