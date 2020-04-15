using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtPickList
    {

        public static List<PickList> GetVendor()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT VendorCode, VendorName FROM dbo.mt_Vendor ORDER BY VendorName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["VendorCode"].ToString(), rs["VendorName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetShip()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT ShipCode, ShipName FROM dbo.mt_Ship ORDER BY ShipName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["ShipCode"].ToString(), rs["ShipName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetDescription()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT id, title FROM dbo.mt_Description ORDER BY title";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["id"].ToString(), rs["title"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetBanner(string template, string bannerPosition)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT b.bannerID, a.title 
                FROM mt_banner_templates b 
                INNER JOIN mt_banners a ON b.bannerID = a.id 
                WHERE b.template = @template AND b.bannerPosition = @bannerPosition 
                ORDER BY a.title";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@template", SqlDbType.VarChar).Value = template;
                cmd.Parameters.Add("@bannerposition", SqlDbType.VarChar).Value = bannerPosition;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["bannerid"].ToString(), rs["title"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetPackageType()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT typecode, typedescription FROM dbo.mt_Type ORDER BY typedescription";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["typecode"].ToString(), rs["typedescription"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetTemplate()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT template, title FROM dbo.mt_Templates ORDER BY sort, template";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["template"].ToString(), rs["title"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetProductCode()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("ps", "PS"));
            list.Add(new PickList("pt", "PT"));
            return list;
        }

        public static List<PickList> GetYesNo()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("yes", "Yes"));
            list.Add(new PickList("no", "No"));
            return list;
        }

        public static List<PickList> GetDepUnit()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("1", "per Person"));
            list.Add(new PickList("2", "per Cabin"));
            return list;
        }

        public static List<PickList> GetCurrencyPerc()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("$"));
            list.Add(new PickList("%"));
            return list;
        }

        public static List<PickList> GetProcessing()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Credit Card to Vendor Preferred"));
            list.Add(new PickList("Cash/Check Payment Forward to Vendor"));
            list.Add(new PickList("Credit Card Run Through POS Forward POS Receipt # to Group Department"));
            list.Add(new PickList("Group Department Sends Payment to Vendor"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetRequiredPass()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Name as it appears on Passport"));
            list.Add(new PickList("Passport Number"));
            list.Add(new PickList("Passport Place of Issue"));
            list.Add(new PickList("Passport Expiration Date"));
            list.Add(new PickList("Date Of Birth"));
            list.Add(new PickList("Citizenship"));
            list.Add(new PickList("Emergency Contact"));
            return list;
        }

        public static List<PickList> GetDocReq()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Government-Issued Photo Identification"));
            list.Add(new PickList("Proof of Citizenship", "Proof of Citizenship (Original Birth Certificate with raised seal, Government Issued Photo)"));
            list.Add(new PickList("Passport"));
            list.Add(new PickList("Visa"));
            list.Add(new PickList("Innoculation"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetContactInstr(string vendorGroupNumber)
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Call vendor and Mention Group # " + vendorGroupNumber));
            list.Add(new PickList("Call Travel Product Development"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetIATAInstr()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Travel Product Development IATA # 08640376", "Travel Product Development IATA"));
            list.Add(new PickList("Your Branch IATA Number", "Branch IATA"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetPhoneInstr()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Travel Product Development 302-230-2957", "Travel Product Development"));
            list.Add(new PickList("Your Branch Phone Number", "Branch"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetAddlInstr()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Special Request To Vendor"));
            list.Add(new PickList("Medical Notes To Vendor"));
            list.Add(new PickList("Special Occasions To Vendor"));
            list.Add(new PickList("Confirm Dining With Vendor"));
            list.Add(new PickList("Other"));
            return list;
        }

        public static List<PickList> GetTransferOption()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("One-Way"));
            list.Add(new PickList("Roundtrip"));
            return list;
        }

        public static bool IsExists(List<PickList> list, string code)
        {
            foreach (PickList pk in list)
            {
                if (pk.code.ToLower() == code.ToLower())
                    return true;
            }
            return false;
        }

        public static string GetDesc(List<PickList> list, string code)
        {
            foreach (PickList pk in list)
            {
                if (pk.code.ToLower() == code.ToLower())
                    return pk.desc;
            }
            return "";
        }

        //public static List<PickList> GetInstructionType()
        //{
        //    List<PickList> list = new List<PickList>();
        //    string sSQL = @"SELECT distinct InstructionType FROM dbo.mt_Instructions ORDER BY InstructionType";
        //    using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
        //    {
        //        cn.Open();
        //        SqlCommand cmd = new SqlCommand(sSQL, cn);
        //        using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
        //        {
        //            while (rs.Read())
        //                list.Add(new PickList(rs["InstructionType"].ToString(), rs["InstructionType"].ToString()));
        //        }
        //    }
        //    return list;
        //}

        public static DataTable GetInstructionType()
        {
            string sSQL = @"SELECT distinct InstructionType FROM dbo.mt_Instructions ORDER BY InstructionType;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

    }
}