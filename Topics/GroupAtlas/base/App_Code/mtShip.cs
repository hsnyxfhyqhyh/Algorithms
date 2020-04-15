using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtShip
    {

        public int shipCode = 0;
	    public string shipName;
	    public string vendorCode;

		public static mtShip GetShip(int shipCode)
		{
            string sSQL = "SELECT * FROM dbo.mt_Ship WHERE shipCode=@shipCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@shipcode", SqlDbType.Int).Value = shipCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtShip s = new mtShip();
                s.shipCode = (int)rs["shipcode"];
                s.shipName = rs["shipname"] + "";
                s.vendorCode = rs["vendorcode"] + "";
                return s;
            }
		}

        public static int Update(mtShip s)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_Ship (ShipName, VendorCode) VALUES (@ShipName, @VendorCode); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_Ship SET ShipName = @ShipName, vendorCode = @VendorCode WHERE shipcode = @shipcode"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (s.shipCode > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@shipcode", SqlDbType.Int).Value = s.shipCode;
                    FillCmd(cmd, s);
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    FillCmd(cmd, s);
                    s.shipCode = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return s.shipCode;
        }

        private static void FillCmd(SqlCommand cmd, mtShip s)
        {
            cmd.Parameters.Add("@shipname", SqlDbType.VarChar, 50).Value = s.shipName;
            cmd.Parameters.Add("@vendorcode", SqlDbType.VarChar, 10).Value = DBNull.Value;
            if (s.vendorCode != "")
                cmd.Parameters["@vendorcode"].Value = s.vendorCode;
        }

        public static void Delete(int shipCode)
        {
            string sSQL = @"DELETE FROM dbo.mt_Ship WHERE shipcode = @shipcode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@shipcode", SqlDbType.Int).Value = shipCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            //string sSQL = @"SELECT s.shipcode, s.shipname, s.vendorcode, v.vendorname
            //    FROM dbo.mt_Ship AS s LEFT JOIN dbo.mt_Vendor v on v.vendorcode = s.vendorcode
            //    ORDER by s.ShipName";
            string sSQL = @"SELECT s.ShipID as shipcode, s.shipname, s.Provider as vendorcode, v.vendorname
                        FROM dbo.grp_ShipID AS s LEFT JOIN dbo.mt_Vendor v on v.vendorcode = s.Provider
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

        public static DataTable GetListByVendor(string vendorcode)
        {
            //string sSQL = @"SELECT s.shipcode, s.shipname, s.vendorcode, v.vendorname
            //    FROM dbo.mt_Ship AS s LEFT JOIN dbo.mt_Vendor v on v.vendorcode = s.vendorcode
            //    ORDER by s.ShipName";
            string sSQL = @"SELECT s.ShipID as shipcode, s.shipname, s.Provider as vendorcode, v.vendorname
                        FROM dbo.grp_ShipID AS s LEFT JOIN dbo.mt_Vendor v on v.vendorcode = s.Provider
                        where v.vendorcode = @vendorcode and s.Status = 'Active' and s.DeleteStatus = 0
                        ORDER by s.ShipName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@vendorcode", SqlDbType.VarChar, 25).Value = vendorcode;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int GetShipCode(string shipName)
        {
            if (shipName == "")
                return 0;
            //string sSQL = @"DECLARE @ShipCode int = 0;
            //    SELECT @ShipCode = max(ShipCode) FROM dbo.mt_Ship WHERE ShipName = @ShipName;
            //    IF ISNULL(@ShipCode,0) = 0
            //    BEGIN
	           //     INSERT INTO dbo.mt_Ship (ShipName) VALUES (@ShipName);
	           //     SELECT @@IDENTITY;
            //    END
            //    ELSE
	           //     SELECT @ShipCode;";
            string sSQL = @"DECLARE @ShipCode int = 0;
                SELECT @ShipCode = max(shipid) FROM dbo.grp_ShipID WHERE ShipName = @ShipName;
                IF ISNULL(@ShipCode,0) = 0
                BEGIN
	                INSERT INTO dbo.grp_ShipID (ShipName) VALUES (@ShipName);
	                SELECT @@IDENTITY;
                END
                ELSE
	                SELECT @ShipCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ShipName", SqlDbType.VarChar).Value = shipName;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

    }
}