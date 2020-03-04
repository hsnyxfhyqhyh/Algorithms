package com.aaa.soa.object;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.SortedSet;
import java.util.StringTokenizer;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Element;

import com.aaa.soa.object.models.Address;
import com.aaa.soa.object.models.Code;
import com.aaa.soa.object.models.CreditCard;
import com.aaa.soa.object.models.EnrollDonorMembershipInARRequest;
import com.aaa.soa.object.models.MembershipEnrollRequest;
import com.aaa.soa.object.models.MembershipPaymentSummary;
import com.aaa.soa.object.models.Name;
import com.aaa.soa.object.models.PaymentParameters;
import com.aaa.soa.object.models.Phone;
import com.aaa.soa.object.models.SimpleAssociateMember;
import com.aaa.soa.object.models.SimpleMembership;
import com.aaa.soa.object.models.SimpleMembershipNumber;
import com.aaa.soa.object.models.SimplePrimaryMember;
import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.cache.DropDownUtil;
import com.rossgroupinc.conxons.rule.Validator;
import com.rossgroupinc.conxons.security.ConxonsSecurity;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.errorhandling.ObjectNotFoundException;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.MemberzPlusUser;
import com.rossgroupinc.memberz.action.MemberAction;
import com.rossgroupinc.memberz.bp.cancel.CancelBP;
import com.rossgroupinc.memberz.bp.cost.CostBP;
import com.rossgroupinc.memberz.bp.member.MembershipMaintenanceBP;
import com.rossgroupinc.memberz.bp.membership.MembershipAffiliationBP;
import com.rossgroupinc.memberz.bp.membership.MembershipIdBP;
import com.rossgroupinc.memberz.bp.payment.CreditCardProcessorBP;
import com.rossgroupinc.memberz.bp.payment.PaymentPosterBP;
import com.rossgroupinc.memberz.data.model.MembershipNumber;
import com.rossgroupinc.memberz.model.AutorenewalCard;
import com.rossgroupinc.memberz.model.BatchHeader;
import com.rossgroupinc.memberz.model.BatchPayment;
import com.rossgroupinc.memberz.model.Branch;
import com.rossgroupinc.memberz.model.CoverageLevel;
import com.rossgroupinc.memberz.model.Division;
import com.rossgroupinc.memberz.model.Donor;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.MemberCode;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.MembershipCode;
import com.rossgroupinc.memberz.model.MembershipComment;
import com.rossgroupinc.memberz.model.MembershipFees;
import com.rossgroupinc.memberz.model.OtherPhone;
import com.rossgroupinc.memberz.model.PaymentSummary;
import com.rossgroupinc.memberz.model.Rider;
import com.rossgroupinc.memberz.model.RiderCost;
import com.rossgroupinc.memberz.model.SalesAgent;
import com.rossgroupinc.memberz.model.Solicitation;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.DateUtils;
import com.rossgroupinc.util.RGILoggerFactory;
import com.rossgroupinc.util.SearchCondition;
import com.rossgroupinc.util.StringUtils;


public class MaintenanceBP extends BusinessProcess {

	private static final long 			serialVersionUID 		= 1L;
	private static Logger 				log 					= null;
	private Validator					v						= null;
	private Member						member 					= null;
	private Membership					membership 				= null;
	private String 						salesAgentId        	= null;
	private Timestamp 					_TransactionDt 			= null;
	private boolean 					isInstallmentPlan 		= false ;  	
	private String 						ppKy 					= null;
	private Object 						request 				= null;
	
	private static final String		localConfig		= "memberz/soa/Maintenance.xml";
	

	private MembershipUtilBP membershipUtilBP = MembershipUtilBP.getInstance();
	public MaintenanceBP(User user) {
		super();
		this.user = user;
		log = LogManager.getLogger(this.getClass().getName(), new RGILoggerFactory());
	}

	/**
	 * Adds new member to an existing membership
	 * @param member
	 * @param marketCd
	 * @return member
	 * @throws SQLException 
	 * @throws Exception
	 */
	public Member addMember(Membership membership, Member member, String marketCd, User mUser, String agentId) throws Exception
	{
		this.membership = membership;
		this.member = member;
		this.user = mUser;
		this.salesAgentId =agentId;		

		StringBuffer comment = new StringBuffer(200);
		comment.append("Add Member Service: ");
		
		boolean enforceAssocateAgeLimit = "Y".equals(ClubProperties.getString("EnforceAssociateAgeLimit", membership.getDivisionKy(), membership.getRegionCode()));

		if (enforceAssocateAgeLimit){
			//We have to have the birth date entered and the relationship cd entered in order
			//for the following code to be valid so if they are not required make them required and error out
			int assocAgeLimit = 21; //set default
			assocAgeLimit = ClubProperties.getInt("AssociateAgeLimit", membership.getDivisionKy(), membership.getRegionCode());
			if (!"SPOUSE".equals(member.getAssociateRelationCd()) && !"SELF".equals(member.getAssociateRelationCd())){
				if (member.getBirthDt() != null){
					// if day of year after today's day of year just subtract years
					// else subtract years -1
					Calendar calBirthDt = Calendar.getInstance();
					calBirthDt.setTimeInMillis(member.getBirthDt().getTime());
					Calendar todayMinusLimit = Calendar.getInstance();
					todayMinusLimit.add(Calendar.YEAR, -assocAgeLimit);
					if (calBirthDt.before(todayMinusLimit)){
						throw new Exception ( "Associates must be under the age of " + assocAgeLimit + " unless they are the spouse.");
					}
				}
			}
		}
		if (ClubProperties.emailIsWebUsername(membership.getDivisionKy(),membership.getRegionCode())) {
			if ((member.isNew() || member.isColumnUpdated(Member.EMAIL)) && member.getEmail() != null && !"".equals(member.getEmail())){
				ArrayList<SearchCondition> nameCriteria = new ArrayList<SearchCondition>();
				nameCriteria.add(new SearchCondition(Member.EMAIL, SearchCondition.EQ, member.getEmail()));
				for (Member m:Member.getMemberList(user, nameCriteria, null)) {
					if (m.getMemberKy().compareTo(member.getMemberKy())!=0)
						throw new Exception ( "Email already in use please provide a different email");
				}
			}
		}
		if ("".equals(member.getBirthDt()) && Member.JUNIOR_MEMBER_TYPE.equals(member.getMemberTypeCd())){
			Timestamp bdayTS = member.getBirthDt();
			Validator bDayValidator = MemberAction.validateJuniorBirthDate(v, "BIRTH_DT", bdayTS, membership.getDivisionKy(), membership.getRegionCode());
			if (!bDayValidator.isValid("BIRTH_DT")){
				throw new Exception ( bDayValidator.getErrorMsg("BIRTH_DT"));
			}
		}
		Solicitation	solicitation	= null;
		
		if(StringUtils.blanknull(marketCd).equals("")){
			marketCd = null;
		}	
		
		if (marketCd != null){
			try{
				solicitation = Solicitation.getSolicitation(this.user, marketCd);
			}
			catch (Exception e)
			{
				log.error ("MaintenanceBP:addMember - Invalid market code. Please try again");
				throw new Exception (marketCd + " is not valid. Please use a different code.");
			}
		}
		if (solicitation != null ) {			
			member.setBillingCategoryCd(solicitation.getBillingCategoryCd());
			member.setSolicitationCd(solicitation.getSolicitationCd());
		}
		else
		{
			member.setBillingCategoryCd(membership.getBillingCategoryCd());
			member.setSolicitationCd(membership.getPrimaryMember().getSolicitationCd());						
		}
		MembershipMaintenanceBP membershipMaintenanceBP = (MembershipMaintenanceBP) BPF.get(this.user, MembershipMaintenanceBP.class);

		//call this to set the assoc id/check digit and other default settings
		boolean setDefaults = membershipMaintenanceBP.setMemberDefaults(membership, member, member.getSolicitationCd());
		if(!setDefaults)
		{
			log.error ("MaintenanceBP:addMember - Failed in setting the member defaults");
			throw new Exception ("Unable to set up member defaults. Please contact the administrator.");
		}		 
		member.setParentMembership(membership);
		if (member.getMemberExpirationDt().compareTo(member.getParentMembership().getPrimaryMember().getMemberExpirationDt()) ==0) {
			member.setActiveExpirationDt(member.getParentMembership().getPrimaryMember().getActiveExpirationDt());
		}
		else {
			// split membership, just add a year
			member.setActiveExpirationDt(DateUtilities.timestampAdd(Calendar.YEAR, 1, member.getMemberExpirationDt()));
		}
		if (member.getCommissionCd() == null){
			member.setCommissionCd(membership.getPrimaryMember().getCommissionCd());
		}		
		member.setMemberTypeCd("A");		
		member.setRenewMethodCd(membership.getPrimaryMember().getRenewMethodCd());	
		member.setSendBillTo(StringUtils.nvl(membership.getSendBillTo(), "P"));
		member.setSendCardTo(StringUtils.nvl(membership.getSendCardTo(), "P"));
		member.setStatus("P");

		// sets up the riders
		Validator memberVal = membershipMaintenanceBP.costMembership(member.getSolicitationCd(), membership, false);
		if (!memberVal.isValid()){
			log.error ("MaintenanceBP:addMember - Failed in costing the membership " + memberVal.getMessage());
			throw new Exception ("Unable to price the membership. " + memberVal.getMessage());
		}

		for (Rider r : member.getRiderList()){
			r.setSecondaryAgentId(r.getAgentId());
			r.setAgentId(salesAgentId);
		}

		_TransactionDt = DateUtilities.getTimestamp(false);
		setUpPaymentSummary();
		boolean postZeroDollarPayment = true;
		//requesting card for new member.
		member.requestCard(Member.DCREAS_NEWMEMBER);
		updateMembershipTypeCd();

		// TR 3573 KK 12/06/2010 When member is added on salvage membership, add with Future Cancel Dt
		if(membership.isFutureCancel())
		{
			member.setFutureCancelDt(membership.getFutureCancelDt());
			member.setFutureCancelFl("Y");
			// TR 3574 - KK - 01/06/2011
			if(membership.getPrimaryMember().isDoNotRenew())
			{
				member.setDoNotRenewFl("Y");
			}
			// Add member on DNR Membership
			// TR 3574 - KK - 01/06/2011
			for(Rider rider : member.getRiderList())
			{
				rider.setFutureCancelDt(member.getFutureCancelDt());
				rider.setCancelReasonCd(membership.getPrimaryMember().getBasicRider().getCancelReasonCd());
				rider.setDispersalMethodCd(membership.getPrimaryMember().getBasicRider().getDispersalMethodCd());
				// TR 3574 - KK - 01/06/2011
				if(member.isDoNotRenew())
				{
					rider.setDoNotRenewFl("Y");
				}
				// Add member on DNR Membership
				// TR 3574 - KK - 01/06/2011
			}
		}
		for (Rider r:membership.getPrimaryMember().getRiderList()) {
			if (r.getAttribute("INCREASE") != null) {
				r.setDuesAdjustmentAt(r.getDuesAdjustmentAt().add((BigDecimal)r.getAttribute("INCREASE")));						
				r.setStatus("P");
				r.setStatusDt(new Timestamp(System.currentTimeMillis()));
				r.getParentMember().setStatus("P");
				r.getParentMember().setStatusDt(new Timestamp(System.currentTimeMillis()));						
			}
		}
		PaymentPosterBP bp = PaymentPosterBP.instance(user);
		membership.addComment(comment.toString() + "\nAssociate " + member.getAssociateId() + "-" + member.getFullName(false) + " added by Primary on " + DateUtilities.formattedDateMMDDYYYY(DateUtilities.today()) ); 
		membership.save();
		
		if (postZeroDollarPayment){
			if(ClubProperties.isTransactionDateEnabled(membership.getDivisionKy(), membership.getRegionCode())){
				if (!bp.postZeroDollarPayment(membership, "AddMember-Associate-" + member.getAssociateId(), "MM", user.getAttributeAsBigDecimal("BRANCH_KY"), "Y", "A",
						null, _TransactionDt)){
					throw new Exception("Unable to post a $0 payment. Please contact the administrator.");

				}
			}
			else{
				if (!bp.postZeroDollarPayment(membership, "AddMember-Associate-" + member.getAssociateId(), "MM", user.getAttributeAsBigDecimal("BRANCH_KY"), "Y", "A",
						null)){
					throw new Exception("Unable to post a $0 payment. Please contact the administrator.");
				}
			}

		}
		membership = new Membership(user, membership.getMembershipKy(), true);
		for (Member m: membership.getMemberList()) {
			if (m.getMemberKy().compareTo(member.getMemberKy())==0) {
				member = m;
				break;
			}
		}	
		return member;
	}

