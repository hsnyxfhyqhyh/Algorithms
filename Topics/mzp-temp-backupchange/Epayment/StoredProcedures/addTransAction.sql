USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[addTransAction]    Script Date: 3/23/2021 5:02:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO









ALTER         proc [dbo].[addTransAction]
@UserLogin varchar(50),
@UserName varchar(50),
@TranType varchar(50),
@MerchantID varchar(25) = null,
@PayType varchar(25) = null,
@Amount money = 0,
@Comment varchar(500) = null,
@TranID int out
as
--declare @User_id int
--select @User_id = [USER_ID] from [user] where USER_LOGIN = @UserLogin


INSERT INTO [TRANS_ACTIONS]
( [MERCHANT_ID],  [USER_LOGIN], [USER_NAME],  [TRAN_TYPE], [PAY_TYPE], [AMOUNT], [COMMENT])
VALUES
(
@MerchantID,
@UserLogin,
@UserName,
@TranType,
@PayType,
@Amount,
@Comment)

Set @TranID = SCOPE_IDENTITY()










