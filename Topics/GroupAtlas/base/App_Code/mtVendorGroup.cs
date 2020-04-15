using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtVendorGroup
    {

	    public string vendorGroupCode = "";

		public static mtVendorGroup GetVendorGroup(string vendorGroupCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_vendorgroupcode WHERE vendorGroupCode=@vendorGroupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar).Value = vendorGroupCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtVendorGroup c = new mtVendorGroup ();
                c.vendorGroupCode = rs["vendorGroupCode"].ToString();
                return c;
            }
		}

        public static void Update(mtVendorGroup c)
        {
            string sSQL = @"IF NOT EXISTS(SELECT * FROM dbo.mt_vendorgroupcode WHERE vendorGroupCode=@vendorGroupCode)
                INSERT INTO dbo.mt_vendorgroupcode (vendorGroupCode)  VALUES (@vendorGroupCode) ";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar, 25).Value = c.vendorGroupCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string vendorGroupCode)
        {
            string sSQL = "DELETE FROM dbo.mt_vendorgroupcode WHERE vendorGroupCode = @vendorGroupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar).Value = vendorGroupCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT * FROM dbo.mt_vendorgroupcode ORDER BY vendorGroupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void Check(string vendorGroupCode)
        {
            if (vendorGroupCode == "")
                return;
            string sSQL = @"IF NOT EXISTS(SELECT * FROM dbo.mt_vendorgroupcode WHERE vendorGroupCode=@vendorGroupCode)
                INSERT INTO dbo.mt_vendorgroupcode (vendorGroupCode)  VALUES (@vendorGroupCode) ";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar, 25).Value = vendorGroupCode;
                cmd.ExecuteNonQuery();
            }
        }

    }
}