<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string iddescriptiontitle
    {
        get { return ViewState["iddescriptiontitle"].ToString(); }
        set { ViewState["iddescriptiontitle"] = value; }
    }
    string iddescription
    {
        get { return ViewState["iddescription"].ToString(); }
        set { ViewState["iddescription"] = value; }
    }


    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            iddescription = (Request.QueryString["iddescription"] == null ? string.Empty : Request.QueryString["iddescription"]);
            iddescriptiontitle = (Request.QueryString["iddescriptiontitle"] == null ? string.Empty : Request.QueryString["iddescriptiontitle"]);
            //rcbxStatus.Checked = d.status;
            //list.DataSource = mtDescription.GetList();
            list.DataSource = mtDescription.GetListActive();
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        DataRowView dr = (DataRowView)data;
        string id = dr["id"] + "";
        string desc = dr["title"] + "";
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        Boolean status = Convert.ToBoolean(dr["status"]);

        return string.Format("<a href=\"javascript:setVal({0},'{1}');\">{2}</a>", id, adjdesc, desc, status);
    }

    protected void Add_Click(object sender, EventArgs e)
    {
        views.ActiveViewIndex = 1;
    }

    void Save_Click(object sender, System.EventArgs e)
    {
        if (!Page.IsValid) return;
        try
        {
            mtDescription d = new mtDescription();
            d.title = txttitle.Text;
            d.description = description.Text;
            if (rcbxStatus.Checked == true)
            {
                d.status = true;
            }
            else
            {
                d.status = false;
            }
            int id = mtDescription.Update(d);
            string adjdesc = HttpUtility.HtmlEncode(d.title).Replace("'", "\\\'");
            string sScript = "<script language=\"JavaScript\">";
            sScript += string.Format("setVal({0},'{1}');", id, adjdesc);
            sScript += Server.HtmlDecode("&lt;/script&gt;");
            Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "SetValCloseWin", sScript);
        }
        catch (ApplicationException ex)
        {
            message.InnerHtml = ex.Message;
        }
    }

    protected void cancel_Click(object sender, EventArgs e)
    {
        views.ActiveViewIndex = 0;
        list.DataSource = mtDescription.GetList();
        list.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Select Description</title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript">
        function setVal(id, val) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=iddescription%>']) f.elements['<%=iddescription%>'].value = id;
            if (f.elements['<%=iddescriptiontitle%>']) f.elements['<%=iddescriptiontitle%>'].value = val;
            window.close();
        }
    </script>
</head>
<body style="margin: 3px;">
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
        <telerik:RadSkinManager ID="RadSkinManager1" runat="server" ShowChooser="false" />
    <asp:MultiView ID="views" runat="server" ActiveViewIndex="0">
        <asp:View ID="viewList" runat="server">
            <table cellspacing="0" cellpadding="0" width="100%">
                <tr>
                    <td class="hdr" valign="bottom">Select Description</td>
                    <td align="right"><asp:button id="add" runat="server" Text="New Description" OnClick="Add_Click" CssClass="button"></asp:button></td>
                </tr>
		        <tr>
			        <td width="100%" colspan="2" class="line" height="1"></td>
		        </tr>
            </table>
            <asp:Repeater ID="list" runat="server" EnableViewState="False">
                <HeaderTemplate>
                    <table width="100%" cellpadding="4" cellspacing="0" border="0">
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Url(Container.DataItem) %></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                </table> 
                </FooterTemplate>
            </asp:Repeater>
        </asp:View>    
        <asp:View ID="viewAdd" runat="server">
	        <table cellpadding="0" cellspacing="0" width="100%">
		        <tr>
			        <td class="hdr" id="hdr" runat="server" valign="top">Add Description</td>
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
				        <br/>
				        <asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:" />
			        </td>
		        </tr>
	        </table>
	        <table cellspacing="1" cellpadding="3" border="0">
		        <tr>
			        <td class="tdlabel" width="100">Title:</td>
			        <td><asp:textbox id="txttitle" runat="server" Width="400"  MaxLength="100"></asp:textbox>
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="txttitle" ErrorMessage="Title is required">*</asp:requiredfieldvalidator>
                    </td>
		        </tr>
		        <tr valign="top">
			        <td class="tdlabel">Description:</td>
			        <td><asp:textbox id="description" runat="server" Width="400"  MaxLength="1000" TextMode="MultiLine" Rows="10"></asp:textbox>
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator1" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="description" ErrorMessage="Description is required">*</asp:requiredfieldvalidator>
                    </td>
		        </tr>
                <tr valign="top">
			        <td class="tdlabel">Save for future use:</td>
			        <td><asp:CheckBox id="rcbxStatus" runat="server"  Visible="true" ForeColor="black"></asp:CheckBox>
                       <asp:Label runat="server" ID="lblDescription" Text="Active = checked / Inactive = unchecked" ForeColor="Blue" Font-Italic="true"></asp:Label>
            </td>
		</tr>
                <tr><td>&nbsp;</td></tr>
		        <tr>
			        <td colspan="2" align="center">
				        <asp:button id="save" runat="server" Text="  Save  " OnClick="Save_Click" CssClass="button"></asp:button>&nbsp;
				        <asp:button id="cancel" runat="server" Text="Cancel" CssClass="button" 
                            CausesValidation="False" onclick="cancel_Click"></asp:button>
			        </td>
		        </tr>
	        </table>
        </asp:View>
    </asp:MultiView>

    </form>
</body>
</html>
