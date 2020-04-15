<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>

<script runat="server">

    string idtourname
    {
        get { return ViewState["idtourname"].ToString(); }
        set { ViewState["idtourname"] = value; }
    }

    string provider
    {
        get { return ViewState["provider"].ToString(); }
        set { ViewState["provider"] = value; }
    }

    string tourName
    {
        get { return ViewState["tourname"].ToString(); }
        set { ViewState["tourname"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            idtourname = (Request.QueryString["idtourname"] == null ? string.Empty : Request.QueryString["idtourname"]);
            provider = Request.QueryString["provider"] + "";
            tourName = Request.QueryString["tourname"] + "";
            list.DataSource = Tour.GetList(provider, tourName);
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        string desc = (string)DataBinder.Eval(data, "tourname");
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal('{0}');\">{1}</a>", adjdesc, desc);
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Lookup Trip Theme</title>
    <link href="include/styles.css" rel="Stylesheet" type="text/css" />
    <script language="JavaScript" type="text/javascript">
        function setVal(val) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idtourname%>']) f.elements['<%=idtourname%>'].value = val;
            window.close();
        }
    </script>
</head>
<body style="margin: 3px;">
    <form id="form1" runat="server">
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
