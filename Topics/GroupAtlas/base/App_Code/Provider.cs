using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Provider
    {


        public static void CreateGroup(string provGroup, string provider)
        {
            string sSQL = @"UPDATE dbo.trvl_Provider SET ProvGroup = @provGroup WHERE Provider = @provider";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                cmd.Parameters.Add("@provgroup", SqlDbType.VarChar).Value = provGroup;
                cmd.ExecuteNonQuery();
            }
        }

        public static void RemoveMember( List<string> provList)
        {
            string sSQL = @"UPDATE dbo.trvl_Provider SET ProvGroup = NULL WHERE Provider = @provider";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (string provider in provList)
                    {
                        SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                        cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
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

        public static void AddMembers(string provGroup, List<string> provList)
        {
            string sSQL = @"UPDATE dbo.trvl_Provider SET ProvGroup = @provgroup WHERE Provider = @provider";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    foreach (string provider in provList)
                    {
                        SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                        cmd.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                        cmd.Parameters.Add("@provgroup", SqlDbType.VarChar).Value = provGroup;
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

        public static void ChangePrimary(string provOld, string provNew)
        {
            string sSQL = @"UPDATE dbo.trvl_Provider SET ProvGroup = @provnew WHERE provGroup = @provold;
                UPDATE dbo.grp_Master SET Provider = @provnew WHERE Provider = @provold;
                UPDATE dbo.grp_ShipID SET Provider = @provnew WHERE Provider = @provold;
                UPDATE dbo.grp_CxlPolicy SET Provider = @provnew WHERE Provider = @provold;";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@provold", SqlDbType.VarChar).Value = provOld;
                    cmd.Parameters.Add("@provnew", SqlDbType.VarChar).Value = provNew;
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

        public static DataTable GetPrimaryList()
        {
            string sSQL = @"SELECT Provider, ProvName, ProvGroup, ProvName + '  ('+Provider+')'  as ProvDesc  
                FROM dbo.trvl_Provider
                WHERE Provider In (SELECT distinct ProvGroup FROM dbo.trvl_Provider WHERE ProvGroup IS NOT NULL)
                ORDER BY ProvName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetMemberList(string provider)
        {
            string sSQL = @"SELECT provider, ProvName FROM dbo.trvl_Provider 
                WHERE ProvGroup = @provider 
                ORDER BY ProvName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@provider", SqlDbType.VarChar).Value = provider;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetList(bool unassigned, string searchstr)
        {
            string sSQL = @"SELECT top 500 Provider, ProvName, ProvGroup FROM dbo.trvl_Provider 
                WHERE (ProvName like @searchstr or Provider like @searchstr)
                AND (@unassigned = 0 or ProvGroup IS NULL)
                AND isnull(ProvName,'') <> '' 
                ORDER BY ProvName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@searchstr", SqlDbType.VarChar).Value = '%' + searchstr.Replace("'", "''") + '%';
                da.SelectCommand.Parameters.Add("@unassigned", SqlDbType.Bit).Value = unassigned;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetPagedList(bool unassigned, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            string fields = " Provider, ProvName, ProvGroup ";
            string filter = " provider <> '' AND isnull(ProvName,'') <> '' ";
            string tables = " dbo.trvl_provider ";
            if (sortExpression == "")
                sortExpression = "provname";
            if (unassigned)
                filter += " AND ProvGroup IS NULL ";
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( ProvName like '%{0}%' or Provider like '%{0}%') ", searchstr);
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

        public static int GetPagedCount(bool unassigned, string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static int GetPagedCount()
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }


    }
}