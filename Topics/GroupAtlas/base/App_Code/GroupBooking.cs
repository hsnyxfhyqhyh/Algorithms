using System;
using System.Data;
using System.Web;
using System.Data.SqlClient;
using System.Collections.Generic;

namespace GM
{

    public class Bill
    {
        private int _billID;
        private int _bookingID;
        private string _description;
        private decimal _rate;
        private int _qty;
        private int _packageid;
        private int _optionid;
        private decimal _commission; 

        public int billID { get { return _billID; } }
        public int bookingID { get { return _bookingID; } }
        public string description { get { return _description; } }
        public decimal rate { get { return _rate; } }
        public int qty { get { return _qty; } }
        public int packageid { get { return _packageid; } }
        public int optionid { get { return _optionid; } }
        public decimal amount 
        { 
            get { return rate * qty; } 
        }

        public decimal commission
        {
            get { return _commission * qty; }
        }

        public Bill(int billID, int bookingID, string description, decimal rate, int qty, int packageid, int optionid)
        {
            this._billID = billID;
            this._bookingID = bookingID;
            this._description = description;
            this._rate = rate;
            this._qty = qty;
            this._packageid = packageid;
            this._optionid = optionid;
            
        }

        public Bill(int billID, int bookingID, string description, decimal rate, int qty, int packageid, int optionid, decimal commission)
        {
            this._billID = billID;
            this._bookingID = bookingID;
            this._description = description;
            this._rate = rate;
            this._qty = qty;
            this._packageid = packageid;
            this._optionid = optionid;
            this._commission = commission;
        }
    }

    public class Payment
    {
        private int _paymentID;
        private int _bookingID;
        private decimal _amount;
        private DateTime _pmtDate;
        private string _pmtType;
        private string _pmtTypeDesc;
        private string _refNum;
        private string _payerName;
        private string _source;

        public int paymentID { get { return _paymentID; } }
        public int bookingID { get { return _bookingID; } }
        public decimal amount { get { return _amount; } }
        public DateTime pmtDate { get { return _pmtDate; } }
        public string pmtType { get { return _pmtType; } }
        public string pmtTypeDesc { get { return _pmtTypeDesc; } }
        public string refNum { get { return _refNum; } }
        public string payerName { get { return _payerName; } }
        public string source { get { return _source; } }

        public Payment(int paymentID, int bookingID, decimal amount, DateTime pmtDate, string pmtType, string pmtTypeDesc, string refNum, string payerName, string source)
        {
            this._paymentID = paymentID;
            this._bookingID = bookingID;
            this._amount = amount;
            this._pmtDate = pmtDate;
            this._pmtType = pmtType;
            this._pmtTypeDesc = pmtTypeDesc;
            this._refNum = refNum;
            this._payerName = payerName;
            this._source = source;
        }
    }

    public class Passenger
    {
        int _passengerID = 0;
        int _bookingID = 0;
        string _firstName = "";
        string _middleName = "";
        string _lastName = "";
        string _badgeName = "";
        string _address = "";
        string _city = "";
        string _state = "";
        string _zip = "";
        string _email = "";
        string _homePhone = "";
        string _cellPhone = "";
        string _gender = "";
        string _birthDate = "";
        bool _isPrimary = false;
        string _emerName = "";
        string _emerPhone = "";
        string _emerRelation = "";
        List<PaxQuestion> _paxQuestions = null;

        public int passengerID { get { return _passengerID; } set { _passengerID = value; } }
        public int bookingID { get { return _bookingID; } set { _bookingID = value; } }
        public string firstName { get { return _firstName; } set { _firstName = value; } }
        public string middleName { get { return _middleName; } set { _middleName = value; } }
        public string lastName { get { return _lastName; } set { _lastName = value; } }
        public string badgeName { get { return _badgeName; } set { _badgeName = value; } }
        public string address { get { return _address; } set { _address = value; } }
        public string city { get { return _city; } set { _city = value; } }
        public string state { get { return _state; } set { _state = value; } }
        public string zip { get { return _zip; } set { _zip = value; } }
        public string email { get { return _email; } set { _email = value; } }
        public string homePhone { get { return _homePhone; } set { _homePhone = value; } }
        public string cellPhone { get { return _cellPhone; } set { _cellPhone = value; } }
        public string gender { get { return _gender; } set { _gender = value; } }
        public string birthDate { get { return _birthDate; } set { _birthDate = value; } }
        public bool isPrimary { get { return _isPrimary; } set { _isPrimary = value; } }
        public string emerName { get { return _emerName; } set { _emerName = value; } }
        public string emerPhone { get { return _emerPhone; } set { _emerPhone = value; } }
        public string emerRelation { get { return _emerRelation; } set { _emerRelation = value; } }
        public List<PaxQuestion> paxQuestions { get { return _paxQuestions; } set { _paxQuestions = value; } }

        public string Name { get { return string.Format("{0} {1} {2}", firstName, middleName, lastName); } }


