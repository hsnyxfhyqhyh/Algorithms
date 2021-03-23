USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_Request]    Script Date: 3/23/2021 5:12:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[usp_ccTranRC_Request]
--in params
@CCTranID int,
@Track1PresentFlag char(1),
@CVVPresentFlag char(1),
@CardPresentFlag char(1), -- legacy cpm value, not used
@TerminalCapability char(1), -- legacy cpm value, not used
@TerminalType char(1), -- legacy cpm value, not used
@PosEntryMode char(1), -- legacy cpm value, not used
@CustomerPresentFlag char(1), -- legacy cpm value, not used
@EcommType char(1), -- legacy cpm value, not used
@CCExpiration varchar(4),
@CCType varchar(4),
--out params
@RC_CCTranID int = 0 out,
@ErrMessage varchar(255) = '' out,
--RC tran values out params
@RC_RequestType varchar(25) = '' out,
@CommonGrp_PymtType varchar(7) = '' out,
@CommonGrp_ReversalInd varchar(7) = '' out,
@CommonGrp_TxnType varchar(20) = '' out,
@CommonGrp_LocalDateTime varchar(14) = '' out,
@CommonGrp_TrnmsnDateTime varchar(14) = '' out,
@CommonGrp_STAN varchar(6) = '' out,
@CommonGrp_RefNum varchar(22) = '' out,
@CommonGrp_OrderNum varchar(15) = '' out,
@CommonGrp_TPPID varchar(6) = '' out,
@CommonGrp_TermID varchar(8) = '' out,
@CommonGrp_MerchID varchar(16) = '' out,
@CommonGrp_MerchCatCode varchar(4) = '' out,
@CommonGrp_POSEntryMode varchar(3) = '' out,
@CommonGrp_POSCondCode varchar(2) = '' out,
@CommonGrp_TermCatCode varchar(2) = '' out,
@CommonGrp_TermEntryCapablt varchar(2) = '' out,
@CommonGrp_TxnAmt varchar(13) = '' out,
@CommonGrp_TxnCrncy varchar(3) = '' out,
@CommonGrp_TermLocInd varchar(1) = '' out,
@CommonGrp_CardCaptCap varchar(1) = '' out,
@CommonGrp_GroupID varchar(13) = '' out,
@CardGrp_AcctNum varchar(24) = '' out,
@CardGrp_CardExpiryDate varchar(8) = '' out,
@CardGrp_CardType varchar(10) = '' out,
@CardGrp_AVSResultCode varchar(2) = '' out,
@CardGrp_CCVInd varchar(12) = '' out,
@CardGrp_CCVResultCode varchar(6) = '' out,
@AddtlAmtGrp_AddAmt1 varchar(13) = '' out,
@AddtlAmtGrp_AddAmtCrncy1 varchar(3) = '' out,
@AddtlAmtGrp_AddAmtType1 varchar(12) = '' out,
@AddtlAmtGrp_PartAuthrztnApprvlCapablt1 varchar(1) = '' out,
@AddtlAmtGrp_AddAmt2 varchar(13) = '' out,
@AddtlAmtGrp_AddAmtCrncy2 varchar(3) = '' out,
@AddtlAmtGrp_AddAmtType2 varchar(12) = '' out,
@AddtlAmtGrp_PartAuthrztnApprvlCapablt2 varchar(1) = '' out,
@AddtlAmtGrp_AddAmt3 varchar(13) = '' out,
@AddtlAmtGrp_AddAmtCrncy3 varchar(3) = '' out,
@AddtlAmtGrp_AddAmtType3 varchar(12) = '' out,
@AddtlAmtGrp_PartAuthrztnApprvlCapablt3 varchar(1) = '' out,
@EcommGrp_EcommTxnInd varchar(2) = '' out,
@EcommGrp_CustSvcPhoneNumber varchar(10) = '' out,
@EcommGrp_EcommURL varchar(32) = '' out,
@VisaGrp_ACI varchar(2) = '' out,
@VisaGrp_CardLevelResult varchar(2) = '' out,
@VisaGrp_TransID varchar(20) = '' out,
@VisaGrp_VisaBID varchar(10) = '' out,
@VisaGrp_VisaAUAR varchar(12) = '' out,
@VisaGrp_TaxAmtCapablt varchar(2) = '' out,
@MCGrp_BanknetData varchar(13) = '' out,
@MCGrp_CCVErrorCode varchar(1) = '' out,
@MCGrp_POSEntryModeChg varchar(1) = '' out,
@MCGrp_TranEditErrCode varchar(1) = '' out,
@DSGrp_DiscProcCode varchar(6) = '' out,
@DSGrp_DiscPOSEntry varchar(4) = '' out,
@DSGrp_DiscRespCode varchar(2) = '' out,
@DSGrp_DiscPOSData varchar(13) = '' out,
@DSGrp_DiscTransQualifier varchar(2) = '' out,
@DSGrp_DiscNRID varchar(15) = '' out,
@AmexGrp_AmExPOSData varchar(12) = '' out,
@AmexGrp_AmExTranID varchar(20) = '' out,
@CustInfoGrp_AVSBillingAddr varchar(30) = '' out,
@CustInfoGrp_AVSBillingPostalCode varchar(9) = '' out,
@RespGrp_RespCode varchar(3) = '' out,
@RespGrp_AuthID varchar(8) = '' out,
@RespGrp_AddtlRespData varchar(50) = '' out,
@RespGrp_AthNtwkID varchar(3) = '' out,
@RespGrp_ErrorData varchar(255) = '' out,
@OrigAuthGrp_OrigAuthID varchar(8) = '' out,
@OrigAuthGrp_OrigLocalDateTime varchar(14) = '' out,
@OrigAuthGrp_OrigTranDateTime varchar(14) = '' out,
@OrigAuthGrp_OrigSTAN varchar(6) = '' out,
@OrigAuthGrp_OrigRespCode varchar(3) = '' out
as

--variables to get current tran details from dbo.CC_TRANS table
DECLARE
@MerchantID varchar(32),
@TranType varchar(50),
@UserID int,
@UserName varchar(50),
@LocationCode varchar(10),
@MerchantCode varchar(10),
@CustomerID varchar(25),
@ProductDesc varchar(50),
@OrderID varchar(50),
@Created datetime,
@Last4PAN varchar(4),
@CardExpirDate varchar(4),
@CardType varchar(4),
@Amount numeric(16,4),
@CustomerName varchar(26),
@Street varchar(50),
@Zip varchar(9),
@SeqNumber varchar(15),
@TokenNumber int,
@TranResult varchar(25),
@ReturnMessage varchar(255),
@AuthResponseCode varchar(25),
@AuthResponseMessage varchar(255),
@ApprovalCode varchar(25),
@AddressMatch char(1),
@ZipMatch char(1),
@CVVResultCode varchar(4),
@SeqNumber_Org varchar(15)
--variables to retrieve original tran values if doing subsequent transaction from dbo.CC_TRANS table
DECLARE
@MerchantID_orig varchar(32),
@TranType_orig varchar(50),
@UserID_orig int,
@UserName_orig varchar(50),
@LocationCode_orig varchar(10),
@MerchantCode_orig varchar(10),
@CustomerID_orig varchar(25),
@ProductDesc_orig varchar(50),
@OrderID_orig varchar(50),
@Created_orig datetime,
@Last4PAN_orig varchar(4),
@CardExpirDate_orig varchar(4),
@CardType_orig varchar(4),
@Amount_orig numeric(16,4),
@CustomerName_orig varchar(26),
@Street_orig varchar(50),
@Zip_orig varchar(9),
@SeqNumber_orig varchar(15),
@TokenNumber_orig int,
@TranResult_orig varchar(25),
@ReturnMessage_orig varchar(255),
@AuthResponseCode_orig varchar(25),
@AuthResponseMessage_orig varchar(255),
@ApprovalCode_orig varchar(25),
@AddressMatch_orig char(1),
@ZipMatch_orig char(1),
@CVVResultCode_orig varchar(4),
@SeqNumber_Org_orig varchar(15)
--variables to retrieve original tran values if doing subsequent transaction from dbo.CC_TRANS_RC table
DECLARE
@RC_RequestType_orig varchar(25),
@CommonGrp_PymtType_orig varchar(7),
@CommonGrp_ReversalInd_orig varchar(7),
@CommonGrp_TxnType_orig varchar(20),
@CommonGrp_LocalDateTime_orig varchar(14),
@CommonGrp_TrnmsnDateTime_orig varchar(14),
@CommonGrp_STAN_orig varchar(6),
@CommonGrp_RefNum_orig varchar(22),
@CommonGrp_OrderNum_orig varchar(15),
@CommonGrp_TPPID_orig varchar(6),
@CommonGrp_TermID_orig varchar(8),
@CommonGrp_MerchID_orig varchar(16),
@CommonGrp_MerchCatCode_orig varchar(4),
@CommonGrp_POSEntryMode_orig varchar(3),
@CommonGrp_POSCondCode_orig varchar(2),
@CommonGrp_TermCatCode_orig varchar(2),
@CommonGrp_TermEntryCapablt_orig varchar(2),
@CommonGrp_TxnAmt_orig varchar(13),
@CommonGrp_TxnCrncy_orig varchar(3),
@CommonGrp_TermLocInd_orig varchar(1),
@CommonGrp_CardCaptCap_orig varchar(1),
@CommonGrp_GroupID_orig varchar(13),
@CardGrp_AcctNum_orig varchar(24),
@CardGrp_CardExpiryDate_orig varchar(8),
@CardGrp_CardType_orig varchar(10),
@CardGrp_AVSResultCode_orig varchar(2),
@CardGrp_CCVInd_orig varchar(12),
@CardGrp_CCVResultCode_orig varchar(6),
@AddtlAmtGrp_AddAmt1_orig varchar(13),
@AddtlAmtGrp_AddAmtCrncy1_orig varchar(3),
@AddtlAmtGrp_AddAmtType1_orig varchar(12),
@AddtlAmtGrp_PartAuthrztnApprvlCapablt1_orig varchar(1),
@AddtlAmtGrp_AddAmt2_orig varchar(13),
@AddtlAmtGrp_AddAmtCrncy2_orig varchar(3),
@AddtlAmtGrp_AddAmtType2_orig varchar(12),
@AddtlAmtGrp_PartAuthrztnApprvlCapablt2_orig varchar(1),
@AddtlAmtGrp_AddAmt3_orig varchar(13),
@AddtlAmtGrp_AddAmtCrncy3_orig varchar(3),
@AddtlAmtGrp_AddAmtType3_orig varchar(12),
@AddtlAmtGrp_PartAuthrztnApprvlCapablt3_orig varchar(1),
@EcommGrp_EcommTxnInd_orig varchar(2),
@EcommGrp_CustSvcPhoneNumber_orig varchar(10),
@EcommGrp_EcommURL_orig varchar(32),
@VisaGrp_ACI_orig varchar(2),
@VisaGrp_CardLevelResult_orig varchar(2),
@VisaGrp_TransID_orig varchar(20),
@VisaGrp_VisaBID_orig varchar(10),
@VisaGrp_VisaAUAR_orig varchar(12),
@VisaGrp_TaxAmtCapablt_orig varchar(2),
@MCGrp_BanknetData_orig varchar(13),
@MCGrp_CCVErrorCode_orig varchar(1),
@MCGrp_POSEntryModeChg_orig varchar(1),
@MCGrp_TranEditErrCode_orig varchar(1),
@DSGrp_DiscProcCode_orig varchar(6),
@DSGrp_DiscPOSEntry_orig varchar(4),
@DSGrp_DiscRespCode_orig varchar(2),
@DSGrp_DiscPOSData_orig varchar(13),
@DSGrp_DiscTransQualifier_orig varchar(2),
@DSGrp_DiscNRID_orig varchar(15),
@AmexGrp_AmExPOSData_orig varchar(12),
@AmexGrp_AmExTranID_orig varchar(20),
@CustInfoGrp_AVSBillingAddr_orig varchar(30),
@CustInfoGrp_AVSBillingPostalCode_orig varchar(9),
@RespGrp_RespCode_orig varchar(3),
@RespGrp_AuthID_orig varchar(8),
@RespGrp_AddtlRespData_orig varchar(50),
@RespGrp_AthNtwkID_orig varchar(3),
@RespGrp_ErrorData_orig varchar(255),
@OrigAuthGrp_OrigAuthID_orig varchar(8),
@OrigAuthGrp_OrigLocalDateTime_orig varchar(14),
@OrigAuthGrp_OrigTranDateTime_orig varchar(14),
@OrigAuthGrp_OrigSTAN_orig varchar(6),
@OrigAuthGrp_OrigRespCode_orig varchar(3)
--variables to get RC merchant details from  dbo.MERCHANT_SETTINGS_RC table
DECLARE
@MerchantIDNash varchar(16),
@TPPID varchar(6),
@TermID varchar(8),
@MerchCatCode varchar(4),
@MerchCatType varchar(50),
@POSEntryMode_RC varchar(3),
@POSCondCode varchar(2),
@TermCatCode varchar(2),
@TermEntryCapablt varchar(2),
@TermLocInd varchar(1),
@CardCaptCap varchar(1),
@GroupID varchar(13),
@PartAuthrztnApprvlCapablt varchar(1),
@ACI varchar(1),
@VisaBID varchar(10),
@VisaAUAR varchar(12),
@TaxAmtCapablt varchar(2),
@EcommTxnInd varchar(2),
@CustSvcPhoneNumber varchar(10),
@EcommURL varchar(32)

