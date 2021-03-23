USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[updateTransAction]    Script Date: 3/23/2021 5:19:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER     proc [dbo].[updateTransAction]
@TranID int,
@SeqID varchar(50),
@TranStatus varchar(50),
@Comment varchar(500)
as

UPDATE 	[TRANS_ACTIONS]
SET	[SEQ_ID] = @SeqID, 
	[COMMENT] = IsNull([COMMENT],' ') + @Comment,
	[TRAN_STATUS] = @TranStatus,
	[COMPLETED_DATE_TIME] = GetDate()
WHERE 	TRAN_ID = @TranID





