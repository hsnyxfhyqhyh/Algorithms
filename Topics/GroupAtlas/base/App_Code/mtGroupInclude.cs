using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtGroupInclude
    {

        public static void Add(string groupCode, string placement, string include)
        {
            string sSQL = @"INSERT INTO dbo.mt_includes (group_id, placement, [include], incl_num)
                VALUES (@groupcode, @placement, @include, 
		        (select isnull(max(incl_num),0)+1 from dbo.mt_includes where group_id = @groupcode and placement = @placement) );
                EXEC usp_mtUpdateIncludes @groupcode, @placement";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                cmd.Parameters.Add("@placement", SqlDbType.VarChar, 50).Value = placement;
                cmd.Parameters.Add("@include", SqlDbType.NText).Value = include;
                cmd.ExecuteNonQuery();
            }
        }

        public static void Update(string groupCode, string placement, int includeid, string include, string incl_num)
        {
            string sSQL = @"UPDATE dbo.mt_Includes SET include = @include, incl_num = @incl_num
                WHERE group_id = @groupcode AND placement = @placement AND includeid = @includeid"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                cmd.Parameters.Add("@placement", SqlDbType.VarChar, 50).Value = placement;
                cmd.Parameters.Add("@includeid", SqlDbType.Int).Value = includeid;
                cmd.Parameters.Add("@include", SqlDbType.NText).Value = include;
                cmd.Parameters.Add("@incl_num", SqlDbType.Int).Value = Convert.ToInt32(incl_num);
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdateIncludeSort(string groupCode, int includeid, int incl_num)
        {
            string sSQL = @"UPDATE dbo.mt_Includes SET incl_num = @incl_num WHERE group_id = @groupcode and includeid = @includeid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupcode", SqlDbType.VarChar, 10).Value = groupCode;
                cmd.Parameters.Add("@includeid", SqlDbType.Int).Value = includeid;
                cmd.Parameters.Add("@incl_num", SqlDbType.Int).Value = Convert.ToInt32(incl_num);
                cmd.ExecuteNonQuery();
            }
        }

        public static void Delete(string groupCode, string placement, int includeid)
        {
            string sSQL = @"DELETE FROM dbo.mt_Includes WHERE group_id = @groupcode and placement = @placement and includeid = @includeid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                    cmd.Parameters.Add("@placement", SqlDbType.VarChar).Value = placement;
                    cmd.Parameters.Add("@includeid", SqlDbType.Int).Value = includeid;
                    cmd.ExecuteNonQuery();
                    ReSequence(groupCode, placement, cn, trn);
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

        private static void ReSequence(string groupCode, string placement, SqlConnection cn, SqlTransaction trn)
        {
            string SQL_SELECT = @"SELECT includeid, incl_num, include FROM dbo.mt_Includes 
                WHERE group_id = @groupcode and placement = @placement order by incl_num, includeid";
            string SQL_UPDATE = @"UPDATE dbo.mt_Includes SET incl_num = @inclnum
                WHERE group_id = @groupcode and placement = @placement and includeid = @includeid";
            DataSet ds = new DataSet();
            SqlDataAdapter da = new SqlDataAdapter(SQL_SELECT, cn);
            da.SelectCommand.Transaction = trn;
            da.SelectCommand.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
            da.SelectCommand.Parameters.Add("@placement", SqlDbType.VarChar).Value = placement;
            da.Fill(ds);
            int num = 0;
            foreach (DataRow dr in ds.Tables[0].Rows)
            {
                num++;
                if (Convert.ToInt32(dr["incl_num"]) != num)
                {
                    SqlCommand cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                    cmd.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                    cmd.Parameters.Add("@placement", SqlDbType.VarChar).Value = placement;
                    cmd.Parameters.Add("@includeid", SqlDbType.Int).Value = Convert.ToInt32(dr["includeid"]);
                    cmd.Parameters.Add("@inclnum", SqlDbType.Int).Value = num;
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static DataTable GetList(string groupCode, string placement)
        {
            string sSQL = @"SELECT includeid, incl_num, group_id as groupcode, placement, include FROM dbo.mt_Includes 
                WHERE group_id = @groupcode and placement = @placement order by incl_num, includeid";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@groupcode", SqlDbType.VarChar).Value = groupCode;
                da.SelectCommand.Parameters.Add("@placement", SqlDbType.VarChar).Value = placement;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }
    }
}