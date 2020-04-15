using System;
using System.Web;
using System.Text.RegularExpressions;
using System.Net;
using System.IO;
using System.Globalization;
using System.Drawing;

namespace GM
{

	public class Util
	{

        public static string BasePath() 
        {
            string port = HttpContext.Current.Request.ServerVariables["SERVER_PORT"];
            string protocol = HttpContext.Current.Request.ServerVariables["SERVER_PORT_SECURE"];
            port = (port == null || port == "80" || port == "443" ? "" : ":" + port);
            protocol = (protocol == null || protocol == "0" ? "http://" : "https://");
            string path = protocol + HttpContext.Current.Request.ServerVariables["SERVER_NAME"] + port + HttpContext.Current.Request.ApplicationPath;
            if (!path.EndsWith("/"))
                path = path + "/";
            return path;
        }

		public static string CurrentPage()
		{
			string page = HttpContext.Current.Request.ServerVariables ["Script_Name"].ToString ().ToLower ();
			int slash = page.LastIndexOf("/");
			if (slash >= 0)
				page = page.Substring(slash+1);
			return page;
		}

        public static string CurrentUser()
        {
            string userName = (HttpContext.Current.User == null) ? "" : HttpContext.Current.User.Identity.Name.ToString();
            int idx = userName.IndexOf("\\");
            if (idx > -1)
                userName = userName.Substring(idx + 1);

            // comment line below before deploying
            userName = "yhu";
            return userName;
        }

        public static string CurrentUser(string userName)
        {
            int idx = userName.IndexOf("\\");
            if (idx > -1)
                userName = userName.Substring(idx + 1);
            return userName;
        }

        public static string CurrentUrl()
        {
            string url = HttpContext.Current.Request.Url.OriginalString;
            if (url.ToLower().IndexOf(".aspx?") == -1)
                url += "?1=1";
            return url;
        }

		public static int parseInt(object val)
		{
			if (val != null)
			{
				if (isInteger(val.ToString()))
					return Int32.Parse (val.ToString());
			}
            return 0;
		}

		public static decimal parseDec(object val)
		{
			if (val != null)
			{
				if (isNumber(val.ToString()))
					return Decimal.Parse(val.ToString ());
			}
            return 0;
		}

        public static float parseFloat(object val)
        {
            if (val != null)
            {
                if (isNumber(val.ToString()))
                    return float.Parse(val.ToString());
            }
            return 0;
        }

		public static bool isValidDate(string sdate)
		{
			try
			{
                return (Convert.ToDateTime(sdate) > Convert.ToDateTime("1/1/1900") ? true : false);
			}
			catch
			{
				return false;
			}
		}

		public static bool isValidTime(string tm)
		{
			try
			{
				DateTime dt = Convert.ToDateTime (tm);
				return true;
			}
			catch
			{
				return false;
			}
		}

		public static bool isInteger(string val)
		{
			string pattern = @"^-{0,1}\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}

		public static bool isPosInteger(string val)
		{
			string pattern = @"^\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}

		public static bool isNegInteger(string val)
		{
			string pattern = @"^-\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}

		public static bool isNumber(string val)
		{
			string pattern = @"^-{0,1}\d*\.{0,1}\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}

		public static bool isPosNumber(string val)
		{
			string pattern = @"^\d*\.{0,1}\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}
		
		public static bool isNegNumber(string val)
		{
			string pattern = @"^-\d*\.{0,1}\d+$";
			Regex expr = new Regex(pattern);
			return (expr.IsMatch(val) ? true : false);
		}

		public static string FmtDuration(int dur)
		{
			string durdesc = "";
			int hh = dur / 60;
			int mm = dur % 60;
			if (hh > 0) {durdesc += hh + " " + (hh > 1 ? "hrs" : "hr") + " ";}
			if (mm > 0) {durdesc += mm + " mins";}
			return durdesc;
		}

        // Replaces and Quote characters to HTML safe equivalents.
        public static string FixHTMLForDisplay(string Html)
        {
            Html = Html.Replace("<", "&lt;");
            Html = Html.Replace(">", "&gt;");
            Html = Html.Replace("\"", "&quot;");
            return Html;
        }

        // Strips HTML tags out of an HTML string and returns just the text.
        public static string StripHtml(string Html)
        {
            Html = Regex.Replace(Html, @"<(.|\n)*?>", string.Empty);
            Html = Html.Replace("\t", " ");
            Html = Html.Replace("\r\n", "");
            Html = Html.Replace("   ", " ");
            return Html.Replace("  ", " ");
        }

        // Fixes a plain text field for display as HTML by replacing carriage returns 
        public static string DisplayMemo(string HtmlText)
        {
            HtmlText = HtmlText.Replace("\r\n", "\r");
            HtmlText = HtmlText.Replace("\n", "\r");
            HtmlText = HtmlText.Replace("\r\r", "<p>");
            HtmlText = HtmlText.Replace("\r", "<br>");
            return HtmlText;
        }

        public static string URLPage(string url)
        {
            HttpWebRequest request;
            HttpWebResponse response;
            Stream stream;
            request = (HttpWebRequest)WebRequest.Create(url);
            response = (HttpWebResponse)request.GetResponse();
            stream = response.GetResponseStream();
            string strHTML = new StreamReader(stream).ReadToEnd();
            return strHTML;
        }

        public static string FormatCSVField(string val)
        {
            if (val.IndexOf(",") != -1 || val.IndexOf("\"") != -1 || val.IndexOf("\r") != -1 || val.IndexOf("\n") != -1) 
                return string.Format("\"{0}\"", val.Replace("\"","\"\""));
            else
                return val;
        }

        public static void AddIframeHeader()
        {
            HttpContext.Current.Response.AddHeader("p3p", "CP=\"IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT\""); 
        }

        // Format Javascript Alert Text
        public static string AlertText(string text)
        {
            text = text.Replace("\r\n", "\\n");
            text = text.Replace("\n", "\\n");
            text = text.Replace("\r", "\\n");
            text = text.Replace("\'", "\\'");
            text = text.Replace("\t", "\\t");
            return text;
        }

        public static string TitleCase(string text)
        {
            TextInfo ti = new CultureInfo("en-US", false).TextInfo;
            return ti.ToTitleCase(text.ToLower());
        }

        public static string ProperCase(string s)
        {
            if (s == null) return s;

            String[] words = s.Split(' ');
            for (int i = 0; i < words.Length; i++)
            {
                if (words[i].Length == 0) continue;

                Char firstChar = Char.ToUpper(words[i][0]);
                String rest = "";
                if (words[i].Length > 1)
                {
                    rest = words[i].Substring(1).ToLower();
                }
                words[i] = firstChar + rest;
            }
            return String.Join(" ", words);
        }

       // data:application/pdf;base64
        public static string GetBase64(string image)
        {
            try
            {
                string filePath = HttpContext.Current.Server.MapPath(image);
                string ext = Path.GetExtension(filePath).Replace(".", "");
                string sBase64 = Convert.ToBase64String(File.ReadAllBytes(filePath));
                return string.Format("data:image/{0};base64,{1}", ext, sBase64);
            }
            catch
            {
                return "";
            }
        }

        public static string GetBase64Doc(string doc)
        {
            try
            {
                string filePath = HttpContext.Current.Server.MapPath(doc);
                string ext = Path.GetExtension(filePath).Replace(".", "").ToLower();
                if (ext == "pdf" || ext == "doc" || ext == "docx")
                    return Convert.ToBase64String(File.ReadAllBytes(filePath));
                return "";
            }
            catch
            {
                return "";
            }
        }

    }
}
