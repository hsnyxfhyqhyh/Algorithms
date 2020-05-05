using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class PickList
    {

        private string _code;
        private string _desc;
        public string code
        {
            get { return _code; }
        }
        public string desc
        {
            get { return _desc; }
        }
        public PickList(string code)
        {
            _code = code;
            _desc = code;
        }
        public PickList(string code, string desc)
        {
            _code = code;
            _desc = desc;
        }

        public static List<PickList> GetPickList(string pickType)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT * FROM dbo.grp_PickList WHERE PickType = @PickType and StatusVisible = 'YES' order by sort, pickdesc";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@picktype", SqlDbType.VarChar, 10).Value = pickType;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["pickcode"].ToString().Trim(), rs["pickdesc"].ToString().Trim()));
                }
            }
            return list;
        }

        public static List<PickList> GetGroupAgent(int flexID)
        {
            List<PickList> list = new List<PickList>();
            //string sSQL = @"SELECT e.FlxID, dbo.trim(e.lastname) + ', ' + dbo.trim(e.firstname) AS Agent
            // FROM dbo.cmn_Employee e 
            // WHERE (e.flxid in (SELECT flexid FROM dbo.grp_Coordinator) OR e.flxid = @flexid)
            //    ORDER BY Agent";
            string sSQL = @"SELECT e.FlxID, e.name AS Agent
	            FROM dbo.cmn_Agent e
	            WHERE (e.flxid in (SELECT flexid FROM dbo.grp_Coordinator) OR e.flxid = @flexid)
                ORDER BY e.name";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flexid", SqlDbType.Int).Value = flexID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["flxid"].ToString(), rs["agent"].ToString()));
                }
            }
            return list;
        }
    
        public static List<PickList> GetAffinityAgent(int flexID)
        {
            List<PickList> list = new List<PickList>();
            //string sSQL = @"SELECT e.FlxID, dbo.trim(e.lastname) + ', ' + dbo.trim(e.firstname) AS Agent
            // FROM dbo.cmn_Employee e 
            // WHERE (e.status = 'Active' OR e.flxid = @flexid)
            //    ORDER BY Agent";
            string sSQL = @"SELECT e.FlxID, e.name AS Agent
	            FROM dbo.cmn_Agent e 
                ORDER BY e.name";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flexid", SqlDbType.Int).Value = flexID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["flxid"].ToString(), rs["agent"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetTravelAgent(int flexID)
        {
            List<PickList> list = new List<PickList>();
            //string sSQL = @"SELECT e.FlxID, dbo.trim(e.lastname) + ', ' + dbo.trim(e.firstname) AS Agent
	           // FROM dbo.cmn_Employee e 
	           // WHERE (e.status = 'Active' OR e.flxid = @flexid)
            //    ORDER BY Agent";
            string sSQL = @"SELECT e.FlxID, e.name AS Agent
	            FROM dbo.cmn_Agent e 
                ORDER BY e.name";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flexid", SqlDbType.Int).Value = flexID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["flxid"].ToString(), rs["agent"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetItinerary(string provider, int itinID)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT	i.ItinID, i.Itinerary 
	            FROM	dbo.grp_ItinID i (nolock)
	            INNER JOIN dbo.grp_Master m (nolock) ON i.ItinID = m.ItinID 
	            WHERE (m.Provider=@provider OR i.ItinID=@itinID) 
	            GROUP BY i.ItinID, i.Itinerary 
                ORDER BY Itinerary";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                cmd.Parameters.Add("@itinID", SqlDbType.Int).Value = itinID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["ItinID"].ToString(), rs["Itinerary"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetLocation()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT locode, Name2 FROM dbo.vw_Location ORDER BY Name2";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["locode"].ToString(), rs["Name2"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetPortCity(string portCity)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT	PortCity, PortCityName 
                FROM dbo.vw_PortCity
                WHERE (ISNUMERIC(PortCity) = 1 OR PortCity=@PortCity)
                ORDER BY PortCityName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@portcity", SqlDbType.VarChar).Value = portCity;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["PortCity"].ToString(), rs["PortCityName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetProvider(string provider)
        {
            List<PickList> list = new List<PickList>();
            //string sSQL = @"SELECT	p.Provider, p.ProvName 
            // FROM	dbo.trvl_Provider p 
            // WHERE	(p.provider IN (SELECT DISTINCT ProvGroup FROM dbo.trvl_Provider WHERE ProvGroup IS NOT NULL)) OR p.provider=@provider 
            //    ORDER BY ProvName";
            string sSQL = @"SELECT	p.vendorCode as Provider, p.vendorCode + ' - ' + p.vendorName as ProvName 
                            FROM	dbo.mt_vendor p
                            WHERE	(p.vendorCode IN (SELECT vendorCode FROM dbo.mt_vendor where vendorName IS NOT NULL)) OR p.vendorCode=@provider 
                            ORDER BY p.vendorName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["Provider"].ToString(), rs["ProvName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetProvider2()
        {
            List<PickList> list = new List<PickList>();
            //string sSQL = @"SELECT Provider, ProvName, ProvGroup, ProvName + '  ('+Provider+')'  as ProvDesc  
            //    FROM dbo.trvl_Provider
            //    WHERE Provider In (SELECT distinct ProvGroup FROM dbo.trvl_Provider WHERE ProvGroup IS NOT NULL)
            //    ORDER BY ProvName";
            string sSQL = @"SELECT v.vendorCode as Provider, v.vendorName as ProvName, v.vendorCode as ProvGroup, v.vendorName + '  ('+v.vendorCode+')'  as ProvDesc  
                            FROM mt_vendor v
                            --left outer join Vendor_Group vg on v.vendorCode = vg.vendorCode
                            WHERE v.vendorCode In (SELECT distinct vendorCode FROM mt_vendor WHERE vendorCode IS NOT NULL)
                            ORDER BY ProvName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["provider"].ToString(), rs["ProvName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetShip(string provider, int shipID)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"Select	ShipID, ShipName 
	            FROM	dbo.grp_ShipID  
	            WHERE	(Provider=@provider OR ShipID=@shipID)
                        and status = 'Active' and DeleteStatus = 0
                ORDER BY ShipName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                cmd.Parameters.Add("@shipID", SqlDbType.Int).Value = shipID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["ShipID"].ToString(), rs["ShipName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetTour(string provider, int tourID)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT	t.TourID, t.TourName 
	            FROM	dbo.grp_TourID t 
	            INNER JOIN	dbo.grp_Master m ON t.TourID = m.TourID 
	            WHERE	(m.Provider=@provider OR t.tourid=@tourid)
	            GROUP BY t.TourID, t.TourName
                ORDER BY t.TourName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                cmd.Parameters.Add("@tourID", SqlDbType.Int).Value = tourID;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["TourID"].ToString(), rs["TourName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetAffinityGroupName()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT DISTINCT AffinityGroupName FROM dbo.grp_Master (nolock) WHERE AffinityGroupName Is Not Null
                ORDER BY AffinityGroupName;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["AffinityGroupName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetCxlPolicy(string provider)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT	PolicyID, Provider + ' ' + [Policy Name] as PolicyDesc
	            FROM dbo.grp_CxlPolicy 
	            WHERE Provider=@provider ORDER BY PolicyDesc;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["PolicyID"].ToString(), rs["PolicyDesc"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetTaskType()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT TaskType, TaskName FROM dbo.grp_TaskType ORDER BY TaskTypeOrder";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["TaskType"].ToString(), rs["TaskName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetState()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT StateCode, StateName FROM dbo.grp_State ORDER BY StateName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["StateCode"].ToString(), rs["StateName"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetPackageType(string revType)
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"SELECT PackageType, PackageTypeName FROM dbo.grp_PackageType ORDER BY PackageTypeName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                    {
                        string packageType = rs["packagetype"] + "";
                        if (revType.ToUpper() == "S" || revType.ToUpper() == "ST") // Cruise 
                        {
                            if (packageType != "ROOM")
                                list.Add(new PickList(packageType, rs["PackageTypeName"].ToString()));
                        }
                        else
                        {
                            if (packageType != "CABIN")
                                list.Add(new PickList(packageType, rs["PackageTypeName"].ToString()));
                        }
                    }
                }
            }
            return list;
        }

        public static List<PickList> GetDescription()
        {
            List<PickList> list = new List<PickList>();
            string sSQL = @"select DescCode from dbo.grp_Description order by DescCode";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        list.Add(new PickList(rs["DescCode"].ToString()));
                }
            }
            return list;
        }

        public static List<PickList> GetAddlDetails()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("DMC"));
            list.Add(new PickList("MAC"));
            list.Add(new PickList("Pre-Trip"));
            list.Add(new PickList("Post-Trip"));
            list.Add(new PickList("Chairman"));
            list.Add(new PickList("President"));
            list.Add(new PickList("CEO"));
            return list;
        }

        //public static List<PickList> GetDescription()
        //{
        //    List<PickList> list = new List<PickList>();
        //    list.Add(new PickList("DMC"));
        //    list.Add(new PickList("MAC"));
        //    list.Add(new PickList("Pre-Trip"));
        //    list.Add(new PickList("Post-Trip"));
        //    list.Add(new PickList("Chairman"));
        //    list.Add(new PickList("President"));
        //    list.Add(new PickList("CEO"));
        //    list.Add(new PickList("World Traveller"));
        //    return list;
        //}

        public static List<PickList> GetSecLevels()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("4", "Agent Booking"));
            list.Add(new PickList("1", "Full Access"));
            list.Add(new PickList("2", "General Use"));
            list.Add(new PickList("3", "Report Only"));
            return list;
        }

        public static List<PickList> GetStatus()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("Active"));
            list.Add(new PickList("Inactive"));
            return list;
        }

        public static List<PickList> GetOptionType()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("TAX"));
            list.Add(new PickList("FEE"));
            list.Add(new PickList("MSC"));
            list.Add(new PickList("OTH"));
            list.Add(new PickList("EXC"));

            return list;
        }


        public static List<PickList> GetBookingStatus()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("A", "Active"));
            list.Add(new PickList("C", "Cancelled"));
            list.Add(new PickList("W", "Wait List"));
            return list;
        }

        public static List<PickList> GetQuestionType()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("TEXT", "Single-line Text"));
            list.Add(new PickList("TEXTAREA", "Multi-line Text"));
            list.Add(new PickList("CHECKBOX", "Checkbox"));
            list.Add(new PickList("DROPDOWNLIST", "Dropdown List"));
            list.Add(new PickList("CHECKBOXLIST", "Checkbox List"));
            list.Add(new PickList("RADIOBUTTONLIST", "RadioButton List"));
            return list;
        }

        public static List<PickList> GetQuestionGroupType()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("FLIGHT", "Flight"));
            list.Add(new PickList("OTHER", "Other"));
            list.Add(new PickList("PAX", "Pax"));
            return list;
        }

        public static string GetQuestionTypeDesc(string code)
        {
            List<PickList> list = GetQuestionType();
            foreach (PickList m in list)
            {
                if (m.code == code)
                    return m.desc;
            }
            return code;
        }

        public static List<PickList> GetRateType()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("P", "Per Person"));
            list.Add(new PickList("B", "Per Booking"));
            return list;
        }

        public static string GetRateTypeDesc(string code)
        {
            List<PickList> list = GetRateType();
            foreach (PickList m in list)
            {
                if (m.code == code)
                    return m.desc;
            }
            return code;
        }

        public static List<PickList> GetGender()
        {
            List<PickList> list = new List<PickList>();
            list.Add(new PickList("M", "Male"));
            list.Add(new PickList("F", "Female"));
            list.Add(new PickList("N", "N/A"));
            return list;
        }

        public static string GetGenderDesc(string code)
        {
            List<PickList> list = GetGender();
            foreach (PickList m in list)
            {
                if (m.code == code)
                    return m.desc;
            }
            return code;
        }

    }
}