USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_Response]    Script Date: 3/23/2021 5:14:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ccTranRC_Response]
--in params
@RC_CCTranID int,
--RC API tran response values
@CommonGrp_TxnAmt varchar(13) = '',
@CardGrp_AVSResultCode varchar(1) = '',
@CardGrp_CCVResultCode varchar(6) = '' ,
@VisaGrp_ACI varchar(1)  = '',
@VisaGrp_CardLevelResult varchar(2) = '',
@VisaGrp_TransID varchar(20) = '',
@MCGrp_BanknetData varchar(13) = '' ,
@MCGrp_CCVErrorCode varchar(1) = '' ,
@MCGrp_POSEntryModeChg varchar(1) = '' ,
@MCGrp_TranEditErrCode varchar(1) = '' ,
@DSGrp_DiscProcCode varchar(6) = '' ,
@DSGrp_DiscPOSEntry varchar(4) = '' ,
@DSGrp_DiscRespCode varchar(2) = '' ,
@DSGrp_DiscPOSData varchar(13) = '' ,
@DSGrp_DiscTransQualifier varchar(2) = '' ,
@DSGrp_DiscNRID varchar(15) = '' ,
@AmexGrp_AmExPOSData varchar(12) = '' ,
@AmexGrp_AmExTranID varchar(20) = '' ,
@RespGrp_RespCode varchar(3) ,
@RespGrp_AuthID varchar(8)  = '',
@RespGrp_AddtlRespData varchar(50)  = '',
@RespGrp_AthNtwkID varchar(3)  = '',
@RespGrp_ErrorData varchar(255) = '',
--out params ePay response 
@SeqNumber varchar(15) = '' out,
@TranResult varchar(25) = '' out,
@ReturnMessage varchar(255) = '' out,
@AuthResponseCode varchar(25) = '' out,
@AuthResponseMessage varchar(255) = '' out,
@ApprovalCode varchar(25) = '' out,
@AddressMatch char(1) = '' out,
@ZipMatch char(1) = '' out,
@CVVResultCode varchar(4) = '' out
as

UPDATE [dbo].[CC_TRANS_RC]
SET Updated = GETDATE(),
      CommonGrp_TxnAmt = Case Len(Ltrim(Rtrim(IsNull(@CommonGrp_TxnAmt,'')))) When 0 Then CommonGrp_TxnAmt Else @CommonGrp_TxnAmt End, -- amt can change if tran is partially authorized
      CardGrp_AVSResultCode = @CardGrp_AVSResultCode ,
      CardGrp_CCVResultCode = @CardGrp_CCVResultCode ,
      VisaGrp_ACI = @VisaGrp_ACI ,
      VisaGrp_CardLevelResult = @VisaGrp_CardLevelResult ,
      VisaGrp_TransID = @VisaGrp_TransID ,
      MCGrp_BanknetData = @MCGrp_BanknetData ,
      MCGrp_CCVErrorCode = @MCGrp_CCVErrorCode ,
      MCGrp_POSEntryModeChg = @MCGrp_POSEntryModeChg ,
      MCGrp_TranEditErrCode = @MCGrp_TranEditErrCode ,
      DSGrp_DiscProcCode = @DSGrp_DiscProcCode ,
      DSGrp_DiscPOSEntry = @DSGrp_DiscPOSEntry ,
      DSGrp_DiscRespCode = @DSGrp_DiscRespCode ,
      DSGrp_DiscPOSData = @DSGrp_DiscPOSData ,
      DSGrp_DiscTransQualifier = @DSGrp_DiscTransQualifier ,
      DSGrp_DiscNRID = @DSGrp_DiscNRID ,
      AmexGrp_AmExPOSData = @AmexGrp_AmExPOSData ,
      AmexGrp_AmExTranID = @AmexGrp_AmExTranID ,
      RespGrp_RespCode = @RespGrp_RespCode ,
      RespGrp_AuthID = @RespGrp_AuthID ,
      RespGrp_AddtlRespData = @RespGrp_AddtlRespData ,
      RespGrp_AthNtwkID = @RespGrp_AthNtwkID ,
      RespGrp_ErrorData = @RespGrp_ErrorData
WHERE CC_TRANS_RC_CCTranID = @RC_CCTranID
IF @@ROWCOUNT = 0
BEGIN 
      SET @TranResult = '-154'
      SET @ReturnMessage = 'UNABLE TO UPDATE CC_TRANS_RC TABLE.'
      RETURN
END

--Translate RC response to ePay response  
SET @SeqNumber = @RC_CCTranID

IF LEN(@RespGrp_ErrorData) > 0
BEGIN
      SET @TranResult = CASE LEN(IsNull(@RespGrp_RespCode,'')) WHEN 0 THEN '-155' ELSE @RespGrp_RespCode END
      SET @ReturnMessage = @RespGrp_ErrorData
END
ELSE
BEGIN
      SET @TranResult = '0'
      SET @ReturnMessage = 'Success'
