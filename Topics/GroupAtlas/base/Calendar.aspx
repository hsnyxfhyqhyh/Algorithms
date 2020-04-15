<%@ Page Language="C#" %>
<%@ Import Namespace="GM" %>

<script runat="server">

    protected void Page_Load(object sender, System.EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            string selected = Request.QueryString["selected"];
            Cal.FirstDayOfWeek = (System.Web.UI.WebControls.FirstDayOfWeek)0;
            if (Util.isValidDate(selected))
                Cal.SelectedDate = Cal.VisibleDate = Convert.ToDateTime(selected);
            ViewState["idDate"] = Request.QueryString["idDate"];
        }
    }

    protected void Cal_SelectionChanged(object sender, System.EventArgs e)
    {
        string sDate = Cal.SelectedDate.ToShortDateString();
        string sScript = "<script language=\"JavaScript\">";
        sScript += string.Format("window.opener.document.forms[0].elements['{0}'].value = '{1}';", ViewState["idDate"], Cal.SelectedDate.ToShortDateString());
        sScript += "window.close();";
        sScript += Server.HtmlDecode("&lt;/script&gt;");
        Cal.VisibleDate = Cal.SelectedDate;
        Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "CalScript", sScript);
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Calendar</title>
    <style type="text/css"> 
			body {margin: 0px;}
			.h {font-weight: bold; font-size: x-small; color: #649cba; font-family: Verdana; text-align: center;}
			.w {border-right: white 2px solid; border-top: white 2px solid; font-size: xx-small; border-left: white 2px solid; width: 14%; color: white; border-bottom: white 2px solid; font-family: Verdana; background-color: #bbbbbb;}
			.d {border-right: white 2px solid; border-top: white 2px solid; font-size: xx-small; border-left: white 2px solid; width: 14%; color: #666666; border-bottom: white 2px solid; font-family: Verdana; background-color: #eaeaea;}		
			.o {border-right: white 2px solid; border-top: white 2px solid; font-size: xx-small; border-left: white 2px solid; width: 14%; color: #666666; border-bottom: white 2px solid; font-family: Verdana; background-color: white;}
		</style>
</head>
<body>
    <form runat="server" id="form1">
        <div style="text-align: center">
            <asp:Calendar EnableViewState="False" ID="Cal" runat="server" BorderWidth="0px" BorderStyle="Solid"
                Font-Names="Verdana" DayNameFormat="FirstLetter" ForeColor="#666666" Width="195px"
                PrevMonthText='<img src="images/calprev.gif" height=18 border=0>' NextMonthText='<img src="images/calnext.gif" height=18 border=0>'
                OnSelectionChanged="Cal_SelectionChanged">
                <TodayDayStyle Font-Bold="True" ForeColor="White" BackColor="#990000" />
                <SelectedDayStyle Font-Bold="True" ForeColor="#333333" BackColor="#FAAD50" />
                <TitleStyle Font-Size="X-Small" Font-Names="Verdana" Font-Bold="True" Height="18px"
                    ForeColor="White" BackColor="#336699" />
                <DayStyle CssClass="d"></DayStyle>
                <DayHeaderStyle CssClass="h"></DayHeaderStyle>
                <WeekendDayStyle CssClass="w"></WeekendDayStyle>
                <OtherMonthDayStyle CssClass="o"></OtherMonthDayStyle>
            </asp:Calendar>
        </div>
    </form>
</body>
</html>
