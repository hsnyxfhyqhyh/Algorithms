<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string idvendorgroupcode
    {
        get { return ViewState["idvendorgroupcode"].ToString(); }
        set { ViewState["idvendorgroupcode"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            idvendorgroupcode = (Request.QueryString["idvendorgroupcode"] == null ? string.Empty : Request.QueryString["idvendorgroupcode"]);
            list.DataSource = mtVendorGroup.GetList();
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        DataRowView dr = (DataRowView)data;
        string code = dr["vendorgroupcode"] + "";
        string adjcode = HttpUtility.HtmlEncode(code).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal('{0}');\">{1}</a>", adjcode, code);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Select Vendor</title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript">
        function setVal(id) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idvendorgroupcode%>']) f.elements['<%=idvendorgroupcode%>'].value = id;
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
