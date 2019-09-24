CREATE OR REPLACE TRIGGER "MZ_MEMBERSHIP_D2000_TBIUR"
    BEFORE
    INSERT OR UPDATE OF STATUS, ADDRESS_LINE1, ADDRESS_LINE2, CITY, STATE, ZIP, COUNTRY, PHONE
    ON MZ_MEMBERSHIP
    REFERENCING NEW AS NEW OLD AS OLD
    FOR EACH ROW



Begin
   	:new.adm_d2000_update_dt := sysdate;
   	--if select count(*) from MZ_PLUS_212.MZ_D3K_UPDATE where PROCESS_FL = 'true' and 
   	INSERT INTO MZ_PLUS_212.MZ_D3K_UPDATE (MEMBERSHIP_KY, MEMBER_KY, MEMBERSHIP_ID, PROCESS_FL, PROCESS_DT, PROCESS_KY)
   	SELECT membership_ky,member_ky,'438212'||trim(membership_id)||associate_id||check_digit_nr,'true',sysdate,MZ_D3PROCESSUPD_KY_SEQ.NEXTVAL
		FROM MZ_PLUS_212.MZ_MEMBER
		WHERE membership_ky=:new.membership_ky and member_type_cd='P';
   
End;


