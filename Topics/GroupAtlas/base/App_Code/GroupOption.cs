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
        private bool _inventoryControl;
        private string _optionType;
        private int _quantity;
        private int _allocated;

        private string _optionCode; 

        private decimal _singlerate;
        private decimal _doublerate;
        private decimal _triplerate;
        private decimal _quadrate;
        private decimal _singlecommission;
        private decimal _doublecommission;
        private decimal _triplecommission;
        private decimal _quadcommission;

        public int optionID { get { return _optionID; } }
        public string optionName {
            get { return _optionName; }
            set { _optionName = value.ToString(); }
        }

        public string optionCode {
            get { return _optionCode; }
            set { _optionCode = value.ToString(); }
        }

        public string rateType { get { return _rateType; } }
        public decimal rate { get { return _rate; } }
        public bool isRequired { get { return _isRequired; } }
        public bool inventoryControl { get { return _inventoryControl; } }
        public string optionType {
            get { return _optionType; }
            set { _optionType = value.ToString(); }
        }
        public string rateTypeDesc
        {
            get {return PickList.GetRateTypeDesc(_rateType); }
        }
        public int quantity {
            get { return _quantity; }
            set { _quantity = Convert.ToInt32(value.ToString()); }
        }

        public int allocated {
            get { return _allocated; }
            set { _allocated = Convert.ToInt32(value.ToString()); }
        }

        public decimal singlerate {
            get { return _singlerate; }
            set { _singlerate = Convert.ToDecimal(value.ToString()); }
        }
        public decimal doublerate {
            get { return _doublerate; }
            set { _doublerate = Convert.ToDecimal(value.ToString()); }
        }
        public decimal triplerate {
            get { return _triplerate; }
            set { _triplerate = Convert.ToDecimal(value.ToString()); }
        }
        public decimal quadrate {
            get { return _quadrate; }
            set { _quadrate = Convert.ToDecimal(value.ToString()); }
        }
        public decimal singlecommission {
            get { return _singlecommission; }
            set { _singlecommission = Convert.ToDecimal(value.ToString()); }
        }
        public decimal doublecommission {
            get { return _doublecommission; }
            set { _doublecommission = Convert.ToDecimal(value.ToString()); }
        }
        public decimal triplecommission {
            get { return _triplecommission; }
            set { _triplecommission = Convert.ToDecimal(value.ToString()); }
        }
        public decimal quadcommission {
            get { return _quadcommission; }
            set { _quadcommission = Convert.ToDecimal(value.ToString()); }
        }


        public GroupOption(int optionID, string optionName, string rateType, decimal rate, bool isRequired, bool inventoryControl, string optionType)
        {
            this._optionID = optionID;
            this._optionName = optionName;
            this._rateType = rateType;
            this._rate = rate;
            this._isRequired = isRequired;
            this._inventoryControl = inventoryControl;
            this._optionType = optionType;

        }

        public GroupOption(int optionID, string optionName, string rateType, decimal rate, bool isRequired, bool inventoryControl, string optionType, string sOptionCode,
                            decimal singleRate, decimal doubleRate, decimal tripleRate, decimal quadRate,
                            decimal singleComm, decimal doubleComm, decimal tripleComm, decimal quadComm, int iQuantity, int iAllocated)
        {
            this._optionID = optionID;
            this._optionName = optionName;
            this._rateType = rateType;
            this._rate = rate;
            this._isRequired = isRequired;
            this._inventoryControl = inventoryControl;
            this._optionType = optionType;

            this._optionCode = sOptionCode;
            this._singlerate = singleRate;
            this._doublerate = doubleRate;
            this._triplerate = tripleRate;
            this._quadrate = quadRate;
            this._singlecommission = singleComm;
            this._doublecommission = doubleComm;
            this._triplecommission = tripleComm;
            this._quadcommission = quadComm;
            this._quantity = iQuantity;
            this._allocated = iAllocated; 
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
                    list.Add(new GroupOption(0, "", "", 0, false, false,  "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
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
            bool inventoryControl = (bool)rs["inventoryControl"];
            string optiontype = rs["optiontype"] + "";

            string sOptionCode = rs["OptionCode"] + "";
            decimal singleRate = Util.parseDec(rs["SingleRate"]);
            decimal doubleRate = Util.parseDec(rs["DoubleRate"]);
            decimal tripleRate = Util.parseDec(rs["TripleRate"]);
            decimal quadRate = Util.parseDec(rs["QuadRate"]);

            decimal singleComm = Util.parseDec(rs["SingleComm"]);
            decimal doubleComm = Util.parseDec(rs["DoubleComm"]);
            decimal tripleComm = Util.parseDec(rs["TripleComm"]);
            decimal quadComm = Util.parseDec(rs["QuadComm"]);

            int iQuantity = Convert.ToInt32(rs["Quantity"]);
            int iAllocated = Convert.ToInt32(rs["Allocated"]);
           

            GroupOption o = new GroupOption(optionid, optionname, ratetype, rate, isrequired, inventoryControl, optiontype, sOptionCode,
                                        singleRate, doubleRate, tripleRate, quadRate, singleComm, doubleComm, tripleComm, quadComm, iQuantity, iAllocated);
            return o;
        }

        public static void Update(string groupID, List<GroupOption> list)
        {
            string SQL_INSERT = @"INSERT INTO dbo.grp_Option(groupid, optionname, ratetype, rate, isrequired, inventoryControl) 
                VALUES(@GroupID, @optionname, @ratetype, @rate, @isrequired, @inventoryControl)";
            string SQL_UPDATE = @"UPDATE dbo.grp_Option SET optionname=@optionname, ratetype=@ratetype, rate=@rate, isrequired=@isrequired , inventoryControl= @inventoryControl
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
                                cmd.Parameters.Add("@inventoryControl", SqlDbType.Bit).Value = c.inventoryControl;
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
                                cmd.Parameters.Add("@inventoryControl", SqlDbType.Bit).Value = c.inventoryControl;
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

        public static void Update(string groupID, GroupOption c)
        {
            string SQL_UPDATE = @"UPDATE dbo.grp_Option SET optionname=@optionname, optioncode=@optioncode, ratetype=@ratetype, rate=@rate, isrequired=@isrequired , inventoryControl= @inventoryControl, 
                                 SingleRate=@SingleRate, DoubleRate=@DoubleRate, TripleRate=@TripleRate, QuadRate=@QuadRate, 
                                 SingleComm=@SingleComm, DoubleComm=@DoubleComm, TripleComm=@TripleComm, QuadComm=@QuadComm, Quantity=@Quantity, Allocated=@Allocated
                WHERE optionid=@optionid AND groupid=@groupid";
            
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    
                    SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);

                    cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                    cmd.Parameters.Add("@optionid", SqlDbType.Int).Value = c.optionID;
                    cmd.Parameters.Add("@optionname", SqlDbType.VarChar, 100).Value = c.optionName;
                    cmd.Parameters.Add("@ratetype", SqlDbType.VarChar, 1).Value = c.rateType;
                    cmd.Parameters.Add("@rate", SqlDbType.Decimal).Value = c.rate;
                    cmd.Parameters.Add("@isrequired", SqlDbType.Bit).Value = c.isRequired;
                    cmd.Parameters.Add("@inventoryControl", SqlDbType.Bit).Value = c.inventoryControl;

                    cmd.Parameters.Add("@optioncode", SqlDbType.VarChar).Value = c.optionCode;
                    cmd.Parameters.Add("@SingleRate", SqlDbType.Decimal).Value = c.singlerate;
                    cmd.Parameters.Add("@DoubleRate", SqlDbType.Decimal).Value = c.doublerate;
                    cmd.Parameters.Add("@TripleRate", SqlDbType.Decimal).Value = c.triplerate;
                    cmd.Parameters.Add("@QuadRate", SqlDbType.Decimal).Value = c.quadrate;
                    cmd.Parameters.Add("@SingleComm", SqlDbType.Decimal).Value = c.singlecommission;
                    cmd.Parameters.Add("@DoubleComm", SqlDbType.Decimal).Value = c.doublecommission;
                    cmd.Parameters.Add("@TripleComm", SqlDbType.Decimal).Value = c.triplecommission;
                    cmd.Parameters.Add("@QuadComm", SqlDbType.Decimal).Value = c.quadcommission;
                    cmd.Parameters.Add("@Quantity", SqlDbType.Int).Value = c.quantity;
                    cmd.Parameters.Add("@Allocated", SqlDbType.Int).Value = c.allocated;


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