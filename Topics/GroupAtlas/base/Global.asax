<%@ Application Language="C#" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Security.Principal"  %>
<%@ Import Namespace="GM" %>

<script runat="server">

    protected void Application_AuthenticateRequest(object sender, EventArgs e)
    {
        Security.Initialize();
    }

    protected void WindowsAuthentication_OnAuthenticate(object sender, WindowsAuthenticationEventArgs e)
    {
        if (e.Identity != null && e.Identity.IsAuthenticated)
        {
            CustomPrincipal p = new CustomPrincipal((WindowsIdentity)e.Identity);
            SecurityDet u = Security.Get(Util.CurrentUser(p.Identity.Name));
            if (u != null)
            {
                if (u.secLevel == 1)
                {
                    p.AddRole("Admin");
                }
                else if(u.secLevel == 2)
                {
                    p.AddRole("Admin");
                }
                else if(u.secLevel == 3)
                {
                    p.AddRole("Admin");
                }
                else if(u.secLevel == 4)
                {
                    p.AddRole("Admin");
                }
                else
                {
                    p.AddRole("User");
                    string curPage = Util.CurrentPage().ToLower();
                    // Non-Setup Unauthorized pages
                    string unauthPages = "mtgroupapprove.aspx,mtgroupreject.aspx,mtgroupdel.aspx,groupdel.aspx,groupdup.aspx";
                    if (unauthPages.IndexOf(curPage) != -1)
                        Response.Redirect("mtGroupList.aspx?msg=Access denied...");
                }
                HttpContext.Current.User = p;
                HttpContext.Current.Items["currentuserid"] = u.ntLogon;
                HttpContext.Current.Items["currentusername"] = u.agentName;
            }
        }
    }

    // Unhandled error will send an email to the recipient specified below
    protected void Application_Error(Object sender, EventArgs e)
    {
        string subject = "Error - " + Request.Url.ToString();
        string message = Request.Url.ToString() + System.Environment.NewLine + Server.GetLastError().ToString();
        Email.Send("groupmanager@aaamidatlantic.com", Config.AdminEmail, subject, message);
    }
</script> 