	/**
	 * Adds new member to an existing membership
	 * @param member
	 * @param marketCd
	 * @return member
	 * @throws SQLException 
	 * @throws Exception
	 */
	//LTV add member fix
	public Member addMember(Membership membership, Member member, String marketCd, User mUser, String agentId, boolean... webMember) throws Exception
	{
		this.membership = membership;
		this.member = member;
		this.user = mUser;
		this.salesAgentId =agentId;		

		StringBuffer comment = new StringBuffer(200);
		comment.append("Add Member Service: ");
		
		boolean enforceAssocateAgeLimit = "Y".equals(ClubProperties.getString("EnforceAssociateAgeLimit", membership.getDivisionKy(), membership.getRegionCode()));

		if (enforceAssocateAgeLimit){
			//We have to have the birth date entered and the relationship cd entered in order
			//for the following code to be valid so if they are not required make them required and error out
			int assocAgeLimit = 21; //set default
			assocAgeLimit = ClubProperties.getInt("AssociateAgeLimit", membership.getDivisionKy(), membership.getRegionCode());
			if (!"SPOUSE".equals(member.getAssociateRelationCd()) && !"SELF".equals(member.getAssociateRelationCd())){
				if (member.getBirthDt() != null){
					// if day of year after today's day of year just subtract years
					// else subtract years -1
					Calendar calBirthDt = Calendar.getInstance();
					calBirthDt.setTimeInMillis(member.getBirthDt().getTime());
					Calendar todayMinusLimit = Calendar.getInstance();
					todayMinusLimit.add(Calendar.YEAR, -assocAgeLimit);
					if (calBirthDt.before(todayMinusLimit)){
						throw new Exception ( "Associates must be under the age of " + assocAgeLimit + " unless they are the spouse.");
					}
				}
			}
		}
		if (ClubProperties.emailIsWebUsername(membership.getDivisionKy(),membership.getRegionCode())) {
			if ((member.isNew() || member.isColumnUpdated(Member.EMAIL)) && member.getEmail() != null && !"".equals(member.getEmail())){
				ArrayList<SearchCondition> nameCriteria = new ArrayList<SearchCondition>();
				nameCriteria.add(new SearchCondition(Member.EMAIL, SearchCondition.EQ, member.getEmail()));
				for (Member m:Member.getMemberList(user, nameCriteria, null)) {
					if (m.getMemberKy().compareTo(member.getMemberKy())!=0)
						throw new Exception ( "Email already in use please provide a different email");
				}
			}
		}
		if ("".equals(member.getBirthDt()) && Member.JUNIOR_MEMBER_TYPE.equals(member.getMemberTypeCd())){
			Timestamp bdayTS = member.getBirthDt();
			Validator bDayValidator = MemberAction.validateJuniorBirthDate(v, "BIRTH_DT", bdayTS, membership.getDivisionKy(), membership.getRegionCode());
			if (!bDayValidator.isValid("BIRTH_DT")){
				throw new Exception ( bDayValidator.getErrorMsg("BIRTH_DT"));
			}
		}
		Solicitation	solicitation	= null;
		
		if(StringUtils.blanknull(marketCd).equals("")){
			marketCd = null;
		}	
		
		if (marketCd != null){
			try{
				solicitation = Solicitation.getSolicitation(this.user, marketCd);
			}
			catch (Exception e)
			{
				log.error ("MaintenanceBP:addMember - Invalid market code. Please try again");
				throw new Exception (marketCd + " is not valid. Please use a different code.");
			}
		}
		String billingCategory = null;
		//LTV fix  rule 1. there is no market code (default) or Market code is 'INTD'
        //                 LTV tier and specialty member  use primary basic rider's billing category, else '0042'
		//         rule 2. default billing category from solicitation;
		if ( webMember !=null && webMember.length > 0 && webMember[0] == true)
		{
			
			
			//in case solicitation from webmember is not null and NOT 'INTD' , get billing category from solicitation 
			if( marketCd != null && !marketCd.equals("") && !marketCd.equals("INTD"))
			{
				try
				{						
					
					if( solicitation == null)
					{
						billingCategory = "0042";
					}
					else
					{
						billingCategory = solicitation.getBillingCategoryCd();
					}
				}
				
				catch(Exception ex)
				{
					billingCategory = "0042";
				}
				
				
			}
			//in case solicitation from webmember is null force billing category to 0042  invalid after 4/1/2019
			//rule 1: there is no market code (default) or Market code is 'INTD'
            //                 LTV tier and specialty member  use primary basic rider's billing category, else '0042'
			else
			{
				//if it is LTV tier or specialty
				if( membership.isOnTier() || membership.isSpecialtyMembership())
				{
					billingCategory = membership.getPrimaryMember().getBasicRider().getBillingCategoryCd();
				}
				else
				{
					billingCategory = "0042";
				}
			}
				
			
		}
		member.setBillingCategoryCd(billingCategory);
		if (solicitation != null ) {			
			//member.setBillingCategoryCd(solicitation.getBillingCategoryCd());
			member.setSolicitationCd(solicitation.getSolicitationCd());
		}
		else
		{
			//member.setBillingCategoryCd(membership.getBillingCategoryCd());
			member.setSolicitationCd(membership.getPrimaryMember().getSolicitationCd());						
		}
		
		MembershipMaintenanceBP membershipMaintenanceBP = (MembershipMaintenanceBP) BPF.get(this.user, MembershipMaintenanceBP.class);

		//call this to set the assoc id/check digit and other default settings
		boolean setDefaults = membershipMaintenanceBP.setMemberDefaults(membership, member, member.getSolicitationCd());
		if(!setDefaults)
		{
			log.error ("MaintenanceBP:addMember - Failed in setting the member defaults");
			throw new Exception ("Unable to set up member defaults. Please contact the administrator.");
		}		 
		member.setParentMembership(membership);
		if (member.getMemberExpirationDt().compareTo(member.getParentMembership().getPrimaryMember().getMemberExpirationDt()) ==0) {
			member.setActiveExpirationDt(member.getParentMembership().getPrimaryMember().getActiveExpirationDt());
		}
		else {
			// split membership, just add a year
			member.setActiveExpirationDt(DateUtilities.timestampAdd(Calendar.YEAR, 1, member.getMemberExpirationDt()));
		}
		if (member.getCommissionCd() == null){
			member.setCommissionCd(membership.getPrimaryMember().getCommissionCd());
		}		
		member.setMemberTypeCd("A");		
		member.setRenewMethodCd(membership.getPrimaryMember().getRenewMethodCd());	
		member.setSendBillTo(StringUtils.nvl(membership.getSendBillTo(), "P"));
		member.setSendCardTo(StringUtils.nvl(membership.getSendCardTo(), "P"));
		member.setStatus("P");

		// sets up the riders
		Validator memberVal = membershipMaintenanceBP.costMembership(member.getSolicitationCd(), membership, false, webMember);
		if (!memberVal.isValid()){
			log.error ("MaintenanceBP:addMember - Failed in costing the membership " + memberVal.getMessage());
			throw new Exception ("Unable to price the membership. " + memberVal.getMessage());
		}

		for (Rider r : member.getRiderList()){
			r.setSecondaryAgentId(r.getAgentId());
			r.setAgentId(salesAgentId);
		}

		_TransactionDt = DateUtilities.getTimestamp(false);
		setUpPaymentSummary();
		boolean postZeroDollarPayment = true;
		//requesting card for new member.
		member.requestCard(Member.DCREAS_NEWMEMBER);
		updateMembershipTypeCd();

		// TR 3573 KK 12/06/2010 When member is added on salvage membership, add with Future Cancel Dt
		if(membership.isFutureCancel())
		{
			member.setFutureCancelDt(membership.getFutureCancelDt());
			member.setFutureCancelFl("Y");
			// TR 3574 - KK - 01/06/2011
			if(membership.getPrimaryMember().isDoNotRenew())
			{
				member.setDoNotRenewFl("Y");
			}
			// Add member on DNR Membership
			// TR 3574 - KK - 01/06/2011
			for(Rider rider : member.getRiderList())
			{
				rider.setFutureCancelDt(member.getFutureCancelDt());
				rider.setCancelReasonCd(membership.getPrimaryMember().getBasicRider().getCancelReasonCd());
				rider.setDispersalMethodCd(membership.getPrimaryMember().getBasicRider().getDispersalMethodCd());
				// TR 3574 - KK - 01/06/2011
				if(member.isDoNotRenew())
				{
					rider.setDoNotRenewFl("Y");
				}
				// Add member on DNR Membership
				// TR 3574 - KK - 01/06/2011
			}
		}
		for (Rider r:membership.getPrimaryMember().getRiderList()) {
			if (r.getAttribute("INCREASE") != null) {
				r.setDuesAdjustmentAt(r.getDuesAdjustmentAt().add((BigDecimal)r.getAttribute("INCREASE")));						
				r.setStatus("P");
				r.setStatusDt(new Timestamp(System.currentTimeMillis()));
				r.getParentMember().setStatus("P");
				r.getParentMember().setStatusDt(new Timestamp(System.currentTimeMillis()));						
			}
		}
		PaymentPosterBP bp = PaymentPosterBP.instance(user);
		membership.addComment(comment.toString() + "\nAssociate " + member.getAssociateId() + "-" + member.getFullName(false) + " added by Primary on " + DateUtilities.formattedDateMMDDYYYY(DateUtilities.today()) ); 
		membership.save();
		
		if (postZeroDollarPayment){
			if(ClubProperties.isTransactionDateEnabled(membership.getDivisionKy(), membership.getRegionCode())){
				if (!bp.postZeroDollarPayment(membership, "AddMember-Associate-" + member.getAssociateId(), "MM", user.getAttributeAsBigDecimal("BRANCH_KY"), "Y", "A",
						null, _TransactionDt)){
					throw new Exception("Unable to post a $0 payment. Please contact the administrator.");

				}
			}
			else{
				if (!bp.postZeroDollarPayment(membership, "AddMember-Associate-" + member.getAssociateId(), "MM", user.getAttributeAsBigDecimal("BRANCH_KY"), "Y", "A",
						null)){
					throw new Exception("Unable to post a $0 payment. Please contact the administrator.");
				}
			}

		}
		membership = new Membership(user, membership.getMembershipKy(), true);
		for (Member m: membership.getMemberList()) {
			if (m.getMemberKy().compareTo(member.getMemberKy())==0) {
				member = m;
				break;
			}
		}	
		return member;
	}
	
	
	/**
	 * Sets up a payment summary record for the balance 
	 * adjustment of adding the member to the membership. 
	 * The payment summary is not saved here. It will be saved when the 
	 * membership is saved. 
	 */
	private void setUpPaymentSummary() throws Exception{
		try{
			PaymentSummary ps = new PaymentSummary(user, null, false);
			ps.setParentMembership(membership);
			BigDecimal duesAt = BigDecimal.ZERO;
			for (Rider r:member.getRiderList()) {
				if (r.isPending()) 
					duesAt = duesAt.add(r.getDuesCostAt()).add(r.getDuesAdjustmentAt()).subtract(r.getPaymentAt());
			}
			for (MembershipFees f: member.getMembershipFeesList()) {
				if (f.isPending() && !f.isWaived())
					duesAt = duesAt.add(f.getFeeAt()).subtract(f.getFeeAppliedAt());
			}
			// TR 2936 - payment_at on payment summary wasn't working for Virginia memberships
			for (Rider r:membership.getPrimaryMember().getRiderList()) {
				if (member.getAttribute("AddUpdateMemberBean.repricedRider"+r.getRiderKy()) != null) {
					duesAt = duesAt.add(((BigDecimal)member.getAttribute("AddUpdateMemberBean.repricedRider"+r.getRiderKy())));
				}
			}
			ps.setPaymentAt(duesAt);
			ps.setPaymentMethodCd("6");
			if (Member.JUNIOR_MEMBER_TYPE.equals(member.getMemberTypeCd())){
				ps.setTransactionTypeCd("P");
			}
			else{
				ps.setTransactionTypeCd("A");
			}
			ps.setBatchName("AddMember-Associate-" + member.getAssociateId());
			ps.setAdjustmentDescriptionCd("42");
			ps.setCreateDt(DateUtilities.getTimeStamp(false));
			ps.setPaymentDt(_TransactionDt);
			ps.setMembershipKy(membership.getMembershipKy());
			ps.setSourceCd("MM");
			ps.setPaidByCd("P");
			ps.setUnappliedAt(BigDecimal.ZERO);
			ps.setAdvancePayAt(BigDecimal.ZERO);
			ps.setBranchKy(((MemberzPlusUser) user).getBranchKy());

		}
		catch (Exception e){
			log.error ("MaintenanceBP:setUpPaymentSummary - Unable to create PaymentSummary " + e);
			throw new Exception ("Unable to create a Payment Summary record. " + e.getMessage());
		
		}
	}


