USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[delVaultValues]    Script Date: 3/23/2021 5:05:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER         proc [dbo].[delVaultValues]
@UserLogin varchar(50), 
@UserName varchar(50),
@VaultID int out
as

declare @User_id int, @err int, @rows int
set @err = 0
select @User_id = [USER_ID] from [user] where USER_LOGIN = @UserLogin

--DELETE 	[VAULT]
--WHERE 	[VAULT_ID] = @VaultID

UPDATE	[VAULT]
SET 	[DELETED] = 'Y', 
	[DELETED_TS] = GetDate(), 
	[DELETED_USER_ID] = @User_id, 
	[DELETED_USER_NAME] = @UserName
WHERE 	[VAULT_ID] = @VaultID and
	[DELETED] = 'N'

select @err = @@ERROR, @rows = @@ROWCOUNT

IF @err <> 0 or @rows = 0 Set @VaultID = -1