--set constant values here
declare @ReversalInd_Void varchar(7); set @ReversalInd_Void = '1'
declare @TxnType_Authorization varchar(20); set @TxnType_Authorization = '1'
declare @TxnType_Completion varchar(20); set @TxnType_Completion = '6'
declare @TxnType_Sale varchar(20); set @TxnType_Sale = '14'
declare @TxnType_Refund varchar(20); set @TxnType_Refund  = '12'


--<<< RETRIEVING TRAN DETAILS START >>>--

--get current tran details from dbo.CC_TRANS table
SELECT		@MerchantID = Ltrim(Rtrim(IsNull([MerchantID],'')))
           ,@TranType = Ltrim(Rtrim(IsNull([TranType],'')))
           ,@UserID = Ltrim(Rtrim(IsNull([UserID],'')))
           ,@UserName = Ltrim(Rtrim(IsNull([UserName],'')))
           ,@LocationCode = Ltrim(Rtrim(IsNull([LocationCode],'')))
           ,@MerchantCode = Ltrim(Rtrim(IsNull([MerchantCode],'')))
           ,@CustomerID = Ltrim(Rtrim(IsNull([CustomerID],'')))
           ,@ProductDesc = Ltrim(Rtrim(IsNull([ProductDesc],'')))
           ,@OrderID = Ltrim(Rtrim(IsNull([OrderID],'')))
           ,@Created = [Created]
           ,@Last4PAN = Ltrim(Rtrim(IsNull([Last4PAN],'')))
           ,@CardExpirDate = Case Len(Ltrim(Rtrim(IsNull([CardExpirDate],''))))
							 When 0 Then @CCExpiration
							 Else Ltrim(Rtrim([CardExpirDate]))
							 End
           ,@CardType = Case Len(Ltrim(Rtrim(IsNull([CardType],''))))
						When 0 Then @CCType
						Else Ltrim(Rtrim([CardType]))
						End
           ,@Amount = IsNull([Amount],0)
           ,@CustomerName = Ltrim(Rtrim(IsNull([CustomerName],'')))
           ,@Street = Ltrim(Rtrim(IsNull([Street],'')))
           ,@Zip = Ltrim(Rtrim(IsNull([Zip],'')))
           ,@SeqNumber = Ltrim(Rtrim(IsNull([SeqNumber],'')))
           ,@TokenNumber = IsNull([TokenNumber],0)
           ,@TranResult = Ltrim(Rtrim(IsNull([TranResult],'')))
           ,@ReturnMessage = Ltrim(Rtrim(IsNull([ReturnMessage],'')))
           ,@AuthResponseCode = Ltrim(Rtrim(IsNull([AuthResponseCode],'')))
           ,@AuthResponseMessage = Ltrim(Rtrim(IsNull([AuthResponseMessage],'')))
           ,@ApprovalCode = Ltrim(Rtrim(IsNull([ApprovalCode],'')))
           ,@AddressMatch = Ltrim(Rtrim(IsNull([AddressMatch],'')))
           ,@ZipMatch = Ltrim(Rtrim(IsNull([ZipMatch],'')))
           ,@CVVResultCode = Ltrim(Rtrim(IsNull([CVVResultCode],'')))
           ,@SeqNumber_Org = Ltrim(Rtrim(IsNull([SeqNumber_Org],'')))
FROM		dbo.CC_TRANS  
WHERE		CCTranID = @CCTranID
IF @@ROWCOUNT = 0
BEGIN
	SET @RC_CCTranID = -154
	SET @ErrMessage = 'Unable to find record from dbo.CC_TRANS table.'
	RETURN
END

--remove original seq since we're doing a REF where all original card values are available
IF @TranType = 'REF_BY_SEQ' SET @SeqNumber_Org = ''

--if doing VOID right after the original sale (<= 3 seconds) then force a delay
IF @TranType = 'VOID' and (	select	DateDiff(ss, orig.Created, void.Created) 
							from	CC_TRANS orig, CC_TRANS void 
							where	orig.SeqNumber = void.SeqNumber_Org and
									orig.SeqNumber = @SeqNumber_Org ) <= 3
BEGIN
	--wait for 2 second
	WAITFOR DELAY '00:00:02'
END 


IF Len(IsNull(@SeqNumber_Org,'')) > 0 -- doing subsequent transaction
BEGIN
--retrieve original settings if doing subsequent transaction
--select * from dbo.CC_TRANS where SeqNumber = @SeqNumber_Org --sequence from CC_TRANS
--select * from dbo.CC_TRANS_RC where CC_TRANS_RC_CCTranID = @SeqNumber_Org --sequence from CC_TRANS

	SELECT		@MerchantID_orig = Ltrim(Rtrim(IsNull([MerchantID],'')))
			   ,@TranType_orig = Ltrim(Rtrim(IsNull([TranType],'')))
			   ,@UserID_orig = Ltrim(Rtrim(IsNull([UserID],'')))
			   ,@UserName_orig = Ltrim(Rtrim(IsNull([UserName],'')))
			   ,@LocationCode_orig = Ltrim(Rtrim(IsNull([LocationCode],'')))
			   ,@MerchantCode_orig = Ltrim(Rtrim(IsNull([MerchantCode],'')))
			   ,@CustomerID_orig = Ltrim(Rtrim(IsNull([CustomerID],'')))
			   ,@ProductDesc_orig = Ltrim(Rtrim(IsNull([ProductDesc],'')))
			   ,@OrderID_orig = Ltrim(Rtrim(IsNull([OrderID],'')))
			   ,@Created_orig = [Created]
			   ,@Last4PAN_orig = Ltrim(Rtrim(IsNull([Last4PAN],'')))
			   ,@CardExpirDate_orig = Ltrim(Rtrim(IsNull([CardExpirDate],'')))
			   ,@CardType_orig = Ltrim(Rtrim(IsNull([CardType],'')))
			   ,@Amount_orig = IsNull([Amount],0)
			   ,@CustomerName_orig = Ltrim(Rtrim(IsNull([CustomerName],'')))
			   ,@Street_orig = Ltrim(Rtrim(IsNull([Street],'')))
			   ,@Zip_orig = Ltrim(Rtrim(IsNull([Zip],'')))
			   ,@SeqNumber_orig = Ltrim(Rtrim(IsNull([SeqNumber],'')))
			   ,@TokenNumber_orig = IsNull([TokenNumber],0)
			   ,@TranResult_orig = Ltrim(Rtrim(IsNull([TranResult],'')))
			   ,@ReturnMessage_orig = Ltrim(Rtrim(IsNull([ReturnMessage],'')))
			   ,@AuthResponseCode_orig = Ltrim(Rtrim(IsNull([AuthResponseCode],'')))
			   ,@AuthResponseMessage_orig = Ltrim(Rtrim(IsNull([AuthResponseMessage],'')))
			   ,@ApprovalCode_orig = Ltrim(Rtrim(IsNull([ApprovalCode],'')))
			   ,@AddressMatch_orig = Ltrim(Rtrim(IsNull([AddressMatch],'')))
			   ,@ZipMatch_orig = Ltrim(Rtrim(IsNull([ZipMatch],'')))
			   ,@CVVResultCode_orig = Ltrim(Rtrim(IsNull([CVVResultCode],'')))
			   ,@SeqNumber_Org_orig = Ltrim(Rtrim(IsNull([SeqNumber_Org],'')))
	FROM		dbo.CC_TRANS  
	WHERE		SeqNumber = @SeqNumber_Org
	IF @@ROWCOUNT = 0
	BEGIN
		SET @RC_CCTranID = -155
		SET @ErrMessage = 'Unable to find parent record from dbo.CC_TRANS table.'
		RETURN
	END
	
	SELECT 
		   @RC_RequestType_orig = IsNull([RC_RequestType],'')
		  ,@CommonGrp_PymtType_orig = IsNull([CommonGrp_PymtType],'')
		  ,@CommonGrp_ReversalInd_orig = IsNull([CommonGrp_ReversalInd],'')
		  ,@CommonGrp_TxnType_orig = IsNull([CommonGrp_TxnType],'')
		  ,@CommonGrp_LocalDateTime_orig = IsNull([CommonGrp_LocalDateTime],'')
		  ,@CommonGrp_TrnmsnDateTime_orig = IsNull([CommonGrp_TrnmsnDateTime],'')
		  ,@CommonGrp_STAN_orig = IsNull([CommonGrp_STAN],'')
		  ,@CommonGrp_RefNum_orig = IsNull([CommonGrp_RefNum],'')
		  ,@CommonGrp_OrderNum_orig = IsNull([CommonGrp_OrderNum],'')
		  ,@CommonGrp_TPPID_orig = IsNull([CommonGrp_TPPID],'')
		  ,@CommonGrp_TermID_orig = IsNull([CommonGrp_TermID],'')
		  ,@CommonGrp_MerchID_orig = IsNull([CommonGrp_MerchID],'')
		  ,@CommonGrp_MerchCatCode_orig = IsNull([CommonGrp_MerchCatCode],'')
		  ,@CommonGrp_POSEntryMode_orig = IsNull([CommonGrp_POSEntryMode],'')
		  ,@CommonGrp_POSCondCode_orig = IsNull([CommonGrp_POSCondCode],'')
		  ,@CommonGrp_TermCatCode_orig = IsNull([CommonGrp_TermCatCode],'')
		  ,@CommonGrp_TermEntryCapablt_orig = IsNull([CommonGrp_TermEntryCapablt],'')
		  ,@CommonGrp_TxnAmt_orig = IsNull([CommonGrp_TxnAmt],'')
		  ,@CommonGrp_TxnCrncy_orig = IsNull([CommonGrp_TxnCrncy],'')
		  ,@CommonGrp_TermLocInd_orig = IsNull([CommonGrp_TermLocInd],'')
		  ,@CommonGrp_CardCaptCap_orig = IsNull([CommonGrp_CardCaptCap],'')
		  ,@CommonGrp_GroupID_orig = IsNull([CommonGrp_GroupID],'')
		  ,@CardGrp_AcctNum_orig = IsNull([CardGrp_AcctNum],'')
		  ,@CardGrp_CardExpiryDate_orig = IsNull([CardGrp_CardExpiryDate],'')
		  ,@CardGrp_CardType_orig = IsNull([CardGrp_CardType],'')
		  ,@CardGrp_AVSResultCode_orig = IsNull([CardGrp_AVSResultCode],'')
		  ,@CardGrp_CCVInd_orig = IsNull([CardGrp_CCVInd],'')
		  ,@CardGrp_CCVResultCode_orig = IsNull([CardGrp_CCVResultCode],'')
		  ,@AddtlAmtGrp_AddAmt1_orig = IsNull([AddtlAmtGrp_AddAmt1],'')
		  ,@AddtlAmtGrp_AddAmtCrncy1_orig = IsNull([AddtlAmtGrp_AddAmtCrncy1],'')
		  ,@AddtlAmtGrp_AddAmtType1_orig = IsNull([AddtlAmtGrp_AddAmtType1],'')
		  ,@AddtlAmtGrp_PartAuthrztnApprvlCapablt1_orig = IsNull([AddtlAmtGrp_PartAuthrztnApprvlCapablt1],'')
		  ,@AddtlAmtGrp_AddAmt2_orig = IsNull([AddtlAmtGrp_AddAmt2],'')
		  ,@AddtlAmtGrp_AddAmtCrncy2_orig = IsNull([AddtlAmtGrp_AddAmtCrncy2],'')
		  ,@AddtlAmtGrp_AddAmtType2_orig = IsNull([AddtlAmtGrp_AddAmtType2],'')
		  ,@AddtlAmtGrp_PartAuthrztnApprvlCapablt2_orig = IsNull([AddtlAmtGrp_PartAuthrztnApprvlCapablt2],'')
		  ,@AddtlAmtGrp_AddAmt3_orig = IsNull([AddtlAmtGrp_AddAmt3],'')
		  ,@AddtlAmtGrp_AddAmtCrncy3_orig = IsNull([AddtlAmtGrp_AddAmtCrncy3],'')
		  ,@AddtlAmtGrp_AddAmtType3_orig = IsNull([AddtlAmtGrp_AddAmtType3],'')
		  ,@AddtlAmtGrp_PartAuthrztnApprvlCapablt3_orig = IsNull([AddtlAmtGrp_PartAuthrztnApprvlCapablt3],'')
		  ,@EcommGrp_EcommTxnInd_orig = IsNull([EcommGrp_EcommTxnInd],'')
		  ,@EcommGrp_CustSvcPhoneNumber_orig = IsNull([EcommGrp_CustSvcPhoneNumber],'')
		  ,@EcommGrp_EcommURL_orig = IsNull([EcommGrp_EcommURL],'')
		  ,@VisaGrp_ACI_orig = IsNull([VisaGrp_ACI],'')
		  ,@VisaGrp_CardLevelResult_orig = IsNull([VisaGrp_CardLevelResult],'')
		  ,@VisaGrp_TransID_orig = Ltrim(Rtrim(IsNull([VisaGrp_TransID],'')))
		  ,@VisaGrp_VisaBID_orig = IsNull([VisaGrp_VisaBID],'')
		  ,@VisaGrp_VisaAUAR_orig = IsNull([VisaGrp_VisaAUAR],'')
		  ,@VisaGrp_TaxAmtCapablt_orig = IsNull([VisaGrp_TaxAmtCapablt],'')
		  ,@MCGrp_BanknetData_orig = IsNull([MCGrp_BanknetData],'')
		  ,@MCGrp_CCVErrorCode_orig = IsNull([MCGrp_CCVErrorCode],'')
		  ,@MCGrp_POSEntryModeChg_orig = IsNull([MCGrp_POSEntryModeChg],'')
		  ,@MCGrp_TranEditErrCode_orig = IsNull([MCGrp_TranEditErrCode],'')
		  ,@DSGrp_DiscProcCode_orig = IsNull([DSGrp_DiscProcCode],'')
		  ,@DSGrp_DiscPOSEntry_orig = IsNull([DSGrp_DiscPOSEntry],'')
		  ,@DSGrp_DiscRespCode_orig = IsNull([DSGrp_DiscRespCode],'')
		  ,@DSGrp_DiscPOSData_orig = IsNull([DSGrp_DiscPOSData],'')
		  ,@DSGrp_DiscTransQualifier_orig = IsNull([DSGrp_DiscTransQualifier],'')
		  ,@DSGrp_DiscNRID_orig = IsNull([DSGrp_DiscNRID],'')
		  ,@AmexGrp_AmExPOSData_orig = IsNull([AmexGrp_AmExPOSData],'')
		  ,@AmexGrp_AmExTranID_orig = IsNull([AmexGrp_AmExTranID],'')
		  ,@CustInfoGrp_AVSBillingAddr_orig = IsNull([CustInfoGrp_AVSBillingAddr],'')
		  ,@CustInfoGrp_AVSBillingPostalCode_orig = IsNull([CustInfoGrp_AVSBillingPostalCode],'')
		  ,@RespGrp_RespCode_orig = IsNull([RespGrp_RespCode],'')
		  ,@RespGrp_AuthID_orig = IsNull([RespGrp_AuthID],'')
		  ,@RespGrp_AddtlRespData_orig = IsNull([RespGrp_AddtlRespData],'')
		  ,@RespGrp_AthNtwkID_orig = IsNull([RespGrp_AthNtwkID],'')
		  ,@RespGrp_ErrorData_orig = IsNull([RespGrp_ErrorData],'')
		  ,@OrigAuthGrp_OrigAuthID_orig = IsNull([OrigAuthGrp_OrigAuthID],'')
		  ,@OrigAuthGrp_OrigLocalDateTime_orig = IsNull([OrigAuthGrp_OrigLocalDateTime],'')
		  ,@OrigAuthGrp_OrigTranDateTime_orig = IsNull([OrigAuthGrp_OrigTranDateTime],'')
		  ,@OrigAuthGrp_OrigSTAN_orig = IsNull([OrigAuthGrp_OrigSTAN],'')
		  ,@OrigAuthGrp_OrigRespCode_orig = IsNull([OrigAuthGrp_OrigRespCode],'')
  FROM		[dbo].[CC_TRANS_RC]
  WHERE		CC_TRANS_RC_CCTranID = @SeqNumber_Org
  IF @@ROWCOUNT = 0
	BEGIN
		SET @RC_CCTranID = -156
		SET @ErrMessage = 'Unable to find parent record from dbo.CC_TRANS_RC table.'
		RETURN
	END
