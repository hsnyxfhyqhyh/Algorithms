CREATE OR REPLACE TRIGGER "MZ_RIDER_D2000_TAIUR"
    AFTER
    INSERT OR UPDATE OF STATUS, EFFECTIVE_DT
    ON MZ_RIDER
    REFERENCING NEW AS NEW OLD AS OLD
    FOR EACH ROW



Begin
   update mz_membership
   set    adm_d2000_update_dt = sysdate
   where  membership_ky   = :new.membership_ky;
   
   INSERT INTO MZ_PLUS_212.MZ_D3K_UPDATE (MEMBERSHIP_KY, MEMBER_KY, MEMBERSHIP_ID, PROCESS_FL, PROCESS_DT, PROCESS_KY)
   SELECT membership_ky,member_ky,'438212'||trim(membership_id)||associate_id||check_digit_nr,'true',sysdate,MZ_D3PROCESSUPD_KY_SEQ.NEXTVAL
		FROM MZ_PLUS_212.MZ_MEMBER
		WHERE membership_ky=:new.membership_ky and member_ky=:new.member_ky and rider_comp_cd = 'BS';
End;



