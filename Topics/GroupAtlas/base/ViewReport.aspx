<%@ Page Language="C#" MasterPageFile="Reports.master" %>
<%@ Import Namespace="GM" %>

<script runat="server">

    string printUrl = "";
    string title = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            title = Request.QueryString["title"] + "";
            //printUrl = Config.SSRSUrlTemplate;
            printUrl = Config.BIPortalUrlTemplate;
            printUrl = Config.BIPortalUrl;
            //printUrl = printUrl.Replace("[REPORTNAME]", Request.QueryString["reportname"]+"");
            cancel.Attributes["onclick"] = "javascript:window.location.href='reports.aspx';return false;";
        }
    }

</script>  

<asp:Content ID="Content1" ContentPlaceHolderID="reportContent" Runat="Server">
    
    <script language="javascript" type="text/javascript">
        window.open('<%=printUrl%>', 'report', 'top=0,left=0,width=1200,height=800,toolbars=0,resizable=1');
    </script>


	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top"><%=title%></td>
			<td align="right">
                <asp:Button ID="cancel" runat="server" Text="Cancel" CausesValidation="False"></asp:Button> &nbsp;
            </td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>

</asp:Content> 