using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI.WebControls;
using System.Data;
using Telerik.Web.UI;

namespace GM
{
    public class Lookup
    {

        public static void FillDropDown(DropDownList list, List<PickList> pickList, string val, string defmsg)
        {
            list.Items.Clear();
            if (defmsg != "") list.Items.Add(new ListItem(defmsg, ""));
            foreach (PickList pk in pickList)
                list.Items.Add(new ListItem(pk.desc, pk.code));
            if (list.Items.FindByValue(val.ToString()) != null)
                list.Items.FindByValue(val.ToString()).Selected = true;
        }

        public static void FillNumber(DropDownList list, int val, int start, int end, string defmsg)
        {
            list.Items.Clear();
            if (defmsg != "")
                list.Items.Add(new ListItem(defmsg, ""));
            for (int i = start; i <= end; i++)
                list.Items.Add(i.ToString());
            if (list.Items.FindByValue(val.ToString()) != null)
                list.Items.FindByValue(val.ToString()).Selected = true;
        }

        public static void FillRadioList(RadioButtonList list, List<PickList> pickList, string val)
        {
            list.Items.Clear();
            foreach (PickList pk in pickList)
                list.Items.Add(new ListItem(pk.desc, pk.code));
            foreach (ListItem itm in list.Items)
            {
                if ((val.Length >= 25) && (itm.Value.Length >= 25))
                {
                    if (itm.Value.Substring(0, 25).ToLower() == val.Substring(0, 25).ToLower())
                    {
                        itm.Selected = true;
                        return;
                    }
                }
                else
                {
                    if (itm.Value.ToLower() == val.ToLower())
                    {
                        itm.Selected = true;
                        return;
                    }
                }
            }
        }
   
    }
}