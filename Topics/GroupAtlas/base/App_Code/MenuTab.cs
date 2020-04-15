using System;
using System.Text;
using System.Collections.Generic;

namespace GM
{
    public class MenuTab
    {
        public string Name = "";
        public bool Selected = false;
        public string Url = "";
        public int Width = 0;

        public MenuTab(string name, string url, bool selected)
        {
            this.Name = name;
            this.Url = url;
            this.Selected = selected;
        }
        
        public static string BuildTab(List<MenuTab> tabList)
        {
            return BuildTab(tabList, string.Empty);
        }

        public static string BuildTab(List<MenuTab> tabList, string linkUrl)
        {
            StringBuilder s = new StringBuilder();
            StringBuilder sL = new StringBuilder();
            // Start
            s.Append("<table cellSpacing=\"0\" cellPadding=\"0\" width=\"100%\" border=\"0\">");
            s.Append("<tr>");
            // Tabs
            bool fsw = true;
            foreach (MenuTab tab in tabList)
            {
                string cls = (tab.Selected ? "tabsel" : "tab");
                if (fsw)
                {
                    s.Append("<td width=\"3\">&nbsp;</td>");
                    sL.Append("<td class=\"tabline\" height=1></td>");
                }
                s.Append("<td nowrap align=\"center\"");
                if (tab.Width > 0) 
                    s.AppendFormat(" width=\"{0}\" ", tab.Width);
                s.AppendFormat(" class=\"{0}\" onClick=\"javascript:window.location.href='", (tab.Selected ? "tabsel" : "tab"));
                s.AppendFormat("{0}';return false;\">&nbsp;", tab.Url);
                s.Append(tab.Name);
                s.Append("&nbsp;</td>");
                s.Append("<td width=\"1\">&nbsp;</td>");
                // Build Line
                sL.AppendFormat("<td class=\"{0}\" height=\"1\"></td>", (tab.Selected ? "tabselline" : "tabline"));
                sL.Append("<td class=\"tabline\" height=\"1\"></td>");
                fsw = false;
            }
            s.AppendFormat("<td width=\"90%\" align=\"right\">&nbsp;{0}</td>", linkUrl);
            s.Append("</td>");
            sL.Append("<td class=\"tabline\" height=\"1\"></td>");
            s.Append("</tr>");
            s.Append("<tr>");
            s.Append(sL.ToString());
            s.Append("</tr>");
            s.Append("</table>");
            return s.ToString();
        }

    }
}