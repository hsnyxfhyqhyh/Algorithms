USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[addCCTrans]    Script Date: 3/23/2021 4:56:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER    proc [dbo].[addCCTrans]
@UserLogin varchar(50),
@UserName varchar(50),
@CyberSrv varchar(25), 
@MerchantID varchar(32),
@TranType varchar(50), 
@LocationCode varchar(10),
@MerchantCode varchar(10),
@CustomerID varchar(25), 
@ProductDesc varchar(50), 
@OrderID varchar(50), 
@TranState char(1) = null, 
@Last4PAN varchar(4), 
@CardExpirDate varchar(4) = '', 
@CardType varchar(4) = '', 
@Amount numeric(16,4), 
@CustomerName varchar(26), 
@Street varchar(50), 
@City varchar(50) = null, 
@State varchar(2) = null, 
@Zip varchar(9), 
@SeqNumber_Org varchar(15), 
@TokenNumber int, 
@TranResult varchar(25) = null, 
@ReturnMessage varchar(255) = null, 
@AuthResponseCode varchar(25) = null, 
@AuthResponseMessage varchar(255) = null, 
@ApprovalCode varchar(25) = null, 
@AddressMatch char(1) = null, 
@ZipMatch char(1) = null, 
@CVVResultCode varchar(4) = null, 
@SeqNumber varchar(15) = null,
@CCTranID int out
as

declare @UserID int
select @UserID = [USER_ID] from [user] where USER_LOGIN = @UserLogin

INSERT INTO [CC_TRANS](
[CyberSrv], [MerchantID], [TranType], [UserID], [UserName], [LocationCode], [MerchantCode], [CustomerID], [ProductDesc], [OrderID],
[TranState], [Last4PAN], [CardExpirDate], [CardType], [Amount], [CustomerName], [Street], [City], [State], [Zip], [SeqNumber], [TokenNumber], 
[TranResult], [ReturnMessage], [AuthResponseCode], [AuthResponseMessage], [ApprovalCode], [AddressMatch], [ZipMatch], [CVVResultCode], [SeqNumber_Org])
VALUES(
@CyberSrv, @MerchantID, 
@TranType, @UserID, @UserName, @LocationCode, @MerchantCode, @CustomerID, @ProductDesc, @OrderID, @TranState, 
@Last4PAN, @CardExpirDate, @CardType, @Amount, @CustomerName, @Street, @City, @State, @Zip, @SeqNumber, @TokenNumber, @TranResult, @ReturnMessage, 
@AuthResponseCode, @AuthResponseMessage, @ApprovalCode, @AddressMatch, @ZipMatch, @CVVResultCode, @SeqNumber_Org)

Set @CCTranID = SCOPE_IDENTITY()

/*
EDK 1/6/14 - Below code was added to update TranState column to support new credit card reports based on EPayment database and is not used for any other purpose.
Update TranState column within the current transaction (inserted above) and parent transaction (if parent seq number @SeqNumber_Org is present)
Various tran types and related tran state codes:
[TranState] = 'O' -> 'AUTH'
[TranState] = 'C' -> 'AUTH_CAPTURE', 'CAPTURE', 'REF', 'REF_BY_SEQ'
[TranState] = 'V' -> 'REVERSAL', 'VOID' (with original parent record also updated to 'V' - 'AUTH', 'AUTH_CAPTURE', 'CAPTURE', 'REF', 'REF_BY_SEQ')

If duplicate subsequent transaction (REVERSAL, VOID, or CAPTURE) is proccessed then do not set it's TranState column enabling reports to ignore duplicates
*/

--Exit here if @TranResult exists and is not 0
IF Len(IsNull(@TranResult,'')) > 0 and IsNull(@TranResult,'') Not In ('0','002') RETURN

--AUTH is set to 'O' and can be updated later to 'V' if voided or reversed
IF @TranType = 'AUTH'
BEGIN
	UPDATE	[CC_TRANS]
	SET		[TranState] = 'O'
	WHERE	CCTranID = @CCTranID
	RETURN
END
--CAPTURE is set to 'C' if no other CAPTURE record exists with the same parent seq number (@SeqNumber_Org)
--CAPTURE is only done against AUTH parent record which is set to 'O' and does not need to be updated
--CAPTURE is set to 'C' but can be updated later to 'V' if void/reversal transaction is issued
IF @TranType = 'CAPTURE'
BEGIN
	IF ((select COUNT(*) from CC_TRANS where SeqNumber_Org = @SeqNumber_Org and TranType = 'CAPTURE' and IsNull(TranResult,'') in ('', '0')) = 1)
	BEGIN
		UPDATE	[CC_TRANS]
		SET		[TranState] = 'C'
		WHERE	CCTranID = @CCTranID
	END
	RETURN
END
--AUTH_CAPTURE, REF, and REF_BY_SEQ tran types are set to 'C' but can be updated later to 'V' if void transaction is issued
IF @TranType = 'AUTH_CAPTURE' or @TranType = 'REF' or @TranType = 'REF_BY_SEQ'
BEGIN
	UPDATE	[CC_TRANS]
	SET		[TranState] = 'C'
	WHERE	CCTranID = @CCTranID
	RETURN
END
--VOID/REVERSAL is set to 'V' if no other VOID/REVERSAL record exists with the same parent seq number (@SeqNumber_Org)
--Parent record is also updated to 'V'
IF @TranType = 'VOID' or @TranType = 'REVERSAL'
BEGIN
	IF ((select COUNT(*) from CC_TRANS where SeqNumber_Org = @SeqNumber_Org and TranType in ('VOID','REVERSAL') and IsNull(TranResult,'') in ('', '0')) = 1)
	BEGIN
		UPDATE	[CC_TRANS]
		SET		[TranState] = 'V'
		WHERE	CCTranID = @CCTranID
	END
	--EDK 2/24/14 MOVED BELOW LOGIC TO [updateCCTran] prior to going live with ePay V2
	--update parent record
	--UPDATE	[CC_TRANS]
	--SET		[TranState] = 'V'
	--WHERE	SeqNumber = @SeqNumber_Org and
	--		TranResult in ('0','002') and --only update valid parent record
	--		TranType <> 'LOOKUP_BY_SEQ' --legacy tran type
	RETURN
END