END
--<<< RETRIEVING TRAN DETAILS END >>>--

--<<< RETRIEVING MERCHANT DETAILS START >>>--
--get RC merchant details from  dbo.MERCHANT_SETTINGS_RC table
SELECT	   @MerchantIDNash = IsNull([MerchID],'')
		  ,@TPPID = IsNull([TPPID],'')
		  ,@TermID = IsNull([TermID],'')
		  ,@MerchCatCode = IsNull([MerchCatCode],'')
		  ,@MerchCatType = Upper(IsNull([MerchCatType],''))
		  ,@POSEntryMode_RC = IsNull([POSEntryMode],'')
		  ,@POSCondCode = IsNull([POSCondCode],'')
		  ,@TermCatCode = IsNull([TermCatCode],'')
		  ,@TermEntryCapablt = IsNull([TermEntryCapablt],'')
		  ,@TermLocInd = IsNull([TermLocInd],'')
		  ,@CardCaptCap = IsNull([CardCaptCap],'')
		  ,@GroupID = IsNull([GroupID],'')
		  ,@PartAuthrztnApprvlCapablt = IsNull([PartAuthrztnApprvlCapablt],'')
		  ,@ACI = IsNull([ACI],'')
		  ,@VisaBID = IsNull([VisaBID],'')
		  ,@VisaAUAR = IsNull([VisaAUAR],'')
		  ,@TaxAmtCapablt = IsNull([TaxAmtCapablt],'')
		  ,@EcommTxnInd = IsNull([EcommTxnInd],'')
		  ,@CustSvcPhoneNumber = IsNull([CustSvcPhoneNumber],'')
		  ,@EcommURL = IsNull([EcommURL],'')
FROM	[dbo].[MERCHANT_SETTINGS_RC]
WHERE	MerchIDNorth = @MerchantID 
IF @@ROWCOUNT = 0
	BEGIN
		SET @RC_CCTranID = -157
		SET @ErrMessage = 'Unable to find RapidConnect merchant record from dbo.MERCHANT_SETTINGS_RC table.'
		RETURN
	END                     
--<<< RETRIEVING MERCHANT DETAILS END >>>--

--<<< FORCE REFUND IF DOING VOID AGAINST ORIGINAL SALE DONE MORE THAN 25 MIN AGO START >>>--
/*
is current transaction a "void"
 is original transaction a "sale"
  is original transaction made more than 25 min ago
   then change current transaction tran type to refund and use original sale amount
*/
IF Upper(@TranType) = 'VOID' and Len(IsNull(@SeqNumber_Org,'')) > 0 and Upper(@TranType_orig) = 'AUTH_CAPTURE' and DATEDIFF(mi, @Created_orig, GetDate()) >= 24
BEGIN
	SET @TranType = 'REF'
	--SET @Amount = @Amount_orig --REMOVED BY EDK - 11/6/15 - if original sale was partialy authorized this will issue refund for the larger amount based on the original amount attempted to be authorized
	SET @Amount = Cast(	Left(@CommonGrp_TxnAmt_orig,LEN(@CommonGrp_TxnAmt_orig)-2) 
						+ '.' + 
						RIGHT(@CommonGrp_TxnAmt_orig,2) 
					as numeric(16,2))
	--remove original seq since we're doing a REF where all original card values are available
	SET @SeqNumber_Org = ''
END
--<<< FORCE REFUND IF DOING VOID AGAINST ORIGINAL SALE DONE MORE THAN 25 MIN AGO END >>>--

--<<< SET ALL OUTPUT PARAMS START >>>--

--prepare all RC request values (translated), generate tran ids (STAN, etc.)
--validate all request values

/*@RC_RequestType
Set RC XML request type
*/
SELECT @RC_RequestType =
		CASE @TranType 
         WHEN 'REVERSAL' THEN 'ReversalRequest'
         WHEN 'VOID' THEN 'ReversalRequest'
         ELSE 'CreditRequest'
		END
/*@CommonGrp_PymtType
The payment type of the transaction. Always set to Credit for credit card transactions.
an-7
*/
SET @CommonGrp_PymtType = 'CREDIT'
/*@CommonGrp_ReversalInd
An identifier used to indicate the reason that a transaction is being reversed.
This field must be supplied when a transaction is to be reversed.
an-7
Timeout – Timeout Reversal / System Timeout
Void – Void / Full Reversal
VoidFr – Void for Suspected Fraud
TORVoid – Timeout Reversal of Void
Partial – Partial Reversal
*/
SELECT @CommonGrp_ReversalInd =
		CASE @TranType 
         WHEN 'REVERSAL' THEN @ReversalInd_Void
         WHEN 'VOID' THEN @ReversalInd_Void
         ELSE ''
		END
/*@CommonGrp_TxnType 
The type of transaction being performed.
On a Timeout Reversal, Void/Full Reversal or Timeout Reversal of Void this field should reflect the Transaction Type of the original transaction being reversed.
One of the Account Number, Track 1 Data, Track 2 Data, Token or Encryption Block fields must be present in all requests, except for TAKeyRequest, which does not require account information. This rule does not apply to Check transactions where MICR or Driver‘s License must be provided.
an-20
Activation – Activation
Authorization - Authorization
BalanceInquiry – Balance Inquiry
BalanceLock – Balance Lock
Cashout – Cashout
CashoutActiveStatus – Cashout Active Status
Completion – Completion
FileDownload – File Download
HostTotals – Host Totals
Load – Generic Load
Redemption – Redemption
RedemptionUnlock – Redemption Unlock
Refund – Refund
Reload – Reload
Sale – Sale
TAKeyRequest – TransArmor Key Update
TATokenRequest – TransArmor Token Request
Verification – Verification
*/ 		
SELECT @CommonGrp_TxnType =
		CASE @TranType 
         WHEN 'AUTH' THEN '1' --'Authorization'
         WHEN 'AUTH_CAPTURE' THEN '14' --'Sale'
         WHEN 'CAPTURE' THEN '6' --'Completion'
         WHEN 'REF' THEN '12' --'Refund'
         WHEN 'REF_BY_SEQ' THEN '12' --'Refund'
         WHEN 'REVERSAL' THEN CASE @TranType_orig 
								 WHEN 'AUTH' THEN '1' --'Authorization'
								 WHEN 'AUTH_CAPTURE' THEN '14' --'Sale'
								 WHEN 'CAPTURE' THEN '6' --'Completion'
								 WHEN 'REF' THEN '12' --'Refund'
								 WHEN 'REF_BY_SEQ' THEN '12' --'Refund'
								 ELSE ''
							   END	
         WHEN 'VOID' THEN CASE @TranType_orig 
								 WHEN 'AUTH' THEN '1' --'Authorization'
								 WHEN 'AUTH_CAPTURE' THEN '14' --'Sale'
								 WHEN 'CAPTURE' THEN '6' --'Completion'
								 WHEN 'REF' THEN '12' --'Refund'
								 WHEN 'REF_BY_SEQ' THEN '12' --'Refund'
								 ELSE ''
							   END	
         --WHEN 'LOOKUP_BY_SEQ' THEN '' --should be handled by the upstream app logic and never get to this point
         ELSE ''
		END	
