<%@ Page Language="C#" MasterPageFile="MasterPage.master" %>

<script language="C#" runat="server">

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("GroupList.aspx?msg=" + Request.QueryString["msg"]);
    }
    
</script>

 <asp:Content ID="Content1" ContentPlaceHolderID="mainContent" Runat="Server">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
 
    <p>&nbsp;</p>
    <h1>Group Manager</h1>
    <p>&nbsp;</p>
    <p>Choose options from menu above.</p>

</asp:Content> 
