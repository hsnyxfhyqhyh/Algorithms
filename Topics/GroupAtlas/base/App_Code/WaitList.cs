using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class WaitList
    {
        public int waitListID = 0;
        public string groupID = "";
        public string firstName = "";
        public string lastName = "";
        public string phone = "";
        public string email = "";
        public int agentFlexID = 0;
        public int paxCnt = 0;
        public bool isConverted = false;
        public DateTime created;

        public static WaitList GetWaitList(int waitListID)
        {
            string sSQL = "SELECT * FROM dbo.grp_WaitList WHERE waitlistid=@waitlistid";
            WaitList w = new WaitList();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@waitlistid", SqlDbType.Int).Value = waitListID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (!rs.Read())
                    return null;
                w.waitListID = Convert.ToInt32(rs["waitlistid"]);
                w.groupID = rs["groupid"] + "";
                w.firstName = rs["firstname"] + "";
                w.lastName = rs["lastname"] + "";
                w.phone = rs["phone"] + "";
                w.email = rs["email"] + "";
                w.agentFlexID = Util.parseInt(rs["agentflexid"]);
                w.paxCnt =  Convert.ToInt32(rs["paxcnt"]);
                w.isConverted = Convert.ToBoolean(rs["isconverted"]);
                w.created = Convert.ToDateTime(rs["created"]);
            }
            return w;
        }

        public static int Add(WaitList w)
        {
            string sSQL = @"INSERT INTO dbo.grp_WaitList (GroupID, FirstName, LastName, Phone, Email, AgentFlexID, PaxCnt, IsConverted)
                VALUES (@GroupID, @FirstName, @LastName, @Phone, @Email, @AgentFlexID, @PaxCnt, @IsConverted);
                SELECT @@IDENTITY"; ;
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = w.groupID;
                cmd.Parameters.Add("@FirstName", SqlDbType.VarChar, 50).Value = w.firstName;
                cmd.Parameters.Add("@LastName", SqlDbType.VarChar, 50).Value = w.lastName;
                cmd.Parameters.Add("@Phone", SqlDbType.VarChar, 20).Value = w.phone;
                cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = w.email;
                cmd.Parameters.Add("@AgentFlexID", SqlDbType.Int).Value = DBNull.Value;
                if (w.agentFlexID > 0)
                    cmd.Parameters["@AgentFlexID"].Value = w.agentFlexID;
                cmd.Parameters.Add("@PaxCnt", SqlDbType.Int).Value = w.paxCnt;
                cmd.Parameters.Add("@IsConverted", SqlDbType.Bit).Value = w.isConverted;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static void Update(WaitList w)
        {
            string sSQL = @"UPDATE dbo.grp_WaitList SET FirstName=@FirstName, LastName=@LastName, Phone=@Phone, Email=@Email, 
                AgentFlexID=@AgentFlexID, PaxCnt=@PaxCnt, IsConverted=@IsConverted
                WHERE WaitListID = @WaitListID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@WaitListID", SqlDbType.Int).Value = w.waitListID;
                cmd.Parameters.Add("@FirstName", SqlDbType.VarChar, 50).Value = w.firstName;
                cmd.Parameters.Add("@LastName", SqlDbType.VarChar, 50).Value = w.lastName;
                cmd.Parameters.Add("@Phone", SqlDbType.VarChar, 20).Value = w.phone;
                cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = w.email;
                cmd.Parameters.Add("@AgentFlexID", SqlDbType.Int).Value = DBNull.Value;
                if (w.agentFlexID > 0)
                    cmd.Parameters["@AgentFlexID"].Value = w.agentFlexID;
                cmd.Parameters.Add("@PaxCnt", SqlDbType.Int).Value = w.paxCnt;
                cmd.Parameters.Add("@IsConverted", SqlDbType.Bit).Value = w.isConverted;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetPagedList(string departfr, string departto, int grouptype, string revtype, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            string fields = @" w.WaitListID, m.DepartDate, m.ReturnDate, m.GroupID, m.GroupName, p.PickDesc as GroupTypeDesc, p2.PickDesc as RevTypeDesc,  
                w.PaxCnt, ga.Agent as BookingAgentName, w.FirstName, w.LastName, w.Phone, w.Email, w.Created, IsConverted ";
            string filter = string.Format(" (m.departdate >= '{0}' ", departfr);
            string tables = @" dbo.grp_WaitList w
                INNER JOIN dbo.grp_Master m on m.GroupID = w.GroupID
                LEFT JOIN dbo.grp_PickList p on p.PickType = 'GROUPTYPE' AND p.PickCode = m.GroupType
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = m.RevType
                LEFT JOIN dbo.vw_Employee ga on ga.FlxID = w.AgentFlexID ";
            if (sortExpression == "")
                sortExpression = "w.waitlistid";
            if (!String.IsNullOrEmpty(departto))
                filter += string.Format(" AND m.departdate <= '{0}' ", departto);
            if (grouptype > 0)
                filter += string.Format(" AND m.grouptype = {0} ", grouptype);
            if (!String.IsNullOrEmpty(revtype))
                filter += string.Format(" AND m.revtype = '{0}' ", revtype);
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( w.LastName like '%{0}%' or w.FirstName like '%{0}%' or w.Email like '%{0}%' or w.phone like '%{0}%' or 
                    ga.Agent like '%{0}%' or m.GroupName like '%{0}%' ) ", searchstr);
            }
            filter += " ) ";
            if (!String.IsNullOrEmpty(searchstr))
                filter += string.Format(" OR m.groupid = '{0}' ", searchstr);
            if (!String.IsNullOrEmpty(searchstr) && Util.isInteger(searchstr) )
                filter += string.Format(" OR w.waitlistid = {0} ", searchstr); 
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

        public static int GetPagedCount(DateTime departfr, DateTime departto, int grouptype, string revtype, string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static int GetPagedCount()
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

    }
}