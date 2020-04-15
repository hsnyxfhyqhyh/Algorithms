using System;
using System.Net.Mail;
using System.IO;

namespace GM
{
	public class Email
	{

        public static bool Send(string emailfr, string emailto, string subject, string body)
        {
            MailMessage mail = new MailMessage(emailfr, emailto, subject, body);
            SmtpClient mailClient = new SmtpClient();
            try
            {
                mailClient.Send(mail);
                return true;
            }
            catch
            {
                return false;
            }
            finally
            {
                mail.Dispose();
            }
        }

	}
}
