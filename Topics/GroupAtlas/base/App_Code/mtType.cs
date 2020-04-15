using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtGroupType
    {

	    public string typeCode = "";
	    public string typeDescription = "";
        public int daysFromDeparture = 0;

		public static mtGroupType GetGroupType(string typeCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_type WHERE typeCode=@typeCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@typeCode", SqlDbType.VarChar).Value = typeCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtGroupType c = new mtGroupType ();
                c.typeCode = rs["typeCode"].ToString();
                c.typeDescription = rs["typeDescription"].ToString();
                c.daysFromDeparture = Util.parseInt(rs["daysfromdeparture"]);
                return c;
            }
		}

        public static void Update(mtGroupType c)
        {
            string sSQL = @"IF EXISTS(SELECT * FROM dbo.mt_type WHERE typeCode=@typeCode)
                UPDATE dbo.mt_type SET typeDescription = @typeDescription WHERE typeCode = @typeCode
                ELSE INSERT INTO dbo.mt_type (typeCode, typeDescription)  VALUES (@typeCode, @typeDescription)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@typeCode", SqlDbType.VarChar, 2).Value = c.typeCode;
                cmd.Parameters.Add("@typeDescription", SqlDbType.VarChar, 25).Value = c.typeDescription;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string typeCode)
        {
            string sSQL = "DELETE FROM dbo.mt_type WHERE typeCode = @typeCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@typeCode", SqlDbType.VarChar, 3).Value = typeCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT * FROM dbo.mt_type ORDER BY typeCode";
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