	private String getBatchHeaderPrefix(String username) throws Exception
	{		
		Element root = getConfiguration(localConfig, this.getUser()).getRootElement();
		String strPrefix = "";
		for (Element appType : (List<Element>) root.element("apps").elements("app")){
			if (appType.attributeValue("user").trim().equalsIgnoreCase(username))
			{	
				strPrefix = appType.element("prefix").getTextTrim();
				return strPrefix;
			}
		}
		if ( strPrefix.equalsIgnoreCase("")) {
			for (Element sourceType : (List<Element>) root.element("apps").elements("source")){
				if (sourceType.attributeValue("name").trim().equalsIgnoreCase("WS")) {
					//default prefix value
					strPrefix = sourceType.element("prefix").getTextTrim();
					return strPrefix;
				}
			}
		}
		
		if ( strPrefix.equalsIgnoreCase(""))
		{
			throw new Exception ("Cannot find valid batch header prefix in Maintenance.xml config file based on user name.");
		}
		return strPrefix;
		
		
	}

	private void updateMembershipTypeCd() throws SQLException{
		//TR 5459 - KK - 02/03/2011
		//Adding Members to DNR memberships for Virginia.
		//int count = membership.getCurrentMemberList().size();
		int count = 0;
		if(membership.getPrimaryMember().isDoNotRenew())
		{
			for (Member m : membership.getMemberList())
			{
				if (!"C".equals(m.getStatus()))
				{
					count++;
				}
			}
		}
		else 
		{
			count = membership.getCurrentMemberList().size();
		}
		//Cancelled or DNR memberships were considered as SGL by default
		//Rider Cost does not exist for SGL, changes were made to not count DNR as SGL
		//Changes ends TR 5459 - KK - 02/03/2011
		CancelBP cBP = BPF.get(user, CancelBP.class);
		String msTypeCd = cBP.findMembershipTypeCd(membership, count);
		membership.setMembershipTypeCd(msTypeCd);

		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		criteria.add(new SearchCondition(CoverageLevel.COVERAGE_LEVEL_CD, SearchCondition.EQ, membership.getCoverageLevelCd()));
		criteria.add(new SearchCondition(CoverageLevel.MEMBERSHIP_TYPE_CD, SearchCondition.EQ, msTypeCd));
		SortedSet<CoverageLevel> set = CoverageLevel.getCoverageLevelList(user, criteria, null);

		membership.setCoverageLevelKy(set.first().getCoverageLevelKy()); //
	}


