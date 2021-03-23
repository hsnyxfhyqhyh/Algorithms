USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[getCyberSettings]    Script Date: 3/23/2021 5:16:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER            proc [dbo].[getCyberSettings]
@UserLogin varchar(50),
--out
@UserName varchar(50) out,
@Location_Code varchar(10) out,
@Merchant_Code varchar(10) out,
@CyberIP varchar(25) out,
@CyberPort varchar(25) out,
@MID varchar(25) out,
@EComm_type char(1) out,
@Card_Present_Flag char(1) out, 
@Terminal_Capability char(1) out, 
@Terminal_Type char(1) out, 
@Pos_Entry_Mode char(1) out, 
@Customer_Present_Flag char(1) out,
@Pan_Readable char(1) out,
@IsValid  int = 0 out,
@IsMIDRCActive char(1) = 'N' out,
@TranDupInterval int = 0 out
as

--parse @UserName into user id, location code, and merchant code
DECLARE @UserID varchar(50), @LocationCode varchar(10), @MerchantCode varchar(10), @TranID int, @Msg varchar(500)
EXEC [parseUserID] @UserName, @UserID OUTPUT , @LocationCode OUTPUT , @MerchantCode OUTPUT 
select @TranID = 0

--temp logic to override AR merchant assignment for the MzP application
if @UserLogin = 'MZP_USER' and Upper(Ltrim(Rtrim(@UserID))) = 'CYBER' and @LocationCode = '013' set @LocationCode = 'GENAR'

IF Len(IsNull(@LocationCode,'')) > 0 and Len(IsNull(@MerchantCode,'')) > 0
BEGIN
	SELECT  @Location_Code = [LOCATION_CODE],
		@Merchant_Code = [MERCHANT_CODE],
		@CyberIP = [CYBER_IP], 
		@CyberPort = [CYBER_PORT], 
		@MID = [CYBER_MID], 
		@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''),
		@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
		@EComm_type = [CYBER_ECOMM], 
		@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
		@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
		@Terminal_Type = [CYBER_TERMINAL_TYPE], 
		@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
		@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
		@Pan_Readable = [PAN_READABLE] 
	FROM 	[CYBER] c, [USER] u
	WHERE	u.[USER_ID] = c.[USER_ID] and
		u.USER_LOGIN = @UserLogin and
		c.LOCATION_CODE = @LocationCode and
		c.MERCHANT_CODE = @MerchantCode
	set @IsValid = @@ROWCOUNT
