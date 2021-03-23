USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_Dups]    Script Date: 3/23/2021 5:17:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ccTranRC_Dups]
@MerchantID varchar(32),
@TranType varchar(50),
@Last4PAN varchar(4),
@Amount numeric(16,4),
@CustomerName varchar(26),
@Street varchar(30),
@CustomerID varchar(50),
@TranDupsInterval int,
@HasDups bit = 0 out
as
IF EXISTS (
			select	*
			from	cc_trans (nolock)
			where	TranResult = '0' and
					AuthResponseCode = 'A' and
					TranState <> 'V' and
					MerchantID = @MerchantID and
					TranType = @TranType and
					TranType in ('AUTH', 'AUTH_CAPTURE', 'REF', 'REF_BY_SEQ') and
					Last4PAN = @Last4PAN and
					Amount = @Amount and
					--CustomerName = @CustomerName and
					Street = @Street and
					CustomerID = @CustomerID and
					Created between DateAdd(mi,-@TranDupsInterval,GETDATE()) and GETDATE()
			)
SET @HasDups = 1
ELSE SET @HasDups = 0

/*
select	count(*) [Dups Count], TranType, Last4PAN [CC Number], Amount [Amount], CustomerName [Name], Street [Address], 
		CustomerID [Member ID], convert(varchar(30),Created, 101) [Date]
from	cc_trans (nolock)
where	TranResult = '0' and
		AuthResponseCode = 'A' and
		--TranState <> 'V' and
		Created between DateAdd(mi,-10,GETDATE()) and GETDATE()
group by TranType, Last4PAN, Amount, CustomerName, Street, CustomerID, convert(varchar(30),Created, 101)
having count(*) > 1
order by [date], CustomerID
*/