        public Passenger()
        {

        }

        public Passenger(int passengerID, int bookingID, string firstName, string middleName, string lastName, string badgeName, string address, string city, string state, 
            string zip, string email, string homePhone, string cellPhone, string gender, string birthDate, bool isPrimary, string emerName, string emerPhone, 
            string emerRelation)
        {
            this._passengerID = passengerID;
            this._bookingID = bookingID;
            this._firstName = firstName;
            this._middleName = middleName;
            this._lastName = lastName;
            this._badgeName = badgeName;
            this._address = address;
            this._city = city;
            this._state = state;
            this._zip = zip;
            this._email = email;
            this._homePhone = homePhone;
            this._cellPhone = cellPhone;
            this._gender = gender;
            this._birthDate = birthDate;
            this._isPrimary = isPrimary;
            this._emerName = emerName;
            this._emerPhone = emerPhone;
            this._emerRelation = emerRelation;
        }
    }

    public class PaxQuestion
    {
        private int _questionID;
        private string _questionName;
        private string _answer;
        public int questionID { get { return _questionID; } }
        public string questionName { get { return _questionName; } }
        public string answer { get { return _answer; } }
        public PaxQuestion(int questionID, string questionName, string answer)
        {
            this._questionID = questionID;
            this._questionName = questionName;
            this._answer = answer;
        }
    }

    public class GroupBooking
    {
        public int bookingID = 0;
        public string groupID = "";
        public DateTime bookingDate;
        public int agentFlexID = 0;
        public string source = "";
        public string status = "";
        public string statusDesc = "";
        public string agentName = "";
        public int paxCnt = 0;
        public List<Bill> billList = null;
        public List<Passenger> paxList = null;
        public List<Payment> pmtList = null;
        public decimal billAmt 
        {
            get 
            {
                decimal tot = 0;
                foreach (Bill b in billList)
                    tot += b.amount;
                return tot;
            }
        }

        public decimal billCommission
        {
            get
            {
                decimal tot = 0;
                foreach (Bill b in billList)
                    tot += b.commission;
                return tot;
            }
        }

        public decimal pmtAmt
        {
            get
            {
                decimal tot = 0;
                foreach (Payment b in pmtList)
                    tot += b.amount;
                return tot;
            }
        }
        public decimal dueAmt
        {
            get { return (billAmt - pmtAmt); }
        }


        public static GroupBooking GetBooking(int bookingID)
        {
            string sSQL = "SELECT * FROM dbo.vw_grp_Booking WHERE bookingID=@bookingID";
            GroupBooking b = new GroupBooking();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@bookingid", SqlDbType.Int).Value = bookingID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.SingleRow);
                if (!rs.Read())
                    return null;
                b.bookingID = Convert.ToInt32(rs["bookingid"]);
                b.groupID = rs["groupid"]+"";
                b.bookingDate = Convert.ToDateTime(rs["bookingdate"]);
                b.agentFlexID = Util.parseInt(rs["agentflexid"]);
                b.source = rs["source"]+"";
                b.status = rs["status"]+"";
                b.paxCnt = Convert.ToInt32(rs["paxcnt"]);
                b.agentName = rs["agentname"] + "";
                b.statusDesc = rs["statusdesc"] + "";
            }
            b.billList = GetBills(bookingID);
            b.pmtList = GetPayments(bookingID);
            b.paxList = GetPassengers(bookingID);
            return b;
        }