END
ELSE IF Len(IsNull(@LocationCode,'')) > 0 and Len(IsNull(@MerchantCode,'')) = 0
BEGIN
	--get default merchant per user and location
	SELECT  @Location_Code = [LOCATION_CODE],
		@Merchant_Code = [MERCHANT_CODE],
		@CyberIP = [CYBER_IP], 
		@CyberPort = [CYBER_PORT], 
		@MID = [CYBER_MID] ,
		@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''),
		@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
		@EComm_type = [CYBER_ECOMM], 
		@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
		@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
		@Terminal_Type = [CYBER_TERMINAL_TYPE], 
		@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
		@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
		@Pan_Readable = [PAN_READABLE] 
	FROM 	[CYBER] c, [USER] u
	WHERE	u.[USER_ID] = c.[USER_ID] and
		u.USER_LOGIN = @UserLogin and
		c.LOCATION_CODE = @LocationCode and
		c.CYBER_ID = (	select 	min(CYBER_ID)
				from	[CYBER], [USER]
				where	[USER].[USER_ID] = [CYBER].[USER_ID] and
					[USER].[USER_LOGIN] = @UserLogin and
					[CYBER].[LOCATION_CODE] = @LocationCode and
					[CYBER].[MERCHANT_DEFAULT] = 'Y'
				)

	set @IsValid = @@ROWCOUNT

	--no default merchant found per user and location, locate non-default first merchant per user and location
	If @IsValid = 0
	Begin
		SELECT  @Location_Code = [LOCATION_CODE],
			@Merchant_Code = [MERCHANT_CODE],
			@CyberIP = [CYBER_IP], 
			@CyberPort = [CYBER_PORT], 
			@MID = [CYBER_MID] ,
			@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''),
			@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
			@EComm_type = [CYBER_ECOMM], 
			@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
			@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
			@Terminal_Type = [CYBER_TERMINAL_TYPE], 
			@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
			@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
			@Pan_Readable = [PAN_READABLE] 
		FROM 	[CYBER] c, [USER] u
		WHERE	u.[USER_ID] = c.[USER_ID] and
			u.USER_LOGIN = @UserLogin and
			c.LOCATION_CODE = @LocationCode and
			c.CYBER_ID = (	select 	min(CYBER_ID)
					from	[CYBER], [USER]
					where	[USER].[USER_ID] = [CYBER].[USER_ID] and
						[USER].[USER_LOGIN] = @UserLogin and
						[CYBER].[LOCATION_CODE] = @LocationCode
					)
		SET @IsValid = @@ROWCOUNT
	End

	--no merchant found per user and location, locate Default merchant per user only
	If @IsValid = 0
	BEGIN
		SELECT  @Location_Code = [LOCATION_CODE],
			@Merchant_Code = [MERCHANT_CODE],
			@CyberIP = [CYBER_IP], 
			@CyberPort = [CYBER_PORT], 
			@MID = [CYBER_MID] ,
			@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''),
			@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0), 
			@EComm_type = [CYBER_ECOMM], 
			@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
			@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
			@Terminal_Type = [CYBER_TERMINAL_TYPE], 
			@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
			@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
			@Pan_Readable = [PAN_READABLE] 
		FROM 	[CYBER] c, [USER] u
		WHERE	u.[USER_ID] = c.[USER_ID] and
			u.USER_LOGIN = @UserLogin and
			c.CYBER_ID = (	select 	min(CYBER_ID)
					from	[CYBER], [USER]
					where	[USER].[USER_ID] = [CYBER].[USER_ID] and
						[USER].[USER_LOGIN] = @UserLogin and
						[CYBER].[MERCHANT_DEFAULT] = 'Y'
					)
		SET @IsValid = @@ROWCOUNT
	
		If @IsValid > 0
		Begin
			set @Msg = 'CLIENT APP PROVIDED LOCATION CODE OF ' + @LocationCode + ' BUT NO MERCHANT FOUND IN CYBER FOR THIS USER_LOGIN. FIRST DEFAULT TABLE ENTRY SELECTED FROM CYBER FOR THIS USER_LOGIN - '
			EXEC addTransAction @UserLogin  = @UserLogin, @UserName = @UserName, @TranType = 'CYBER-WARNING', @TranID = @TranID,
				@Comment  = @Msg
		End
	END

	--no default merchant found per user, locate first merchant per user only
	If @IsValid = 0
	BEGIN
		SELECT  @Location_Code = [LOCATION_CODE],
			@Merchant_Code = [MERCHANT_CODE],
			@CyberIP = [CYBER_IP], 
			@CyberPort = [CYBER_PORT], 
			@MID = [CYBER_MID] ,
			@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''), 
			@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
			@EComm_type = [CYBER_ECOMM], 
			@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
			@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
			@Terminal_Type = [CYBER_TERMINAL_TYPE], 
			@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
			@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
			@Pan_Readable = [PAN_READABLE] 
		FROM 	[CYBER] c, [USER] u
		WHERE	u.[USER_ID] = c.[USER_ID] and
			u.USER_LOGIN = @UserLogin and
			c.CYBER_ID = (	select 	min(CYBER_ID)
					from	[CYBER], [USER]
					where	[USER].[USER_ID] = [CYBER].[USER_ID] and
						[USER].[USER_LOGIN] = @UserLogin
					)
		SET @IsValid = @@ROWCOUNT
	
		If @IsValid > 0
		Begin
			set @Msg = 'CLIENT APP PROVIDED LOCATION CODE OF ' + @LocationCode + ' BUT NO MERCHANT FOUND IN CYBER FOR THIS USER_LOGIN. FIRST TABLE ENTRY SELECTED FROM CYBER FOR THIS USER_LOGIN - '
			EXEC addTransAction @UserLogin  = @UserLogin, @UserName = @UserName, @TranType = 'CYBER-WARNING', @TranID = @TranID,
				@Comment  = @Msg
		End
	END
