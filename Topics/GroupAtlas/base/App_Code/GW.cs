using System;
using System.Data;
using System.Data.Odbc;
using System.Collections.Generic;

namespace GM
{

    public class GW
    {

        public static DataTable GetPaxList(string groupId)
        {
            string sSQL = @"SELECT GroupId, Traveler, PartyID, Phone, StatementName, case Status when 'v' then 'Void' when 'o' then 'Active' else '' end AS StatusDesc
                FROM dba.GroupPassenger 
                WHERE GroupId = ?
                AND Status = 'o' 
                ORDER BY PartyID, StatementName DESC";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                OdbcDataAdapter da = new OdbcDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static DataTable GetInvoicedList(string groupId)
        {
            string sSQL = @"SELECT PartyID, InvoiceNumber, InvoiceDate, Traveler, TotalCost, GroupID
                FROM dba.Invoice
                WHERE GroupId = ?
                AND InvoiceDate >= ?
                AND Status <> 'V'
                ORDER BY PartyID, InvoiceNumber, InvoiceDate;";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                OdbcDataAdapter da = new OdbcDataAdapter(sSQL, cn);
                da.SelectCommand.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                da.SelectCommand.Parameters.Add("startdate", OdbcType.Date).Value = StartDate(groupId).Date;
                da.Fill(ds);
                return ds.Tables[0];
            }
        }

        public static decimal GetTotalInvoiced(string groupId)
        {
            string sSQL = @"SELECT isnull(Sum((Totalcost)),0) as TC FROM dba.Invoice WHERE Status <>'v' AND GroupID = ? AND InvoiceDate >= ?";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                OdbcCommand cmd = new OdbcCommand(sSQL, cn);
                cmd.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                cmd.Parameters.Add("startdate", OdbcType.Date).Value = StartDate(groupId).Date;
                return Convert.ToDecimal(cmd.ExecuteScalar());
            }
        }

        public static decimal GetTotalBooked(string groupId)
        {
            string sSQL = @"SELECT c.Data as bkamt 
                FROM dba.Invoice i
                INNER JOIN dba.Comments c ON i.PayID = c.InvPayID 
                WHERE i.PayID = c.InvPayID 
                AND i.Status <> 'v' 
                AND c.LineNum = 90 
                AND i.GroupID = ?
                AND i.InvoiceDate >= ?";
            decimal totBooked = 0;
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                OdbcCommand cmd = new OdbcCommand(sSQL, cn);
                cmd.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                cmd.Parameters.Add("startdate", OdbcType.Date).Value = StartDate(groupId).Date;
                using (OdbcDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (rs.Read())
                        totBooked += Util.parseDec(rs["bkamt"] + "");
                }
            }
            return totBooked;
        }

        public static int GetActivePax(string groupId)
        {
            string sSQL = @"SELECT count(Traveler) as cnt FROM dba.GroupPassenger WHERE Status='o' AND GroupID = ?";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                OdbcCommand cmd = new OdbcCommand(sSQL, cn);
                cmd.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static int GetActiveParty(string groupId)
        {
            string sSQL = @"SELECT count(distinct PartyID) as cnt FROM dba.GroupPassenger WHERE Status='o' AND GroupID = ?";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                OdbcCommand cmd = new OdbcCommand(sSQL, cn);
                cmd.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static int GetActivePhone(string groupId)
        {
            string sSQL = @"SELECT count(distinct Phone) as cnt FROM dba.GroupPassenger WHERE Status='o' AND GroupID = ?";
            using (OdbcConnection cn = new OdbcConnection(Config.gwConnectionString))
            {
                cn.Open();
                OdbcCommand cmd = new OdbcCommand(sSQL, cn);
                cmd.Parameters.Add("groupid", OdbcType.VarChar, 10).Value = groupId;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private static DateTime StartDate(string groupId)
        {
            GroupMaster g = GroupMaster.GetGroupMaster(groupId);
            DateTime startDt = DateTime.Today.AddYears(-6);
            if (Util.isValidDate(g.DepartDate))
                startDt = Convert.ToDateTime(g.DepartDate).AddYears(-4);
            return startDt;
        }

    }
}