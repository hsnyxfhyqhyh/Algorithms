USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[updateCCTran]    Script Date: 3/23/2021 4:29:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER     proc [dbo].[updateCCTran] 
@ClientID varchar(50),
@ClientUserID varchar(50),
@TranType varchar(50),
@CustomerID varchar(50),
@SaveCC char(1),
@SeqNumber varchar(15),
@TokenNumber int = 0 out,
@CCNumber varbinary(500) = null,
@CCExpiration varbinary(500) = null,
@CCType varbinary(500) = null,
@CCLast4 varchar(4) = '', 
@ContainerName varchar(50) = '',
@CCTranID int,
@AuditTranID int,
@TranResult varchar(25) out,
@ReturnMessage varchar(255) out,
@AuthResponseCode varchar(25) = '',
@AuthResponseMessage varchar(255) = '',
@ApprovalCode varchar(25) = '',
@AddressMatch char(1) = '',
@ZipMatch char(1) = '',
@CVVResultCode varchar(4) = ''
as

DECLARE @pay_type varchar(10); select @pay_type = Ltrim(Rtrim(privilege_code)) from security_privilege where privilege_name = @TranType
DECLARE @Comment varchar(500)

If @pay_type = 'S'
Begin
	EXEC 	addVaultValues 	@UserLogin  = @ClientID, @UserName = @ClientUserID, @ContainerName = @ContainerName, @CCLast4 = @CCLast4, 
				@Vault1 = @CCNumber, @Vault2 = @CCExpiration, @Vault3 = @CCType, @VaultID = @TokenNumber OUTPUT 
	If @TokenNumber = -1 
	Begin
		SELECT @TranResult = '-1004' , @ReturnMessage = 'UNABLE TO ADD/UPDATE CREDIT CARD INFO'
		IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
		RETURN
	End
	Else If @TokenNumber = -2 
	Begin
		SELECT @TranResult = '-1010' , @ReturnMessage = 'UNABLE TO UPDATE CREDIT CARD INFO USING PROVIDED TOKEN'
		IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
		RETURN
	End
	Else 
	Begin
		SELECT @TranResult = '0' , @ReturnMessage = 'Success'
		Set 	@Comment = 'UPDATE CC BY ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID
		IF (@AuditTranID > 1) EXEC 	updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = @AuthResponseCode, @Comment = @Comment
	End
	RETURN
End

--ADD TOKEN START - add token if auth = success and token is requested
If (@SaveCC = 'Y') and ( ((@pay_type = 'C' or @pay_type = 'A') and Ltrim(Rtrim(@AuthResponseCode)) = 'A') or (@pay_type = 'R' and @TranResult = 0) ) and @TokenNumber = 0
Begin
	EXEC 	addVaultValues 	@UserLogin  = @ClientID, @UserName = @ClientUserID, @ContainerName = @ContainerName, @CCLast4 = @CCLast4, 
				@Vault1 = @CCNumber, @Vault2 = @CCExpiration, @Vault3 = @CCType, @VaultID = @TokenNumber OUTPUT 
		--not checking return code since this is a secondary transaction and we know that main transaction was processed
End
Else If ( ((@pay_type = 'C' or @pay_type = 'A') and Ltrim(Rtrim(@AuthResponseCode)) = 'A') or (@pay_type = 'R' and @TranResult = 0) ) and @TokenNumber > 0
Begin
	EXEC 	addVaultValues 	@UserLogin  = @ClientID, @UserName = @ClientUserID, @ContainerName = @ContainerName, @CCLast4 = @CCLast4, 
				@Vault1 = @CCNumber, @Vault2 = @CCExpiration, @Vault3 = @CCType, @VaultID = @TokenNumber OUTPUT 
		--not checking return code since this is a secondary transaction and we know that main transaction was processed
End
--ADD TOKEN END
--UPDATE AUDIT TRANSACTION START
Set 	@Comment = 'CC TRANSACTION BY ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID
IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = @AuthResponseCode, @Comment = @Comment
--UPDATE AUDIT TRANSACTION END
--UPDATE CC TRANSACTION START
Update	CC_TRANS
Set	TranResult = @TranResult, 
	ReturnMessage = @ReturnMessage, 
	AuthResponseCode = @AuthResponseCode, 
	AuthResponseMessage = @AuthResponseMessage, 
	ApprovalCode = @ApprovalCode, 
	AddressMatch = @AddressMatch, 
	ZipMatch = @ZipMatch, 
	CVVResultCode = @CVVResultCode, 
	SeqNumber = @SeqNumber,
	Last4PAN = @CCLast4,
	PAN = @CCNumber,
	ContainerName = @ContainerName,
	TranState = Case @TranResult
				When '0' Then TranState
				When '002' Then TranState
				Else Null
				End
Where	CCTranID = @CCTranID
If @@ERROR <> 0 and (@AuditTranID > 1) 
EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = @AuthResponseCode, @Comment = ' - !!!ERROR UPDATING CC_TRANS TABLE!!!'
Else
Begin
	--Parent record is also updated to 'V' if Void/Reversal was successful
	IF (@TranType = 'VOID' or @TranType = 'REVERSAL') and (Ltrim(Rtrim(@TranResult)) = '0' and Ltrim(Rtrim(@AuthResponseCode)) in ('','A'))
	BEGIN
		--update parent record
		UPDATE	[CC_TRANS]
		SET		[TranState] = 'V'
		WHERE	SeqNumber = (select SeqNumber_Org from CC_TRANS where CCTranID = @CCTranID) and
				TranResult in ('0','002') and --only update valid parent record
				TranType <> 'LOOKUP_BY_SEQ' --legacy tran type
	END
End
--UPDATE CC TRANSACTION END