/*@CommonGrp_LocalDateTime
The local date and time in which the transaction was performed.
This field will always contain the local date and time for the transaction being submitted. For subsequent transactions the Local Date and Time of the original request should be submitted in the ORIGINAL AUTHORIZATION Group.Original Local Date and Time field.
This field is echoed in response messages.
N-14
YYYYMMDDhhmmss
*/		
SET @CommonGrp_LocalDateTime = 
		Cast(DatePart(YYYY, GETDATE()) as varchar(4)) + Right('0' + Cast(DatePart(MM, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(DD, GETDATE()) as varchar(2)),2) + 
		Right('0' + Cast(DatePart(hh, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(mi, GETDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(ss, GETDATE()) as varchar(2)),2)
/*@CommonGrp_TrnmsnDateTime
The transmission date and time of the transaction (in GMT/UCT).
This field will always contain the transmission date and time for the transaction being submitted. For subsequent transactions the Transmission Date and Time of the original request should be submitted in the ORIGINAL AUTHORIZATION Group.Original Transmission Date and Time field.
Every response message will contain the time and date of the Rapid Connect system, in which it passed the response back to the merchant.
N-14
YYYYMMDDhhmmss
*/
SET @CommonGrp_TrnmsnDateTime = 
		Cast(DatePart(YYYY, GETUTCDATE()) as varchar(4)) + Right('0' + Cast(DatePart(MM, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(DD, GETUTCDATE()) as varchar(2)),2) + 
		Right('0' + Cast(DatePart(hh, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(mi, GETUTCDATE()) as varchar(2)),2) + Right('0' + Cast(DatePart(ss, GETUTCDATE()) as varchar(2)),2)
/*@CommonGrp_STAN
A number assigned by the merchant to uniquely reference the transaction. This number must be unique within a day per Merchant ID per Terminal ID.
This field will always contain the STAN for the transaction being submitted. For subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) the STAN of the original authorization should be submitted in the ORIGINAL AUTHORIZATION Group.Original STAN field. The STAN for the message being submitted will be returned in that transaction‘s response message. If multiple terminals are used at a merchant's location, the STAN must be different for each terminal. The STAN must increment from 000001 to 999999 and not reset until it reaches 999999. 
N-6
000001 - 999999
*/
declare @seq_stan varchar(255); set @seq_stan = @MerchantID + '_STAN'
exec @CommonGrp_STAN = usp_GetNewSeqVal @seq_stan
if @CommonGrp_STAN <= 0 begin select @RC_CCTranID = -915, @ErrMessage = 'Unable to generate STAN';return;end
set @CommonGrp_STAN = Right('000000' + @CommonGrp_STAN, 6)
/*@CommonGrp_RefNum
A number assigned by the merchant to uniquely reference a set of transactions. This number must be unique within a day for a given Merchant ID/ Terminal ID.
The Reference Number in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) should be the same as the Reference Number submitted in the original transaction.
The Reference Number for the message being submitted will be returned in that transaction‘s response message.
This field must be numeric and contain no more than 12 bytes of data, unless prior approval is provided by First Data.
an-22
999999999999
*/		
IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN	
	SET @CommonGrp_RefNum = @CommonGrp_RefNum_orig
END
ELSE
BEGIN
	declare @seq_refnum varchar(255); set @seq_refnum = @MerchantID + '_RefNum'
	exec @CommonGrp_RefNum = usp_GetNewSeqVal @seq_refnum
	if @CommonGrp_RefNum <= 0 begin select @RC_CCTranID = -916, @ErrMessage = 'Unable to generate RefNum';return;end
	set @CommonGrp_RefNum = Right('00000000' + @CommonGrp_RefNum, 8)
END

/*@CommonGrp_OrderNum
A number assigned by the merchant to uniquely reference a transaction. This field must be numeric and contain no more than 8 bytes of data, unless prior approval is provided by First Data.
The Order Number in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) must be the same as the Order Number submitted in the original transaction.
The Order Number for the message being submitted will be returned in that transaction‘s response message.
The Order Number is mandatory for all MOTO and Ecommerce transactions, but optional for Retail transactions.
The value in this field cannot contain all zeroes
an-15
99999999
*/
IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN	
	SET @CommonGrp_OrderNum = @CommonGrp_OrderNum_orig
END
ELSE
BEGIN
	declare @seq_ordnum varchar(255); set @seq_ordnum = 'AllMerchants_OrdNum'
	exec @CommonGrp_OrderNum = usp_GetNewSeqVal @seq_ordnum
	if @CommonGrp_OrderNum <= 0 begin select @RC_CCTranID = -917, @ErrMessage = 'Unable to generate OrdNum';return;end
	set @CommonGrp_OrderNum = Right('00000000' + @CommonGrp_OrderNum, 8)
END
/*@CommonGrp_TPPID
An ID assigned by First Data for the Third Party Processor, Software Vendor, or Merchant that generated the transaction.
This field is mandatory for all transactions.
an-6
*/
SET @CommonGrp_TPPID = @TPPID 
/*@CommonGrp_TermID
A unique ID assigned to a terminal.
The Terminal ID submitted in a subsequent transaction (e.g. Void, Completion Message, etc.) must match the Terminal ID that was submitted with the original authorization request.
This field is echoed in response messages.
an-8
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN	
	SET @CommonGrp_TermID  = @CommonGrp_TermID_orig
END
ELSE SET @CommonGrp_TermID = @TermID
/*@CommonGrp_MerchID
A unique ID assigned by First Data, to identify the Merchant.
The Merchant ID submitted in a subsequent transaction (e.g. Void, Completion Message, etc.) must match the Merchant ID that was submitted with the original authorization.
This field is echoed in response messages.
an-16
*/				
IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN	
	SET @CommonGrp_MerchID = @CommonGrp_MerchID_orig
END
ELSE SET @CommonGrp_MerchID = @MerchantIDNash 		
/*@CommonGrp_MerchCatCode
The merchant category code (MCC).
This field is optional and supplied if the merchant desires to use a specific MCC rather than the MCC set up in the merchant record.
If present in the original transaction, this field must be present in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) and refunds. The value should be the same as submitted in the original transaction
N-4
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN	
	if Len(IsNull(@CommonGrp_MerchCatCode_orig,'')) > 0 SET @CommonGrp_MerchCatCode  = @CommonGrp_MerchCatCode_orig
END
ELSE 
BEGIN
	if Len(IsNull(@MerchCatCode,'')) > 0 SET @CommonGrp_MerchCatCode = @MerchCatCode  	
END
/*@CommonGrp_POSEntryMode
An identifier used to indicate the terminal‘s account number entry mode and authentication capability via the Point-of-Service.
The only valid values for check transactions, for the Account Entry Mode (i.e. first two digits), are 01 and 04.
The second part of this field must have the value of 1 (PIN entry capability) for all Debit transactions.
The same value submitted at the time of authorization must be submitted on all subsequent transactions (Completions, Voids/Full Reversals, and Partial Reversals).
N-3
The first part is the account number entry mode, consisting of the following values:
00 – Unspecified
01 – Manual
03 – Barcode
04 – OCR
05 – Integrated Circuit Read (Reliable)
07 – Contactless Integrated Circuit Read (Reliable)
79 – Manual Entry at Chip Terminal
80 – Magnetic Stripe at Chip Terminal/Fallback (Reliable)
82 – Contactless Mobile Commerce
90 – Magnetic Stripe - Track Read
91 – Contactless Magnetic Stripe Read
95 – Integrated Circuit Read (CVV data unreliable)
The second part is the electronic/PIN authentication capability, consisting of the following values:
0 – Unspecified
1 – PIN entry capability
2 – No PIN entry capability
3 – PIN Pad Inoperative
4 – PIN verified by terminal device
*/
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and (@CommonGrp_ReversalInd = @ReversalInd_Void or @CommonGrp_TxnType = @TxnType_Completion)  --'Void' or 'Completion'
BEGIN
	SET @CommonGrp_POSEntryMode = @CommonGrp_POSEntryMode_orig
END	
ELSE 
BEGIN
	IF @MerchCatType in ('RETAIL','QUASICASH','EMERGINGMARKET') -- overwrite merchant settings value from MERCHANT_SETTINGS_RC table
		SELECT @CommonGrp_POSEntryMode =
			CASE @Track1PresentFlag 
			 WHEN 'Y' THEN '902'
			 ELSE '012'
			END 
	ELSE SET @CommonGrp_POSEntryMode = @POSEntryMode_RC -- use static merchant setting from MERCHANT_SETTINGS_RC table
END
/*@CommonGrp_POSCondCode
An identifier used to indicate the authorization conditions at the Point-of-Service (POS).
The only valid value for check transactions is 06.
Recurring transactions are only applicable for Visa, MasterCard, American Express, Discover (including Diners and JCB Domestic), and PINLess Debit transactions.
The only valid values for PINLess Debit are 04 and 59.
N-2
00 – Customer Present, Card Present
01 – Customer Present, Unspecified
02 – Customer Present, Unattended Device
03 – Customer Present, Suspect Fraud
04 – Customer Not Present – Recurring
05 – Customer Present, Card Not Present
06 – Customer Present, Identity Verified
08 – Customer Not Present, Mail Order/Telephone Order
59 – Customer Not Present, Ecommerce
71 – Customer Present, Magnetic Stripe Could Not Be Read
*/	
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and (@CommonGrp_ReversalInd = @ReversalInd_Void or @CommonGrp_TxnType = @TxnType_Completion)  --'Void' or 'Completion'
BEGIN
	SET @CommonGrp_POSCondCode = 	CASE @CommonGrp_POSCondCode_orig 
									WHEN '00' THEN '0'
									WHEN '01' THEN '1'
									WHEN '02' THEN '2'
									WHEN '03' THEN '3'
									WHEN '04' THEN '4'
									WHEN '05' THEN '5'
									WHEN '06' THEN '6'
									WHEN '08' THEN '7'
									WHEN '59' THEN '8'
									WHEN '71' THEN '9'
									ELSE ''
									END
END	
ELSE 
BEGIN
	IF @MerchCatType in ('RETAIL','QUASICASH','EMERGINGMARKET') -- overwrite merchant settings value from MERCHANT_SETTINGS_RC table
	SELECT @CommonGrp_POSCondCode =
			CASE @Track1PresentFlag 
			 WHEN 'Y' THEN '0' --00
			 ELSE '9' --71
			END 
	ELSE SET @CommonGrp_POSCondCode =	CASE @POSCondCode -- use static merchant setting from MERCHANT_SETTINGS_RC table
										WHEN '00' THEN '0'
										WHEN '01' THEN '1'
										WHEN '02' THEN '2'
										WHEN '03' THEN '3'
										WHEN '04' THEN '4'
										WHEN '05' THEN '5'
										WHEN '06' THEN '6'
										WHEN '08' THEN '7'
										WHEN '59' THEN '8'
										WHEN '71' THEN '9'
										ELSE ''
										END
END
/*@CommonGrp_TermCatCode
An identifier used to describe the type of terminal being used for the transaction.
N-2
00 – Unspecified
01 – Electronic Payment Terminal (POS)
05 – Automated Fuel Dispensing Machine (AFD)
06 – Unattended Customer Terminal
08 – Mobile Terminal (Transponder)
12 – Electronic Cash Register
17 – Ticket Machine
18 – Call Center Operator
*/			
SET @CommonGrp_TermCatCode =	CASE @TermCatCode  -- use static merchant setting from MERCHANT_SETTINGS_RC table
								WHEN '00' THEN '0'
								WHEN '01' THEN '1'
								WHEN '05' THEN '2'
								WHEN '06' THEN '3'
								WHEN '08' THEN '4'
								WHEN '12' THEN '5'
								WHEN '17' THEN '6'
								WHEN '18' THEN '7'
								ELSE ''
								END	
/*@CommonGrp_TermEntryCapablt
An identifier used to indicate the entry mode capability of the terminal
N-2
00 – Unspecified
01 – Terminal not used
02 – Magnetic stripe only
03 – Magnetic stripe and key entry
04 – Magnetic stripe, key entry and chip
05 – Bar code
06 – Proximity terminal - contactless chip / RFID
07 – OCR
08 – Chip only
09 – Chip and magnetic stripe
10 – Manual entry only
11 – Proximity terminal - contactless magnetic stripe
*/		
SET @CommonGrp_TermEntryCapablt =	CASE @TermEntryCapablt -- use static merchant setting from MERCHANT_SETTINGS_RC table
									WHEN '00' THEN '0'
									WHEN '01' THEN '1'
									WHEN '02' THEN '2'
									WHEN '03' THEN '3'
									WHEN '04' THEN '4'
									WHEN '05' THEN '5'
									WHEN '06' THEN '6'
									WHEN '07' THEN '7'
									WHEN '08' THEN '8'
									WHEN '09' THEN '9'
									WHEN '10' THEN '10'
									WHEN '11' THEN '11'
									ELSE ''
									END
/*@CommonGrp_TxnAmt
The amount of the transaction. This may be an authorization amount, adjustment amount or a reversal amount based on the type of transaction. It is inclusive of all additional amounts. It is submitted in the currency represented by the Transaction Currency field. The field is overwritten in the response for a partial authorization.
If the Transaction Type = BalanceInquiry or Verification, the transaction amount must be zero in the request message. For example, 000 for USD.
The field must have the correct number of implied decimal places as identified by the Transaction Currency.
For Prepaid Closed Loop Transactions, if the card is denominated then the Transaction Amount can be provided but it‘s not required for Activation and Load. If the Transaction Amount is provided, then it must match the denomination of the card.
The Transaction Amount will be returned in response messages.
an-13  (12 digits for numbers and a minus sign)
"-999999999999"
*/		
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and @CommonGrp_TxnType <> @TxnType_Completion --Completion
BEGIN
	SET @CommonGrp_TxnAmt = @CommonGrp_TxnAmt_orig
END	
ELSE 
BEGIN
	declare @amount_str varchar(13); set @amount_str = Cast(Cast(@Amount as numeric(16,2)) as varchar(13)) 
	declare @strDol varchar(13), @strCen as varchar(2), @dotPos int
	if CHARINDEX ('.', @amount_str) > 0
	begin
		set @dotPos =  CHARINDEX ('.', @amount_str)
		set @strDol = SUBSTRING(@amount_str, 1, @dotPos - 1)
		set @strCen = LEFT(SUBSTRING(@amount_str, @dotPos + 1, LEN(@amount_str) - @dotPos) + '00', 2)
		set @amount_str = @strDol + @strCen
	end
	else
	begin 
		set @amount_str = @amount_str + '00'
	end
	SET @CommonGrp_TxnAmt = @amount_str -- should not have long values but if len > 13 then exception will be thrown
END

/*@CommonGrp_TxnCrncy
The numeric currency of the Transaction Amount.
US currency = 840
N-3
"840"
*/
SET @CommonGrp_TxnCrncy = '840'	
/*@CommonGrp_TermLocInd
An indicator that describes the location of the terminal.
an-1
0 – On Premises
1 – Off Premises
*/	
SET @CommonGrp_TermLocInd = CASE @TermLocInd -- use static merchant setting from MERCHANT_SETTINGS_RC table
							WHEN '0' THEN '0'
							WHEN '1' THEN '1'
							ELSE ''
							END
/*@CommonGrp_CardCaptCap
Indicates whether or not the terminal has the capability to capture the card data.
If the value is 0 then Track Data should not be present
N-1
0 – terminal has no card capture capability or no terminal used
1 – terminal has card capture capability
*/
IF @Track1PresentFlag = 'Y' SET @CommonGrp_CardCaptCap = '1'
ELSE SET @CommonGrp_CardCaptCap =	CASE @CardCaptCap -- use static merchant setting from MERCHANT_SETTINGS_RC table
									WHEN '0' THEN '0'
									WHEN '1' THEN '1'
									ELSE ''
									END
/*@CommonGrp_GroupID
An ID assigned by First Data to identify the individual merchant or group of merchants.
This field is mandatory on all request messages.
an5-13
*/			 
SET @CommonGrp_GroupID = @GroupID 
/*@CardGrp_AcctNum
The account number of the card for which the transaction is being performed.
This field must be present if the Account Number is manually entered (POS Entry Mode = 01 or 79).
This field will not be returned on transactions in which a token is returned.
This field is not present for subsequent transactions where the merchant uses TransArmor.
This field must not be present in check transactions.
The Account Number will always be returned on Prepaid Closed Loop.
For Completions, this field should always be populated, except when the merchant uses TransArmor.
For Voids/Full Reversals, this field should always be populated, except when the merchant uses TransArmor or when the reversal was swiped with the Cardholder present.
If the transaction being submitted contains encrypted data in the TransArmor Encryption Block, this field will not be present.
N-24
*/			 
SET @CardGrp_AcctNum = @Last4PAN -- app side will populate this field properly, set last 4 here for logging to dbo.CC_TRANS_RC
/*@CardGrp_CardExpiryDate
The expiration date of the card being used for the transaction.
The DD part of this field is optional except for Prepaid Closed Loop.
This field must be present if the card number is manually entered (POS Entry Mode = 01 or 79) except for a TATokenRequest or Prepaid Closed Loop request.
This field must not be present in check transactions.
This field should not be sent in VeriFone Encryption Transactions.
If the expiration date was submitted in the original authorization, then the expiration date must also be submitted in any subsequent Timeout Reversal, or Void/Full Reversal requests.
N-6 or 8 depending on the presence or absence of DD part
YYYYMMDD
*/
IF @Track1PresentFlag <> 'Y'
BEGIN
	IF LEN(@CardExpirDate) = 4 --@CardExpirDate format MMYY
	BEGIN			
		declare @mmddyy datetime; set @mmddyy = Left(@CardExpirDate,2) + '/01/' + Right(@CardExpirDate,2) -- get MMDDYY based on @CardExpirDate
		SET @CardGrp_CardExpiryDate = Right(convert(varchar(25), @mmddyy, 101),4) + Left(@CardExpirDate,2) -- output format YYYYMM		 
	END		
	ELSE IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		SET @CardGrp_CardExpiryDate = @CardGrp_CardExpiryDate_orig
	END	
END		
/*@CardGrp_CardType
An identifier used to indicate the card type.
Card Type is required only when Payment Type is Credit or Prepaid
an-10
Amex – Amex
Diners - Diners
Discover – Discover
JCB – JCB
Mastercard – MasterCard
PPayCL – Prepaid Closed Loop
Visa – Visa
GiftCard – Gift Card
*/
IF LEN(@CardType) > 0 
BEGIN			
	SELECT @CardGrp_CardType =
			CASE @CardType
			 WHEN 'VN' THEN '6' --'Visa'
			 WHEN 'VA' THEN '6' --'Visa'
			 WHEN 'MC' THEN '4' --'Mastercard'
			 WHEN 'MN' THEN '4' --'Mastercard'
			 WHEN 'MA' THEN '4' --'Mastercard'
			 WHEN 'DS' THEN '2' --'Discover'
			 WHEN 'AMEX' THEN '0' --'Amex'
			 WHEN 'AN' THEN '0' --'Amex'
			 --below codes not used by epay, set for future use
			 WHEN 'DN' THEN '1' --'Diners'
			 WHEN 'JCB' THEN '3' --'JCB'			 
			END 	
END
ELSE IF Len(IsNull(@SeqNumber_Org,'')) > 0
BEGIN
	SET @CardGrp_CardType =	 CASE @CardGrp_CardType_orig
							 WHEN 'VN' THEN '6' --'Visa'
							 WHEN 'VA' THEN '6' --'Visa'
							 WHEN 'MC' THEN '4' --'Mastercard'
							 WHEN 'MN' THEN '4' --'Mastercard'
							 WHEN 'MA' THEN '4' --'Mastercard'
							 WHEN 'DS' THEN '2' --'Discover'
							 WHEN 'AMEX' THEN '0' --'Amex'
							 WHEN 'AN' THEN '0' --'Amex'
							 WHEN 'DN' THEN '1' --'Diners'
							 WHEN 'JCB' THEN '3' --'JCB'			 
							 END 	
END					
/*@CardGrp_AVSResultCode
The result of checking the cardholder‘s postal code and any additional address information provided against the Issuer‘s system of record.
This field is returned on any transaction in which address information is provided.
For Discover transactions, if this field was returned in the Authorization Response, the same value must be submitted in Subsequent transactions (e.g. Completion, Void/Full Reversal).
If the transaction is a Completion transaction and address verification was processed on the original Authorization, the AVS Result Code must be presented in the Completion message
an-1
If CARD Group.Card Type = Visa
A – Street address matches, postal code does not match
B – Street addresses match; postal code not verified due to incompatible formats
C – Street address and postal code not verified
D – Street address and postal code match (International only)
F – Street address and postal code match (UK)
G – Address information not verified for international transaction. Issuer is not an AVS Participant, or, AVS data was present in the request but the issuer did not return an AVS result, or no address on file (International only)
I – Address verification service not performed (International only)
M – Street address and postal codes match (International only)
N – No match; neither the street addresses nor the postal codes match
P – Postal code matches; street address not verified
R – Retry, system unavailable to process
S – Service not supported
U – Address information is unavailable
Y – Both postal code and address match
Z – Postal code matches, Street address does not match or Street address not included in request
If CARD Group.Card Type = Mastercard
A – Street address matches, postal code does not match
N – No match; neither the street addresses nor the postal codes match
R – Retry, system unavailable to process
S – Service not supported
U – Address information is unavailable
W – U.S. - Street Address does not match, nine digit postal code matches; For address outside the U.S., postal code matches, address does not
X – Exact: U.S. - Address and 9-digit postal code match; For address outside the U.S., postal code matches, address does not
Y – Yes: Address and 5-digit postal code match for US address
Z – Five digit postal code matches, address does not match
B – Visa Only. Street address matches for international transaction; postal code not verified
C – Visa Only. Street & postal code not verified
D – Visa Only. Street address and postal code matches for international transaction
F – Visa Only. Street addresses and postal codes match for international transaction (UK only)
G – Visa Only. Address information not verified for international transaction
I – Visa Only. Address information not verified for international transaction
M – Visa Only. Street address and postal codes match for international transaction
P – Visa Only. Postal code matches; street address not verified
If CARD Group.Card Type = Amex
A – Street address matches, postal code does not match
N – No match; neither the street addresses nor the postal code matches
R – Retry, system unavailable to process
S – Service not supported
U – Address information is unavailable
Y - Both postal code and address match
Z – Nine or five digit postal code matches, address does not match
D – Card member Name incorrect, Billing Postal Code matches
F – Card member Name incorrect, Billing Address matches
If CARD Group.Card Type = Discover or JCB
A - Both address and five digit postal code match
G – Address information not verified for international transaction
N – No match; neither the street addresses nor the postal code matches
R – Retry, system unable to process
S – Service not supported
T– No data received from Issuer
W – Nine digit postal code matches, address does not match
X – All digits match (nine digit zip code)
Y – Street address matches, postal code does not match
Z – Five digit postal code matches, address does not match
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 
	--NOTE: spec calls for all subsequent DS transactions to have AVSResultCode populated based on the original response however this appears to be false based on testing 
	--IF @CardType = 'DS' -- set @CardGrp_AVSResultCode for all subsequent transactions for Discover
	--BEGIN
	--	SET @CardGrp_AVSResultCode = CASE @CardGrp_AVSResultCode_orig
	--							 WHEN 'A' THEN '0'
	--							 WHEN 'B' THEN '1'
	--							 WHEN 'C' THEN '2'
	--							 WHEN 'D' THEN '3'
	--							 WHEN 'E' THEN '4'
	--							 WHEN 'F' THEN '5'
	--							 WHEN 'G' THEN '6'
	--							 WHEN 'I' THEN '7'
	--							 WHEN 'K' THEN '8'
	--							 WHEN 'L' THEN '9'
	--							 WHEN 'M' THEN '10'
	--							 WHEN 'N' THEN '11'
	--							 WHEN 'O' THEN '12'
	--							 WHEN 'P' THEN '13'
	--							 WHEN 'R' THEN '14'
	--							 WHEN 'S' THEN '15'
	--							 WHEN 'T' THEN '16'
	--							 WHEN 'U' THEN '17'
	--							 WHEN 'W' THEN '18'
	--							 WHEN 'X' THEN '19'
	--							 WHEN 'Y' THEN '20'
	--							 WHEN 'Z' THEN '21'
	--							 ELSE ''
	--							 END	
	--END
	--ELSE 
	IF @CommonGrp_TxnType = @TxnType_Completion --Completion
			and @TranType Not In ('VOID', 'REVERSAL')
	BEGIN
		SET @CardGrp_AVSResultCode = CASE @CardGrp_AVSResultCode_orig
									 WHEN 'A' THEN '0'
									 WHEN 'B' THEN '1'
									 WHEN 'C' THEN '2'
									 WHEN 'D' THEN '3'
									 WHEN 'E' THEN '4'
									 WHEN 'F' THEN '5'
									 WHEN 'G' THEN '6'
									 WHEN 'I' THEN '7'
									 WHEN 'K' THEN '8'
									 WHEN 'L' THEN '9'
									 WHEN 'M' THEN '10'
									 WHEN 'N' THEN '11'
									 WHEN 'O' THEN '12'
									 WHEN 'P' THEN '13'
									 WHEN 'R' THEN '14'
									 WHEN 'S' THEN '15'
									 WHEN 'T' THEN '16'
									 WHEN 'U' THEN '17'
									 WHEN 'W' THEN '18'
									 WHEN 'X' THEN '19'
									 WHEN 'Y' THEN '20'
									 WHEN 'Z' THEN '21'
									 ELSE ''
									 END	
	END	
ELSE SET @CardGrp_AVSResultCode = ''
/*@CardGrp_CCVInd
An identifier provided in the authorization request to indicate the presence of CCV data on the card.
The only valid value for MasterCard and Amex is 'Prvded'
an-12
Ntprvd – CCV value is deliberately bypassed or not provided
Prvded – CCV value is present
Illegible – CCV value is on the card but is illegible
NtOnCrd – No CCV value on card
*/		
IF @CVVPresentFlag  = 'Y' and Len(@CommonGrp_ReversalInd) = 0 and @CommonGrp_TxnType <> @TxnType_Completion SET @CardGrp_CCVInd = '1' --'Prvded'
ELSE SET @CardGrp_CCVInd = ''
/*@CardGrp_CCVResultCode
An identifier used to indicate the result code of the CCV verification.
This field is present in response messages when CCV validation is attempted.
an-6
Match – Values match
NoMtch – Values do not match
NotPrc – Not processed
NotPrv – Value not provided
NotPrt – Issuer not participating
Unknwn – Unknown
*/	
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and @CommonGrp_TxnType = @TxnType_Completion --Completion
SET @CardGrp_CCVResultCode = CASE @CardGrp_CCVResultCode_orig 
							 WHEN 'Match' THEN '0'
							 WHEN 'NoMtch' THEN '1'
							 WHEN 'NotPrc' THEN '2'
							 WHEN 'NotPrv' THEN '3'
							 WHEN 'NotPrt' THEN '4'
							 WHEN 'Unknwn' THEN '5'
							 ELSE ''
							END
ELSE SET @CardGrp_CCVResultCode = ''			
/*@AddtlAmtGrp_AddAmt
The value for a single additional amount instance. 
Multiple Additional Amounts may be contained within a single request or response message.
For each Additional Amount field that is present the corresponding Additional Amount Currency and Additional Amount Type fields will also be present.
The field must have the correct number of implied decimal places as identified by the Transaction Currency.
an-13
"-999999999999"
*/			 
SET @AddtlAmtGrp_AddAmt1 = '' -- set below as part of @AddtlAmtGrp_AddAmtType1
/*@AddtlAmtGrp_AddAmtCrncy
The numeric currency of the Additional Amount value. US currency - 840
Multiple Additional Amounts may be contained within a single request or response message. 
If the Additional Amount field is present then this field must also be present.
an-3
"840"	
*/
SET @AddtlAmtGrp_AddAmtCrncy1 = '' -- set below as part of @AddtlAmtGrp_AddAmtType1	
/*@AddtlAmtGrp_AddAmtType 
The type of Additional Amount. 
Multiple additional amounts may be contained within a single request or response message.
If the Additional Amount field is present then this field must also be present.
The FirstAuthAmt value must be submitted in Completion Messages and must contain the transaction amount that was initially authorized for the original transaction.
The TotalAuthAmt amount must be submitted on Void messages except for Prepaid Closed Loop.
When submitting the TotalAuthAmt in a Void message, the value must be equal to the total authorized amount.
For Completion messages the TotalAuthAmt should reflect the total amount authorized, including all Reversals and Voids/Full Reversals.
The OrigReqAmt may be returned on any transaction.
The Cashback amount for Debit or EBT (Cash Benefit) Voids/Full Reversals must match the original Debit or EBT (Cash Benefit) request.
The Cashback amount for Discover cannot be greater than $100.00 or the Transaction Amount, whichever is lesser.
an-12
Request Values:
Cashback – Cashback – Debit, EBT/Cash, Credit (Discover only) – the amount of cash requested by the cardholder at the time of purchase
Surchrg – Surcharge – identifies the transaction‘s surcharge amount
FirstAuthAmt – First Authorized Amount – the amount that was originally authorized
PreAuthAmt – Pre-Authorized Amount (EBT) – the amount that was pre-authorized.
TotalAuthAmt – Total Authorized Amount – the total transaction amount that was authorized. Note: Rapid Connect currently does not support incremental authorizations. The TotalAuthAmt should be the same as the FirstAuthAmt.
Tax – Tax Amount
Response Values:
BegBal – Beginning Balance – The balance before the transaction was applied, in the currency noted in the ADDITIONAL AMOUNTS Group.Additional Amounts Currency field. This value can be returned on EBT and Prepaid Closed Loop.
EndingBal – Ending Balance – The balance after the transaction was applied, in the currency noted in the ADDITIONAL AMOUNTS Group.Additional Amounts Currency field. This value can be returned on EBT and Prepaid Closed Loop.
AvailBal – Available Balance – Current available balance. Typically, this amount is the ledger balance less outstanding authorizations (since depository institutions also include pending deposits and the credit or overdraft line associated with the account). The available balance may be returned on Credit, Debit, EBT, or Open Loop Gift Cards.
LedgerBal – Ledger Balance – The ―posted balance for a deposit account.
Cashback – Cashback – For Prepaid Closed Loop ―cashback refers to payout from the POS to the cardholder as a result of the balance falling below the minimum. Functionality is based on promo set-up. Supported on Credit (Discover, JCB – US domestic only, and Diners), and Debit this is the amount that was provided to the cardholder, in cash.
HoldBal – Hold Balance – The value on the card that is locked due to a previous Balance Lock transaction. This value can be returned on Prepaid Closed Loop only.
Surchrg – Surcharge – The transaction‘s surcharge amount in the local currency of the Acquirer or the merchant‘s location.
OrigReqAmt – Original Requested Amount – the amount that was originally requested
PreAuthAmt – Pre-Authorized Amount (EBT) – the amount that was pre-authorized.
OpenToBuy – Open-to-buy (Credit Card)
*/	
IF (@TranType = 'REVERSAL' or @TranType = 'VOID')
BEGIN
	SET @AddtlAmtGrp_AddAmtType1 = '4' --'TotalAuthAmt'
	SET @AddtlAmtGrp_AddAmt1 = @CommonGrp_TxnAmt_orig
	SET @AddtlAmtGrp_AddAmtCrncy1 = '840'
END
ELSE IF (@TranType = 'CAPTURE')
BEGIN
	SET @AddtlAmtGrp_AddAmtType1 = '2' --'FirstAuthAmt'
	SET @AddtlAmtGrp_AddAmt1 = @CommonGrp_TxnAmt_orig
	SET @AddtlAmtGrp_AddAmtCrncy1 = '840'
	SET @AddtlAmtGrp_AddAmtType2 = '4' --'TotalAuthAmt'
	SET @AddtlAmtGrp_AddAmt2 = @CommonGrp_TxnAmt_orig 
	SET @AddtlAmtGrp_AddAmtCrncy2 = '840'
END
/*@AddtlAmtGrp_PartAuthrztnApprvlCapablt
An identifier used to indicate whether or not the terminal/software can support partial authorization approvals.
For Prepaid Closed Loop transactions the value must be 1.
For Credit Authorization and Sale transactions the value must be 1.
For Debit Sale transactions the value must be 1.
N-1
0 – Not Supported
1 – Partial authorization approvals are supported
*/	
IF (@TranType = 'AUTH' or @TranType = 'AUTH_CAPTURE')
BEGIN		
	SET @AddtlAmtGrp_PartAuthrztnApprvlCapablt1 = @PartAuthrztnApprvlCapablt 	
END
ELSE SET @AddtlAmtGrp_PartAuthrztnApprvlCapablt1 = ''
/*@EcommGrp_EcommTxnInd
An indicator provided by the merchant to identify the security level of an Ecommerce transaction. It is used for all major card types when participating in programs such as Verified by Visa and MasterCard SecureCode.
This field must be supplied on all E-commerce transactions.
For PINLess Debit E-commerce transactions, the only valid values are 03 and 04.
N-2
01 – Secure electronic commerce transaction
02 – Non-authenticated security transaction at a 3-D capable merchant
03 – Non-authenticated security transaction at a non 3-D capable merchant
04 – Non-secure transaction
*/		
IF @MerchCatType = 'ECOMM'	SET @EcommGrp_EcommTxnInd = CASE @EcommTxnInd
							WHEN '01' THEN '0'
							WHEN '02' THEN '1'
							WHEN '03' THEN '2'
							WHEN '04' THEN '3'
							ELSE ''
							END
/*@EcommGrp_CustSvcPhoneNumber
The phone number, provided by the merchant, that can be used to assist cardholder‘s with questions pertaining to the transaction.
This field is required for MOTO
an-10
*/		 
IF @MerchCatType = 'ECOMM' and @CommonGrp_TxnType in (@TxnType_Sale, @TxnType_Completion, @TxnType_Refund) and @CommonGrp_ReversalInd <> @ReversalInd_Void --('Void') --Sale, Completion, Refund
SET @EcommGrp_CustSvcPhoneNumber = @CustSvcPhoneNumber 
--always set it for MOTO merchants
IF @MerchCatType = 'MOTO' and @CommonGrp_TxnType in (@TxnType_Sale, @TxnType_Completion, @TxnType_Refund) and @CommonGrp_ReversalInd <> @ReversalInd_Void --('Void') --Sale, Completion, Refund
SET @EcommGrp_CustSvcPhoneNumber = @CustSvcPhoneNumber 
/*@EcommGrp_EcommURL
The URL of the site performing the Ecommerce transaction.
This field is required for Ecommerce/Web based Sale, Completion, Refund transactions.
For Visa, the length is up to 13 bytes
For Mastercard, the length is up to 32 bytes.
an-32
*/			
IF @MerchCatType = 'ECOMM' and @CommonGrp_TxnType in (@TxnType_Sale, @TxnType_Completion, @TxnType_Refund) and @CommonGrp_ReversalInd <> @ReversalInd_Void --('Void') --Sale, Completion, Refund
BEGIN
	SELECT @EcommGrp_EcommURL =
			CASE @CardType
			 WHEN 'VN' THEN Left(@EcommURL,13) --'Visa'
			 WHEN 'VA' THEN Left(@EcommURL,13) --'Visa'
			 WHEN 'MC' THEN Left(@EcommURL,32) --'Mastercard'
			 WHEN 'MN' THEN Left(@EcommURL,32) --'Mastercard'
			 WHEN 'MA' THEN Left(@EcommURL,32) --'Mastercard'
			 WHEN 'DS' THEN @EcommURL --'Discover'
			 WHEN 'AMEX' THEN @EcommURL --'Amex'
			 WHEN 'AN' THEN @EcommURL --'Amex'
			 --below codes not used by epay, set for future use
			 WHEN 'DN' THEN @EcommURL --'Diners'
			 WHEN 'JCB' THEN @EcommURL --'JCB'	
			 ELSE @EcommURL		 
			END 	
END
/*@VisaGrp_ACI
A code used to request qualification in the Custom Payment Service (CPS) program as defined by Visa. Upon evaluation, the code may be changed in the response message if provided by Visa.
Mandatory for Visa Credit Authorizations and Sales.
The value of R in the request message is only allowed for specific Select Developing Market merchants with the following MCC‘s - 4899, 5960, 5968, 5983, 6300, 8211, 8220, 8299, 8351, 8398, 9211, 9222, or 9399. Card-not-present transactions with these MCC‘s are not required to send AVS.
If a value is returned in the authorization response, the same value must be submitted on all subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.).
an-1
Possible Request Values:
Y – Transaction requests participation
R - Card-not-present, AVS not required
Possible Response Values:
A – Card Present
C – Card present with merchant name and location data (cardholder activated)
E - Card present with merchant name and location data
F - Card not present, Account Funding
K - Key Entered Transaction (error while reading magnetic stripe data)
N - Not a custom payment service transaction
R - Card-not-present, AVS not required
S - Card not present, e-commerce 3-D secure attempt
T - Transaction cannot participate in CPS programs
U - Card not present, 3-D secure
V - Card-not-present, AVS requested
W - Card not present, e-commerce non-3-D secure
*/		
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@VisaGrp_ACI_orig) > 0 SET @VisaGrp_ACI =	CASE @VisaGrp_ACI_orig
															WHEN 'A' THEN '2'
															WHEN 'C' THEN '3'
															WHEN 'E' THEN '4'
															WHEN 'F' THEN '5'
															WHEN 'K' THEN '6'
															WHEN 'N' THEN '7'
															WHEN 'R' THEN '1'
															WHEN 'R1' THEN '8'
															WHEN 'S' THEN '9'
															WHEN 'T' THEN '10'
															WHEN 'U' THEN '11'
															WHEN 'V' THEN '12'
															WHEN 'W' THEN '13'
															WHEN 'Y' THEN '0'
															ELSE ''
															END
	END
	ELSE
	BEGIN
		IF @CommonGrp_TxnType in (@TxnType_Authorization, @TxnType_Sale)
		SET @VisaGrp_ACI =	CASE @ACI
							WHEN 'A' THEN '2'
							WHEN 'C' THEN '3'
							WHEN 'E' THEN '4'
							WHEN 'F' THEN '5'
							WHEN 'K' THEN '6'
							WHEN 'N' THEN '7'
							WHEN 'R' THEN '1'
							WHEN 'R1' THEN '8'
							WHEN 'S' THEN '9'
							WHEN 'T' THEN '10'
							WHEN 'U' THEN '11'
							WHEN 'V' THEN '12'
							WHEN 'W' THEN '13'
							WHEN 'Y' THEN '0'
							ELSE ''
							END
		ELSE SET @VisaGrp_ACI = ''
	END
END
/*@VisaGrp_CardLevelResult
A value returned by Visa, to designate the type of card product used to process the transaction.
If this field is received in an authorization response message, it must be submitted in any subsequent Completion Message.
an-2
*/			
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0 and @CommonGrp_TxnType = @TxnType_Completion --Completion
	BEGIN
		IF LEN(@VisaGrp_CardLevelResult_orig) > 0 SET @VisaGrp_CardLevelResult = @VisaGrp_CardLevelResult_orig
	END
END	
/*@VisaGrp_TransID
A unique value up to 20 digits assigned by Visa, used to identify and link together all related transactions for authorization and settlement through Visa. This field contains Transaction Identifier and Validation Code.
This field may be returned on Visa authorization response messages, when the payment type is Credit.
This field must be submitted on subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) just as it was returned in the authorization response message, if available.
an-20
The last 4 characters represent Validation Code and all the characters before that represent Transaction ID
*/		
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@VisaGrp_TransID_orig) > 0 SET @VisaGrp_TransID = @VisaGrp_TransID_orig
	END
END
/*@VisaGrp_VisaBID
Business Identifier (BID) provided by Visa to Third Party Servicers (TPS).
This field is applicable only if the merchant is assigned a TPP ID.
Multiple VISA BID values may be contained within a single request message.
If the BID has not been assigned by Visa, spaces should be submitted in this field.
ans-10
*/
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF LEN(@CommonGrp_TPPID) > 0
	BEGIN
		IF @CommonGrp_ReversalInd <> @ReversalInd_Void --'Void'
		BEGIN
			IF LEN(@VisaBID) > 0 SET @VisaGrp_VisaBID = @VisaBID 
			ELSE SET @VisaGrp_VisaBID = REPLICATE(' ', 10)
		END
	END
END			
/*@VisaGrp_VisaAUAR
Visa's Agent Unique Account Result (AUAR).
This field is applicable only if the merchant is assigned a TPP ID.
Multiple VISA AUAR values may be contained within a single request message.
If an AUAR has not been assigned by Visa, 6 bytes (12-digits) of Hex 0 should be submitted (e.g. 000000000000).
h-12
12 hex digits Example: 123456789012
*/			
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF LEN(@CommonGrp_TPPID) > 0
	BEGIN
		IF @CommonGrp_ReversalInd <> @ReversalInd_Void --'Void'
		BEGIN
			IF LEN(@VisaAUAR) > 0 SET @VisaGrp_VisaAUAR = @VisaAUAR 
			ELSE SET @VisaGrp_VisaAUAR = REPLICATE('0', 12)
		END
	END
END						
/*@VisaGrp_TaxAmtCapablt
An indicator that describes the capability of the POS to Prompt for the Tax Amount, and then handle the Commercial card type in the response message.
If a Visa commercial card (Business, Corporate, or Purchasing) is used, the terminal should prompt for the Tax Amount.
an-2
Request Messages:
0 – Terminal is Not Tax Prompt Capable
1 – Terminal is Tax Prompt Capable
Response Messages:
VB – Visa Business Card
VC – Visa Corporate Card
VP – Visa Purchasing Card
TX – Unable to obtain information (prompt for Tax)
NA – The card is not listed as above
*/			
IF @CardGrp_CardType = '6' --'Visa'
BEGIN
	IF @CommonGrp_ReversalInd <> @ReversalInd_Void --'Void' 
		and @CommonGrp_TxnType not in (@TxnType_Completion, @TxnType_Refund) SET @VisaGrp_TaxAmtCapablt = @TaxAmtCapablt
END			
/*@MCGrp_BanknetData 
Data that is assigned by MasterCard, to every transaction that is processed through MasterCard‘s Banknet System.
The BankNet Reference Data will be returned in authorization response messages, when available.
When submitting subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) the same BankNet Reference Data must be provided if returned in the authorization response.
an-13
This field consists of BankNet Date (MMDD) followed by a 9 byte BankNet Reference Number.
*/			
IF @CardGrp_CardType = '4' --'Mastercard'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@MCGrp_BanknetData_orig) > 0 SET @MCGrp_BanknetData = @MCGrp_BanknetData_orig
	END
END
/*@MCGrp_CCVErrorCode
An error code that may be returned in response to the CCV submitted at the time of authorization. 
If this field is returned in an authorization response, the same value must be provided in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.).
an-1
Y – CCV Error
*/			
IF @CardGrp_CardType = '4' --'Mastercard'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@MCGrp_CCVErrorCode_orig) > 0 SET @MCGrp_CCVErrorCode =	CASE @MCGrp_CCVErrorCode_orig
																		WHEN 'Y' THEN '0'
																		ELSE ''
																		END
	END
END
/*@MCGrp_POSEntryModeChg
A value that indicates that the POS Entry Mode was changed by the Issuer.
If this field is received on a MasterCard transaction, it must be submitted on any subsequent transactions (e.g. Voids/Full Reversals, Completion Message, etc.).
an-1
Y – POS Entry Mode was changed by Issuer
*/			
IF @CardGrp_CardType = '4' --'Mastercard'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@MCGrp_POSEntryModeChg_orig) > 0 SET @MCGrp_POSEntryModeChg =	CASE @MCGrp_POSEntryModeChg_orig
																				WHEN 'Y' THEN '0'
																				ELSE ''
																				END
		
	END
