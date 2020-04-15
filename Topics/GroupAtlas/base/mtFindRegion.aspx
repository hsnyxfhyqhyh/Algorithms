<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    string idregiondescription
    {
        get { return ViewState["idregiondescription"].ToString(); }
        set { ViewState["idregiondescription"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            idregiondescription = (Request.QueryString["idregiondescription"] == null ? string.Empty : Request.QueryString["idregiondescription"]);
            list.DataSource = mtRegion.GetList();
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        DataRowView dr = (DataRowView)data;
        string desc = dr["regiondescription"] + "";
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal('{0}');\">{1}</a>", adjdesc, desc);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Select Region Description</title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript">
        function setVal(val) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idregiondescription%>']) f.elements['<%=idregiondescription%>'].value = val;
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
