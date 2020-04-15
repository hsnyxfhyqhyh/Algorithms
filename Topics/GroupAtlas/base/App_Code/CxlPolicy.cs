using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class CxlPolicyDet2
    {
        private string _daysPrior;
        private string _custLoss;
        private DateTime _dateFr;
        private DateTime _dateTo;

        public string daysPrior { get { return _daysPrior; } }
        public string custLoss { get { return _custLoss; } }
        public DateTime dateFr { get { return _dateFr; } }
        public DateTime dateTo { get { return _dateTo; } }
        public string dateRange 
        {
            get { return string.Format("{0} - {1}", dateFr.ToShortDateString(), dateTo.ToShortDateString()); ; } 
        }

        public CxlPolicyDet2(string daysPrior, string custLoss, DateTime dateFr, DateTime dateTo)
        {
            this._daysPrior = daysPrior;
            this._custLoss = custLoss;
            this._dateFr = dateFr;
            this._dateTo = dateTo;
        }
    }

    public class CxlPolicyDet
    {
        private int _dtlID = 0;
        private string _cxlPolicy;
        private string _valType;
        private int _rngStart;
        private int _rngEnd;

        public int dtlID { get {return _dtlID; } }
        public string cxlPolicy { get {return _cxlPolicy; } }
        public string valType { get {return _valType; } }
        public int rngStart { get {return _rngStart; } }
        public int rngEnd { get {return _rngEnd; } }

        public CxlPolicyDet(int dtlID, string cxlPolicy, string valType, int rngStart, int rngEnd)
        {
            this._dtlID = dtlID;
            this._cxlPolicy = cxlPolicy;
            this._valType = valType;
            this._rngStart = rngStart;
            this._rngEnd = rngEnd;
        }
    }

    public class CxlPolicy
    {

        public int policyID = 0;
	    public string provider = "";
	    public string policyName = "";
        public List<CxlPolicyDet> policyList;

        public static CxlPolicy GetPolicy(int policyID)
        {
            return GetPolicy(policyID, 0);
        }

		public static CxlPolicy GetPolicy(int policyID, int blankRows)
		{
            string SQL_POLICY = "SELECT * FROM dbo.grp_CxlPolicy WHERE policyID=@policyID";
            string SQL_POLICY_DET = "SELECT * FROM dbo.grp_CxlPolicyDetail WHERE policyID=@policyID ORDER BY rngStart DESC";
            CxlPolicy p = new CxlPolicy();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(SQL_POLICY, cn);
                cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = policyID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (rs.Read())
                {
                    p.policyID = (int)rs["policyid"];
                    p.provider = rs["provider"] + "";
                    p.policyName = rs["policy name"] + "";
                }
                rs.Close();
                //
                List<CxlPolicyDet> list = new List<CxlPolicyDet>();
                cmd = new SqlCommand(SQL_POLICY_DET, cn);
                cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = policyID;
                rs = cmd.ExecuteReader();
                while (rs.Read())
                {
                    int dtlID = Convert.ToInt32(rs["dtlID"]);
                    string cxlPolicy = rs["cxlPolicy"]+"";
                    string valType = rs["valType"]+"";
                    int rngStart = Util.parseInt(rs["rngStart"]);
                    int rngEnd = Util.parseInt(rs["rngEnd"]);
                    list.Add(new CxlPolicyDet(dtlID, cxlPolicy, valType, rngStart, rngEnd));
                }
                rs.Close();
                //
                if (blankRows > 0 && blankRows < 10)
                {
                    for (int i = 0; i < blankRows; i++ )
                        list.Add(new CxlPolicyDet(0, "", "", 0, 0));
                }
                p.policyList = list;
            }
            return p;
        }

        public static int Update(CxlPolicy p)
        {
            string SQL_INSERT = @"INSERT INTO dbo.grp_CxlPolicy (Provider, [Policy Name]) VALUES (@Provider, @PolicyName); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.grp_CxlPolicy SET [Policy Name] = @PolicyName, Provider = @Provider WHERE PolicyID = @PolicyID";
            string SQL_INSERT_DET = @"INSERT INTO dbo.grp_CxlPolicyDetail (PolicyID, CxlPolicy, valType, rngStart, rngEnd)
                VALUES (@PolicyID, @CxlPolicy, @valType, @rngStart, @rngEnd);";
            string SQL_UPDATE_DET = @"UPDATE dbo.grp_CxlPolicyDetail SET CxlPolicy=@CxlPolicy, valType=@valType, rngStart=@rngStart, rngEnd=@rngEnd
                WHERE PolicyID=@PolicyID AND dtlID=@dtlID;";
            string SQL_DELETE_DET = @"DELETE FROM dbo.grp_CxlPolicyDetail WHERE PolicyID=@PolicyID AND dtlID=@dtlID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    if (p.policyID > 0)
                    {
                        cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                        cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = p.policyID;
                        cmd.Parameters.Add("@policyname", SqlDbType.VarChar, 50).Value = p.policyName;
                        cmd.Parameters.Add("@provider", SqlDbType.VarChar, 50).Value = p.provider;
                        cmd.ExecuteNonQuery();
                    }
                    else
                    {
                        cmd = new SqlCommand(SQL_INSERT, cn, trn);
                        cmd.Parameters.Add("@policyname", SqlDbType.VarChar, 50).Value = p.policyName;
                        cmd.Parameters.Add("@provider", SqlDbType.VarChar, 50).Value = p.provider;
                        p.policyID = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    foreach (CxlPolicyDet d in p.policyList)
                    {
                        if (d.dtlID == 0 && d.cxlPolicy != "" && d.valType != "")
                        {
                            cmd = new SqlCommand(SQL_INSERT_DET, cn, trn);
                            cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = p.policyID;
                            cmd.Parameters.Add("@cxlPolicy", SqlDbType.VarChar, 50).Value = d.cxlPolicy;
                            cmd.Parameters.Add("@valtype", SqlDbType.Char, 1).Value = d.valType;
                            cmd.Parameters.Add("@rngstart", SqlDbType.Int).Value = d.rngStart;
                            cmd.Parameters.Add("@rngend", SqlDbType.Int).Value = d.rngEnd;
                            cmd.ExecuteNonQuery();
                        }
                        else if (d.dtlID > 0 && d.cxlPolicy != "" && d.valType != "")
                        {
                                cmd = new SqlCommand(SQL_UPDATE_DET, cn, trn);
                                cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = p.policyID;
                                cmd.Parameters.Add("@dtlid", SqlDbType.Int).Value = d.dtlID;
                                cmd.Parameters.Add("@cxlPolicy", SqlDbType.VarChar, 50).Value = d.cxlPolicy;
                                cmd.Parameters.Add("@valtype", SqlDbType.Char, 1).Value = d.valType;
                                cmd.Parameters.Add("@rngstart", SqlDbType.Int).Value = d.rngStart;
                                cmd.Parameters.Add("@rngend", SqlDbType.Int).Value = d.rngEnd;
                                cmd.ExecuteNonQuery();
                        }
                        else if (d.dtlID > 0 && d.cxlPolicy == "" && d.valType == "")
                        {
                            cmd = new SqlCommand(SQL_DELETE_DET, cn, trn);
                            cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = p.policyID;
                            cmd.Parameters.Add("@dtlid", SqlDbType.Int).Value = d.dtlID;
                            cmd.ExecuteNonQuery();
                        }
                    }
                    trn.Commit();
                }
                catch (SqlException ex)
                {
                    string msg = ex.Message;
                    try { trn.Rollback(); }
                    catch { }
                    throw new Exception(msg);
                }
            }
            return p.policyID;
        }

        public static void Delete(int policyID)
        {
            string sSQL = @"DELETE FROM dbo.grp_CxlPolicyDetail WHERE PolicyID=@PolicyID;
                DELETE FROM dbo.grp_CxlPolicy WHERE PolicyID=@PolicyID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = policyID;
                    cmd.ExecuteNonQuery();
                    trn.Commit();
                }
                catch (SqlException ex)
                {
                    string msg = ex.Message;
                    try { trn.Rollback(); }
                    catch { }
                    throw new Exception(msg);
                }
            }
        }

        public static DataTable GetList()
        {
            //string sSQL = @"SELECT c.PolicyID, c.Provider, c.[Policy Name] as PolicyName, p.ProvName
            //    FROM dbo.grp_CxlPolicy c 
            //    INNER JOIN dbo.trvl_Provider p ON c.Provider = p.Provider
            //    ORDER BY p.ProvName, PolicyName;";
            string sSQL = @"SELECT c.PolicyID, c.Provider, c.[Policy Name] as PolicyName, p.vendorName as ProvName
                FROM dbo.grp_CxlPolicy c 
                INNER JOIN dbo.mt_vendor p ON c.Provider = p.vendorCode
                ORDER BY p.vendorName, PolicyName;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static List<CxlPolicyDet2> GetDetails(int policyID, string sDepartDate)
        {
            string sSQL = @"SELECT rngStart, rngEnd, CxlPolicy, valType FROM dbo.grp_CxlPolicyDetail 
                WHERE PolicyID=@PolicyID ORDER BY rngStart DESC;";
            List<CxlPolicyDet2> list = new List<CxlPolicyDet2>();
            if (!Util.isValidDate(sDepartDate))
                return list;

            DateTime departDate = Convert.ToDateTime(sDepartDate);
            int  days2Depart = (departDate - DateTime.Today).Days;
            
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@policyid", SqlDbType.Int).Value = policyID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int rngStart = Util.parseInt(rs["rngStart"]);
                    int rngEnd = Util.parseInt(rs["rngEnd"]);
                    string daysPrior = string.Format("{0} - {1}", rngEnd, rngStart);
                    string custLoss = rs["cxlPolicy"] + "";
                    DateTime dateFr = departDate.AddDays(-rngEnd);
                    DateTime dateTo = departDate.AddDays(-rngStart);
                    list.Add(new CxlPolicyDet2(daysPrior, custLoss, dateFr, dateTo));
                }
            }
            return list;
        }



    }
}