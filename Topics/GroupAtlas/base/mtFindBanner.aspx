<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string idbannertitle
    {
        get { return ViewState["idbannertitle"].ToString(); }
        set { ViewState["idbannertitle"] = value; }
    }
    string idbannerid
    {
        get { return ViewState["idbannerid"].ToString(); }
        set { ViewState["idbannerid"] = value; }
    }
    string template
    {
        get { return ViewState["template"].ToString(); }
        set { ViewState["template"] = value; }
    }
    string bannerPosition
    {
        get { return ViewState["bannerposition"].ToString(); }
        set { ViewState["bannerposition"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            template = Request.QueryString["template"] + "";
            bannerPosition = Request.QueryString["bannerposition"] + "";
            idbannerid = (Request.QueryString["idbannerid"] == null ? string.Empty : Request.QueryString["idbannerid"]);
            idbannertitle = (Request.QueryString["idbannertitle"] == null ? string.Empty : Request.QueryString["idbannertitle"]);
            list.DataSource = mtPickList.GetBanner(template, bannerPosition);
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        PickList pk = (PickList)data;
        string id = pk.code;
        string desc = pk.desc;
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal({0},'{1}');\">{2}</a>", id, adjdesc, desc);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Select <%=bannerPosition%> Banner</title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript" type="text/javascript">
        function setVal(id, desc) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idbannerid%>']) f.elements['<%=idbannerid%>'].value = id;
            if (f.elements['<%=idbannertitle%>']) f.elements['<%=idbannertitle%>'].value = desc;
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
