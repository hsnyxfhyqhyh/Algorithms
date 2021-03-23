USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[usp_ccTranRC_LogXML]    Script Date: 3/23/2021 5:10:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_ccTranRC_LogXML]
@CC_TRANS_RC_CCTranID int,
@CC_TRANS_RC_XML varchar(max),
@CC_TRANS_RC_XML_TYPE varchar(50),
@CC_TRANS_RC_XML_CCTranID int = 0 out
as
INSERT INTO [dbo].[CC_TRANS_RC_XML]
           ([CC_TRANS_RC_CCTranID]
           ,[CC_TRANS_RC_XML]
           ,[CC_TRANS_RC_XML_TYPE])
     VALUES
           (@CC_TRANS_RC_CCTranID,
            @CC_TRANS_RC_XML,
            @CC_TRANS_RC_XML_TYPE)
            
IF @@ERROR = 0 SET @CC_TRANS_RC_XML_CCTranID = SCOPE_IDENTITY()
ELSE SET @CC_TRANS_RC_XML_CCTranID = -1