	public SimpleMembership getMembershipOverview(Membership ms) throws Exception
	{
		SimpleMembership simpleMembership = new SimpleMembership();

		simpleMembership.setCoverageLevel(membershipUtilBP.getCoverageByMZPType(ms.getCoverageLevelCd()));
		simpleMembership.setDonor(null);

		ArrayList<Code> webAvailableMembershipOptions = MembershipUtilBP.getInstance().getWebMembershipCodeOption(user);
		
		SortedSet<MembershipCode> mbsCodesList = ms.getMembershipCodeList();
		if (mbsCodesList !=null && mbsCodesList.size() > 0)
		{
			for(MembershipCode code :  mbsCodesList)
			{
				
				if(code.getCode().equals("DNDM"))
					simpleMembership.setDoNotDirectMailSolicit(true);
				else if(code.getCode().equals("DNE"))
					simpleMembership.setDoNotEmail(true);
				else if(code.getCode().equals("DNTM"))
					simpleMembership.setDoNotTelemarket(true);
				else if(code.getCode().equals("DSP"))
					simpleMembership.setDoNotSendPublication(true);
				else if (code.getCode().equals("90")) {
					simpleMembership.setDoNotOfferPlus(true);
				}
				 
			}
		}
		
		MembershipUtilBP.getInstance().setMembershipOptionforOverview(webAvailableMembershipOptions, mbsCodesList, simpleMembership);
		
		BigDecimal branchKy = ms.getBranchKy();
		
		Branch b = new Branch(user, branchKy);
		String regionCd = b.getRegionCd();
		String clubRegionCd = b.getSubCompanyCd();
		
		String divisionCd = b.getParentDivision().getDivisionCd();
		BigDecimal divisionKy = b.getParentDivision().getDivisionKy();
		
		Member primaryMbr = ms.getPrimaryMember();
		simpleMembership.setMarketCode(primaryMbr.getSolicitationCd());

		SimplePrimaryMember pm = new SimplePrimaryMember();
		Address address  = new Address();
		address.setAddressLine1(ms.getAddressLine1());
		address.setAddressLine2(ms.getAddressLine2());
		address.setCity(ms.getCity());
		address.setState(ms.getState());
		address.setZipCode(ms.getZip());
		pm.setAddress(address);
		pm.setAssociateType(membershipUtilBP.getAssociateTypeByMZPType(primaryMbr.getMemberTypeCd()));
		pm.setAssociateTypeMZPValue(primaryMbr.getMemberTypeCd());
		pm.setCustomerId(primaryMbr.getCustomerId() == null ? null : primaryMbr.getCustomerId().toString() );
		pm.setStatusMZPValue(primaryMbr.getStatus());
		pm.setDateOfBirth( handle100YearOldDob(DateUtilities.asString(primaryMbr.getBirthDt()) ) );
		pm.setJoinAAADate(DateUtilities.asString(primaryMbr.getJoinAaaDt()));
		pm.setJoinAAAYears(getJoinAAAYear(primaryMbr.getJoinAaaDt()));
		pm.setMemberExpirationDate(DateUtilities.asString(primaryMbr.getMemberExpirationDt()));
		pm.setRenewMethodCd(primaryMbr.getRenewMethodCd());
		if (primaryMbr.getCredentialKy() !=null ){
			pm.setCredentialKy(primaryMbr.getCredentialKy().toString());
		}
		
		pm.setEmail(primaryMbr.getEmail());
		pm.setGender(membershipUtilBP.getGenderByMZPType(primaryMbr.getGender()));
		try
		{
			int gradYear;
			gradYear = Integer.parseInt(primaryMbr.getGraduationYr());
			pm.setGraduationYear(gradYear);
		}
		catch (Exception ignore){}
		Name nm = new Name();
		nm.setFirstName(primaryMbr.getFirstName());
		nm.setLastName(primaryMbr.getLastName());
		nm.setMiddleName(primaryMbr.getMiddleName());
		nm.setSuffix(membershipUtilBP.getSuffixByMZPType(primaryMbr.getNameSuffix()));
		nm.setSuffixMZPValue(primaryMbr.getNameSuffix());
		nm.setTitle(membershipUtilBP.getSalutationByMZPType(primaryMbr.getSalutation()));
		nm.setTitleMZPValue(primaryMbr.getSalutation());
		
		pm.setName(nm);
		
		//TODO employee membership flag
		simpleMembership.setIsEmployee(false);
		
		if (membershipUtilBP.isCancelledBefore18Month(ms)){
			simpleMembership.setCanceled18Months(true);
		}

		//[KO] Data inconsistency has been found to cause issues here
		//**** Build phone list based on all sources, add to response if any are found
		ArrayList<Phone> phoneList = new ArrayList<Phone>();
		Phone ph = new Phone();
		
		if(!StringUtils.blanknull(ms.getPhone()).equals("")) {			
			ph.setPhoneNumber(ms.getPhone());
			ph.setPhoneTypeCode(membershipUtilBP.getPhoneTypeByMZPType("PC"));//explicitly set to Primary
			ph.setIsPrimary(true);
			phoneList.add(ph);//add membership phone
		}
				
		for (OtherPhone phone : ms.getOtherPhoneList()) {
			ph = new Phone(); 
			ph.setPhoneNumber(phone.getPhone());
			ph.setExtension(phone.getExtension());
			ph.setPhoneTypeCode( membershipUtilBP.getPhoneTypeByMZPType(phone.getPhoneType()) );
			phoneList.add(ph);//add other phone
		}
		
		//add only if we have anything to add
		if(phoneList.size() > 0){
			Phone[] phList =  phoneList.toArray(new Phone[phoneList.size()]);
			pm.setPhones(phList);
		}
		
		pm.setRelation(membershipUtilBP.getRelationByMZPType(primaryMbr.getAssociateRelationCd()));
		
		ArrayList<Code> webAvailableOptions = MembershipUtilBP.getInstance().getWebMemberCodeOption(user);
		
		SortedSet<MemberCode> mbrCodesList = primaryMbr.getMemberCodeList();
		
		if (mbrCodesList !=null && mbrCodesList.size() > 0)
		{
			for(MemberCode code :  mbrCodesList)
			{				
				if(code.getCode().equals("DNAE"))
					pm.setDoNotAskForEmail(true);
				else if(code.getCode().equals("DNE"))
					pm.setDoNotEmail(true);
				else if(code.getCode().equals("DNC"))
					pm.setDoNotCall(true);
				else if(code.getCode().equals("DNM"))
					pm.setDoNotMail(true);
				 
			}
		}
		
		
		//do it again in the collection defined by Simple Member 
		MembershipUtilBP.getInstance().setMemberOptionforOverview(webAvailableOptions, mbrCodesList, pm);
		
		pm.setDoNotRenewFl(primaryMbr.getDoNotRenewFl());
		
		Rider pmbsRider = primaryMbr.getBasicRider();
		simpleMembership.setPaidBy(pmbsRider.getPaidByCd());
		
		simpleMembership.setPrimaryMember(pm);

		ArrayList<SimpleAssociateMember> associateList = new ArrayList<SimpleAssociateMember>();
		
		for (Member associateMbr:ms.getMemberList()){
			if(associateMbr.isPrimary()) continue;
			SimpleAssociateMember sam = new SimpleAssociateMember();			
			sam.setAssociateType(membershipUtilBP.getAssociateTypeByMZPType(associateMbr.getMemberTypeCd()));
			sam.setAssociateTypeMZPValue(associateMbr.getMemberTypeCd());
			if(associateMbr.getCustomerId() != null)
			{
			  sam.setCustomerId(associateMbr.getCustomerId().toString() );
			}
			sam.setDateOfBirth(handle100YearOldDob(DateUtilities.asString(associateMbr.getBirthDt()) ) );
			sam.setJoinAAADate(DateUtilities.asString(associateMbr.getJoinAaaDt()));
			sam.setJoinAAAYears(getJoinAAAYear(associateMbr.getJoinAaaDt()));
			sam.setMemberExpirationDate(DateUtilities.asString(associateMbr.getMemberExpirationDt()));
			sam.setStatusMZPValue(associateMbr.getStatus());
			sam.setEmail(associateMbr.getEmail());
			if (associateMbr.getCredentialKy() !=null ){
				sam.setCredentialKy(associateMbr.getCredentialKy().toString());	
			}
			
			sam.setRenewMethodCd(associateMbr.getRenewMethodCd());
			
			sam.setGender(membershipUtilBP.getGenderByMZPType(associateMbr.getGender()));
			try
			{
				int gradYear;
				gradYear = Integer.parseInt(associateMbr.getGraduationYr());
				sam.setGraduationYear(gradYear);
			}
			catch (Exception ignore){}
			Name name = new Name();
			name.setFirstName(associateMbr.getFirstName());
			name.setLastName(associateMbr.getLastName());
			name.setMiddleName(associateMbr.getMiddleName());
			name.setSuffix(membershipUtilBP.getSuffixByMZPType(associateMbr.getNameSuffix()));
			name.setSuffixMZPValue(associateMbr.getNameSuffix());
			name.setTitle(membershipUtilBP.getSalutationByMZPType(associateMbr.getSalutation()));
			name.setTitleMZPValue(associateMbr.getSalutation());
			sam.setName(name);
			SimpleMembershipNumber mbrshipNumber = new SimpleMembershipNumber();
			mbrshipNumber.setNumber(associateMbr.getMembershipId());
			mbrshipNumber.setAssociateId(associateMbr.getAssociateId());
			sam.setNumber(mbrshipNumber);
			sam.setRelation(membershipUtilBP.getRelationByMZPType(associateMbr.getAssociateRelationCd()));
			
			sam.setDoNotRenewFl(associateMbr.getDoNotRenewFl());

			SortedSet<MemberCode> assocMbrCodesList = associateMbr.getMemberCodeList();
			if (assocMbrCodesList !=null && assocMbrCodesList.size() > 0)
			{
				for(MemberCode code :  assocMbrCodesList)
				{				
					if(code.getCode().equals("DNAE"))
						sam.setDoNotAskForEmail(true);
					else if(code.getCode().equals("DNE"))
						sam.setDoNotEmail(true);
					else if(code.getCode().equals("DNC"))
						sam.setDoNotCall(true);
					else if(code.getCode().equals("DNM"))
						sam.setDoNotMail(true);
					 
				}
			}
			
			MembershipUtilBP.getInstance().setMemberOptionforOverview(webAvailableOptions, assocMbrCodesList, sam);
			
			associateList.add(sam);
		} //END of associate Member only  
		
		SimpleAssociateMember[] assocList =  associateList.toArray(new SimpleAssociateMember[associateList.size()]);
		simpleMembership.setAssociates(assocList);
		//set the membership number for each of the members
		simpleMembership = membershipUtilBP.setMembershipNumForReturn(simpleMembership, ms);				
		simpleMembership = membershipUtilBP.setStatusForReturn(simpleMembership, ms);				
		
		simpleMembership.setRenewalMethod(membershipUtilBP.getRenewalTypeByMZPType(ms.getPrimaryMember().getRenewMethodCd()));
		simpleMembership.setMembershipExpiration(DateUtilities.asString(ms.getPrimaryMember().getMemberExpirationDt(),"MM/dd/yyyy"));
		simpleMembership.setOutOfTerritoryFlag(membershipUtilBP.getOOTByMZPType(ms.getOutOfTerritoryCd()));
		String billCatDesc = DropDownUtil.getCodeValue("BILTYP", nvl(ms.getBillingCategoryCd(),""));
		if (billCatDesc != null && !"".equals(billCatDesc) ){
			simpleMembership.setBillingCategory(ms.getBillingCategoryCd() + "-" + billCatDesc);
			simpleMembership.setBillingCategoryCode(ms.getBillingCategoryCd()); 
			simpleMembership.setBillingCategoryDesc(billCatDesc); 
		}
		simpleMembership.setInRenewal(ms.getPrimaryMember().inRenewal() && "RM".equals(ms.getBillingCd()));
		simpleMembership.setHeavyERSUser(ms.isHeavyERSUser());
		simpleMembership.setSalvage(ms.isSalvage());
		simpleMembership.setFutureCancel(ms.isFutureCancel());
		simpleMembership.setDoNotRenew(getDoNotRenew(ms));
		simpleMembership.setOtherPhoneFlag(ms.isOtherPhone());
		simpleMembership.setBadAddressFlag(ms.isBadAddress());
		 
		//TODO - military membership flag
		MembershipAffiliationBP abp = (MembershipAffiliationBP) BPF.get(this.user, MembershipAffiliationBP.class);
		simpleMembership.setMilitaryFlag(abp.isMilitaryMembership(ms));
		
		simpleMembership.setType(membershipUtilBP.getMembershipTypeByMZPType(ms.getMembershipTypeCd()));
		simpleMembership.setMembershipTypeCode(ms.getMembershipTypeCd()); 
		
		simpleMembership.setDonorType(membershipUtilBP.getDonorTypeByMZPType(getDonorType(ms)));
		simpleMembership.setCommissionCode(membershipUtilBP.getCommissionCodeByMZPType(ms.getPrimaryMember().getBasicRider().getCommissionCd()));
		simpleMembership.setIsEnrolledInEbilling(ms.isEbill());
		
		simpleMembership.setCoverageLevelMZPValue(ms.getCoverageLevelCd());
		simpleMembership.setStatusMZPValue(ms.getStatus());
		simpleMembership.setDivision(getDivisionName(ms.getDivisionKy()));
		simpleMembership.setDivisionCd(divisionCd);
		simpleMembership.setDivisionKy(divisionKy.toString());
		simpleMembership.setClubRegionCd(clubRegionCd);
		simpleMembership.setRegionCd(regionCd);
		
		if (ms.getTierKy()!=null) {
			simpleMembership.setIsOnTier(true);
		}
	
		return simpleMembership;
	}