END
ELSE
BEGIN
	SELECT  @Location_Code = [LOCATION_CODE],
		@Merchant_Code = [MERCHANT_CODE],
		@CyberIP = [CYBER_IP], 
		@CyberPort = [CYBER_PORT], 
		@MID = [CYBER_MID] ,
		@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''), 
		@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
		@EComm_type = [CYBER_ECOMM], 
		@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
		@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
		@Terminal_Type = [CYBER_TERMINAL_TYPE], 
		@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
		@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
		@Pan_Readable = [PAN_READABLE] 
	FROM 	[CYBER] c, [USER] u
	WHERE	u.[USER_ID] = c.[USER_ID] and
		u.USER_LOGIN = @UserLogin  and
		c.CYBER_ID = (	select 	min(CYBER_ID)
				from	[CYBER], [USER]
				where	[USER].[USER_ID] = [CYBER].[USER_ID] and
					[USER].[USER_LOGIN] = @UserLogin and
					[CYBER].[MERCHANT_DEFAULT] = 'Y'
				)
	SET @IsValid = @@ROWCOUNT
	If @IsValid > 0
	Begin
		set @Msg = 'CLIENT APP DID NOT PROVIDE LOCATION CODE. DEFAULT ENTRY SELECTED FROM CYBER FOR THIS USER_LOGIN.'
		EXEC addTransAction @UserLogin  = @UserLogin, @UserName = @UserName, @TranType = 'CYBER-WARNING', @TranID = @TranID,
			@Comment  = @Msg
	End

	If @IsValid = 0
	BEGIN
		SELECT  @Location_Code = [LOCATION_CODE],
			@Merchant_Code = [MERCHANT_CODE],
			@CyberIP = [CYBER_IP], 
			@CyberPort = [CYBER_PORT], 
			@MID = [CYBER_MID] ,
			@IsMIDRCActive = ISNULL([MERCHANT_RC_FLAG],''),
			@TranDupInterval = ISNULL(TRAN_DUPS_INTERVAL,0),
			@EComm_type = [CYBER_ECOMM], 
			@Card_Present_Flag = [CYBER_CARD_PRESENT_FLAG], 
			@Terminal_Capability = [CYBER_TERMINAL_CAPABILITY], 
			@Terminal_Type = [CYBER_TERMINAL_TYPE], 
			@Pos_Entry_Mode = [CYBER_POS_ENTRY_MODE], 
			@Customer_Present_Flag = [CYBER_CUSTOMER_PRESENT_FLAG],
			@Pan_Readable = [PAN_READABLE] 
		FROM 	[CYBER] c, [USER] u
		WHERE	u.[USER_ID] = c.[USER_ID] and
			u.USER_LOGIN = @UserLogin  and
			c.CYBER_ID = (	select 	min(CYBER_ID)
					from	[CYBER], [USER]
					where	[USER].[USER_ID] = [CYBER].[USER_ID] and
						[USER].[USER_LOGIN] = @UserLogin 
					)
		SET @IsValid = @@ROWCOUNT
	
		If @IsValid > 0
		Begin
			set @Msg = 'CLIENT APP DID NOT PROVIDE LOCATION CODE. FIRST TABLE ENTRY SELECTED FROM CYBER FOR THIS USER_LOGIN.'
			EXEC addTransAction @UserLogin  = @UserLogin, @UserName = @UserName, @TranType = 'CYBER-WARNING', @TranID = @TranID,
				@Comment  = @Msg
		End
	END
END

If @IsValid <= 0
Begin
	set @Msg = 'UNABLE TO LOCATE MERCHANT INFO FROM CYBER TABLE FOR THIS USER_LOGIN.'
	EXEC addTransAction @UserLogin  = @UserLogin, @UserName = @UserName, @TranType = 'CYBER-ERROR', @TranID = @TranID,
		@Comment  = @Msg
End














