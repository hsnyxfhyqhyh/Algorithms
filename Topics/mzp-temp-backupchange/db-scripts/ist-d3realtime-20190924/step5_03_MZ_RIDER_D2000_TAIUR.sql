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
End;