	/**
	 * Add payments to payment batch for the given Membership enroll membership if batch payment is required
	 * only required for Check, Credit Card, and Discount
	 * 
	 * Pre-req:  membership has been saved and membership ID has been generated.
	 * @param simpleMembership
	 */
	public boolean addPayments(PaymentParameters paymentParams,  Membership membership, BigDecimal amountDue, SalesAgent sa, String salesAgentBranchCd, String paymentSourceCd ){

		boolean paymentSuccessful = true;
		boolean batchPaymentRequired = false;
		BatchHeader paymentBatch=null;
		String dsPaymentOptionCd="";
		String membershipId="";
		

		if(paymentParams == null)
			return false;

		String paymentDescription="";  //for logging purposes

		try {
			
			if(paymentParams!=null)
			{
				if(paymentParams.getCard()!=null)
				{
					dsPaymentOptionCd = "C";
				} else if(paymentParams.getCheck()!=null){
					dsPaymentOptionCd = "K";
				}
			}			 
			membershipId = membership.getMembershipId();

		} catch (SQLException e1) {
			//nothing
		}
		batchPaymentRequired= "K".equalsIgnoreCase(dsPaymentOptionCd)|| "C".equalsIgnoreCase(dsPaymentOptionCd);	/* if check or credit card then batch payment required. if neither then a balance will show and membership will be pending*/

		if (batchPaymentRequired)
		{
			/*--------------------------*/
			//*inspect payment option cd


			//if B (Bill me) then no payment, just save membership and member will get a bill
			//if C (credit card) then add credit card payment and charge the card 
			//are there any discount records?  if so add them
			//add batch payment

			try {

				String strHeaderPrfix = "";
				String batchName = "";
				if( sa!= null){
					/*create the batch*/
					strHeaderPrfix = getBatchHeaderPrefix(sa.getAgentId());
					batchName= strHeaderPrfix +"_"+ membership.getMembershipId();
					paymentBatch = createPaymentBatch(sa.getBranchKy(), batchName);
				}
				else
				{
					/*create the batch*/
					batchName = salesAgentBranchCd + DateUtilities.getFormattedDate(DateUtilities.today(), "MMddyy") + membershipId;
					paymentBatch=createPaymentBatch(membership.getBranchKy(),batchName);	
				}
											
				paymentBatch.setExpCt(1);
				BatchPayment payment = new BatchPayment(this.user, null, false);		/*create the payment to be added to the batch*/
				payment.setMembershipKy(membership.getMembershipKy());
				payment.setMembershipId(membershipId);
				payment.setParentBatchHeader(paymentBatch);				
				payment.setPaidByCd("P");					/*primary*/
				payment.setAdjustmentDescriptionCd("00");
				payment.setReasonCd("00");
				if( sa!=null)
				{
					payment.setPaymentSourceCd(strHeaderPrfix);
				}
				else
				{
					payment.setPaymentSourceCd("DS");  			//see code type PAYSRC
				}
				payment.setTransactionTypeCd("P");
				payment.setCreateDt(new Timestamp(System.currentTimeMillis()));

				if ("C".equalsIgnoreCase(dsPaymentOptionCd))		/*if credit card*/		
				{
					payment.setPaymentMethodCd("3");				/*credit card*/

					payment.setPaymentAt(amountDue);	/*calculated total*/
					paymentBatch.setExpAt(amountDue);

					/*add card info*/				

					if (!"".equals(paymentParams.getCard().getExpirationDate()))
					{
						String ccExpirationMonth=paymentParams.getCard().getExpirationDate().substring(0, 2);
						String ccExpirationYear="20" + paymentParams.getCard().getExpirationDate().substring(2);		/*TODO:make more robust*/			
						try {
							payment.setCcExpirationDt(DateUtilities.getTimestamp(ccExpirationMonth+ccExpirationYear, "MMyyyy"));
						} catch (ParseException e) {
							//bad expiration date
						}
					}				
					payment.setCcCity(membership.getCity());
					payment.setCcFirstName(membership.getPrimaryMember().getFirstName());
					payment.setCcLastName(membership.getPrimaryMember().getLastName());				
					payment.setCcToken(paymentParams.getCard().getTokenNumber());
					payment.setCcTypeCd(paymentParams.getCard().getCardTypeCode());
					payment.setCcNumber(paymentParams.getCard().getAccountNumber());
					/*end add card info*/
					paymentDescription="Credit Card";

				} else {
					//CHECK - YH - 12/4/2015
					payment.setPaymentMethodCd("16");				/*ECheck*/

					/*calculated total*/
					payment.setPaymentAt(amountDue);				
					paymentBatch.setExpAt(amountDue);
					
					payment.setAchBankAccountNumber(paymentParams.getCheck().getCheckBankAccountNumber());   
					payment.setAchBankRoutingNumber(paymentParams.getCheck().getCheckABANumber());
					payment.setAchToken(paymentParams.getCheck().getCheckTokenNumber());
					payment.setAchAuthorizationNr(nvl(paymentParams.getCheck().getAuthorizationNumber()));
					
					if (paymentSourceCd!=null && !paymentSourceCd.trim().equals("")){
						payment.setPaymentSourceCd(paymentSourceCd);
					} else {
						payment.setPaymentSourceCd("ME");
					}
					payment.setTransactionTypeCd("P");
					payment.setPaidByCd("P");
					payment.setCheckNr(paymentParams.getCheck().getCheckCheckNumber());
					
					payment.setCcFirstName(membership.getPrimaryMember().getFirstName());
					payment.setCcLastName(membership.getPrimaryMember().getLastName());
					payment.setCcStreet(membership.getAddressLine1());
					payment.setCcZip(membership.getZip());
					
					payment.setAchBankAccountType("CHK");
					payment.setAchBankAccountName(membership.getPrimaryMember().getFirstName() + " " + membership.getPrimaryMember().getLastName());
										
					paymentDescription="ECheck";
					
				}
				paymentBatch.addBatchPayment(payment);					/*add payment to batch*/
				
				if ("C".equalsIgnoreCase(dsPaymentOptionCd) && 
						(paymentParams.getCard().getTokenNumber() == null || paymentParams.getCard().getTokenNumber().equals(""))
						&& paymentParams.getCard().getAccountNumber() !=null)		/*if credit card*/		
				{
					updateBatch(membership, paymentBatch, paymentParams);  // to tokenize the card.
				}
				
				if("C".equalsIgnoreCase(dsPaymentOptionCd))
				{
					paymentParams.getCard().setAccountNumber(payment.getCcLastFour());
				}

				/*TR 2772 redux: 3/24/2010: PBC.  the check for success no longer worked as expected so CC transactions looked like they passed when they were really rejected*/
				/*don't do this any more: if (postPaymentBatch(paymentBatch))*/		/*the boolean returned is no longer correct after a change in payment poster in Late Feb early March 2010*/
				postPaymentBatch(paymentBatch);													/*ignoring the boolean returned since it now does not mean what is needed here*/
				paymentBatch.clearBatchPaymentList();
				
				String achToken = "";
				for (BatchPayment p: paymentBatch.getBatchPaymentList(true)){			/*only one payment per batch expected*/		
					if ("K".equalsIgnoreCase(dsPaymentOptionCd)) {
						achToken = p.getAchToken();
						p.setAchBankAccountNumber("");
						p.setAchBankRoutingNumber("");
					}
					
					String rejectCode="";
					String rejectDescription="";
					rejectCode=StringUtils.nvl(p.getReasonCd());
					rejectDescription=StringUtils.nvl(p.getErrorText());
					if(p.isCcReject())
					{
						paymentSuccessful = false;
					}
					if (p.isPostCompleted()&& p.isCcReject())							/*must now check both of these flags to determine if cc failed.*/
					{	/*TR2772*/														/*payment was rejected or failed*/												
						for(Member m: membership.getMemberList()){								/*need to also set renew method on membership back to billing.*/
							m.setRenewMethodCd("B");				
						}
						membership.addComment("AAA File Membership: " + membership.getMembershipId() + " " + paymentDescription + " failed. Reject:" + rejectCode + " Descripion: "
								+ rejectDescription);

					}
					else if(p.isPostCompleted())
					{		/*payment was success*/
						log.debug("MembershipEnrollBP::addPayments -" + membership.getMembershipId() +   ": Payment by " + paymentDescription + " Succeeded." );
					}
					else{
						log.debug(("MembershipEnrollBP::addPayments -" +membership.getMembershipId() +   ": Payment by " + paymentDescription + " failed to complete.  Descripion: " + rejectDescription + ". Membership still processed but is pending."));
					}
					p.save();
				}
				
				for (PaymentSummary ps: paymentBatch.getPaymentSummaryList()){
					ps.setAchToken(achToken);
					ps.setAchBankAccountNumber("");
					ps.setAchBankRoutingNumber("");
					ps.save();
				}
				
			} catch (Exception e) {

				log.error("MembershipEnrollBP::addPayments -"  + membershipId + " Failed to add batch payment: " + StackTraceUtil.getStackTrace(e));	
			}
		}
		return paymentSuccessful;


	}

	/**
	 * Create a new batch by given name or default if no name is passed.
	 * For branch key passed.
	 * 
	 * @throws Exception
	 */
	private BatchHeader createPaymentBatch(BigDecimal branchKy, String batchName) throws Exception{
		BatchHeader paymentBatch = new BatchHeader(this.user, (BigDecimal) null, false);
		paymentBatch.setBranchKy(branchKy);
		paymentBatch.setUserId(this.user.userID);
		paymentBatch.setBatchReadyFl(false);
		paymentBatch.setBatchTypeCd("MB");
		paymentBatch.setSourceCd("MBL");
		paymentBatch.setTransactionDt(DateUtilities.getTimestamp(true));
		paymentBatch.setExpAt(BigDecimal.ZERO);
		paymentBatch.setExpCt(BigDecimal.ZERO);		
		paymentBatch.setBatchName(batchName);
		return paymentBatch;		
	}
	
	private String getDonorType(Membership mbrs) throws SQLException
	{
		Rider bsRider = mbrs.getPrimaryMember().getBasicRider();
		if ("D".equals(bsRider.getPaidByCd())){
			Donor d = bsRider.getParentDonor();
			if (d != null){
				return d.getDonorTypeCd();	
			}			
		}
		
		return "";
	}
	
	public boolean getDoNotRenew(Membership mbrs) throws SQLException
	{
		for(Member m : mbrs.getMemberList()){
			if(m.isCancelled()) continue;
			if(m.isDoNotRenew()){
				return true;
			}
			
			for(Rider r : m.getRiderList()){
				if(r.isCancelled()) continue;
				if(r.isDoNotRenew()){
					return true;
				}
			}
		}		
		return false;
	}
	
	private String getDivisionName(BigDecimal divisionKy)
	{
		String divisionName = "";
		
		if(divisionKy == null)
			return divisionName;
		
		try {
			Division div = new Division(this.user, divisionKy, true);
			divisionName = div.getDivisionName();
		} catch (SQLException e) {
			log.error("Error getting Division name", e);
		} catch (ObjectNotFoundException e) {
			log.error("Division not found for division key: " + divisionKy, e);
		}

		return divisionName;
	}

	/**
	 * Update the batch.  Tokenizes credit card information if necessary.
	 * Removes autorenewal flag from payments if renew method code is not
	 * ADVANTAGE RENEWAL (A).
	 * 
	 * copied from ME
	 * 
	 * @throws Exception
	 */
	private void updateBatch(Membership membership, BatchHeader paymentBatch, PaymentParameters paymentParams) throws Exception {

		paymentBatch.setBatchReadyFl(true);
		SortedSet<BatchPayment> fullPaymentList = paymentBatch.getBatchPaymentList();
		String size = Integer.toString(fullPaymentList.size());
		paymentBatch.setExpCt(new BigDecimal(size));
		BigDecimal total = BigDecimal.ZERO;
		CreditCardProcessorBP ccbp = (CreditCardProcessorBP) BPF.get(this.user, CreditCardProcessorBP.class);
		for (BatchPayment payment : fullPaymentList) {
			total = total.add(payment.getPaymentAt());
			if (payment.getMembershipKy().compareTo(membership.getMembershipKy()) == 0) {
				// for payments that apply to this membership
				if (!"A".equals(membership.getPrimaryMember().getRenewMethodCd())) {
					// if we had previously set as autorenewal card
					payment.setAutoRenewFl(false);
				}
				if (ccbp.usesToken() && (payment.getCcToken() == null || payment.getCcToken().equals(""))) {
					String decryptedCard = ConxonsSecurity.instance().decrypt(paymentParams.getCard().getAccountNumber());
					Timestamp ccExpirationDt = payment.getCcExpirationDt();
					String ccExpMo = DateUtilities.getFormattedDate(ccExpirationDt, "MM");
					String ccExpYr = DateUtilities.getFormattedDate(ccExpirationDt, "yy");
					payment.setCcNumber(ccbp.getCreditCardNumber(decryptedCard));
					payment.setCcToken(ccbp.getCreditCardToken(null, decryptedCard, ccExpMo, ccExpYr, payment.getCcTypeCd()));
				}
			}
		}
		paymentBatch.setExpAt(total);	
		paymentBatch.save();
	}

