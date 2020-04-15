<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string idvendorname
    {
        get { return ViewState["idvendorname"].ToString(); }
        set { ViewState["idvendorname"] = value; }
    }
    string idvendorcode
    {
        get { return ViewState["idvendorcode"].ToString(); }
        set { ViewState["idvendorcode"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            idvendorcode = (Request.QueryString["idvendorcode"] == null ? string.Empty : Request.QueryString["idvendorcode"]);
            idvendorname = (Request.QueryString["idvendorname"] == null ? string.Empty : Request.QueryString["idvendorname"]);
            list.DataSource = mtVendor.GetList();
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        DataRowView dr = (DataRowView)data;
        string code = dr["vendorcode"] + "";
        string desc = dr["vendorname"] + "";
        string adjcode = HttpUtility.HtmlEncode(code).Replace("'", "\\\'");
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal('{0}','{1}');\">{2}</a>", adjcode, adjdesc, desc);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Select Vendor</title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript">
        function setVal(id, val) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idvendorcode%>']) f.elements['<%=idvendorcode%>'].value = id;
            if (f.elements['<%=idvendorname%>']) f.elements['<%=idvendorname%>'].value = val;
            window.close();
        }
    </script>
</head>
<body style="margin: 3px;">
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server" ID="RadScriptManager1" />
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
    </form>
</body>
</html>
