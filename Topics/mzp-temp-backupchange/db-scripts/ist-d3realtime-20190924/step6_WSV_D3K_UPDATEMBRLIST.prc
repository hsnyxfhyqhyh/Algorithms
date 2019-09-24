CREATE OR REPLACE PROCEDURE "WSV_D3K_UPDATEMBRLIST" 
(  --v_membership_ky in number,
   v_member_ky in number,
   out_refcursor  out SYS_REFCURSOR )
is
 
BEGIN
  
 OPEN out_refcursor FOR
  select  a.membership_ky,
       b.member_ky,
       (case when b.status <> 'C' and (sysdate - b.member_expiration_dt) > 0 then 'Y' else 'N' end) as update_fl,
       '212' as clb_cd,
       a.membership_id,
       b.associate_id,
       b.last_name, 
       b.first_name, 
       a.address_line1,
       a.address_line2,
       a.city, 
       a.state,
       a.zip,
       a.delivery_route, 
       (case when b.status = 'P' and a.membership_type_cd = 'TEMP' then 'A'
             else b.status
        end) as status,
        
       (case
               (case when b.status = 'P' and a.membership_type_cd = 'TEMP' then 'A'
                     else b.status
                 end)
               when 'C' then nvl(d.cancel_reason_cd,'C1')
               when 'P' then nvl((
                    select decode(bill_type,'R','B','D')||ltrim(decode(bill_type,'D',notice_nr -1, notice_nr))
                    from mz_bill_summary bs
                    where bs.process_dt > sysdate - 30
                    and bs.bill_summary_ky = (select max(bill_summary_ky)
                                           from mz_bill_summary b2
                                           where b2.membership_ky = bs.membership_ky)
                    and bs.membership_ky = a.membership_ky
                    and bs.bill_type in ('R','D')
                    ),' ')
               else '  '
             end) status_desc, 
             
       a.phone,
       b.salutation,
       b.name_suffix, 
       lpad((case when b.status = 'C' and (b.cancel_dt < b.join_aaa_dt or b.cancel_dt is null or b.join_aaa_dt is null) then '00'
             when b.status = 'C' then substr(to_char(100 + to_number(to_char(b.cancel_dt, 'YYYY')) - to_number(to_char(b.join_aaa_dt, 'YYYY'))), 2)
             when b.member_expiration_dt < b.join_aaa_dt or b.member_expiration_dt is null or b.join_aaa_dt is null then '00'
             else substr(to_char(100 + to_number(to_char(b.member_expiration_dt, 'YYYY')) - to_number(to_char(b.join_aaa_dt, 'YYYY'))), 2)
        end),2,'0') as membership_length,
        
       rpad(nvl(to_char(b.join_aaa_dt, 'YYYY'), '0'), 4, '0') as aaa_join_year,
       rpad(nvl(to_char(b.join_club_dt, 'YYYY'), '0'), 4, '0') as club_join_year,
       to_char(b.birth_dt, 'MM/DD/YYYY') as birth_dt, 
       to_char(b.member_expiration_dt, 'MM/DD/YYYY') as member_expiration_dt,
       case when b.status = 'C' and b.cancel_dt is null and b.join_club_dt is not null then to_char(b.join_club_dt, 'MM/DD/YYYY')
                  when b.cancel_dt is null then ' '
                  else to_char(b.cancel_dt, 'MM/DD/YYYY')
             end as cancel_dt,
       case when p.rider_comp_cd is null then ' '
                  when d.effective_dt is null then ' '
                  when p.cancel_dt is not null and d.effective_dt > p.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < p.effective_dt then ' '
                  else p.rider_comp_cd
             end as plus_rider_comp_cd,
       case when p.effective_dt is null then ' '
                  when d.effective_dt is null then ' '
                  when p.cancel_dt is not null and d.effective_dt > p.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < p.effective_dt then ' '
                  when f.membership_ky is not null and f.member_type_cd = 'P'  then  to_char(p.effective_dt + 2, 'MM/DD/YYYY')
                  when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  to_char(p.effective_dt + 2, 'MM/DD/YYYY')
                  when d.effective_dt > p.effective_dt then to_char(d.effective_dt + 7, 'MM/DD/YYYY')
                  else to_char(p.effective_dt + 7, 'MM/DD/YYYY')
             end as plus_effective_dt,
             
       case when d.effective_dt is null then ' '
                  when p.cancel_dt is not null and d.effective_dt > p.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < p.effective_dt then ' '
                  when p.rider_comp_cd is not null and p.cancel_dt is not null and b.cancel_dt is not null and b.cancel_dt < p.cancel_dt then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when p.rider_comp_cd is not null and p.cancel_dt is null and b.cancel_dt is not null then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when p.cancel_dt is null then ' '
                  else to_char(p.cancel_dt, 'MM/DD/YYYY')
             end as plus_cancel_dt,
             
       case when r.rider_comp_cd is null then ' '
                  when d.effective_dt is null then ' '
                  when r.cancel_dt is not null and d.effective_dt > r.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < r.effective_dt then ' '
                  else r.rider_comp_cd
             end as rv_rirder_comp_cd,
       case when r.effective_dt is null then ' '
                  when d.effective_dt is null then ' '
                  when r.cancel_dt is not null and d.effective_dt > r.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < r.effective_dt then ' '
                  when f.membership_ky is not null and f.member_type_cd = 'P'  then  to_char(r.effective_dt + 2, 'MM/DD/YYYY')
                  when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  to_char(r.effective_dt + 2, 'MM/DD/YYYY')
                  when d.effective_dt > r.effective_dt then to_char(d.effective_dt + 7, 'MM/DD/YYYY')
                  else to_char(r.effective_dt + 7, 'MM/DD/YYYY')
             end as rv_effective_dt,
             
       case when d.effective_dt is null then ' '
                  when r.cancel_dt is not null and d.effective_dt > r.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < r.effective_dt then ' '
                  when r.rider_comp_cd is not null and r.cancel_dt is not null and b.cancel_dt is not null and b.cancel_dt < r.cancel_dt then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when r.rider_comp_cd is not null and r.cancel_dt is null and b.cancel_dt is not null then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when r.cancel_dt is null then ' '
                  else to_char(r.cancel_dt, 'MM/DD/YYYY')
             end as rv_Cancel_dt,
             
       case when m.rider_comp_cd is null then ' '
                  when d.effective_dt is null then ' '
                  when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                  When case when r.rider_comp_cd is null then ' '
                       when d.effective_dt is null then ' '
                       when r.cancel_dt is not null and d.effective_dt > r.cancel_dt then ' '
                       when b.cancel_dt is not null and b.cancel_dt < r.effective_dt then ' '
                       else 'V'
                       end = 'V' Then 'V'
                  else 'E'
             end as premier_rider_come_cd,
             
       case when m.effective_dt is null then ' '
                  when d.effective_dt is null then ' '
                  when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                  when f.membership_ky is not null and f.member_type_cd = 'P'  then  to_char(m.effective_dt + 2, 'MM/DD/YYYY')
                  when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  to_char(m.effective_dt + 2, 'MM/DD/YYYY')
                  when d.effective_dt > m.effective_dt then to_char(d.effective_dt + 7, 'MM/DD/YYYY')
                  else to_char(m.effective_dt + 7, 'MM/DD/YYYY')
             end as premier_effective_dt,
             
       case when d.effective_dt is null then ' '
                  when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                  when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                  when m.rider_comp_cd is not null and m.cancel_dt is not null and b.cancel_dt is not null and b.cancel_dt < m.cancel_dt then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when m.rider_comp_cd is not null and m.cancel_dt is null and b.cancel_dt is not null then to_char(b.cancel_dt, 'MM/DD/YYYY')
                  when m.cancel_dt is null then ' '
                  else to_char(m.cancel_dt, 'MM/DD/YYYY')
             end as premier_cancel_dt,
             
       nvl(substr(c.branch_cd, length(c.branch_cd) - 1, length(c.branch_cd)), ' ') as branch_cd,

       case when a.salvage_fl = 'Y' then 'SLVG'
                  when b.renew_method_cd='A' then 'AR'
                  else ' '
             end as salvage_ar_fl,

        case when a.flex_date_1 < sysdate and (select count(*) from mz_rider where member_ky = b.member_ky and rider_comp_cd = 'BP' and status <> 'C') > 0 then 'PB'
                  else ' '
             end pb_rider_comp_cd,
             
        case when (select count(*) from mz_rider where membership_ky = a.membership_ky and rider_comp_cd = 'MC' and status <> 'C') > 0 then 'MC'
                  else ' '
             end mc_rider_comp_cd,
    
       case when (select count(*) from mz_batch_payment p where p.membership_ky = a.membership_ky and p.reason_cd = '21') > 0 then 'Y'
            else 'N'
        end return_check,
      --sysdate as current_dt,
      b.email, 
      MZ_FULL_MEMBERSHIP_ID('212',b.member_ky) as full_membership_id,
     case
          when (upper(b.billing_cd) = 'NM' or b.commission_cd = 'N') and nvl(a.salvage_fl,'N') = 'N' and (select count(*) from mz_membership_code where code = 'SAL' and membership_ky = a.membership_ky )<= 0and b.status <> 'C'
                then COALESCE(TO_char(b.corp_join_dt,'MM/DD/YYYY'),TO_char(b.join_club_dt,'MM/DD/YYYY'),TO_char(b.activation_dt,'MM/DD/YYYY'),to_char(sysdate, 'MM/DD/YYYY'))
           when (nvl(a.salvage_fl,'N') = 'Y' or (select count(*) from mz_membership_code where code = 'SAL' and membership_ky = a.membership_ky )> 0) and b.status <> 'C'
               then COALESCE(TO_char(b.corp_join_dt,'MM/DD/YYYY'),TO_char(b.activation_dt,'MM/DD/YYYY'),to_char(sysdate, 'MM/DD/YYYY'))
          when  nvl(d.reinstate_fl,'N') = 'Y' and b.status <> 'C'
            then COALESCE(TO_char(b.corp_join_dt,'MM/DD/YYYY'),TO_char(b.activation_dt,'MM/DD/YYYY'),to_char(sysdate, 'MM/DD/YYYY'))
           when (MOD(EXTRACT(year FROM trunc(b.member_expiration_dt)), 4)= 0 OR  MOD(EXTRACT(year FROM trunc(b.member_expiration_dt)), 400) = 0)  AND  MOD(EXTRACT(year FROM trunc(b.member_expiration_dt)), 100)!=0
            then to_char(trunc(b.member_expiration_dt) -365,'MM/DD/YYYY')
        else
            to_char(trunc(b.member_expiration_dt) -364,'MM/DD/YYYY')
        end as entitlement_start_dt,

      to_char(b.member_expiration_dt,'MM/DD/YYYY') as entitlement_end_dt,
      nvl(TO_char(b.join_club_dt,'MM/DD/YYYY'),(to_char(sysdate, 'MM/DD/YYYY'))) as join_club_dt,
      nvl(TO_char(b.join_aaa_dt,'MM/DD/YYYY'),(to_char(sysdate, 'MM/DD/YYYY'))) as join_aaa_dt,
      c.branch_cd as branch_code,
      
      Case
         --Effective Premier and AR
         when
           (case when m.rider_comp_cd is null then ' '
                when d.effective_dt is null then ' '
                when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                when m.cancel_dt is not null and m.cancel_dt <= trunc(sysdate) then ' '
                else 'E' end )  = 'E' and
           (case        when f.membership_ky is not null and f.member_type_cd = 'P'  then  m.effective_dt + 2
                        when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  m.effective_dt + 2
                        when d.effective_dt > m.effective_dt then d.effective_dt + 7
                        else m.effective_dt + 7
                   end) < trunc(sysdate)  and
              b.renew_method_cd='A' Then '06'
         --Non-effective Premier and AR
         when
               (case when m.rider_comp_cd is null then ' '
                when d.effective_dt is null then ' '
                when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                when m.cancel_dt is not null and m.cancel_dt <= trunc(sysdate) then ' '
                else 'E' end)  = 'E' and
           (case        when f.membership_ky is not null and f.member_type_cd = 'P'  then  m.effective_dt + 2
                        when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  m.effective_dt + 2
                        when d.effective_dt > m.effective_dt then d.effective_dt + 7
                        else m.effective_dt + 7
                   end) > trunc(sysdate) and
              b.renew_method_cd='A' Then '05'
         --Effective Premier and Non-AR
         when
           (case when m.rider_comp_cd is null then ' '
                when d.effective_dt is null then ' '
                when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                when m.cancel_dt is not null and m.cancel_dt <= trunc(sysdate) then ' '
                else 'E' end)  = 'E' and
           (case        when f.membership_ky is not null and f.member_type_cd = 'P'  then  m.effective_dt + 2
                        when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  m.effective_dt + 2
                        when d.effective_dt > m.effective_dt then d.effective_dt + 7
                        else m.effective_dt + 7
                   end) < trunc(sysdate) and
              b.renew_method_cd<>'A' Then '05'
         --Non-Effective Premier and Non-AR
         when
           (case when m.rider_comp_cd is null then ' '
                when d.effective_dt is null then ' '
                when m.cancel_dt is not null and d.effective_dt > m.cancel_dt then ' '
                when b.cancel_dt is not null and b.cancel_dt < m.effective_dt then ' '
                when m.cancel_dt is not null and m.cancel_dt <= trunc(sysdate) then ' '
                else 'E' end)  = 'E' and
           (case        when f.membership_ky is not null and f.member_type_cd = 'P'  then  m.effective_dt + 2
                        when f.membership_ky is not null and f.member_type_cd = 'A' and b.member_ky = f.member_ky  then  m.effective_dt + 2
                        when d.effective_dt > m.effective_dt then d.effective_dt + 7
                        else m.effective_dt + 7
                   end) > trunc(sysdate) and
              b.renew_method_cd <> 'A' Then '04'

          --No Premier and AR
          When  b.renew_method_cd = 'A' Then '05'
          --Default
          else '04'
       end as entitlement_count,
       a.status as membership_status,
       '' as plus_ind
 
  from mz_member b
  inner join mz_membership a on b.membership_ky = a.membership_ky 
  left join mz_branch c on c.branch_ky = a.branch_ky
  left outer join mz_rider d on d.member_ky = b.member_ky and d.rider_comp_cd = 'BS'
  left outer join mz_rider p on p.member_ky = b.member_ky and p.rider_comp_cd = 'PL'
  left outer join mz_rider r on r.member_ky = b.member_ky and r.rider_comp_cd = 'RV'
  left outer join mz_rider m on m.member_ky = b.member_ky and m.rider_comp_cd = 'PM'
 
  left join (select b1.member_ky, b1.membership_ky, b1.membership_id, b1.member_type_cd
            from mz_member b1, mz_membership_fees f1
            Where  f1.fee_type in ('ESF', '2DW')
            and f1.status = 'A'
            and b1.member_ky = f1.member_ky) f on  b.membership_ky = f.membership_ky
  
  --where  b.membership_ky = v_membership_ky;
  where b.member_ky = v_member_ky;
  
  
  

END WSV_D3K_UPDATEMBRLIST;
/
