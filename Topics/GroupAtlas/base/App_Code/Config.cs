using System;
using System.Configuration; 
using System.Web;
using System.Net; 

namespace GM
{
	public class Config
	{
		public static string ConnectionString
		{
          get { return ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString; }
		}

        public static string gwConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["gwConnectionString"].ConnectionString; }
        }

        public static string AdminEmail
        {
            get { return (ConfigurationManager.AppSettings["AdminEmail"]); }
        }

        public static string RecipientEmail
        {
            get { return (ConfigurationManager.AppSettings["RecipientEmail"]); }
        }

        public static string SenderEmail
        {
            get { return (ConfigurationManager.AppSettings["SenderEmail"]); }
        }

        public static string SSRSUrlTemplate
        {
            get { return (ConfigurationManager.AppSettings["SSRSUrlTemplate"]); }
        }
        public static string BIPortalUrlTemplate
        {
            get { return (ConfigurationManager.AppSettings["BIPortalUrlTemplate"]); }
        }
        public static string BIPortalUrl
        {
            get { return (ConfigurationManager.AppSettings["BIPortalUrl"]); }
        }

        public static string HdrComment
        {
            get { return (ConfigurationManager.AppSettings["HdrComment"]); }
        }

    }
}
