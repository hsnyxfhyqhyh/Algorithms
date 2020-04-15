using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtDestination
    {

        public int destinationCode = 0;
	    public string destinationDescription;

		public static mtDestination GetDestination(int destinationCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_Destination WHERE destinationCode=@destinationCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@destinationcode", SqlDbType.Int).Value = destinationCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtDestination d = new mtDestination();
                d.destinationCode = (int)rs["destinationcode"];
                d.destinationDescription = rs["destinationdescription"] + "";
                return d;
            }
		}

        public static int Update(mtDestination d)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_Destination (DestinationDescription) VALUES (@DestinationDescription); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_Destination SET DestinationDescription = @DestinationDescription WHERE destinationcode = @destinationcode"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (d.destinationCode > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@destinationcode", SqlDbType.Int).Value = d.destinationCode;
                    cmd.Parameters.Add("@destinationdescription", SqlDbType.VarChar, 50).Value = d.destinationDescription;
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    cmd.Parameters.Add("@destinationdescription", SqlDbType.VarChar, 50).Value = d.destinationDescription;
                    d.destinationCode = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return d.destinationCode;
        }

        public static void Delete(int destinationCode)
        {
            string sSQL = @"DELETE FROM dbo.mt_Destination WHERE destinationcode = @destinationcode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@destinationcode", SqlDbType.Int).Value = destinationCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT destinationcode, destinationdescription FROM dbo.mt_Destination
                ORDER by DestinationDescription";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int GetDestinationCode(string destinationDescription)
        {
            if (destinationDescription == "")
                return 0;
            string sSQL = @"DECLARE @DestinationCode int = 0;
                SELECT @DestinationCode = max(DestinationCode) FROM dbo.mt_Destination WHERE DestinationDescription = @DestinationDescription;
                IF ISNULL(@DestinationCode,0) = 0
                BEGIN
	                INSERT INTO dbo.mt_Destination (DestinationDescription) VALUES (@DestinationDescription);
	                SELECT @@IDENTITY;
                END
                ELSE
	                SELECT @DestinationCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@DestinationDescription", SqlDbType.VarChar).Value = destinationDescription;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

    }
}