using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class GroupOption
    {


        private int _optionID;
        private string _optionName;
        private string _rateType;
        private decimal _rate;
        private bool _isRequired;
        private string _optionType;

        public int optionID { get { return _optionID; } }
        public string optionName { get { return _optionName; } }
        public string rateType { get { return _rateType; } }
        public decimal rate { get { return _rate; } }
        public bool isRequired { get { return _isRequired; } }
        public string optionType { get { return _optionType; } }
        public string rateTypeDesc
        {
            get {return PickList.GetRateTypeDesc(_rateType); }
        }

        public GroupOption(int optionID, string optionName, string rateType, decimal rate, bool isRequired, string optionType)
        {
            this._optionID = optionID;
            this._optionName = optionName;
            this._rateType = rateType;
            this._rate = rate;
            this._isRequired = isRequired;
            this._optionType = optionType;
        }

        public static GroupOption GetOption(int optionID, string groupID)
        {
            string sSQL = "SELECT * FROM dbo.grp_Option WHERE optionid=@optionid and groupID = @GroupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@optionID", SqlDbType.Int).Value = optionID;
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                return FillOption(rs);
            }
        }

        public static List<GroupOption> GetOption(string groupID)
        {
            return GetOption(groupID, false);
        }

        public static List<GroupOption> GetOption(string groupID, bool blankRows)
        {
            string sSQL = "SELECT * FROM dbo.grp_Option WHERE groupID = @GroupID order by optionid";
            List<GroupOption> list = new List<GroupOption>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    list.Add(FillOption(rs));
                }
            }
            if (blankRows)
            {
                int cnt = (list.Count == 0) ? 10 : 5;
                for (int i = 0; i < cnt; i++)
                    list.Add(new GroupOption(0, "", "", 0, false, ""));
            }
            return list;
        }

        private static GroupOption FillOption(SqlDataReader rs)
        {
            int optionid = Convert.ToInt32(rs["optionid"]);
            string optionname = rs["optionname"] + "";
            string ratetype = rs["ratetype"] + "";
            decimal rate = Util.parseDec(rs["rate"]);
            bool isrequired = (bool)rs["isrequired"];
            string optiontype = rs["optiontype"] + "";
            GroupOption o = new GroupOption(optionid, optionname, ratetype, rate, isrequired, optiontype);
            return o;
        }

        public static void Update(string groupID, List<GroupOption> list)
        {
            string SQL_INSERT = @"INSERT INTO dbo.grp_Option(groupid, optionname, ratetype, rate, isrequired) 
                VALUES(@GroupID, @optionname, @ratetype, @rate, @isrequired)";
            string SQL_UPDATE = @"UPDATE dbo.grp_Option SET optionname=@optionname, ratetype=@ratetype, rate=@rate, isrequired=@isrequired 
                WHERE optionid=@optionid AND groupid=@groupid";
            string SQL_DELETE = @"DELETE FROM dbo.grp_Option WHERE optionid=@optionid AND groupid=@groupid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (GroupOption c in list)
                    {
                        if (c.optionID == 0)
                        {
                            if (c.optionName != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_INSERT, cn, trn);
                                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                                cmd.Parameters.Add("@optionname", SqlDbType.VarChar, 100).Value = c.optionName;
                                cmd.Parameters.Add("@ratetype", SqlDbType.VarChar, 1).Value = (c.rateType=="") ? "P" : c.rateType;
                                cmd.Parameters.Add("@rate", SqlDbType.Decimal).Value = c.rate;
                                cmd.Parameters.Add("@isrequired", SqlDbType.Bit).Value = c.isRequired;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            if (c.optionName == "" && c.rateType == "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                                cmd.Parameters.Add("@optionid", SqlDbType.Int).Value = c.optionID;
                                cmd.ExecuteNonQuery();
                            }
                            else
                            {
                                SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                                cmd.Parameters.Add("@optionid", SqlDbType.Int).Value = c.optionID;
                                cmd.Parameters.Add("@optionname", SqlDbType.VarChar, 100).Value = c.optionName;
                                cmd.Parameters.Add("@ratetype", SqlDbType.VarChar, 1).Value = c.rateType;
                                cmd.Parameters.Add("@rate", SqlDbType.Decimal).Value = c.rate;
                                cmd.Parameters.Add("@isrequired", SqlDbType.Bit).Value = c.isRequired;
                                cmd.ExecuteNonQuery();
                            }
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
        }

        public static void Delete(string groupID, int optionID)
        {
            string sSQL = @"DELETE FROM dbo.grp_Option WHERE groupID = @groupID and optionid = @optionid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                cmd.Parameters.Add("@optionid", SqlDbType.Int).Value = optionID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList(string groupID)
        {
            string sSQL = @"SELECT * FROM dbo.grp_Option WHERE groupid = @groupid";
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

        public static void InsertDefOptions(string groupID)
        {
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand("usp_InsertDefOptions", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                cmd.ExecuteNonQuery();
            }
        }

    }
}