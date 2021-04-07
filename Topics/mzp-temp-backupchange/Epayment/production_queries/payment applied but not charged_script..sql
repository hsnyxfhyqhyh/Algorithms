--Step1: research the situation for payment applied, but not captured in Rapid connect

DECLARE @TranResult varchar(25)
set @TranResult = '-911'  -- A connection attempt failed because the connected party did not properly respond after a period of time, 
								--or established connection failed because connected host has failed to respond

DECLARE @CC_Created_before varchar(25)
set @CC_Created_before  = '2021-03-25 01:49:53.000'

DECLARE @CC_Created_after varchar(25)
set @CC_Created_after  = '2021-03-31 01:00:53.000'



select * from [dbo].[CC_TRANS] c (nolock)
where	(TranResult =@TranResult  or c.TranResult is null)  --null means no rapid connect record was not created.
	and (TranType = 'CAPTURE' or TranType= 'AUTH_CAPTURE')
	and created > @CC_Created_before  
	and created < @CC_Created_after
order by LocationCode , created desc

--step1: end, do individual membership research , copy the membership id from CustomerID column of above data grid , and set the value to step2 , 

--step2: 
--WM Enroll: 
			-- user: webmbr@014
			-- save_cc,  no cc tran record
			-- auth
					--customerID:	cc token number (1017267569 )
					--productDesc: 'Web Enroll'
			-- capture 
					-- customerID: 7 digit membershipid
					-- product desc: 7 digit membershipid

--WM my account: 
			-- auth happened in wm (
					--customerID:   is 16 digit membership id 4382121085326001 
					--productDesc : 'WM My Account Payment'
			-- capture happened mzp
					-- customerID: 7 digit membershipid
					-- product desc: 7 digit membershipid

--MZP : 

--Find the customer ID then set to following variable
DECLARE @CustomerID varchar(25)
Set @CustomerID = '7869607' -- can get the 16 digit membershipid from mzp 

/*
ORACLE QUERY 

select concat(concat( concat('438212' ,m.membership_id) , m.associate_id) , m.check_digit_nr ) as FullmembershipID
FROM mz_member m 
where m.membership_id = '7869607'
*/

DECLARE @CustomerID_16 varchar(25)
Set @CustomerID_16 = '4382127869607003' -- can get the 16 digit membershipid from mzp 


select * 
from [dbo].[CC_TRANS] c (nolock)
where 
		created > @CC_Created_before 
	and ProductDesc = @CustomerID or ProductDesc = @CustomerID_16

--step 3: 
DECLARE @SeqNumber varchar(25)
Set @SeqNumber = '1022207656'


select *
from [dbo].[CC_TRANS_RC] c (nolock)
where cc_trans_rc_CCTranID = @SeqNumber


select * 
from [dbo].[CC_TRANS_RC_XML] c (nolock)
where cc_trans_rc_CCTranID = @SeqNumber