        public static List<Bill> GetBills(int bookingID)
        {
            string sSQL = "SELECT * FROM dbo.grp_Bill WHERE bookingID = @bookingID order by billid";
            List<Bill> list = new List<Bill>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@bookingid", SqlDbType.Int).Value = bookingID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int billid = Convert.ToInt32(rs["billid"]);
                    int bookingid = Convert.ToInt32(rs["bookingid"]);
                    string description = rs["description"] + "";
                    int qty = Convert.ToInt32(rs["qty"]);
                    decimal rate = Convert.ToDecimal(rs["rate"]);
                    int packageid = Util.parseInt(rs["packageid"]);
                    int optionid = Util.parseInt(rs["optionid"]);
                    decimal commission = Convert.ToDecimal(rs["commission"]);
                    list.Add(new Bill(billid, bookingid, description, rate, qty, packageid, optionid, commission));
                }
            }
            return list;
        }

        public static List<Payment> GetPayments(int bookingID)
        {
            string sSQL = @"SELECT p.*, l.PickDesc as PmtTypeDesc 
                FROM dbo.grp_Payment p 
                LEFT JOIN dbo.grp_PickList l on l.PickType = 'PMTTYPE' AND l.PickCode = p.PmtType 
                WHERE bookingID = @bookingID order by paymentid";
            List<Payment> list = new List<Payment>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@bookingid", SqlDbType.Int).Value = bookingID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int paymentid = Convert.ToInt32(rs["paymentid"]);
                    int bookingid = Convert.ToInt32(rs["bookingid"]);
                    decimal amount = Convert.ToDecimal(rs["amount"]);
                    DateTime pmtdate = Convert.ToDateTime(rs["pmtdate"]);
                    string pmttype = rs["pmttype"] + "";
                    string pmttypedesc = rs["pmttypedesc"] + "";
                    string refnum = rs["refnum"] + "";
                    string payername = rs["payername"] + "";
                    string source = rs["source"] + "";
                    list.Add(new Payment(paymentid, bookingid, amount, pmtdate, pmttype, pmttypedesc, refnum, payername, source));
                }
            }
            return list;
        }

        public static Passenger GetPassenger(int passengerID)
        {
            string sSQL = "SELECT * FROM dbo.grp_Passenger WHERE passengerID = @passengerID";
            List<Passenger> list = new List<Passenger>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@passengerid", SqlDbType.Int).Value = passengerID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                return FillPassenger(rs);
            }
        }

        public static Passenger GetPrimPassenger(int bookingID)
        {
            string sSQL = "SELECT * FROM dbo.grp_Passenger WHERE bookingID=@bookingID AND IsPrimary=1";
            List<Passenger> list = new List<Passenger>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@bookingid", SqlDbType.Int).Value = bookingID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                if (!rs.Read())
                    return null;
                return FillPassenger(rs);
            }
        }

        public static List<Passenger> GetPassengers(int bookingID)
        {
            string sSQL = "SELECT * FROM dbo.grp_Passenger WHERE bookingID = @bookingID order by passengerid";
            List<Passenger> list = new List<Passenger>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@bookingid", SqlDbType.Int).Value = bookingID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                    list.Add(FillPassenger(rs));
            }
            return list;
        }

        private static Passenger FillPassenger(SqlDataReader rs)
        {
            Passenger p = new Passenger();
            p.passengerID = Convert.ToInt32(rs["passengerid"]);
            p.bookingID = Convert.ToInt32(rs["bookingid"]);
            p.firstName = rs["firstname"] + "";
            p.middleName = rs["middlename"] + "";
            p.lastName = rs["lastname"] + "";
            p.badgeName = rs["badgename"] + "";
            p.address = rs["address"] + "";
            p.city = rs["city"] + "";
            p.state = rs["state"] + "";
            p.zip = rs["zip"] + "";
            p.email = rs["email"] + "";
            p.homePhone = rs["homephone"] + "";
            p.cellPhone = rs["cellphone"] + "";
            p.gender = rs["gender"] + "";
            p.birthDate = (rs["birthdate"] is DBNull) ? "" : Convert.ToDateTime(rs["birthdate"]).ToShortDateString(); ;
            p.isPrimary = (bool)rs["isprimary"];
            p.emerName = rs["emername"] + "";
            p.emerPhone = rs["emerphone"] + "";
            p.emerRelation = rs["emerrelation"] + "";
            return p;
        }

        public static int Add(GroupBooking b)
        {
            string SQL_INSERT_BOOKING = @"INSERT INTO dbo.grp_Booking (GroupID, BookingDate, AgentFlexID, Source, Status, PaxCnt)
                VALUES (@GroupID, @BookingDate, @AgentFlexID, @Source, @Status, @PaxCnt);
                SELECT @@IDENTITY;";
            string SQL_INSERT_PAX = @"INSERT INTO dbo.grp_Passenger(BookingID, FirstName, MiddleName, LastName, BadgeName, Address, City, State, Zip, Email, 
                    HomePhone, CellPhone, Gender, BirthDate, IsPrimary, EmerName, EmerPhone, EmerRelation)
                VALUES (@BookingID, @FirstName, @MiddleName, @LastName, @BadgeName, @Address, @City, @State, @Zip, @Email, 
                    @HomePhone, @CellPhone, @Gender, @BirthDate, @IsPrimary, @EmerName, @EmerPhone, @EmerRelation);
                SELECT @@IDENTITY;";
            string SQL_INSERT_BILL = @"INSERT INTO dbo.grp_Bill (BookingID, Description, Rate, Qty, PackageID, OptionID)   
                VALUES (@BookingID, @Description, @Rate, @Qty, @PackageID, @OptionID) ";
            string SQL_INSERT_PAXQUES = @"INSERT INTO dbo.grp_PaxQuestion (PassengerID, QuestionID, Answer)
                VALUES (@PassengerID, @QuestionID, @Answer);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(SQL_INSERT_BOOKING, cn, trn);
                    cmd.Parameters.Add("@GroupID", SqlDbType.VarChar, 6).Value = b.groupID;
                    cmd.Parameters.Add("@BookingDate", SqlDbType.DateTime).Value = b.bookingDate;
                    cmd.Parameters.Add("@AgentFlexID", SqlDbType.Int).Value = DBNull.Value;
                    if (b.agentFlexID > 0)
                        cmd.Parameters["@AgentFlexID"].Value = b.agentFlexID;
                    cmd.Parameters.Add("@Source", SqlDbType.VarChar).Value = b.source;

                    //cmd.Parameters.Add("@Status", SqlDbType.VarChar, 1).Value = "A";
                    cmd.Parameters.Add("@Status", SqlDbType.VarChar, 1).Value = b.status;

                    cmd.Parameters.Add("@PaxCnt", SqlDbType.Int).Value = b.paxCnt;
                    b.bookingID = Convert.ToInt32(cmd.ExecuteScalar());
                    foreach (Passenger p in b.paxList)
                    {
                        cmd = new SqlCommand(SQL_INSERT_PAX, cn, trn);
                        cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                        cmd.Parameters.Add("@FirstName", SqlDbType.VarChar, 50).Value = p.firstName;
                        cmd.Parameters.Add("@MiddleName", SqlDbType.VarChar, 50).Value = p.middleName;
                        cmd.Parameters.Add("@LastName", SqlDbType.VarChar, 50).Value = p.lastName;
                        cmd.Parameters.Add("@BadgeName", SqlDbType.VarChar, 50).Value = p.badgeName;
                        cmd.Parameters.Add("@Address", SqlDbType.VarChar, 100).Value = p.address;
                        cmd.Parameters.Add("@City", SqlDbType.VarChar, 50).Value = p.city;
                        cmd.Parameters.Add("@State", SqlDbType.VarChar, 2).Value = p.state;
                        cmd.Parameters.Add("@Zip", SqlDbType.VarChar, 10).Value = p.zip;
                        cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = p.email;
                        cmd.Parameters.Add("@HomePhone", SqlDbType.VarChar, 20).Value = p.homePhone;
                        cmd.Parameters.Add("@CellPhone", SqlDbType.VarChar, 20).Value = p.cellPhone;
                        cmd.Parameters.Add("@Gender", SqlDbType.VarChar, 1).Value = p.gender;
                        cmd.Parameters.Add("@BirthDate", SqlDbType.DateTime).Value = DBNull.Value;
                        if (p.birthDate != "")
                            cmd.Parameters["@BirthDate"].Value = Convert.ToDateTime(p.birthDate);
                        cmd.Parameters.Add("@IsPrimary", SqlDbType.Bit).Value = p.isPrimary;
                        cmd.Parameters.Add("@EmerName", SqlDbType.VarChar, 50).Value = p.emerName;
                        cmd.Parameters.Add("@EmerPhone", SqlDbType.VarChar, 50).Value = p.emerPhone;
                        cmd.Parameters.Add("@EmerRelation", SqlDbType.VarChar, 25).Value = p.emerRelation;
                        p.passengerID = Convert.ToInt32(cmd.ExecuteScalar());
                        if (p.paxQuestions != null)
                        {
                            foreach (PaxQuestion q in p.paxQuestions)
                            {
                                if (q.answer.Length > 0)
                                {
                                    cmd = new SqlCommand(SQL_INSERT_PAXQUES, cn, trn);
                                    cmd.Parameters.Add("@PassengerID", SqlDbType.Int).Value = p.passengerID;
                                    cmd.Parameters.Add("@QuestionID", SqlDbType.Int).Value = q.questionID;
                                    cmd.Parameters.Add("@Answer", SqlDbType.VarChar, 500).Value = q.answer;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    foreach (Bill l in b.billList)
                    {
                        cmd = new SqlCommand(SQL_INSERT_BILL, cn, trn);
                        cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                        cmd.Parameters.Add("@Description", SqlDbType.VarChar, 100).Value = l.description;
                        cmd.Parameters.Add("@Rate", SqlDbType.Decimal).Value = l.rate;
                        cmd.Parameters.Add("@Qty", SqlDbType.Int).Value = l.qty;
                        cmd.Parameters.Add("@PackageID", SqlDbType.Int).Value = DBNull.Value;
                        if (l.packageid > 0)
                            cmd.Parameters["@PackageID"].Value = l.packageid;
                        cmd.Parameters.Add("@OptionID", SqlDbType.Int).Value = DBNull.Value;
                        if (l.optionid > 0)
                            cmd.Parameters["@OptionID"].Value = l.optionid;
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
            return b.bookingID;
        }


        public static int Update(GroupBooking b)
        {
            string SQL_UPDATE_BOOKING = @"UPDATE dbo.grp_Booking 
                SET AgentFlexID=@AgentFlexID, Status=@Status, PaxCnt=@PaxCnt
                WHERE BookingID = @BookingID";
            string SQL_DELETE = @"DELETE q 
                FROM dbo.grp_PaxQuestion q 
                INNER JOIN dbo.grp_Passenger p ON p.PassengerID = q.PassengerID
                WHERE p.BookingID = @BookingID;
                DELETE FROM dbo.grp_Passenger WHERE BookingID = @BookingID;
                DELETE FROM dbo.grp_Bill WHERE BookingID = @BookingID;";
            string SQL_INSERT_PAX = @"INSERT INTO dbo.grp_Passenger(BookingID, FirstName, MiddleName, LastName, BadgeName, Address, City, State, Zip, Email, 
                    HomePhone, CellPhone, Gender, BirthDate, IsPrimary, EmerName, EmerPhone, EmerRelation)
                VALUES (@BookingID, @FirstName, @MiddleName, @LastName, @BadgeName, @Address, @City, @State, @Zip, @Email, 
                    @HomePhone, @CellPhone, @Gender, @BirthDate, @IsPrimary, @EmerName, @EmerPhone, @EmerRelation);
                SELECT @@IDENTITY;";
            string SQL_INSERT_BILL = @"INSERT INTO dbo.grp_Bill (BookingID, Description, Rate, Qty, PackageID, OptionID)   
                VALUES (@BookingID, @Description, @Rate, @Qty, @PackageID, @OptionID) ";
            string SQL_INSERT_PAXQUES = @"INSERT INTO dbo.grp_PaxQuestion (PassengerID, QuestionID, Answer)
                VALUES (@PassengerID, @QuestionID, @Answer);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(SQL_UPDATE_BOOKING, cn, trn);
                    cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                    cmd.Parameters.Add("@AgentFlexID", SqlDbType.Int).Value = DBNull.Value;
                    if (b.agentFlexID > 0)
                        cmd.Parameters["@AgentFlexID"].Value = b.agentFlexID;
                    cmd.Parameters.Add("@Status", SqlDbType.VarChar, 1).Value = b.status;
                    cmd.Parameters.Add("@PaxCnt", SqlDbType.Int).Value = b.paxCnt;
                    cmd.ExecuteNonQuery();
                    cmd = new SqlCommand(SQL_DELETE, cn, trn);
                    cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                    cmd.ExecuteNonQuery();
                    foreach (Passenger p in b.paxList)
                    {
                        cmd = new SqlCommand(SQL_INSERT_PAX, cn, trn);
                        cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                        cmd.Parameters.Add("@FirstName", SqlDbType.VarChar, 50).Value = p.firstName;
                        cmd.Parameters.Add("@MiddleName", SqlDbType.VarChar, 50).Value = p.middleName;
                        cmd.Parameters.Add("@LastName", SqlDbType.VarChar, 50).Value = p.lastName;
                        cmd.Parameters.Add("@BadgeName", SqlDbType.VarChar, 50).Value = p.badgeName;
                        cmd.Parameters.Add("@Address", SqlDbType.VarChar, 100).Value = p.address;
                        cmd.Parameters.Add("@City", SqlDbType.VarChar, 50).Value = p.city;
                        cmd.Parameters.Add("@State", SqlDbType.VarChar, 2).Value = p.state;
                        cmd.Parameters.Add("@Zip", SqlDbType.VarChar, 10).Value = p.zip;
                        cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = p.email;
                        cmd.Parameters.Add("@HomePhone", SqlDbType.VarChar, 20).Value = p.homePhone;
                        cmd.Parameters.Add("@CellPhone", SqlDbType.VarChar, 20).Value = p.cellPhone;
                        cmd.Parameters.Add("@Gender", SqlDbType.VarChar, 1).Value = p.gender;
                        cmd.Parameters.Add("@BirthDate", SqlDbType.DateTime).Value = DBNull.Value;
                        if (p.birthDate != "")
                            cmd.Parameters["@BirthDate"].Value = Convert.ToDateTime(p.birthDate);
                        cmd.Parameters.Add("@IsPrimary", SqlDbType.Bit).Value = p.isPrimary;
                        cmd.Parameters.Add("@EmerName", SqlDbType.VarChar, 50).Value = p.emerName;
                        cmd.Parameters.Add("@EmerPhone", SqlDbType.VarChar, 50).Value = p.emerPhone;
                        cmd.Parameters.Add("@EmerRelation", SqlDbType.VarChar, 25).Value = p.emerRelation;
                        p.passengerID = Convert.ToInt32(cmd.ExecuteScalar());
                        if (p.paxQuestions != null)
                        {
                            foreach (PaxQuestion q in p.paxQuestions)
                            {
                                if (q.answer.Length > 0)
                                {
                                    cmd = new SqlCommand(SQL_INSERT_PAXQUES, cn, trn);
                                    cmd.Parameters.Add("@PassengerID", SqlDbType.Int).Value = p.passengerID;
                                    cmd.Parameters.Add("@QuestionID", SqlDbType.Int).Value = q.questionID;
                                    cmd.Parameters.Add("@Answer", SqlDbType.VarChar, 500).Value = q.answer;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    foreach (Bill l in b.billList)
                    {
                        cmd = new SqlCommand(SQL_INSERT_BILL, cn, trn);
                        cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = b.bookingID;
                        cmd.Parameters.Add("@Description", SqlDbType.VarChar, 100).Value = l.description;
                        cmd.Parameters.Add("@Rate", SqlDbType.Decimal).Value = l.rate;
                        cmd.Parameters.Add("@Qty", SqlDbType.Int).Value = l.qty;
                        cmd.Parameters.Add("@PackageID", SqlDbType.Int).Value = DBNull.Value;
                        if (l.packageid > 0)
                            cmd.Parameters["@PackageID"].Value = l.packageid;
                        cmd.Parameters.Add("@OptionID", SqlDbType.Int).Value = DBNull.Value;
                        if (l.optionid > 0)
                            cmd.Parameters["@OptionID"].Value = l.optionid;
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
            return b.bookingID;
        }

        public static void UpdateStatus(int bookingID, int agentFlexID, string status)
        {
            string sSQL = @"UPDATE dbo.grp_Booking SET AgentFlexID=@AgentFlexID, Status=@Status
                WHERE BookingID=@BookingID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = bookingID;
                cmd.Parameters.Add("@AgentFlexID", SqlDbType.Int).Value = DBNull.Value;
                if (agentFlexID > 0)
                    cmd.Parameters["@AgentFlexID"].Value = agentFlexID;
                cmd.Parameters.Add("@Status", SqlDbType.VarChar, 1).Value = status;
                cmd.ExecuteNonQuery();
            }
        }

        public static void UpdatePassenger(Passenger p)
        {
            string sSQL = @"UPDATE dbo.grp_Passenger SET FirstName=@FirstName, MiddleName=@MiddleName, LastName=@LastName, BadgeName=@BadgeName, Address=@Address, 
                City=@City, State=@State, Zip=@Zip, Email=@Email, HomePhone=@HomePhone, CellPhone=@CellPhone, Gender=@Gender, BirthDate=@BirthDate, 
                EmerName=@EmerName, EmerPhone=@EmerPhone, EmerRelation=@EmerRelation
                WHERE passengerID=@PassengerID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@PassengerID", SqlDbType.Int).Value = p.passengerID;
                cmd.Parameters.Add("@FirstName", SqlDbType.VarChar, 50).Value = p.firstName;
                cmd.Parameters.Add("@MiddleName", SqlDbType.VarChar, 50).Value = p.middleName;
                cmd.Parameters.Add("@LastName", SqlDbType.VarChar, 50).Value = p.lastName;
                cmd.Parameters.Add("@BadgeName", SqlDbType.VarChar, 50).Value = p.badgeName;
                cmd.Parameters.Add("@Address", SqlDbType.VarChar, 100).Value = p.address;
                cmd.Parameters.Add("@City", SqlDbType.VarChar, 50).Value = p.city;
                cmd.Parameters.Add("@State", SqlDbType.VarChar, 2).Value = p.state;
                cmd.Parameters.Add("@Zip", SqlDbType.VarChar, 10).Value = p.zip;
                cmd.Parameters.Add("@Email", SqlDbType.VarChar, 100).Value = p.email;
                cmd.Parameters.Add("@HomePhone", SqlDbType.VarChar, 20).Value = p.homePhone;
                cmd.Parameters.Add("@CellPhone", SqlDbType.VarChar, 20).Value = p.cellPhone;
                cmd.Parameters.Add("@Gender", SqlDbType.VarChar, 1).Value = p.gender;
                cmd.Parameters.Add("@BirthDate", SqlDbType.DateTime).Value = DBNull.Value;
                if (p.birthDate != "")
                    cmd.Parameters["@BirthDate"].Value = Convert.ToDateTime(p.birthDate);
                cmd.Parameters.Add("@EmerName", SqlDbType.VarChar, 50).Value = p.emerName;
                cmd.Parameters.Add("@EmerPhone", SqlDbType.VarChar, 50).Value = p.emerPhone;
                cmd.Parameters.Add("@EmerRelation", SqlDbType.VarChar, 25).Value = p.emerRelation;
                cmd.ExecuteNonQuery();
            }
        }

        public static List<PaxQuestion> GetPaxQuestion(int passengerID)
        {
            string sSQL = @"SELECT p.*, q.QuestionNAme
                FROM dbo.grp_PaxQuestion p 
                INNER JOIN dbo.grp_Question q ON q.questionid=p.questionid
                WHERE p.passengerid=@passengerid
                ORDER BY QustionSort, QuestionName";
            List<PaxQuestion> list = new List<PaxQuestion>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@passengerid", SqlDbType.Int).Value = passengerID;
                SqlDataReader rs = cmd.ExecuteReader(CommandBehavior.CloseConnection);
                while (rs.Read())
                {
                    int questionID = Convert.ToInt32(rs["questionid"]);
                    string questionName = rs["questionname"]+"";
                    string answer = rs["answer"]+"";
                    PaxQuestion q = new PaxQuestion (questionID, questionName, answer);
                    list.Add(q);
                }
            }
            return list;
        }

        public static void UpdatePaxQuestion(int passengerID, List<PaxQuestion> quesList)
        {
            string SQL_DELETE = @"DELETE FROM dbo.grp_PaxQuestion WHERE PassengerID=@PassengerID";
            string SQL_INSERT = @"INSERT INTO dbo.grp_PaxQuestion (PassengerID, QuestionID, Answer)
                VALUES (@PassengerID, @QuestionID, @Answer);";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlTransaction trn = cn.BeginTransaction();
                try
                {
                    SqlCommand cmd = new SqlCommand(SQL_DELETE, cn, trn);
                    cmd.Parameters.Add("@PassengerID", SqlDbType.Int).Value = passengerID;
                    cmd.ExecuteNonQuery();
                    foreach (PaxQuestion q in quesList)
                    {
                        if (q.answer.Length > 0)
                        {
                            cmd = new SqlCommand(SQL_INSERT, cn, trn);
                            cmd.Parameters.Add("@PassengerID", SqlDbType.Int).Value = passengerID;
                            cmd.Parameters.Add("@QuestionID", SqlDbType.Int).Value = q.questionID;
                            cmd.Parameters.Add("@Answer", SqlDbType.VarChar, 500).Value = q.answer;
                            cmd.ExecuteNonQuery();
                        }
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

        public static void PostPayment(Payment p)
        {
            string sSQL = @"INSERT INTO dbo.grp_Payment (BookingID, Amount, PmtDate, PmtType, RefNum, PayerName, Source)
                    VALUES (@BookingID, @Amount, @PmtDate, @PmtType, @RefNum, @PayerName, @Source)";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@BookingID", SqlDbType.Int).Value = p.bookingID;
                cmd.Parameters.Add("@Amount", SqlDbType.Decimal).Value = p.amount;
                cmd.Parameters.Add("@PmtDate", SqlDbType.DateTime).Value = p.pmtDate;
                cmd.Parameters.Add("@PmtType", SqlDbType.VarChar, 3).Value = p.pmtType;
                cmd.Parameters.Add("@RefNum", SqlDbType.VarChar, 25).Value = p.refNum;
                cmd.Parameters.Add("@PayerName", SqlDbType.VarChar, 50).Value = p.payerName;
                cmd.Parameters.Add("@Source", SqlDbType.VarChar, 10).Value = p.source;
                cmd.ExecuteNonQuery();
            }
        }

        public static int GetPaxBooked(string groupID)
        {
            string sSQL = @"SELECT isnull(sum(paxcnt),0) FROM dbo.grp_Booking WHERE GroupID = @GroupID AND Status = 'A'";
            List<Payment> list = new List<Payment>();
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupid", SqlDbType.VarChar).Value = groupID;
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        public static DataTable GetPagedList(string departfr, string departto, int grouptype, string revtype, string searchstr, string sortExpression, int startRowIndex, int maximumRows)
        {
            string fields = @" b.BookingID, m.DepartDate, m.ReturnDate, m.GroupID, m.GroupName, p.PickDesc as GroupTypeDesc, p2.PickDesc as RevTypeDesc,  
                b.PaxCnt, ga.Agent as BookingAgentName, b.BillAmount, b.PmtAmount, b.BillAmount-b.PmtAmount as DueAmount, 
	            px.BadgeName, px.LastName + ', '+ px.FirstName + ' ' + px.MiddleName as PaxName, b.BookingDate, b.StatusDesc, b.Status";
            string filter = string.Format(" (m.departdate >= '{0}' ", departfr);
            string tables = @" dbo.vw_grp_Booking b
                INNER JOIN dbo.grp_Master m on m.GroupID = b.GroupID
                LEFT JOIN dbo.grp_Passenger px on px.bookingid = b.bookingid and px.IsPrimary = 1
                LEFT JOIN dbo.grp_PickList p on p.PickType = 'GROUPTYPE' AND p.PickCode = m.GroupType
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = m.RevType
                LEFT JOIN dbo.vw_Employee ga on ga.FlxID = b.AgentFlexID ";
            if (sortExpression == "")
                sortExpression = "b.bookingid";
            if (!String.IsNullOrEmpty(departto))
                filter += string.Format(" AND m.departdate <= '{0}' ", departto);
            if (grouptype > 0)
                filter += string.Format(" AND m.grouptype = {0} ", grouptype);
            if (!String.IsNullOrEmpty(revtype))
                filter += string.Format(" AND m.revtype = '{0}' ", revtype);
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( px.LastName like '%{0}%' or px.FirstName like '%{0}%' or px.BadgeName like '%{0}%' or 
                    ga.Agent like '%{0}%' or m.GroupName like '%{0}%' ) ", searchstr);
            }
            filter += " ) ";
            if (!String.IsNullOrEmpty(searchstr))
                filter += string.Format(" OR m.groupid = '{0}' ", searchstr);
            if (!String.IsNullOrEmpty(searchstr) && Util.isInteger(searchstr) )
                filter += string.Format(" OR b.bookingid = {0} ", searchstr); 
            string ssql = "SELECT * FROM " +
                " (SELECT " + fields + ", ROW_NUMBER() OVER (ORDER BY " + sortExpression + ") as RowNum " +
                " FROM " + tables + " WHERE " + filter + ") as List " +
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

        public static int GetPagedCount(string departfr, string departto, int grouptype, string revtype, string searchstr)
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }

        public static int GetPagedCount()
        {
            return Convert.ToInt32(System.Web.HttpContext.Current.Items["rowCount"]);
        }


        public static void Export(string departfr, string departto, int grouptype, string revtype, string searchstr)
        {
            string fields = @" b.BookingID, b.BookingDate, b.StatusDesc as Status, m.GroupID as [Group#], m.GroupName, m.DepartDate, 
                p.PickDesc as [GroupType], p2.PickDesc as TravelType, ga.Agent as Agent, px.LastName + ', '+ px.FirstName + ' ' + px.MiddleName as PrimaryPax,  
                b.PaxCnt as [#Pax], b.BillAmount as [Billed], b.PmtAmount as [Paid], b.BillAmount-b.PmtAmount as [Due]";
            string filter = string.Format(" (m.departdate >= '{0}' ", departfr);
            string tables = @" dbo.vw_grp_Booking b
                INNER JOIN dbo.grp_Master m on m.GroupID = b.GroupID
                LEFT JOIN dbo.grp_Passenger px on px.bookingid = b.bookingid and px.IsPrimary = 1
                LEFT JOIN dbo.grp_PickList p on p.PickType = 'GROUPTYPE' AND p.PickCode = m.GroupType
                LEFT JOIN dbo.grp_PickList p2 on p2.PickType = 'REVTYPE' AND p2.PickCode = m.RevType
                LEFT JOIN dbo.vw_Employee ga on ga.FlxID = b.AgentFlexID ";
            if (!String.IsNullOrEmpty(departto))
                filter += string.Format(" AND m.departdate <= '{0}' ", departto);
            if (grouptype > 0)
                filter += string.Format(" AND m.grouptype = {0} ", grouptype);
            if (!String.IsNullOrEmpty(revtype))
                filter += string.Format(" AND m.revtype = '{0}' ", revtype);
            if (!String.IsNullOrEmpty(searchstr))
            {
                searchstr = searchstr.Replace("'", "''");
                filter += string.Format(@" AND ( px.LastName like '%{0}%' or px.FirstName like '%{0}%' or px.BadgeName like '%{0}%' or 
                    ga.Agent like '%{0}%' or m.GroupName like '%{0}%' ) ", searchstr);
            }
            filter += " ) ";
            if (!String.IsNullOrEmpty(searchstr))
                filter += string.Format(" OR m.groupid = '{0}' ", searchstr);
            if (!String.IsNullOrEmpty(searchstr) && Util.isInteger(searchstr))
                filter += string.Format(" OR b.bookingid = {0} ", searchstr);
            string sSQL = string.Format("SELECT {0} FROM {1} WHERE {2} ORDER BY b.BookingID", fields, tables, filter);

            // Header
            HttpContext ctx = HttpContext.Current;
            ctx.Response.Clear();
            ctx.Response.Charset = "";
            ctx.Response.Buffer = true;
            ctx.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=BookingExport_{0}.csv", DateTime.Now.ToString("yyyyMMddhhmmss")));
            ctx.Response.ContentType = "text/csv";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
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

        public static DataTable GetEmails(string groupID)
        {
            //string sSQL = @"select b.GroupID, b.BookingID, p.LastName + ', ' + p.FirstName as Name,  p.Email + ';' as Email
            //                from grp_Booking b
            //                inner join grp_Passenger p on b.BookingID = p.BookingID
            //                where b.status = 'A'
            //                and b.GroupID = @groupID
            //                group by b.BookingID, b.GroupID, p.LastName, p.FirstName, p.Email;";

            string sSQL = @"select b.GroupID, Ltrim(Rtrim(p.Email)) + ';' as Email
                            from grp_Booking b
                            inner join grp_Passenger p on b.BookingID = p.BookingID
                            where b.status = 'A'
                            and b.GroupID = @groupID
                            and p.Email is not null
                            and Ltrim(Rtrim(p.Email)) != '' 
                            group by p.Email, b.GroupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupID", SqlDbType.VarChar).Value = groupID;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

        public static DataTable GetEmailsAgents(string groupID)
        {
            string sSQL = @"select distinct b.GroupID, Ltrim(Rtrim(e.Email)) + ';'  as EmailAgent
                            from [dbo].[vw_grp_Booking] b 
                            inner join [dbo].[cmn_Employee] e on b.AgentFlexID = e.flxid
                            where b.GroupID = @groupID
                            group by e.Email, b.GroupID";
            using (SqlConnection cn = new SqlConnection(Config.ConnectionString))
            {
                cn.Open();
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                SqlCommand cmd = new SqlCommand(sSQL, cn);
                cmd.Parameters.Add("@groupID", SqlDbType.VarChar).Value = groupID;
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(ds);
                dt = ds.Tables[0];
                return dt;
            }
        }

    }
}