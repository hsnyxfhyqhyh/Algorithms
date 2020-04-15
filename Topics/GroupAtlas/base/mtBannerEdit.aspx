<%@ Page Language="C#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">

    int id
    {
        get { return Convert.ToInt32(ViewState["id"]); }
        set { ViewState["id"] = value.ToString(); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            Page.Form.Attributes.Add("enctype", "multipart/form-data");
            message.InnerHtml = Request.QueryString["msg"];
            id = Util.parseInt(Request.QueryString["id"]);
            if (id > 0)
            {
                mtBanner b = mtBanner.GetBanner(id);
                if (b == null)
                    Response.Redirect("mtBannerList.aspx?msg=Flyer banner not found");
                hdr.InnerHtml = "Edit Flyer Banner";
                txttitle.Text = b.title;
                lblfilename.Text = b.fileName;
            }
            else
            {
                hdr.InnerHtml = "Add Flyer Banner";
            }
            templatelist.DataSource = mtBanner.GetTemplateEdit(id);
            templatelist.DataBind();
            cancel.Attributes["onclick"] = "javascript:window.location.href='mtBannerList.aspx';return false;";
        }
    }

    protected void save_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        List<mtBannerTemplate> list = new List<mtBannerTemplate>();
        int cnt = 0;
        foreach (RepeaterItem itm in templatelist.Items)
        {
            bool selected =  Convert.ToBoolean(((CheckBox)itm.FindControl("selected")).Checked);
            if (selected)
            {
                string sTemplate = ((HiddenField)itm.FindControl("template")).Value;
                string sTitle = ((HiddenField)itm.FindControl("template")).Value;
                string sBannerPosition = ((HiddenField)itm.FindControl("bannerposition")).Value;
                list.Add(new mtBannerTemplate(sTemplate, sTitle, sBannerPosition));
                cnt++;
            }
        }
        if (cnt == 0)
        {
            message.InnerHtml = "At least one(1) template must be selected";
            return;
        }
        //
        mtBanner b = new mtBanner();
        if (id > 0)
            b = mtBanner.GetBanner(id);
        if (filename.HasFile && filename.PostedFile.ContentLength > 0)
        {
            string imagePath = HttpContext.Current.Server.MapPath("~/bannerFiles/");
            string imageName = Path.GetFileName(filename.PostedFile.FileName);
            filename.PostedFile.SaveAs(imagePath + imageName);
            b.fileName = imageName;
        }
        b.title = txttitle.Text;
        b.templateList = list;
        mtBanner.Update(b);
        string msg = "\"" + txttitle.Text + "\" was updated.";
        Response.Redirect("mtBannerList.aspx?msg=" + msg);
    }
</script>  

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" Runat="Server">

	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">Flyer Banner</td>
			<td align="right">&nbsp;</td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0">
		<tr>
			<td>
				<span id="message" class="message" runat="server" EnableViewState="false"></span>
				<br/>
				<asp:validationsummary id="ValidationSummary1" runat="server" ForeColor="red" HeaderText="Please correct the following:"
					CssClass="valsumry"></asp:validationsummary>
			</td>
		</tr>
	</table>
    
   <table cellspacing="0" cellpadding="0" border="0">
        <tr>
            <td>
                <table cellpadding="2" cellspacing="0" border="0">
                <tr>
                    <td width="150" class="tdlabel">Title: </td>                
                    <td><asp:TextBox ID="txttitle" runat="server" Width="400px" MaxLength="100" ></asp:TextBox>
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator2" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="txttitle" ErrorMessage="Title is required">*</asp:requiredfieldvalidator>                    
                    </td>
                </tr>                
	            <tr  valign="top">
		            <td class="tdlabel">Banner Image:</td>
		            <td><asp:Label ID="lblfilename" runat="server" /><br />
		                <asp:FileUpload id="filename" runat="server" Width="400px" />
                        <asp:requiredfieldvalidator id="Requiredfieldvalidator3" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="filename" ErrorMessage="File is required">*</asp:requiredfieldvalidator>   
                        <%--<asp:requiredfieldvalidator id="Requiredfieldvalidator4" runat="server" Display="Dynamic" CssClass="error" ControlToValidate="lblfilename" ErrorMessage="File is required">*</asp:requiredfieldvalidator>--%> 
	                </td>
	            </tr>
                <tr valign="top">
                    <td class="tdlabel">Applicable Templates: </td>                
                    <td>
           		        <asp:Panel ID="Panel1" runat="server" Width="400px" ScrollBars="Vertical" Height="250px" BorderColor="#CCCCCC" BorderStyle="Ridge" BorderWidth="1px">
                            <asp:Repeater ID="templatelist" runat="server">
                                <HeaderTemplate>
                                    <table cellpadding="1" cellspacing="0" border="0" width="375">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <asp:HiddenField ID="template" runat="server" Value='<%# Eval("template") %>' />
                                        <asp:HiddenField ID="title" runat="server" Value='<%# Eval("title") %>' />
                                        <asp:HiddenField ID="bannerposition" runat="server" Value='<%# Eval("bannerposition") %>' />
					                    <td width="50" align="center"><asp:CheckBox  id="selected" runat="server" Checked='<%# Bind("selected") %>' />&nbsp;</td>
                                        <td><%# Eval("title")%>&nbsp;</td>                                    
                                        <td><%# Eval("bannerposition")%>&nbsp;</td>                                    
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                    </td>
                </tr>                
                </table>
            </td>
        </tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td align="center"><br />
                <asp:Button ID="save" runat="server" Text="   Save   " OnClick="save_Click"></asp:Button>&nbsp;&nbsp;
                <asp:Button ID="cancel" runat="server" Text="Cancel" CausesValidation="False"></asp:Button>
            </td>
        </tr>
    </table>
</asp:Content> 