using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtRegion
    {

        public int regionCode = 0;
	    public string regionDescription;

		public static mtRegion GetRegion(int regionCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_Region WHERE regionCode=@regionCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@regioncode", SqlDbType.Int).Value = regionCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtRegion r = new mtRegion();
                r.regionCode = (int)rs["regioncode"];
                r.regionDescription = rs["regiondescription"] + "";
                return r;
            }
		}

        public static int Update(mtRegion r)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_Region (RegionDescription) VALUES (@RegionDescription); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_Region SET RegionDescription = @RegionDescription WHERE regioncode = @regioncode"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (r.regionCode > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@regioncode", SqlDbType.Int).Value = r.regionCode;
                    cmd.Parameters.Add("@regiondescription", SqlDbType.VarChar, 50).Value = r.regionDescription;
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    cmd.Parameters.Add("@regiondescription", SqlDbType.VarChar, 50).Value = r.regionDescription;
                    r.regionCode = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return r.regionCode;
        }

        public static void Delete(int regionCode)
        {
            string sSQL = @"DELETE FROM dbo.mt_Region WHERE regioncode = @regioncode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@regioncode", SqlDbType.Int).Value = regionCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT regioncode, regiondescription FROM dbo.mt_Region
                ORDER by RegionDescription";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int GetRegionCode(string regionDescription)
        {
            if (regionDescription == "")
                return 0;
            string sSQL = @"DECLARE @RegionCode int = 0;
                SELECT @RegionCode = max(RegionCode) FROM dbo.mt_Region WHERE RegionDescription = @RegionDescription;
                IF ISNULL(@RegionCode,0) = 0
                BEGIN
	                INSERT INTO dbo.mt_Region (RegionDescription) VALUES (@RegionDescription);
	                SELECT @@IDENTITY;
                END
                ELSE
	                SELECT @RegionCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RegionDescription", SqlDbType.VarChar).Value = regionDescription;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

    }
}