END
/*@MCGrp_TranEditErrCode
An indicator that identifies the error encountered with the track data provided in the authorization request message.
If there is an error with Track Data, this field may be returned from the Issuer with a value describing the error.
an-1
0 – Track 1 or Track 2 Not Present in the Message
1 – PAN is Not the Same as the Card Number Submitted in the Track Data
2 – Expiration Date is Not the Same as the Expiration Data in the Track Data
3 – Card Type is Invalid in the Track Data
4 – Field Separators are Invalid in the Track Data
5 – A Field Within the Track Data Exceeds the Maximum Length
6 – The Transaction Category Code is ―T
7 – POS Customer Presence Indicator is ―1
8 – POS Card Presence Indicator is ―1
*/			
SET @MCGrp_TranEditErrCode = ''	-- updated after the RC API call on the app side		
/*@DSGrp_DiscProcCode
A value used to identify the type of transaction sent to the Card Acceptor.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message.
an-6
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscProcCode_orig) > 0 SET @DSGrp_DiscProcCode = @DSGrp_DiscProcCode_orig
	END
END
/*@DSGrp_DiscPOSEntry
The entry mode provided to Discover for the transaction.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message
an-4
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscPOSEntry_orig) > 0 SET @DSGrp_DiscPOSEntry = @DSGrp_DiscPOSEntry_orig
	END
END
/*@DSGrp_DiscRespCode
The code assigned by Discover which indicates the status of the transaction.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message.
an-2
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscRespCode_orig) > 0 SET @DSGrp_DiscRespCode = @DSGrp_DiscRespCode_orig
	END
END
/*@DSGrp_DiscPOSData
The specific POS capture conditions for the card information at the time of the transaction.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message.
an-13
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscPOSData_orig) > 0 SET @DSGrp_DiscPOSData = @DSGrp_DiscPOSData_orig
	END
END		
/*@DSGrp_DiscTransQualifier
The indicator used to identify the magnetic stripe conditions and the vulnerability to fraud for Discover and Network Card transactions.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message.
an-2
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscTransQualifier_orig) > 0 SET @DSGrp_DiscTransQualifier = @DSGrp_DiscTransQualifier_orig
	END
END	
/*@DSGrp_DiscNRID
The Network Result Indicator (NRID) assigned by Discover.
This field may be returned in the authorization response, if available.
This field must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.) if it was returned in the authorization response message.
an-15
*/			
IF @CardGrp_CardType = '2' --'Discover'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@DSGrp_DiscNRID_orig) > 0 SET @DSGrp_DiscNRID = @DSGrp_DiscNRID_orig
	END
