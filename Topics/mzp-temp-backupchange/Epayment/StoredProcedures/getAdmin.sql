USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[getAdmin]    Script Date: 3/23/2021 5:06:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER     proc [dbo].[getAdmin]
@UserLogin varchar(50),
@AdminName varchar(50),
@IsValid  int out
as
/*
return 1 to allow, 0 to restrict
*/

--parse @UserName into user id, location code, and merchant code
DECLARE @UserID varchar(50), @LocationCode varchar(10), @MerchantCode varchar(10)
EXEC [parseUserID] @AdminName, @UserID OUTPUT , @LocationCode OUTPUT , @MerchantCode OUTPUT 

select 	@IsValid = Count(*)
from 	[user] u, [admin] a
where 	u.[USER_ID] = a.[USER_ID] and
	u.user_login = @UserLogin and
	a.admin_user_name = @UserID and
	u.active = 'Y' and
	a.active = 'Y'



