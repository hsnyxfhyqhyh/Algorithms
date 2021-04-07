USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_AddMerchant]    Script Date: 4/7/2021 10:05:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ccTranRC_AddMerchant]
@COMPANY varchar(50), --MA/SJ/SP/IG
@APP_NAME varchar(50), --POS/MZP, etc.
@USER_LOGIN varchar(50), --POS_USER/MZP_USER, etc.
@LOCATION_CODE varchar(10), --008,050, etc.
@LOCATION_NAME varchar(50), --WILMINGTON, CENTER CITY, etc.
@MERCHANT_ID varchar(25), --12 digits
@MERCHANT_TYPE varchar(50), --RETAIL/MOTO/ECOMM/QUASICASH/EMERGINGMARKET
@MERCHANT_CODE varchar(50), --8675,6300,6051, etc
@SETTLE_TIME varchar(50), --10pm, 1am
@MAI_CODE varchar(50), --AAA MAT, AAA MEC
@NASHVILLE_MID varchar(50) = '', --optional value
@NASHVILLE_TID varchar(50) --7 digits
as
declare @user_id int, @merch_code varchar(10), @merch_name varchar(50), @merch_ecomm char(1), @err int
set @err = 0

if @COMPANY not in ('MA','SJ','SP','IG')
begin
	print '@COMPANY does not match available values - MA/SJ/SP/IG'
	return
end
if not exists (select * from USER_APPS where APPS_NAME = @APP_NAME)
begin
	print '@APP_NAME does not match available values in the [USER_APPS] table'
	return
end
select @user_id = [USER_ID] from [USER] where USER_LOGIN = @USER_LOGIN
if ISNULL(@user_id,0) <= 0
begin
	print 'Unable to locate user record in the [USER] table based on the @USER_LOGIN'
	return
end
if LEN(@LOCATION_CODE) <=0 
begin
	print '@LOCATION_CODE is required'
	return
end
if LEN(@LOCATION_NAME) <=0 
begin
	print '@LOCATION_NAME is required'
	return
end
if LEN(@MERCHANT_ID) <> 12
begin
	print '@MERCHANT_ID must be 12 digits long'
	return
end
if @MERCHANT_TYPE not in ('RETAIL','MOTO','ECOMM','QUASICASH','EMERGINGMARKET')
begin
	print '@MERCHANT_TYPE does not match available values - RETAIL/MOTO/ECOMM/QUASICASH/EMERGINGMARKET'
	return
end
if LEN(@MERCHANT_CODE) <=0 
begin
	print '@MERCHANT_CODE is required'
	return
end
if LEN(@SETTLE_TIME) <=0 
begin
	print '@SETTLE_TIME is required'
	return
end
if @MAI_CODE not in ('AAA MAT','AAA MEC')
begin
	print '@MAI_CODE does not match available values - AAA MAT/AAA MEC'
	return
end
if LEN(@NASHVILLE_TID) <=0 
begin
	print '@NASHVILLE_TID is required'
	return
end

select	@merch_code =	CASE @MERCHANT_TYPE
						WHEN 'RETAIL' THEN 'RS'
						WHEN 'EMERGINGMARKET' THEN 'IN'
						WHEN 'QUASICASH' THEN 'CA'
						WHEN 'MOTO' THEN 'RS'
						WHEN 'ECOMM' THEN 'RS'
						ELSE 'RS'
						END,
		@merch_name =	CASE @MERCHANT_TYPE
						WHEN 'RETAIL' THEN 'RETAIL'
						WHEN 'EMERGINGMARKET' THEN 'INSURANCE'
						WHEN 'QUASICASH' THEN 'CASH ADVANCE'
						WHEN 'MOTO' THEN 'RETAIL'
						WHEN 'ECOMM' THEN 'RETAIL'
						ELSE 'RETAIL'
						END,
		@merch_ecomm =	CASE @MERCHANT_TYPE
						WHEN 'ECOMM' THEN 'Y'
						ELSE 'N'
						END

BEGIN TRAN	
						
INSERT INTO [dbo].[CYBER]
           ([USER_ID]
           ,[LOCATION_CODE]
           ,[LOCATION_NAME]
           ,[MERCHANT_CODE]
           ,[MERCHANT_NAME]
           ,[MERCHANT_DEFAULT]
           ,[CYBER_IP]
           ,[CYBER_PORT]
           ,[CYBER_MID]
           ,[CYBER_ECOMM]
           ,[CYBER_CARD_PRESENT_FLAG]
           ,[CYBER_TERMINAL_CAPABILITY]
           ,[CYBER_TERMINAL_TYPE]
           ,[CYBER_POS_ENTRY_MODE]
           ,[CYBER_CUSTOMER_PRESENT_FLAG]
           ,[PAN_READABLE]
           ,[TRAN_DUPS_INTERVAL]
           ,[MERCHANT_RC_FLAG]
           ,[MERCHANT_RC_ACTIVE_TS])
     VALUES
           (@user_id
           ,@LOCATION_CODE
           ,@LOCATION_NAME
           ,@merch_code
           ,@merch_name
           ,'N'
           ,0
           ,0
           ,@MERCHANT_ID
           ,@merch_ecomm
           ,'0'
           ,'0'
           ,'0'
           ,'0'
           ,'0'
           ,'N'
           ,0
           ,null
           ,null)
set @err = @@ERROR
if @err = 0
INSERT INTO [dbo].[aaa_merchants]
       ([MerchantName]
       ,[MerchantID]
       ,[Company]
       ,[MerchantType]
       ,[SettlementTime]
       ,[MAICode]
       ,[MCC]
       ,[NashvilleMID]
       ,[NashvilleTID]
       ,[RCGoLiveDate]
       ,[DisabledByPNC]
       ,[RCActive])
 VALUES
       (UPPER(@APP_NAME + ' - ' + @LOCATION_NAME + ' - ' + @merch_name + ' - ' + @LOCATION_CODE)
       ,@MERCHANT_ID
       ,@COMPANY
       ,@MERCHANT_TYPE
       ,@SETTLE_TIME
       ,@MAI_CODE
       ,@MERCHANT_CODE
       ,@NASHVILLE_MID
       ,@NASHVILLE_TID
       ,GETDATE()
       ,null
       ,null)
set @err = @err + @@ERROR	  
	  
exec [usp_ccTranRC_SwitchMerchantBatch] 'N'
set @err = @err + @@ERROR

if @err = 0 
begin
	COMMIT
	print 'success'
end
else 
begin
	ROLLBACK
	print 'error'
end