using System;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace GM
{
    
    public class SecurityDet
    {
        public string ntLogon;
        public int secLevel;
        public string agentName;
        public string groupID_allow;
        public string groupID_allow2;
        public string groupID_allow3;
        public string groupID_allow4;
        public string groupID_allow5;
    }
    
    public class Security
    {

        // Website Authentication/Authorization
        public static void Initialize()
        {
            //string sSQL = "SELECT SecLevel, GroupID_Allow FROM dbo.grp_Security WHERE NTLogon = @UserID";
            string sSQL = "SELECT SecLevel FROM dbo.grp_Security WHERE NTLogon = @UserID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@userid", SqlDbType.VarChar).Value = Util.CurrentUser();
                using (SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    if (rs.Read())
                    {
                        HttpContext.Current.Items.Add("SecLevel", Util.parseInt(rs["SecLevel"]));
                        //HttpContext.Current.Items.Add("GroupID_Allow", rs["groupID_Allow"].ToString());
                    }
                }
            }
        }

        public static int SecLevel()
        {
            return (HttpContext.Current.Items["SecLevel"] == null) ? 0 : Convert.ToInt32(HttpContext.Current.Items["SecLevel"]);
        }

        public static bool SecClear(int maxLevel)
        {
           return (SecLevel() > maxLevel) ? false : true;
        }

        public static bool IsAdmin()
        {
            return (SecLevel() == 1) ? true : false;
        }

        // Admin

        public static SecurityDet Get(string ntlogon)
        {
            string sSQL = @"SELECT s.NTLogon, s.SecLevel, ltrim(rtrim(lastname)) + ', ' + ltrim(rtrim(firstname)) as AgentName, 
                s.GroupID_Allow, s.GroupID_Allow2, s.GroupID_Allow3, s.GroupID_Allow4, s.GroupID_Allow5
                FROM dbo.grp_Security s
                LEFT JOIN dbo.cmn_employee e on e.ntlogon = s.ntlogon
                WHERE s.NTLogon = @ntlogon";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ntlogon", SqlDbType.VarChar).Value = ntlogon;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                SecurityDet s = new SecurityDet ();
                s.ntLogon = rs["ntlogon"].ToString();
                s.secLevel = Util.parseInt(rs["seclevel"]);
                s.agentName = rs["agentname"].ToString();
                s.groupID_allow = rs["groupID_Allow"].ToString();
                s.groupID_allow2 = rs["groupID_Allow2"].ToString();
                s.groupID_allow3 = rs["groupID_Allow3"].ToString();
                s.groupID_allow4 = rs["groupID_Allow4"].ToString();
                s.groupID_allow5 = rs["groupID_Allow5"].ToString();
                return s;
            }
        }

        public static void Update(SecurityDet s)
        {
            string sSQL = @"IF EXISTS(SELECT * FROM dbo.grp_Security WHERE ntlogon=@ntlogon)
                UPDATE dbo.grp_Security SET seclevel = @seclevel, GroupID_Allow = @GroupID_Allow,
                GroupID_Allow2 = @GroupID_Allow2, GroupID_Allow3 = @GroupID_Allow3, GroupID_Allow4 = @GroupID_Allow4, GroupID_Allow5 = @GroupID_Allow5
                WHERE ntlogon = @ntlogon;
                ELSE
                INSERT INTO dbo.grp_Security (ntlogon, seclevel, GroupID_Allow, GroupID_Allow2, GroupID_Allow3, GroupID_Allow4, GroupID_Allow5) 
                VALUES (@ntlogon, @seclevel, @GroupID_Allow, @GroupID_Allow2, @GroupID_Allow3, @GroupID_Allow4, @GroupID_Allow5);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ntlogon", SqlDbType.VarChar).Value = s.ntLogon;
                cmd.Parameters.Add("@seclevel", SqlDbType.SmallInt).Value = s.secLevel;
                cmd.Parameters.Add("@GroupID_Allow", SqlDbType.VarChar).Value = s.groupID_allow;
                cmd.Parameters.Add("@GroupID_Allow2", SqlDbType.VarChar).Value = s.groupID_allow2;
                cmd.Parameters.Add("@GroupID_Allow3", SqlDbType.VarChar).Value = s.groupID_allow3;
                cmd.Parameters.Add("@GroupID_Allow4", SqlDbType.VarChar).Value = s.groupID_allow4;
                cmd.Parameters.Add("@GroupID_Allow5", SqlDbType.VarChar).Value = s.groupID_allow5;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string ntLogon)
        {
            string sSQL = @"DELETE FROM dbo.grp_Security WHERE ntlogon = @ntlogon";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@ntlogon", SqlDbType.VarChar).Value = ntLogon;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            //string sSQL = @"SELECT s.NTLogon, s.SecLevel, 
	           // case s.SecLevel when 1 then 'Full Access' when 2 then 'General Use' when 3 then 'Report Only' else '' end as SecLevelDesc, 
	           // ltrim(rtrim(lastname)) + ', ' + ltrim(rtrim(firstname)) as AgentName
            //    FROM dbo.grp_Security s
            //    LEFT JOIN dbo.cmn_employee e on e.ntlogon = s.ntlogon
            //    ORDER BY s.ntlogon";
            string sSQL = @"SELECT s.NTLogon, s.SecLevel, 
	            case s.SecLevel when 1 then 'Full Access' when 2 then 'General Use' when 3 then 'Report Only' when 4 then 'Agent Booking' else '' end as SecLevelDesc, 
	            ltrim(rtrim(lastname)) + ', ' + ltrim(rtrim(firstname)) as AgentName, 
                s.GroupID_Allow + '   ' +  s.GroupID_Allow2 + '   ' +  s.GroupID_Allow3 + '   ' +  s.GroupID_Allow4 + '  ' +  s.GroupID_Allow5 as GroupID_Allow 
                FROM dbo.grp_Security s
                LEFT JOIN dbo.cmn_employee e on e.ntlogon = s.ntlogon
                ORDER BY s.ntlogon";
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

