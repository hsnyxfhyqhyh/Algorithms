
USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[ccTranRC]    Script Date: 3/23/2021 8:13:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER           proc [dbo].[ccTranRC] 
@ClientID varchar(50),
@ClientPwd varbinary(50),
@ClientUserID varchar(50),
@TranType varchar(50),
--
@CustomerID varchar(50),
@ProductDesc varchar(50),
@OrderID varchar(50),
@Amount varchar(20),
@CustomerAddress varchar(30),
@CustomerZip varchar(9),
@CustomerName varchar(26),
@SaveCC char(1),
@EpaySrvName varchar(25) = '',
--input-out
@CCNumber varbinary(500) = null out,
@CCExpiration varbinary(500) = null out,
@CCType varbinary(500) = null out,
@CCLast4 varchar(4) = '' out,
@CCExpText varchar(4) = '' out,
@CCTypeText varchar(4) = '' out,
@CCValid bit = 0, 
@ContainerName varchar(50) = '' out,
@CardPresentFlag char(1) = '' out,
@TerminalCapability char(1) = '' out,
@TerminalType char(1) = '' out,
@PosEntryMode char(1) = '' out,
@CustomerPresentFlag char(1) = '' out,
@SeqNumber varchar(15) = '',
@TokenNumber int = 0 out, --varchar(25)
@BypassValidation varchar(10) = 'False',
--out
@TranResult varchar(25) = '' out,
@ReturnMessage varchar(255) = '' out,
@CCTranID int = 0 out,
@AuditTranID int = 0 out,
@CyberIP varchar(25) = '' out,
@CyberPort varchar(25) = '' out,
@MID varchar(25) = '' out,
@EcommType char(1) = '' out,
@PANReadable char(1) = '' out,
@Admin int = 0 out,
@TranTypeCode varchar(10) = '' out,
@PayProcConnect int = 0 out,
@CCInfoUpdated int = 0 out,
@PayGateToUse varchar(25) = 'CPM' out
as

/*
CHECK THE FOLLOWING SP's FOR PWD ENCRYPTION
addUser - done
getUser - uncomment when WSSS supports password encryption
getUserInfo - done
getUserInfoRecSet - done
updateUser - done
validateUser - done
*/

set nocount on

--DECLARATION START
DECLARE @IsValid int
DECLARE @Privilege varchar(50); Set @Privilege = @TranType
DECLARE @PayType varchar(25); Set @PayType = 'CC'
DECLARE @Amount_Nbr money; If IsNumeric(@Amount) = 1 Set @Amount_Nbr = Cast(@Amount as money) Else Set @Amount_Nbr = 0
DECLARE @Comment varchar(500)
DECLARE @pay_type varchar(10); select @pay_type = Ltrim(Rtrim(privilege_code)) from security_privilege where privilege_name = @TranType; set @TranTypeCode = @pay_type
DECLARE @card_present_flag char(1) 
DECLARE @terminal_capability char(1)
DECLARE @terminal_type char(1)
DECLARE @pos_entry_mode char(1)
DECLARE @customer_present_flag char(1)
DECLARE @location_code varchar(10)
DECLARE @merchant_code varchar(10)
DECLARE @CCNumber_str varchar(500)
DECLARE @CCExpiration_str varchar(500)
DECLARE @CCType_str varchar(500)
DECLARE @IsMIDRCActive char(1)
DECLARE @TranDupsInterval int
/*
Set	@pay_type = 	Case @TranType
			When 'AUTH_CAPTURE' Then 'C'
			When 'REF' Then 'R'
			When 'AUTH' Then 'A'
			When 'CAPTURE' Then 'P'
			When 'REVERSAL' Then 'RV'
			When 'REF_BY_SEQ' Then 'Q'
			When 'LOOKUP_BY_SEQ' Then 'L'
			When 'LOOKUP_BY_TOKEN' Then 'T'
			When 'SAVE_CC' Then 'S'
			When 'DELETE_CC' Then 'D'
			When 'VOID' Then 'VD'
		    	End
*/
--DECLARATION END

