using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class GroupPackage
    {

        public int packageID = 0;
	    public string groupID = "";
	    public string packageCd = "";
	    public string packageName = "";
	    public decimal singleRate = 0;
	    public decimal doubleRate = 0;
	    public decimal tripleRate = 0;
	    public decimal quadRate = 0;
	    public decimal singleComm = 0;
	    public decimal doubleComm = 0;
        public decimal tripleComm = 0;
        public decimal quadComm = 0;
        public decimal portCharges = 0;
        public string packageType = "";
        public string packageTypeName = "";
        public int quantity = 0;
        public int allocated = 0;
        public int sold = 0;
        public int soldPax = 0;
        public int available
        {
            get { return allocated - sold; }
        }

        public static GroupPackage GetPackage(int packageID, string groupID)
        {
            string sSQL = "SELECT * FROM dbo.vw_grp_Package WHERE packageid=@packageid AND groupid=@groupid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@packageid", SqlDbType.Int).Value = packageID;
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                GroupPackage p = FillPackage(rs);
                return p;
            }
        }

        public static List<GroupPackage> GetPackage(string groupID, string packageType)
        {
            string sSQL = "SELECT * FROM dbo.vw_grp_Package WHERE groupid=@groupid AND packageType=@packageType";
            List<GroupPackage> list = new List<GroupPackage>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                cmd.Parameters.Add("@packagetype", SqlDbType.VarChar).Value = packageType;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    GroupPackage p = FillPackage(rs);
                    list.Add(p);
                }
            }
            return list;
        }

        private static GroupPackage FillPackage(SqlDataReader rs)
        {
            GroupPackage p = new GroupPackage();
            p.packageID = (int)rs["packageid"];
            p.groupID = rs["groupid"] + "";
            p.packageCd = rs["packagecd"] + "";
            p.packageName = rs["packagename"] + "";
            p.singleRate = Util.parseDec(rs["singlerate"]);
            p.doubleRate = Util.parseDec(rs["doublerate"]);
            p.tripleRate = Util.parseDec(rs["triplerate"]);
            p.quadRate = Util.parseDec(rs["quadrate"]);
            p.singleComm = Util.parseDec(rs["singlecomm"]);
            p.doubleComm = Util.parseDec(rs["doublecomm"]);
            p.tripleComm = Util.parseDec(rs["triplecomm"]);
            p.quadComm = Util.parseDec(rs["quadcomm"]);
            p.quantity = Util.parseInt(rs["quantity"]);
            p.allocated = Util.parseInt(rs["allocated"]);
            p.portCharges = Util.parseDec(rs["portcharges"]);
            p.sold = Util.parseInt(rs["sold"]);
            p.soldPax = Util.parseInt(rs["soldpax"]);
            p.packageType = rs["packagetype"] + "";
            p.packageTypeName = rs["packagetypename"] + "";
            return p;
        }

        public static int Add(GroupPackage p)
        {
            string sSQL = @"INSERT INTO dbo.grp_Package (GroupID, PackageCd, PackageName, SingleRate, DoubleRate, TripleRate, 
                    QuadRate, SingleComm , DoubleComm, TripleComm, QuadComm, Quantity, Allocated, PortCharges, PackageType)
                VALUES (@GroupID, @PackageCd, @PackageName, @SingleRate, @DoubleRate, @TripleRate, 
                    @QuadRate, @SingleComm , @DoubleComm,@TripleComm, @QuadComm, @Quantity, @Allocated, @PortCharges, @PackageType);
                SELECT @@IDENTITY;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = p.groupID;
                cmd.Parameters.Add("@PackageCd", SqlDbType.VarChar, 3).Value = p.packageCd;
                cmd.Parameters.Add("@PackageName", SqlDbType.VarChar, 100).Value = p.packageName;
                cmd.Parameters.Add("@SingleRate", SqlDbType.Decimal).Value = p.singleRate;
                cmd.Parameters.Add("@DoubleRate", SqlDbType.Decimal).Value = p.doubleRate;
                cmd.Parameters.Add("@TripleRate", SqlDbType.Decimal).Value = p.tripleRate;
                cmd.Parameters.Add("@QuadRate", SqlDbType.Decimal).Value = p.quadRate;
                cmd.Parameters.Add("@SingleComm", SqlDbType.Decimal).Value = p.singleComm;
                cmd.Parameters.Add("@DoubleComm", SqlDbType.Decimal).Value = p.doubleComm;
                cmd.Parameters.Add("@TripleComm", SqlDbType.Decimal).Value = p.tripleComm;
                cmd.Parameters.Add("@QuadComm", SqlDbType.Decimal).Value = p.quadComm;
                cmd.Parameters.Add("@Quantity", SqlDbType.Int).Value = p.quantity;
                cmd.Parameters.Add("@Allocated", SqlDbType.Int).Value = p.allocated;
                cmd.Parameters.Add("@PortCharges", SqlDbType.Decimal).Value = p.portCharges;
                cmd.Parameters.Add("@PackageType", SqlDbType.VarChar, 5).Value = p.packageType;
                p.packageID = Convert.ToInt32(cmd.ExecuteScalar());
            }
            return p.packageID;
        }

        public static void Update(GroupPackage p)
        {
            string sSQL = @"UPDATE dbo.grp_Package SET PackageCd = @PackageCd, PackageName = @PackageName, SingleRate = @SingleRate, 
                DoubleRate = @DoubleRate, TripleRate = @TripleRate, QuadRate = @QuadRate, SingleComm = @SingleComm, DoubleComm = @DoubleComm, TripleComm = @TripleComm, QuadComm= @QuadComm,
                Quantity = @Quantity, Allocated = @Allocated, PortCharges=@PortCharges, PackageType=@PackageType 
                WHERE GroupID = @GroupID AND PackageID = @packageID"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PackageID", SqlDbType.Int).Value = p.packageID;
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = p.groupID;
                cmd.Parameters.Add("@PackageCd", SqlDbType.VarChar, 3).Value = p.packageCd;
                cmd.Parameters.Add("@PackageName", SqlDbType.VarChar, 100).Value = p.packageName;
                cmd.Parameters.Add("@SingleRate", SqlDbType.Decimal).Value = p.singleRate;
                cmd.Parameters.Add("@DoubleRate", SqlDbType.Decimal).Value = p.doubleRate;
                cmd.Parameters.Add("@TripleRate", SqlDbType.Decimal).Value = p.tripleRate;
                cmd.Parameters.Add("@QuadRate", SqlDbType.Decimal).Value = p.quadRate;
                cmd.Parameters.Add("@SingleComm", SqlDbType.Decimal).Value = p.singleComm;
                cmd.Parameters.Add("@DoubleComm", SqlDbType.Decimal).Value = p.doubleComm;
                cmd.Parameters.Add("@TripleComm", SqlDbType.Decimal).Value = p.tripleComm;
                cmd.Parameters.Add("@QuadComm", SqlDbType.Decimal).Value = p.quadComm;
                cmd.Parameters.Add("@Quantity", SqlDbType.Int).Value = p.quantity;
                cmd.Parameters.Add("@Allocated", SqlDbType.Int).Value = p.allocated;
                cmd.Parameters.Add("@PortCharges", SqlDbType.Decimal).Value = p.portCharges;
                cmd.Parameters.Add("@PackageType", SqlDbType.VarChar, 5).Value = p.packageType;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string groupID, int packageID)
        {
            string sSQL = @"DELETE FROM dbo.grp_Package WHERE groupID = @groupID and packageid = @packageid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                cmd.Parameters.Add("@packageid", SqlDbType.Int).Value = packageID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList(string groupID)
        {
            string sSQL = @"SELECT *, allocated-sold as avail FROM dbo.vw_grp_Package WHERE groupid = @groupid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static decimal GetTotalRate(GroupPackage p, int paxCnt)
        {
            decimal amt = p.doubleRate * 2;
            if (paxCnt == 1)
                amt = p.singleRate;
            else if (paxCnt == 2)
                amt = p.doubleRate * 2;
            else if (paxCnt == 3)
                amt  = (p.doubleRate * 2) + p.tripleRate;
            else if (paxCnt == 4)
                amt = (p.doubleRate * 2) + p.tripleRate + p.quadRate;
            return amt;
        }

        public static decimal GetPaxRate(GroupPackage p, int paxCnt, int paxNum)
        {
            decimal amt = p.doubleRate;
            if (paxCnt == 1)
                amt = p.singleRate;
            else if (paxCnt == 2)
                amt = p.doubleRate;
            else if (paxCnt == 3)
                amt = (paxNum == 3) ? p.tripleRate : p.doubleRate;
            else if (paxCnt == 4)
            {
                if (paxNum == 4)
                    amt = p.quadRate;
                else if (paxNum == 3)
                    amt = p.tripleRate;
                else
                    amt = p.doubleRate;
            }
            return amt;
        }

        public static List<PickList> GetPackageTypeList(string groupID)
        {
            string sSQL = @"SELECT distinct  p.packagetype, t.PackageTypeName, 
                case when p.packagetype in ('ROOM','CABIN') then 1 else 5 end as Sort
                FROM dbo.grp_Package p
                INNER JOIN dbo.grp_PackageType t on t.PackageType=p.PackageType
                WHERE p.GroupID = @GroupID
                ORDER BY Sort";
            List<PickList> list = new List<PickList>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                    list.Add(new PickList(rs["packagetype"].ToString(), rs["packagetypename"].ToString()));
            }
            return list;
        }

    }
}