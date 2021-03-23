USE [EPayment]
GO
/****** Object:  StoredProcedure [dbo].[validateCCTran]    Script Date: 3/23/2021 1:07:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[validateCCTran]
@Cyber_ip varchar(25), 
@Cyber_port varchar(25),
@Merch_id varchar(25),
@Pay_type varchar(10),
@Cust_id varchar(50) = '',
@Prod_descr varchar(50) = '',
@Order_id varchar(50) = '',
@CC_amt varchar(20) = '',
@CC_addr varchar(30) = '',
@CC_zip varchar(9) = '',
@Cust_name varchar(26) = '',
@EComm_type char(1) = 'N',
@Card_present_flag char(1) = '0', --0:The card is not present; 1:The card is present; 2:Unknown
@Terminal_capability char(1) = '3', --0:Unknown; 1:Terminal has a magnetic stripe reader and manual entry capabilities; 2:Magnetic stripe reader; 3:No magnetic stripe reader; 4:Contactless chip read capability; 5:Contactless magnetic stripe read capability
@Terminal_type char(1) = '2', --0:Unknown; 1:Standalone credit card terminal; 2:Electronic Cash Register/POS system; 3:Unattended device
@Pos_entry_mode char(1) = '3', --0:Unknown; 1:Read from credit card magnetic track 1; 2:Read from credit card magnetic track 2; 3:Credit card number manually keyed in to POS terminal; 4:Read from contactless M/chip or Visa smart card; 5:Contactless mobile commerce; 6:Read from contactless chip magnetic strip
@Customer_present_flag char(1) = '1', --0:Customer present; 1:Customer not present; 2:Recurring; 3:Deferred; 4:Telephone transaction; 6:Debt transaction; 7:Billing installment; 8:Interactive Voice Response (IVR) for PINless debit only
@Seq_num varchar(15) = '', 
@CC_num varchar(500) = '',
@CC_expir varchar(500) = '',
@CC_type varchar(500) = '',
@TRAN_RESULT_OUT int = null out,
@RETURN_CODE_MESSAGE_OUT varchar(255) = null out,
@TokenNumber int = 0
as
/*
Validate transaction data:
charge (auth-capture) tran 			@Pay_Type = C
refund tran 					@Pay_Type = R
auth tran 					@Pay_Type = A
capture tran 					@Pay_Type = P
reversal tran					@Pay_Type = RV
refund by seq tran 				@Pay_Type = Q
lookup by seq tran				@Pay_Type = L
void by seq tran				@Pay_Type = VD
*/

--VALIDATE @Pay_Type
If @Pay_Type <> 'C' and @Pay_Type <> 'R' and @Pay_Type <> 'A' and @Pay_Type <> 'P' and @Pay_Type <> 'RV' and @Pay_Type <> 'Q' and @Pay_Type <> 'L' and @Pay_Type <> 'VD'
Begin
	Set @TRAN_RESULT_OUT = -1100
	Set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Invalid Transaction Type'
	RETURN
End

--VALIDATE INPUT PER @Pay_type

