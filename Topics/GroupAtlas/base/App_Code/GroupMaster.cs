using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class GroupMaster
    {

        public string GroupID = "";
        public string ProviderGroupID = "";
        public string Provider = "";
        public string VGroupCode = "";
        public string VendorGroupCode2 = "";
        public string VGroupDescription = "";
        public string vendorName2 = "";
        public int GroupAgentFlxID = 0;
        public int AffinityAgentFlxID = 0;
        public string AffinityGroupName = "";
        public string DepartDate = "";
        public string ReturnDate = "";
        public string RevType = "";
        public string PortCity = "";
        public string Destination = "";
        public int ShipID = 0;
        public int TourID = 0;
        public int ItinID = 0;
        public string AddDetails = "";
        public int Berths = 0;
        public decimal Deposit = 0;
        public bool Air_Inc = false;
        public bool Cancelled = false;
        public string Recall_1 = "";
        public string Recall_2 = "";
        public string Recall_3 = "";
        public string Deposit_2 = "";
        public string FinalDue = "";
        public int GroupType = 0;
        public decimal FinalGrossSales = 0;
        public decimal Premium = 0;
        public decimal FinalComm = 0;
        public decimal FinalBonusComm = 0;
        public decimal FinalNetTourConductor = 0;
        public decimal FinalGrossExpense = 0;
        public int FinalPax = 0;
        public string Date2Accounting = "";
        public decimal ClosedSales = 0;
        public decimal ClosedComm = 0;
        public decimal ClosedBonusComm = 0;
        public decimal ClosedTourConductor = 0;
        public decimal ClosedGrossExpense = 0;
        public int ClosedPax = 0;
        public string DateClosed = "";
        public bool TrvlWrkSheet = false;
        public string CancelDate = "";
        public string HardStopDate = "";
        public int CxlPolicyID = 0;
        public decimal Premium2 = 0;
        public decimal ClosedTourConUsed = 0;
        public decimal FinalTourConUsed = 0;
        public string ClosedNotes = "";
        public string GroupName = "";
        public bool IsSellOverAlloc = false;
        public int MaxPassengers = 0;
        public int MinPassengers = 0;
        // descriptions
        public string GroupTypeDesc = "";
        public string RevTypeDesc = "";
        public string PortCityName = "";
        public string DestinationName = "";
	    public string GroupAgentName = "";
        public string AffinityAgentName = "";
        public string Itinerary = "";
        public string ShipName = "";
        public string ProvName = "";
        public string TourName = "";
        public int GType = 0;
        public string IATA = "";
        //
        public string FinalDue2
        {
            get { return (FinalDue != "") ? Convert.ToDateTime(FinalDue).AddDays(-10).ToShortDateString() : ""; }
        }
        // 
        public int ReportType
        {
            get
            {
                //if (GroupType == 1)
                //    return 1;
                //else if (GroupType == 2 || GroupType == 3)
                //    return 3;
                //else if (GroupType == 4)
                //    return 2;
                //return 1;
                return GroupType;
            }
        }


		public static GroupMaster GetGroupMaster(string groupID)
		{
            string sSQL = @"SELECT m.*,  p.PickDesc as GroupTypeDesc, p2.PickDesc as RevTypeDesc, pc.PortCityName as PortCityName, dc.Name2 as DestinationName, 
	                ga.Agent as GroupAgentName, aa.Agent as AffinityAgentName, it.Itinerary, s.ShipName, v.vendorName as ProvName, 
					t.TourName, gt.GroupType as GType, vg.VGroupDescription, v1.vendorName
                FROM dbo.grp_Master m 
                LEFT JOIN dbo.grp_PickList p on p.PickType = 'GROUPTYPE' AND p.PickCode = m.GroupType
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = m.RevType
                LEFT JOIN dbo.vw_Employee ga on ga.FlxID = m.GroupAgentFlxID
                LEFT JOIN dbo.vw_Employee aa on aa.FlxID = m.AffinityAgentFlxID
                LEFT JOIN dbo.vw_PortCity pc on pc.PortCity = m.PortCity
                LEFT JOIN dbo.vw_Location dc on dc.locode = m.Destination
                LEFT JOIN dbo.grp_ItinID it on it.ItinID = m.ItinID
                LEFT JOIN dbo.grp_ShipID s on s.ShipID = m.ShipID
                LEFT JOIN dbo.grp_TourID t on t.TourID = m.TourID
                LEFT JOIN dbo.mt_vendor v on v.vendorCode = m.Provider
				Left JOIN dbo.grp_VGroupCode vg on m.VGroupCode = vg.VGroupCode
				Left JOIN dbo.mt_vendor v1 on m.VendorGroupCode2 = v1.vendorCode
                --LEFT JOIN dbo.trvl_Provider pr on pr.Provider = m.Provider
				Left JOIN dbo.grp_GroupType gt on m.GroupType = gt.PickCode
                WHERE m.GroupID = @groupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                GroupMaster g = new GroupMaster();
                g.GroupID = rs["GroupID"].ToString();
                g.ProviderGroupID = rs["ProviderGroupID"] + "";
                g.Provider = rs["Provider"] + "";
                g.VGroupCode = rs["VGroupCode"] + "";
                g.VendorGroupCode2 = rs["VendorGroupCode2"] + "";
                g.GroupAgentFlxID = Util.parseInt(rs["GroupAgentFlxID"]);
                g.AffinityAgentFlxID = Util.parseInt(rs["AffinityAgentFlxID"]);
                g.AffinityGroupName = rs["AffinityGroupName"] + "";
                g.DepartDate = (rs["DepartDate"] is DBNull) ? "" : Convert.ToDateTime(rs["DepartDate"]).ToShortDateString();
                g.ReturnDate = (rs["ReturnDate"] is DBNull) ? "" : Convert.ToDateTime(rs["ReturnDate"]).ToShortDateString();
                g.RevType = (rs["RevType"] + "").ToUpper();
                g.PortCity = rs["PortCity"] + "";
                g.Destination = rs["Destination"] + "";
                g.ShipID = Util.parseInt(rs["ShipID"]);
                g.TourID = Util.parseInt(rs["TourID"]);
                g.ItinID = Util.parseInt(rs["ItinID"]);
                g.AddDetails = rs["AddDetails"] + "";
                g.Berths = Util.parseInt(rs["Berths"]);
                g.Deposit = Util.parseDec(rs["Deposit"]);
                g.Air_Inc = (bool) rs["Air_Inc"];
                g.Cancelled = (bool) rs["Cancelled"];
                g.Recall_1 = (rs["Recall_1"] is DBNull) ? "" : Convert.ToDateTime(rs["Recall_1"]).ToShortDateString();
                g.Recall_2 = (rs["Recall_2"] is DBNull) ? "" : Convert.ToDateTime(rs["Recall_2"]).ToShortDateString();
                g.Recall_3 = (rs["Recall_3"] is DBNull) ? "" : Convert.ToDateTime(rs["Recall_3"]).ToShortDateString();
                g.Deposit_2 = (rs["Deposit_2"] is DBNull) ? "" : Convert.ToDateTime(rs["Deposit_2"]).ToShortDateString();
                g.FinalDue = (rs["FinalDue"] is DBNull) ? "" : Convert.ToDateTime(rs["FinalDue"]).ToShortDateString();
                g.GroupType = Util.parseInt(rs["GroupType"]);
                g.FinalGrossSales = Convert.ToDecimal(rs["FinalGrossSales"]);
                g.Premium = Convert.ToDecimal(rs["Premium"]);
                g.FinalComm = Convert.ToDecimal(rs["FinalComm"]);
                g.FinalBonusComm = Convert.ToDecimal(rs["FinalBonusComm"]);
                g.FinalNetTourConductor = Convert.ToDecimal(rs["FinalNetTourConductor"]);
                g.FinalGrossExpense = Convert.ToDecimal(rs["FinalGrossExpense"]);
                g.FinalPax = Util.parseInt(rs["FinalPax"]);
                g.Date2Accounting = (rs["Date2Accounting"] is DBNull) ? "" : Convert.ToDateTime(rs["Date2Accounting"]).ToShortDateString();
                g.ClosedSales = Convert.ToDecimal(rs["ClosedSales"]);
                g.ClosedComm = Convert.ToDecimal(rs["ClosedComm"]);
                g.ClosedBonusComm = Convert.ToDecimal(rs["ClosedBonusComm"]);
                g.ClosedTourConductor = Convert.ToDecimal(rs["ClosedTourConductor"]);
                g.ClosedGrossExpense = Convert.ToDecimal(rs["ClosedGrossExpense"]);
                g.ClosedPax = Util.parseInt(rs["ClosedPax"]);
                g.DateClosed = (rs["DateClosed"] is DBNull) ? "" : Convert.ToDateTime(rs["DateClosed"]).ToShortDateString();
                g.TrvlWrkSheet = (bool) rs["TrvlWrkSheet"];
                g.CancelDate = (rs["CancelDate"] is DBNull) ? "" : Convert.ToDateTime(rs["CancelDate"]).ToShortDateString();
                g.HardStopDate = (rs["HardStopDate"] is DBNull) ? "" : Convert.ToDateTime(rs["HardStopDate"]).ToShortDateString();
                g.CxlPolicyID = Util.parseInt(rs["CxlPolicyID"]);
                g.Premium2 = Convert.ToDecimal(rs["Premium2"]);
                g.ClosedTourConUsed = Convert.ToDecimal(rs["ClosedTourConUsed"]);
                g.FinalTourConUsed = Convert.ToDecimal(rs["FinalTourConUsed"]);
                g.ClosedNotes = rs["ClosedNotes"] + "";
                g.GroupName = rs["GroupName"] + "";
                g.IsSellOverAlloc = (bool) rs["IsSellOverAlloc"];
                g.MaxPassengers = Util.parseInt(rs["MaxPassengers"]);
                g.MinPassengers = Util.parseInt(rs["MinPassengers"]);
                // descriptions
                g.GroupTypeDesc = rs["GroupTypeDesc"] + "";
                g.RevTypeDesc = rs["RevTypeDesc"] + "";
                g.PortCityName = rs["PortCityName"] + "";
                g.DestinationName = rs["DestinationName"] + "";
                g.GroupAgentName = rs["GroupAgentName"] + "";
                g.AffinityAgentName = rs["AffinityAgentName"] + "";
                g.Itinerary = rs["Itinerary"] + "";
                g.ShipName = rs["ShipName"] + "";
                g.ProvName = rs["ProvName"] + "";
                g.TourName = rs["TourName"] + "";
                g.IATA = rs["IATA"] + "";
                g.VGroupDescription = rs["VGroupDescription"] + "";
                g.vendorName2 = rs["vendorName"] + "";
                g.GType = Util.parseInt(rs["GType"]);

                return g;
            }
		}

        public static string GetGroupNumber(string groupType, string departDate)
        {
            string groupid = "";
            string sSQL = @"SELECT @groupid = dbo.udf_NextGroupID (@grouptype, @departDate);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Direction = ParameterDirection.Output;
                cmd.Parameters.Add("@DepartDate", SqlDbType.VarChar).Value = departDate;
                cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = groupType;

                cmd.ExecuteNonQuery();
                groupid = cmd.Parameters["@GroupID"].Value.ToString();       
            }
            if (groupid == "")
                throw new ApplicationException("Unable to get next group id. Please try again.");
            return groupid;
        }

        public static void Add(string groupType, DateTime departDate, string provider, int shipID, string providergroupid, string groupid, string VGroupCode)
        {
            int iReturn = 0;
            string sSQL = @"IF EXISTS(SELECT 1 FROM dbo.grp_Master WHERE groupid=@groupid) 
                    BEGIN
                        SET @groupid = '';
                        RETURN;
                    END;
                    INSERT INTO dbo.grp_Master (GroupID, ProviderGroupID, GroupType, DepartDate, Provider, ShipID, VGroupCode) 
                    VALUES (@GroupID, @ProviderGroupID, @GroupType, @DepartDate, @Provider, @ShipID, @VGroupCode);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
            
                cn.Open();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn);
                    cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupid;
                    cmd.Parameters.Add("@DepartDate", SqlDbType.DateTime).Value = departDate;
                    cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = groupType;
                    cmd.Parameters.Add("@Provider", SqlDbType.VarChar, 25).Value = provider;
                    cmd.Parameters.Add("@ShipID", SqlDbType.Int).Value = shipID;
                    cmd.Parameters.Add("@ProviderGroupID", SqlDbType.VarChar).Value = providergroupid;
                    cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar).Value = VGroupCode;
                    iReturn = cmd.ExecuteNonQuery();
                }
                catch (Exception ex)
                {
                    ex.Message.ToString();
                }
            }
        }

        //public static string Add(string groupType, DateTime departDate, string provider, int shipID, string providergroupid)
        //{
        //    string groupid = "";
        //    string sSQL = @"SELECT @groupid = dbo.udf_NextGroupID (@grouptype, @departDate); 
        //            IF EXISTS(SELECT 1 FROM dbo.grp_Master WHERE groupid=@groupid) 
        //            BEGIN
        //                SET @groupid = '';
        //                RETURN;
        //            END;
        //            INSERT INTO dbo.grp_Master (GroupID, GroupType, DepartDate, Provider, ShipID) 
        //            VALUES (@GroupID, @GroupType, @DepartDate, @Provider, @ShipID);";
        //    using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
        //    {
        //        cn.Open();
        //        for (int i = 0; i < 5; i++)
        //        {
        //            SqlCommand cmd = new SqlCommand(sSQL, cn);
        //            cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Direction = ParameterDirection.Output;
        //            cmd.Parameters.Add("@DepartDate", SqlDbType.DateTime).Value = departDate;
        //            cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = groupType;
        //            cmd.Parameters.Add("@Provider", SqlDbType.VarChar, 25).Value = provider;
        //            cmd.Parameters.Add("@ShipID", SqlDbType.Int).Value = shipID;
        //            cmd.Parameters.Add("@ProviderGroupID", SqlDbType.VarChar).Value = providergroupid;
        //            cmd.ExecuteNonQuery();
        //            groupid = cmd.Parameters["@GroupID"].Value.ToString();
        //            if (groupid != "")
        //                break;
        //        }
        //    }
        //    if (groupid == "")
        //        throw new ApplicationException("Unable to get next group id. Please try again.");
        //    return groupid;
        //}



        public static void Update(GroupMaster g)
        {
            string sSQL = @"UPDATE dbo.grp_Master SET ProviderGroupID = @ProviderGroupID, Provider = @Provider, GroupAgentFlxID = @GroupAgentFlxID, 
                AffinityAgentFlxID = @AffinityAgentFlxID, AffinityGroupName = @AffinityGroupName, DepartDate = @DepartDate, ReturnDate = @ReturnDate,
                RevType = @RevType, PortCity = @PortCity, Destination = @Destination, ShipID = @ShipID, TourID = @TourID, ItinID = @ItinID, 
                AddDetails = @AddDetails, Berths = @Berths, Deposit = @Deposit, Air_Inc = @Air_Inc, Cancelled = @Cancelled, Recall_1 = @Recall_1,
                Recall_2 = @Recall_2, Recall_3 = @Recall_3, Deposit_2 = @Deposit_2, FinalDue = @FinalDue, GroupType = @GroupType, FinalGrossSales = @FinalGrossSales, 
                Premium = @Premium, FinalComm = @FinalComm, FinalBonusComm = @FinalBonusComm, FinalNetTourConductor = @FinalNetTourConductor, 
                FinalGrossExpense = @FinalGrossExpense, FinalPax = @FinalPax, Date2Accounting = @Date2Accounting, ClosedSales = @ClosedSales, ClosedComm = @ClosedComm, 
                ClosedBonusComm = @ClosedBonusComm, ClosedTourConductor = @ClosedTourConductor, ClosedGrossExpense = @ClosedGrossExpense, ClosedPax = @ClosedPax, 
                DateClosed = @DateClosed, TrvlWrkSheet = @TrvlWrkSheet, CancelDate = @CancelDate, HardStopDate = @HardStopDate, CxlPolicyID = @CxlPolicyID, 
                Premium2 = @Premium2, ClosedTourConUsed = @ClosedTourConUsed, FinalTourConUsed = @FinalTourConUsed, ClosedNotes = @ClosedNotes,
                GroupName = @GroupName, IATA=@IATA, VGroupCode = @VGroupCode, VendorGroupCode2 = @VendorGroupCode2
                WHERE GroupID = @GroupID"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = g.GroupID;
                cmd.Parameters.Add("@ProviderGroupID", SqlDbType.VarChar, 100).Value = g.ProviderGroupID;
                cmd.Parameters.Add("@Provider", SqlDbType.VarChar, 25).Value = g.Provider;
                cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 10).Value = g.VGroupCode;
                cmd.Parameters.Add("@VendorGroupCode2", SqlDbType.VarChar, 25).Value = g.VendorGroupCode2;
                cmd.Parameters.Add("@GroupAgentFlxID", SqlDbType.Int).Value = DBNull.Value;
                if (g.GroupAgentFlxID > 0)
                    cmd.Parameters["@GroupAgentFlxID"].Value = g.GroupAgentFlxID;
                cmd.Parameters.Add("@AffinityAgentFlxID", SqlDbType.Int).Value = DBNull.Value;
                if (g.AffinityAgentFlxID > 0) 
                    cmd.Parameters["@AffinityAgentFlxID"].Value = g.AffinityAgentFlxID;
                cmd.Parameters.Add("@AffinityGroupName", SqlDbType.VarChar, 255).Value = g.AffinityGroupName;
                cmd.Parameters.Add("@DepartDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.DepartDate != "")
                    cmd.Parameters["@DepartDate"].Value = Convert.ToDateTime(g.DepartDate);
                cmd.Parameters.Add("@ReturnDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.ReturnDate != "")
                    cmd.Parameters["@ReturnDate"].Value = Convert.ToDateTime(g.ReturnDate);
                cmd.Parameters.Add("@RevType", SqlDbType.VarChar, 2).Value = g.RevType;
                cmd.Parameters.Add("@PortCity", SqlDbType.VarChar, 5).Value = g.PortCity;
                cmd.Parameters.Add("@Destination", SqlDbType.VarChar, 5).Value = g.Destination;
                cmd.Parameters.Add("@ShipID", SqlDbType.Int).Value = g.ShipID;
                cmd.Parameters.Add("@TourID", SqlDbType.Int).Value = g.TourID;
                cmd.Parameters.Add("@ItinID", SqlDbType.Int).Value = g.ItinID;
                cmd.Parameters.Add("@AddDetails", SqlDbType.VarChar, 255).Value = g.AddDetails;
                cmd.Parameters.Add("@Berths", SqlDbType.Int).Value = g.Berths;
                cmd.Parameters.Add("@Deposit", SqlDbType.Decimal).Value = g.Deposit;
                cmd.Parameters.Add("@Air_Inc", SqlDbType.Bit).Value = g.Air_Inc;
                cmd.Parameters.Add("@Cancelled", SqlDbType.Bit).Value = g.Cancelled;
                cmd.Parameters.Add("@Recall_1", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.Recall_1 != "")
                    cmd.Parameters["@Recall_1"].Value = Convert.ToDateTime(g.Recall_1);
                cmd.Parameters.Add("@Recall_2", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.Recall_2 != "")
                    cmd.Parameters["@Recall_2"].Value = Convert.ToDateTime(g.Recall_2);
                cmd.Parameters.Add("@Recall_3", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.Recall_3 != "")
                    cmd.Parameters["@Recall_3"].Value = Convert.ToDateTime(g.Recall_3);
                cmd.Parameters.Add("@Deposit_2", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.Deposit_2 != "")
                    cmd.Parameters["@Deposit_2"].Value = Convert.ToDateTime(g.Deposit_2);
                cmd.Parameters.Add("@FinalDue", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.FinalDue != "")
                    cmd.Parameters["@FinalDue"].Value = Convert.ToDateTime(g.FinalDue);
                cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = g.GroupType;
                cmd.Parameters.Add("@FinalGrossSales", SqlDbType.Decimal).Value = g.FinalGrossSales;
                cmd.Parameters.Add("@Premium", SqlDbType.Decimal).Value = g.Premium;
                cmd.Parameters.Add("@FinalComm", SqlDbType.Decimal).Value = g.FinalComm;
                cmd.Parameters.Add("@FinalBonusComm", SqlDbType.Decimal).Value = g.FinalBonusComm;
                cmd.Parameters.Add("@FinalNetTourConductor", SqlDbType.Decimal).Value = g.FinalNetTourConductor;
                cmd.Parameters.Add("@FinalGrossExpense", SqlDbType.Decimal).Value = g.FinalGrossExpense;
                cmd.Parameters.Add("@FinalPax", SqlDbType.Int).Value = g.FinalPax;
                cmd.Parameters.Add("@Date2Accounting", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.Date2Accounting != "")
                    cmd.Parameters["@Date2Accounting"].Value = Convert.ToDateTime(g.Date2Accounting);
                cmd.Parameters.Add("@ClosedSales", SqlDbType.Decimal).Value = g.ClosedSales;
                cmd.Parameters.Add("@ClosedComm", SqlDbType.Decimal).Value = g.ClosedComm;
                cmd.Parameters.Add("@ClosedBonusComm", SqlDbType.Decimal).Value = g.ClosedBonusComm;
                cmd.Parameters.Add("@ClosedTourConductor", SqlDbType.Decimal).Value = g.ClosedTourConductor;
                cmd.Parameters.Add("@ClosedGrossExpense", SqlDbType.Decimal).Value = g.ClosedGrossExpense;
                cmd.Parameters.Add("@ClosedPax", SqlDbType.Int).Value = g.ClosedPax;
                cmd.Parameters.Add("@DateClosed", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.DateClosed != "")
                    cmd.Parameters["@DateClosed"].Value = Convert.ToDateTime(g.DateClosed);
                cmd.Parameters.Add("@TrvlWrkSheet", SqlDbType.Bit).Value = g.TrvlWrkSheet;
                cmd.Parameters.Add("@CancelDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.CancelDate != "")
                    cmd.Parameters["@CancelDate"].Value = Convert.ToDateTime(g.CancelDate);
                cmd.Parameters.Add("@HardStopDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.HardStopDate != "")
                    cmd.Parameters["@HardStopDate"].Value = Convert.ToDateTime(g.HardStopDate);
                cmd.Parameters.Add("@CxlPolicyID", SqlDbType.Int).Value = g.CxlPolicyID;
                cmd.Parameters.Add("@Premium2", SqlDbType.Decimal).Value = g.Premium2;
                cmd.Parameters.Add("@ClosedTourConUsed", SqlDbType.Decimal).Value = g.ClosedTourConUsed;
                cmd.Parameters.Add("@FinalTourConUsed", SqlDbType.Decimal).Value = g.FinalTourConUsed;
                cmd.Parameters.Add("@ClosedNotes", SqlDbType.VarChar, 255).Value = g.ClosedNotes;
                cmd.Parameters.Add("@GroupName", SqlDbType.VarChar, 100).Value = g.GroupName;
                cmd.Parameters.Add("@IATA", SqlDbType.VarChar, 8).Value = g.IATA;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateDoNotDisplay(string GroupID)
        {
            string sSQL = @"UPDATE dbo.mt_info SET DoNotDisplay = 1
                WHERE GroupCode = @GroupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 6).Value = GroupID;

                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateInv(string GroupID, bool IsSellOverAlloc, int MaxPassengers, int MinPassengers)
        {
            string sSQL = @"UPDATE dbo.grp_Master SET IsSellOverAlloc=@IsSellOverAlloc, MaxPassengers=@MaxPassengers, MinPassengers=@MinPassengers 
                WHERE GroupID = @GroupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = GroupID;
                cmd.Parameters.Add("@IsSellOverAlloc", SqlDbType.Bit).Value = IsSellOverAlloc;
                cmd.Parameters.Add("@MaxPassengers", SqlDbType.Int).Value = MaxPassengers;
                cmd.Parameters.Add("@MinPassengers", SqlDbType.Int).Value = MinPassengers;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string groupID)
        {
            mtGroup g = mtGroup.GetGroup(groupID);
            if (g != null)
                throw new ApplicationException("Please delete Flyer before deleting group");

            string sSQL = @"DELETE FROM dbo.grp_Master_Notes WHERE groupID = @groupID;
                DELETE FROM dbo.grp_FileMaint WHERE groupID = @groupID;
                DELETE FROM dbo.grp_Option WHERE groupID = @groupID;
                DELETE FROM dbo.grp_Package WHERE groupID = @groupID;
                DELETE FROM dbo.grp_Master WHERE groupID = @groupID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@groupid", SqlDbType.VarChar, 6).Value = groupID;
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


        public static string Duplicate(string origGroupID, DateTime newDepartDate, string providergroupid)
        {
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_DuplicateGroup", cn, trn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@OrigGroupID", SqlDbType.VarChar, 6).Value = origGroupID;
                    cmd.Parameters.Add("@NewDepartDate", SqlDbType.DateTime).Value = newDepartDate;
                    cmd.Parameters.Add("@UserID", SqlDbType.VarChar, 50).Value = Util.CurrentUser();
                    cmd.Parameters.Add("@ProviderGroupID", SqlDbType.VarChar).Value = providergroupid;
                    cmd.Parameters.Add("@NewGroupID", SqlDbType.VarChar, 6).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@ErrorMsg", SqlDbType.VarChar, 255).Direction = ParameterDirection.Output;
                    cmd.ExecuteNonQuery();
                    trn.Commit();
                    string errorMsg = cmd.Parameters["@ErrorMsg"].Value.ToString();
                    if (errorMsg != "")
                        throw new ApplicationException(errorMsg);
                    return cmd.Parameters["@NewGroupID"].Value.ToString();
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


        //public static DataTable GetPagedList(string departfr, string departto, int grouptype, string revtype, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        public static DataTable GetPagedList(DateTime departfr, DateTime departto, int grouptype, string revtype, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            if (departfr == DateTime.MinValue)
            {
                departfr = Convert.ToDateTime("1900-01-01");
            }
            if (departto == DateTime.MinValue)
            {
                departto = Convert.ToDateTime("1900-01-01");
            }
            string fields = @" m.DepartDate, m.ReturnDate, m.GroupID, p.PickDesc as GroupTypeDesc, p2.PickDesc as RevTypeDesc,  
	            pc.PortCityName as PortCityDesc, dc.Name2 as DestinationDesc, ga.Agent as GroupAgentName, aa.Agent as AffinityAgentName, 
	            it.Itinerary, s.ShipName,  
                pr.vendorName as ProvName, 
                m.GroupName, m.Cancelled, m.IATA, gt.GroupType as GType, gs.NewStatus ";
            string filter = string.Format(" (m.departdate >= '{0}' ", departfr);
            string tables = @" dbo.grp_Master m 
                LEFT JOIN dbo.grp_PickList p on p.PickType = 'GROUPTYPE' AND p.PickCode = m.GroupType
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = m.RevType
                LEFT JOIN dbo.vw_Employee ga on ga.FlxID = m.GroupAgentFlxID
                LEFT JOIN dbo.vw_Employee aa on aa.FlxID = m.AffinityAgentFlxID
                LEFT JOIN dbo.vw_PortCity pc on pc.PortCity = m.PortCity
                LEFT JOIN dbo.vw_Location dc on dc.locode = m.Destination
                LEFT JOIN dbo.grp_ItinID it on it.ItinID = m.ItinID
                LEFT JOIN dbo.grp_ShipID s on s.ShipID = m.ShipID
                Left JOIN dbo.grp_GroupType gt on m.GroupType = gt.PickCode
                 LEFT JOIN dbo.mt_vendor pr on pr.vendorCode = m.Provider 
                LEFT JOIN dbo.vw_grp_Status gs on m.GroupID = gs.GroupID ";
            if (sortExpression == "")
                sortExpression = "m.GroupID";
            
            if (departto != DateTime.MinValue && departto > departfr)
                filter += string.Format(" AND m.ReturnDate <= '{0}' ", departto);
            if (grouptype > 0)
                filter += string.Format(" AND m.grouptype = {0} ", grouptype);
            if (!String.IsNullOrEmpty(revtype))
                filter += string.Format(" AND m.revtype = '{0}' ", revtype);
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( pc.PortCityName like '%{0}%' or dc.Name2 like '%{0}%' or ga.Agent like '%{0}%' or 
                    aa.Agent like '%{0}%' or it.Itinerary like '%{0}%' or s.ShipName like '%{0}%' or pr.vendorName like '%{0}%' or 
                    m.AffinityGroupName like '%{0}%' or m.ProviderGroupID like '%{0}%' or m.GroupName like '%{0}%') ", searchstr);
            }
            filter += " ) ";
            if (!String.IsNullOrEmpty(searchstr))
                filter += string.Format(" OR m.groupid = '{0}' ", searchstr); 
            string ssql = "SELECT * FROM " +
                " (SELECT " + fields + ", ROW_NUMBER() OVER (ORDER BY " + sortExpression + ") as RowNum " +
                " FROM " + tables + "WHERE " + filter + ") as List " +
                " WHERE RowNum BETWEEN " + startRowIndex + " AND " + (startRowIndex + maximumRows - 1);
            string cntSql = "Select count(*) from " + tables + " where " + filter;
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(ssql, cn);
                da.Fill(ds);
                SqlCommand cmd = new SqlCommand(cntSql, cn);
                int rowCount = (int)cmd.ExecuteScalar();
                System.Web.HttpContext.Current.Items["rowCount"] = rowCount.ToString();
                return ds.Tables[0];
            }
        }

        public static int GetPagedCount(DateTime departfr, DateTime departto, int grouptype, string revtype, string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static int GetPagedCount()
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }


        /* Notes */
        public static DataTable GetNotesList(string groupId)
        {
            string sSQL = @"SELECT Notes, NoteDate, NoteBy, NoteID  FROM dbo.grp_Master_Notes 
                WHERE GroupId = @GroupID
                ORDER BY NoteDate DESC, NoteID Desc";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@groupid", SqlDbType.VarChar, 10).Value = groupId;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void AddNotes(string groupID, string notes)
        {
            string sSQL = @"INSERT INTO dbo.grp_Master_notes (GroupID, Notes, NoteBy) VALUES (@GroupID, @Notes, @NoteBy);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                cmd.Parameters.Add("@Notes", SqlDbType.Text).Value = notes;
                cmd.Parameters.Add("@NoteBy", SqlDbType.VarChar).Value = Util.CurrentUser();
                cmd.ExecuteNonQuery();
            }
        }

        public static void DeleteNotes(int noteid, string groupID)
        {
            if (groupID != null)
            {
                string sSQL = @"Delete from grp_Master_Notes where NoteID = @NoteID and GroupID = @GroupID;";
                using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
                {
                    cn.Open();
                    SqlCommand cmd = new SqlCommand(sSQL, cn);
                    cmd.Parameters.Add("@NoteID", SqlDbType.Int).Value = noteid;
                    cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                    cmd.ExecuteNonQuery();
                }
            }
        }
        public static void UpdateNotes(string groupID, string notes, int noteid)
        {
            if (groupID != null)
            {
                string sSQL = @"update grp_Master_Notes set Notes = @Notes, NoteBy = @NoteBy where GroupID = @GroupID and NoteID = @NoteID;";
                using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
                {
                    cn.Open();
                    SqlCommand cmd = new SqlCommand(sSQL, cn);
                    cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                    cmd.Parameters.Add("@Notes", SqlDbType.Text).Value = notes;
                    cmd.Parameters.Add("@NoteID", SqlDbType.Int).Value = noteid;
                    cmd.Parameters.Add("@NoteBy", SqlDbType.VarChar).Value = Util.CurrentUser();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        /* File Maintenance */

        public static void CreateFileMaintCheckList(string groupID)
        {
            string sSQL = @"INSERT INTO dbo.grp_FileMaint (GroupID,TaskID) 
                SELECT distinct @GroupID, tl.TaskID
                FROM dbo.grp_TaskReport tr 
                INNER JOIN dbo.grp_TaskList tl ON tr.TaskID = tl.TaskID 
                LEFT JOIN dbo.grp_FileMaint (nolock) tm on tm.GroupID = @GroupID AND tm.TaskID = tl.TaskID
                WHERE tr.ReportType = @ReportType
                AND tm.TaskID IS NULL;";
            GroupMaster g = GetGroupMaster(groupID);
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = g.ReportType;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetTaskList(string groupID, int taskType)
        {
            string sSQL = @"SELECT fm.FMaintID, fm.groupid, fm.TaskID, fm.DateComplete, fm.CompleteBy, tl.Task, tt.tasktype 
                FROM dbo.grp_FileMaint fm 
                INNER JOIN dbo.grp_TaskList tl ON fm.TaskID = tl.TaskID 
                INNER JOIN dbo.grp_TaskReport tr ON tl.TaskID = tr.TaskID AND tr.ReportType = @ReportType
                INNER JOIN dbo.grp_TaskType tt ON tr.TaskType = tt.TaskType 
                WHERE fm.GroupID = @GroupID
                AND tr.TaskType = @TaskType 
                ORDER BY tt.tasktypeorder, tr.RptOrder;";
            GroupMaster g = GetGroupMaster(groupID);
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@groupid", SqlDbType.VarChar, 6).Value = groupID;
                da.SelectCommand.Parameters.Add("@ReportType", SqlDbType.Int).Value = g.ReportType;
                da.SelectCommand.Parameters.Add("@TaskType", SqlDbType.Int).Value = taskType;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void UpdateTask(string groupID, int taskID, string dateComplete)
        {
            string sSQL = @"UPDATE dbo.grp_FileMaint SET DateComplete = @DateComplete, CompleteBy =  @CompleteBy 
                WHERE GroupID = @GroupID AND TaskID = @TaskID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = taskID;
                cmd.Parameters.Add("@DateComplete", SqlDbType.DateTime).Value = DBNull.Value;
                if (Util.isValidDate(dateComplete))
                    cmd.Parameters["@DateComplete"].Value = dateComplete;
                cmd.Parameters.Add("@CompleteBy", SqlDbType.VarChar).Value = Util.CurrentUser();
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdatePolicyID(string groupID, int cxlPolicyID)
        {
            string sSQL = @"UPDATE dbo.grp_Master SET CxlPolicyID = @CxlPolicyID WHERE GroupID = @GroupID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = groupID;
                cmd.Parameters.Add("@CxlPolicyID", SqlDbType.Int).Value = DBNull.Value;
                if (cxlPolicyID > 0)
                    cmd.Parameters["@CxlPolicyID"].Value = cxlPolicyID;
                cmd.ExecuteNonQuery();
            }
        }

        /* Misc */
        public static List<string> GetGroupIDList(DateTime departDate, string groupType, string provider, int shipID)
        {
            string sSQL = @"SELECT GroupID FROM dbo.grp_Master
                WHERE Departdate = @DepartDate 
                AND GroupType = @GroupType 
                AND (@Provider = '' OR Provider = @Provider)
                AND (@ShipID = 0 OR ShipID = @ShipID)
                ORDER BY GroupID";
            List<string> list = new List<string>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@DepartDate", SqlDbType.DateTime).Value = departDate;
                cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = groupType;
                cmd.Parameters.Add("@Provider", SqlDbType.VarChar).Value = provider;
                cmd.Parameters.Add("@ShipID", SqlDbType.Int).Value = shipID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                    list.Add(rs["GroupID"].ToString());
            }
            return list;
        }
        public static DataTable GetTaskType()
        {
            string sSQL = @"select TaskType, TaskName, TaskTypeOrder from grp_TaskType ORDER BY TaskTypeOrder, TaskName;";
           
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }
        public static int RowsCountTaskType(int TaskType)
        {
            string sSQL = @"select count(*)
                            from grp_TaskType tt
                            inner join grp_TaskReport tr on tt.TaskType = tr.TaskType
                            where tt.TaskType = @TaskType";
            int count = 0;
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sSQL, cn))
                {

                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                    cn.Open();
                    count = int.Parse(cmd.ExecuteScalar().ToString());
                }

                return count;
            }
        }
        public static int DeleteTaskType(int TaskType)
        {
            int iReturn = 0;
            string sSQL = @"DELETE tt FROM grp_TaskType tt
                            LEFT JOIN grp_TaskReport tr ON tt.TaskType = tr.TaskType 
                            WHERE tr.TaskType IS NULL
	                        and tt.TaskType = @TaskType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                iReturn = cmd.ExecuteNonQuery();
            }

            return iReturn;
        }

        public static int AddTypes(string TaskName, int TaskTypeOrder)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_TaskType (TaskName, TaskTypeOrder) VALUES (@TaskName, @TaskTypeOrder);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskName", SqlDbType.VarChar, 50).Value = TaskName;
                cmd.Parameters.Add("@TaskTypeOrder", SqlDbType.Int).Value = TaskTypeOrder;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void UpdateTypesSort(int TaskType, int TaskTypeOrder)
        {
            string sSQL = @"Update grp_TaskType Set TaskTypeOrder = @TaskTypeOrder where TaskType = @TaskType";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                cmd.Parameters.Add("@TaskTypeOrder", SqlDbType.Int).Value = TaskTypeOrder;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateTaskType(int TaskType, string TaskName, int TaskTypeOrder)
        {
            string sSQL = @"Update grp_TaskType Set TaskName = @TaskName, TaskTypeOrder = @TaskTypeOrder WHERE TaskType = @TaskType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                cmd.Parameters.Add("@TaskName", SqlDbType.VarChar, 50).Value = TaskName;
                cmd.Parameters.Add("@TaskTypeOrder", SqlDbType.Int).Value = TaskTypeOrder;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetReportsList()
        {
            //string sSQL = @"select ReportType, ReportName from grp_Reports ORDER BY ReportName;";
            string sSQL = @"select g.PickCode as ReportType, p.PickDesc as ReportName from grp_GroupType g inner join grp_PickList p on g.PickCode = p.PickCode where p.StatusVisible = 'YES';";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }
        //--------------------------------REMOVE
        public static int AddReport(string ReportName)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_Reports (ReportName) VALUES (@ReportName);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportName", SqlDbType.VarChar, 50).Value = ReportName;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }
        //--------------------------------REMOVE
        public static int DeleteReport(int ReportType)
        {
            int iReturn = 0;
            string sSQL = @"DELETE r
                            FROM grp_Reports r
                              LEFT JOIN grp_TaskReport tr ON r.ReportType = tr.ReportType
                                  WHERE tr.ReportType IS NULL
                               and r.ReportType = @ReportType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                iReturn = cmd.ExecuteNonQuery();
            }

            return iReturn;
        }
        //--------------------------------REMOVE
        public static void UpdateReport(int ReportType, string ReportName)
        {
            string sSQL = @"Update grp_Reports Set ReportName = @ReportName WHERE ReportType = @ReportType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@ReportName", SqlDbType.VarChar, 50).Value = ReportName;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetTask()
        {
            string sSQL = @"select TaskID, Task from grp_TaskList ORDER BY Task;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int AddTask(string Task)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_TaskList (Task) VALUES (@Task);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Task", SqlDbType.VarChar, 100).Value = Task;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void UpdateTask(int TaskID, string Task)
        {
            string sSQL = @"Update dbo.grp_TaskList Set Task = @Task WHERE TaskID = @TaskID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                cmd.Parameters.Add("@Task", SqlDbType.VarChar, 100).Value = Task;
                cmd.ExecuteNonQuery();
            }
        }

        public static int RowsCountTask(int TaskID)
        {
            string sSQL = @"select count(*)
                            from grp_TaskList tl
                            inner join grp_TaskReport tr on tl.TaskID = tr.TaskID
                            where tl.TaskID = @TaskID";
            int count = 0;
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sSQL, cn))
                {

                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                    cn.Open();
                    count = int.Parse(cmd.ExecuteScalar().ToString());
                }

                return count;
            }
        }

        public static int DeleteTask(int TaskID)
        {
            int iReturn = 0;
            string sSQL = @"DELETE tl
                            FROM grp_TaskList tl
                            LEFT JOIN grp_TaskReport tr ON tl.TaskID = tr.TaskID
                            WHERE tr.TaskID IS NULL 
                            and tl.TaskID = @TaskID;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                try
                {
                    iReturn = cmd.ExecuteNonQuery();
                }
                catch (SqlException ex)
                {
                    string msg = ex.Message;
                }
            }

            return iReturn;
        }

        public static DataTable GetReportTypesTasksList(int ReportType, int TaskType)
        {
            string sSQL = @"select tr.ReportID, p.PickCode as ReportType, p.PickDesc as ReportName, tt.TaskType, tt.TaskName, tl.TaskID, tl.Task, tr.RptOrder
                            from grp_TaskList tl 
                            left outer join grp_TaskReport tr on tr.TaskID = tl.TaskID
                            left outer join grp_PickList p on tr.ReportType = Convert(int, p.PickCode)
                            left outer join grp_TaskType tt on tr.TaskType = tt.TaskType
                            where Convert(int,p.PickCode) = @ReportType
                            and p.PickType = 'GROUPTYPE'
                            and p.StatusVisible = 'YES'
                            and tt.TaskType = @TaskType
                            order by tr.RptOrder;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static DataTable GetReportTypesTasksList2(int ReportType, int TaskType)
        {
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();

                SqlCommand cmd = new SqlCommand("uspws_getTypesReportsTasks", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static int AddTaskTypeReport(int TaskID, int ReportType, int TaskType, int RptOrder)
        {
            int iReturn = 0;
            string sSQL = @"Insert into grp_TaskReport (TaskID, ReportType, TaskType, RptOrder) Values (@TaskID, @ReportType, @TaskType, @RptOrder);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@RptOrder", SqlDbType.Int).Value = RptOrder;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void UpdateTaskTypeReport(int TaskID, int ReportType, int TaskType, int RptOrder)
        {
            string sSQL = @"Update grp_TaskReport Set RptOrder = @RptOrder WHERE TaskID = @TaskID and TaskType = @TaskType and ReportType = @ReportType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@RptOrder", SqlDbType.Int).Value = RptOrder;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetTaskTypeReportSort(int ReportType, int TaskType)
        {
            string sSQL = @"select tr.ReportID, tl.Task, tr.RptOrder from grp_TaskReport tr 
                            inner join grp_PickList p on tr.ReportType = Convert(int, p.PickCode)
                            inner join grp_tasktype tt on tr.TaskType = tt.TaskType 
                            inner join grp_taskList tl on tr.TaskID = tl.TaskID 
                            where Convert(int,p.PickCode) = @ReportType
                            and p.PickType = 'GROUPTYPE'
                            and p.StatusVisible = 'YES'
                            and tt.TaskType = @TaskType
                            order by tr.RptOrder;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static void UpdateTaskTypeReportSort(int ReportID, int RptOrder)
        {
            string sSQL = @"Update grp_TaskReport Set RptOrder = @RptOrder where ReportID = @ReportID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ReportID", SqlDbType.Int).Value = ReportID;
                cmd.Parameters.Add("@RptOrder", SqlDbType.Int).Value = RptOrder;
                cmd.ExecuteNonQuery();
            }
        }

        public static int RowsCountTaskTypeReport(int TaskID, int ReportType, int TaskType)
        {
            string sSQL = @"select count(*)
                            from grp_TaskReport tr
                            inner join grp_FileMaint fm on tr.TaskID = fm.TaskID
                            where tr.TaskId = @TaskID
                            and tr.ReportType = @ReportType
                            and tr.TaskType = @TaskType";
            int count = 0;
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(sSQL, cn))
                {
                    
                    cmd.CommandType = CommandType.Text;
                    cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                    cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                    cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                    cn.Open();
                    var iCount = int.Parse(cmd.ExecuteScalar().ToString());
                    count = iCount;
                }
                    
                return count; 
            }
        }
        

        public static int DeleteTaskTypeReport(int TaskID, int ReportType, int TaskType)
        {
            int iReturn = 0;
            string sSQL = @"delete from grp_TaskReport
                            where TaskId = @TaskID
                            and ReportType = @ReportType
                            and TaskType = @TaskType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TaskID", SqlDbType.Int).Value = TaskID;
                cmd.Parameters.Add("@TaskType", SqlDbType.Int).Value = TaskType;
                cmd.Parameters.Add("@ReportType", SqlDbType.Int).Value = ReportType;
                iReturn = cmd.ExecuteNonQuery();
            }
            return iReturn;
        }

        public static DataTable GetGroupList(string PickType, string StatusVisible)
        {
            //string sSQL = @"SELECT * FROM dbo.grp_PickList WHERE PickType = 'GROUPTYPE' and StatusVisible = 'YES' order by sort, pickdesc";
            //string sSQL = @"SELECT * FROM dbo.grp_PickList WHERE PickType = @PickType and StatusVisible = @StatusVisible order by sort, pickdesc";
            string sSQL = @"SELECT Distinct p.RID, p.PickCode, p.PickDesc, p.Sort, p.StatusVisible, g.GroupDesc
                        FROM dbo.grp_PickList p
                        inner join grp_GroupType g on p.PickCode = g.PickCOde
                        WHERE p.PickType = @PickType and p.StatusVisible = @StatusVisible order by p.sort, p.pickdesc;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@StatusVisible", SqlDbType.VarChar, 10).Value = StatusVisible;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static int AddGroupType(string PickType, string PickDesc, string StatusVisible, int RowCount)
        {
            int iReturn = 0;
            string sSQL = @"Insert into grp_PickList (PickType, PickCode, PickDesc, Sort, StatusVisible)
                            values (@PickType, @RowCount, @PickDesc, 
                            (select max(Sort)+1 from grp_PickList where PickType='GROUPTYPE'), @StatusVisible);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@PickDesc", SqlDbType.VarChar, 50).Value = PickDesc;
                cmd.Parameters.Add("@StatusVisible", SqlDbType.VarChar, 10).Value = StatusVisible;
                cmd.Parameters.Add("@RowCount", SqlDbType.Int).Value = RowCount;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static int RowsCount(string sPickType)
        {
            int count = 0;
            string sSQL = "select Count(*) from grp_PickList where PickType = @PickType";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                using (SqlCommand cmdCount = new SqlCommand(sSQL, cn))
                {
                    cn.Open();
                    cmdCount.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = sPickType;
                    //count = (int)cmdCount.ExecuteScalar();
                    count = Convert.ToInt32(cmdCount.ExecuteScalar());
                }
                return count;
            } 
        }

        public static int AddGroupTypeAffinity(int GroupType, string GroupDesc, int RowCount)
        {
            int iReturn = 0;
            string sSQL = @"Insert into grp_GroupType (GroupType, PickCode, GroupDesc)
                            values (@GroupType, @RowCount, @GroupDesc);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupType", SqlDbType.Int).Value = GroupType;
                cmd.Parameters.Add("@GroupDesc", SqlDbType.VarChar, 50).Value = GroupDesc;
                cmd.Parameters.Add("@RowCount", SqlDbType.Int).Value = RowCount;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void UpdateGroupType(int RID, string PickType, string PickCode, string PickDesc)
        {
            string sSQL = @"Update grp_PickList Set PickDesc = @PickDesc WHERE RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@PickCode", SqlDbType.VarChar, 10).Value = PickCode;
                cmd.Parameters.Add("@PickDesc", SqlDbType.VarChar, 50).Value = PickDesc;
                cmd.ExecuteNonQuery();
            }
        }

        //Not needed anymore
        public static void UpdateGroupType1(int RID, string PickType, string PickCode, string PickDesc)
        {
            string sSQL = @"Update grp_PickList Set PickDesc = @PickDesc WHERE RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@PickCode", SqlDbType.VarChar, 10).Value = PickCode;
                cmd.Parameters.Add("@PickDesc", SqlDbType.VarChar, 50).Value = PickDesc;
                //cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateGroupTypeList(int RID, string PickType, string PickDesc)
        {
            string sSQL = @"Update grp_PickList Set PickDesc = @PickDesc WHERE RID = @RID and PickType = @PickType;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@PickDesc", SqlDbType.VarChar, 50).Value = PickDesc;
                cmd.ExecuteNonQuery();
            }
        }

        public static void DeleteGroupType(string PickType, string PickCode, int RID, string PickDesc)
        {
            string sSQL = @"Update grp_PickList Set StatusVisible = 'NO' WHERE PickType = @PickType and PickCode = @PickCode and RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@PickCode", SqlDbType.VarChar, 10).Value = PickCode;
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;

                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetGroupTypeSort(string PickType, string StatusVisible)
        {
            string sSQL = @"SELECT * FROM dbo.grp_PickList WHERE PickType = @PickType and StatusVisible = @StatusVisible order by sort, pickdesc;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.Parameters.Add("@StatusVisible", SqlDbType.VarChar, 10).Value = StatusVisible;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static void UpdatetGroupTypeSort(string PickCode, int Sort, string PickType)
        {
            string sSQL = @"Update grp_PickList Set Sort = @Sort where PickType = @PickType and PickCode = @PickCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Sort", SqlDbType.Int).Value = Sort;
                cmd.Parameters.Add("@PickCode", SqlDbType.VarChar, 10).Value = PickCode;
                cmd.Parameters.Add("@PickType", SqlDbType.VarChar, 10).Value = PickType;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetInstructions(string InstructionType)
        {
            string sSQL = @"select RID, InstructionType, InstructionCode, InstructionSort from [dbo].[mt_Instructions] 
                            where InstructionType = @InstructionType
                            ORDER BY InstructionSort;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@InstructionType", SqlDbType.VarChar, 100).Value = InstructionType;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static void UpdatetInstruction(int RID, string InstructionCode)
        {
            string sSQL = @"update [dbo].[mt_Instructions]
                        set InstructionCode = @InstructionCode
                        where RID = @RID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@InstructionCode", SqlDbType.VarChar, 500).Value = InstructionCode;
                cmd.ExecuteNonQuery();
            }
        }

        public static int AddInstruction(string InstructionType, string InstructionCode, int InstructionSort)
        {
            int iReturn = 0;
            string sSQL = @"insert into [dbo].[mt_Instructions] (InstructionType, InstructionCode, InstructionSort) 
                                        values (@InstructionType, @InstructionCode, @InstructionSort);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@InstructionType", SqlDbType.VarChar, 100).Value = InstructionType;
                cmd.Parameters.Add("@InstructionCode", SqlDbType.VarChar, 500).Value = InstructionCode;
                cmd.Parameters.Add("@InstructionSort", SqlDbType.Int).Value = InstructionSort;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static int DeleteInstruction(int RID)
        {
            int iReturn = 0;
            string sSQL = @"delete from [dbo].[mt_Instructions] where RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                iReturn = cmd.ExecuteNonQuery();
            }
            return iReturn;
        }

        public static void UpdateInstructionSort(int RID, int InstructionSort)
        {
            string sSQL = @"Update [dbo].[mt_Instructions] Set InstructionSort = @InstructionSort where RID = @RID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@InstructionSort", SqlDbType.Int).Value = InstructionSort;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetInstructionSort(string InstructionType)
        {
            string sSQL = @"SELECT * FROM [dbo].[mt_Instructions] WHERE InstructionType = @InstructionType order by InstructionSort, InstructionCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@InstructionType", SqlDbType.VarChar, 100).Value = InstructionType;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static string GetAffinityLocationByFlxID(int flxid)
        {
            string sSQL = @"select location from cmn_Agent where flxid = @flxid;";
            string sDepartment = "";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flxid", SqlDbType.BigInt).Value = flxid;
                try
                {
                    cn.Open();
                    sDepartment = Convert.ToString(cmd.ExecuteScalar());
                }
                catch (Exception ex)
                {
                    throw ex;
                }

                return sDepartment;
            }
        }

        public static string GetAffinityIATA(int flxid)
        {
            string sSQL = @"select IATA from cmn_Agent where flxid = @flxid;";
            string sIATA = "";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flxid", SqlDbType.BigInt).Value = flxid;
                try
                {
                    cn.Open();
                    sIATA = Convert.ToString(cmd.ExecuteScalar());
                }
                catch (Exception ex)
                {
                    throw ex;
                }

                return sIATA;
            }
        }

        public static string GetAffinityLocationByName(string name)
        {
            string sSQL = @"select location from cmn_Agent where name = @name;";
            string sDepartment = "";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@name", SqlDbType.VarChar).Value = name;
                try
                {
                    cn.Open();
                    sDepartment = Convert.ToString(cmd.ExecuteScalar());
                }
                catch (Exception ex)
                {
                    throw ex;
                }

                return sDepartment;
            }
        }

        public static DataTable GetTheme()
        {
            string sSQL = @"SELECT t.TourID, t.TourName , count(m.TourID) as GroupsCounter
                            FROM dbo.grp_TourID t 
                            Left JOIN dbo.grp_Master m (NOLOCK) ON t.TourID = m.TourID 
                            Group by t.TourName, t.TourID
                            ORDER BY t.TourName;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int AddTheme(string TourName)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_TourID (TourName) VALUES (@TourName);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TourName", SqlDbType.VarChar, 100).Value = TourName;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void UpdateTheme(int TourID, string TourName)
        {
            string sSQL = @"Update dbo.grp_TourID Set TourName = @TourName WHERE TourID = @TourID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TourID", SqlDbType.Int).Value = TourID;
                cmd.Parameters.Add("@TourName", SqlDbType.VarChar, 100).Value = TourName;
                cmd.ExecuteNonQuery();
            }
        }

        public static void DeleteTheme(int TourID)
        {
            string sSQL = @"delete from [dbo].[grp_TourID] where TourID = @TourID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@TourID", SqlDbType.Int).Value = TourID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetGroupCode()
        {
            string sSQL = @"SELECT RID, VGroupCode, VGroupDescription
                            FROM grp_VGroupCode
                            Group by VGroupCode, VGroupDescription, RID;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int AddVGroupCode(string VGroupCode, string VGroupDescription)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_VGroupCode (VGroupCode, VGroupDescription) VALUES (@VGroupCode, @VGroupDescription);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 100).Value = VGroupCode;
                cmd.Parameters.Add("@VGroupDescription", SqlDbType.VarChar, 250).Value = VGroupDescription;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void DeleteVGroupCode(int RID)
        {
            string sSQL = @"delete from [dbo].[grp_VGroupCode] where RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateVGroupCode(int RID, string VGroupCode, string VGroupDescription)
        {
            string sSQL = @"Update dbo.grp_VGroupCode Set VGroupCode = @VGroupCode, VGroupDescription = @VGroupDescription WHERE RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 100).Value = VGroupCode;
                cmd.Parameters.Add("@VGroupDescription", SqlDbType.VarChar, 250).Value = VGroupDescription;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetBookingQuantity(string GroupID, int BookingID)
        {
            string sSQL = @"select b.BookingID, b.PackageID, p.PackageCd, p.Quantity - p.Sold as Available
                            from grp_Bill b
                            inner join vw_grp_Package p on b.PackageID = p.PackageID
                            where p.GroupID = @GroupID
                            and b.BookingID = @BookingID
                            group by b.BookingID, b.PackageID, p.PackageCd, p.Quantity, p.Sold;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = GroupID;
                cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = BookingID;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static DataTable GetIATAList()
        {
            string sSQL = @"select Distinct Location, IATA
                            from cmn_Agent
                            Group by Location, IATA
                            Order by Location";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void UpdateIATAList(string Location, string IATA)
        {
            string sSQL = @"Update cmn_Agent Set IATA = @IATA WHERE Location = @Location;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Location", SqlDbType.VarChar, 255).Value = Location;
                cmd.Parameters.Add("@IATA", SqlDbType.VarChar, 8).Value = IATA;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetDescCode()
        {
            string sSQL = @"SELECT RID, DescCode, Description
                            FROM grp_Description
                            Group by DescCode, Description, RID;";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int AddDescCode(string DescCode, string Description)
        {
            int iReturn = 0;
            string sSQL = @"INSERT INTO dbo.grp_Description (DescCode, Description) VALUES (@DescCode, @Description);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@DescCode", SqlDbType.VarChar, 50).Value = DescCode;
                cmd.Parameters.Add("@Description", SqlDbType.VarChar, 100).Value = Description;
                iReturn = cmd.ExecuteNonQuery();

                return iReturn;
            }
        }

        public static void DeleteDescCode(int RID)
        {
            string sSQL = @"delete from dbo.grp_Description where RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateDescCode(int RID, string DescCode, string Description)
        {
            string sSQL = @"Update dbo.grp_Description Set DescCode = @DescCode, Description = @Description WHERE RID = @RID;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@RID", SqlDbType.Int).Value = RID;
                cmd.Parameters.Add("@DescCode", SqlDbType.VarChar, 50).Value = DescCode;
                cmd.Parameters.Add("@Description", SqlDbType.VarChar, 100).Value = Description;
                cmd.ExecuteNonQuery();
            }
        }
    }
}