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
            mtGroup.Reopen(groupCode);
            msg = string.Format("Group {0} was re-opened to allow users to edit and re-submit for approval", groupCode);
        }
        catch (ApplicationException ex)
        {
            msg = ex.Message;
        }
        Response.Redirect("mtGroupList.aspx?msg=" + msg);
	}
    
</script>

</asp:Content> 