END

IF @RespGrp_RespCode = '000' 
BEGIN
      SET @AuthResponseCode = 'A' 
      SET @AuthResponseMessage = 'APPROVAL'
      SET @ApprovalCode = @RespGrp_AuthID
END
ELSE 
BEGIN
      SET @AuthResponseCode = Case @RespGrp_RespCode 
                                          When '107' Then 'C' --call
                                          When '101' Then 'X' --expired card
                                          When '704' Then 'P' --pickup card
                                          When '500' Then 'D' --declined
                                          Else 'E' --error
                                          End
      SET @AuthResponseMessage = CASE LEN(IsNull(@RespGrp_AddtlRespData,'')) WHEN 0 THEN 'ERROR' ELSE Left('ERROR - ' + @RespGrp_AddtlRespData, 255) END
      SET @ApprovalCode = ''
END
--set resp code to 002 to force epay to issue an immediate Void if this feature is active (web.config rcVoidPartialAuth)
IF @RespGrp_RespCode = '002' 
BEGIN 
      SET @TranResult = '0' -- EDK 7/7/14 changed 002 to 0 to accomodate POS acceptance of partial authorizations
      SET @ReturnMessage = 'Success' -- EDK 7/7/14 setting to static value to accomodate POS acceptance of partial authorizations
      SET @AuthResponseCode = 'T' -- EDK 7/7/14 changed D to T to accomodate POS acceptance of partial authorizations
      SET @ApprovalCode = @RespGrp_AuthID -- EDK 7/7/14 added setting of @ApprovalCode to accomodate POS acceptance of partial authorizations
      -- EDK 7/7/14 replaced setting of @ReturnMessage with @AuthResponseMessage to accomodate POS acceptance of partial authorizations
      IF LEN(@CommonGrp_TxnAmt) = 1 SET @AuthResponseMessage = @RespGrp_AddtlRespData + ' - $' + @CommonGrp_TxnAmt + '.00'
      ELSE SET @AuthResponseMessage = @RespGrp_AddtlRespData + ' - $' + Left(@CommonGrp_TxnAmt,LEN(@CommonGrp_TxnAmt)-2) + '.' + Right(@CommonGrp_TxnAmt,2)
      --IF LEN(@CommonGrp_TxnAmt) = 1 SET @ReturnMessage = @RespGrp_AddtlRespData + ' - $' + @CommonGrp_TxnAmt + '.00'
      --ELSE SET @ReturnMessage = @RespGrp_AddtlRespData + ' - $' + Left(@CommonGrp_TxnAmt,LEN(@CommonGrp_TxnAmt)-2) + '.' + Right(@CommonGrp_TxnAmt,2)
END
--EDK 3/15/15 changed RapidConnect response code of 785 to 0 to accomodate acceptance of $0 authorizations
IF @RespGrp_RespCode = '785' 
BEGIN 
      SET @TranResult = '0' -- EDK 3/15/15 changed RapidConnect response code of 785 to 0 to accomodate acceptance of $0 authorizations
      SET @ReturnMessage = 'Success' -- EDK 3/15/15 setting to static value to accomodate acceptance of $0 authorizations
      SET @AuthResponseCode = 'Z' -- EDK 3/15/15 setting to Z to accomodate acceptance of $0 authorizations
      SET @ApprovalCode = @RespGrp_AuthID -- EDK 3/15/15 added setting of @ApprovalCode to accomodate acceptance of $0 authorizations
      SET @AuthResponseMessage = @RespGrp_AddtlRespData -- EDK 3/15/15 setting @AuthResponseMessage to message set by RapidConnect to accomodate acceptance of $0 authorizations
END

/*@CardGrp_AVSResultCode*/
--DO NOT TRANSLATE SEND AS IS SINCE EPAY V1 CLIENTS DO NOT USE AVS
SET @AddressMatch = @CardGrp_AVSResultCode
--DO NOT TRANSLATE SEND AS IS SINCE EPAY V1 CLIENTS DO NOT USE AVS
SET @ZipMatch = @CardGrp_AVSResultCode

/*@CardGrp_CCVResultCode - Translate into the legacy CPM values
Match – Values match
NoMtch – Values do not match
NotPrc – Not processed
NotPrv – Value not provided
NotPrt – Issuer not participating
Unknwn – Unknown
*/
/*@CVVResultCode CPM
M: Match
N: No match
S: Merchant code was not on the card
I, U, or P: Unknown/service unavailable
*/
SELECT @CVVResultCode = 
            CASE @CardGrp_CCVResultCode 
         WHEN 'Match' --0
         THEN 'M'
         WHEN 'NoMtch' --1
         THEN 'N'
         WHEN 'NotPrc' --2
         THEN 'I'
         WHEN 'NotPrv' -- 3 
         THEN 'P'
         WHEN 'NotPrt' --3 
         THEN 'U'
         WHEN 'Unknwn' --5 
         THEN 'U'
         ELSE ''
            END