--store encrypted binary values into strings to be used with one purpose only - validation of required fields
Select @CCNumber_str = CAST(@CCNumber as varchar(500)), @CCExpiration_str = CAST(@CCExpiration as varchar(500)), @CCType_str = CAST(@CCType as varchar(500))
--get user's admin status
EXEC getAdmin @ClientID, @ClientUserID, @Admin OUTPUT 
	
BEGIN
	--AUTHENTICATION START
	Set @IsValid = 0
	EXEC getUser @ClientID, @ClientPwd, @IsValid OUTPUT 
	IF @IsValid <> 1
	Begin
		Set @TranResult = '-1000'
		Set @ReturnMessage = 'INVALID USER NAME OR PASSWORD'
		EXEC addTransAction @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, 
					@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
		RETURN
	End
	--AUTHENTICATION END
	--AUTHORIZATION START
	Set @IsValid = 0
	EXEC getUserSettings @ClientID, @Privilege, @IsValid OUTPUT 
	IF @IsValid <> 1
	Begin
		Set @TranResult = '-1001'
		Set @ReturnMessage = 'USER NOT AUTHORIZED'
		EXEC addTransAction @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, 
					@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
		RETURN
	End
	--AUTHORIZATION END
	--GET CYBER CONFIG START
	Set @IsValid = 0
	EXEC getCyberSettings 	@ClientID, @ClientUserID, @location_code OUTPUT, @merchant_code OUTPUT,
				@CyberIP OUTPUT , @CyberPort OUTPUT , @MID OUTPUT , 
				@EcommType OUTPUT , @card_present_flag OUTPUT , @terminal_capability OUTPUT , 
				@terminal_type OUTPUT , @pos_entry_mode OUTPUT , @customer_present_flag OUTPUT, 
				@PANReadable OUTPUT, @IsValid OUTPUT, @IsMIDRCActive OUTPUT, @TranDupsInterval OUTPUT
	IF @IsValid <> 1
	Begin
		Set @TranResult = '-1002'
		Set @ReturnMessage = 'UNABLE TO RETRIEVE CYBER CONFIG SETTINGS'
		EXEC addTransAction @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, 
					@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
		RETURN
	End
	Else
	Begin
		If Len(Ltrim(Rtrim(@CardPresentFlag))) = 0 Set @CardPresentFlag = @card_present_flag
		If Len(Ltrim(Rtrim(@TerminalCapability))) = 0 Set @TerminalCapability = @terminal_capability
		If Len(Ltrim(Rtrim(@TerminalType))) = 0 Set @TerminalType = @terminal_type
		If Len(Ltrim(Rtrim(@PosEntryMode))) = 0 Set @PosEntryMode = @pos_entry_mode
		If Len(Ltrim(Rtrim(@CustomerPresentFlag))) = 0 Set @CustomerPresentFlag = @customer_present_flag
		--Set Payment Gateway to be used by the client app
		If IsNull(@IsMIDRCActive,'') = 'Y' and Len(Ltrim(Rtrim(@SeqNumber))) < 15 
		Begin
			Set @PayGateToUse = 'RAPIDCONNECT'
			Set @CyberIP = @EpaySrvName
		End
		Else Set @PayGateToUse = 'CPM'
	End
	--GET CYBER CONFIG END
	--VALIDATE CC NUMBER FOR ALL TRANSACTIONS
	If Len(Ltrim(Rtrim(IsNull(@CCNumber_str,'')))) > 0 
	Begin
		--card pre-validated on the app side prior to this sp
		Set @IsValid = @CCValid
		
		IF @IsValid <> 1
		Begin
			Set @TranResult = '-1100'
			Set @ReturnMessage = 'CREDIT CARD NUMBER IS INVALID'
			EXEC addTransAction @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, 
						@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
			RETURN
		End
	End
	--VALIDATE CC NUMBER FOR ALL TRANSACTIONS END
	--GET CC INFO FROM THE VAULT ON THE CLIENT BEHALF START
	IF ((@pay_type = 'C' or @pay_type = 'R' or @pay_type = 'A' or @pay_type = 'S') and @TokenNumber > 0)  -- charge by token, refund by token, auth by token, save by token
	BEGIN
		Declare @Temp_TokenNumber int
		Set @Temp_TokenNumber = @TokenNumber
		--retrieve all the Vault data with container name to be decrypted/re-encrypted on the app side - @CCNumber, @CCExpiration, @CCType
		Begin
			Set	@CCInfoUpdated = 1
			--retrieve Vault values
			EXEC	getVaultValues 	@VaultID = @TokenNumber OUTPUT, @UserLogin  = @ClientID, @UserName = @ClientUserID,
				@Vault1 = @CCNumber OUTPUT , @Vault2 = @CCExpiration OUTPUT , @Vault3 = @CCType OUTPUT, @ContainerName = @ContainerName OUTPUT, @Lookup = 'N'
	
			If @TokenNumber = -1
			Begin
				Set @TranResult = '-1003'
				Set @ReturnMessage = 'UNABLE TO LOCATE CC INFO USING PROVIDED TOKEN - ' + Cast(IsNull(@Temp_TokenNumber, 0) as varchar(25))
				EXEC addTransAction @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, 
						@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
				RETURN
			End
		End
	END
	--GET CC INFO FROM THE VAULT ON THE CLIENT BEHALF END
	
	--GET CC INFO FROM THE CC_TRANS ON THE CLIENT BEHALF TO ISSUE A SUBSEQUENT TRANSACTION START
	IF ((@pay_type = 'P' or @pay_type = 'RV' or @pay_type = 'VD' or @pay_type = 'Q') and IsNull(@IsMIDRCActive,'') = 'Y' and (Len(Ltrim(Rtrim(@SeqNumber))) > 0 and Len(Ltrim(Rtrim(@SeqNumber))) < 15))  -- CAPTURE, REVERSAL, REF_BY_SEQ, VOID with Parent Seq Num present (len <15 to differentiate from CPM seq nbrs) and used by merchants switched to RapidConnect Gateway
	BEGIN
		--retrieve all the CC_TRANS data with pan and container name to be decrypted on the app side
		Begin
			Set	@CCInfoUpdated = 2
			
			--if trying to void transaction which was voided already exit with an error
			IF @pay_type = 'VD'
			Begin
				IF Exists (	select	*
							from	CC_TRANS
							where	SeqNumber = @SeqNumber and
									IsNull(TranState,'') = 'V')
				Begin
					Set @TranResult = '-1500'
					Set @ReturnMessage = 'UNABLE TO VOID TRANSACTION THAT WAS PREVIOUSLY VOIDED - ' + @SeqNumber
					EXEC addTransAction @MerchantID = @MID, @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, @PayType = @PayType,
							@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
					RETURN
				End
			End
			
			--retrieve values	
			select	@CCNumber = PAN, @ContainerName = ContainerName, @CCLast4 = Last4PAN, @CCExpText = CardExpirDate, @CCTypeText = CardType
			from	CC_TRANS
			where	SeqNumber = @SeqNumber and
					--original tran must be succesful and encrypted pan must be present
					((TranResult = '0' and TranType = 'REF') or (TranResult = '0' and TranType <> 'REF' and AuthResponseCode = 'A') or (TranResult = '0' and TranType <> 'REF' and AuthResponseCode = 'T'))  and --(TranResult = '002' and TranType <> 'REF')) --EDK 7/7/14 updated to accomodate POS acceptance of partial authorizations 
					PAN is not null
			If @@ROWCOUNT = 0
			Begin
				--PAN can be Null for CAPTURE or REF_BY_SEQ, try retrieving it from the grand-parent record
				If Exists (select Max(SeqNumber_Org) from CC_TRANS where SeqNumber = @SeqNumber)
				Begin
					--retrieve values	
					select	@CCNumber = PAN, @ContainerName = ContainerName, @CCLast4 = Last4PAN, @CCExpText = CardExpirDate, @CCTypeText = CardType
					from	CC_TRANS
					where	SeqNumber = (select Max(SeqNumber_Org) from CC_TRANS where SeqNumber = @SeqNumber) and
							--original tran must be succesful and encrypted pan must be present
							((TranResult = '0' and TranType = 'REF') or (TranResult = '0' and TranType <> 'REF' and AuthResponseCode = 'A')) and
							PAN is not null 
				End
				--Valid parent record is not available
				If @@ROWCOUNT = 0
				Begin
					Set @TranResult = '-1021'
					Set @ReturnMessage = 'UNABLE TO ISSUE SUBSEQUENT TRANSACTION. UNABLE TO LOCATE VALID ORIGINAL CC INFO BY PARENT SEQUENCE NUMBER - ' + @SeqNumber
					EXEC addTransAction @MerchantID = @MID, @UserLogin  = @ClientID, @UserName = @ClientUserID, @TranType = @TranType, @PayType = @PayType,
							@Comment  = @ReturnMessage, @TranID = @AuditTranID OUTPUT 
					RETURN
				End
			End
		End
	END
	----GET CC INFO FROM THE CC_TRANS ON THE CLIENT BEHALF TO ISSUE A SUBSEQUENT TRANSACTION END
	
	--ADD AUDIT TRANSACTION START
	--EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
	--			@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
	--			@TranID = @AuditTranID OUTPUT 
	--ADD AUDIT TRANSACTION END
	
	--VALIDATE TRANSACTION START
	IF (@pay_type = 'C' or @pay_type = 'R' or @pay_type = 'Q' or @pay_type = 'A' or @pay_type = 'P' or @pay_type = 'RV' or @pay_type = 'VD') -- charge, refund, refund by sequence -- REMOVED @pay_type = 'L' and added stand alone logic below as an elseif condition
	BEGIN
		--ADD AUDIT TRANSACTION START
		IF (@Admin <> 1)
		EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
				@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
				@TranID = @AuditTranID OUTPUT 
		ELSE SET @AuditTranID = 1
		--ADD AUDIT TRANSACTION END
	
		--set to 1 to return/indicate to the app to do the CPM call
		Set @PayProcConnect = 1
		--reset the var
		Set @TranResult = '0'
		--bypass db validation if app has requested it
		IF @BypassValidation = 'False '
		EXEC	validateCCTran 	@Cyber_ip = @CyberIP, @Cyber_port = @CyberPort, @Merch_id = @MID, @Pay_Type = @pay_type, 
					@Cust_Id = @CustomerID, @Prod_Descr = @ProductDesc, @Order_id = @OrderID, 
					@CC_amt = @Amount, @CC_addr = @CustomerAddress, @CC_zip = @CustomerZip, @Cust_name = @CustomerName, 
					@EComm_type = @EcommType, @Card_Present_Flag = @CardPresentFlag, @Terminal_Capability = @TerminalCapability, 
					@Terminal_Type = @TerminalType, @Pos_Entry_Mode = @PosEntryMode, @Customer_Present_Flag = @CustomerPresentFlag, 
					@Seq_num = @SeqNumber, @CC_num = @CCNumber_str, @CC_expir = @CCExpText, @CC_type = @CCType_str,
					@Tran_Result_OUT = @TranResult OUTPUT , @RETURN_CODE_MESSAGE_OUT = @ReturnMessage OUTPUT, @TokenNumber = @TokenNumber
		IF @TranResult <> '0'
		Begin
			--ADD CC TRANSACTION
			EXEC addCCTrans @UserLogin = @ClientID, @UserName = @ClientUserID, @CyberSrv = @CyberIP, @MerchantID = @MID, @TranType = @TranType, 
					@LocationCode = @location_code, @MerchantCode = @merchant_code, @CustomerID = @CustomerID, @ProductDesc = @ProductDesc, 
					@OrderID = @OrderID, @Last4PAN = @CCLast4, @CardExpirDate = @CCExpText, @CardType = @CCTypeText, @Amount = @Amount_Nbr, @CustomerName = @CustomerName, 
					@Street = @CustomerAddress, @Zip = @CustomerZip, @SeqNumber_Org = @SeqNumber, @TokenNumber = @TokenNumber, @TranResult = @TranResult, @ReturnMessage = @ReturnMessage, @CCTranID = @CCTranID OUTPUT 
			IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
			RETURN
		End
		Else
		Begin
			--ADD CC TRANSACTION START
			EXEC addCCTrans @UserLogin = @ClientID, @UserName = @ClientUserID, @CyberSrv = @CyberIP, @MerchantID = @MID, @TranType = @TranType, 
					@LocationCode = @location_code, @MerchantCode = @merchant_code, @CustomerID = @CustomerID, @ProductDesc = @ProductDesc, 
					@OrderID = @OrderID, @Last4PAN = @CCLast4, @CardExpirDate = @CCExpText, @CardType = @CCTypeText, @Amount = @Amount_Nbr, @CustomerName = @CustomerName, 
					@Street = @CustomerAddress, @Zip = @CustomerZip, @SeqNumber_Org = @SeqNumber, @TokenNumber = @TokenNumber, @CCTranID = @CCTranID OUTPUT 
			If @CCTranID > 0
			Begin
				--PERFORM DUPLICATE TRANS CHECK IF MERCHANT IS CONFIGURED
				If @TranDupsInterval > 0
				Begin
					declare @HasDups bit
					--locate cclast4 if payment is being made using token
					if (len(@CCLast4) = 0 and @TokenNumber > 0) select @CCLast4 = Right(token,4) from vault where vault_id = @TokenNumber
					exec dbo.usp_ccTranRC_Dups
						@MID,
						@TranType,
						@CCLast4,
						@Amount_Nbr,
						@CustomerName,
						@CustomerAddress,
						@CustomerID,
						@TranDupsInterval,
						@HasDups out
					If @HasDups = 0	SELECT @TranResult = '0' , @ReturnMessage = 'Success'
					Else 
					Begin
						Set @TranResult = '1917'
						Set @ReturnMessage = 'DUPLICATE TRANSACTION REQUEST DETECTED WITHIN THE LAST ' + Cast(@TranDupsInterval as varchar(10)) + ' MINUTES'
						Update	CC_TRANS
						Set		TranResult = @TranResult, 
								ReturnMessage = @ReturnMessage,
								TranState = Null
						Where	CCTranID = @CCTranID
						IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
						RETURN
					End
				End
				Else SELECT @TranResult = '0' , @ReturnMessage = 'Success'
			End
			Else
			Begin
				Set @TranResult = '-1006'
				Set @ReturnMessage = 'UNABLE TO ADD CC TRANS RECORD'
				IF (@AuditTranID > 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			--ADD CC TRANSACTION END
		End
	END
	--VALIDATE TRANSACTION END
	--ADD NEW CC INFO START
	ELSE IF @pay_type = 'S'
	BEGIN
		--ADD AUDIT TRANSACTION START
		IF (@Admin <> 1)
			EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
								@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
								@TranID = @AuditTranID OUTPUT 
		ELSE SET @AuditTranID = 1
		--ADD AUDIT TRANSACTION END
		If @TokenNumber = 0 -- if > 0 then extraction from the vault was done above and update will be done in update sp
		Begin
			--VALIDATION START
			If Len(IsNull(Ltrim(Rtrim(@CCLast4)), '')) = 0
			Begin
				SELECT @TranResult = '-1110' , @ReturnMessage = 'CYBER INPUT VALIDATION ERROR - CREDIT CARD NUMBER'
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			If Len(IsNull(Ltrim(Rtrim(@CCExpText)), '')) = 0
			Begin
				SELECT @TranResult = '-1110' , @ReturnMessage = 'CYBER INPUT VALIDATION ERROR - CREDIT CARD EXPIRATION'
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			If Len(IsNull(Ltrim(Rtrim(@CCTypeText)), '')) = 0
			Begin
				SELECT @TranResult = '-1110' , @ReturnMessage = 'CYBER INPUT VALIDATION ERROR - CREDIT CARD TYPE'
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			--VALIDATION END
			
			EXEC 	addVaultValues @UserLogin  = @ClientID, @UserName = @ClientUserID, @ContainerName = @ContainerName, @CCLast4 = @CCLast4, 
						@Vault1 = @CCNumber, @Vault2 = @CCExpiration, @Vault3 = @CCType, @VaultID = @TokenNumber OUTPUT 
			If @TokenNumber = -1 
			Begin
				SELECT @TranResult = '-1004' , @ReturnMessage = 'UNABLE TO ADD/UPDATE CREDIT CARD INFO'
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			Else If @TokenNumber = -2 
			Begin
				SELECT @TranResult = '-1010' , @ReturnMessage = 'UNABLE TO UPDATE CREDIT CARD INFO USING PROVIDED TOKEN'
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
				RETURN
			End
			Else 
			Begin
				Set @Comment = 'CC ADDED ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID
				IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = '', @Comment = @Comment
				SELECT @TranResult = '0' , @ReturnMessage = 'Success'
			End
		End
		Else
		Begin
			SELECT @TranResult = '0' , @ReturnMessage = 'Success'
		End
	END
	--ADD NEW CC INFO END
	--LOOKUP BY TOKEN START
	ELSE IF @pay_type = 'T' 
	BEGIN
		Declare @Temp_TokenNumber1 int
		Set @Temp_TokenNumber1 = @TokenNumber
		--ADD AUDIT TRANSACTION START
		IF (@Admin <> 1)
			EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
								@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
								@TranID = @AuditTranID OUTPUT 
		ELSE SET @AuditTranID = 1
		--ADD AUDIT TRANSACTION END
		IF (@PANReadable <> 'Y') or (@Admin <> 1)
		EXEC	getVaultValues @VaultID = @TokenNumber OUTPUT, @UserLogin  = @ClientID, @UserName = @ClientUserID, 
					@Vault1 = @CCNumber OUTPUT , @Vault2 = @CCExpiration OUTPUT , @Vault3 = @CCType OUTPUT, @ContainerName = @ContainerName OUTPUT, @Lookup = 'N'
		ELSE	
		EXEC	getVaultValues @VaultID = @TokenNumber OUTPUT, @UserLogin  = @ClientID, @UserName = @ClientUserID, 
					@Vault1 = @CCNumber OUTPUT , @Vault2 = @CCExpiration OUTPUT , @Vault3 = @CCType OUTPUT, @ContainerName = @ContainerName OUTPUT
		
		If @TokenNumber = -1
		Begin
			Set @TranResult = '-1003'
			Set @ReturnMessage = 'UNABLE TO LOCATE CC INFO USING PROVIDED TOKEN ' + Cast(IsNull(@Temp_TokenNumber1, 0) as varchar(25))
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
			RETURN
		End
		Else
		Begin
			Set @Comment = 'CC LOOKUP BY TOKEN ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID + ' - ' + @PANReadable + Cast(@Admin as varchar(5)) + '-' + Cast(@TokenNumber as varchar(25))
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = '', @Comment = @Comment
			SELECT	@TranResult = '0', @ReturnMessage = 'Success'
		End
	END
	--LOOKUP BY TOKEN END
	--DELETE BY TOKEN START
	ELSE IF @pay_type = 'D' 
	BEGIN
		--ADD AUDIT TRANSACTION START
		EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
							@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
							@TranID = @AuditTranID OUTPUT 
		--ADD AUDIT TRANSACTION END
		EXEC	delVaultValues @UserLogin  = @ClientID, @UserName = @ClientUserID, @VaultID = @TokenNumber OUTPUT
		
		If @TokenNumber = -1 
		Begin
			SELECT @TranResult = '-1005' , @ReturnMessage = 'UNABLE TO LOCATE AND/OR REMOVE CREDIT CARD INFO'
			EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
			RETURN 
		End
		Else 
		Begin
			Set @Comment = 'CC DELETED ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID
			EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = '', @Comment = @Comment
			SELECT @TranResult = '0' , @ReturnMessage = 'Success'
		End
	END
	--DELETE BY TOKEN END
	--MATCH BY SEQ START
	ELSE IF @pay_type = 'M' 
	BEGIN
		IF (@Admin <> 1)
			EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
								@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
								@TranID = @AuditTranID OUTPUT 
		ELSE SET @AuditTranID = 1
		SELECT @CCNumber = PAN, @ContainerName = ContainerName 
		FROM CC_TRANS
		WHERE SeqNumber = @SeqNumber and PAN is not null
		If @@ROWCOUNT = 0
		Begin
			Set @TranResult = '-1009'
			Set @ReturnMessage = 'UNABLE TO LOCATE CC BY SEQUENCE NUMBER'
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = 'E', @Comment = @ReturnMessage
			RETURN
		END
		ELSE
		BEGIN
			Set @Comment = 'CC MATCH BY SEQ ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID + ':' + @SeqNumber
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = '', @Comment = @Comment
			SELECT @TranResult = '0' , @ReturnMessage = 'Success'
		END
	END
	--MATCH BY SEQ END
	--LOOKUP BY SEQ START
	ELSE IF @pay_type = 'L' 
	BEGIN
		IF (@Admin <> 1)
			EXEC addTransAction @MerchantID = @MID, @UserLogin = @ClientID, @UserName = @ClientUserID, 
								@TranType = @TranType, @PayType = @PayType, @Amount = @Amount_Nbr, 
								@TranID = @AuditTranID OUTPUT 
		ELSE SET @AuditTranID = 1
		--retrieve based on the original transaction		
		select	@CCLast4 = Last4PAN, @CCExpText = CardExpirDate, @CCTypeText = CardType
		from	[dbo].[CC_TRANS]
		where	CCTranID = (
							select	MIN(CCTranID)
							from	[dbo].[CC_TRANS]
							where	TranType <> 'LOOKUP_BY_SEQ' and
									SeqNumber = @SeqNumber
							)
		If @@ROWCOUNT = 0
		Begin
			Set @TranResult = '-1020'
			Set @ReturnMessage = 'UNABLE TO LOCATE CC INFO BY SEQUENCE NUMBER'
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = 'E', @Comment = @ReturnMessage
			RETURN
		END
		ELSE
		BEGIN
			Set @Comment = 'CC LOOKUP BY SEQ ' + @ClientID + ':' + @ClientUserID + ':' + @CustomerID + ':' + @SeqNumber
			IF (@Admin <> 1) EXEC updateTransAction @TranID = @AuditTranID, @SeqID = @SeqNumber, @TranStatus = '', @Comment = @Comment
			SELECT @TranResult = '0' , @ReturnMessage = 'Success'
		END
	END
	--LOOKUP BY SEQ END
	--INVALID TRANSACTION
	ELSE
	BEGIN
		SELECT @TranResult = '-1007' , @ReturnMessage = 'UNABLE TO PROCESS CC, INVALID TRANSACTION' + ' - Transaction Type: ' + @TranType + ' - Code: ' + @pay_type + ' ; Check type and code mapping in the security_privilege table!!!'
		EXEC updateTransAction @TranID = @AuditTranID, @SeqID = '', @TranStatus = 'E', @Comment = @ReturnMessage
		RETURN
	END
END








