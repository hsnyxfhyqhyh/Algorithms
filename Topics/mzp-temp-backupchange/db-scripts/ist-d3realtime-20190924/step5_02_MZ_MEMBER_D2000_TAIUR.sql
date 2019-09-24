CREATE OR REPLACE TRIGGER "MZ_MEMBER_D2000_TAIUR"
    AFTER
    INSERT OR UPDATE OF MEMBER_EXPIRATION_DT, STATUS, JOIN_AAA_DT, JOIN_CLUB_DT, SALUTATION, FIRST_NAME, MIDDLE_NAME, LAST_NAME, ASSOCIATE_ID, RENEW_METHOD_CD, EMAIL, ENTITLEMENT_START_DT, ENTITLEMENT_END_DT
    ON MZ_MEMBER
    REFERENCING NEW AS NEW OLD AS OLD
    FOR EACH ROW


Begin
   update mz_membership
   set    adm_d2000_update_dt = sysdate
   where  membership_ky   = :new.membership_ky;
   
   INSERT INTO MZ_PLUS_212.MZ_D3K_UPDATE (MEMBERSHIP_KY, MEMBER_KY, MEMBERSHIP_ID, PROCESS_FL, PROCESS_DT, PROCESS_KY)
   SELECT membership_ky,member_ky,'438212'||trim(membership_id)||associate_id||check_digit_nr,'true',sysdate,MZ_D3PROCESSUPD_KY_SEQ.NEXTVAL
		FROM MZ_PLUS_212.MZ_MEMBER
		WHERE membership_ky=:new.membership_ky and member_ky=:new.member_ky;
   
End;