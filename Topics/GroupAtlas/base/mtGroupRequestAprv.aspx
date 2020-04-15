<%@ Page language="c#" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

	void Page_Load(object sender, System.EventArgs e)
	{
        string groupCode = Request.QueryString["groupcode"] + "";
        mtGroup g = mtGroup.GetGroup(groupCode);
        if (g == null)
            Response.Redirect("mtGroupList.aspx?msg=Group Flyer not found");
        string msg = "";
        try 
        {
            mtGroup.RequestApproval(groupCode);
            msg = string.Format("Notification was sent to {0} for review/approval of Group {1}", Config.RecipientEmail, groupCode);
        }
        catch (ApplicationException ex)
        {
            msg = ex.Message;
        }
        Response.Redirect("mtGroupList.aspx?msg=" + msg);
	}
    
</script>

</asp:Content> 