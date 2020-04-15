<%@ Page  Language="C#" %>
<%@ Import Namespace="GM" %>

<script runat="server">
    string idaffinitygroupname
    {
        get { return ViewState["idaffinitygroupname"].ToString(); }
        set { ViewState["idaffinitygroupname"] = value; }
    }
    int groupType
    {
        get { return Convert.ToInt32(ViewState["grouptype"]); }
        set { ViewState["grouptype"] = value; }
    }

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
        {
            idaffinitygroupname = (Request.QueryString["idaffinitygroupname"] == null ? string.Empty : Request.QueryString["idaffinitygroupname"]);
            groupType = Util.parseInt(Request.QueryString["grouptype"]);
            list.DataSource = (groupType == 4) ? PickList.GetAffinityGroupName() : PickList.GetDescription();
            list.DataBind();
        }
    }

    protected string Url(object data)
    {
        string desc = ((PickList)data).desc;
        string adjdesc = HttpUtility.HtmlEncode(desc).Replace("'", "\\\'");
        return string.Format("<a href=\"javascript:setVal('{0}');\">{1}</a>", adjdesc, desc);
    }

    protected string title()
    {
        return (groupType == 4) ? "Select Affinity Group Name" : "Select Description";
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title><%=title()%></title>
    <link href="include/styles.css" rel="Stylesheet" />
    <script language="JavaScript" />
        function setVal(val) {
            var f = window.opener.document.forms[0];
            if (f.elements['<%=idaffinitygroupname%>']) f.elements['<%=idaffinitygroupname%>'].value = val;
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