--cc charge tran @Pay_Type = C or auth tran @Pay_Type = A
If @Pay_Type = 'C' or @Pay_Type = 'A'
Begin
	if Len(IsNull(@Merch_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Merchant ID'; RETURN; end
	if Len(IsNull(@Cust_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Customer ID'; RETURN; end
	if Len(IsNull(@Prod_descr,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Product Description'; RETURN; end 
	if Len(IsNull(@Order_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Order ID'; RETURN; end  
	if Len(IsNull(@CC_amt,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Amount'; RETURN; end  
	if Len(IsNull(@CC_addr,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Address'; RETURN; end  
 	if Len(IsNull(@CC_zip,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Zip'; RETURN; end   
	--@Cust_name - used but not required
	--@EComm_type - used but not required
	--@Card_present_flag - used but not required  
	--@Terminal_capability - used but not required  
	--@Terminal_type - used but not required
	--@Pos_entry_mode - used but not required 
	--@Customer_present_flag - used but not required 
	--@Seq_num - not used 
	if IsNull(@TokenNumber,0) <= 0
	begin
		if Len(IsNull(@CC_num,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Number'; RETURN; end   
		if (Len(IsNull(@CC_expir,'')) < 4 or IsNumeric(IsNull(@CC_expir,'')) <> 1)   begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Expiration'; RETURN; end    
		if Len(IsNull(@CC_type,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Type'; RETURN; end    
	end
End
--cc refund tran @Pay_Type = R
Else If @Pay_Type = 'R'
Begin
	if Len(IsNull(@Merch_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Merchant ID'; RETURN; end
	if Len(IsNull(@Cust_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Customer ID'; RETURN; end
	if Len(IsNull(@Prod_descr,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Product Description'; RETURN; end 
	if Len(IsNull(@Order_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Order ID'; RETURN; end  
	if Len(IsNull(@CC_amt,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Amount'; RETURN; end  
	if Len(IsNull(@CC_addr,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Address'; RETURN; end  
 	if Len(IsNull(@CC_zip,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Zip'; RETURN; end   
	--@Cust_name - used but not required
	--@EComm_type - used but not required
	--@Card_present_flag - used but not required  
	--@Terminal_capability - used but not required    
	--@Terminal_type - used but not required  
	--@Pos_entry_mode - used but not required  
	--@Customer_present_flag - used but not required  
	--@Seq_num - not used 
	if IsNull(@TokenNumber,0) <= 0
	begin
		if Len(IsNull(@CC_num,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Number'; RETURN; end   
		if (Len(IsNull(@CC_expir,'')) < 4 or IsNumeric(IsNull(@CC_expir,'')) <> 1) begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Expiration'; RETURN; end    
		if Len(IsNull(@CC_type,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Credit Card Type'; RETURN; end    
	end
End
--cc refund by seq tran @Pay_Type = Q
Else If @Pay_Type = 'Q' or @Pay_Type = 'P' or @Pay_Type = 'RV'
Begin
	if Len(IsNull(@Merch_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Merchant ID'; RETURN; end
	--@Cust_id - not used
	--@Prod_descr - not used
	--@Order_id - not used
	if Len(IsNull(@CC_amt,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Amount'; RETURN; end  
	--@CC_addr - not used
 	--@CC_zip - not used
	--@Cust_name - not used 
	--@EComm_type - not used 
	--@Card_present_flag - not used  
	--@Terminal_capability - not used  
	--@Terminal_type - not used
	--@Pos_entry_mode - not used 
	--@Customer_present_flag - not used 
	if Len(IsNull(@Seq_num,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Parent Sequence Number'; RETURN; end    
	--@CC_num - not used
	--@CC_expir - not used
	--@CC_type - not used
End
--cc lookup by seq tran	@Pay_Type = L
Else If @Pay_Type = 'L' or @Pay_Type = 'VD'
Begin
	if Len(IsNull(@Merch_id,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Merchant ID'; RETURN; end
	--@Cust_id - not used
	--@Prod_descr - not used
	--@Order_id - not used
	--@CC_amt  - not used
	--@CC_addr - not used
 	--@CC_zip - not used
	--@Cust_name - not used 
	--@EComm_type - not used 
	--@Card_present_flag - not used  
	--@Terminal_capability - not used  
	--@Terminal_type - not used
	--@Pos_entry_mode - not used 
	--@Customer_present_flag - not used 
	if Len(IsNull(@Seq_num,'')) <= 0 begin set @TRAN_RESULT_OUT = -1100; set @RETURN_CODE_MESSAGE_OUT = 'INPUT VALIDATION ERROR - Parent Sequence Number'; RETURN; end    
	--@CC_num - used as an output
	--@CC_expir - used as an output
	--@CC_type - used as an output
End






