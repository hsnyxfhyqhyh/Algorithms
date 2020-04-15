using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtGroupCategory
    {
        private int _categoryid;
        private string _category;
        private string _des;
        private decimal _sng;
        private decimal _dbl;
        private decimal _commissionSng;
        private decimal _commissionDbl;
        //private decimal _commissionTRPL;
        //private decimal _commissionQUAD;

        public int categoryid { get { return _categoryid; } }
        public string category { get { return _category; } }
        public string des { get { return _des; } }
        public decimal sng { get { return _sng; } }
        public decimal dbl { get { return _dbl; } }
        public decimal commissionSng { get { return _commissionSng; } }
        public decimal commissionDbl { get { return _commissionDbl; } }
        //public decimal commissionTRPL { get { return _commissionTRPL; } }
        //public decimal commissionQUAD { get { return _commissionQUAD; } }

        public mtGroupCategory(int categoryid, string category, string des, decimal sng, decimal dbl, decimal commissionSng, decimal commissionDbl)
        {
            this._categoryid = categoryid;
            this._category = category;
            this._des = des;
            this._sng = sng;
            this._dbl = dbl;
            this._commissionSng = commissionSng;
            this._commissionDbl = commissionDbl;
            //this._commissionTRPL = commissionTRPL;
            //this._commissionQUAD = commissionQUAD;
        }
    }

    public class mtItinerary
    {
        private int _itineraryid;
        private string _itinerary;
        private string _date;
        private string _detail;

        public int itineraryid { get { return _itineraryid; } }
        public string itinerary { get { return _itinerary; } }
        public string date { get { return _date; } }
        public string detail { get { return _detail; } }

        public mtItinerary(int itineraryid, string itinerary, string date, string detail)
        {
            this._itineraryid = itineraryid;
            this._itinerary = itinerary;
            this._date = date;
            this._detail = detail;
        }
    }

    public class mtCancelPolicy
    {
        private int _cancpolicyid;
        private string _policy;
        private string _dateFr;
        private string _dateTo;
        private string _days;

        public int cancpolicyid { get { return _cancpolicyid; } }
        public string policy { get { return _policy; } }
        public string dateFr { get { return _dateFr; } }
        public string dateTo { get { return _dateTo; } }
        public string days { get { return _days; } }

        public mtCancelPolicy(int cancpolicyid, string policy, string dateFr, string dateTo, string days)
        {
            this._cancpolicyid = cancpolicyid;
            this._policy = policy;
            this._dateFr = dateFr;
            this._dateTo = dateTo;
            this._days = days;
        }
    }

    public class mtGroupBanner
    {
        private int _bannerID;
        private string _bannerPosition;

        public int bannerID { get { return _bannerID; } }
        public string bannerPosition { get { return _bannerPosition; } }

        public mtGroupBanner(int bannerID, string bannerPosition)
        {
            this._bannerID = bannerID;
            this._bannerPosition = bannerPosition;
        }
    }

    public class mtGroup
    {

        public string PackageType = "";
        public bool DoNotDisplay = false;
        public bool ATI = false;
        public string ATI_Promo = "";
        public string Template = "";
        public bool SpecialtyGroup = false;
        public bool SpecialInterests =  false;
        public bool Affinity = false;
        public string AgentName = "";
        public string GroupCode = "";
        public string ProductCode = "";
        public string Heading = "";
        public string ScriptHeader = "";
        public string TourName = "";
        public int ShipCode = 0;
        public string VendorCode = "";
        public string VGroupCode = "";
        public string VendorGroupCode2 = "";

        public string VendorGroupCode = "";
        public string VendorGroupNumber = "";
        public string VGroupDescription = "";
        public string VendorName2 = "";
        public int RegionCode = 0;
        public int DestinationCode = 0;
        public string CityCode = "";
        public int DeparturePoint = 0;
        public int Description = 0;
        public string DepartureDate = "";
        public string ReturnDate = "";
        public decimal StartingRates = 0;
        public bool HideRates = false;
        public decimal SingleRate = 0;
        public decimal DoubleRate = 0;
        public decimal TripleRate = 0;
        public decimal QuadRate = 0;
        public string TrplQuad = "";
        public decimal TrplQuadRate = 0;
        public string TrplQuadComments = "";
        public decimal PortCharges = 0;
        public string PortChargesIncluded = "";
        public decimal GovtFees = 0;
        public string GovtFeesIncluded = "";
        public decimal Taxes = 0;
        public string TaxesIncluded = "";
        public decimal Miscellaneous = 0;
        public string MiscComments = "";
        public string MiscIncluded = "";
        public string DepositAmount = "";
        public int DepUnit = 0;
        public string FinalPmtDate = "";
        public int FinalPmtDays = 0;
        public string FirstDepositDate = "";
        public string SecondDepositDate = "";
        public string RecallDate = "";
        public int RecallDays = 0;
        public string ProcessDeposit = "";
        public string ProcessDepositOther = "";
        public string ProcessPayment = "";
        public string ProcessPaymentOther = "";
        public string SpecialFeatures = "";
        public string AdditionalNotes = "";
        public string CustomAir = "";
        public decimal CustomAirAmount = 0;
        public string SuggestCustomAir = "";
        public string TravelInsurance = "";
        public string Disclaimer = "";
        public string FlyerDisclaimer = "";
        public string CallToAction = "";
        public string Pre = "";
        public decimal PreAmount = 0;
        public string Post = "";
        public decimal PostAmount = 0;
        public string RequiredPass = "";
        public string Script331 = "";
        public string AgentNotes = "";
        public string DocReq = "";
        public string Visa = "";
        public string Innoculation = "";
        public string DocOther = "";
        public string MotorCoach = "";
        public string ContactInstr = "";
        public string ContactInstrOther = "";
        public string IATAInstr = "";
        public string IATAInstrOther = "";
        public string PhoneInstr = "";
        public string PhoneInstrOther = "";
        public string AddlInstr = "";
        public string AddlInstrOther = "";
        public string AddAir = "";
        public string TransfersIncluded = "";
        public string TransfersCost = "";
        public string CreateDate = "";
        public string PrintVersion = "";
        public string SellingTip = "";
        public string Status = "";
        public string RejectReason = "";
        public DateTime Created;
        public string CreatedBy = "";
        public string LastEdited = "";
        public string LastEditedBy = "";
        // descriptions
        public string ShipName = "";
        public string RegionDescription = "";
        public string TypeDescription = "";
        public string VendorName = "";
        public string DeparturePointName = ""; 
        public string DestinationDescription = "";
        public string DescriptionTitle = "";
        public string DescriptionDetail = "";
        public string TemplateTitle = "";
        public decimal commissionSng = 0;
        public decimal commissionDbl = 0;
        public decimal commissionTRPL = 0;
        public decimal commissionQUAD = 0;
        public string DepUnitDescription
        {
            get
            {
                if (DepUnit == 1)
                    return "per person";
                else if (DepUnit == 2)
                    return "per cabin";
                else
                    return "per person";
            }
        }
        public string StatusDescription
        {
            get
            {
                if (Status == "")
                    return "In Development";
                return Status;
            }
        }
        public string TravelDates
        {
            get
            {
                if (DepartureDate != "" && ReturnDate != "")
                {
                    DateTime dtDepart = Convert.ToDateTime(DepartureDate);
                    DateTime dtReturn = Convert.ToDateTime(ReturnDate);
                    if (dtDepart == dtReturn)
                        return dtDepart.ToString("MMMM d, yyyy");
                    else if (dtDepart.Year == dtReturn.Year)
                        return dtDepart.ToString("MMMM d") + " - " + ((dtDepart.Month == dtReturn.Month) ? dtReturn.Day.ToString() : dtReturn.ToString("MMMM d")) + ", " + dtReturn.Year;
                    else
                        return dtDepart.ToString("MMMM d, yyyy") + " - " + dtReturn.ToString("MMMM d, yyyy");
                }
                return "";
            }
        }
        public bool useDateRange = false;
        public DateTime dateFrom = DateTime.Now;
        public DateTime dateTo = DateTime.Now.AddDays(1);
        //

		public static mtGroup GetGroup(string groupCode)
		{
            //left join dbo.mt_ship b on b.shipcode = a.shipcode  //modified by Vlad
            string sSQL = @"select a.*, b.ShipName, c.RegionDescription, d.TypeDescription, e.VendorName, f.departurepoint as DeparturePointName, 
                    g.DestinationDescription, h.title as DescriptionTitle, i.title as TemplateTitle, 
					h.description as DescriptionDetail, vg.VGroupDescription, v1.vendorName as VendorName2
                from dbo.mt_info a
                left join dbo.grp_ShipID b on b.shipid = a.shipcode
                left join dbo.mt_region c on c.regioncode = a.regioncode
                left join dbo.mt_type d on d.typecode = a.packagetype
                left join dbo.mt_vendor e on e.vendorcode = a.vendorgroupcode
                left join dbo.mt_departurepoint f on f.departurecode = a.departurepoint
                left join dbo.mt_destination g on g.destinationcode = a.destinationcode 
                left join dbo.mt_description h on h.id = a.[description]
                left join dbo.mt_templates i on i.template = a.template 
				Left JOIN dbo.grp_VGroupCode vg on a.VGroupCode = vg.VGroupCode
				Left JOIN dbo.mt_vendor v1 on a.VendorGroupCode2 = v1.vendorCode
                WHERE a.GroupCode = @groupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtGroup g = new mtGroup ();
                g.GroupCode = rs["groupcode"].ToString();
                g.PackageType = rs["packageType"] + "";
                g.DoNotDisplay = (rs["DoNotDisplay"] is DBNull) ? false : (bool) rs["DoNotDisplay"]; 
                g.ATI = (rs["ATI"] is DBNull) ? false : (bool) rs["ATI"] ;
                g.ATI_Promo = rs["ATI_Promo"] + "";
                g.Template = rs["template"] + "";
                g.SpecialtyGroup = (rs["SpecialtyGroup"] is DBNull) ? false : (bool) rs["SpecialtyGroup"];
                g.SpecialInterests = (rs["SpecialInterests"] is DBNull) ? false : (bool) rs["specialInterests"];
                g.Affinity = (rs["Affinity"] is DBNull) ? false : (bool) rs["Affinity"];
                g.AgentName = rs["AgentName"] + "";
                g.ProductCode = rs["ProductCode"] + "";
                g.Heading = rs["Heading"] + "";
                g.ScriptHeader = rs["ScriptHeader"] + "";
                g.TourName = rs["tourname"] + "";
                g.ShipCode = Util.parseInt(rs["ShipCode"]);
                //g.VendorCode = rs["VendorCode"] + "";

                g.VGroupCode = rs["VGroupCode"] + "";
                g.VendorGroupCode = rs["vendorGroupCode"] + "";
                g.VendorGroupCode2 = rs["VendorGroupCode2"] + ""; 
                g.VendorGroupNumber = rs["vendorGroupNumber"] + "";
                g.VGroupDescription = rs["VGroupDescription"] + "";
                g.VendorName2 = rs["VendorName2"] + "";

                g.RegionCode = Util.parseInt(rs["RegionCode"]);
                g.DestinationCode = Util.parseInt(rs["DestinationCode"]);
                g.CityCode = rs["CityCode"] + "";
                g.DeparturePoint = Util.parseInt(rs["DeparturePoint"]);
                g.Description = Util.parseInt(rs["description"]);
                g.DepartureDate = (rs["DepartureDate"] is DBNull) ? "" : Convert.ToDateTime(rs["DepartureDate"]).ToShortDateString();
                g.ReturnDate = (rs["ReturnDate"] is DBNull) ? "" : Convert.ToDateTime(rs["ReturnDate"]).ToShortDateString();
                g.StartingRates = Util.parseDec(rs["startingRates"]);
                g.HideRates = (rs["HideRates"] is DBNull) ? false : (bool) rs["HideRates"];
                g.SingleRate = Util.parseDec(rs["singleRate"]);
                g.DoubleRate = Util.parseDec(rs["doubleRate"]);
                g.TripleRate = Util.parseDec(rs["tripleRate"]);
                g.QuadRate = Util.parseDec(rs["quadRate"]);
                g.TrplQuad = rs["trplQuad"] + "";
                g.TrplQuadRate = Util.parseDec(rs["trplQuadRate"]);
                g.TrplQuadComments = rs["trplQuadComments"] + "";
                g.PortCharges = Util.parseDec(rs["PortCharges"]);
                g.PortChargesIncluded = rs["PortChargesIncluded"] + "";
                g.GovtFees = Util.parseDec(rs["GovtFees"]);
                g.GovtFeesIncluded = rs["GovtFeesIncluded"] + "";
                g.Taxes = Util.parseDec(rs["Taxes"]);
                g.TaxesIncluded = rs["TaxesIncluded"] + "";
                g.Miscellaneous = Util.parseDec(rs["Miscellaneous"]);
                g.MiscComments = rs["MiscComments"] + "";
                g.MiscIncluded = rs["MiscIncluded"] + "";
                g.DepositAmount = rs["DepositAmount"] + "";
                g.DepUnit = Util.parseInt(rs["depUnit"]);
                g.FinalPmtDate = (rs["finalPmtDate"] is DBNull) ? "" : Convert.ToDateTime(rs["finalPmtDate"]).ToShortDateString();
                g.FinalPmtDays = Util.parseInt(rs["finalPmtDays"]);
                g.FirstDepositDate = (rs["firstDepositDate"] is DBNull) ? "" : Convert.ToDateTime(rs["firstDepositDate"]).ToShortDateString();
                g.SecondDepositDate = (rs["secondDepositDate"] is DBNull) ? "" : Convert.ToDateTime(rs["secondDepositDate"]).ToShortDateString();
                g.RecallDate = (rs["recallDate"] is DBNull) ? "" : Convert.ToDateTime(rs["recallDate"]).ToShortDateString();
                g.RecallDays = Util.parseInt(rs["recallDays"]);
                g.ProcessDeposit = rs["ProcessDeposit"] + "";
                g.ProcessDepositOther = rs["ProcessDepositOther"] + "";
                g.ProcessPayment = rs["ProcessPayment"] + "";
                g.ProcessPaymentOther = rs["ProcessPaymentOther"] + "";
                g.SpecialFeatures = rs["specialFeatures"] + "";
                g.AdditionalNotes = rs["AdditionalNotes"] + "";
                g.CustomAir = rs["CustomAir"] + "";
                g.CustomAirAmount = Util.parseDec(rs["CustomAirAmount"]);
                g.SuggestCustomAir = rs["SuggestCustomAir"] + "";
                g.TravelInsurance = rs["TravelInsurance"] + "";
                g.Disclaimer = rs["Disclaimer"] + "";
                g.FlyerDisclaimer = rs["flyerdisclaimer"] + "";
                g.CallToAction = rs["CallToAction"] + "";
                g.Pre = rs["Pre"] + "";
                g.PreAmount = Util.parseDec(rs["PreAmount"]);
                g.Post = rs["Post"] + "";
                g.PostAmount = Util.parseDec(rs["PostAmount"]);
                g.RequiredPass = rs["RequiredPass"] + "";
                g.Script331 = rs["script331"] + "";
                g.AgentNotes = rs["AgentNotes"] + "";
                g.DocReq = rs["DocReq"] + "";
                g.Visa = rs["Visa"] + "";
                g.Innoculation = rs["Innoculation"] + "";
                g.DocOther = rs["DocOther"] + "";
                g.MotorCoach = rs["motorcoach"] + "";
                g.ContactInstr = rs["ContactInstr"] + "";
                g.ContactInstrOther = rs["ContactInstrOther"] + "";
                g.IATAInstr = rs["IATAInstr"] + "";
                g.IATAInstrOther = rs["IATAInstrOther"] + "";
                g.PhoneInstr = rs["PhoneInstr"] + "";
                g.PhoneInstrOther = rs["PhoneInstrOther"] + "";
                g.AddlInstr = rs["AddlInstr"] + "";
                g.AddlInstrOther = rs["AddlInstrOther"] + "";
                g.AddAir = rs["AddAir"] + "";
                g.TransfersIncluded = rs["TransfersIncluded"] + "";
                g.TransfersCost = rs["TransfersCost"] + "";
                g.CreateDate = (rs["createDate"] is DBNull) ? "" : Convert.ToDateTime(rs["createDate"]).ToShortDateString();
                g.PrintVersion = rs["printversion"] + "";
                g.SellingTip = rs["SellingTip"] + "";
                g.Status = rs["status"] + "";
                g.RejectReason = rs["rejectReason"] + "";
                g.Created = Convert.ToDateTime(rs["created"]);
                g.CreatedBy = rs["createdBy"] + "";
                g.LastEdited = (rs["lastEdited"] is DBNull) ? "" : Convert.ToDateTime(rs["lastEdited"]).ToShortDateString();
                g.LastEditedBy = rs["lastEditedBy"] + "";
                // Descriptions
                g.ShipName = (g.PackageType == "T") ? "" : rs["ShipName"] + "";
                g.RegionDescription = rs["RegionDescription"] + "";
                g.TypeDescription = rs["TypeDescription"] + "";
                g.VendorName = rs["VendorName"] + "";
                g.DeparturePointName = rs["DeparturePointName"] + ""; 
                g.DestinationDescription = rs["DestinationDescription"] + "";
                g.DescriptionTitle = rs["DescriptionTitle"] + "";
                g.DescriptionDetail = rs["DescriptionDetail"] + "";
                g.TemplateTitle = rs["TemplateTitle"] + "";
                // Commissions
                g.commissionSng = Util.parseDec(rs["commissionSng"]);
                g.commissionDbl = Util.parseDec(rs["commissionDbl"]);
                g.commissionTRPL = Util.parseDec(rs["commissionTRPL"]);
                g.commissionQUAD = Util.parseDec(rs["commissionQUAD"]);
                g.useDateRange = (rs["useDateRange"] is DBNull) ? false : (bool)rs["useDateRange"];
                g.dateFrom = Convert.ToDateTime((rs["dateFrom"] is DBNull) ? DateTime.Now : rs["dateFrom"]);
                g.dateTo = Convert.ToDateTime((rs["dateTo"] is DBNull) ? DateTime.Now.AddDays(1) : rs["dateTo"]);

                return g;
            }
		}


        public static List<mtGroupBanner> GetBanner(string groupCode, string template)
        {
            string sSQL = @"SELECT t.bannerPosition, isnull(b.bannerID,0) as bannerID
                FROM mt_templates_banners t 
                LEFT OUTER JOIN mt_info_banners b ON b.bannerPosition = t.bannerPosition AND b.groupCode = @groupcode
                WHERE t.template = @template 
                ORDER BY t.bannerPosition";
            List<mtGroupBanner> list = new List<mtGroupBanner>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                cmd.Parameters.Add("@template", SqlDbType.VarChar).Value = template;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int bannerID = Convert.ToInt32(rs["bannerID"]);
                    string bannerPosition = rs["bannerPosition"] + "";
                    list.Add(new mtGroupBanner(bannerID, bannerPosition));
                }
            }
            return list;
        }

        public static string GetBannerImage(string groupCode, string bannerPosition)
        {
            string sSQL = @"SELECT isnull(max(b.[filename]),'') as filename
                FROM mt_info_banners gib 
                LEFT OUTER JOIN mt_banners b ON gib.bannerID = b.id 
                WHERE gib.groupCode = @groupcode 
                AND gib.bannerPosition = @bannerposition";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                cmd.Parameters.Add("@bannerposition", SqlDbType.VarChar).Value = bannerPosition;
                return cmd.ExecuteScalar().ToString();
            }
        }

        public static List<mtCancelPolicy> GetCancelPolicy(string groupCode)
        {
            return GetCancelPolicy(groupCode, false);
        }

		public static List<mtCancelPolicy> GetCancelPolicy(string groupCode, bool blankRows)
		{
            string sSQL = "SELECT * FROM dbo.mt_cancel_policy WHERE groupCode = @GroupCode order by datefr";
            List<mtCancelPolicy> list = new List<mtCancelPolicy>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int cancpolicyid = Convert.ToInt32(rs["cancpolicyid"]);
                    string policy = rs["policy"] + "";
                    string dateFr = (rs["datefr"] is DBNull) ? "" : Convert.ToDateTime(rs["datefr"]).ToShortDateString();
                    string dateTo = (rs["dateto"] is DBNull) ? "" : Convert.ToDateTime(rs["dateto"]).ToShortDateString();
                    string days = rs["days"] + "";
                    list.Add (new mtCancelPolicy(cancpolicyid, policy, dateFr, dateTo, days));
                }
            }
            if (blankRows)
            {
                int cnt = (list.Count > 5) ? 2 : 5 - list.Count;
                for (int i = 0; i < cnt; i++)
                     list.Add (new mtCancelPolicy (0, "", "", "", ""));
            }
            return list;
        }

        public static List<mtItinerary> GetItinerary(string groupCode)
        {
            return GetItinerary(groupCode, false);
        }

        public static List<mtItinerary> GetItinerary(string groupCode, bool blankRows)
        {
            string sSQL = @"EXEC dbo.usp_mtGenItinerary @GroupCode;
                    SELECT * FROM dbo.mt_itinerary WHERE groupCode = @GroupCode order by date, itineraryid";
            List<mtItinerary> list = new List<mtItinerary>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int itineraryid = Convert.ToInt32(rs["itineraryid"]);
                    string itinerary = rs["itinerary"] + "";
                    string date = Convert.ToDateTime(rs["date"]).ToShortDateString();
                    string detail = rs["detail"] + "";
                    list.Add(new mtItinerary(itineraryid, itinerary, date, detail));
                }
            }
            if (blankRows)
            {
                int cnt = (list.Count == 0) ? 10 : 5;
                for (int i = 0; i < cnt; i++)
                    list.Add(new mtItinerary(0, "", "", ""));
            }
            return list;
        }

        public static List<mtGroupCategory> GetCategory(string groupCode)
        {
            return GetCategory(groupCode, false);
        }

        public static List<mtGroupCategory> GetCategory(string groupCode, bool blankRows)
        {
            string sSQL = "SELECT * FROM dbo.mt_category WHERE groupCode = @GroupCode order by dble desc";
            List<mtGroupCategory> list = new List<mtGroupCategory>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int categoryid = Convert.ToInt32(rs["categoryid"]);
                    string category = rs["category"] + "";
                    string des = rs["descrip"] + "";
                    decimal sng = Util.parseDec(rs["sing"]);
                    decimal dbl = Util.parseDec(rs["dble"]);
                    decimal commissionSng = Util.parseDec(rs["commissionSng"]);
                    decimal commissionDbl = Util.parseDec(rs["commissionDbl"]);
                    //decimal commissionTRPL = Util.parseDec(rs["commissionTRPL"]);
                    //decimal commissionQUAD = Util.parseDec(rs["commissionQUAD"]);
                    list.Add(new mtGroupCategory(categoryid, category, des, sng, dbl, commissionSng, commissionDbl));
                }
            }
            if (blankRows)
            {
                int cnt = (list.Count == 0) ? 10 : 5;
                for (int i = 0; i < cnt; i++)
                    list.Add(new mtGroupCategory(0, "", "", 0, 0, 0, 0));
            }
            return list;
        }

        public static DataTable GetAir(string groupCode)
        {
            string sSQL = "SELECT * FROM dbo.mt_Air WHERE groupcode=@groupcode ORDER BY id;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = groupCode;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void Add(string groupCode, string packageType, string template)
        {
            string SQL_INSERT_CANC = @"INSERT INTO dbo.mt_cancel_policy (GroupCode, DateFr, DateTo, Policy) 
                VALUES (@GroupCode, @DateFr, @DateTo, @Policy);";

            GroupMaster g = GroupMaster.GetGroupMaster(groupCode);
            List<CxlPolicyDet2> cancList = null;
            if (g != null)
                cancList = CxlPolicy.GetDetails(g.CxlPolicyID, g.DepartDate);

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand("usp_mtAddGroup", cn, trn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = groupCode;
                    cmd.Parameters.Add("@packagetype", SqlDbType.VarChar, 2).Value = packageType;
                    cmd.Parameters.Add("@template", SqlDbType.VarChar, 50).Value = template;
                    cmd.Parameters.Add("@createDate", SqlDbType.DateTime).Value = DateTime.Today;
                    cmd.Parameters.Add("@createdBy", SqlDbType.VarChar, 50).Value = Util.CurrentUser();
                    cmd.ExecuteNonQuery();
                    if (cancList != null)
                    {
                        foreach (CxlPolicyDet2 x in cancList)
                        {
                            cmd = new SqlCommand(SQL_INSERT_CANC, cn, trn);
                            cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = groupCode;
                            cmd.Parameters.Add("@policy", SqlDbType.VarChar, 500).Value = x.custLoss;
                            cmd.Parameters.Add("@datefr", SqlDbType.DateTime).Value = x.dateFr;
                            cmd.Parameters.Add("@dateto", SqlDbType.DateTime).Value = x.dateTo;
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
        }

        public static void Delete(string groupCode)
        {
            string sSQL = @"DELETE FROM dbo.mt_cancel_policy WHERE groupCode = @groupCode;
                DELETE FROM dbo.mt_air WHERE groupCode = @groupCode;
                DELETE FROM dbo.mt_category WHERE groupCode = @groupCode;
                DELETE FROM dbo.mt_includes WHERE group_id = @groupCode;
                DELETE FROM dbo.mt_info_banners WHERE groupCode = @groupCode;
                DELETE FROM dbo.mt_itinerary WHERE groupCode = @groupCode;
                DELETE FROM dbo.mt_info WHERE groupCode = @groupCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
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


        public static void Update(mtGroup g)
        {
            string sSQL = @"UPDATE dbo.mt_info SET packageType = @packageType, DoNotDisplay = @DoNotDisplay, ATI = @ATI, ATI_Promo = @ATI_Promo, template = @template,
                SpecialtyGroup = @SpecialtyGroup, specialInterests = @specialInterests, [Affinity] = @Affinity, AgentName = @AgentName, ProductCode = @ProductCode, 
                Heading = @Heading, ScriptHeader = @ScriptHeader, tourname = @tourname, ShipCode = @ShipCode, VGroupCode = @VGroupCode, vendorGroupCode = @vendorGroupCode,
                vendorGroupNumber = @vendorGroupNumber, RegionCode = @RegionCode, DestinationCode = @DestinationCode, CityCode = @CityCode, DeparturePoint = @DeparturePoint,
                [description] = @description, DepartureDate = @DepartureDate, ReturnDate = @ReturnDate, startingRates = @startingRates, HideRates = @HideRates, 
                singleRate = @singleRate, doubleRate = @doubleRate, tripleRate = @tripleRate, quadRate = @quadRate, trplQuad = @trplQuad, trplQuadRate = @trplQuadRate, 
                trplQuadComments = @trplQuadComments, PortCharges = @PortCharges, PortChargesIncluded = @PortChargesIncluded, GovtFees = @GovtFees, 
                GovtFeesIncluded = @GovtFeesIncluded, Taxes = @Taxes, TaxesIncluded = @TaxesIncluded, Miscellaneous = @Miscellaneous, MiscComments = @MiscComments, 
                MiscIncluded = @MiscIncluded, DepositAmount = @DepositAmount, depUnit = @depUnit, finalPmtDate = @finalPmtDate, finalPmtDays = @finalPmtDays, 
                firstDepositDate = @firstDepositDate, secondDepositDate = @secondDepositDate, recallDate = @recallDate, recallDays = @recallDays, 
                ProcessDeposit = @ProcessDeposit, ProcessDepositOther = @ProcessDepositOther, ProcessPayment = @ProcessPayment, ProcessPaymentOther = @ProcessPaymentOther, 
                specialFeatures = @specialFeatures, AdditionalNotes = @AdditionalNotes, CustomAir = @CustomAir, CustomAirAmount = @CustomAirAmount, 
                SuggestCustomAir = @SuggestCustomAir, TravelInsurance = @TravelInsurance, Disclaimer = @Disclaimer, flyerdisclaimer = @flyerdisclaimer, 
                CallToAction = @CallToAction, Pre = @Pre, PreAmount = @PreAmount, Post = @Post, PostAmount = @PostAmount, RequiredPass = @RequiredPass,
                script331 = @script331, AgentNotes = @AgentNotes, DocReq = @DocReq, Visa = @Visa, Innoculation = @Innoculation, DocOther = @DocOther, motorcoach = @motorcoach, 
                ContactInstr = @ContactInstr, ContactInstrOther = @ContactInstrOther, IATAInstr = @IATAInstr, IATAInstrOther = @IATAInstrOther, PhoneInstr = @PhoneInstr, 
                PhoneInstrOther = @PhoneInstrOther, AddlInstr = @AddlInstr, AddlInstrOther = @AddlInstrOther, AddAir = @AddAir, TransfersIncluded = @TransfersIncluded, 
                TransfersCost = @TransfersCost, printversion = @printversion, SellingTip = @SellingTip, lastEdited = @lastEdited, lastEditedBy = @lastEditedBy,
                commissionSng = @commissionSng, commissionDbl = @commissionDbl, commissionTRPL = @commissionTRPL, commissionQUAD = @commissionQUAD,
                useDateRange = @useDateRange, dateFrom = @dateFrom, dateTo = @dateTo, VendorGroupCode2 = @VendorGroupCode2
                WHERE GroupCode = @GroupCode;
                EXEC dbo.usp_mtUpdateIncludes @GroupCode"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = g.GroupCode;
                cmd.Parameters.Add("@packageType", SqlDbType.VarChar, 2).Value = g.PackageType;
                cmd.Parameters.Add("@DoNotDisplay", SqlDbType.Bit).Value = g.DoNotDisplay;
                cmd.Parameters.Add("@ATI", SqlDbType.Bit).Value = g.ATI;
                cmd.Parameters.Add("@ATI_Promo", SqlDbType.VarChar, 250).Value = g.ATI_Promo;
                cmd.Parameters.Add("@template", SqlDbType.VarChar, 50).Value = g.Template;
                cmd.Parameters.Add("@SpecialtyGroup", SqlDbType.Bit).Value = g.SpecialtyGroup;
                cmd.Parameters.Add("@specialInterests", SqlDbType.Bit).Value = g.SpecialInterests;
                cmd.Parameters.Add("@Affinity", SqlDbType.Bit).Value = g.Affinity;
                cmd.Parameters.Add("@AgentName", SqlDbType.VarChar, 200).Value = g.AgentName;
                cmd.Parameters.Add("@ProductCode", SqlDbType.VarChar, 50).Value = g.ProductCode;
                cmd.Parameters.Add("@Heading", SqlDbType.VarChar, 500).Value = g.Heading;
                cmd.Parameters.Add("@ScriptHeader", SqlDbType.VarChar, 255).Value = g.ScriptHeader;
                cmd.Parameters.Add("@tourname", SqlDbType.VarChar, 80).Value = g.TourName;
                cmd.Parameters.Add("@ShipCode", SqlDbType.Int).Value = DBNull.Value;
                if (g.ShipCode > 0)
                    cmd.Parameters["@ShipCode"].Value = g.ShipCode;
                cmd.Parameters.Add("@VendorCode", SqlDbType.VarChar, 10).Value = DBNull.Value;
                if (g.VendorCode != "")
                    cmd.Parameters["@VendorCode"].Value = g.VendorCode;
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar, 25).Value = DBNull.Value;
                if (g.VendorGroupCode != "")
                    cmd.Parameters["@VendorGroupCode"].Value = g.VendorGroupCode;
                cmd.Parameters.Add("@vendorGroupCode2", SqlDbType.VarChar, 25).Value = DBNull.Value;
                if (g.VendorGroupCode2 != "")
                    cmd.Parameters["@VendorGroupCode2"].Value = g.VendorGroupCode2;
                cmd.Parameters.Add("@VGroupCode", SqlDbType.VarChar, 10).Value = g.VGroupCode;
                if (g.VGroupCode != "")
                    cmd.Parameters["@VGroupCode"].Value = g.VGroupCode;

                cmd.Parameters.Add("@vendorGroupNumber", SqlDbType.VarChar, 10).Value = g.VendorGroupNumber;
                cmd.Parameters.Add("@RegionCode", SqlDbType.Int).Value = DBNull.Value;
                if (g.RegionCode > 0)
                    cmd.Parameters["@RegionCode"].Value = g.RegionCode;
                cmd.Parameters.Add("@DestinationCode", SqlDbType.Int).Value = DBNull.Value;
                if (g.DestinationCode > 0)
                    cmd.Parameters["@DestinationCode"].Value = g.DestinationCode;
                cmd.Parameters.Add("@CityCode", SqlDbType.VarChar, 10).Value = g.CityCode;
                cmd.Parameters.Add("@DeparturePoint", SqlDbType.Int).Value = DBNull.Value;
                if (g.DeparturePoint > 0)
                    cmd.Parameters["@DeparturePoint"].Value = g.DeparturePoint;
                cmd.Parameters.Add("@description", SqlDbType.Int).Value = DBNull.Value;
                if (g.Description > 0)
                    cmd.Parameters["@Description"].Value = g.Description;
                cmd.Parameters.Add("@DepartureDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.DepartureDate != "")
                    cmd.Parameters["@DepartureDate"].Value = Convert.ToDateTime(g.DepartureDate);
                cmd.Parameters.Add("@ReturnDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.ReturnDate != "")
                    cmd.Parameters["@ReturnDate"].Value = Convert.ToDateTime(g.ReturnDate);
                cmd.Parameters.Add("@startingRates", SqlDbType.Decimal).Value = g.StartingRates;
                cmd.Parameters.Add("@HideRates", SqlDbType.Bit).Value = g.HideRates;
                cmd.Parameters.Add("@singleRate", SqlDbType.Decimal).Value = g.SingleRate;
                cmd.Parameters.Add("@doubleRate", SqlDbType.Decimal).Value = g.DoubleRate;
                cmd.Parameters.Add("@tripleRate", SqlDbType.Decimal).Value = g.TripleRate;
                cmd.Parameters.Add("@quadRate", SqlDbType.Decimal).Value = g.QuadRate;
                cmd.Parameters.Add("@trplQuad", SqlDbType.VarChar, 10).Value = g.TrplQuad;
                cmd.Parameters.Add("@trplQuadRate", SqlDbType.Decimal).Value = g.TrplQuadRate;
                cmd.Parameters.Add("@trplQuadComments", SqlDbType.VarChar, 250).Value = g.TrplQuadComments;
                cmd.Parameters.Add("@PortCharges", SqlDbType.Decimal).Value = g.PortCharges;
                cmd.Parameters.Add("@PortChargesIncluded", SqlDbType.VarChar, 5).Value = g.PortChargesIncluded;
                cmd.Parameters.Add("@GovtFees", SqlDbType.Decimal).Value = g.GovtFees;
                cmd.Parameters.Add("@GovtFeesIncluded", SqlDbType.VarChar, 5).Value = g.GovtFeesIncluded;
                cmd.Parameters.Add("@Taxes", SqlDbType.Decimal).Value = g.Taxes;
                cmd.Parameters.Add("@TaxesIncluded", SqlDbType.VarChar, 5).Value = g.TaxesIncluded;
                cmd.Parameters.Add("@Miscellaneous", SqlDbType.Decimal).Value = g.Miscellaneous;
                cmd.Parameters.Add("@MiscComments", SqlDbType.VarChar, 50).Value = g.MiscComments;
                cmd.Parameters.Add("@MiscIncluded", SqlDbType.VarChar, 5).Value = g.MiscIncluded;
                cmd.Parameters.Add("@DepositAmount", SqlDbType.VarChar, 20).Value = g.DepositAmount;
                cmd.Parameters.Add("@depUnit", SqlDbType.Int).Value = g.DepUnit;
                cmd.Parameters.Add("@FinalPmtDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.FinalPmtDate != "")
                    cmd.Parameters["@FinalPmtDate"].Value = Convert.ToDateTime(g.FinalPmtDate);
                cmd.Parameters.Add("@finalPmtDays", SqlDbType.Int).Value = g.FinalPmtDays;
                cmd.Parameters.Add("@firstDepositDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.FirstDepositDate != "")
                    cmd.Parameters["@FirstDepositDate"].Value = Convert.ToDateTime(g.FirstDepositDate);
                cmd.Parameters.Add("@secondDepositDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.SecondDepositDate != "")
                    cmd.Parameters["@SecondDepositDate"].Value = Convert.ToDateTime(g.SecondDepositDate);
                cmd.Parameters.Add("@recallDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (g.RecallDate != "")
                    cmd.Parameters["@RecallDate"].Value = Convert.ToDateTime(g.RecallDate);
                cmd.Parameters.Add("@recallDays", SqlDbType.Int).Value = g.RecallDays;
                cmd.Parameters.Add("@ProcessDeposit", SqlDbType.VarChar, 1000).Value = g.ProcessDeposit;
                cmd.Parameters.Add("@ProcessDepositOther", SqlDbType.VarChar, 50).Value = g.ProcessDepositOther;
                cmd.Parameters.Add("@ProcessPayment", SqlDbType.VarChar, 1000).Value = g.ProcessPayment;
                cmd.Parameters.Add("@ProcessPaymentOther", SqlDbType.VarChar, 50).Value = g.ProcessPaymentOther;
                cmd.Parameters.Add("@specialFeatures", SqlDbType.VarChar, 500).Value = g.SpecialFeatures;
                cmd.Parameters.Add("@AdditionalNotes", SqlDbType.VarChar, 1000).Value = g.AdditionalNotes;
                cmd.Parameters.Add("@CustomAir", SqlDbType.VarChar, 10).Value = g.CustomAir;
                cmd.Parameters.Add("@CustomAirAmount", SqlDbType.Decimal).Value = g.CustomAirAmount;
                cmd.Parameters.Add("@SuggestCustomAir", SqlDbType.VarChar, 500).Value = g.SuggestCustomAir;
                cmd.Parameters.Add("@TravelInsurance", SqlDbType.VarChar, 2000).Value = g.TravelInsurance;
                cmd.Parameters.Add("@Disclaimer", SqlDbType.VarChar, 1000).Value = g.Disclaimer;
                cmd.Parameters.Add("@flyerdisclaimer", SqlDbType.VarChar, 500).Value = g.FlyerDisclaimer;
                cmd.Parameters.Add("@CallToAction", SqlDbType.VarChar, 2000).Value = g.CallToAction;
                cmd.Parameters.Add("@Pre", SqlDbType.VarChar, 5).Value = g.Pre;
                cmd.Parameters.Add("@PreAmount", SqlDbType.Decimal).Value = g.PreAmount;
                cmd.Parameters.Add("@Post", SqlDbType.VarChar, 5).Value = g.Post;
                cmd.Parameters.Add("@PostAmount", SqlDbType.Decimal).Value = g.PostAmount;
                cmd.Parameters.Add("@RequiredPass", SqlDbType.VarChar, 1000).Value = g.RequiredPass;
                cmd.Parameters.Add("@script331", SqlDbType.VarChar, 10).Value = g.Script331;
                cmd.Parameters.Add("@AgentNotes", SqlDbType.VarChar, 2000).Value = g.AgentNotes;
                cmd.Parameters.Add("@DocReq", SqlDbType.VarChar, 1000).Value = g.DocReq;
                cmd.Parameters.Add("@Visa", SqlDbType.VarChar, 50).Value = g.Visa;
                cmd.Parameters.Add("@Innoculation", SqlDbType.VarChar, 50).Value = g.Innoculation;
                cmd.Parameters.Add("@DocOther", SqlDbType.VarChar, 50).Value = g.DocOther;
                cmd.Parameters.Add("@motorcoach", SqlDbType.VarChar, 5).Value = g.MotorCoach;
                cmd.Parameters.Add("@ContactInstr", SqlDbType.VarChar, 500).Value = g.ContactInstr;
                cmd.Parameters.Add("@ContactInstrOther", SqlDbType.VarChar, 200).Value = g.ContactInstrOther;
                cmd.Parameters.Add("@IATAInstr", SqlDbType.VarChar, 500).Value = g.IATAInstr;
                cmd.Parameters.Add("@IATAInstrOther", SqlDbType.VarChar, 200).Value = g.IATAInstrOther;
                cmd.Parameters.Add("@PhoneInstr", SqlDbType.VarChar, 500).Value = g.PhoneInstr;
                cmd.Parameters.Add("@PhoneInstrOther", SqlDbType.VarChar, 50).Value = g.PhoneInstrOther;
                cmd.Parameters.Add("@AddlInstr", SqlDbType.VarChar, 500).Value = g.AddlInstr;
                cmd.Parameters.Add("@AddlInstrOther", SqlDbType.VarChar, 200).Value = g.AddlInstrOther;
                cmd.Parameters.Add("@AddAir", SqlDbType.VarChar, 5).Value = g.AddAir;
                cmd.Parameters.Add("@TransfersIncluded", SqlDbType.VarChar, 5).Value = g.TransfersIncluded;
                cmd.Parameters.Add("@TransfersCost", SqlDbType.VarChar, 50).Value = g.TransfersCost;
                cmd.Parameters.Add("@printversion", SqlDbType.VarChar, 100).Value = g.PrintVersion;
                cmd.Parameters.Add("@SellingTip", SqlDbType.VarChar, 100).Value = g.SellingTip;
                cmd.Parameters.Add("@lastEdited", SqlDbType.DateTime).Value = DateTime.Now;
                cmd.Parameters.Add("@lastEditedBy", SqlDbType.VarChar, 0).Value = Util.CurrentUser();
                cmd.Parameters.Add("@commissionSng", SqlDbType.Decimal).Value = g.commissionSng;
                cmd.Parameters.Add("@commissionDbl", SqlDbType.Decimal).Value = g.commissionDbl;
                cmd.Parameters.Add("@commissionTRPL", SqlDbType.Decimal).Value = g.commissionTRPL;
                cmd.Parameters.Add("@commissionQUAD", SqlDbType.Decimal).Value = g.commissionQUAD;
                cmd.Parameters.Add("@useDateRange", SqlDbType.Bit).Value = g.useDateRange;
                cmd.Parameters.Add("@dateFrom", SqlDbType.DateTime).Value = g.dateFrom;
                cmd.Parameters.Add("@dateTo", SqlDbType.DateTime).Value = g.dateTo;
                cmd.ExecuteNonQuery();
            }
        }
       
        public static void UpdateFlyer(string GroupCode, string VendorGroupCode, int ShipCode)
        {
            string sSQL = @"update mt_info Set vendorGroupCode = @VendorGroupCode, ShipCode = @ShipCode
                            where GroupCode = @GroupCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = GroupCode;
                cmd.Parameters.Add("@vendorGroupCode", SqlDbType.VarChar, 25).Value = VendorGroupCode;
                cmd.Parameters.Add("@ShipCode", SqlDbType.Int).Value = ShipCode;


                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateStatus(string groupCode, string status)
        {
            string sSQL = @"UPDATE dbo.mt_info SET Status = @Status WHERE GroupCode = @GroupCode;";
            if (status != "Pending Approval" && status != "Approved" && status != "Rejected" && status != "")
                throw new ApplicationException("Invalid Status");
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = groupCode;
                cmd.Parameters.Add("@Status", SqlDbType.VarChar, 50).Value = DBNull.Value;
                if (status != "")
                    cmd.Parameters["@Status"].Value = status;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateCancelPolicy(string groupCode, List<mtCancelPolicy> list)
        {
            string SQL_INSERT = "INSERT INTO dbo.mt_cancel_policy (groupcode, datefr, dateto, policy) VALUES (@groupcode, @datefr, @dateto, @policy)";
            string SQL_UPDATE = "UPDATE dbo.mt_cancel_policy SET datefr=@datefr, dateto=@dateto, policy=@policy WHERE cancpolicyid=@cancpolicyid AND groupcode=@groupcode";
            string SQL_DELETE = "DELETE FROM dbo.mt_cancel_policy WHERE cancpolicyid=@cancpolicyid AND groupcode=@groupcode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (mtCancelPolicy c in list)
                    {
                        if (c.cancpolicyid == 0)
                        {
                            if (c.dateFr != "" || c.dateTo != "" || c.policy != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_INSERT, cn, trn);
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@policy", SqlDbType.VarChar, 500).Value = c.policy;
                                cmd.Parameters.Add("@datefr", SqlDbType.DateTime).Value = DBNull.Value;
                                if (c.dateFr != "")
                                    cmd.Parameters["@datefr"].Value = Convert.ToDateTime(c.dateFr);
                                cmd.Parameters.Add("@dateto", SqlDbType.DateTime).Value = DBNull.Value;
                                if (c.dateTo != "")
                                    cmd.Parameters["@dateto"].Value = Convert.ToDateTime(c.dateTo);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            if (c.dateFr != "" || c.dateTo != "" || c.policy != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                                cmd.Parameters.Add("@cancpolicyid", SqlDbType.Int).Value = c.cancpolicyid;
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@policy", SqlDbType.VarChar, 500).Value = c.policy;
                                cmd.Parameters.Add("@datefr", SqlDbType.DateTime).Value = DBNull.Value;
                                if (c.dateFr != "")
                                    cmd.Parameters["@datefr"].Value = Convert.ToDateTime(c.dateFr);
                                cmd.Parameters.Add("@dateto", SqlDbType.DateTime).Value = DBNull.Value;
                                if (c.dateTo != "")
                                    cmd.Parameters["@dateto"].Value = Convert.ToDateTime(c.dateTo);
                                cmd.ExecuteNonQuery();
                            }
                            else
                            {
                                SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                                cmd.Parameters.Add("@cancpolicyid", SqlDbType.Int).Value = c.cancpolicyid;
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
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

        public static void UpdateItinerary(string groupCode, List<mtItinerary> list)
        {
            string SQL_INSERT = "INSERT INTO dbo.mt_itinerary(GroupCode, itinerary, date, detail) VALUES(@GroupCode, @itinerary, @date, @detail)";
            string SQL_UPDATE = "UPDATE dbo.mt_itinerary SET itinerary=@itinerary, date=@date, detail=@detail WHERE itineraryid=@itineraryid AND GroupCode=@GroupCode";
            string SQL_DELETE = "DELETE FROM dbo.mt_itinerary WHERE itineraryid=@itineraryid AND GroupCode=@GroupCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (mtItinerary m in list)
                    {
                        if (m.itineraryid == 0)
                        {
                            if (m.date != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_INSERT, cn, trn);
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@itinerary", SqlDbType.VarChar, 500).Value = m.itinerary;
                                cmd.Parameters.Add("@date", SqlDbType.DateTime).Value = Convert.ToDateTime(m.date);
                                cmd.Parameters.Add("@detail", SqlDbType.VarChar, 500).Value = m.detail;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            if (m.date != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                                cmd.Parameters.Add("@itineraryid", SqlDbType.Int).Value = m.itineraryid;
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@itinerary", SqlDbType.VarChar, 500).Value = m.itinerary;
                                cmd.Parameters.Add("@date", SqlDbType.DateTime).Value = Convert.ToDateTime(m.date);
                                cmd.Parameters.Add("@detail", SqlDbType.VarChar, 500).Value = m.detail;
                                cmd.ExecuteNonQuery();
                            }
                            else
                            {
                                SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                                cmd.Parameters.Add("@itineraryid", SqlDbType.Int).Value = m.itineraryid;
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
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

        public static void UpdateCategory(string groupCode, List<mtGroupCategory> list)
        {
            //string SQL_INSERT = @"INSERT INTO dbo.mt_category(GroupCode, category, descrip, sing, dble, commissionDbl, commissionSng, commissionTRPL, commissionQUAD) 
            string SQL_INSERT = @"INSERT INTO dbo.mt_category(GroupCode, category, descrip, sing, dble, commissionDbl, commissionSng)
                VALUES(@GroupCode, @category, @descrip, @sing, @dble, @commissionDbl, @commissionSng)";

            string SQL_UPDATE = @"UPDATE dbo.mt_category SET category=@category, descrip=@descrip, sing=@sing, dble=@dble, commissionDbl=@commissionDbl, 
                commissionSng=@commissionSng WHERE categoryid=@categoryid AND GroupCode=@GroupCode";

            string SQL_DELETE = @"DELETE FROM dbo.mt_category WHERE categoryid=@categoryid AND GroupCode=@GroupCode";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (mtGroupCategory c in list)
                    {
                        if (c.categoryid == 0)
                        {
                            if (c.category != "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_INSERT, cn, trn);
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@categoryid", SqlDbType.Int).Value = c.categoryid;
                                cmd.Parameters.Add("@category", SqlDbType.VarChar, 3).Value = c.category;
                                cmd.Parameters.Add("@descrip", SqlDbType.VarChar, 100).Value = c.des;
                                cmd.Parameters.Add("@sing", SqlDbType.Decimal).Value = c.sng;
                                cmd.Parameters.Add("@dble", SqlDbType.Decimal).Value = c.dbl;
                                cmd.Parameters.Add("@commissionSng", SqlDbType.Decimal).Value = c.commissionSng;
                                cmd.Parameters.Add("@commissionDbl", SqlDbType.Decimal).Value = c.commissionDbl;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            if (c.category == "" && c.des == "")
                            {
                                SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@categoryid", SqlDbType.Int).Value = c.categoryid;
                                cmd.ExecuteNonQuery();
                            }
                            else
                            {
                                SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                                cmd.Parameters.Add("@categoryid", SqlDbType.Int).Value = c.categoryid;
                                cmd.Parameters.Add("@category", SqlDbType.VarChar, 3).Value = c.category;
                                cmd.Parameters.Add("@descrip", SqlDbType.VarChar, 100).Value = c.des;
                                cmd.Parameters.Add("@sing", SqlDbType.Decimal).Value = c.sng;
                                cmd.Parameters.Add("@dble", SqlDbType.Decimal).Value = c.dbl;
                                cmd.Parameters.Add("@commissionSng", SqlDbType.Decimal).Value = c.commissionSng;
                                cmd.Parameters.Add("@commissionDbl", SqlDbType.Decimal).Value = c.commissionDbl;

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

        public static void UpdateBanner(string groupCode, List<mtGroupBanner> list)
        {
            string SQL_DELETE = "DELETE FROM dbo.mt_info_banners WHERE groupCode = @groupCode";
            string SQL_INSERT = "INSERT INTO dbo.mt_info_banners (groupCode, bannerID, bannerPosition) VALUES (@groupCode, @bannerID, @bannerPosition)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                    cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                    cmd.ExecuteNonQuery();
                    foreach (mtGroupBanner b in list)
                    {
                        cmd = new SqlCommand(SQL_INSERT, cn, trn);
                        cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                        cmd.Parameters.Add("@bannerid", SqlDbType.Int).Value = b.bannerID;
                        cmd.Parameters.Add("@bannerposition", SqlDbType.VarChar, 50).Value = b.bannerPosition;
                        cmd.ExecuteNonQuery();
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

        public static void RequestApproval(string groupCode)
        {
            // Send Email
            string subject = string.Format("Group # {0} Sent for Approval", groupCode);
            string message = string.Format("Group departure # {0} has been submitted for approval. Please log into Group manager to review and approve", groupCode);
            Email.Send(Config.SenderEmail, Config.RecipientEmail, subject, message);

            // Update Status
            UpdateStatus(groupCode, "Pending Approval");
        }

        public static void Approve(string groupCode)
        {
            
            // Send Email
            string subject = string.Format("Group # {0} has been approved", groupCode);
            string message = string.Format("Group departure # {0} has been approved.", groupCode);
            Email.Send(Config.SenderEmail, Config.RecipientEmail, subject, message);

            // Update Status
            UpdateStatus(groupCode, "Approved");
        }

        public static void Reject(string groupCode, string rejectReason, string AgentEmail)
        {
            // Send Email
            string SenderEmail = Config.SenderEmail;
            string RecipientEmail = Config.RecipientEmail + ", " + AgentEmail;

            string subject = string.Format("Group # {0} has been rejected", groupCode);
            //string message = string.Format("Group departure # {0} has been rejected.\r\n\r\n: ", groupCode, rejectReason);
            //string message = string.Format("Group departure # {0} has been rejected.\r\n\r\n " + rejectReason, groupCode, rejectReason);
            string message = string.Format("Group departure # {0} has been rejected.\r\n\r\n", groupCode);
            string message1 = message + rejectReason;

            //Email.Send(Config.SenderEmail, Config.RecipientEmail + "; " + AgentEmail, subject, message);
            Email.Send(SenderEmail, RecipientEmail, subject, message1);

            // Update Status
            UpdateRejectStatus(groupCode, rejectReason);
        }

        public static void UpdateRejectStatus(string groupCode, string rejectReason)
        {
            string sSQL = @"UPDATE dbo.mt_info SET Status = 'Rejected', RejectReason=@RejectReason WHERE GroupCode = @GroupCode;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupCode", SqlDbType.VarChar, 10).Value = groupCode;
                cmd.Parameters.Add("@RejectReason", SqlDbType.VarChar, 500).Value = rejectReason;
                cmd.ExecuteNonQuery();
            }
        }

        public static string GetAgentEmail(string groupID)
        {
            string sSQL = @"select gm.GroupAgentFlxID, ce.Email, ce.firstname, ce.lastname
                            from grp_Master gm
                            inner join cmn_Employee ce on gm.GroupAgentFlxID = ce.flxid
                            where GroupID = @GroupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@groupID", SqlDbType.VarChar).Value = groupID;
                da.Fill(ds);
                return ds.Tables[0].Rows[0]["Email"].ToString();
            }
        }

        public static void Reopen(string groupCode)
        {
            UpdateStatus(groupCode, "");
        }

        public static DataTable GetPagedList(string departfr, string departto, string status, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            string fields = @" a.packageType, a.TourName, a.groupCode, a.heading, a.DepartureDate, a.ReturnDate, a.ATI, a.SpecialtyGroup, a.template, 
                isnull(a.status,'In Development') as Status, b.TypeDescription, a.DoNotDisplay, i.title as TemplateTitle, a.useDateRange, dateFrom, dateTo  ";
            string filter = string.Format(" (DepartureDate >= '{0}' ", departfr);
            string tables = @" dbo.mt_info a 
                left join mt_type b on b.typecode = a.packagetype 
                left join dbo.mt_templates i on i.template = a.template "; 
            if (sortExpression == "")
                sortExpression = "groupcode";
            if (!String.IsNullOrEmpty(departto))
                filter += string.Format(" AND a.DepartureDate <= '{0}' ", departto);
            if (!String.IsNullOrEmpty(status))
                filter += (status == "In Development") ? " AND a.status is NULL " : string.Format(" AND a.status = '{0}' ", status);
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( a.Heading like '%{0}%' or a.groupcode like '%{0}%' or a.vendorgroupnumber like '%{0}%' ) ", searchstr);
            }
            filter += " ) ";
            if (!String.IsNullOrEmpty(searchstr))
                filter += string.Format(" OR a.groupcode = '{0}' ", searchstr); 
            string ssql = "SELECT * FROM " +
                " (SELECT " + fields + ", ROW_NUMBER() OVER (ORDER BY " + sortExpression + ") as RowNum " +
                " FROM " + tables + " WHERE " + filter + ") as List " +
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

        public static int GetPagedCount(DateTime departfr, DateTime departto, string status, string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static void UpdateDoNotDisplay()
        {
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();

                SqlCommand cmd = new SqlCommand("usp_mt_Info_UpdateDoNotDisplay", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                cmd.ExecuteNonQuery();
            }
        }

    }
}