using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class mtDescription
    {
        public int id = 0;
        public string title;
	    public string description;
        public bool status;


        public static mtDescription GetDescription(int id)
		{
            string sSQL = "SELECT * FROM dbo.mt_Description WHERE id=@id and DisableStatus=0 order by title";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                mtDescription d = new mtDescription();
                d.id = (int)rs["id"];
                d.title = rs["title"] + "";
                d.description = rs["description"] + "";
                d.status = Convert.ToBoolean(rs["status"]);
                return d;
            }
		}

        public static int Update(mtDescription d)
        {
            string SQL_INSERT = @"INSERT INTO dbo.mt_Description (title, description, status, DisableStatus) VALUES (@title, @description, @status, 0); SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.mt_Description SET title = @title, description = @description, status=@status, DisableStatus = 0 WHERE id = @id"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (d.id > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@id", SqlDbType.Int).Value = d.id;
                    cmd.Parameters.Add("@title", SqlDbType.VarChar, 100).Value = d.title;
                    cmd.Parameters.Add("@description", SqlDbType.VarChar, 1000).Value = d.description;
                    cmd.Parameters.Add("@status", SqlDbType.Bit).Value = d.status;
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    cmd.Parameters.Add("@title", SqlDbType.VarChar, 100).Value = d.title;
                    cmd.Parameters.Add("@description", SqlDbType.VarChar, 1000).Value = d.description;
                    cmd.Parameters.Add("@status", SqlDbType.Bit).Value = d.status;
                    d.id = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return d.id;
        }

        public static void Delete(int id)
        {
            //string sSQL = @"IF EXISTS(SELECT 1 FROM dbo.mt_info WHERE description=@id)
            string sSQL = @"IF EXISTS(SELECT 1 FROM mt_Description d 
                                        inner join mt_info a on d.id = a.description
                                        where d.id = @id 
                                        and getdate() < (select max(b.DepartureDate) from mt_info b where b.description = d.id))
                BEGIN
                    RaisError ('Cannot delete! There are Flyers associated with the selected description.', 16, 1);
                    RETURN;
                END
                if exists(select status from mt_description where id=@id and status = 1)
                BEGIN
                    RaisError ('Cannot delete! Selected description is saved for future use.', 16, 1);
                    RETURN;
                END
                UPDATE dbo.mt_Description set DisableStatus = 1 WHERE id=@id";

                //UPDATE d
                //Set d.DisableStatus = 1
                //FROM mt_Description d
                //inner join mt_info a on d.id = a.description
                //where d.id = @id and d.status = 0 and getdate() > (select max(b.DepartureDate) from mt_info b where b.description = d.id)";

                //Delete mt_Description 
                //FROM mt_Description d
                //inner join mt_info a on d.id = a.description
                //where d.id = @id and d.status = 0 and getdate() > (select max(b.DepartureDate) from mt_info b where b.description = d.id)";

                //DELETE FROM dbo.mt_Description WHERE id = @id";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = id;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            //string sSQL = @"SELECT * FROM dbo.mt_Description ORDER by title";
            //string sSQL = @"SELECT distinct d.id, d.title, d.description, d.status, max(Convert(varchar(10),a.DepartureDate, 101)) as departuredate
            //string sSQL = @"SELECT d.id, d.title, d.description, d.status, Convert(varchar(10),a.DepartureDate, 101) as departuredate
            //        FROM mt_Description d
            //        left outer join mt_info a on d.id = a.description
            //        Where d.DisableStatus = 0 
            //        group by d.id, d.title, d.description, d.status, a.departuredate
            //        order by d.title";

            //DisableStatus:  0=Visible, 1=Hide
            string sSQL = @"SELECT d1.id, d1.title, d1.description, d1.status, a1.DepartureDate as departuredate, d1.DisableStatus
                            into #temp1
                            FROM mt_Description d1
                            left join mt_info a1 on d1.id = a1.description
                            where d1.DisableStatus = 0
                            group by d1.id, d1.title, d1.description, d1.status, a1.DepartureDate, d1.DisableStatus
                            order by d1.title, a1.departuredate

                            select t1.id, t1.title, t1.description, t1.status, Convert(varchar(10), max(t1.departuredate), 101) as departuredate, t1.DisableStatus
                            from #temp1 t1
                            where Exists(select 1 from #temp1 t2
                            where t2.id = t1.id
                            and t2.title = t1.title
                            and t2.status = t1.status
                            group by t2.id, t2.title, t2.status
                            --having t1.departuredate = max(t2.departuredate))
                            having t1.DisableStatus = 0)
                            group by t1.id, t1.title, t1.description, t1.status, t1.DisableStatus
                            order by title, departuredate";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetListActive()
        {
            //string sSQL = @"SELECT * FROM dbo.mt_Description ORDER by title";
            //string sSQL = @"SELECT distinct d.id, d.title, d.description, d.status, max(Convert(varchar(10),a.DepartureDate, 101)) as departuredate
            //string sSQL = @"SELECT d.id, d.title, d.description, d.status, Convert(varchar(10),a.DepartureDate, 101) as departuredate
            //        FROM mt_Description d
            //        left outer join mt_info a on d.id = a.description
            //        Where d.DisableStatus = 0 
            //        group by d.id, d.title, d.description, d.status, a.departuredate
            //        order by d.title";

            //DisableStatus:  0=Visible, 1=Hide
            string sSQL = @"SELECT d1.id, d1.title, d1.description, d1.status, a1.DepartureDate as departuredate, d1.DisableStatus
                            into #temp1
                            FROM mt_Description d1
                            left join mt_info a1 on d1.id = a1.description
                            where d1.DisableStatus = 0
                            group by d1.id, d1.title, d1.description, d1.status, a1.DepartureDate, d1.DisableStatus
                            order by d1.title, a1.departuredate

                            select t1.id, t1.title, t1.description, t1.status, Convert(varchar(10), max(t1.departuredate), 101) as departuredate, t1.DisableStatus
                            from #temp1 t1
                            where Exists(select 1 from #temp1 t2
                            where t2.id = t1.id
                            and t2.title = t1.title
                            and t2.status = t1.status
                            and t1.status = 1
                            group by t2.id, t2.title, t2.status
                            --having t1.departuredate = max(t2.departuredate))
                            having t1.DisableStatus = 0)
                            group by t1.id, t1.title, t1.description, t1.status, t1.DisableStatus
                            order by title, departuredate";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static int DeleteAllByExpiredDate()
        {
            int iReturn = 0;
            string sSQL = @"UPDATE d
                            Set d.DisableStatus = 1
                            FROM mt_Description d
                            left join mt_info a on d.id = a.description
                            where d.status = 0 and getdate() > (select max(b.DepartureDate) from mt_info b where b.description = d.id)";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                iReturn = cmd.ExecuteNonQuery();
            }

            return iReturn;
        }
        public static int DeleteAllByEmptyDate()
        {
            int iReturn = 0;
            string sSQL2 = @"UPDATE d
                            Set d.DisableStatus = 1
                            FROM mt_Description d
                            left join mt_info a on d.id = a.description
                            where d.status = 0 and a.DepartureDate is null or a.DepartureDate = ''";

            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                
                cn.Open();

                SqlCommand cmd2 = new SqlCommand(sSQL2, cn);
                iReturn = cmd2.ExecuteNonQuery();
            }
            return iReturn;
        }
    }
}