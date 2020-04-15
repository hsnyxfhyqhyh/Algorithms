using System;
using System.Web;
using System.Text.RegularExpressions;
using System.Net;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Collections.Generic;


namespace GM
{

	public class Custom
	{

        public static void AddControl(PlaceHolder ph, string id, string val, string type, string list, int width)
        {
            List<string> pickList = GetPickList(list, type);
            val = (val == null ? string.Empty : val.Trim());
            switch (type)
            {

                case "TEXT":
                    TextBox t = new TextBox();
                    t.Attributes.Add("runat", "server");
                    t.ID = id;
                    t.Text = val;
                    t.Width = Unit.Pixel(width);
                    t.CssClass = "customText";
                    ph.Controls.Add(t);
                    break;

                case "TEXTAREA":
                    TextBox ta = new TextBox();
                    ta.Attributes.Add("runat", "server");
                    ta.ID = id;
                    ta.Text = val;
                    ta.Width = Unit.Pixel(width);
                    ta.CssClass = "customText";
                    ta.TextMode = TextBoxMode.MultiLine;
                    ta.Rows = 2;
                    ph.Controls.Add(ta);
                    break;

                case "CHECKBOX":
                    CheckBox ck = new CheckBox();
                    ck.Attributes.Add("runat", "server");
                    ck.ID = id;
                    ck.CssClass = "customText";
                    ck.Checked = ((val.ToLower() == "on" || val.ToLower() == "yes" || val.ToLower() == "true") ? true : false);
                    ph.Controls.Add(ck);
                    break;

                case "DROPDOWNLIST":
                    if (!pickList.Exists(delegate(string str) { return str == val; }))
                        pickList.Add(val);
                    DropDownList dl = new DropDownList();
                    dl.Attributes.Add("runat", "server");
                    dl.ID = id;
                    dl.Width = Unit.Pixel(width);
                    dl.CssClass = "customText";
                    dl.DataSource = pickList;
                    dl.DataBind();
                    if (dl.Items.FindByValue(val) != null)
                        dl.Items.FindByValue(val).Selected = true;
                    ph.Controls.Add(dl);
                    break;

                case "CHECKBOXLIST":
                    if (val != string.Empty)
                    {
                        string[] arrVal = val.Split(";".ToCharArray());
                        for (int i = 0; i < arrVal.Length; i++)
                        {
                            if (!pickList.Exists(delegate(string str) { return str == arrVal[i].Trim(); }))
                                pickList.Add(arrVal[i].Trim());
                        }
                    }
                    CheckBoxList cl = new CheckBoxList();
                    cl.Attributes.Add("runat", "server");
                    cl.ID = id;
                    cl.CssClass = "customText";
                    cl.DataSource = pickList;
                    cl.DataBind();
                    int maxLen = 0;
                    foreach (ListItem m in cl.Items)
                    {
                        if (m.Text.Length > maxLen)
                            maxLen = m.Text.Length;
                        if (val.IndexOf(m.Text) != -1)
                            m.Selected = true;
                    }
                    cl.RepeatColumns = (maxLen < 30 && pickList.Count > 8 ? 2 : 1);
                    ph.Controls.Add(cl);
                    break;

                case "RADIOBUTTONLIST":
                    if (val != string.Empty)
                    {
                        if (!pickList.Exists(delegate(string str) { return str == val; }))
                            pickList.Add(val);
                    }
                    RadioButtonList rb = new RadioButtonList();
                    rb.Attributes.Add("runat", "server");
                    rb.ID = id;
                    rb.RepeatColumns = (pickList.Count > 8 ? 2 : 1);
                    //rb.Width = Unit.Pixel(width);
                    rb.CssClass = "customText";
                    rb.DataSource = pickList;
                    rb.DataBind();
                    if (rb.Items.FindByValue(val) != null)
                        rb.Items.FindByValue(val).Selected = true;
                    ph.Controls.Add(rb);
                    break;

                default:
                    TextBox th = new TextBox();
                    th.Attributes.Add("runat", "server");
                    th.Visible = false;
                    th.ID = id;
                    th.Text = val;
                    ph.Controls.Add(th);
                    break;
            }
        }
	
        public static string CustomValue(Control c)
        {
            switch (c.GetType().ToString())
            {
                case "System.Web.UI.WebControls.TextBox":
                    return ((TextBox)c).Text;

                case "System.Web.UI.WebControls.CheckBox":
                    return ((CheckBox)c).Checked.ToString();

                case "System.Web.UI.WebControls.DropDownList":
                    return ((DropDownList)c).SelectedValue;

                case "System.Web.UI.WebControls.RadioButtonList":
                    return ((RadioButtonList)c).SelectedValue;

                case "System.Web.UI.WebControls.CheckBoxList":
                    string ret = string.Empty;
                    string sep = string.Empty;
                    CheckBoxList ck = (CheckBoxList)c;
                    foreach (ListItem m in ck.Items)
                    {
                        if (m.Selected)
                        {
                            ret += sep + m.Text;
                            sep = ";  ";
                        }
                    }
                    return ret;

                default:
                    return string.Empty;
            }
        }

        private static List<string> GetPickList (string list, string type)
        {
            string[] arrList = list.Split(";".ToCharArray());
            List<string> pkL = new List<string>();
            if (type == "DROPDOWNLIST")
                pkL.Add(string.Empty);
            for (int i = 0; i < arrList.Length; i++)
            {
                if (arrList[i].Length > 0)
                    pkL.Add(arrList[i].Trim());
            }
            return pkL;
        }

    }

}
