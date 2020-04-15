using System;
using System.Data;
using System.Web; 
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{


    public class mtDownload
    {

        public static void ExportGroupInfo(string dlType)
        {
            string gCode = "";
            string eCode = "";
            if (dlType == "ATI")
	            gCode = "AM";
            else if (dlType == "CRU")
            {
	            gCode = "C";
	            eCode = "YC";
            }
            else if (dlType == "CTG")
            {
	            gCode = "CT";
	            eCode = "YD";
            }
            else if (dlType == "TGD")
            {
	            gCode = "T";
	            eCode = "YT";
            }
            
            string sSQL = @"select a.*, b.ShipName, c.RegionDescription, d.TypeDescription, e.VendorName,
                f.departurepoint as DeparturePointName, g.DestinationDescription, 
                h.title as DescriptionTitle, i.title as TemplateTitle
                from mt_info a
                left join grp_ShipID b on b.ShipID = a.shipcode
                left join mt_region c on c.regioncode = a.regioncode
                left join mt_type d on d.typecode = a.packagetype
                left join mt_vendor e on e.vendorcode = a.vendorgroupcode 
                left join mt_departurepoint f on f.departurecode = a.departurepoint
                left join mt_destination g on g.destinationcode = a.destinationcode 
                left join mt_description h on h.id = a.[description]
                left join mt_templates i on i.template = a.template  
                where (a.packageType = @gcode or a.packageType = @ecode)
                and a.status = 'Approved' 
                order by created DESC";

            // Header
            HttpContext ctx = HttpContext.Current;
            ctx.Response.Clear();
            ctx.Response.Charset = "";
            ctx.Response.Buffer = true;
            ctx.Response.AddHeader("Content-Disposition", "attachment; filename=GroupExport.csv");
            ctx.Response.ContentType = "text/csv";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@gcode", SqlDbType.VarChar).Value = gCode;
                cmd.Parameters.Add("@ecode", SqlDbType.VarChar).Value = eCode;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                // Column header
               for (int c = 0; c < rs.FieldCount; c++)
                {
                    if (c > 0)
                        ctx.Response.Write(",");
                    ctx.Response.Write(rs.GetName(c).ToString());
                }
                ctx.Response.Write("\r\n"); 
                /*
                 *  System.String
                    System.Boolean
                    System.Int32
                    System.DateTime
                    System.Decimal
                 * */

                // Details
                while (rs.Read())
                {
                    for (int c = 0; c < rs.FieldCount; c++)
                    {
                        if (c > 0)
                            ctx.Response.Write(",");
                        string val = (rs[c] == DBNull.Value) ? "" : rs[c].ToString();
                        if (val != "")
                        {
                            if (rs.GetFieldType(c).ToString() == "System.DateTime")
                                val = rs.GetDateTime(c).ToShortDateString();
                            else if (rs.GetFieldType(c).ToString() == "System.Boolean")
                                val = (rs.GetBoolean(c)) ? "Yes" : "No";
                        }
                        ctx.Response.Write(Util.FormatCSVField(val));
                    }
                    ctx.Response.Write("\r\n");
                }
            }
            ctx.Response.End();
        }

    }
}