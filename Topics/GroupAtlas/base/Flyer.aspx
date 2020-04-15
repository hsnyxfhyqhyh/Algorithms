<%@ Page language="c#"  %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">
    mtGroup g;

    /*
        Generates HTML code snippet for flyer
     * */
    
	void Page_Load(object sender, System.EventArgs e)
	{
        string groupCode = Request.QueryString["groupcode"] + "";
        string overrideDisplay = Request.QueryString["overrideDisplay"] + "";
        g = mtGroup.GetGroup(groupCode);
        if (g == null)
        {
            Response.Write("<p style=\"color: red\">The group departure you have selected could not be found</p>");
            Response.End();
        }
        if (overrideDisplay.ToLower() != "y" && overrideDisplay.ToLower() != "yes")
        {
            if (g.DoNotDisplay || g.Status != "Approved")
            {
                Response.Write("<p style=\"color: red\">The group departure you have selected is not available at this time</p>");
                Response.End();
            }
        }
        // Load flyer based on template        
        string page = "";
        if (g.Template == "6") page = "template_6.ascx";
        else if (g.Template == "7") page = "template_7.ascx";
        else if (g.Template.StartsWith("cruise")) page = "template_cruise.ascx";
        else  page = "template_6.ascx"; // default
        if (page == "")
        {
            Response.Write("<p style=\"color: red\">Unable to generate flyer for group departure. The group template is invalid.</p>");
            Response.End();
        }
        content.Controls.Add(Page.LoadControl("Templates\\"+page));
	}
</script>

<style type="text/css">
    * {margin: 0px; padding: 0px; font-family: Arial, Verdana, Helvetica, Sans-serif;}
    body {color: #000000; font-size: 12px; background-color: #FFFFFF; }
    h2 {font: bold 16px/normal Helvetica, Arial, Verdana, Sans-serif; padding-bottom: 0.4em; clear: both; margin-bottom: 0.8em; border-bottom-color: #AECFEE; border-bottom-width: 2px; border-bottom-style: solid;}
    p {line-height: 1.3em; font-size: 12px; margin-bottom: 1em;}
    ul {list-style: none; font-size: 12px;}
    td {color: #000000; font-size: 12px;}
    .flyer {width: 550px; padding: 15 15 15 15;}
</style>


<div class="flyer">

    <asp:PlaceHolder id="content" runat="server" />
    
    <!-- CALL TO ACTION -->
    <table width="100%" cellpadding="0" cellspacing="0" border="0">
	    <tr>
		    <td align="center" width="100%">
			    <br><br><em><% =g.CallToAction %></em>
		    </td>
	    </tr>
    </table>

    <!-- Footer -->
    <p align="right">
        #<% =g.GroupCode + " - " + g.CreateDate %>
    </p>

</div>
