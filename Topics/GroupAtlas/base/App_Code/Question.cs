using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Question
    {

        public int questionID = 0;
	    public string questionName = "";
	    public string type = "";
        public string list = "";
        public string revtype = "";
        public string answer = "";
        public string groupidList = "";
        public string questiongroup = "";
        public string displayorder = "";

		public static Question GetQuestion(int questionID)
		{
            string sSQL = "SELECT * FROM dbo.grp_Question WHERE questionID=@questionID order by QuestionSort, QuestionName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@questionID", SqlDbType.Int).Value = questionID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                return FillQuestion(rs);
            }
		}

        public static List<Question> GetPaxQuestions(int passengerID, string revType, string groupID)
        {
            string sSQL = @"SELECT q.*, isnull(p.answer ,'') as answer
                FROM dbo.grp_Question q 
                LEFT JOIN dbo.grp_PaxQuestion p ON p.questionid=q.questionid AND p.passengerid=@passengerid
                WHERE (q.RevType = @RevType OR q.RevType = '')
                AND ( isnull(GroupIDList,'') = '' or (isnull(GroupIDLIst,'') <> '' and patindex('%'+@groupid+'%', GroupIDList) > 0) )
                ORDER BY q.QuestionSort, q.QuestionName";
            List<Question> list = new List<Question>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@passengerid", SqlDbType.Int).Value = passengerID;
                cmd.Parameters.Add("@revtype", SqlDbType.VarChar, 2).Value = revType;
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    Question q = FillQuestion(rs);
                    q.answer = rs["answer"] + "";
                    list.Add(q);
                }
            }
            return list;
        }

        private static Question FillQuestion (SqlDataReader rs)
        {
            Question q = new Question();
            q.questionID = (int)rs["questionID"];
            q.questionName = rs["questionname"] + "";
            q.type = rs["type"] + "";
            q.list = rs["list"] + "";
            q.revtype = rs["revtype"] + "";
            q.groupidList = rs["groupidlist"] + "";
            q.questiongroup = rs["questiongroup"] + "";
            q.displayorder = rs["QuestionSort"] + "";
            return q;            
        }

        public static int Update(Question q)
        {
            string SQL_INSERT = @"INSERT INTO dbo.grp_Question (QuestionGroup, QuestionName, Type, List, RevType, GroupIDList, QuestionSort) 
                VALUES (@QuestionGroup, @QuestionName, @Type, @List, @RevType, @GroupIDList, @QuestionSort); 
                SELECT @@IDENTITY;";
            string SQL_UPDATE = @"UPDATE dbo.grp_Question SET QuestionGroup=@QuestionGroup, QuestionName=@QuestionName, Type=@Type, List=@List, RevType=@RevType, GroupIDList=@GroupIDList, QuestionSort=@QuestionSort  
                WHERE questionID = @questionID"; 
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd;
                if (q.questionID > 0)
                {
                    cmd = new SqlCommand(SQL_UPDATE, cn);
                    cmd.Parameters.Add("@questionID", SqlDbType.Int).Value = q.questionID;
                    FillCmd(cmd, q);
                    cmd.ExecuteNonQuery();
                }
                else
                {
                    cmd = new SqlCommand(SQL_INSERT, cn);
                    FillCmd(cmd, q);
                    q.questionID = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }
            return q.questionID;
        }

        private static void FillCmd(SqlCommand cmd, Question q)
        {
            cmd.Parameters.Add("@questionGroup", SqlDbType.VarChar, 50).Value = q.questiongroup;
            cmd.Parameters.Add("@questionname", SqlDbType.VarChar, 50).Value = q.questionName;
            cmd.Parameters.Add("@type", SqlDbType.VarChar, 20).Value = q.type;
            cmd.Parameters.Add("@list", SqlDbType.VarChar, 2000).Value = q.list;
            cmd.Parameters.Add("@revtype", SqlDbType.VarChar, 2).Value = q.revtype;
            cmd.Parameters.Add("@groupidlist", SqlDbType.VarChar, 2000).Value = q.groupidList;
            cmd.Parameters.Add("@QuestionSort", SqlDbType.Int).Value = Convert.ToInt32(q.displayorder);
        }

        public static void Delete(int questionID)
        {
            string sSQL = @"DELETE FROM dbo.grp_PaxQuestion WHERE QuestionID=@QuestionID;
                DELETE FROM dbo.grp_Question WHERE questionID = @questionID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@questionID", SqlDbType.Int).Value = questionID;
                cmd.ExecuteNonQuery();
            }
        }

        public static DataTable GetList()
        {
            string sSQL = @"SELECT q.*, isnull(p2.PickDesc,'All') as RevTypeDesc,
                case when exists(select 1 from dbo.grp_PaxQuestion where QuestionID=q.QuestionID and isnull(Answer,'') <> '') then 'Y' else 'N' end as PaxExist 
                FROM dbo.grp_Question q 
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = q.RevType
                ORDER by q.QuestionSort, q.QuestionName";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                SqlDataAdapter da = new SqlDataAdapter(sSQL, cn);
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static void UpdateSort(int questionID, int QuestonSort)
        {
            string sSQL = @"Update grp_Question Set QuestionSort = @QuestionSort where QuestionID = @QuestionID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@questionID", SqlDbType.Int).Value = questionID;
                cmd.Parameters.Add("@QuestionSort", SqlDbType.Int).Value = QuestonSort;
                cmd.ExecuteNonQuery();
            }
        }

    }
}