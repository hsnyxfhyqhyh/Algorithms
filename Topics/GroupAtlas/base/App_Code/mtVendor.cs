using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtVendor
    {

	    public string vendorCode = "";
	    public string vendorName = "";
        public string phoneArea = "";
        public string phonePrefix = "";
        public string phoneSuffix = "";
        public string ext = "";
        public int RID;
        public string phone
        {
            get
            {
                if (phoneArea.Length > 2)
                    return string.Format("({0}) {1}-{2} {3}", phoneArea, phonePrefix, phoneSuffix, ((ext.Length > 1) ? " Ext: "+ext : ""));
                else
                    return "";
            }
        }

		public static mtVendor GetVendor(string vendorCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_vendor WHERE vendorCode=@vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar).Value = vendorCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtVendor v = new mtVendor ();
                v.vendorCode = rs["vendorCode"].ToString();
                v.vendorName = rs["vendorName"].ToString();
                v.phoneArea = rs["phonearea"] + "";
                v.phonePrefix = rs["phoneprefix"] + "";
                v.phoneSuffix = rs["phonesuffix"] + "";
                v.ext = rs["ext"] + "";
                v.RID = Convert.ToInt32(rs["RID"]);
                return v;
            }
		}
        public static int GetVendorVendor(string vendorCode)
        {
            string sSQL = "SELECT * FROM dbo.mt_vendor WHERE vendorCode=@vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar).Value = vendorCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return 0;

                return 1;
            }
        }

        public static DataTable GetSecondaryVendorCode(string VgroupCode)
        {
            string sSQL = @"select vg.vendorCode, v.vendorName
                            from Vendor_Group vg
                            inner join mt_vendor v on vg.vendorCode = v.vendorCode
                            where vg.VgroupCode = @VgroupCode
				            ORDER BY vg.vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@VgroupCode", SqlDbType.VarChar, 25).Value = VgroupCode;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int GetVendorFlyers(string vendorCode)
        {
            string sSQL = "SELECT * FROM dbo.mt_info WHERE vendorGroupCode=@vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar).Value = vendorCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return 0;
               
                return 1;
            }
        }

        public static int GetVendorGroups(string vendorCode)
        {
            string sSQL = "SELECT * FROM dbo.grp_Master WHERE Provider=@vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar).Value = vendorCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return 0;
                
                return 1;
            }
        }

        //public static void Update(mtVendor v)
        //{
        //    string sSQL = @"IF EXISTS(SELECT * FROM dbo.mt_vendor WHERE vendorCode=@vendorCode and VGroupCode = @VGroupCode)
        //        UPDATE dbo.mt_vendor SET vendorName=@vendorName, phoneArea=@phoneArea, phoneprefix=@phonePrefix, 
        //            phoneSuffix=@phoneSuffix, ext=@ext, VGroupCode = @VGroupCode WHERE vendorCode = @vendorCode
        //        ELSE INSERT INTO dbo.mt_vendor (vendorCode, vendorName, phoneArea, phonePrefix, phoneSuffix, ext, VGroupCode)  
        //            VALUES (@vendorCode, @vendorName, @phoneArea, @phonePrefix, @phoneSuffix, @ext, @VGroupCode)";
        //    using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
        //    {
        //        cn.Open();
        //        SqlCommand cmd = new SqlCommand(sSQL, cn);
        //        cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar, 10).Value = v.vendorCode;
        //        cmd.Parameters.Add("@vendorName", SqlDbType.VarChar, 50).Value = v.vendorName;
        //        cmd.Parameters.Add("@phoneArea", SqlDbType.VarChar, 3).Value = v.phoneArea;
        //        cmd.Parameters.Add("@phonePrefix", SqlDbType.VarChar, 3).Value = v.phonePrefix;
        //        cmd.Parameters.Add("@phoneSuffix", SqlDbType.VarChar, 4).Value = v.phoneSuffix;
        //        cmd.Parameters.Add("@ext", SqlDbType.VarChar, 10).Value = v.ext;
        //        cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 20).Value = v.vGroupCode;
        //        cmd.ExecuteNonQuery();
        //    }
        //}
        public static void Update(mtVendor v)
        {
            string sSQL = @"UPDATE dbo.mt_vendor SET vendorName=@vendorName, phoneArea=@phoneArea, phoneprefix=@phonePrefix, 
                    phoneSuffix=@phoneSuffix, ext=@ext, vendorCode=@vendorCode 
                    WHERE RID = @RID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar, 10).Value = v.vendorCode;
                cmd.Parameters.Add("@vendorName", SqlDbType.VarChar, 50).Value = v.vendorName;
                cmd.Parameters.Add("@phoneArea", SqlDbType.VarChar, 3).Value = v.phoneArea;
                cmd.Parameters.Add("@phonePrefix", SqlDbType.VarChar, 3).Value = v.phonePrefix;
                cmd.Parameters.Add("@phoneSuffix", SqlDbType.VarChar, 4).Value = v.phoneSuffix;
                cmd.Parameters.Add("@ext", SqlDbType.VarChar, 10).Value = v.ext;
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = v.RID;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Insert(mtVendor v)
        {
            string sSQL = @"INSERT INTO dbo.mt_vendor (vendorCode, vendorName, phoneArea, phonePrefix, phoneSuffix, ext)  
                    VALUES (@vendorCode, @vendorName, @phoneArea, @phonePrefix, @phoneSuffix, @ext)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorCode", SqlDbType.VarChar, 10).Value = v.vendorCode;
                cmd.Parameters.Add("@vendorName", SqlDbType.VarChar, 50).Value = v.vendorName;
                cmd.Parameters.Add("@phoneArea", SqlDbType.VarChar, 3).Value = v.phoneArea;
                cmd.Parameters.Add("@phonePrefix", SqlDbType.VarChar, 3).Value = v.phonePrefix;
                cmd.Parameters.Add("@phoneSuffix", SqlDbType.VarChar, 4).Value = v.phoneSuffix;
                cmd.Parameters.Add("@ext", SqlDbType.VarChar, 10).Value = v.ext;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(int RID)
        {
            string sSQL = "DELETE FROM dbo.mt_vendor WHERE RID = @RID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GeVendor()
        {
            string sSQL = @"SELECT v.RID, v.vendorcode, v.vendorname  
                            FROM dbo.mt_vendor v
                            Group by vendorCode, vendorname, RID
                            ORDER BY vendorname";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT v.RID, v.vendorcode, v.vendorname, case when len(v.phonearea) > 2 then '('+v.phonearea+') '+v.phoneprefix+'-'+v.phonesuffix + 
                            case when len(v.ext) > 1 then ' Ext: ' + v.ext else '' end 
                            else '' end as phone, Count(m.Provider) as GroupsCounter, Count(mi.vendorGroupCode) as FlyersCounter   
                            FROM dbo.mt_vendor v
                            left join dbo.grp_Master m (NOLOCK) ON v.vendorCode = m.Provider
                            left join dbo.mt_info mi (NOLOCK) ON v.vendorCode = mi.vendorGroupCode
                            Group by vendorCode, vendorname, RID, phonearea, phoneprefix, phonesuffix, ext
                            ORDER BY vendorname";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }
        public static DataTable GetListVcode(string VGroupCode)
        {
            string sSQL = @"SELECT RID, vendorcode, vendorname,  case when len(phonearea) > 2 then '('+phonearea+') '+phoneprefix+'-'+phonesuffix + 
                case when len(ext) > 1 then ' Ext: ' + ext else '' end 
                else '' end as phone  
                FROM dbo.mt_vendor 
				Group by vendorCode, vendorname, RID, phonearea, phoneprefix, phonesuffix, ext
				ORDER BY vendorCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        //public static List<PickList> GetVGroupCode()
        //{
        //    List<PickList> list = new List<PickList>();
        //    string sSQL = @"SELECT VGroupCode, VGroupCode + ' - ' + VGroupDescription as VGroupDescription FROM dbo.grp_VGroupCode ORDER BY VGroupCode";
        //    using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
        //    {
        //        cn.Open();
        //        SqlCommand cmd = new SqlCommand(sSQL, cn);
        //        using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
        //        {
        //            while (rs.Read())
        //                list.Add(new PickList(rs["VGroupCode"].ToString(), rs["VGroupDescription"].ToString()));
        //        }
        //    }
        //    return list;
        //}

        public static DataTable GetVGroupCode()
        {
            string sSQL = @"SELECT VGroupCode, VGroupDescription FROM dbo.grp_VGroupCode ORDER BY VGroupCode;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetUsedVendors(string VGroupCode)
        {
            string sSQL = @"select v.RID, v.vendorCode, v.vendorName
                            from Vendor_Group vg
                            inner join mt_vendor v on v.vendorCode = vg.vendorCode
                            where vg.VgroupCode = @VgroupCode
                            order by v.VendorCode;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 20).Value = VGroupCode;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetNotUsedVendors(string VGroupCode)
        {
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();

                SqlCommand cmd = new SqlCommand("uspws_getGroupVendor", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 20).Value = VGroupCode;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static int AddVendorsGroups(string sVcode, string sGroup)
        {
            int iReturn = 0;
            string sSQL = @"Insert into Vendor_Group (vendorCode, VgroupCode) Values (@sVcode, @sGroup);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@sVcode", SqlDbType.VarChar, 10).Value = sVcode;
                cmd.Parameters.Add("@sGroup", SqlDbType.VarChar, 20).Value = sGroup;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static int DeleteVendorsGroups(string sVcode, string sGroup)
        {
            int iReturn = 0;
            string sSQL = @"delete from Vendor_Group
                            where vendorCode = @sVcode
                            and VgroupCode = @sGroup;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@sVcode", SqlDbType.VarChar, 10).Value = sVcode;
                cmd.Parameters.Add("@sGroup", SqlDbType.VarChar, 20).Value = sGroup;
                iReturn = cmd.ExecuteNonQuery();
            }
            return iReturn;
        }
    }
}