END	
/*@AmexGrp_AmExPOSData
Transaction specific data that is returned by Am Ex and required on subsequent transactions.
The POS Data may be returned in the response message to an original authorization request.
The same POS Data values that were received in the original response message must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.).
an-12
*/			
IF @CardGrp_CardType = '0' --'Amex'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@AmexGrp_AmExPOSData_orig) > 0 SET @AmexGrp_AmExPOSData = @AmexGrp_AmExPOSData_orig
	END
END	
/*@AmexGrp_AmExTranID
A unique value up to 20 digits assigned by American Express, used to identify and link together all related transactions for authorization and settlement through American Express. This field contains the Transaction Identifier and Validation Code.
The Am Ex Tran ID may be returned in the response message to an original authorization request.
The same Am Ex Tran ID that was received in the original response message must be submitted in subsequent transactions (e.g. Voids/Full Reversals, Completion Messages, etc.).
an-20
*/			
IF @CardGrp_CardType = '0' --'Amex'
BEGIN
	IF Len(IsNull(@SeqNumber_Org,'')) > 0
	BEGIN
		IF LEN(@AmexGrp_AmExTranID_orig) > 0 SET @AmexGrp_AmExTranID = @AmexGrp_AmExTranID_orig
	END
END	
/*@CustInfoGrp_AVSBillingAddr
The street address of the customer.
an-30
*/	
IF Len(IsNull(@SeqNumber_Org,'')) > 0 
BEGIN
	IF @CommonGrp_ReversalInd <> @ReversalInd_Void --'Void' 
	SET @CustInfoGrp_AVSBillingAddr = @CustInfoGrp_AVSBillingAddr_orig
	ELSE SET @CustInfoGrp_AVSBillingAddr = ''
