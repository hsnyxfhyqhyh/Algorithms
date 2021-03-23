USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_TORValues]    Script Date: 3/23/2021 5:27:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ccTranRC_TORValues]
@CCTranID int,
@CommonGrp_LocalDateTime varchar(14) = '' out,
@CommonGrp_TrnmsnDateTime varchar(14) = '' out,
@CommonGrp_STAN varchar(6) = '' out
as

DECLARE @MerchantID varchar(32)

--get current tran details from dbo.CC_TRANS table
SELECT		@MerchantID = Ltrim(Rtrim(IsNull([MerchantID],'')))
FROM		dbo.CC_TRANS  
WHERE		CCTranID = @CCTranID

/*@CommonGrp_LocalDateTime
The local date and time in which the transaction was performed.
This field will always contain the local date and time for the transaction being submitted.
N-14
YYYYMMDDhhmmss
*/		
SET @CommonGrp_LocalDateTime = 
		Cast(DatePart(YYYY, GETDATE()) as varchar(4)) + Right('0' + Cast(DatePart(MM, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(DD, GETDATE()) as varchar(2)),2) + 
		Right('0' + Cast(DatePart(hh, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(mi, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(ss, GETDATE()) as varchar(2)),2)
/*@CommonGrp_TrnmsnDateTime
The transmission date and time of the transaction (in GMT/UCT).
This field will always contain the transmission date and time for the transaction being submitted.
N-14
YYYYMMDDhhmmss
*/
SET @CommonGrp_TrnmsnDateTime = 
		Cast(DatePart(YYYY, GETUTCDATE()) as varchar(4)) + Right('0' + Cast(DatePart(MM, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(DD, GETUTCDATE()) as varchar(2)),2) + 
		Right('0' + Cast(DatePart(hh, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(mi, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(ss, GETUTCDATE()) as varchar(2)),2)
/*@CommonGrp_STAN
A number assigned by the merchant to uniquely reference the transaction. This number must be unique within a day per Merchant ID per Terminal ID.
This field will always contain the STAN for the transaction being submitted. The STAN must increment from 000001 to 999999 and not reset until it reaches 999999. 
N-6
000001 - 999999
*/
declare @seq_stan varchar(255); set @seq_stan = @MerchantID + '_STAN'
exec @CommonGrp_STAN = usp_GetNewSeqVal @seq_stan
set @CommonGrp_STAN = Right('000000' + @CommonGrp_STAN, 6)
