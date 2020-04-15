using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Tour
    {

		public static int GetTourID(string tourName)
		{
            if (tourName == "")
                return 0;
            string sSQL = @"DECLARE @TourID int = 0;
                SELECT @TourID = max(TourID) FROM dbo.grp_TourID WHERE TourName = @TourName;
                IF ISNULL(@TourID,0) = 0
                BEGIN
	                INSERT INTO dbo.grp_TourID (TourName) VALUES (@TourName);
	                SELECT @@IDENTITY;
                END
                ELSE
	                SELECT @TourID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@tourname", SqlDbType.VarChar).Value = tourName;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
		}

        public static DataTable GetList()
        {
            string sSQL = @"SELECT tourid, tourname  ORDER by tourname";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetList(string provider, string tourName)
        {
            //string sSQL = @"SELECT	DISTINCT t.TourID, t.TourName 
	           // FROM dbo.grp_TourID t 
	           // INNER JOIN	dbo.grp_Master m (NOLOCK) ON t.TourID = m.TourID 
	           // WHERE (m.Provider=@provider OR t.tourname=@tourname)
            //    ORDER BY t.TourName";
            //string sSQL = @"SELECT	DISTINCT t.TourID, t.TourName 
	           // FROM dbo.grp_TourID t 
	           // LEFT OUTER JOIN	dbo.grp_Master m (NOLOCK) ON t.TourID = m.TourID 
	           // WHERE (m.Provider=@provider OR t.tourname=@tourname)
            //    ORDER BY t.TourName";
            string sSQL = @"SELECT	DISTINCT t.TourID, t.TourName 
	            FROM dbo.grp_TourID t 
	            LEFT OUTER JOIN	dbo.grp_Master m (NOLOCK) ON t.TourID = m.TourID 
                ORDER BY t.TourName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                da.SelectCommand.Parameters.Add("@tourname", SqlDbType.VarChar).Value = tourName;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

    }
}