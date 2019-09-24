-- Create table
create table MZ_PLUS_212.MZ_D3K_NEWJOIN
(
  membership_ky NUMBER,
  member_ky     NUMBER,
  membership_id VARCHAR2(16),
  process_fl    VARCHAR2(10),
  process_dt    DATE,
  process_ky    NUMBER not null
)
tablespace MZP_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

alter table MZ_D3K_NEWJOIN
  add constraint MZ_D3K_NEWJOIN_PK primary key (process_ky)
  using index 
  tablespace MZ_PLUS_007_INDEX_LARGE
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 184M
    next 1M
    minextents 1
    maxextents unlimited
  );
  

create index MZ_D3K_NEWJOIN_IDX on MZ_D3K_NEWJOIN (MEMBER_KY)
  tablespace MZ_PLUS_007_INDEX_LARGE
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 100M
    next 1M
    minextents 1
    maxextents unlimited
  );
  
create index MZ_D3K_NEWJOIN_MS_IDX on MZ_D3K_NEWJOIN (MEMBERSHIP_KY)
  tablespace MZ_PLUS_007_INDEX_LARGE
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 100M
    next 1M
    minextents 1
    maxextents unlimited
  );
  
create index MZ_D3K_NEWJOIN_PD_IDX on MZ_D3K_NEWJOIN (process_dt)
  tablespace MZ_PLUS_007_INDEX_LARGE
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 100M
    next 1M
    minextents 1
    maxextents unlimited
  );
      
create sequence MZ_D3PROCESS_KY_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
cache 20;

  
