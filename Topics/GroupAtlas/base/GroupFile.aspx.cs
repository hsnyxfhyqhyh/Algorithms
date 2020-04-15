using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI.FileExplorer;
using Telerik.Web;
using System.IO;


public partial class GroupFile : System.Web.UI.Page
    {

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string groupid = Request.QueryString["groupid"];
            lblGroup.Text = groupid;
            string path = System.Configuration.ConfigurationManager.AppSettings["PhysPath"] + groupid + "/";
            //string path = "~/Groups/" + groupid + "/";
            CreateIfMissing(path);

            //string[] filePaths = Directory.GetFiles(Server.MapPath(path));
            string[] filePaths = Directory.GetFiles(path);

            List<ListItem> files = new List<ListItem>();
            foreach (string filePath in filePaths)
            {
                files.Add(new ListItem(Path.GetFileName(filePath), filePath));
            }
            Grid.DataSource = files;
            Grid.DataBind();
        }
    }

    private void CreateIfMissing(string path)
    {
        bool folderExists = Directory.Exists(path);
        if (!folderExists)
            Directory.CreateDirectory(path);
    }

    protected void UploadFile(object sender, EventArgs e)
    {
        string groupid = lblGroup.Text;
        string fileName = Path.GetFileName(FileUpload1.PostedFile.FileName);
        string FileUploadURL = System.Configuration.ConfigurationManager.AppSettings["FilesUploadURL"];
        //FileUpload1.PostedFile.SaveAs(Server.MapPath("~/Uploads/") + fileName);
        string path = System.Configuration.ConfigurationManager.AppSettings["PhysPath"] + groupid + "/";
        FileUpload1.PostedFile.SaveAs(path + fileName);
        //Response.Redirect(Request.Url.AbsoluteUri);
        Response.Redirect(FileUploadURL);
    }
    protected void DownloadFile(object sender, EventArgs e)
    {
        string filePath = (sender as Button).CommandArgument;
        Response.ContentType = ContentType;
        Response.AppendHeader("Content-Disposition", "attachment; filename=" + Path.GetFileName(filePath));
        Response.WriteFile(filePath);
        Response.End();
    }
protected void DeleteFile(object sender, EventArgs e)
    {
        string groupid = lblGroup.Text;
        string filePath = (sender as Button).CommandArgument;
        File.Delete(filePath);
        //Response.Redirect(Request.Url.AbsoluteUri);
        Response.Redirect("/GroupFile.aspx?groupid=" + groupid);

    }

    protected void cancel_Click(object sender, EventArgs e)
    {
        string groupid = lblGroup.Text;
        Response.Redirect("GroupView.aspx?groupid=" + groupid);
    }
}



