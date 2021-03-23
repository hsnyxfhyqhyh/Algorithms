USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[getVaultValues]    Script Date: 3/23/2021 5:08:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER               proc [dbo].[getVaultValues]
@VaultID int out,
@UserLogin varchar(50),
@UserName varchar(50),
@Vault1 varbinary(500) = null out,
@Vault2 varbinary(500) = null out,
@Vault3 varbinary(500) = null out,
@Vault4 varbinary(500) = null out,
@Vault5 varbinary(500) = null out,
@Vault6 varbinary(500) = null out,
@Vault7 varbinary(500) = null out,
@Vault8 varbinary(500) = null out,
@Vault9 varbinary(500) = null out,
@Vault10 varbinary(500) = null out,
@ContainerName varchar(50) = null out,
@Lookup char(1) = 'Y',
@Last4 varchar(4) = '1234' out
as

declare @User_id int, @rowcount int
select @User_id = [USER_ID] from [user] where USER_LOGIN = @UserLogin

SELECT 
	@Vault1 = VAULT1,
	@Vault2 = VAULT2,
	@Vault3 = VAULT3,
	@Vault4 = VAULT4,
	@Vault5 = VAULT5,
	@Vault6 = VAULT6,
	@Vault7 = VAULT7,
	@Vault8 = VAULT8,
	@Vault9 = VAULT9,
	@Vault10 = VAULT10,
	@ContainerName = CONTAINER_NAME,
	@Last4 = Right(LTrim(RTrim(TOKEN)), 4)
FROM  	[VAULT]
WHERE 	[VAULT_ID] = @VaultID and
	DELETED = 'N'
	
set @rowcount = @@ROWCOUNT

IF @rowcount > 0
INSERT INTO [VAULT_ACCESS]([VAULT_ID], [VAULT_ACCESS_TS], [LOOKUP], [USER_ID], [USER_NAME])
VALUES(@VaultID, GetDate(), @Lookup, @User_id, @UserName)
ELSE Set @VaultID = -1