	/**
	 * Post the batch and log any issues
	 * @return
	 * @throws SQLException
	 */
	public  boolean postPaymentBatch(BatchHeader paymentBatch) {		
		boolean posted=false;
		try {
			paymentBatch.setBatchReadyFl(true);
			paymentBatch.save();
			posted=paymentBatch.postBatch();
		} catch (SQLException e) {
			log.error(e.getStackTrace());
		}
		return posted;		 
	}

	/*
	 * This is a clone copy from buildAutorenewalCard. 
	 * For the new enroll operation we want to use the correct credit card information to create the autorenewal card. 
	 * The old one is used by enroll/applyPayment/makePayment and the member's name and address information is used in current production for mobile app etc. 
	 * To minimize the testing time and risk, I created this new function and called it from the enroll operation. Later when we get a chance we can do the 
	 * switch inside applyPayment and makePayment.
	 */  
	public AutorenewalCard buildAutorenewalCardEnroll(Membership membership, PaymentParameters paymentParams, Object req) throws IllegalArgumentException {
		request = req;
		return buildAutorenewalCard(membership, paymentParams);
		
	}
	
	//
	public AutorenewalCard buildAutorenewalCardForDonorEnroll(Membership membership, PaymentParameters paymentParams, Donor donor) throws IllegalArgumentException {
		if(paymentParams == null || paymentParams.getCard() == null || paymentParams.getCard().getTokenNumber() == null || paymentParams.getCard().getTokenNumber().equals(""))
			throw new IllegalArgumentException("Card Token Number is required.");
		
		if("".equals(paymentParams.getCard().getExpirationDate())) throw new IllegalArgumentException("Card Expiration Date is required."); 
		
		String cardFirstName = "";
		String cardLastName = "";
		String cardStreet ="";
		String cardCity = "";
		String cardState = "";
		String cardZip = "";
		
		AutorenewalCard card =null;
		String simpleMembershipId="";
		try {
			simpleMembershipId=membership.getMembershipId();
		} catch (SQLException e1) {
			//nothing
		}
		try{
			card = new AutorenewalCard(this.user, null, false);

			cardFirstName = donor.getFirstName();
			cardLastName = donor.getLastName();
		
			CreditCard cd = paymentParams.getCard();
			cardStreet = cd.getCardHolderStreetAddress();
			cardCity = "";
			cardState = "";
			cardZip = cd.getCardHolderZipCode();
		
			card.setCcFirstName(cardFirstName);
			card.setCcLastName(cardLastName);
			card.setCcStreet(cardStreet);
			card.setCcCity(cardCity);
			card.setCcState(cardState);
			card.setCcZip(cardZip);
			
			String accountNumber = paymentParams.getCard().getAccountNumber();
			String lastFour= getLastFourDigits(accountNumber);
			
			card.setCcTypeCd(paymentParams.getCard().getCardTypeCode());
			card.setCcNumber(null);
			card.setCcLastFour(lastFour);
			card.setCcToken(paymentParams.getCard().getTokenNumber());		
			card.setCcExpirationDt(DateUtilities.getTimestamp(paymentParams.getCard().getExpirationDate().trim(), "MMyy"));
			
			//to handle the debit card or credit card type - [yh - 2018-04-13]
			String creditDebitCode = paymentParams.getCard().getCreditDebitCode();
			
			if (creditDebitCode!=null && !creditDebitCode.trim().equalsIgnoreCase("")) {
				if (creditDebitCode.trim().equalsIgnoreCase("C") || creditDebitCode.trim().equalsIgnoreCase("D")) {
					card.setCreditDebitType(creditDebitCode.trim().toUpperCase());
				}
			}
			
			card.setStatus("A");
			card.setStatusDt(new Timestamp(System.currentTimeMillis()));

			for (Member m: membership.getMemberList()) {
				if (!m.getStatus().equalsIgnoreCase("C")) {
					m.setRenewMethodCd("A");
					m.setSendBillTo("D");
					m.setSendCardTo("D");
					
					for (com.rossgroupinc.memberz.model.Rider r: m.getRiderList()) {
						if (!r.getStatus().equalsIgnoreCase("C")) {
							r.setAutorenewalCardKy(card.getAutorenewalCardKy());
							r.setDonorNr(donor.getDonorNr());
							r.setDonorRenewalCd("P");
							r.setPaidByCd("D");
						}
					}
				}
			}
			
			card.setDonorNr(donor.getDonorNr());
			
			log.debug("buildAutorenewalCard - " + simpleMembershipId + ": Autorenewal Card Added");
			//}
		}catch (Exception e){

			log.error("buildAutorenewalCard - "  + simpleMembershipId + " Failed to add batch payment: " + StackTraceUtil.getStackTrace(e));	

		}
		return card;	
		
	}
	
	/**
	 * Build an autorenewal card if we have autorenewal information that is not
	 * the same as one of the payments. If card is built add it to list to be saved
	 * with membership. 
	 * 
	 * copied from PaymentBean.java and edited
	 * 
	 */
	public AutorenewalCard buildAutorenewalCard(Membership membership, PaymentParameters paymentParams) throws IllegalArgumentException {
		
		if(paymentParams == null || paymentParams.getCard() == null || paymentParams.getCard().getTokenNumber() == null || paymentParams.getCard().getTokenNumber().equals(""))
			throw new IllegalArgumentException("Card Token Number is required.");
		
		if("".equals(paymentParams.getCard().getExpirationDate())) throw new IllegalArgumentException("Card Expiration Date is required."); 
		
		String cardFirstName = "";
		String cardLastName = "";
		String cardStreet ="";
		String cardCity = "";
		String cardState = "";
		String cardZip = "";
		
		AutorenewalCard card =null;
		String simpleMembershipId="";
		try {
			simpleMembershipId=membership.getMembershipId();
		} catch (SQLException e1) {
			//nothing
		}
		try{
			card = new AutorenewalCard(this.user, null, false);
			Member primaryMember = membership.getPrimaryMember();

			cardFirstName = primaryMember.getFirstName();
			cardLastName = primaryMember.getLastName();
			
			if (membership.getAddressLine1().equalsIgnoreCase(paymentParams.getCard().getCardHolderStreetAddress())) {
				cardStreet = membership.getAddressLine1();
				cardCity = membership.getCity();
				cardState = membership.getState();
				cardZip = membership.getZip();
			} else {
				cardStreet = paymentParams.getCard().getCardHolderStreetAddress();
				cardCity = "";
				cardState = "";
				cardZip = paymentParams.getCard().getCardHolderZipCode();
			}
			
			if (request!=null && (request instanceof MembershipEnrollRequest) ){
				MembershipEnrollRequest enrollReq = (MembershipEnrollRequest) request;
				if (enrollReq.isDonorMembership() && enrollReq.getDonor()!=null) {
					cardFirstName = enrollReq.getDonor().getFirstName().toUpperCase();
					cardLastName = enrollReq.getDonor().getLastName().toUpperCase();
					
					if (enrollReq.getDonor().getAddress1().equalsIgnoreCase(paymentParams.getCard().getCardHolderStreetAddress())) {
						cardStreet = enrollReq.getDonor().getAddress1().toUpperCase();
						cardCity = enrollReq.getDonor().getCity().toUpperCase();
						cardState = enrollReq.getDonor().getState().toUpperCase();
						cardZip = enrollReq.getDonor().getZip();
					} else {
						cardStreet = paymentParams.getCard().getCardHolderStreetAddress();
						cardCity = "";
						cardState = "";
						cardZip = paymentParams.getCard().getCardHolderZipCode();
					}
				}
			}
			
			card.setCcFirstName(cardFirstName);
			card.setCcLastName(cardLastName);
			card.setCcStreet(cardStreet);
			card.setCcCity(cardCity);
			card.setCcState(cardState);
			card.setCcZip(cardZip);
			
			String accountNumber = paymentParams.getCard().getAccountNumber();
			String lastFour= getLastFourDigits(accountNumber);
			
			card.setCcTypeCd(paymentParams.getCard().getCardTypeCode());
			card.setCcNumber(null);
			card.setCcLastFour(lastFour);
			card.setCcToken(paymentParams.getCard().getTokenNumber());		
			card.setCcExpirationDt(DateUtilities.getTimestamp(paymentParams.getCard().getExpirationDate().trim(), "MMyy"));
			
			//to handle the debit card or credit card type - [yh - 2018-04-13]
			String creditDebitCode = paymentParams.getCard().getCreditDebitCode();
			
			if (creditDebitCode!=null && !creditDebitCode.trim().equalsIgnoreCase("")) {
				if (creditDebitCode.trim().equalsIgnoreCase("C") || creditDebitCode.trim().equalsIgnoreCase("D")) {
					card.setCreditDebitType(creditDebitCode.trim().toUpperCase());
				}
			}
			
			card.setStatus("A");
			card.setStatusDt(new Timestamp(System.currentTimeMillis()));

			for (Member member : membership.getMemberList()){
				for (Rider rider : member.getRiderList()) {
					// since this autorenewal card is the primary's card only set the
					// member's who are paid by primary.
					if (primaryMember.getBasicRider().getPaidByCd().equals(rider.getPaidByCd())){
						rider.setAutorenewalCardKy(card.getAutorenewalCardKy());
						if (Rider.COVERAGE_CD_BASIC.equals(rider.getRiderCompCd())) {
							member.setRenewMethodCd(primaryMember.getRenewMethodCd());
						}
						if ("D".equals(rider.getPaidByCd())) {
							card.setDonorNr(rider.getDonorNr());
						}
					}					
				}
			}
			log.debug("buildAutorenewalCard - " + simpleMembershipId + ": Autorenewal Card Added");
			//}
		}catch (Exception e){

			log.error("buildAutorenewalCard - "  + simpleMembershipId + " Failed to add batch payment: " + StackTraceUtil.getStackTrace(e));	

		}
		return card;		
	}

	private String getLastFourDigits(String accountNumber) {
		if (accountNumber==null || accountNumber.length()<4){
			return "";
		} else {
			String lastFour = accountNumber.substring(accountNumber.length()-4);
			
			String regex = "\\d+";

			if (lastFour.matches(regex)) {
				return lastFour; 
			} else {
				CreditCardProcessorBP ccbp = (CreditCardProcessorBP) BPF.get(this.user, CreditCardProcessorBP.class);
				return ccbp.getLastFour(accountNumber);
			}
		}
	}