END
ELSE IF @CommonGrp_TxnType not in (@TxnType_Refund) SET @CustInfoGrp_AVSBillingAddr = Left(@Street, 30)
ELSE SET @CustInfoGrp_AVSBillingAddr = ''
/*@CustInfoGrp_AVSBillingPostalCode
The postal or zip code of the cardholder.
an-9
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 
BEGIN
	IF @CommonGrp_ReversalInd <> @ReversalInd_Void --'Void' 
	SET @CustInfoGrp_AVSBillingPostalCode = @CustInfoGrp_AVSBillingPostalCode_orig
	ELSE SET @CustInfoGrp_AVSBillingPostalCode = ''
END
ELSE IF @CommonGrp_TxnType not in (@TxnType_Refund) 
BEGIN
	IF IsNumeric(REPLACE(REPLACE(REPLACE(@Zip,' ',''),'.',''),'-','')) <> 1 -- remove space, dot, dash
	SET @CustInfoGrp_AVSBillingPostalCode = '' --send blank since an invalid zip was provided
	ELSE													
	SET @CustInfoGrp_AVSBillingPostalCode = Left(REPLACE(REPLACE(REPLACE(@Zip,' ',''),'.',''),'-',''),5) --send zip5 for US address
END
ELSE SET @CustInfoGrp_AVSBillingPostalCode = ''
/*@RespGrp_RespCode
The value returned by the authorizing endpoint that represents the status of the transaction.
This field is present in responses to transactions that are successfully processed by Rapid Connect.
A Response Code of "000" does not mean the Void was successfully processed but is simply an acknowledgement that request was received. 
A 914 Response Code will be returned if the original transaction is not found or already reversed or settled (refund may be needed).
an-3
*/			
SET @RespGrp_RespCode = ''			
/*@RespGrp_AuthID
The value assigned by the authorizer and returned in the response to the authorization request.
This field is present in approved responses to transactions that are successfully processed by Rapid Connect.
an-8
*/			
SET @RespGrp_AuthID = ''
/*@RespGrp_AddtlRespData
Additional data that may be returned in an authorization response message. This field could contain values that describe things like the reason for a decline, the field in error, etc.
This field will be returned when data is available.
A 914 response will be returned on Void/Full Reversal requests in which the Original Authorization was not found.
ans-50
*/			
SET @RespGrp_AddtlRespData = ''			
/*@RespGrp_AthNtwkID
This field indicates the Network ID as returned by the host, when available.
This field may be returned in a response message when available.
an-3
*/			
SET @RespGrp_AthNtwkID = ''
/*@RespGrp_ErrorData
A code and description returned in the response message that describes an error condition encountered when processing the transaction.
This field will only be returned if the transaction could not be processed.
an-255
EC000 – XML Validation Error: <text describing error>
EC001 – Invalid Field Length: <field name>
EC002 – Invalid Field Value: <field name>
EC003 – Invalid Field Format: <field name>
EC004 – Invalid Field Attribute: <field name>
EC005 – Missing Mandatory Field: <field name>
EC006 – Missing: <field name> related field to: <field name>
EC007 – Invalid Field Value: <field name> related to: <field name>
EC008 – Unexpected Field: <field name>
EC009 – Unsupported Field: <field name>
EC010 – Unexpected Message
EC011 – Unsupported Message
REnnnn – <text describing Rules Engine error> e.g. RE0288 – ProdDesc is missing
RXnnnn – <text describing Rules Engine error> e.g. RX001:RE unable to process transaction
TCnnnn – <text describing Test Case error>
*/			
SET @RespGrp_ErrorData = ''
/*@OrigAuthGrp_OrigAuthID
The Authorization ID of the response to the original message.
If the Authorization ID was returned in the response to the original authorization the same value should be provided in subsequent transactions.
an-8
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and LEN(@RespGrp_AuthID_orig) > 0 SET @OrigAuthGrp_OrigAuthID = @RespGrp_AuthID_orig
ELSE SET @OrigAuthGrp_OrigAuthID = ''
/*@OrigAuthGrp_OrigLocalDateTime
The local date and time of the original authorization transaction.
This field is required for all subsequent transactions.
Required for Time out Reversals.
If the Reversal Reason Code is TORVoid, this field must have the Original Local Date and Time of the Void message and not the original transaction.
N-14
YYYYMMDDhhmmss
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and LEN(@CommonGrp_LocalDateTime_orig) > 0 SET @OrigAuthGrp_OrigLocalDateTime = @CommonGrp_LocalDateTime_orig
ELSE SET @OrigAuthGrp_OrigLocalDateTime = ''
/*@OrigAuthGrp_OrigTranDateTime
The transmission date and time of the original transaction (in GMT).
This field is required for all subsequent transactions.
Required for Timeout Reversals.
N-14
YYYYMMDDhhmmss
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and LEN(@CommonGrp_TrnmsnDateTime_orig) > 0 SET @OrigAuthGrp_OrigTranDateTime = @CommonGrp_TrnmsnDateTime_orig
ELSE SET @OrigAuthGrp_OrigTranDateTime = ''
/*@OrigAuthGrp_OrigSTAN
The STAN (System Trace Audit Number) of the original transaction.
This field is required for all subsequent transactions.
Required for Time out Reversals.
N-6
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and LEN(@CommonGrp_STAN_orig) > 0 SET @OrigAuthGrp_OrigSTAN = @CommonGrp_STAN_orig
ELSE SET @OrigAuthGrp_OrigSTAN = ''
/*@OrigAuthGrp_OrigRespCode
The response code returned in the original authorization response.
This field is required for all subsequent transactions.,
N-3
*/			
IF Len(IsNull(@SeqNumber_Org,'')) > 0 and LEN(@RespGrp_RespCode_orig) > 0 SET @OrigAuthGrp_OrigRespCode = @RespGrp_RespCode_orig
ELSE SET @OrigAuthGrp_OrigRespCode = ''			
						

--<<< SET ALL OUTPUT PARAMS END >>>--



--<<< CREATE LOG RECORD START >>>--

