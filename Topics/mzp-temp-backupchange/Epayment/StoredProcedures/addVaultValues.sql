USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[addVaultValues]    Script Date: 3/23/2021 5:03:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER           proc [dbo].[addVaultValues]
@UserLogin varchar(50),
@UserName varchar(50),
@ContainerName varchar(50),
@CCLast4 varchar(4) = '1234',
@Vault1 varbinary(500) = null,
@Vault2 varbinary(500) = null,
@Vault3 varbinary(500) = null,
@Vault4 varbinary(500) = null,
@Vault5 varbinary(500) = null,
@Vault6 varbinary(500) = null,
@Vault7 varbinary(500) = null,
@Vault8 varbinary(500) = null,
@Vault9 varbinary(500) = null,
@Vault10 varbinary(500)  = null,
@VaultID int = null out
as

declare @User_id int, @err int, @row_cnt int, @token varchar(50)
set @err = 0
select @User_id = [USER_ID] from [user] where USER_LOGIN = @UserLogin

BEGIN TRAN

IF IsNull(@VaultID,0) > 0
Begin

	SELECT	@row_cnt = count(*)
	FROM	[VAULT]
	WHERE 	[VAULT_ID] = @VaultID and
			DELETED = 'N'
	
	if IsNull(@row_cnt,0) > 0
	begin
		UPDATE 	[VAULT]
		SET 	[UPDATED_USER_ID] = @User_id, 
			[UPDATED_USER_NAME] = @UserName,
			[VAULT1] = IsNull(@Vault1,[VAULT1]), 
			[VAULT2] = IsNull(@Vault2,[VAULT2]),  
			[VAULT3] = IsNull(@Vault3,[VAULT3]), 
			[VAULT4] = IsNull(@Vault4,[VAULT4]),  
			[VAULT5] = IsNull(@Vault5,[VAULT5]),  
			[VAULT6] = IsNull(@Vault6,[VAULT6]), 
			[VAULT7] = IsNull(@Vault7,[VAULT7]),  
			[VAULT8] = IsNull(@Vault8,[VAULT8]), 
			[VAULT9] = IsNull(@Vault9,[VAULT9]), 
			[VAULT10] = IsNull(@Vault10,[VAULT10]),
			[CONTAINER_NAME] =  IsNull(@ContainerName,[CONTAINER_NAME]),
			[VAULT_TS] = GetDate(),
			TOKEN = Left(LTRIM(RTRIM(IsNull(TOKEN,''))), 12) + @CCLast4
		WHERE [VAULT_ID] = @VaultID 
		set @err = @@ERROR
	end
	else 
	begin
		set @err = -7777
	end
End
ELSE
Begin
	INSERT INTO [VAULT](
	[USER_ID], [USER_NAME], [VAULT1], [VAULT2], [VAULT3], [VAULT4], [VAULT5], [VAULT6], [VAULT7], [VAULT8], [VAULT9], [VAULT10], [CONTAINER_NAME], [TOKEN])
	VALUES(
	@User_id, @UserName, @Vault1, @Vault2, @Vault3, @Vault4, @Vault5, 
	@Vault6, @Vault7, @Vault8, @Vault9, @Vault10, @ContainerName, '')
	
	set @err = @@ERROR
	
	Set @VaultID = SCOPE_IDENTITY()
	
	If @VaultID > 0 
	Begin
		set @token =	Cast(@VaultID as varchar(25)) + 
						SUBSTRING(
							Cast(RAND( 
									(DATEPART(mm, GETDATE()) * 100000 ) +
       								(DATEPART(ss, GETDATE()) * 1000 ) +
       								(DATEPART(ms, GETDATE()) )
       								) 
							as varchar(50)),
						5,2) + 
						IsNull(@CCLast4, '1234')
	
		UPDATE 	[VAULT]
		SET 	TOKEN = @token
		WHERE 	[VAULT_ID] = @VaultID

		set @err = @err + @@ERROR
		
	End
End



IF @err = 0 COMMIT
ELSE
Begin
	if @err = -7777 set @VaultID = -2 else set @VaultID = -1
	ROLLBACK
End


