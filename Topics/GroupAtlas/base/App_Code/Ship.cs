using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Ship
    {

        public int shipID = 0;
	    public string shipName;
	    public string provider;
        public string status;

		public static Ship GetShip(int shipID)
		{
            string sSQL = "SELECT * FROM dbo.grp_ShipID WHERE shipID=@shipID and DeleteStatus = 0";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@shipid", SqlDbType.Int).Value = shipID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                Ship s = new Ship();
                s.shipID = (int)rs["shipid"];
                s.shipName = rs["shipname"] + "";
                s.provider = rs["provider"] + "";
                s.status = rs["status"] + "";
                return s;
            }
		}

        public static int Update(Ship s)
        {
            string SQL_INSERT = @"INSERT INTO dbo.grp_ShipID (ShipName, Provider, Status, DeleteStatus) VALUES (@ShipName, @Provider, @Status, 0); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.grp_ShipID SET ShipName = @ShipName, Provider = @Provider, Status = @Status, DeleteStatus = 0 WHERE shipid = @shipid"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (s.shipID > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@shipid", SqlDbType.Int).Value = s.shipID;
                    FillCmd(cmd, s);
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    FillCmd(cmd, s);
                    s.shipID = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return s.shipID;
        }

        private static void FillCmd(SqlCommand cmd, Ship s)
        {
            cmd.Parameters.Add("@shipname", SqlDbType.VarChar, 100).Value = s.shipName;
            cmd.Parameters.Add("@provider", SqlDbType.VarChar, 50).Value = s.provider;
            cmd.Parameters.Add("@status", SqlDbType.VarChar, 10).Value = s.status;
        }

        //public static void Delete(int shipID)
        //{
        //    string sSQL = @"DELETE FROM dbo.grp_ShipID WHERE shipid = @shipid";
        //    using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
        //    {
        //        cn.Open();
        //        SqlCommand cmd = new SqlCommand(sSQL, cn);
        //        cmd.Parameters.Add("@shipid", SqlDbType.Int).Value = shipID;
        //        cmd.ExecuteNonQuery();
        //    }
        //}

        public static void Delete(int shipID)
        {
            string sSQL = @"Update dbo.grp_ShipID set DeleteStatus = 1 WHERE shipid = @shipid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@shipid", SqlDbType.Int).Value = shipID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT s.shipid, s.shipname, s.provider, p.vendorName, s.status, Count(m.Provider) as GroupsCounter, Count(mi.vendorGroupCode) as FlyersCounter
                                FROM dbo.grp_ShipID AS s 
                                LEFT JOIN dbo.mt_vendor p on p.vendorCode = s.provider
	                            left join dbo.grp_Master m (NOLOCK) ON s.ShipID = m.ShipID
                                left join dbo.mt_info mi (NOLOCK) ON s.ShipID = mi.ShipCode
                                Where s.DeleteStatus = 0
	                            Group by s.ShipID, s.shipname, s.provider, p.vendorName, s.status
                                ORDER by s.ShipName";
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