--insert/log all RC values into the CC_TRANS_RC table
INSERT INTO [dbo].[CC_TRANS_RC]
           ([CC_TRANS_CCTranID]
           ,[RC_RequestType]
           ,[CommonGrp_PymtType]
           ,[CommonGrp_ReversalInd]
           ,[CommonGrp_TxnType]
           ,[CommonGrp_LocalDateTime]
           ,[CommonGrp_TrnmsnDateTime]
           ,[CommonGrp_STAN]
           ,[CommonGrp_RefNum]
           ,[CommonGrp_OrderNum]
           ,[CommonGrp_TPPID]
           ,[CommonGrp_TermID]
           ,[CommonGrp_MerchID]
           ,[CommonGrp_MerchCatCode]
           ,[CommonGrp_POSEntryMode]
           ,[CommonGrp_POSCondCode]
           ,[CommonGrp_TermCatCode]
           ,[CommonGrp_TermEntryCapablt]
           ,[CommonGrp_TxnAmt]
           ,[CommonGrp_TxnCrncy]
           ,[CommonGrp_TermLocInd]
           ,[CommonGrp_CardCaptCap]
           ,[CommonGrp_GroupID]
           ,[CardGrp_AcctNum]
           ,[CardGrp_CardExpiryDate]
           ,[CardGrp_CardType]
           ,[CardGrp_AVSResultCode]
           ,[CardGrp_CCVInd]
           ,[CardGrp_CCVResultCode]
           ,[AddtlAmtGrp_AddAmt1]
           ,[AddtlAmtGrp_AddAmtCrncy1]
           ,[AddtlAmtGrp_AddAmtType1]
           ,[AddtlAmtGrp_PartAuthrztnApprvlCapablt1]
           ,[AddtlAmtGrp_AddAmt2]
           ,[AddtlAmtGrp_AddAmtCrncy2]
           ,[AddtlAmtGrp_AddAmtType2]
           ,[AddtlAmtGrp_PartAuthrztnApprvlCapablt2]
           ,[AddtlAmtGrp_AddAmt3]
           ,[AddtlAmtGrp_AddAmtCrncy3]
           ,[AddtlAmtGrp_AddAmtType3]
           ,[AddtlAmtGrp_PartAuthrztnApprvlCapablt3]
           ,[EcommGrp_EcommTxnInd]
           ,[EcommGrp_CustSvcPhoneNumber]
           ,[EcommGrp_EcommURL]
           ,[VisaGrp_ACI]
           ,[VisaGrp_CardLevelResult]
           ,[VisaGrp_TransID]
           ,[VisaGrp_VisaBID]
           ,[VisaGrp_VisaAUAR]
           ,[VisaGrp_TaxAmtCapablt]
           ,[MCGrp_BanknetData]
           ,[MCGrp_CCVErrorCode]
           ,[MCGrp_POSEntryModeChg]
           ,[MCGrp_TranEditErrCode]
           ,[DSGrp_DiscProcCode]
           ,[DSGrp_DiscPOSEntry]
           ,[DSGrp_DiscRespCode]
           ,[DSGrp_DiscPOSData]
           ,[DSGrp_DiscTransQualifier]
           ,[DSGrp_DiscNRID]
           ,[AmexGrp_AmExPOSData]
           ,[AmexGrp_AmExTranID]
           ,[CustInfoGrp_AVSBillingAddr]
           ,[CustInfoGrp_AVSBillingPostalCode]
           ,[RespGrp_RespCode]
           ,[RespGrp_AuthID]
           ,[RespGrp_AddtlRespData]
           ,[RespGrp_AthNtwkID]
           ,[RespGrp_ErrorData]
           ,[OrigAuthGrp_OrigAuthID]
           ,[OrigAuthGrp_OrigLocalDateTime]
           ,[OrigAuthGrp_OrigTranDateTime]
           ,[OrigAuthGrp_OrigSTAN]
           ,[OrigAuthGrp_OrigRespCode])
     VALUES
           (@CCTranID,
			@RC_RequestType,
			@CommonGrp_PymtType ,
			--@CommonGrp_ReversalInd ,
		CASE @CommonGrp_ReversalInd 
         WHEN '1' THEN 'Void'
         --below reversal ind values are not used in the sp but listed for future needs
         WHEN '0' THEN 'Timeout'
         WHEN '2' THEN 'VoidFr'
         WHEN '3' THEN 'TORVoid'
         WHEN '4' THEN 'Partial'
         ELSE ''
		END,
			--@CommonGrp_TxnType ,
	 CASE @CommonGrp_TxnType 
         WHEN '1' THEN 'Authorization'
         WHEN '14' THEN 'Sale'
         WHEN '6' THEN 'Completion'
         WHEN '12' THEN 'Refund'
         ELSE ''
	 END,	
			@CommonGrp_LocalDateTime ,
			@CommonGrp_TrnmsnDateTime ,
			@CommonGrp_STAN ,
			@CommonGrp_RefNum ,
			@CommonGrp_OrderNum ,
			@CommonGrp_TPPID ,
			@CommonGrp_TermID,
			@CommonGrp_MerchID ,
			@CommonGrp_MerchCatCode,
			@CommonGrp_POSEntryMode ,
			--@CommonGrp_POSCondCode ,
	CASE @CommonGrp_POSCondCode
	WHEN '0' THEN '00'
	WHEN '1' THEN '01'
	WHEN '2' THEN '02'
	WHEN '3' THEN '03'
	WHEN '4' THEN '04'
	WHEN '5' THEN '05'
	WHEN '6' THEN '06'
	WHEN '7' THEN '08'
	WHEN '8' THEN '59'
	WHEN '9' THEN '71'
	ELSE ''
	END,
			--@CommonGrp_TermCatCode ,
	CASE @CommonGrp_TermCatCode
	WHEN '0' THEN '00'
	WHEN '1' THEN '01'
	WHEN '2' THEN '05'
	WHEN '3' THEN '06'
	WHEN '4' THEN '08'
	WHEN '5' THEN '12'
	WHEN '6' THEN '17'
	WHEN '7' THEN '18'
	ELSE ''
	END,
			--@CommonGrp_TermEntryCapablt,
	CASE @CommonGrp_TermEntryCapablt
	WHEN '0' THEN '00'
	WHEN '1' THEN '01'
	WHEN '2' THEN '02'
	WHEN '3' THEN '03'
	WHEN '4' THEN '04'
	WHEN '5' THEN '05'
	WHEN '6' THEN '06'
	WHEN '7' THEN '07'
	WHEN '8' THEN '08'
	WHEN '9' THEN '09'
	WHEN '10' THEN '10'
	WHEN '11' THEN '11'
	ELSE ''
	END,
			@CommonGrp_TxnAmt ,
			@CommonGrp_TxnCrncy ,
			--@CommonGrp_TermLocInd ,
	CASE @CommonGrp_TermLocInd 
	WHEN '0' THEN '0'
	WHEN '1' THEN '1'
	ELSE ''
	END,
			--@CommonGrp_CardCaptCap ,
	CASE @CommonGrp_CardCaptCap
	WHEN '0' THEN '0'
	WHEN '1' THEN '1'
	ELSE ''
	END,
			@CommonGrp_GroupID ,
			@CardGrp_AcctNum ,
			@CardGrp_CardExpiryDate ,
			--@CardGrp_CardType ,
	CASE @CardGrp_CardType
	WHEN '6' THEN 'Visa'
	WHEN '4' THEN 'Mastercard'
	WHEN '2' THEN 'Discover'
	WHEN '0' THEN 'Amex'
	WHEN '1' THEN 'Diners'
	WHEN '3' THEN 'JCB'
	ELSE ''			 
	END, 	
			--@CardGrp_AVSResultCode,
	CASE @CardGrp_AVSResultCode
	WHEN '0' THEN 'A'
	WHEN '1' THEN 'B'
	WHEN '2' THEN 'C'
	WHEN '3' THEN 'D'
	WHEN '4' THEN 'E'
	WHEN '5' THEN 'F'
	WHEN '6' THEN 'G'
	WHEN '7' THEN 'I'
	WHEN '8' THEN 'K'
	WHEN '9' THEN 'L'
	WHEN '10' THEN 'M'
	WHEN '11' THEN 'N'
	WHEN '12' THEN 'O'
	WHEN '13' THEN 'P'
	WHEN '14' THEN 'R'
	WHEN '15' THEN 'S'
	WHEN '16' THEN 'T'
	WHEN '17' THEN 'U'
	WHEN '18' THEN 'W'
	WHEN '19' THEN 'X'
	WHEN '20' THEN 'Y'
	WHEN '21' THEN 'Z'
	ELSE ''
	END,	
			--@CardGrp_CCVInd ,
	CASE @CardGrp_CCVInd
	WHEN '0' THEN 'Ntprvd'
	WHEN '1' THEN 'Prvded'
	WHEN '2' THEN 'Illegible'
	WHEN '3' THEN 'NtOnCrd'
	ELSE ''
	END,
			@CardGrp_CCVResultCode,
			@AddtlAmtGrp_AddAmt1 ,
			@AddtlAmtGrp_AddAmtCrncy1 ,
			--@AddtlAmtGrp_AddAmtType1 ,
	CASE @AddtlAmtGrp_AddAmtType1 
	WHEN '2' THEN 'FirstAuthAmt'
	WHEN '4' THEN 'TotalAuthAmt'
	ELSE ''
	END,

			@AddtlAmtGrp_PartAuthrztnApprvlCapablt1 ,
			@AddtlAmtGrp_AddAmt2 ,
			@AddtlAmtGrp_AddAmtCrncy2 ,
			--@AddtlAmtGrp_AddAmtType2 ,
	CASE @AddtlAmtGrp_AddAmtType2 
	WHEN '2' THEN 'FirstAuthAmt'
	WHEN '4' THEN 'TotalAuthAmt'
	ELSE ''
	END,
			@AddtlAmtGrp_PartAuthrztnApprvlCapablt2 ,
			@AddtlAmtGrp_AddAmt3 ,
			@AddtlAmtGrp_AddAmtCrncy3 ,
			--@AddtlAmtGrp_AddAmtType3 ,
	CASE @AddtlAmtGrp_AddAmtType3 
	WHEN '2' THEN 'FirstAuthAmt'
	WHEN '4' THEN 'TotalAuthAmt'
	ELSE ''
	END,
			@AddtlAmtGrp_PartAuthrztnApprvlCapablt3 ,
			--@EcommGrp_EcommTxnInd ,
	CASE @EcommGrp_EcommTxnInd 
	WHEN '0' THEN '01'
	WHEN '1' THEN '02'
	WHEN '2' THEN '03'
	WHEN '3' THEN '04'
	ELSE ''
	END,
			@EcommGrp_CustSvcPhoneNumber ,
			@EcommGrp_EcommURL ,
			--@VisaGrp_ACI ,
	CASE @VisaGrp_ACI
	WHEN '2' THEN 'A'
	WHEN '3' THEN 'C'
	WHEN '4' THEN 'E'
	WHEN '5' THEN 'F'
	WHEN '6' THEN 'K'
	WHEN '7' THEN 'N'
	WHEN '1' THEN 'R'
	WHEN '8' THEN 'R1'
	WHEN '9' THEN 'S'
	WHEN '10' THEN 'T'
	WHEN '11' THEN 'U'
	WHEN '12' THEN 'V'
	WHEN '13' THEN 'W'
	WHEN '0' THEN 'Y'
	ELSE ''
	END,
			@VisaGrp_CardLevelResult ,
			@VisaGrp_TransID ,
			@VisaGrp_VisaBID ,
			@VisaGrp_VisaAUAR ,
			@VisaGrp_TaxAmtCapablt ,
			@MCGrp_BanknetData ,
			--@MCGrp_CCVErrorCode ,
	CASE @MCGrp_CCVErrorCode
	WHEN '0' THEN 'Y'
	ELSE ''
	END,
			--@MCGrp_POSEntryModeChg ,
	CASE @MCGrp_POSEntryModeChg 
	WHEN '0' THEN 'Y'
	ELSE ''
	END,
			@MCGrp_TranEditErrCode,
			@DSGrp_DiscProcCode ,
			@DSGrp_DiscPOSEntry ,
			@DSGrp_DiscRespCode ,
			@DSGrp_DiscPOSData ,
			@DSGrp_DiscTransQualifier ,
			@DSGrp_DiscNRID ,
			@AmexGrp_AmExPOSData ,
			@AmexGrp_AmExTranID ,
			@CustInfoGrp_AVSBillingAddr ,
			@CustInfoGrp_AVSBillingPostalCode ,
			@RespGrp_RespCode ,
			@RespGrp_AuthID ,
			@RespGrp_AddtlRespData ,
			@RespGrp_AthNtwkID ,
			@RespGrp_ErrorData ,
			@OrigAuthGrp_OrigAuthID ,
			@OrigAuthGrp_OrigLocalDateTime ,
			@OrigAuthGrp_OrigTranDateTime ,
			@OrigAuthGrp_OrigSTAN ,
			@OrigAuthGrp_OrigRespCode )
IF @@ERROR = 0
BEGIN
	SET @RC_CCTranID = SCOPE_IDENTITY()
	SET @ErrMessage = 'Success'
END
ELSE
BEGIN
	SET @RC_CCTranID = -153
	SET @ErrMessage = 'Unable to insert record into the dbo.CC_TRANS_RC table.'
END
--<<< CREATE LOG RECORD END >>>--

--return values back to the app
RETURN

