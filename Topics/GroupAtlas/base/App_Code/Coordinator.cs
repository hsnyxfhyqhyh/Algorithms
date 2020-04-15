using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Coordinator
    {

        public static void Add(int flexID)
        {
            string sSQL = @"IF NOT EXISTS(select 1 FROM dbo.grp_Coordinator where FlexID=@FlexID)
                    INSERT INTO dbo.grp_Coordinator (FlexID) VALUES (@FlexID)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flexid", SqlDbType.Int).Value = flexID;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(int flexID)
        {
            string sSQL = @"DELETE FROM dbo.grp_Coordinator WHERE flexid = @flexid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flexid", SqlDbType.Int).Value = flexID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT c.flexid, e.firstname, e.lastname, e.email, e.[status], e.title, e.CiDescrip as Department
                FROM dbo.grp_Coordinator c
                INNER JOIN dbo.cmn_Employee e ON e.flxid = c.FlexID
                ORDER BY e.firstname, e.lastname";
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