	public  PaymentParameters getAutoRenewalCard(Membership  membership){

		PaymentParameters paymentParams= null;
		String mbrshipId ="";
		try{
			mbrshipId= membership.getMembershipId();
			AutorenewalCard card = null;
			if (membership.getPrimaryMember().getBasicRider().getAutorenewalCardKy() != null &&
					!membership.getPrimaryMember().getBasicRider().getAutorenewalCardKy().equals("")){
				ArrayList<SearchCondition> cardCriteria = new ArrayList<SearchCondition>();
				cardCriteria.add(new SearchCondition(AutorenewalCard.AUTORENEWAL_CARD_KY, SearchCondition.EQ, membership.getPrimaryMember().getBasicRider().getAutorenewalCardKy()));
				SortedSet<AutorenewalCard> cardList = AutorenewalCard.getAutorenewalCardList(user, cardCriteria, null);
				if (!cardList.isEmpty()){
					card = cardList.first();
				}
			}
			if(card!=null)
			{
				paymentParams = new PaymentParameters();
				CreditCard cc = new CreditCard();
				cc.setAccountNumber(card.getCcLastFour());
				cc.setCardHolderFullName(card.getCcFirstName() + " " + card.getCcLastName());
				cc.setCardHolderStreetAddress(card.getCcStreet());
				cc.setCardHolderZipCode(card.getCcZip());
				cc.setCardTypeCode(card.getCcTypeCd());
				cc.setTokenNumber(card.getCcToken());
				
				if (card.getCreditDebitType()!=null) {
					if (card.getCreditDebitType().trim().equalsIgnoreCase("D") || card.getCreditDebitType().trim().equalsIgnoreCase("C")){
						cc.setCreditDebitCode(card.getCreditDebitType().trim());
					} else {
						cc.setCreditDebitCode((""));
					}
				} else {
					cc.setCreditDebitCode((""));
				}
				
				cc.setExpirationDate(DateUtilities.getFormattedDate(card.getCcExpirationDt(), "MMyyyy"));
				cc.setSaveAsAutoRenewalCard(true);				
				paymentParams.setCard(cc);
			}
		}
		catch (Exception e)
		{
			log.error("getAutoRenewalCard - "  + mbrshipId + " Failed to get Autorenewal card : " + StackTraceUtil.getStackTrace(e));	

		}
		return paymentParams;
	}

	public PaymentParameters getDonorAutoRenewalCard(Donor donor){

		PaymentParameters paymentParams= null;
		
		String donorNumber = "";
		
		if (donor == null  ) {
			return null;
		}
		
		try{
			AutorenewalCard card = null;
			
			donorNumber = donor.getDonorNr();
			
			for (AutorenewalCard ac: donor.getAutorenewalCardList()) {
				if (ac.getStatus().equalsIgnoreCase("A")) {
					card = ac;
					break; 
				}
			}
			
			if(card!=null)
			{
				paymentParams = new PaymentParameters();
				CreditCard cc = new CreditCard();
				cc.setAccountNumber(card.getCcLastFour());
				cc.setCardHolderFullName(card.getCcFirstName() + " " + card.getCcLastName());
				cc.setCardHolderStreetAddress(card.getCcStreet());
				cc.setCardHolderZipCode(card.getCcZip());
				cc.setCardTypeCode(card.getCcTypeCd());
				cc.setTokenNumber(card.getCcToken());
				
				if (card.getCreditDebitType()!=null) {
					if (card.getCreditDebitType().trim().equalsIgnoreCase("D") || card.getCreditDebitType().trim().equalsIgnoreCase("C")){
						cc.setCreditDebitCode(card.getCreditDebitType().trim());
					} else {
						cc.setCreditDebitCode((""));
					}
				} else {
					cc.setCreditDebitCode((""));
				}
				
				cc.setExpirationDate(DateUtilities.getFormattedDate(card.getCcExpirationDt(), "MMyyyy"));
				cc.setSaveAsAutoRenewalCard(true);				
				paymentParams.setCard(cc);
			}
		}
		catch (Exception e)
		{
			log.error("getAutoRenewalCard of Donor - "  + donorNumber + " Failed to get Autorenewal card : " + StackTraceUtil.getStackTrace(e));	

		}
		return paymentParams;
	}
	/**
	 * Gets an array of all the payment summaries attached to the membership passed into the method. 
	 * Converts the table codes into readable values. 
	 * 
	 * @param clubCode
	 * @param membershipKy
	 * @return
	 * @throws ObjectNotFoundException
	 * @throws SQLException
	 */
	public MembershipPaymentSummary[] getPaymentSummary( String membershipKy, String date) throws ObjectNotFoundException, SQLException, ParseException{
		Membership membership = new Membership(user, new BigDecimal(membershipKy));

		//return payment summaries within a certain time frame.
		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		if(date!=null)
		{
			criteria.add(new SearchCondition(PaymentSummary.PAYMENT_DT, SearchCondition.GT + SearchCondition.EQ, DateUtilities.getTimestamp(date,"MM/dd/yyyy")));
		}
		criteria.add(new SearchCondition(PaymentSummary.PAYMENT_AT,SearchCondition.GT,BigDecimal.ZERO));
		criteria.add(new SearchCondition(PaymentSummary.TRANSACTION_TYPE_CD,SearchCondition.EQ,"P"));
		criteria.add(new SearchCondition(PaymentSummary.REV_MEMBERSHIP_PAYMENT_KY,SearchCondition.ISNULL));

		// Do not show transfers, write offs, safety funds

		ArrayList<String> orderBy = new ArrayList<String>();
		orderBy.add(PaymentSummary.PAYMENT_DT +" DESC");
		SortedSet<PaymentSummary> set = membership.getPaymentSummaryList(criteria, orderBy);
		ArrayList<MembershipPaymentSummary> array = new ArrayList<MembershipPaymentSummary>();

		try{
			for (PaymentSummary payment : set){
				MembershipPaymentSummary paymentSumm = new MembershipPaymentSummary(payment);
				array.add(paymentSumm);
			}
		}
		catch (Exception e){
			log.error("Error in getPaymentSummary method.", e);
		}

		return array.toArray(new MembershipPaymentSummary[array.size()]);
	}
	


	/**
	 * Takes in required membership key and the associates to be cancelled on a membership.
	 * Calls the CancelBP  
	 */
	public Membership processMemberCancel(SimpleAssociateMember[] associatesToCancel, BigDecimal membershipKey, User mUser, String source) throws Exception
	{		
		this.user = mUser;
		Timestamp cancel_dt = null; 
		String cancelReason = "C2";
		
		StringBuffer comment = new StringBuffer(200);
		comment.append("Cancel Member Service: ");
		if(!"".equals(source))
		{
			comment.append("\nChanges made via ");
			comment.append(source);
			comment.append(".\n");
		}
		boolean memberCancelled = false;
		boolean riderCancelled = false;		
		Timestamp latestCancelDt =  DateUtilities.getTimestamp(true);
		int cancelledMembers=0;		
		Membership storedMembership = null;
		try{
			
			CancelBP bp = (CancelBP) BPF.get(user, CancelBP.class);
			storedMembership = bp.buildMembership(membershipKey);

			Member pm = storedMembership.getPrimaryMember();
			
			boolean salvageFl = storedMembership.getSalvageFl(); 
			
			//only 2 situations will be handled through web member, for pending membership in renewal
			//	1. before the current term expiration date, set it to member's expiration date; cancelReason -->do not renewal which is D2
			//	2. after or equal to expiration date, default to today ; cancelReason --> member request which is C2
			cancel_dt = DateUtilities.getTimestamp(true);
			
			if (cancel_dt.before(pm.getMemberExpirationDt()) && !salvageFl) {
				cancel_dt = pm.getMemberExpirationDt();
				cancelReason = "D2";
			}
			
			for(Member storedMember : storedMembership.getMemberList())
			{
				if (storedMember.isPrimary())
					continue;
				if(associatesToCancel !=null && associatesToCancel.length >0)
				{
					MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
					MembershipNumber mn =  null;
					for (SimpleAssociateMember sam:associatesToCancel){						
						try
						{
							mn =  mbp.parseFullMembershipNumber(sam.getNumber().getFullNumber());
						}
						catch (Exception e)
						{
							throw new  Exception("Membership ID is invalid. " + e.getMessage());
						}
						if(mn.getAssociateID().equals(storedMember.getAssociateId()) && 
								mn.getMembershipID().equals(storedMember.getMembershipId()))
						{
							if(!(storedMember.isCancelled()) )
							{
								//set attributes for cancelled members
								storedMember.setAttribute("CANCEL", Boolean.TRUE);
								storedMember.setAttribute("CANCEL_DT", cancel_dt);
								memberCancelled = true;
								String memberType = "Associate " + storedMember.getAssociateId() + "-" + storedMember.getFullName(false) + " cancelled by Primary on " + DateUtilities.formattedDateMMDDYYYY(DateUtilities.today()) + "; ";
								comment.append(memberType);
								cancelledMembers++;
							}
							for(Rider storedRider : storedMember.getRiderList())
							{
								if((!(storedRider.isCancelled())) || memberCancelled)
								{
									//set attributes for cancelled members
									//default cancel reason to member request
									//default dispersal method to pending
									storedRider.setAttribute("CANCEL", Boolean.TRUE);
									storedRider.setAttribute("CANCEL_DT", cancel_dt);
									storedRider.setAttribute("CANCEL_REASON_CD", cancelReason);
									storedRider.setAttribute("DISPERSAL_METHOD_CD", "P");
									 
									if(!memberCancelled && !riderCancelled)
									{
										String riderType = storedRider.getRiderCompCd() + " rider cancelled by Primary on " + DateUtilities.formattedDateMMDDYYYY(DateUtilities.today()) + "; ";
										comment.append(riderType);
										riderCancelled = true;
									}
								}	
							}
							memberCancelled = false;
							break;
						}
					}
				}

			}
			//Call cancel BP processCancels
			MembershipComment cmt = new MembershipComment(user, (BigDecimal) null, false);
			cmt.setParentMembership(storedMembership);
			cmt.setComments(comment.toString());
			cmt.setCreateDt(new Timestamp(System.currentTimeMillis()));
			cmt.setCreateUserId(user.userID);
			cmt.setCommentTypeCd(MembershipComment.TYPE_SYSTEM);
			storedMembership.addMembershipComment(cmt);
			
			/**
			 * TR5532: If you cancel an associate from a VA Family membeship (SGL, DBL, or FAM) via Webmember it does not adjust the dues correctly.
			 * Added logic to Reprice the non cancelled members and calculate the dues
			 */
		    int activeMembers = storedMembership.getMemberList().size() - cancelledMembers;
		    String msTypeCd = bp.findMembershipTypeCd(storedMembership, activeMembers);
		    if(msTypeCd.equalsIgnoreCase("DBL")|| msTypeCd.equalsIgnoreCase("SGL")||msTypeCd.equalsIgnoreCase("FAM"))
		    {
			   for(Rider rider: storedMembership.getPrimaryMember().getRiderList())
			   {
				
				    CostBP costBp = (CostBP) BPF.get(user, CostBP.class);
				    BigDecimal creditAt = BigDecimal.ZERO;
				    BigDecimal adjAt    = BigDecimal.ZERO;
					
					adjAt = rider.getDuesAdjustmentAt();
										
					BigDecimal priceDecreaseAt = costBp.recostPrimaryRiderOnCancellation(rider, activeMembers, latestCancelDt, null);
					creditAt = priceDecreaseAt;
					if (priceDecreaseAt.compareTo(BigDecimal.ZERO) != 0){
						adjAt=  priceDecreaseAt.negate();
					}					
					String creditStr = creditAt.toString();
					if(creditStr.isEmpty() || !bp.isRepriceNoncancelledRiders(storedMembership, activeMembers))
					{
						continue;
					}	
					rider.setAttribute("REPRICE", Boolean.TRUE);					
					rider.setAttribute("REPRICE_DT", latestCancelDt);
					rider.setAttribute("CREDIT_AT", new BigDecimal(creditStr));
					String adjStr = adjAt.toString();
					rider.setAttribute("REPRICE_NEW_ADJ_AT", new BigDecimal(adjStr));
	
					Timestamp today = new Timestamp(Calendar.getInstance().getTimeInMillis());
					//Prakash - 07/02/2018 - Dues By State - Start
					RiderCost rc = new RiderCost(User.getGenericUser(), rider.getRiderCompCd(), rider.getBillingCategoryCd(), 
							rider.getParentMember().getMemberTypeCd(), storedMembership.getRegionCode(), 
						    storedMembership.getDivisionKy(), storedMembership.getBranchKy(), rider.getCostEffectiveDt(), msTypeCd, storedMembership.getDuesState());
					//Prakash - 07/02/2018 - Dues By State - End
				    rider.setAttribute("ADM_ORIGINAL_COST_AT", rc.getRenewAt()); // to be saved on the rider in CancelBP
			  }
		    }
			Validator v = bp.processCancels(storedMembership);
			if(v.isValid()){
				storedMembership = new Membership(user, storedMembership.getMembershipKy());
			}
			else
			{
				log.error("processMemberCancel: Error occurred in processing cancellations in cancelAssociate  ");
				throw new Exception ("Unable to cancel the associate. " + storedMembership.getMembershipId());
			}
		}
		catch (Exception e){
			log.error("processMemberCancel: Error occurred in cancelAssociate ");
			log.error(StackTraceUtil.getStackTrace(e));
			throw new Exception ("Unable to cancel the associate. " + membershipKey); 
		}
		return storedMembership;
	}
	
