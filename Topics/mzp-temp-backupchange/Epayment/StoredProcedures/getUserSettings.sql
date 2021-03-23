USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[getUserSettings]    Script Date: 3/23/2021 5:08:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER        proc [dbo].[getUserSettings]
@UserLogin varchar(50),
@Privilege varchar(50),
@IsValid  int out
as
/*get user rights based on the privilege accessed

return 1 to allow access, 0 to restrict
*/
select 	@IsValid = Count(*)
from	[user] u, security_group g, security_privilege p, security_rights r, security_role o
where	g.Group_ID = r.Group_ID and
	p.Privilege_ID = r.Privilege_ID and
	u.[User_ID] = o.[User_ID] and
	g.Group_ID = o.Group_ID and
	r.active = 'Y' and
	u.active = 'Y' and
	g.active = 'Y' and
	p.active = 'Y' and
	o.active = 'Y' and
	p.privilege_name = @Privilege and
	u.user_login = @UserLogin and
	(dateadd(mm, 
		(select last_logon_range_mm from [user] u, [user_apps] ua where u.APPS_ID = ua.APPS_ID and u.user_login = @UserLogin), 
		u.last_logon_date) > getdate()) and
	(dateadd(mm, 
		(select password_set_range_mm from [user] u, [user_apps] ua where u.APPS_ID = ua.APPS_ID and u.user_login = @UserLogin), 
		u.password_set_date) > getdate())

if @IsValid > 1 set @IsValid = 1
	
if @IsValid = 1
Update 	[user]
Set	last_logon_date = getdate()
Where	user_login = @UserLogin





