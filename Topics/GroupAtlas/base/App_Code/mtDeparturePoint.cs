using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtDeparturePoint
    {

        public int departureCode = 0;
	    public string departurePoint;

		public static mtDeparturePoint GetDeparturePoint(int departureCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_DeparturePoint WHERE departurecode=@departurecode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@departurecode", SqlDbType.Int).Value = departureCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtDeparturePoint d = new mtDeparturePoint();
                d.departureCode = (int)rs["departurecode"];
                d.departurePoint = rs["departurepoint"] + "";
                return d;
            }
		}

        public static int Update(mtDeparturePoint d)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_DeparturePoint (DeparturePoint) VALUES (@DeparturePoint); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_DeparturePoint SET DeparturePoint = @DeparturePoint WHERE departurecode = @departurecode"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (d.departureCode > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@departurecode", SqlDbType.Int).Value = d.departureCode;
                    cmd.Parameters.Add("@departurepoint", SqlDbType.VarChar, 50).Value = d.departurePoint;
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    cmd.Parameters.Add("@departurepoint", SqlDbType.VarChar, 50).Value = d.departurePoint;
                    d.departureCode = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return d.departureCode;
        }

        public static void Delete(int departureCode)
        {
            string sSQL = @"DELETE FROM dbo.mt_DeparturePoint WHERE departurecode = @departurecode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@departurecode", SqlDbType.Int).Value = departureCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            //string sSQL = @"SELECT departurecode, departurepoint FROM dbo.mt_DeparturePoint
            //    ORDER by DeparturePoint";
            string sSQL = @"SELECT d.departurecode, d.departurepoint, count(gm.PortCity) as GroupCount, count(mi.DeparturePoint) as FlyerCount
	                        FROM dbo.mt_DeparturePoint d
	                        left outer join grp_Master gm on d.DepartureCode = gm.PortCity
	                        left outer join mt_info mi on d.DepartureCode = mi.DeparturePoint
	                        group by d.DeparturePoint, d.DepartureCode
                            ORDER by DeparturePoint";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int GetDepartureCode(string departurePoint)
        {
            if (departurePoint == "")
                return 0;
            string sSQL = @"DECLARE @DepartureCode int = 0;
                SELECT @DepartureCode = max(DepartureCode) FROM dbo.mt_DeparturePoint WHERE DeparturePoint = @DeparturePoint;
                IF ISNULL(@DepartureCode,0) = 0
                BEGIN
	                INSERT INTO dbo.mt_DeparturePoint (DeparturePoint) VALUES (@DeparturePoint);
	                SELECT @@IDENTITY;
                END
                ELSE
	                SELECT @DepartureCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@DeparturePoint", SqlDbType.VarChar).Value = departurePoint;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
}