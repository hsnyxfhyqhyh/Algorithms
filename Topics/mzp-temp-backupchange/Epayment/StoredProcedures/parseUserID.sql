USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[parseUserID]    Script Date: 3/23/2021 5:09:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER proc [dbo].[parseUserID] 
@UserName varchar(50),
@UserID varchar(50) out,
@LocationCode varchar(10) out,
@MerchantCode varchar(10) out
as

--set @UserName = 'JSMITH@777-RS'

Declare @first_token_pos int, @second_token_pos int, @str_len int
Set @first_token_pos = CHARINDEX('@', @UserName, 1)
Set @second_token_pos = CHARINDEX('-', @UserName, @first_token_pos)
Set @str_len = Len(@UserName)
if @first_token_pos = 0 set @first_token_pos = @str_len + 1
if @second_token_pos = 0 set @second_token_pos = @str_len + 1

--select @first_token_pos, @second_token_pos, @str_len

Set @UserID = Left(@UserName, @first_token_pos - 1)
If @first_token_pos < @str_len Set @LocationCode = Substring(@UserName, @first_token_pos + 1, @second_token_pos - @first_token_pos - 1)
Else Set @LocationCode = ''
If @second_token_pos < @str_len Set @MerchantCode = Substring(@UserName, @second_token_pos + 1, @str_len - @second_token_pos)
Else Set @MerchantCode = ''

--select @UserID, @LocationCode, @MerchantCode



