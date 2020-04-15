using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Employee
    {

        public static DataTable GetPagedList(string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            string fields = " firstname, lastname, flxid, title, status, CiDescrip ";
            string filter = " flxid > 0 ";
            string tables = " dbo.cmn_employee ";
            if (sortExpression == "")
                sortExpression = "flxid";
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( lastname like '%{0}%' or firstname like '%{0}%' or (rtrim(firstname) + ' ' + ltrim(lastname)) like '%{0}%'  
                    or (rtrim(lastname) + ', ' + ltrim(firstname)) like '%{0}%' or title like '%{0}%' or cidescrip like '%{0}%' ", searchstr);
                if (Util.isInteger(searchstr))
                    filter += string.Format(" or flxid = {0} ", searchstr);

                filter += ") ";
            }
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

        public static int GetPagedCount(string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static int GetPagedCount()
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static DataTable GetTitle()
        {
            string sSQL = @"select distinct ce.title as Title, ' (' + try_cast(count(ce.title) as varchar(10)) + ')' as [count]
                            from cmn_Employee ce
                            left join Cmn_Agent ca on ce.title = ca.title
                            where ce.status = 'Active'
                            and ca.title is null
                            group by ce.title
                            order by ce.title;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static void InsertTitle(string Title)
        {
            string sSQL = @"insert into cmn_Agent (flxid, location, title, name)
                            select flxid, location, title, Rtrim(lastname) + ', ' + Rtrim(firstname) as name
                            from cmn_Employee where status = 'Active' and title = @Title;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Title", SqlDbType.VarChar, 255).Value = Title;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetEmployee()
        {
            string sSQL = @"select RID, flxid, location, title, name from cmn_Agent order by name;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static void DeleteTitle(string Title)
        {
            string sSQL = @"delete from cmn_Agent where title = @Title;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Title", SqlDbType.VarChar, 255).Value = Title;
                cmd.ExecuteNonQuery();
            }
        }

        public static void DeleteEmployee(int flxid)
        {
            string sSQL = @"delete from cmn_Agent where flxid = @flxid;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@flxid", SqlDbType.Int).Value = flxid;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetAGentNames(string Title)
        {
            string sSQL = @"select lastname, firstname, Title from cmn_Employee where status = 'Active' and title = @Title order by title;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@Title", SqlDbType.VarChar, 255).Value = Title;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }
    }
}