	/**
	 * Takes credit card information and applies payment to membership.
	 * ONLY USES PASSED IN TOKEN.  DOES NOT CURRENTLY CHARGE CARD.
	 * 
	 * @param card Credit Card information
	 * @param paymentAmount The amount to charge the credit card
	 * @param membership
	 * @param sa Sales Agent
	 * @param isAutoRenew Should the payment AutoRenewFl be marked.
	 * @return
	 * @throws IllegalArgumentException
	 * @throws Exception
	 */
	public boolean applyCreditCardPayment(CreditCard card, BigDecimal paymentAmount, Membership membership, SalesAgent sa, boolean isAutoRenew) throws IllegalArgumentException, Exception
	{
		//fix, will based on sa agent decide if it comes from webmember or mobile
		/*String internetActivitySalesAgent = ClubProperties.getStringNvl("InternetActivity").trim();
		boolean isWebMember = false;
		if (!internetActivitySalesAgent.equalsIgnoreCase("") &&  sa.getAgentId()!=null && sa.getAgentId().trim().equalsIgnoreCase(internetActivitySalesAgent))
		{
			isWebMember = true;
		}*/
		//based on new conversation with Konny/YHu, batch header must be fully configurable
		//in case there is no agent ID, se
		String strHeaderPrfix = getBatchHeaderPrefix(sa.getAgentId()); 
		if (isInstallmentPlan){
			strHeaderPrfix = strHeaderPrfix + "_IP";
		}
		if(card == null) throw new IllegalArgumentException("Card can not be null.");
		if(paymentAmount == null) throw new IllegalArgumentException("Payment amount can not be null.");
		if(membership == null) throw new IllegalArgumentException("Membership can not be null.");
		if(sa == null) throw new IllegalArgumentException("Sales agent can not be null.");
		
		if(card.getTokenNumber() == null || card.getTokenNumber().trim().equals("")) throw new IllegalArgumentException("Card token number must be specified.");
		if(card.getAuthorizationNumber() == null || card.getAuthorizationNumber().trim().equals("")) throw new IllegalArgumentException("Card authorization number must be specified.");
		
		boolean paymentSuccessful = false;
		BatchHeader paymentBatch = null;
		String cardHolderFirstName = "";
		String cardHolderLastName = "";
		
		//get first and last names if present
		if(!"".equals(card.getCardHolderFullName()))
		{
			String[] names = card.getCardHolderFullName().split(" ");
			if(names.length >= 2)
			{
				cardHolderFirstName = names[0];
				cardHolderLastName = names[names.length -1]; //full name may have middle initial to get last element
			}
		}
		
		try
		{
			String batchName= strHeaderPrfix +"_"+ membership.getMembershipId();
			//if it is from webmember, change header prefix
			/*if( isWebMember)
			{
				batchName = "WB_" + membership.getMembershipId();
			}*/

			//Create and set Payment Batch
			paymentBatch = createPaymentBatch(sa.getBranchKy(),batchName);	
			paymentBatch.setExpCt(1);
			
			//Create and set batch payment
			BatchPayment payment = new BatchPayment(this.user, null, false);
			
			payment.setPaymentAt(paymentAmount);
			paymentBatch.setExpAt(paymentAmount);
			payment.setPaymentMethodCd("3"); /*credit card*/
			payment.setPaymentSourceCd(strHeaderPrfix);
			//if it is from webmember,
			/*if( isWebMember)
			{
				payment.setPaymentSourceCd("WB");
			}
			else
			{
				payment.setPaymentSourceCd("MB");	
			}*/
			
			payment.setCcTypeCd(card.getCardTypeCode());  
			payment.setAutoRenewFl(isAutoRenew);
			payment.setMembershipKy(membership.getMembershipKy());
			payment.setMembershipId(membership.getMembershipId());
			payment.setParentBatchHeader(paymentBatch);				
			payment.setPaidByCd("P");					/*primary*/
			payment.setAdjustmentDescriptionCd("00");
			payment.setReasonCd("00");				
			payment.setTransactionTypeCd("P");
			payment.setCreateDt(new Timestamp(System.currentTimeMillis()));						
			//payment.setCcCity("");
			payment.setCcStreet("".equals(card.getCardHolderStreetAddress()) ? null : card.getCardHolderStreetAddress());
			payment.setCcZip("".equals(card.getCardHolderZipCode()) ? null : card.getCardHolderZipCode());
			payment.setCcFirstName(cardHolderFirstName.equals("") ? membership.getPrimaryMember().getFirstName() : cardHolderFirstName);
			payment.setCcLastName(cardHolderLastName.equals("") ? membership.getPrimaryMember().getLastName() : cardHolderLastName);
			payment.setCcToken(card.getTokenNumber());
			
			String accountNumber = card.getAccountNumber(); 
			//payment.setCcLastFour(getLastFourDigits(accountNumber));
			
			payment.setCcAuthorizationNr(card.getAuthorizationNumber());		
			payment.setCcNumber(null); //Set to null because we have token
			payment.setCcLastFour(getLastFourDigits(accountNumber));
			
			if (!"".equals(card.getExpirationDate()))
			{
				String ccExpirationMonth = card.getExpirationDate().substring(0, 2);
				String ccExpirationYear = "20" + card.getExpirationDate().substring(2);			
				try {
					payment.setCcExpirationDt(DateUtilities.getTimestamp(ccExpirationMonth+ccExpirationYear, "MMyyyy"));
				} catch (ParseException e) {
					//bad expiration date
				}
			}				

			//Add payment to payment batch
			paymentBatch.addBatchPayment(payment);
			
			//Post payment batch
			if (isInstallmentPlan && ppKy !=null){ 
				paymentBatch.setBatchReadyFl(true);
				paymentBatch.save();
				PaymentPosterBP bp = (PaymentPosterBP) BPF.get(user, PaymentPosterBP.class);
				bp.postInstallmentBatch(paymentBatch.getBatchKy(), ppKy);
			} else {
				postPaymentBatch(paymentBatch);	
			}
			
			paymentBatch.clearBatchPaymentList();					
			for (BatchPayment p: paymentBatch.getBatchPaymentList(true)){			/*only one payment per batch expected*/																								
				if(p.isPostCompleted())
				{		
					log.debug("MaintenanceBP::applyCreditCardPayment -" + membership.getMembershipId() +   ": Payment by credit card succeeded." );
					paymentSuccessful = true;
				}
				else{
					log.debug(("MaintenanceBP::applyCreditCardPayment -" +membership.getMembershipId() +   ": Payment by credit card failed to complete.  Descripion: " + StringUtils.nvl(p.getErrorText())));
					paymentSuccessful = false;
				}

			}
		}
		catch(Exception e)
		{
			throw new Exception("Unable to apply credit card payment.", e);
		}
		
		return paymentSuccessful;
	}
	
	public boolean applyCreditCardPaymentIPProxy(CreditCard card, BigDecimal paymentAmount, Membership membership, SalesAgent sa, boolean isAutoRenew, String paymentPlanKy) throws IllegalArgumentException, Exception
	{
		isInstallmentPlan = true;
		ppKy = paymentPlanKy;
		return applyCreditCardPayment(card, paymentAmount, membership, sa, isAutoRenew) ;
	}
	
	private String handle100YearOldDob(String dob) {
		if (dob == null || dob.length()!= 10) {
			return null;
		}
		
		try {
			int year = Integer.parseInt(dob.substring(6));
			int currentyear = Calendar.getInstance().get(Calendar.YEAR);
			if (currentyear -year >100) {
				return null;
			} else {
				return dob;
			}
		} catch (Exception e) {
			return null;
		}
	}
	
	private String getJoinAAAYear(Timestamp joinAAADate) {
		Timestamp today = new Timestamp(DateUtils.today().getTime());
		String result = "Unknown"; 
		try {
			if (!today.before(joinAAADate)){
				int diffDays = (int)((today.getTime()- joinAAADate.getTime())/(24 *60 * 60 * 1000 ));
				int diffYears = diffDays / 365;
				if (diffYears == 0 ){
					result = "< 1 year";
				} else if (diffYears == 1 ){
					result = "1 year";
				} else {
					result = diffYears + " years";
				}
				
				//System.out.println(diffYears);	
			}
		} catch(Exception e) { 
			result = "Unknown";
		}
		
		return result;
	}

}
