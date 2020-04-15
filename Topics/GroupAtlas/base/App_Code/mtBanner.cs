using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{


    public class mtBannerTemplate
    {
        private string _template;
        private string _title;
        private string _bannerPosition;

        public string template  { get { return _template; } }
        public string title { get { return _title; } }
        public string bannerPosition { get { return _bannerPosition; } }

        public mtBannerTemplate(string template, string title, string bannerPosition)
        {
            this._template = template;
            this._title = title;
            this._bannerPosition = bannerPosition;
        }
    }
    
    
    public class mtBanner
    {

        public int id = 0;
	    public string title;
	    public string fileName;
        public List<mtBannerTemplate> templateList;

		public static mtBanner GetBanner(int id)
		{
            string SQL_BANNER = "SELECT * FROM dbo.mt_Banners WHERE id=@id";
            string SQL_BANNER_TEMPLATE = @"SELECT b.template, t.title, b.bannerPosition 
                FROM mt_banner_templates b 
                INNER JOIN mt_templates t ON t.template = b.template 
                WHERE b.bannerID = @bannerid
                ORDER BY t.sort, t.title, b.bannerPosition desc";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(SQL_BANNER, cn);
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (!rs.Read())
                    return null;
                mtBanner b = new mtBanner();
                b.id = (int)rs["id"];
                b.title = rs["title"] + "";
                b.fileName = rs["filename"] + "";
                rs.Close();
                //
                List<mtBannerTemplate> list = new List<mtBannerTemplate>();
                cmd = new SqlCommand(SQL_BANNER_TEMPLATE, cn);
                cmd.Parameters.Add("@bannerid", SqlDbType.Int).Value = id;
                rs = cmd.ExecuteReader();
                while (rs.Read())
                {
                    string template = rs["template"] + "";
                    string title = rs["title"] + "";
                    string bannerPosition = rs["bannerposition"]+"";
                    list.Add(new mtBannerTemplate (template, title, bannerPosition));
                }
                rs.Close();

                return b;
            }
		}

        public static DataTable GetTemplateEdit(int bannerID)
        {
            string sSQL = @"select t.title, tb.template, tb.bannerPosition, 
                cast(case when bt.template is NULL then 0 else 1 end as bit) as selected
                from mt_templates_banners tb 
                INNER JOIN mt_templates t ON tb.template = t.template 
                LEFT JOIN mt_banner_templates bt ON bt.bannerID = @bannerid AND bt.template = tb.template AND bt.bannerPosition = tb.bannerPosition
                ORDER BY selected desc, t.sort, t.title, tb.bannerPosition desc";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("@bannerid", SqlDbType.Int).Value = bannerID;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int Update(mtBanner b)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_Banners (title, FileName) VALUES (@title, @FileName); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_Banners SET title = @title, fileName = @FileName WHERE id = @id";
            string SQL_DELETE_TEMPLATE = @"DELETE FROM mt_banner_templates WHERE bannerid = @bannerid";
            string SQL_INSERT_TEMPLATE = @"INSERT INTO dbo.mt_banner_templates(template, bannerID, bannerPosition) VALUES (@template, @bannerID, @bannerPosition)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    if (b.id > 0)
                    {
                        cmd = new SqlCommand(SQL_UPDATE, cn, trn);
                        cmd.Parameters.Add("@id", SqlDbType.Int).Value = b.id;
                        FillCmd(cmd, b);
                        cmd.ExecuteNonQuery();
                    }
                    else
                    {
                        cmd = new SqlCommand(SQL_INSERT, cn, trn);
                        FillCmd(cmd, b);
                        b.id = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                    //
                    cmd = new SqlCommand(SQL_DELETE_TEMPLATE, cn, trn);
                    cmd.Parameters.Add("@bannerid", SqlDbType.Int).Value = b.id;
                    cmd.ExecuteNonQuery();
                    //
                    foreach (mtBannerTemplate t in b.templateList)
                    {
                        cmd = new SqlCommand(SQL_INSERT_TEMPLATE, cn, trn);
                        cmd.Parameters.Add("@bannerid", SqlDbType.Int).Value = b.id;
                        cmd.Parameters.Add("@template", SqlDbType.VarChar, 50).Value = t.template;
                        cmd.Parameters.Add("@bannerposition", SqlDbType.VarChar, 50).Value = t.bannerPosition;
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
            return b.id;
        }

        private static void FillCmd(SqlCommand cmd, mtBanner b)
        {
            cmd.Parameters.Add("@title", SqlDbType.VarChar, 100).Value = b.title;
            cmd.Parameters.Add("@filename", SqlDbType.VarChar, 100).Value = b.fileName;
        }

        public static void Delete(int id)
        {
            string sSQL = @"DELETE FROM mt_banner_templates WHERE bannerid = @id;
                DELETE FROM dbo.mt_Banners WHERE id = @id";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(sSQL, cn, trn);
                    cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
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

        public static DataTable GetList()
        {
            string sSQL = @"select b.id, b.title, b.filename, 
	                (select a.template+'<br>' as [text()]
	                     from 
		                    (select t.title +' ('+bt.bannerPosition+')' as template
		                    from mt_banner_templates bt 
		                    LEFT JOIN mt_templates t ON t.template = bt.template 
		                    where bt.bannerID = b.id) a 
	                     order by 1
	                     for XML PATH ('')
	                ) as templates
                from mt_banners b
                order by b.title";
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