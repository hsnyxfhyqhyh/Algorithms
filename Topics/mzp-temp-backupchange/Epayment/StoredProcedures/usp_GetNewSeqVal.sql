USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetNewSeqVal]    Script Date: 3/26/2021 2:17:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************   
** Name: dbo.usp_GetNewSeqVal
** Desc: retrieve next seq value from the AllSequences table based on the seq name (MID). reset current seq value if max range is reached or next time interval is reached
** Auth: Ed Klichinsky, AAA Mid-Atlantic, eklichinsky@aaamidatlantic.com
** Date: 10/30/13
*******************************/
ALTER procedure [dbo].[usp_GetNewSeqVal]
      @SeqName nvarchar(255)-- name of the sequence (MID)
as
begin
      declare @NewSeqVal int
      set NOCOUNT ON
      update AllSequences
      set @NewSeqVal = CurrVal = (case 
									when (
											(IsNull(CurrVal,0) < IsNull(MaxVal,0)) and
											(GetDate() <= (case IsNull(IncrDatepart,'') 
															when 'year' then DateAdd(year, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
															when 'month' then DateAdd(month, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
															when 'week' then DateAdd(week, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
															when 'day' then DateAdd(day, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
															when 'hour' then DateAdd(hour, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
															when 'minute' then DateAdd(minute, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
															when 'second' then DateAdd(second, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
															else GetDate()
														  end))
										 )
									then CurrVal+Incr 
									else Seed 
								  end),
		  IncrDatepartValTS = (case 
								when (
									(GetDate() >= (case IsNull(IncrDatepart,'') 
													when 'year' then DateAdd(year, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
													when 'month' then DateAdd(month, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
													when 'week' then DateAdd(week, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
													when 'day' then DateAdd(day, IsNull(IncrDatepartVal,1), Convert(varchar(20),IsNull(IncrDatepartValTS,'01/01/2013'), 101))
													when 'hour' then DateAdd(hour, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
													when 'minute' then DateAdd(minute, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
													when 'second' then DateAdd(second, IsNull(IncrDatepartVal,1), IsNull(IncrDatepartValTS,'01/01/2013'))
													else GetDate()
												  end))
								 )
								then GetDate()
								else IsNull(IncrDatepartValTS,GetDate())
							  end)
      where SeqName = @SeqName
     
      if @@rowcount = 0 
      begin  
		--create explicit sequence if seq name contains 'STAN' string
		if PATINDEX('%STAN%',@SeqName) > 0
		begin 
			--create new sequence record which will start at 1 and increment by 1 until max range is reached. sequence value will also be reset when time interval is reached (start of next day)
			exec usp_CreateNewSeq
				  @seqname = @SeqName,
				  @seed = 1,
				  @incr = 1,
				  @maxval = 999999,
				  @incrdatepart = 'day',
				  @incrdatepartval = 1
			--recursive call, get sequence value 
			exec @NewSeqVal = usp_GetNewSeqVal @SeqName
		end
		--create explicit sequence if seq name contains 'RefNum' string
		else if PATINDEX('%RefNum%',@SeqName) > 0
		begin 
			--create new sequence record which will start at 1 and increment by 1 until max range is reached. sequence value will also be reset when time interval is reached (start of next day)
			exec usp_CreateNewSeq
				  @seqname = @SeqName,
				  @seed = 1,
				  @incr = 1,
				  @maxval = 99999999, --max int type size = 2,147,483,647 - if larger value is needed change type to bigint
				  @incrdatepart = 'day',
				  @incrdatepartval = 1
			--recursive call, get sequence value 
			exec @NewSeqVal = usp_GetNewSeqVal @SeqName
		end
		--create explicit sequence if seq name contains 'AllMerchants_OrdNum' string
		else if PATINDEX('%AllMerchants_OrdNum%',@SeqName) > 0
		begin 
			--create new sequence record which will start at 1 and increment by 1 until max range is reached.
			exec usp_CreateNewSeq
				  @seqname = @SeqName,
				  @seed = 1,
				  @incr = 1,
				  @maxval = 99999999, --max int type size = 2,147,483,647 - if larger value is needed change type to bigint
				  @incrdatepart = null,
				  @incrdatepartval = null
			--recursive call, get sequence value 
			exec @NewSeqVal = usp_GetNewSeqVal @SeqName
		end		
		--sequence not found return error
		else
		begin
			print 'Sequence does not exist'
			return
		end
      end
 
      return @NewSeqVal
end

