

    alter table [TravelServices].[dbo].[grp_Package] 
  add [TripleComm] [decimal](9, 2) NULL; 

alter table [TravelServices].[dbo].[grp_Package] 
  add [QuadComm] [decimal](9, 2) NULL;


 

  --
  	alter table [TravelServices].[dbo].[grp_Option] 
  add [SingleRate] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

  alter table [TravelServices].[dbo].[grp_Option] 
  add [DoubleRate] [decimal](9, 2) NOT NULL DEFAULT 0.00; 
	
alter table [TravelServices].[dbo].[grp_Option] 
  add [TripleRate] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [QuadRate] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [SingleComm] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [DoubleComm] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [TripleComm] [decimal](9, 2) NOT NULL DEFAULT 0.00; 
	
alter table [TravelServices].[dbo].[grp_Option] 
  add [QuadComm] [decimal](9, 2) NOT NULL DEFAULT 0.00; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [Quantity] [int] NOT NULL DEFAULT 0; 

alter table [TravelServices].[dbo].[grp_Option] 
  add [Allocated] [int] NOT NULL DEFAULT 0; 


alter table [TravelServices].[dbo].[grp_Option] 
  add [OptionCode] [varchar](10) NOT NULL DEFAULT ''; 


alter table [TravelServices].[dbo].[grp_Bill] 
  add [Commission][decimal](9, 2) NOT NULL DEFAULT 0.00; 



/*
--dropped
alter table [TravelServices].[dbo].[grp_Option] 
DROP COLUMN  [Rate];

--not dropped , because of constraint "DF_grp_Option_OptionType"
alter table [TravelServices].[dbo].[grp_Option] 
DROP COLUMN  [RateType];
  */