/*
 ********************************************************************************
 * MODULE        :  DiscountBP.java
 * DESCRIPTION   :  Discount Business Process
 * 
 * Copyright (c) 2009-2010 Ross Group Inc - The source code for
 * this program is not published or otherwise divested of its trade secrets,
 * irrespective of what has been deposited with the U.S. Copyright office.
 * 
 * ********************************************************************************
 * Modification Log:
 * Date     | Developer     |Ticket#  |Description
 * ---------| --------------|---------|------------------------------------------
 * 03/08/10 | Al Moor       | PCR 26  | Rewrote to update instead of delete/insert
 * 03/09/10 | Al Moor       | TR 2762 | Set paid by on payment summary records
 * 04/04/10 | Al Moor       |         | Referral coupons
 * 04/13/10 | Al Moor       |         | Added removal of discounts
 * 05/08/10 | Al Moor       | TR 3070 | Don't remove (re)new only discounts.
 * 05/24/10 | Al Moor       |         | Got rid of "adjusted by $0.00" comments
 * 07/02/10 | Al Moor       | TR 3221 | Losing discount amounts on re-apply
 * 07/13/10 | Al Moor       | TR 3221 | Protect conversion discounts
 * 08/31/10 | Al Moor       | TR 3372 | Filtering canceled members from consideration
 * 09/01/10 | Al Moor       | TR 3384 | Fixed NPE in applyDiscounts
 * 09/01/10 | Al Moor       | TR 3372 | Missed a canceled member filter.
 * 11/03/10 | Karan Kapoor  | TR 3271 | Installment Plan was based on Basic Rider
  		    | 			    |         | Changes made to accept the plan if Basic 
  		    |			    |		  | Rider is already paid.
 *12/23/10  | Karan Kapoor  | TR 3433 | Updated to accept Payment Plan for specialty memberships  
 *05/04/11  | Karan Kapoor	| TR 5637 | Changed the logic for DNR memberships as now we can add members.		   
 *05/11/11	| Preethi C     | TR 5500 | Cannot add mbr when the solicitation code expires	   
 *08/01/2011| KK/PC         | TR 5666 | Reverting back the changes
 *08/02/2011| Karan/Preethi | TR 5666 | Added new changes for TR 5666
 *08/16/2011| Karan Kapoor  | TR 5666 | TR 5666 Rollback for 1.0.20.0
 *12/20/2011| YH/KK/PC      | TR DSC  | Discounts not getting carried forward from prior year issue 
 *10/30/2014| Pat Cotter    | 3.0.0.0 | Modified getDiscountPaymentSummaryRecords and disperseDiscounts to accommodate multiple discounts while on installment plan
 *********************************************************************************
 */
package com.rossgroupinc.memberz.bp.club;

import static com.rossgroupinc.memberz.constants.AdjustmentCodes.ADJ_DUES;
import static com.rossgroupinc.memberz.constants.PaymentMethod.PAYMTH_DISCOUNT;
import static java.math.BigDecimal.ZERO;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Attribute;
import org.dom4j.Document;
import org.dom4j.Element;

import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.bp.BusinessProcessException;
import com.rossgroupinc.conxons.dao.SimpleEditor;
import com.rossgroupinc.conxons.dao.SimpleVO;
import com.rossgroupinc.conxons.pool.ConnectionPool;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.errorhandling.ObjectNotFoundException;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.MemberzPlusUser;
import com.rossgroupinc.memberz.bp.cost.CostBP;
import com.rossgroupinc.memberz.bp.cost.CostData;
import com.rossgroupinc.memberz.bp.payment.PayableComponent;
import com.rossgroupinc.memberz.bp.payment.PaymentManagerBP;
import com.rossgroupinc.memberz.bp.payment.PaymentPosterBP;
import com.rossgroupinc.memberz.model.Discount;
import com.rossgroupinc.memberz.model.DiscountHistory;
import com.rossgroupinc.memberz.model.Discountable;
import com.rossgroupinc.memberz.model.DonationHistory;
import com.rossgroupinc.memberz.model.JournalEntry;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.MemberCode;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.MembershipComment;
import com.rossgroupinc.memberz.model.MembershipFees;
import com.rossgroupinc.memberz.model.PaymentDetail;
import com.rossgroupinc.memberz.model.PaymentHierarchy;
import com.rossgroupinc.memberz.model.PaymentPlan;
import com.rossgroupinc.memberz.model.PaymentSummary;
import com.rossgroupinc.memberz.model.PlanBilling;
import com.rossgroupinc.memberz.model.Rider;
import com.rossgroupinc.memberz.model.Solicitation;
import com.rossgroupinc.memberz.model.SolicitationDiscount;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.RGILoggerFactory;
import com.rossgroupinc.util.SearchCondition;

public class DiscountBP extends BusinessProcess {

	private static final long serialVersionUID = 3698813986836296547L;
	private static final String CONFIG_FILE = "memberz/club/Discount.xml";
	private static Document configuration;
	private static Logger log = LogManager.getLogger(DiscountBP.class.getName(), new RGILoggerFactory());;

	protected static String METHOD_NAME = "test-condition";
	protected static String RETURN_VALUE = "value";
	protected static String REGEXP_VALUE = "regexp";
	protected static String NEGATION = "not";
	protected static String OPERATION = "operation";
	protected static String PARAMETER = "parameter";
	protected static String OBJECT = "object";

	// DiscountCd,PaymentSummary list
	protected Map<String, PaymentSummary> paymentSummary = new HashMap<String, PaymentSummary>();

	protected Membership membership = null;
	
	protected Set<String> discountCodes = new HashSet<String>();
	protected SimpleVO priorDiscounts = null;

	/**
	 * Generic constructor.
	 * 
	 * @param usr
	 */
	public DiscountBP(User usr) {
		super();
		this.user = usr;
		configuration = getConfiguration(CONFIG_FILE, user);
	}

	/********************************************************************************
	 * APPLY METHODS *
	 ********************************************************************************/

	/**
	 * Apply any discounts which the membership qualifies for. Automatic
	 * discounts will be assigned. Any discounts based on solicitation code will
	 * be assigned using the appropriate solicitation code on the membership.
	 * 
	 * This is the primary call to reset discounts when the membership structure
	 * changes.
	 * 
	 * @param membership
	 * @return boolean
	 */
	public boolean applyDiscounts(Membership membership, boolean... inRenewals) {
		this.membership = membership;

		try {
			//12/20/2011| YH/KK/PC      | TR DSC  | Discounts not getting carried forward from prior year issue 
			/*
			 * PC: 12/13/17: Handling discount after renewal is only cause more issues as the bill is already sent out.
			 * The carry forward discounts are handled in Renewal package
			if(inRenewals !=null && inRenewals.length > 0 && inRenewals[0] == true)
			{
				//handle carried forward discounts during renewals
				return handleCarriedForwardDiscounts();
				
			}*/
			try
			{
				// Get all related payment summary records
				getDiscountPaymentSummaryRecords();
			}
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in getDiscountPaymentSummaryRecords . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// Remove discounts that are in memory but not yet persisted
				removeUnpersistedDiscounts();
			}
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in removeUnpersistedDiscounts . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// Tag the membership discounts for comparison later
				saveExistingDiscounts();
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in saveExistingDiscounts . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// assign the automatic discounts
				assignAutomatics();
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in assignAutomatics . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// assign discounts based on market code on the membership objects.
				assignDiscountFromSolicitation();
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in assignDiscountFromSolicitation . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// Membership now has all high-level discounts assigned, now
				// disperse them across the riders/fees
				disperseDiscounts(membership); 
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in disperseDiscounts . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				//System.err.println(membership.debugDataObject())
				priorDiscounts = priorDiscounts();
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in priorDiscounts . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			try
			{
				// Now that we've reset all the discounts, generate comments
				// and maintain the payment summaries
				recordDiscountChanges();
			}			
			catch (Exception ex)
			{
				log.error("Failed while applying discounts because of exception in recordDiscountChanges . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				throw ex;
			}
			// Create the journal entries
			try
			{
			   addJournalEntries();
			}
			catch(Exception ex)
			{
				log.error("Failed while applying discounts because Journal entries are out of balance . Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
				log.error(StackTraceUtil.getStackTrace(ex));
				
			}
			
			//handle unused discounts
			return true;
		} catch (Exception e) {
			log.error("Unable to assign any discounts.");
			log.error(StackTraceUtil.getStackTrace(e));
		}
		return false;

	}
	//Apply renewal discounts if the membership, member and rider is in renewal
	public void applyDiscountWithMarketCodes(String membershipID, String solicitationCode) throws Exception {
		boolean autoRenewalReqFl = false;
		if (solicitationCode != null){
			Membership membership = new Membership(user, membershipID);
			Solicitation solicitation = Solicitation.getSolicitation(user, solicitationCode.toUpperCase());
			autoRenewalReqFl = solicitation.getAutoRenewalRequiredFl();
			
			if (solicitation != null  ) {	
				boolean inRenewal = false;
				
				Member pm = membership.getPrimaryMember();
				if (membership.isPending()){
					inRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
					inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
				}		
				
				if (inRenewal ||autoRenewalReqFl) {
					for (Member m: membership.getMemberList()) {
						if(m.getStatus().equalsIgnoreCase("P") && ( autoRenewalReqFl || m.inRenewal() ) ){
						    m.setSolicitationCd(solicitation.getSolicitationCd());		
						    if (autoRenewalReqFl) {
						    	m.setRenewMethodCd("A");
						    }
						    m.save();
						    for(Rider r: m.getRiderList())
						    {
						    	if(r.getStatus().equalsIgnoreCase("P") &&  (autoRenewalReqFl ||
						    			!( r.getBillingCd().equalsIgnoreCase("NM") || r.getBillingCd().equalsIgnoreCase("UM")))) {	
						    		r.setSolicitationCd(solicitation.getSolicitationCd());
						    		r.save();
						    	}
						    }	
						}
					}
					membership.save();

					DiscountBP dbp = BPF.get(user, DiscountBP.class); 
					dbp.applyDiscounts(membership);	
					membership.save();	
					for (Member m: membership.getMemberList()) {
						if(m.getStatus().equalsIgnoreCase("P") &&(autoRenewalReqFl || m.inRenewal()) 
								&&(m.getSolicitationCd() == null || m.getSolicitationCd().equalsIgnoreCase(solicitation.getSolicitationCd()))) {	
						    m.setSolicitationCd(null);		
						    m.save();
						    for(Rider r: m.getRiderList())
						    {
						    	if(r.getStatus().equalsIgnoreCase("P") &&  (autoRenewalReqFl ||
						    			!( r.getBillingCd().equalsIgnoreCase("NM") || r.getBillingCd().equalsIgnoreCase("UM")))
						    			&& (r.getSolicitationCd() == null || r.getSolicitationCd().equalsIgnoreCase(solicitation.getSolicitationCd()))) {	
						    		r.setSolicitationCd(null);
						    		r.save();
						    	}
						    }	
						}
					}
					membership.addComment(solicitationCode + " code applied for membership.");
					
					membership.save();
					
					PaymentPosterBP pmtBP = BPF.get(user,PaymentPosterBP.class);
					pmtBP.postZeroDollarPayment(membership,"Billing_0_Dollar","BL",((MemberzPlusUser)user).getBranchKy(),"Y","A",null);
					
					membership.save();
				}
			}
		}
	}
	//Get renewal discount amount if the membership, member and rider is in renewal
	public BigDecimal getDiscountAmountForMarketCode(String membershipID, String solicitationCode) throws Exception {
		BigDecimal discountAmt = ZERO;
		boolean autoRenewalReqFl = false;
		String origRenewalMethodCd = "";
		try
		{			
		    if (solicitationCode != null){
			this.membership = new Membership(user, membershipID);
			Solicitation solicitation = Solicitation.getSolicitation(user, solicitationCode.toUpperCase());
			autoRenewalReqFl = solicitation.getAutoRenewalRequiredFl();
			
			if (solicitation != null  ) {	
				boolean inRenewal = false;
				
				Member pm = membership.getPrimaryMember();
				if (membership.isPending()){
					inRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
					inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
				}		
				//set the solicitation code to calculate discount
				if (inRenewal || autoRenewalReqFl) {
					for (Member m: membership.getMemberList()) {
						if(m.getStatus().equalsIgnoreCase("P") && (autoRenewalReqFl || m.inRenewal())) { 
						    m.setSolicitationCd(solicitation.getSolicitationCd());	
						    if (autoRenewalReqFl) {
						    	origRenewalMethodCd = m.getRenewMethodCd();
						    	m.setRenewMethodCd("A");
						    }
						    m.save();
						    for(Rider r: m.getRiderList())
						    {
						    	if(r.getStatus().equalsIgnoreCase("P") && (autoRenewalReqFl ||
						    			!( r.getBillingCd().equalsIgnoreCase("NM") || r.getBillingCd().equalsIgnoreCase("UM")))) {	
						    		r.setSolicitationCd(solicitation.getSolicitationCd());
						    		r.save();
						    	}
						    }	
						}
					}
					membership.save();
					//Copied logic from applydiscounts method
					// Get all related payment summary records
					getDiscountPaymentSummaryRecords();
					// Remove discounts that are in memory but not yet persisted
					removeUnpersistedDiscounts();
					// Tag the membership discounts for comparison later
					saveExistingDiscounts();
					// assign discounts based on market code on the membership objects.
					assignDiscountFromSolicitation();
					// Membership now has all high-level discounts assigned, now
					// disperse them across the riders/fees
					disperseDiscounts(membership); 
					//To avoid same discount applied back to back on the same day while make payment,
					//we have to consider discounts applied on the same day too
					priorDiscounts = priorOrSameDayDiscounts();
					//calculate discount amount 					
					discountAmt = calculateDiscountWithoutRecording(solicitation);		
					
				}
			}
		  }  //end of if
		}
	   catch (Exception ex)
	   {
		log.error("Failed while calculating discounts because of exception. Membership id = " + membership.getMembershipId().toString() + ex.getMessage());
		log.error(StackTraceUtil.getStackTrace(ex));
		throw ex;
	    }
		finally
		{
			//get the saved membership again ; without the discount histroy
			this.membership = new Membership(user, membershipID);
			//reset the solicitation code back to null 
			for (Member m: membership.getMemberList()) {
				if(m.getStatus().equalsIgnoreCase("P") && (autoRenewalReqFl || m.inRenewal() )
						&&(m.getSolicitationCd() == null || m.getSolicitationCd().equalsIgnoreCase(solicitationCode))) {	
				    m.setSolicitationCd(null);		
				    if (autoRenewalReqFl) {
				    	m.setRenewMethodCd(origRenewalMethodCd);
				    }
				    m.save();
				    for(Rider r: m.getRiderList())
				    {
				    	if(r.getStatus().equalsIgnoreCase("P") &&   (autoRenewalReqFl || 
				    			!( r.getBillingCd().equalsIgnoreCase("NM") || r.getBillingCd().equalsIgnoreCase("UM")))
				    			&& (r.getSolicitationCd() == null || r.getSolicitationCd().equalsIgnoreCase(solicitationCode)) ) {	
				    		r.setSolicitationCd(null);
				    		r.save();
				    	}
				    }	
				}
			}
			membership.save();
			
			
		}
		return discountAmt;
	}
	
	/*
	 * This method is used to move all the carried forward distributed discounts at renewals to be 
	 * consolidated and move to a new parent with new cost effective date
	 */
	//12/20/2011| YH/KK/PC      | TR DSC  | Discounts not getting carried forward from prior year issue 
	public boolean handleCarriedForwardDiscounts() throws SQLException, ObjectNotFoundException, Exception{


		boolean usedInPriorTerm = false;
		boolean processCarryForwardDH = false;
		boolean handlePriorTermDhCase = false;
		BigDecimal carriedForwardAmt = ZERO;
		BigDecimal parentCurrentAmt =  ZERO;
		BigDecimal discountKey = ZERO;
		String discountCd = "";
		String discountPaymentMethodCd = "";
		HashMap<BigDecimal, DiscountHistory> dhParentMap= new HashMap<BigDecimal, DiscountHistory>();
		List<DiscountHistory> dhRemovalList = new ArrayList<DiscountHistory>();
		List<PaymentDetail> pdRemovalList = new ArrayList<PaymentDetail>();
		List<PaymentSummary> psRemovalList = new ArrayList<PaymentSummary>();
		List<JournalEntry> jeRemovalList = new ArrayList<JournalEntry>();
		List<DiscountHistory> dhParentSaveList = new ArrayList<DiscountHistory>();
		
		/*
		 * Get the child discount histories added by Renewal with Applied at renewal flag = Y
		 * Get the parent of those and add it to dhParentMap.
		 */
		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		ArrayList<BigDecimal> memberKeys = new ArrayList<BigDecimal>();
		ArrayList<BigDecimal> riderKeys = new ArrayList<BigDecimal>();
		for (Member m : membership.getMemberList()){
			memberKeys.add(m.getMemberKy());
			for (Rider r : m.getRiderList())
			{
				riderKeys.add(r.getRiderKy());
			}
		}
		criteria.add(new SearchCondition(DiscountHistory.MEMBER_KY, SearchCondition.IN, memberKeys));
		criteria.add(new SearchCondition("OR" , DiscountHistory.RIDER_KY, SearchCondition.IN, riderKeys));
		SortedSet<DiscountHistory> dhList = DiscountHistory.getDiscountHistoryList(user, criteria, null);
		for (DiscountHistory dhChild : dhList) {
			if(dhChild.getAppliedAtRenewal().equals("Y"))
			{
				if (!dhParentMap.containsKey(dhChild.getParentDiscountHistoryKy())){					
					//need to read directly from database for some values as the values in dataobject has already been marked differently.
					DiscountHistory dhParentFromDatabase = new DiscountHistory(user, dhChild.getParentDiscountHistoryKy());
					dhChild.getParentDiscountHistory().setOriginalAt(dhParentFromDatabase.getOriginalAt());
					dhChild.getParentDiscountHistory().setSustainableFl("Y");
					dhChild.getParentDiscountHistory().setAttribute("balanceNonDistributed", dhParentFromDatabase.getAmount());
					dhParentMap.put(dhChild.getParentDiscountHistoryKy(),dhChild.getParentDiscountHistory());
					processCarryForwardDH = true;  
				}								
			}
		}
		if (dhParentMap !=null && !dhParentMap.isEmpty())
		{
			PaymentSummary ps = null;
			for (DiscountHistory dhParent : dhParentMap.values()) {
				usedInPriorTerm = false;
				ArrayList<SearchCondition> criteria1 = new ArrayList<SearchCondition>();
				criteria1.add(new SearchCondition(DiscountHistory.PARENT_DISCOUNT_HISTORY_KY, SearchCondition.EQ, dhParent.getDiscountHistoryKy()));
				SortedSet<DiscountHistory> dhChildList = DiscountHistory.getDiscountHistoryList(user, criteria1, null);
				for (DiscountHistory dh1 : dhChildList) {

					discountKey = dh1.getDiscountKy();
					discountCd = dh1.getDiscountCd();
					discountPaymentMethodCd = dh1.getPaymentMethodCd();
					if (dh1.getSafeString("APPLIED_AT_RENEWAL").equals("N") && dh1.getAmount().compareTo(ZERO) ==0)
					{
						usedInPriorTerm = true;
						break;
					}				
				}	
				int count = 0; 
				for (DiscountHistory dh1 : dhChildList) {
					if(usedInPriorTerm == true)// used in prior term as well
					{
						handlePriorTermDhCase = true;						
						if(count ==0)
						{
							if(dhParent.getAttribute("balanceNonDistributed") !=null)
							    parentCurrentAmt =parentCurrentAmt.add((BigDecimal)(dhParent.getAttribute("balanceNonDistributed"))); // consolidated unused so far amount
							dhParent.setSustainableFl("N");
							dhParentSaveList.add(dhParent);							
						}						
						if (dh1.getSafeString("APPLIED_AT_RENEWAL").equals("N") && dh1.getAmount().compareTo(ZERO) ==0)
						{
							count++;
							continue;
						}						
					}
					else
					{
						if(count ==0)
						{
							dhParent.setCostEffectiveDt(membership.getPrimaryMember().getBasicRider().getCostEffectiveDt());
							dhParent.setAppliedAtRenewal("Y");
							dhParentSaveList.add(dhParent);							
						}						
					}
					count++;					
					carriedForwardAmt = carriedForwardAmt.add(dh1.getAmount());
					SortedSet<PaymentDetail> pdList = dh1.getPaymentDetailList();
					if (pdList !=null && !pdList.isEmpty())
					{							
						for (PaymentDetail pd : pdList) 
						{
							ps = pd.getParentPaymentSummary();						 
							if (pd != null && pd.getDiscountHistoryKy() != null)
							{
								pdRemovalList.add(pd);
							}
						}														
					}
					dhRemovalList.add(dh1);							
				}
			}
			if(ps != null)
			{
				psRemovalList.add(ps);
				SortedSet<JournalEntry> jeList = ps.getJournalEntryList();
				for (JournalEntry je : jeList) 
				{
					if (je != null && je.getJournalEntryKy() != null)
					{
						jeRemovalList.add(je);
					}
				}						 
			}			
		}// end of if dhParentList!=null 
		else
		{ // this case is used for handling discounts if not dispersed by RE1 package due to any exceptions
			for (DiscountHistory dh : membership.getDiscountHistoryList()) {
				if(dh.getAmount().compareTo(ZERO) == -1 )
				{   //implies there is amount in parent discount that is not still used , but not got dispersed by RE1 package
					
					DiscountHistory dhNewParent = new DiscountHistory(user, (BigDecimal) null, false);
					dhNewParent.setDiscountKy(dh.getDiscountKy());
					dhNewParent.setParentMembership(membership);
					dhNewParent.setMembershipKy(membership.getMembershipKy());
					dhNewParent.setSustainableFl(true);						
					dhNewParent.setOriginalAt(dh.getOriginalAt());
					dhNewParent.setAmount(dh.getAmount());
					dhNewParent.setDiscountCd(dh.getDiscountCd());
					dhNewParent.setPaymentMethodCd(dh.getPaymentMethodCd());
					dhNewParent.setCostEffectiveDt(DateUtilities.getTimestamp(true));
					dhNewParent.setCostEffectiveDt(membership.getPrimaryMember().getBasicRider().getCostEffectiveDt());
					dhNewParent.setCountedFl(false);
					dhNewParent.setDiscontinuedFl(false);
					dhNewParent.setAppliedAtRenewal("Y");
					dhNewParent.save();		
					
					dh.setSustainableFl("N");
					dh.setAmount(ZERO);
					dh.save();
					
					processCarryForwardDH = true;	

				}
			}
		}
		
		if(!pdRemovalList.isEmpty())
		{
			for (PaymentDetail pd: pdRemovalList) {
				pd.delete();
			}
		}
		if(!dhRemovalList.isEmpty())
		{
			for (DiscountHistory dh: dhRemovalList) {
				dh.delete();
				dh.save();
			}
		}
		if(!jeRemovalList.isEmpty())
		{
			for (JournalEntry je: jeRemovalList) {
				je.delete();	
			}
		}
		if(!psRemovalList.isEmpty())
		{
			for (PaymentSummary ps1: psRemovalList) {
				ps1.delete();
				ps1.save();	
			}
			
		}
		if(handlePriorTermDhCase == true)
		{
			carriedForwardAmt = carriedForwardAmt.add(parentCurrentAmt);
			if(carriedForwardAmt.compareTo(ZERO) !=0 )
			{
				DiscountHistory dhNewParent = new DiscountHistory(user, (BigDecimal) null, false);
				dhNewParent.setDiscountKy(discountKey);
				dhNewParent.setParentMembership(membership);
				dhNewParent.setMembershipKy(membership.getMembershipKy());
				dhNewParent.setSustainableFl(true);
				dhNewParent.setOriginalAt(carriedForwardAmt);
				dhNewParent.setAmount(carriedForwardAmt);
				dhNewParent.setDiscountCd(discountCd);
				dhNewParent.setPaymentMethodCd(discountPaymentMethodCd);
				dhNewParent.setCostEffectiveDt(membership.getPrimaryMember().getBasicRider().getCostEffectiveDt());
				dhNewParent.setCountedFl(false);
				dhNewParent.setDiscontinuedFl(false);
				dhNewParent.setAppliedAtRenewal("Y");
				dhNewParent.save();				
			}
		}
		if(!dhParentSaveList.isEmpty())
		{
			for (DiscountHistory dhParent: dhParentSaveList) {
				dhParent.save();
			}
		}
		if(processCarryForwardDH)
		{
			membership.save();
			this.membership = new Membership(user, membership.getMembershipKy(), true);
			membership.clearDiscountHistoryList();
		}
		
		return processCarryForwardDH;
	}

	/**
	 * This method will take all membership and member level discounts and
	 * create the appropriate rider level discounts. It will also compute the
	 * amount of a rider level percentage ediscount.
	 * 
	 * It will NOT close them out, that is the payment poster's job when the
	 * riders go active. We do not bother doing anything with discounts that are
	 * not effective for the current membership year.
	 * 
	 * @param membership
	 * @return updated membership
	 * @throws SQLException
	 */
	public Membership disperseDiscounts(Membership ms) throws SQLException, ObjectNotFoundException {
		this.membership = ms;
		if (membership.isPending()||membership.isOnPaymentPlan()) {//pbc 10/30/2014 since installment plans are always active now.  the never flow through here
			boolean done = false;
			if ("P".equals(membership.getPrimaryMember().getRenewMethodCd())) {
				try {
					//disperseDiscountsToInstallments();   /*pbc 10/30/2014 - removed this because it seemed to do nothing right or helpful.  this kind of stuff i*/
					disperseDiscountsByHierarchy(membership);  /*pbc 10/30/2014 - added this.  turns out this was the real problem.  the fact that the membership level discount would not disperse across the riders.  do it here just like does it for pending non install plan */
					done = true;
				} catch (Exception e) {
					// let it disperse to non-payment plan items
				}
			}
			if (!done) {
				if (!ClubProperties.isFullPaymentOnly(membership.getDivisionKy(), membership.getRegionCode())) {
					disperseDiscountsByHierarchy(membership);
				} else {

					disperseDiscountsProportionately();
				}
			}
		}
		/*
		else
		{
			//Get the primary basic rider
			//create a new DH attached to this rider... DH should point to parent DH
			for (DiscountHistory dh : membership.getDiscountHistoryList()) {
				DiscountHistory discountHist = new DiscountHistory(user, null, false);
				discountHist.setDiscountKy(dh.getDiscountKy());
				discountHist.setCostEffectiveDt(dh.getCostEffectiveDt());
				discountHist.setParentRider(membership.getPrimaryMember().getBasicRider());
				discountHist.setParentDiscountHistoryKy(dh.getDiscountHistoryKy());
				discountHist.setPaymentMethodCd(dh.getPaymentMethodCd());
				discountHist.setSustainableFl(false);
				discountHist.setDiscountCd(dh.getDiscountCd());
				discountHist.setAttribute("PRIOR_AMOUNT", ZERO);
				discountHist.setAttribute("KEEP",true);
				discountHist.setOriginalAt(ZERO);
				discountHist.setAmount(ZERO);
				/*
				 * discountHist = new DiscountHistory(user, null, false);
				discountHist.setDiscountKy(discount.getDiscountKy());
				discountHist.setCostEffectiveDt(pc.getCostEffectiveDt().after(dh.getCostEffectiveDt()) ? pc
						.getCostEffectiveDt() : dh.getCostEffectiveDt());
				if (ph.getRiderCompCd() != null) {
					discountHist.setParentRider((Rider) pc);
				} else if (ph.getFeeTypeCd() != null) {
					discountHist.setParentMembershipFees((MembershipFees) pc);
				}

				discountHist.setParentDiscountHistoryKy(dh.getDiscountHistoryKy());
				discountHist.setPaymentMethodCd(dh.getPaymentMethodCd());
				discountHist.setSustainableFl(false);
				discountHist.setDiscountCd(discount.getDiscountCd());
				discountHist.setAttribute("PRIOR_AMOUNT", ZERO);
			}
			discountHist.setAttribute("KEEP",true);
				 
			}
			
		}
		*/
		return membership;
	}

	/**
	 * Builds a map of the all the riders on a membership and their amount due
	 * after discounts have been taken into consideration.
	 * 
	 * @param ms
	 * @return HashMap<BigDecimal, BigDecimal> key - rider_ky, value - amount
	 *         due after discounts.
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	public HashMap<BigDecimal, BigDecimal> getRiderAmountDueMinusDiscounts(Membership ms) throws SQLException,
			ObjectNotFoundException {
		HashMap<BigDecimal, BigDecimal> totalMap = new HashMap<BigDecimal, BigDecimal>();
		// initialize the map and apply rider level discounts.
		// For Future cancel we want to add member
		for (Member m : ms.getMemberList()) {
			if (m.isCancelled() || (m.isFutureCancel() && false)) continue;
			for (Rider r : m.getRiderList()) {
				totalMap.put(r.getRiderKy(), r.amountDue());
			}
			for (MembershipFees r : m.getMembershipFeesList()) {
				totalMap.put(r.getMembershipFeesKy(), r.amountDue());
			}
		}
		return totalMap;
	}

	/********************************************************************************
	 * REMOVAL METHODS *
	 ********************************************************************************/

	/**
	 * @Deprecated
	 */
	private void removeUnpersistedDiscounts() throws Exception {
		List<DiscountHistory> removeList = new ArrayList<DiscountHistory>();
		List<PaymentSummary> removePaymentSummaryList = new ArrayList<PaymentSummary>();
		List<JournalEntry> removeJournalEntryList = new ArrayList<JournalEntry>();
		List<PaymentDetail> removePaymentDetailList = new ArrayList<PaymentDetail>();
		List<MembershipComment> removeCommentList = new ArrayList<MembershipComment>();
		List<BigDecimal> removedDiscountKey= new ArrayList<BigDecimal>();
		
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.isNew() && !dh.isSustainable()) {
				removeList.add(dh);
			}
		}
		for (DiscountHistory dh : removeList) {
			membership.removeDiscountHistory(dh);
			removedDiscountKey.add(dh.getDiscountHistoryKy());
		}
		getDiscountCommentRecords();
		for (MembershipComment cmt : membership.getCurrentMembershipCommentList()) {
			// this is sort of hack-ish, but any commented generated here needs to
			// be removed so we don't get duplicates
			if (cmt.isNew() && cmt.getAttribute("DiscountBP") != null) {
				removeCommentList.add(cmt);
			}
		}
		for (MembershipComment cmt : removeCommentList) {
			membership.removeMembershipComment(cmt);
		}
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			removeList.clear();
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.isNew() && !dh.isSustainable()) {
					removeList.add(dh);
				}
			}
			for (DiscountHistory dh : removeList) {
				m.removeDiscountHistory(dh);
				removedDiscountKey.add(dh.getDiscountHistoryKy());
			}
			for (Rider r : m.getRiderList()) {
				removeList.clear();
				for (DiscountHistory dh : r.getDiscountHistoryList()) {
					if (dh.isNew() && !dh.isSustainable()) {
						removeList.add(dh);
					}
				}
				for (DiscountHistory dh : removeList) {
					r.removeDiscountHistory(dh);
					removedDiscountKey.add(dh.getDiscountHistoryKy());
				}
			}
		}
		
		for (PaymentSummary ps : membership.getCurrentPaymentSummaryList()) {
			if (!PaymentSummary.TC_DISCOUNT.equals(ps.getTransactionCd())) continue;
			if (ps.isNew()) {
				removePaymentSummaryList.add(ps);
			}
			else {
				// check for new payment details on existing payment summary
				removePaymentDetailList.clear();
				for (PaymentDetail pd:ps.getPaymentDetailList()) {
					if (pd.isNew() && removedDiscountKey.contains(pd.getDiscountHistoryKy())) {
						removePaymentDetailList.add(pd);
					}
				}
				for (PaymentDetail pd:removePaymentDetailList) {
					ps.removePaymentDetail(pd);
				}
				// check for new payment details on existing payment summary
				removeJournalEntryList.clear();
				for (JournalEntry je:ps.getJournalEntryList()) {
					if (je.isNew()) {
						removeJournalEntryList.add(je);
					}
				}
				for (JournalEntry je:removeJournalEntryList) {
					ps.removeJournalEntry(je);
				}
			}
		}
		for (PaymentSummary ps : removePaymentSummaryList) {
			membership.removePaymentSummary(ps);
		}
	}

	/**
	 * Goes thro the discount entries and calculate the total amount of discount
	 */
	private BigDecimal calculateDiscountWithoutRecording(Solicitation solicitation) throws Exception {
	  BigDecimal totalDiscountAmt = ZERO;
	  if(solicitation !=null )
	  {
		  SearchCondition sc = new SearchCondition(SolicitationDiscount.SOLICITATION_KY, +SearchCondition.EQ, solicitation.getSolicitationKy());
	      ArrayList<SearchCondition> conds = new ArrayList<SearchCondition>();
		  conds.add(sc);		
		  SortedSet<SolicitationDiscount> sds= solicitation.getSolicitationDiscountList(conds, null);
		  for (SolicitationDiscount sd: sds) {
			for (DiscountHistory dh : membership.getDiscountHistoryList()) {
				// don't bother id discount code is not the one available for the solicitation
				if (!dh.getDiscountCd().equalsIgnoreCase(sd.getDiscountCd())) continue;
				// the only thing we need to do at membership level is to
				// record a dollar amount if we were unable to disperse the
				// entire discount.hing w
				if (!(Boolean)dh.getAttribute("KEEP")) {
					killDiscount(dh,membership);
					continue;
				}
				// only worry about it if it's > 0
				if (dh.getAmount().compareTo(ZERO) == 0) {
					continue;
				}
				// how much is the payment detail?
				// It should be set to either the full amount, or if we established
				// the discount on a previous day, the difference between what was
				// reported then and what the value of the discount is today.
				BigDecimal priorAmount = priorValue(dh);
				BigDecimal delta = dh.getAmount().subtract(priorAmount);
				totalDiscountAmt = delta;
			}
			// now do Member level discounts
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				long memberKy = m.getMemberKy().longValue();
				for (DiscountHistory dh : m.getDiscountHistoryList()) {
					// don't bother id discount code is not the one available for the solicitation
					if (!dh.getDiscountCd().equalsIgnoreCase(sd.getDiscountCd())) continue;
					if (!((Boolean)dh.getAttribute("KEEP"))) {
						killDiscount(dh,m);
						continue;
					}
					// only worry about it if it's > 0
					if (dh.getAmount().compareTo(ZERO) == 0) {
						continue;
					}
					BigDecimal priorAmount = priorValue(dh);
					BigDecimal delta = dh.getAmount().subtract(priorAmount);
					totalDiscountAmt = totalDiscountAmt.add(delta);
				}
			}
			// now do Rider level discounts
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				for (PayableComponent pc : m.getPayableComponentList()) {
					for (DiscountHistory dh : pc.getDiscountHistoryList()) {
						// don't bother id discount code is not the one available for the solicitation
						if (!dh.getDiscountCd().equalsIgnoreCase(sd.getDiscountCd())) continue;
						if (!((Boolean)dh.getAttribute("KEEP"))) {
							if (dh.getParentDiscountHistoryKy() == null) {
								killDiscount(dh,pc);
							}
							continue;
						}
						
						BigDecimal priorAmount = priorValue(dh);
						BigDecimal delta = dh.getAmount().subtract(priorAmount);
						totalDiscountAmt = totalDiscountAmt.add(delta);
					}
				}
			}
		  }// for each discounts
	  }
	  return totalDiscountAmt;
	
		
	}
	/**
	 * Put comments on the membership and maintain payment summary and journal
	 * entry records for any changes in the discounts on the membership.
	 */
	private void recordDiscountChanges() throws Exception {
		//System.err.println(membership.debugDataObject())
		
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			// don't bother with conversion discounts
			if ("CONVCH".equals(dh.getDiscountCd())) continue;
			// the only thing we need to do at membership level is to
			// record a dollar amount if we were unable to disperse the
			// entire discount.
			if (!(Boolean)dh.getAttribute("KEEP")) {
				killDiscount(dh,membership);
				continue;
			}
			// only worry about it if it's > 0
			if (dh.getAmount().compareTo(ZERO) == 0) {
				continue;
			}
			// how much is the payment detail?
			// It should be set to either the full amount, or if we established
			// the discount on a previous day, the difference between what was
			// reported then and what the value of the discount is today.
			BigDecimal priorAmount = priorValue(dh);
			BigDecimal delta = dh.getAmount().subtract(priorAmount);
			PaymentSummary ps = null;
			if (paymentSummary.containsKey(dh.getDiscountCd())) {
				ps = paymentSummary.get(dh.getDiscountCd());
			}
			else {
				ps = buildPaymentSummary(dh, dh.getAmount());
			}
			PaymentDetail thisDetail = null;
			for (PaymentDetail pd : ps.getPaymentDetailList()) {
				// find if there is a membership level detail
				if (pd.getDiscountHistoryKy() != null
						&& pd.getDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy()) == 0) {
					thisDetail = pd;
				}
			}
			if (thisDetail == null) {
				thisDetail = new PaymentDetail(user, (BigDecimal) null, false);
				thisDetail.setParentPaymentSummary(ps);
				thisDetail.setAttribute("PRIOR_AMOUNT",ZERO);
				thisDetail.setDiscountHistoryKy(dh.getDiscountHistoryKy());
				thisDetail.setDescription(dh.getParentDiscount().getName());
				thisDetail.setMemberKy(membership.getPrimaryMember().getMemberKy());
				
			}
			thisDetail.setAttribute("KEEP",true);
			if (!dh.isReadOnly())
				thisDetail.setMembershipPaymentAt(delta);
		}
		// now do Member level discounts
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			long memberKy = m.getMemberKy().longValue();
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				// don't bother with conversion discounts
				if ("CONVCH".equals(dh.getDiscountCd())) continue;
				if (!((Boolean)dh.getAttribute("KEEP"))) {
					killDiscount(dh,m);
					continue;
				}
				// only worry about it if it's > 0
				if (dh.getAmount().compareTo(ZERO) == 0) {
					continue;
				}
				BigDecimal priorAmount = priorValue(dh);
				BigDecimal delta = dh.getAmount().subtract(priorAmount);
				long dhKey = dh.getDiscountHistoryKy().longValue();
				PaymentSummary ps = null;
				if (paymentSummary.containsKey(dh.getDiscountCd())) {
					ps = paymentSummary.get(dh.getDiscountCd());
				}
				else {
					ps = buildPaymentSummary(dh, dh.getAmount());
				}
				PaymentDetail thisDetail = null;
				for (PaymentDetail pd : ps.getPaymentDetailList()) {
					// find if there is a membership level detail
					if (pd.getMemberKy() != null && pd.getMemberKy().longValue() == memberKy
							&& pd.getDiscountHistoryKy() != null && pd.getDiscountHistoryKy().longValue() == dhKey) {
						thisDetail = pd;
					}
				}
				if (thisDetail == null) {
					thisDetail = new PaymentDetail(user, (BigDecimal) null, false);
					thisDetail.setParentPaymentSummary(ps);
					thisDetail.setMemberKy(memberKy);
					thisDetail.setAttribute("PRIOR_AMOUNT",ZERO);
					thisDetail.setDiscountHistoryKy(dhKey);
					thisDetail.setDescription(dh.getParentDiscount().getName());
				}
				thisDetail.setAttribute("KEEP",true);
				if (!dh.isReadOnly())
					thisDetail.setMembershipPaymentAt(delta);
			}
		}
		// now do Rider level discounts
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (PayableComponent pc : m.getPayableComponentList()) {
				long componentKy = pc.getKey().longValue();
				for (DiscountHistory dh : pc.getDiscountHistoryList()) {
					if (!((Boolean)dh.getAttribute("KEEP"))) {
						if (dh.getParentDiscountHistoryKy() == null) {
							killDiscount(dh,pc);
						}
						continue;
					}
					// don't bother with conversion discounts
					if ("CONVCH".equals(dh.getDiscountCd())) continue;
					BigDecimal priorAmount = priorValue(dh);
					BigDecimal delta = dh.getAmount().subtract(priorAmount);
					long dhKey = dh.getDiscountHistoryKy().longValue();
					PaymentSummary ps = null;
					//TR 5666 Changes should go here
					//TR 5666 Rollback for 1.0.20.0
					if (paymentSummary.containsKey(dh.getDiscountCd())) {
						ps = paymentSummary.get(dh.getDiscountCd());
					}
					else {
						ps = buildPaymentSummary(dh, dh.getAmount());
					}
					PaymentDetail thisDetail = null;
					for (PaymentDetail pd : ps.getPaymentDetailList()) {
						// find if there is a membership level detail
						if (((pd.getRiderKy() != null && pd.getRiderKy().longValue() == componentKy)
								|| (pd.getMembershipFeesKy() != null && pd.getMembershipFeesKy().longValue() == componentKy))
								&& pd.getDiscountHistoryKy() != null && pd.getDiscountHistoryKy().longValue() == dhKey) {
							thisDetail = pd;
						}
					}
					if (thisDetail == null) {
						thisDetail = new PaymentDetail(user, (BigDecimal) null, false);
						thisDetail.setParentPaymentSummary(ps);
						if (pc instanceof Rider)
							thisDetail.setRiderKy(componentKy);
						else if (pc instanceof MembershipFees)
							thisDetail.setMembershipFeesKy(componentKy);
						thisDetail.setMemberKy(m.getMemberKy());
						thisDetail.setAttribute("PRIOR_AMOUNT",ZERO);
						thisDetail.setDiscountHistoryKy(dhKey);
						thisDetail.setDescription(dh.getParentDiscount().getName());
					}
					thisDetail.setAttribute("KEEP",true);
					if (!dh.isReadOnly())
						thisDetail.setMembershipPaymentAt(delta);
				}
			}
		}
		// At this point, we have a proper payment summary/payment detail
		// environment.  Possibly, we could have unaccounted payment details
		// that were there on an existing discount, but are no longer needed.
		for (PaymentSummary ps : paymentSummary.values()) {
			BigDecimal paymentAt = ZERO;
			List<PaymentDetail> removeList = new ArrayList<PaymentDetail>();
			for (PaymentDetail pd : ps.getPaymentDetailList()) {
				if (pd.isNew() && pd.getMembershipPaymentAt().compareTo(ZERO) == 0) {
					removeList.add(pd);
					continue;
				}
				if (!(Boolean)pd.getAttribute("KEEP")) {
					pd.delete();
				}
				else {
					paymentAt = paymentAt.add(pd.getMembershipPaymentAt());
				}
			}
			ps.setPaymentAt(paymentAt);
			for (PaymentDetail pd:removeList) {
				ps.removePaymentDetail(pd);
			}
		}
		
		// Any rider level discounts where effective dt is null that were
		// not reused, set amount to 0.
		for (Member m:membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (Rider r:m.getRiderList()) {
				for (DiscountHistory dh:r.getDiscountHistoryList()) {
					if (dh.isRowDeleted()) continue;
					if (!((Boolean)dh.getAttribute("KEEP"))) {
						// we can't delete it, so set amounts to zero and set effective date
						// so it's never considered again
						
						//TR5500 - Unable to enter new associate to membership if internet Act exists
						if (dh.getInternetActivityList(true).size() > 0)
						{
							dh.setAmount(ZERO);
						}
						else
						{
						  dh.delete();
						}
//						dh.setAmount(ZERO);
//						dh.setOriginalAt(ZERO);
//						dh.setEffectiveDt(DateUtilities.getTimestamp(true));
					}
					//AGI - PC: Remove 0 dollars member or membership level discounts distributed to rider
					//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
					if (!dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR") &&
							dh.getAmount().compareTo(ZERO) == 0 && dh.getOriginalAt().compareTo(ZERO) ==0 
							&& dh.getParentDiscountHistoryKy() !=null) {
						if (dh.isRowDeleted()) continue;
						r.removeDiscountHistory(dh);					    
				    }
				}
			}
			//AGI - PC: Remove 0 dollars member or membership level discounts distributed to rider 
			for (MembershipFees fee : m.getMembershipFeesList()) {
				for (DiscountHistory dh:fee.getDiscountHistoryList()) 
				{
					//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
					if (!dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR") &&
							dh.getAmount().compareTo(ZERO) == 0 && dh.getOriginalAt().compareTo(ZERO) ==0 
							&& dh.getParentDiscountHistoryKy() !=null) {
						if (dh.isRowDeleted()) continue;
						fee.removeDiscountHistory(dh);					    
				    }
					else if (!((Boolean)dh.getAttribute("KEEP"))) {
						fee.removeDiscountHistory(dh);	
						
					}
			  }
			}
		}

		StringBuilder comment = new StringBuilder(2000);
		// Set the payment summary payment amount
		for (PaymentSummary ps: paymentSummary.values()) {
			if (ps.isRowDeleted()) continue;
			BigDecimal originalAt = null;
			BigDecimal paymentAt = ps.getPaymentAt();
			if (!ps.isNew() && ps.getOriginalField(PaymentSummary.PAYMENT_AT)!= null) {
				originalAt = new BigDecimal(ps.getOriginalField(PaymentSummary.PAYMENT_AT).toString());
			}
			if (originalAt == null) {
				// it's new
				if(paymentAt !=null && paymentAt.compareTo(ZERO) != 0)
				    comment.append("\n").append(ps.getReasonCd()).append(" discount for $").append(paymentAt.setScale(2)).append(" added.");
			}
			else if (originalAt.compareTo(ZERO) != 0 && paymentAt.subtract(originalAt).compareTo(ZERO) != 0) {
				// it changed
				comment.append("\n").append(ps.getReasonCd()).append(" discount adjusted by ").append(paymentAt.subtract(originalAt).setScale(2));
			}
		}
		if (comment.toString().trim().length() > 0) {
			MembershipComment cmt = new MembershipComment(user,(BigDecimal)null, false);
			cmt.setAttribute("DiscountBP","Y");
			cmt.setParentMembership(membership);
			cmt.setCommentTypeCd(MembershipComment.TYPE_SYSTEM);
			cmt.setCreateDt(new Timestamp(System.currentTimeMillis()));
			cmt.setCreateUserId(user.userID);
			cmt.setComments(comment.toString().substring(1));
		}
		
		// and finally, if we have changed a discount on an active component
		// such that it owes money, we need to switch it pending
		for (Member m:membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (Rider r:m.getRiderList()) {
				if (!r.isActive()) continue;
				if (r.amountDue().compareTo(ZERO) > 0) {
					r.setStatus("P");
					r.setStatusDt(new Timestamp(System.currentTimeMillis()));
					if (m.isActive()) {
						m.setStatus("P");
						m.setStatusDt(r.getStatusDt());
						if (membership.isActive()) {
							membership.setStatus("P");
							membership.setStatusDt(r.getStatusDt());
						}
					}
				}
			}
		}
		
	}
	private BigDecimal priorValue(DiscountHistory dh) throws SQLException {
		BigDecimal result = ZERO;
		priorDiscounts.beforeFirst();
		while (priorDiscounts.next()) {
			if (priorDiscounts.getInt(1) == dh.getDiscountHistoryKy().intValue()) {
				result = priorDiscounts.getBigDecimal(2);
			}
		}
		return result;
	}
	private SimpleVO priorDiscounts() throws SQLException {
		StringBuilder sb = new StringBuilder(1000);
		sb.append("select discount_history_ky, sum(membership_payment_at) ");
		sb.append("  from mz_payment_detail pd, mz_payment_summary ps ");
		sb.append(" where pd.membership_payment_ky = ps.membership_payment_ky ");
		sb.append("   and ps.payment_dt < trunc(sysdate) ");
		sb.append("   and ps.membership_ky =  ").append(membership.getMembershipKy());
		sb.append("   and discount_history_ky in ");
		char comma = '(';
		for (DiscountHistory dh:membership.getDiscountHistoryList()) {
			if ((Boolean)dh.getAttribute("KEEP")) {
				sb.append(comma).append(dh.getDiscountHistoryKy());
				comma = ',';
			}
		}
		for (Member m:membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (DiscountHistory dh:membership.getDiscountHistoryList()) {
				if ((Boolean)dh.getAttribute("KEEP")) {
					sb.append(comma).append(dh.getDiscountHistoryKy());
					comma = ',';
				}
			}
			for (Rider r:m.getRiderList()) {
				for (DiscountHistory dh2:r.getDiscountHistoryList()) {
					if ((Boolean)dh2.getAttribute("KEEP")) {
						sb.append(comma).append(dh2.getDiscountHistoryKy());
						comma = ',';
					}
				}
			}
		}
		if (comma == '(') {
			sb.append("(-1");
		}
		sb.append(") group by discount_history_ky");
		SimpleVO result = new SimpleVO();
		result.setCommand(sb.toString());
		Connection conn = ConnectionPool.getConnection(user);
		try {
			result.execute(conn);
		}
		finally {
			try { conn.close(); } catch (Exception ignore) {}
		}
		return result;
	}
	
	private SimpleVO priorOrSameDayDiscounts() throws SQLException {
		StringBuilder sb = new StringBuilder(1000);
		sb.append("select discount_history_ky, sum(membership_payment_at) ");
		sb.append("  from mz_payment_detail pd, mz_payment_summary ps ");
		sb.append(" where pd.membership_payment_ky = ps.membership_payment_ky ");
		sb.append("   and ps.payment_dt <= trunc(sysdate) ");
		sb.append("   and ps.membership_ky =  ").append(membership.getMembershipKy());
		sb.append("   and discount_history_ky in ");
		char comma = '(';
		for (DiscountHistory dh:membership.getDiscountHistoryList()) {
			if ((Boolean)dh.getAttribute("KEEP")) {
				sb.append(comma).append(dh.getDiscountHistoryKy());
				comma = ',';
			}
		}
		for (Member m:membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (DiscountHistory dh:membership.getDiscountHistoryList()) {
				if ((Boolean)dh.getAttribute("KEEP")) {
					sb.append(comma).append(dh.getDiscountHistoryKy());
					comma = ',';
				}
			}
			for (Rider r:m.getRiderList()) {
				for (DiscountHistory dh2:r.getDiscountHistoryList()) {
					if ((Boolean)dh2.getAttribute("KEEP")) {
						sb.append(comma).append(dh2.getDiscountHistoryKy());
						comma = ',';
					}
				}
			}
		}
		if (comma == '(') {
			sb.append("(-1");
		}
		sb.append(") group by discount_history_ky");
		SimpleVO result = new SimpleVO();
		result.setCommand(sb.toString());
		Connection conn = ConnectionPool.getConnection(user);
		try {
			result.execute(conn);
		}
		finally {
			try { conn.close(); } catch (Exception ignore) {}
		}
		return result;
	}
	
	private void addJournalEntries() throws SQLException, ObjectNotFoundException {
		JournalEntryBP jbp = BPF.get(user,JournalEntryBP.class);
		jbp.addDiscountJournalEntries(membership, paymentSummary);
	}

	private void killDiscount(DiscountHistory dh, Member m) throws SQLException, ObjectNotFoundException {
		// did this discount exist before today?
		long dhKey = dh.getDiscountHistoryKy().longValue();
		PaymentSummary ps = buildPaymentSummary(dh,ZERO);
		List<DiscountHistory> dhRemovalList = new ArrayList<DiscountHistory>();
		for (Rider r:m.getRiderList()) {
			for (DiscountHistory rdh:r.getDiscountHistoryList()) {
				if (rdh.getParentDiscountHistoryKy().longValue() == dhKey) {
					BigDecimal amt = (BigDecimal) rdh.getAttribute("PRIOR_AMOUNT");
					ps.setPaymentAt(ps.getPaymentAt().subtract(amt==null?ZERO:amt));
					rdh.setAttribute("ParentDiscount",dh);
					rdh.setAttribute("ParentObject",r);
					dhRemovalList.add(rdh);
				}
			}
		}
		offsetDiscount(ps, dhRemovalList);
		boolean keep = false;
		for (Rider r:m.getRiderList()) {
			for (DiscountHistory rdh:r.getDiscountHistoryList()) {
				if (!rdh.isRowDeleted()) keep = true;
			}
		}
		if (!keep) {
			if (dh.isNew()) m.removeDiscountHistory(dh);
			else 
				{
				    //TR5500 - Unable to enter new associate to membership if internet Act exists
					if (dh.getInternetActivityList(true).size() > 0)
					{
					  dh.setAmount(ZERO);
					}
					else
					{
					  dh.delete();
					}
				}
		}
	}

	private void killDiscount(DiscountHistory dh, Membership m) throws SQLException, ObjectNotFoundException {
		long dhKey = dh.getDiscountHistoryKy().longValue();
		PaymentSummary ps = buildPaymentSummary(dh,ZERO);
		List<DiscountHistory> dhRemovalList = new ArrayList<DiscountHistory>();
		for (Member mbr:m.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (Rider r:mbr.getRiderList()) {
				for (DiscountHistory rdh:r.getDiscountHistoryList()) {
					//fix exception due to discount ky null  Preethi/Wei
					if (rdh.getParentDiscountHistoryKy() !=null && rdh.getParentDiscountHistoryKy().longValue() == dhKey) {
						ps.setPaymentAt(ps.getPaymentAt().subtract(rdh.getAmount()));
						rdh.setAttribute("ParentDiscount",dh);
						rdh.setAttribute("ParentObject",r);
						dhRemovalList.add(rdh);
					}
				}
			}
		}
		offsetDiscount(ps, dhRemovalList);
		boolean keep = false;
		for (Member mbr:m.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (Rider r:mbr.getRiderList()) {
				for (DiscountHistory rdh:r.getDiscountHistoryList()) {
					if (!rdh.isRowDeleted()) keep = true;
				}
			}
		}
		if (!keep) {
			if (dh.isNew()) m.removeDiscountHistory(dh);
			else 
				{
				    //TR5500 - Unable to enter new associate to membership if internet Act exists
					if (dh.getInternetActivityList(true).size() > 0)
					{
					  dh.setAmount(ZERO);
					}
					else
					{
						dh.delete();
					}
				}
		}
				
		
	}

	private void killDiscount(DiscountHistory dh, PayableComponent r) throws SQLException, ObjectNotFoundException {
		long dhKey = dh.getDiscountHistoryKy().longValue();
		PaymentSummary ps = buildPaymentSummary(dh,ZERO);
		List<DiscountHistory> dhRemovalList = new ArrayList<DiscountHistory>();
		ps.setPaymentAt(ps.getPaymentAt().subtract(dh.getAmount()));
		if (dh.getInternetActivityList(true).size() > 0)
		{
			dh.setAmount(ZERO);
			
		}
		else
		{
		  dhRemovalList.add(dh);
		}
		dh.setAttribute("ParentObject",r);
		offsetDiscount(ps, dhRemovalList);
		
	}

	/**
	 * Delete the discount, and create adjusting entries.  Upon entry, the 
	 * payment summary will have had the payment amount adjusted by the 
	 * discount history records in the dhRemovalList collection.
	 * 
	 * @param ps
	 * @param dhRemovalList
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	private void offsetDiscount(PaymentSummary ps, List<DiscountHistory> dhRemovalList) throws SQLException,
			ObjectNotFoundException {
		// We are in one of two states, either the discount was established today
		// and removed today, in which case the payment summary payment_at will be
		// $0.00.  Or we established the discount prior to today and need to adjust
		// the discount off today.
		if (ps.getPaymentAt().compareTo(ZERO) == 0) {
			// we are deleting the discount entirely
			if (ps.isNew()) membership.removePaymentSummary(ps);
			else {
				for (PaymentDetail pd:ps.getPaymentDetailList()) {
					pd.delete();
				}
				for (JournalEntry je:ps.getJournalEntryList()) {
					je.delete();
				}
				ps.delete();
			}
			for (DiscountHistory dh: dhRemovalList) {
				//TR5500 - Unable to enter new associate to membership if internet Act exists
				if (dh.getInternetActivityList(true).size() > 0)
				{
				  dh.setAmount(ZERO);
				}
				else
				{
				  dh.delete();
				}
			}
		}
		else if (ps.isNew()){
			String discountCd = null; 
			// the ps.payment_at will be positive, because it started at 0.
			// the only thing we need to do is to reverse all the discount
			// history records' journal entries, then delete them.
			for (DiscountHistory rdh:dhRemovalList) {
				// DATABASE NOTE: foreign key between payment detail and
				//                discount history MUST be configured for 
				//                "SET NULL" on parent (discount history)
				//                deletion.
				if (discountCd == null) discountCd = rdh.getParentDiscount().getName();
				PaymentDetail pd = new PaymentDetail(user,(BigDecimal)null,false);
				
				pd.setParentPaymentSummary(ps);
				pd.setMembershipPaymentAt(priorValue(rdh).abs());
				pd.setRiderKy(rdh.getRiderKy());
				pd.setMembershipFeesKy(rdh.getMembershipFeesKy());
				pd.setDescription(discountCd);
				for (Member m:membership.getMemberList()) {
					if (m.isCancelled() || m.isFutureCancel()) continue;
					for (PayableComponent r:m.getPayableComponentList()) {
						if (r instanceof Rider && rdh.getRiderKy().compareTo(r.getKey())==0) {
							pd.setMemberKy(m.getMemberKy());
						}
						//fix exception due to discount ky null  Preethi/Wei
						if (r instanceof MembershipFees && rdh.getMembershipFeesKy() !=null && rdh.getMembershipFeesKy().compareTo(r.getKey())==0) {
							pd.setMemberKy(m.getMemberKy());
						}
					}
				}
			}
			// call the journal entry process
			JournalEntryBP jbp = BPF.get(user,JournalEntryBP.class);
			Map<String,PaymentSummary> map = new HashMap<String,PaymentSummary>();
			map.put(discountCd,ps);
			jbp.addDiscountJournalEntries(membership, map);
			// journal entries are now tied to the payment summary, delete the discount 
			// history records.
		}
		else {
			// we are removing part of the discount, just do the offsets for the discounts removed
			for (PaymentDetail pd:ps.getPaymentDetailList()) {
				//fix exception due to discount ky null  Preethi/Wei
				if( pd.getDiscountHistoryKy() != null)
				{
					for (DiscountHistory rdh:dhRemovalList) {
						if (rdh.getDiscountHistoryKy().compareTo(pd.getDiscountHistoryKy())==0) {
							pd.delete();
						}
					}
				}
			}
			for (DiscountHistory rdh:dhRemovalList) {
				//TR5500 - Unable to enter new associate to membership if internet Act exists
				if (rdh.getInternetActivityList(true).size() > 0)
				{
				  rdh.setAmount(ZERO);
				}
				else
				{
				  rdh.delete();
				}
			}
		}
	}	
	
	/**
	 * Final step of payment summary management. We've determined that we need
	 * to document an increase/decrease in discount amount. Write a payment
	 * summary and payment detail record.
	 * 
	 * @param ms
	 *            Membership record to tie to the payment summary;
	 * @param dh
	 *            DiscountHistory record to tie to the payment detail.
	 * @param amount
	 *            Amount (negative or positive) of the discount. If positive, we
	 *            are reducing or eliminating a discount previously taken.
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	protected PaymentSummary buildPaymentSummary(DiscountHistory dh, BigDecimal amount) throws SQLException, ObjectNotFoundException {

		PaymentSummary ps = paymentSummary.get(dh.getDiscountCd());
		if (ps == null) {
			ps = new PaymentSummary(user, (BigDecimal) null, false);
			ps.setParentMembership(membership);
			ps.setTransactionTypeCd("A");
			ps.setTransactionCd(PaymentSummary.TC_DISCOUNT);
			ps.setPaymentDt(DateUtilities.getTimestamp(true));
			ps.setAdjustmentDescriptionCd(ADJ_DUES);
			ps.setPaymentMethodCd(PAYMTH_DISCOUNT);
			ps.setBatchName(dh.getParentDiscount().getName());
			ps.setPaidByCd(membership.getPrimaryMember().getBasicRider().getPaidByCd());
			ps.setDonorNr(membership.getPrimaryMember().getBasicRider().getDonorNr());
			ps.setReasonCd(dh.getDiscountCd());
			ps.setBranchKy(((MemberzPlusUser)user).getBranchKy());
			paymentSummary.put(dh.getDiscountCd(), ps);
		}
		ps.setPaymentAt(ps.getPaymentAt().add(amount));
		return ps;
	}

	/********************************************************************************
	 * ASSIGNING METHODS *
	 ********************************************************************************/

	/**
	 * Assigns the automatic discounts the membership is eligible for.
	 * 
	 * @param membership
	 * @throws Exception  System.err.println(membership.debugDataObject())
	 */
	private void assignAutomatics() throws Exception {
		Collection<Discount> automaticDiscounts = null;
		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		criteria.add(new SearchCondition(Discount.START_DT, SearchCondition.LT, DateUtilities.getTimestamp(true)));
		criteria.add(new SearchCondition("nvl(" + Discount.END_DT + ",sysdate + 1)", SearchCondition.GT, DateUtilities
				.getTimestamp(true)));
		criteria.add(new SearchCondition(Discount.AUTO_FL, SearchCondition.EQ, "Y"));
		criteria.add(new SearchCondition(Discount.MEMBERSHIP_TYPE_CD, SearchCondition.EQ, membership
				.getMembershipTypeCd()));
		automaticDiscounts = Discount.getDiscountList(user, criteria, membership.getDivisionKy(), membership
				.getRegionCode(), membership.getBranchKy());

		// keep track of members that receive a particluar discount
		// key = discountCode, value=set of member_ky values
		Map<String, Set<BigDecimal>> membersHave = new HashMap<String, Set<BigDecimal>>();
		for (Discount automaticDiscount : automaticDiscounts) {
			if(automaticDiscount.getMemberCount()!=null){
				
			
			int maxMembers = automaticDiscount.getMemberCount().intValue();
			if (maxMembers == 0) maxMembers = 99;
			if (!membersHave.containsKey(automaticDiscount.getDiscountCd())) {
				// if a member has this discount, and it's read only, we can't remove it
				// so count it.
				HashSet<BigDecimal> init = new HashSet<BigDecimal>();
				for (Member m:membership.getMemberList()) {
					if (m.isCancelled() || m.isFutureCancel()) continue;
					for (DiscountHistory dh:m.getDiscountHistoryList()) {
						if (dh.getDiscountCd().equals(automaticDiscount.getDiscountCd()) && 
								dh.isReadOnly()) {
							init.add(m.getMemberKy());
						}
					}
				}
				
				membersHave.put(automaticDiscount.getDiscountCd(), init);
			}
			int membersAlreadyHave = membersHave.get(automaticDiscount.getDiscountCd()).size();
			if (automaticDiscount.appliesToMembership() && checkRequirements(automaticDiscount, membership)
					&& membersAlreadyHave == 0) {
				// membership level discount.
				addDiscount(automaticDiscount, membership);
				membersHave.get(automaticDiscount.getDiscountCd()).add(membership.getPrimaryMember().getMemberKy());
			} else if (!automaticDiscount.appliesToMembership() && membersAlreadyHave < maxMembers) {
				int count = maxMembers - membersAlreadyHave;
				// member and rider level discounts.
				for (Member member : membership.getMemberList()) {
					if (member.isCancelled() || member.isFutureCancel()) continue;
					if (count == 0) {
						break;
					} else if (member.getMemberTypeCd().equalsIgnoreCase(automaticDiscount.getMemberTypeCd())) {
						if (automaticDiscount.appliesToMember() && checkRequirements(automaticDiscount, member)) 
						{
							addDiscount(automaticDiscount, member);
							count--;
							membersHave.get(automaticDiscount.getDiscountCd()).add(member.getMemberKy());
						} else if (automaticDiscount.appliesToRider()) {
							Rider rider = member.getRiderByRiderCompCode(automaticDiscount.getRiderCompCd());
							if (rider != null && checkRequirements(automaticDiscount, rider)) {
								addDiscount(automaticDiscount, rider);
								count--;
								membersHave.get(automaticDiscount.getDiscountCd()).add(member.getMemberKy());
							}
						}
					}
				}
			}
			}
			else
			{
				log.error("No member count set up for this discount - ignoring the discount " + automaticDiscount.getDiscountCd());
			}
		}
	}

	/**
	 * Assigns the solicitation discounts the membership is eligble for, based
	 * on the solicitation code on the components. Membership level discounts
	 * are based on the solicitation code on the primary member. Member level
	 * discounts are based on the solicitation code on the member. Rider level
	 * discounts are based on the solicitation code on the rider.
	 * 
	 * @param membership
	 * @throws Exception
	 */
	private void assignDiscountFromSolicitation() throws Exception {
		Collection<Discount> solDiscounts = null;
		ArrayList<SearchCondition> startCriteria = new ArrayList<SearchCondition>();
		startCriteria.add(new SearchCondition(Discount.START_DT, SearchCondition.LE, DateUtilities
				.getTimestamp(true)));
		startCriteria.add(new SearchCondition("nvl(" + Discount.END_DT + ",sysdate + 1)",
				SearchCondition.GT, DateUtilities.getTimestamp(true)));
		startCriteria.add(new SearchCondition(Discount.AUTO_FL, SearchCondition.EQ, "N"));
		startCriteria.add(new SearchCondition(Discount.MEMBERSHIP_TYPE_CD, SearchCondition.EQ,
				membership.getMembershipTypeCd()));

		for (Member member : membership.getMemberList()) {
			if (member.isCancelled() || member.isFutureCancel()) continue;
			//wwei JRDR
			//JRDR rule: the solicitation code will apply to next regular member. Junior Driver won't take solicitation discount
			// rule apply even JRDR is in mid-term, won't get free member JRDR discount this year
			// this rule only happen to AGI/N OHIO region. 
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if( member.isJunior() && member.isJRDRDivision(membership.getDivisionKy().toEngineeringString().trim())) continue;
			
			for (Rider rider : member.getRiderList()) {
				// rider level discounts.
				String riderSolicitationCd = rider.getSolicitationCd();
				if (riderSolicitationCd != null) {
					Solicitation riderSolicitation = null;
					try {
						//release 2.8 THNX basically need check solicitation is active based on rider's cost effective date
						//riderSolicitation = Solicitation.getSolicitation(user, riderSolicitationCd, rider);
						riderSolicitation = Solicitation.getSolicitation(user, riderSolicitationCd);
					} catch (Exception e) {
						// may not be active
                        log.debug("assignDiscountFromSolicitation: The solicitation code for rider is not active for today");
						
						try
						{
					        List criteria = new ArrayList();
					        List orderby = new ArrayList();
					        criteria.add(new SearchCondition(Solicitation.SOLICITATION_CD,SearchCondition.EQ,riderSolicitationCd));
					        
					        orderby.add(Solicitation.SOLICITATION_CD);
					        orderby.add(Solicitation.BEGIN_DT);
					        SortedSet<Solicitation> solcdList = Solicitation.getSolicitationList(user,criteria,orderby);
					        //the active one with the latest begin date
					        for (Iterator <Solicitation>it = solcdList.iterator();it.hasNext();) {
					            Solicitation tmpDO = (Solicitation)it.next();
					            Timestamp today = DateUtilities.getTimestamp(true);
					            Timestamp beginDate = DateUtilities.timestampAdd(Calendar.DATE,-1,today);
					            Timestamp endDate = DateUtilities.timestampAdd(Calendar.DATE,+1,rider.getCostEffectiveDt());
					            if (tmpDO.getActiveFl().booleanValue() && (tmpDO.getBeginDt().compareTo(beginDate)<=0 && tmpDO.getEndDt().compareTo(endDate)>=0))
					            {
					            	riderSolicitation = tmpDO;
					            	break;
					            }
					         
					        }
						}
				       catch (Exception ex)
				       {
				    	   log.debug("assignDiscountFromSolicitation: The solicitation code for rider is not active for current riders' effective date");
							
				       }
				       
					}
					if (riderSolicitation != null) {
						for (SolicitationDiscount sd : riderSolicitation.getSolicitationDiscountList()) {
							ArrayList<SearchCondition> solcriteria = new ArrayList<SearchCondition>();
							solcriteria.addAll(startCriteria);
							solcriteria.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.EQ, sd
									.getDiscountCd()));
							solcriteria.add(new SearchCondition(Discount.APPLIES_TO, SearchCondition.EQ,
									Discount.APPLIES_TO_RIDER));
							solDiscounts = Discount.getDiscountList(user, solcriteria, membership.getDivisionKy(),
									membership.getRegionCode(), membership.getBranchKy());
							for (Discount d : solDiscounts) {
								if (getReceivingCount(d).compareTo(d.getMemberCount()) < 0
										&& checkRequirements(d, rider)) {
									// this discount applies to riders and we
									// have not reached the maximum
									// applications.
									addDiscount(d, rider);
								}
							}
						}
					}
				}
			}
			// member level discounts.
			String memberSolicitationCd = member.getSolicitationCd();
			if (memberSolicitationCd != null) {
				Solicitation memberSolicitation = null;
				try {
					memberSolicitation = Solicitation.getSolicitation(user, memberSolicitationCd);
				} catch (Exception e) {
					// may not be active
                    log.debug("assignDiscountFromSolicitation: The solicitation code for member is not active for today");
				}
				if (memberSolicitation != null) {
					for (SolicitationDiscount sd :  memberSolicitation.getSolicitationDiscountList()) {
						ArrayList<SearchCondition> solcriteria = new ArrayList<SearchCondition>();
						solcriteria.addAll(startCriteria);
						solcriteria.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.EQ, sd
								.getDiscountCd()));
						solcriteria.add(new SearchCondition(Discount.APPLIES_TO, SearchCondition.EQ,
								Discount.APPLIES_TO_MEMBER));
						solDiscounts = Discount.getDiscountList(user, solcriteria, membership.getDivisionKy(),
								membership.getRegionCode(), membership.getBranchKy());
						for (Discount d : solDiscounts) {
							if (getReceivingCount(d).compareTo(d.getMemberCount()) < 0 && checkRequirements(d, member)) {
								// this discount applies to members and we have
								// not reached the maximum applications.
								addDiscount(d, member);
								// make sure non-basic riders get their solicitation code
								// set correctly for the discount
								for (Rider r:member.getRiderList()) {
									if (!r.isCancelled() && !memberSolicitation.getSolicitationCd().equals(r.getSolicitationCd())) {
										r.setSolicitationCd(memberSolicitation.getSolicitationCd());
									}
								}
							}
						}
					}
				}
			}
		}
		String membershipSolicitationCd = membership.getPrimaryMember().getSolicitationCd();
		if (membershipSolicitationCd != null) {
			// membership level discounts.
			Solicitation membershipSolicitation = null;
			try {
				membershipSolicitation = Solicitation.getSolicitation(user, membershipSolicitationCd);
			} catch (Exception e) {
				// may not be active
				log.debug("assignDiscountFromSolicitation: The solicitation code for membership is not active for today");
			}
			if (membershipSolicitation != null) {
				for (SolicitationDiscount sd :  membershipSolicitation.getSolicitationDiscountList()) {
					ArrayList<SearchCondition> solcriteria = new ArrayList<SearchCondition>();
					solcriteria.addAll(startCriteria);
					solcriteria.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.EQ, sd.getDiscountCd()));
					solcriteria.add(new SearchCondition(Discount.APPLIES_TO, SearchCondition.EQ,
							Discount.APPLIES_TO_MEMBERSHIP));
					solDiscounts = Discount.getDiscountList(user, solcriteria, membership.getDivisionKy(), membership
							.getRegionCode(), membership.getBranchKy());
					for (Discount d : solDiscounts) {
						// my assumption is we can only receive a particular
						// membership level discount once,
						// since we are not able to set the member count on the
						// discount maintenance screen.
						if (getReceivingCount(d).compareTo(BigDecimal.ONE) < 0 && checkRequirements(d, membership)) {
							addDiscount(d, membership);
							// make sure non-basic riders get their solicitation code
							// set correctly for the discount
							for (Member member:membership.getMemberList()) {
								if (member.isCancelled()) continue;
								if (!membershipSolicitation.getSolicitationCd().equals(member.getSolicitationCd())) {
									member.setSolicitationCd(membershipSolicitation.getSolicitationCd());
								}
								for (Rider r:member.getRiderList()) {
									if (!r.isCancelled() && !membershipSolicitation.getSolicitationCd().equals(r.getSolicitationCd())) {
										r.setSolicitationCd(membershipSolicitation.getSolicitationCd());
									}
								}
							}
						}
					}
				}
			}
		}
	}

	/**
	 * This routine adds only the head discount, it doesn't deal with changing
	 * existing child discount records. That happpens in the "distribute"
	 * methods.
	 * 
	 * @param discount
	 *            (applies to membership)
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	protected void addDiscount(Discount discount, Discountable obj) throws SQLException, ObjectNotFoundException {
		long dk = discount.getDiscountKy().longValue();
		DiscountHistory newDH = null;		
		discountCodes.add(discount.getDiscountCd());
		//wwei JRDR due to old member getDiscountHistory	
		//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
		for (DiscountHistory dh:obj.getDiscountHistoryList()) {
			if (dh.getDiscountCd().equals(discount.getDiscountCd())) {
				if (dh.isReadOnly()) return;
				newDH = dh;
				break;
			}
		}
		//wwei JRDR due to the search function problem, if newDH is null 
		//we need do further search
		if( newDH == null)
		{
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if (discount.getDiscountCd().equals("JRDR"))
			{
				if( obj instanceof Member)
				{
					Member mbr = (Member)obj;
					for (DiscountHistory dh: mbr.getFullDiscountHistoryList()) 
					{
						if (dh.getDiscountCd().equals(discount.getDiscountCd())) 
						{
							if (dh.isReadOnly()) return;
							newDH = dh;
							break;
						}
					}
				}
			}
		}		
		if (newDH == null) {
			newDH = new DiscountHistory(user, null, false);
			newDH.setDiscountKy(dk);
			newDH.setCostEffectiveDt(obj.getDiscountCostEffectiveDt(discount.isApplyAtRenewal()));
			newDH.setDiscountCd(discount.getDiscountCd());
			newDH.setPaymentMethodCd("DISCNT");
			//wwei JRDR make sure discount flag is sustaintable
			//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
			//Make it sustainale as the market code is wiped out after discount is applied
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if( discount.getDiscountCd().equalsIgnoreCase("JRDR") || discount.isApplyAtRenewal() )
			{
				newDH.setSustainableFl(true);
			}
			obj.addDiscount(newDH);
			
		}
		newDH.setAttribute("KEEP",true);
		//wwei JRDR add JRDR discount must be full cost,not prorated cost
		//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
		if(discount.getDiscountCd().equalsIgnoreCase("JRDR") )
		{
			newDH.setAmount(calculateFullTermAmount(obj));
		}
		else
			newDH.setAmount(calculateAmount(discount, obj));		
		newDH.setOriginalAt(newDH.getAmount());
	}
	
	
	//wwei JRDR function calculate full cost 
	//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore, but keep it
	private BigDecimal calculateFullTermAmount(Discountable obj )
	{
		BigDecimal totalCost = BigDecimal.ZERO;
		Member member = (Member) obj;
		try {
			for(Rider rider : member.getRiderList())
			{			
				CostBP costBP = BPF.get(membership.getUser(), CostBP.class);
				//Prakash - 07/16/2018 - Dues By State - Start
				CostData costResult = costBP.getRiderCost(membership, rider, user.getStringAttribute("ClubCode"), rider.getBillingCategoryCd(), membership.getRegionCode(),
						membership.getDivisionKy(), membership.getBranchKy(), rider.getRiderCompCd(), member.getMemberTypeCd(), member
								.getMemberExpirationDt(), "PRIMARY", member, "N", membership.getMembershipTypeCd(), membership.getDuesState());
				//Prakash - 07/16/2018 - Dues By State - End
				totalCost = totalCost.add(costResult.getFullCost());
			}
		} catch (BusinessProcessException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//webmember need return negative discount 
		return totalCost = totalCost.abs().negate().setScale(2, BigDecimal.ROUND_HALF_UP);
	}

	private BigDecimal calculateAmount(Discount discount, Discountable obj) throws SQLException, ObjectNotFoundException {
		BigDecimal amt = ZERO;
		if (!discount.isPercent()) {
			// it's not a percentage.
			amt = discount.getAmount();
			if (obj instanceof PayableComponent) {
				BigDecimal due = amountDue((PayableComponent)obj,discount.getDiscountCd());
				if (amt.compareTo(due) > 0) {
					MembershipComment cmt = new MembershipComment(user,(BigDecimal)null, false);
					cmt.setAttribute("DiscountBP","Y");
					cmt.setParentMembership(membership);
					cmt.setCommentTypeCd(MembershipComment.TYPE_SYSTEM);
					cmt.setCreateDt(new Timestamp(System.currentTimeMillis()));
					cmt.setCreateUserId(user.userID);
					cmt.setComments(discount.getName()+" for $"+amt.setScale(2)+" reduced to amount due of $"+due.setScale(2)+" on "+((PayableComponent)obj).getIdentifier());
					amt = due;
				}
			}
		} else {
			// it's a percentage
			amt = ZERO;
			if (discount.appliesToRider() ){	
				
				amt = ((Rider) obj).getDuesCostAt();
				//if there is a write of  amount less than the allowed write off , any operation in membership makes the rider pending.
				//so skip the write off amount while calculating discount amt
				if(((Rider) obj).getDuesAdjustmentAt().abs().compareTo(new BigDecimal(0)) !=0)
				{
					if(((Rider) obj).getDuesAdjustmentAt().abs().compareTo(getUnderPayWriteOffAmt()) > 0)
					{
						amt = ((Rider) obj).getDuesCostAt().add(((Rider) obj).getDuesAdjustmentAt());
					}
			    }			  
					 
			} else if (discount.appliesToMember()) {
				for (Rider r : ((Member) obj).getRiderList()) {
					if (!r.isCancelled() && r.getFutureCancelDt() == null) 
					{
						//wwei JRDR if paid in full and try to upgrade, don't calculate JRDR upgrade discount
						//condition 1. upgrade  UM 2. PIF membership due <= 0 	
						//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
						if( discount.getDiscountCd().equals("JRDR") && r.getBillingCd().equalsIgnoreCase("UM") && membership.getDuesCostAt().compareTo(ZERO) <= 0 ) 
						{
							continue;
						}						
						amt = amt.add(r.getDuesCostAt().add(r.getDuesAdjustmentAt()));
					}
				}
			} else if (discount.appliesToMembership()) {
				for (Member m : ((Membership) obj).getMemberList()) {
					if (!m.isCancelled() && !m.isFutureCancel()) {
						for (Rider r : m.getRiderList()) {
							if (!r.isCancelled() && r.getFutureCancelDt() == null) {
								amt = amt.add(r.getDuesCostAt().add(r.getDuesAdjustmentAt()));
							}
						}
					}
				}
			} else if (discount.appliesToFee()) {
				amt = ((MembershipFees) obj).getFeeAt();
			}
			amt = amt.setScale(2).multiply(discount.getAmount()).divide(new BigDecimal("100.00"));
		}
		amt = amt.abs().negate().setScale(2, BigDecimal.ROUND_HALF_UP);
		return amt;
	}
	
	public BigDecimal getUnderPayWriteOffAmt(){
		BigDecimal writeOffAmt = ClubProperties.getBigDecimal("UnderPayWriteOffThreshold", user.getAttributeAsBigDecimal("DIVISION_KY"), user.getAttributeAsString("REGION_CD"));
			if (writeOffAmt != null ) {
				return writeOffAmt;
		}
		return BigDecimal.ZERO;
	}

	/********************************************************************************
	 * ELIGIBILITY METHODS *
	 ********************************************************************************/

	/**
	 * Checks xml and basic business rule logic to see if the given object m
	 * (Can be Membership,Member,Rider) is eligible for the given riderCompCd.
	 * If there is no xml test for the given riderCompCd, it will return
	 * defaultResponse.
	 * 
	 * @param discountCode
	 * @param m
	 * @return boolean
	 * @throws InvocationTargetException
	 * @throws IllegalAccessException
	 * @throws IllegalArgumentException
	 */
	@SuppressWarnings("unchecked")
	private boolean checkRequirements(Discount disc, Discountable m) throws IllegalArgumentException,
			IllegalAccessException, InvocationTargetException, Exception {
		Discountable o = (Discountable) m.clone();
		// before going to the xml methods, check the basics on the discount to
		// begin with

		if (disc == null) {
			return false; // jic, but honestly, if this is null, we have a
			// problem
		}

		Membership membership = null;
		Member member = null;
		Rider rider = null;
		if (m instanceof Membership) {
			membership = (Membership) m;
			// if they are active and already have it, don't take it away
			if (membership.isActive()) {
				for (DiscountHistory dh:membership.getDiscountHistoryList()) {
					if (dh.getDiscountKy().compareTo(disc.getDiscountKy()) == 0) {
						return true;
					}
				}
			}
			if (membership.isCancelled() || membership.isFutureCancel()) return false;
			member = membership.getPrimaryMember();
			rider = member.getBasicRider();
			if (disc.getRegionCd() != null
					&& (membership.getRegionCode() == null || !disc.getRegionCd().equalsIgnoreCase(
							membership.getRegionCode()))) {
				return false;
			}
			if (disc.getBranchKy() != null
					&& (membership.getBranchKy() == null || disc.getBranchKy().compareTo(membership.getBranchKy()) != 0)) {
				return false;
			}
			if (disc.getDivisionKy() != null
					&& (membership.getDivisionKy() == null || disc.getDivisionKy()
							.compareTo(membership.getDivisionKy()) != 0)) {
				return false;
			}
			if (disc.getNewOnlyFl() && member.getBasicRider().getEffectiveDt() != null && !alreadyHasDiscount(disc,m)) {
				return false;
			}
			if (disc.getRenewOnlyFl() && !alreadyHasDiscount(disc,m) && (!member.inRenewal() || "NM".equals(member.getBillingCd()))) {
				if (!disc.isApplyAtRenewal()) {
					return false;
				}
			}
			if (disc.isPercent() && (amountDue(membership,disc.getDiscountCd()).compareTo(ZERO) == 0)) {
				return false;
			}
			//AGI - PC: just uses ApplyatRenewal for certain discounts  like AR10DS with no other flags checked that gets applied for new members
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if (!disc.getDiscountCd().equalsIgnoreCase("JRDR") &&
					!alreadyHasDiscount(disc,m) && (!member.inRenewal() || "NM".equals(member.getBillingCd()))) {
				if (disc.isApplyAtRenewal() && !disc.getNewOnlyFl() ) {
					return false;
				}
			}						
		}
		if (m instanceof Member) {
			member = (Member) m;
			// if they are active and already have it, don't take it away
			if (member.isActive()) {
				for (DiscountHistory dh:member.getDiscountHistoryList()) {
					if (dh.getDiscountKy().compareTo(disc.getDiscountKy()) == 0) {
						return true;
					}
				}
			}
			if (member.isCancelled() || member.isFutureCancel()) return false;
			membership = member.getParentMembership();
			rider = member.getBasicRider();
			if (!((Member) m).getMemberTypeCd().equalsIgnoreCase(disc.getMemberTypeCd())) {
				return false;
			}
			if (disc.getRegionCd() != null
					&& (member.getParentMembership().getRegionCode() == null || !disc.getRegionCd().equalsIgnoreCase(
							member.getParentMembership().getRegionCode()))) {
				return false;
			}
			if (disc.getBranchKy() != null
					&& (member.getParentMembership().getBranchKy() == null || disc.getBranchKy().compareTo(
							member.getParentMembership().getBranchKy()) != 0)) {
				return false;
			}
			if (disc.getDivisionKy() != null
					&& (member.getParentMembership().getDivisionKy() == null || disc.getDivisionKy().compareTo(
							member.getParentMembership().getDivisionKy()) != 0)) {
				return false;
			}
			if (disc.isPercent() && (amountDue(member,disc.getDiscountCd()).compareTo(ZERO) == 0)) {
				return false;
			}
			if (disc.getNewOnlyFl() && !alreadyHasDiscount(disc,m) && member.getBasicRider().getEffectiveDt() != null) {
				return false;
			}
			//wwei/preethi remove discount JRDR
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if (disc.getDiscountCd().equalsIgnoreCase("JRDR") )
				{
				   SortedSet<MemberCode> memberCodes = member.getMemberCodeList();				
				   //loop through codes.  If there, then Y, else N.
				  for(MemberCode mc : memberCodes){
					//Check if NO JRDR flag set for this member.
					if("NOJRDR".equals(mc.getCode())){
						return false;
					}				
				}
				 
			}
			if (disc.getRenewOnlyFl() && !alreadyHasDiscount(disc,m) && (!member.inRenewal() || "NM".equals(member.getBillingCd()))) {
				return false;
			}
			
			//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
			//don't offer RE discounts for new members or rider coverages
		    //PC : 11/24/17: NM members if added to an existing renewal membership should 
			//be allowed to have discount; but not a brand new membership
			if (disc.isApplyAtRenewal() && (member.getParentMembership().isNew())) {
				return false;
			}
			
		}

		if (m instanceof Rider) {
			rider = (Rider) m;
			// if they are active and already have it, don't take it away
			if (rider.isActive()) {
				for (DiscountHistory dh:rider.getDiscountHistoryList()) {
					if (dh.getDiscountKy().compareTo(disc.getDiscountKy()) == 0) {
						return true;
					}
				}
			}
			if (rider.isCancelled() || rider.getFutureCancelDt() != null) return false;
			member = rider.getParentMember();
			membership = member.getParentMembership();
			// new&renew flags apply to the rider only
			if (disc.getNewOnlyFl() && !alreadyHasDiscount(disc,m) && rider.getEffectiveDt() != null) {
				// The costEffectiveDt is null until payment is taken - this is
				// better than the isNew Flag on the dataObject
				return false;
			}
			if (!member.getMemberTypeCd().equalsIgnoreCase(disc.getMemberTypeCd())) {
				return false;
			}
			// Is this a renew only discount - is this member in renewal
			if (disc.getRenewOnlyFl() && !alreadyHasDiscount(disc,m)
					&& (!rider.getParentMember().inRenewal() || "NM".equals(rider.getParentMember().getBillingCd()))) {
				return false;
			}
			// Is the rider code on the discount = ridercompcd on rider
			if (!rider.getRiderCompCd().equalsIgnoreCase(disc.getRiderCompCd())) {
				return false;
			}
			if (disc.getRegionCd() != null
					&& (rider.getParentMember().getParentMembership().getRegionCode() == null || !disc.getRegionCd()
							.equalsIgnoreCase(rider.getParentMember().getParentMembership().getRegionCode()))) {
				return false;
			}
			if (disc.getBranchKy() != null
					&& (rider.getParentMember().getParentMembership().getBranchKy() == null || disc.getBranchKy()
							.compareTo(rider.getParentMember().getParentMembership().getBranchKy()) != 0)) {
				return false;
			}
			if (disc.getDivisionKy() != null
					&& (rider.getParentMember().getParentMembership().getDivisionKy() == null || disc.getDivisionKy()
							.compareTo(rider.getParentMember().getParentMembership().getDivisionKy()) != 0)) {
				return false;
			}
			if (disc.isPercent()) {
				if (amountDue(rider,disc.getDiscountCd()).compareTo(ZERO) <= 0) {
					return false;
				}
			}
			//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
			//don't offer RE discounts for new members or rider coverages
			if (disc.isApplyAtRenewal() && (!rider.getParentMember().inRenewal() || "NM".equals(rider.getParentMember().getBillingCd()))) {
				return false;
			}

		}

		Element root = configuration.getRootElement();
		String xmlMethodNameText = null;
		Attribute operation = null;
		Attribute negation = null;
		Attribute returnValue = null;
		Attribute regExpValue = null;
		Attribute parameter = null;
		
		//Debugging block setup
		String discountCodeInterested = "ML";
		boolean hasDiscountCodeInterested = false; 

		Iterator<Element> iter = root.elementIterator();
		Method[] methodList = m.getClass().getMethods();
		boolean xmlRuleForDiscount = false;
		while (iter.hasNext()) {// loop through <discount></discount> tags
			Element e = iter.next();
			Iterator<Element> i = e.elementIterator();

			while (i.hasNext()) {
				// make a loop to find the code
				Element ele = i.next();
				if (ele.getName().equalsIgnoreCase("code")) {
					if (disc.getDiscountCd().equals(ele.getText())) {
						xmlRuleForDiscount = true;
						
						
						//uncomment to the particular discount code in interest
						if (discountCodeInterested.equals(ele.getText())) {
							hasDiscountCodeInterested = true; 
						}
						
						
								
						break;
					}
				}
			}
			
			 
			i = e.elementIterator();// resset loop

			if (xmlRuleForDiscount) {
				// now we check the requirements set in the xml.
				boolean metAllXmlRequirements = true;

				while (i.hasNext()) {// this time perform xml configuration
					// checks
					Element ele = i.next();
					if (ele.getName().equalsIgnoreCase("test")) {
						xmlMethodNameText = ele.getText();

						operation = ele.attribute(OPERATION);
						negation = ele.attribute(NEGATION);
						returnValue = ele.attribute(RETURN_VALUE);
						regExpValue = ele.attribute(REGEXP_VALUE);
						parameter = ele.attribute(PARAMETER);

						// let's be sure that we are checking the appropriate
						// object.
						if (ele.attribute(OBJECT) != null) {
							String objectText = ele.attribute(OBJECT).getText();
							if ("rider".equalsIgnoreCase(objectText) && rider != null) {
								methodList = rider.getClass().getMethods();
								o = rider;
							} else if ("member".equalsIgnoreCase(objectText) && member != null) {
								methodList = member.getClass().getMethods();
								o = member;
							} else if ("membership".equals(objectText) && membership != null) {
								methodList = membership.getClass().getMethods();
								o = membership;
							}
						}

						// perform the test
						for (Method me : methodList) {
							if (xmlMethodNameText.equals(me.getName())) {
								// invoke the method, if the paramater is null,
								// then pass no params
								// otherwise pass the param requested
								Object[] args;
								if (parameter == null) {
									args = null;
								} else {
									args = new Object[1];
									args[0] = parameter.getText();
								}// end if
								try
								{
									Object methodValue = me.invoke(o, args);
									Object assumedType = findAssumedType(returnValue, regExpValue);
									if (!doTest(methodValue, assumedType, negation, operation)) {
										metAllXmlRequirements = false;
									}
								}
								catch(Exception exp)
								{
									log.error("Failed in invoking method " + me.getName());
								}
								// we're good if we get here
								break;
							}// end if
						}// end for
					}// end <test> if
				}// end <code><test> xml while
				return metAllXmlRequirements;
			}// end found the right <discount> xml if
		}// end <discount> while looop
		if (!xmlRuleForDiscount) {
			return true; // This means there were no xml rules for this we just
			// want to give them a discount
		}
		return false;
	}// checkXmlRequirements

	/**
	 * For "new only" and "renew only", if the discount is already established for the
	 * object, do not remove it.  This keeps operations like Extend Expiration, which
	 * could happen after the membership is established, from removing a discount the
	 * membership got when created.  There are many other scenarios that would cause 
	 * problems.  The basic rule is, once a (re)new only discount has been applied,
	 * don't remove it simply on that basis.
	 * 
	 * @param discount
	 * @param discountable
	 * @return True if the discountable object already has that discount.
	 * @throws SQLException
	 */
	private boolean alreadyHasDiscount(Discount discount, Discountable discountable) throws SQLException {
		for (DiscountHistory dh:discountable.getDiscountHistoryList()) {
			if (dh.getDiscountKy().compareTo(discount.getDiscountKy())==0) 
				return true;
		}
		return false;
	}
	/**
	 * This method returns an object of an assumed type given the value. This
	 * will support only the basic primitives boolean, numeric(double), or
	 * alpha(String).
	 * 
	 * All values are wrapped in an object.
	 * 
	 * @param value
	 * @return Object
	 */
	private Object findAssumedType(Attribute valObj, Attribute regExpObj) {
		if (valObj != null) {
			String value = valObj.getText();
			if (value.equalsIgnoreCase("true") || value.equalsIgnoreCase("y")) {
				return true;
			} else if (value.equalsIgnoreCase("false") || value.equalsIgnoreCase("n")) {
				return false;
			}
			// so I guess we're not a boolean, try a double
			try {
				return (new BigDecimal(Double.parseDouble(value))).stripTrailingZeros();
			} catch (Exception e) {
				// guess not...
			}
			return valObj.getText();
		}
		if (regExpObj != null) {
			return Pattern.compile(regExpObj.getText());
		}
		return null;
	}// end findAssumedType

	/**
	 * This method tests assumedType against methodValue given the conditions
	 * passed in.
	 * <ul>
	 * <li>If not/operation are both null then it tests metodValue ==
	 * assumedType</li>
	 * <li>If only operation is null then it tests methodValue != assumedType</li>
	 * </ul>
	 * operation can only contain {&gt;|&lt;|&gt;=|&lt;=} and it will test
	 * against these operators. assumedType and methodValue must be of some
	 * numeric type. If it is not, then it will return false
	 * 
	 * @param methodValue
	 * @param assumedType
	 * @param not
	 * @param operation
	 * @return boolean
	 * @throws Exception
	 */
	private boolean doTest(Object methodValue, Object assumedType, Attribute not, Attribute operation) throws Exception {
		if (assumedType instanceof Pattern) {
			try {
				Matcher m = ((Pattern) assumedType).matcher((String) methodValue);
				return not == null ? m.matches() : !m.matches();
			} catch (Exception e) {
				log.error("Regular expression failed on comparison. " + StackTraceUtil.getStackTrace(e));
				return false;
			}
		}

		if (operation == null) {
			if (not == null) {
				if (!methodValue.equals(assumedType)) {
					// if we're here we failed, so set false and get out
					return false;
				}// end if
			} else {
				if (methodValue.equals(assumedType)) {
					// if we're here we failed, so set false and get out
					return false;
				}// end if
			}// end if
			return true;
		}// end if

		// ok we have an operation, we need to test for it.
		String operator = operation.getValue();
		// not handling, just in case someone is odd and negates a comparitor.
		if (not != null)
			if (operator.charAt(0) == '>') {
				operator.replace('>', '<');
			} else {
				operator.replace('<', '>');
			}

		if (!(methodValue instanceof Double) && !(assumedType instanceof Double)) {
			return false;
		}// end if

		Double left = new Double(methodValue.toString());
		Double right = new Double(assumedType.toString());
		int compare = left.compareTo(right);
		// easy case, if it's equal and the operator is >= or <=
		if (compare == 0 && operator.contains("="))
			return true;
		if (compare < 0 && operator.contains("<"))
			return true;
		if (compare > 0 && operator.contains(">"))
			return true;

		return false;
	}// end doTest

	/**
	 * 
	 * @param membership
	 * @param discount
	 * @return
	 * @throws SQLException
	 */
	private BigDecimal getReceivingCount(Discount discount) throws SQLException {
		BigDecimal count = ZERO;
		if (discount.appliesToMembership()) {
			for (DiscountHistory sdh : membership.getDiscountHistoryList()) {
				if (sdh.isRowDeleted())	continue;
				if (!(Boolean)sdh.getAttribute("KEEP")) continue;
				if (sdh.getDiscountKy().compareTo(discount.getDiscountKy()) == 0 ) {
					count = count.add(BigDecimal.ONE);
				}
			}
		}
		else {
			for (Member member : membership.getMemberList()) {
				if (member.isCancelled() || member.isFutureCancel()) continue;
				if (discount.appliesToMember()) {
					for (DiscountHistory mdh : member.getDiscountHistoryList()) {
						if (mdh.isRowDeleted())	continue;
						if (!(Boolean)mdh.getAttribute("KEEP")) continue;
						if (mdh.getDiscountKy().compareTo(discount.getDiscountKy()) == 0) {
							count = count.add(BigDecimal.ONE);
						}
					}
				}
				if (discount.appliesToRider()) {
					for (Rider rider : member.getRiderList()) {
						if (rider.isCancelled() || rider.getFutureCancelDt()!=null) continue;
						for (DiscountHistory rdh : rider.getDiscountHistoryList()) {
							if (rdh.isRowDeleted())	continue;
							if (!rdh.getDiscountCd().equals(discount.getDiscountCd())) continue;
							if (!(Boolean)rdh.getAttribute("KEEP")) continue;
							if (rdh.isRowDeleted()) continue;
							//TR 3264 - adds the discount back after setting it to zero
							//TR 3342 - fix to check the absolute value to get the count right
							if (rdh.getAmount().abs().intValue() > 0)
								count = count.add(BigDecimal.ONE);
						}
					}
				}
			}
		}
		return count;
	}

	/********************************************************************************
	 * DISPERSAL METHODS *
	 ********************************************************************************/

	protected void disperseDiscountsProportionately() throws SQLException, ObjectNotFoundException {
		// First, membership level discounts
		BigDecimal memberCt = ZERO;

		// Membership level discounts
		outer: for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			Discount discount = dh.getParentDiscount();
			if (!discountIsQualified(discount,dh,membership.getPrimaryMember())) {
				continue;
			}
			dh.setAmount(dh.getOriginalAt());

			// if it's not a percentage discount, manually build
			// percent rates for all eligible components.
			// for each component, we need to record the key (rider
			// or fee) and the percentage
			Map<BigDecimal, BigDecimal> discountMap = new HashMap<BigDecimal, BigDecimal>();
			if (!discount.isPercent()) {
				discountMap = buildPercentMap(dh);
			}

			memberCt = ZERO;
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				memberCt = memberCt.add(BigDecimal.ONE);
				if (discount.getMemberCount() != null && discount.getMemberCount().intValue() > 0
						&& discount.getMemberCount().compareTo(memberCt) < 0)
					continue;
				if (discount.isRenewOnly() && !m.inRenewal())
					continue;
				buildComponentDiscounts(m, dh, discount, discountMap);
			}
			memberCt = ZERO;
			if (!discount.isPercent() && dh.getAmount().compareTo(ZERO) != 0) {
				// didn't quite get it all
				for (Member m : membership.getMemberList()) {
					if (m.isCancelled() || m.isFutureCancel()) continue;
					if (dh.getAmount().compareTo(ZERO) == 0)
						break;
					memberCt = memberCt.add(BigDecimal.ONE);
					if (discount.getMemberCount() != null && discount.getMemberCount().intValue() > 0
							&& discount.getMemberCount().compareTo(memberCt) < 0)
						continue;
					if (discount.isRenewOnly() && !m.inRenewal())
						continue;
					for (PayableComponent pc : m.getPayableComponentList()) {
						if (pc instanceof DonationHistory)
							continue;
						if (dh.getAmount().compareTo(ZERO) == 0)
							break;
						if (discountMap.containsKey(pc.getKey())) {
							if (finishOffDiscount(pc, dh)) {
								break;
							}
						}
					}
				}
			}
		}
		// Next, member level discounts
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				Discount discount = dh.getParentDiscount();
				if (!discountIsQualified(discount,dh,membership.getPrimaryMember()))
					continue;
				dh.setAmount(dh.getOriginalAt());
				// if it's not a percentage discount, manually build
				// percent rates
				// for all eligible components.
				// for each component, we need to record the key
				// (rider or fee) and the percentage
				Map<BigDecimal, BigDecimal> discountMap = new HashMap<BigDecimal, BigDecimal>();
				if (!discount.isPercent()) {
					discountMap = buildPercentMap(dh, m);
				}
				buildComponentDiscounts(m, dh, discount, discountMap);
				if (!discount.isPercent() && dh.getAmount().compareTo(ZERO) != 0) {
					// didn't quite get it all
					for (PayableComponent pc : m.getPayableComponentList()) {
						if (dh.getAmount().compareTo(ZERO) == 0)
							break;
						if (discountMap.containsKey(pc.getKey())) {
							if (finishOffDiscount(pc, dh)) {
								break;
							}
						}
					}
				}
			}
		}
	}

	private boolean discountIsQualified(Discount discount, DiscountHistory dh, Member m) throws SQLException {
		if (!dh.getCostEffectiveDt().before(m.getActiveExpirationDt()))
			return false;
		
		//7/17/2017 PC : Cannot give apply at renewal discounts to new members
		if (discount.isPercent() && discount.isApplyAtRenewal() && !m.inRenewal())
			return false;
				
		if (discount.isRenewOnly() && !m.inRenewal())
			return false;
		if (!discount.isPercent() && dh.getOriginalAt().compareTo(ZERO) == 0)
			return false;
		return true;
	}
	/**
	 * Discount has been distributed, but there's some left over, usually
	 * because the calculated discount was more than could be discounted on one
	 * or more components.
	 * 
	 * @param pc
	 * @param dh
	 * @return
	 * @throws SQLException
	 */
	protected boolean finishOffDiscount(PayableComponent pc, DiscountHistory dh) throws SQLException {
		BigDecimal riderDues = pc.getDuesCostAt().add(pc.getDuesAdjustmentAt());
		BigDecimal riderCost = riderDues.subtract(pc.getPaymentAt());
		BigDecimal currentDiscounts = ZERO;
		DiscountHistory newDiscount = null;
		for (DiscountHistory rdh : pc.getDiscountHistoryList()) {
			if (rdh.getCostEffectiveDt().before(pc.getCostEffectiveDt()))
				continue;
			if (!rdh.getCostEffectiveDt().before(pc.getParentMember().getActiveExpirationDt()))
				continue;
			if (rdh.getParentDiscountHistoryKy() != null
					&& rdh.getParentDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy()) == 0) {
				newDiscount = rdh;
			}
			currentDiscounts = currentDiscounts.add(rdh.getAmount());
		}
		if (newDiscount == null)
			return false;
		BigDecimal available = riderCost.add(currentDiscounts);
		if (available.compareTo(ZERO) == 0)
			return false;
		BigDecimal additionalDiscount = dh.getAmount();
		if (available.add(additionalDiscount).compareTo(ZERO) < 0) {
			// can't put the full amount here
			additionalDiscount = available.negate();
		}
		newDiscount.setAmount(newDiscount.getAmount().add(additionalDiscount));
		dh.setAmount(dh.getAmount().subtract(additionalDiscount));
		dh.setAttribute("KEEP",true);
		return dh.getAmount().compareTo(ZERO) == 0;
	}

	/**
	 * This dispersal method attempts to take as much of the discount as
	 * possible with the first installment. It fully discounts fees first, then
	 * proportionately allocates the discount across all riders.
	 * 
	 * @param ms
	 * @return
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 * @throws NoPaymentPlanException
	 */
	protected void disperseDiscountsToInstallments() throws SQLException, ObjectNotFoundException,
			NoPaymentPlanException {
		// get the payment plan
		PaymentPlan plan = null;

		//KK 11/03/2010 TR 3271
		//Initially the payment billing plan was based entirely on Basic Rider 
		//If basic rider is paid already an membership needs to be put on installment plan the payment structure page was failing
		//Following change looks for the Plus or higher rider if basic is already paid
		for(Rider r : membership.getPrimaryMember().getRiderList()){
			if(!r.isCancelled()){
				for(PlanBilling pb : r.getPlanBillingList())
				{
					if(pb != null && pb.getPaymentStatus().equals("U"))
					{
						plan = pb.getParentPaymentPlan();
						break;
					}
				}	
			}
		}
		//Changes by Karan Kapoor ends - TR 3271
		//Changes by KK - TR 3433 12/23/2010
		//Change for specialty Memberships with associate on Payment Plan 
		if (plan == null)
		{
			if (membership.isSpecialtyMembership())
			{
				for(Member m : membership.getMemberList())
				{
					for(Rider r : m.getRiderList())
					{
						if(!r.isCancelled()){
							for(PlanBilling pb : r.getPlanBillingList())
							{
								if(pb != null && pb.getPaymentStatus().equals("U"))
								{
									plan = pb.getParentPaymentPlan();
									break;
								}
							}	
						}
					}
				}
			}
		}
		//Changes by KK - TR 3433 12/23/2010
		
		if (plan == null) {
			throw new NoPaymentPlanException();
		}

		// process member level discounts
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;

			// first, percentage discounts
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.getAmount().compareTo(ZERO) == 0)
					continue;
				if (!dh.getCostEffectiveDt().before(m.getActiveExpirationDt()))
					continue;
				Discount discount = dh.getParentDiscount();
				if (!discount.isPercent())
					continue;
				Map<BigDecimal, BigDecimal> discountMap = new HashMap<BigDecimal, BigDecimal>();
				if (!discount.isPercent()) {
					discountMap = buildPercentMap(dh, m);
				}
				buildComponentDiscounts(m, dh, discount, discountMap);
			}
			// amount discounts
			//
			// for installment pay memberships, we discount the fees first,
			// then proportionately discount the riders.
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.getAmount().compareTo(ZERO) == 0)
					continue;
				if (!dh.getCostEffectiveDt().before(m.getActiveExpirationDt()))
					continue;
				Discount discount = dh.getParentDiscount();
				if (discount.isPercent())
					continue;
				BigDecimal discountAmount = dh.getAmount().abs();
				for (MembershipFees fee : m.getMembershipFeesList()) {
					BigDecimal due = amountDue(fee,dh.getDiscountCd());
					BigDecimal discountAt = ZERO;
					if (due.compareTo(ZERO) <= 0)
						continue;
					if (discountAmount.compareTo(due) > 0) {
						discountAt = due;
						discountAmount = discountAmount.subtract(due);
					} else {
						discountAt = discountAmount;
						discountAmount = ZERO;
					}
					if (discountAt.compareTo(ZERO) > 0)
						buildDiscount(fee, discount, dh, discountAt);
					else
						break;
				}
				// are we done?
				if (discountAmount.compareTo(ZERO) == 0)
					continue;

				// Figure the proportions of the discount to apply to each
				// rider.
				// Since the goal is to completely pay for the first installment
				// if
				// possible, we will consider all current payments and discounts
				// in calculating the proportions.
				BigDecimal ridersDue = ZERO;
				for (Rider r : m.getRiderList()) {
					if (r.getFutureCancelDt() != null)
						continue;
					ridersDue = ridersDue.add(amountDue(r,dh.getDiscountCd()));
				}
				BigDecimal originalDiscount = discountAmount;
				for (Rider r : m.getRiderList()) {
					if (r.getFutureCancelDt() != null)
						continue;
					BigDecimal amt = (amountDue(r,dh.getDiscountCd()).setScale(4).divide(ridersDue, 4, BigDecimal.ROUND_HALF_UP)
							.multiply(originalDiscount)).setScale(2, BigDecimal.ROUND_HALF_UP);
					if (amt.compareTo(discountAmount) > 0)
						amt = discountAmount;
					BigDecimal amtDue = amountDue(r,dh.getDiscountCd());
					if (amt.compareTo(amtDue) > 0)
						amt = amtDue;
					discountAmount = discountAmount.subtract(amt);
					if (amt.compareTo(ZERO) > 0)
						buildDiscount(r, discount, dh, amt);
				}

				dh.setAmount(discountAmount.negate());
			}
		}

		// Membership Discounts

		// first, percentage discounts
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.getAmount().compareTo(ZERO) == 0)
				continue;
			if (!dh.getCostEffectiveDt().before(membership.getPrimaryMember().getActiveExpirationDt()))
				continue;
			Discount discount = dh.getParentDiscount();
			if (!discount.isPercent())
				continue;
			Map<BigDecimal, BigDecimal> discountMap = new HashMap<BigDecimal, BigDecimal>();
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				buildComponentDiscounts(m, dh, discount, discountMap);
			}
		}
		// amount discounts
		//
		// for installment pay memberships, we discount the fees first,
		// then proportionately discount the riders.
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.getAmount().compareTo(ZERO) == 0)
				continue;
			if (!dh.getCostEffectiveDt().before(membership.getPrimaryMember().getActiveExpirationDt()))
				continue;
			Discount discount = dh.getParentDiscount();
			if (discount.isPercent())
				continue;
			BigDecimal discountAmount = dh.getAmount().abs();
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				for (MembershipFees fee : m.getMembershipFeesList()) {
					BigDecimal due = amountDue(fee,dh.getDiscountCd());
					BigDecimal discountAt = ZERO;
					if (due.compareTo(ZERO) <= 0)
						continue;
					if (discountAmount.compareTo(due) > 0) {
						discountAt = due;
						discountAmount = discountAmount.subtract(due);
					} else {
						discountAt = discountAmount;
						discountAmount = ZERO;
					}
					if (discountAt.compareTo(ZERO) > 0)
						buildDiscount(fee, discount, dh, discountAt);
					else
						break;
				}
				if (discountAmount.compareTo(ZERO) == 0)
					break;
			}
			// are we done?
			if (discountAmount.compareTo(ZERO) == 0)
				continue;

			// Figure the proportions of the discount to apply to each rider.
			// Since the goal is to completely pay for the first installment if
			// possible, we will consider all current payments and discounts
			// in calculating the proportions.
			BigDecimal ridersDue = ZERO;
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				for (Rider r : m.getRiderList()) {
					if (r.getFutureCancelDt() != null)
						continue;
					ridersDue = ridersDue.add(amountDue(r,dh.getDiscountCd()));
				}
			}
			BigDecimal originalDiscount = discountAmount;
			for (Member m : membership.getMemberList()) {
				if (m.isCancelled() || m.isFutureCancel()) continue;
				for (Rider r : m.getRiderList()) {
					if (r.getFutureCancelDt() != null)
						continue;
					BigDecimal amt = (amountDue(r,dh.getDiscountCd()).setScale(4).divide(ridersDue, 4, BigDecimal.ROUND_HALF_UP)
							.multiply(originalDiscount)).setScale(2, BigDecimal.ROUND_HALF_UP);
					if (amt.compareTo(discountAmount) > 0)
						amt = discountAmount;
					BigDecimal amtDue = amountDue(r,dh.getDiscountCd());
					if (amt.compareTo(amtDue) > 0)
						amt = amtDue;
					discountAmount = discountAmount.subtract(amt);
					if (amt.compareTo(ZERO) > 0)
						buildDiscount(r, discount, dh, amt);
				}
			}

			dh.setAmount(discountAmount.negate());
		}

	}
	
	private BigDecimal amountDue(PayableComponent pc, String discountCd) throws SQLException {
		BigDecimal result = pc.amountDueWithoutDiscounts();
		for (DiscountHistory dh:pc.getDiscountHistoryList()) {
			if (dh.getDiscountCd().equals(discountCd)) continue;
			result = result.add(dh.getAmount());
		}
		return result;
	}

	private BigDecimal amountDue(Member member, String discountCd) throws SQLException {
		BigDecimal result = ZERO;
		for (PayableComponent pc:member.getPayableComponentList()) {
			if (pc.isCancelled()) continue;
			result = result.add(amountDue(pc,discountCd));
		}
		return result;
	}
	
	private BigDecimal amountDue(Membership ms, String discountCd) throws SQLException {
		BigDecimal result = ZERO;
		for (Member m:ms.getMemberList()) {
			if (m.isCancelled()) continue;
			result = result.add(amountDue(m,discountCd));
		}
		return result;
	}

	private void buildDiscount(PayableComponent pc, Discount discount, DiscountHistory dh, BigDecimal amount)
			throws SQLException, ObjectNotFoundException {
		
		DiscountHistory discountHist = null;
		for (DiscountHistory newDH: pc.getDiscountHistoryList()) {
			if (newDH.getDiscountKy().equals(discount.getDiscountKy())) {
				discountHist = newDH;
				break;
			}
		}
		if (discountHist == null) {
			discountHist = new DiscountHistory(user, null, false);
			discountHist.setDiscountKy(discount.getDiscountKy());
			if (pc instanceof Rider) {
				discountHist.setParentRider((Rider) pc);
			} else if (pc instanceof MembershipFees) {
				discountHist.setParentMembershipFees((MembershipFees) pc);
			}
			discountHist.setDiscountCd(discount.getDiscountCd());
			discountHist.setAttribute("PRIOR_AMOUNT",ZERO);
		}
		discountHist.setCostEffectiveDt(pc.getCostEffectiveDt().after(dh.getCostEffectiveDt()) ? pc
				.getCostEffectiveDt() : dh.getCostEffectiveDt());

		discountHist.setParentDiscountHistoryKy(dh.getDiscountHistoryKy());
		discountHist.setSustainableFl(false);
		discountHist.setPaymentMethodCd(dh.getPaymentMethodCd());
		discountHist.setOriginalAt(amount.abs().negate());
		discountHist.setAmount(discountHist.getOriginalAt());
		dh.setAmount(dh.getAmount().subtract(discountHist.getAmount()));
		discountHist.setAttribute("KEEP",true);
	}

	/**
	 * This method will take all membership and member level discounts and
	 * create the appropriate rider level discounts based on the payment
	 * hierarchy. It will NOT close them out, that is the payment poster's job
	 * when the riders go active. We do not bother doing anything with discounts
	 * that are not effective for the current membership year.
	 * 
	 * @param membership
	 * @return updated membership
	 * @throws SQLException
	 */
	protected void disperseDiscountsByHierarchy(Membership membership) throws SQLException, ObjectNotFoundException {
		if (!(membership.isPending()||membership.isOnPaymentPlan()))
			return;
		// First, membership level discounts
		ArrayList<SearchCondition> phCond = new ArrayList<SearchCondition>();
		ArrayList<String> phOrder = new ArrayList<String>();
		phCond.add(new SearchCondition(Membership.MEMBERSHIP_TYPE_CD, SearchCondition.EQ, membership
				.getMembershipTypeCd()));
		phCond.add(new SearchCondition(PaymentHierarchy.DONATION_TYPE_CD, SearchCondition.ISNULL));
		phOrder.add(PaymentHierarchy.PAYMENT_SORT_NR);
		SortedSet<PaymentHierarchy> hierarchy = PaymentHierarchy.getPaymentHierarchyList(user, phCond, phOrder);
		outer: for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.getAttribute("KEEP") != null && !((Boolean)dh.getAttribute("KEEP"))) continue;
			Discount discount = dh.getParentDiscount();
			if (!discountIsQualified(discount,dh,membership.getPrimaryMember())) continue;
			
			try
			{  //AGI - PC: changes for member level and membership level discounts - to stop discount changes for end dated mkt code
				// and discount code
				java.util.Date date = new java.util.Date();			
				//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
				if (!discount.getDiscountCd().equalsIgnoreCase("JRDR") && discount.getEndDt()!=null 
						&& discount.getEndDt().before(new Timestamp(date.getTime())) )
					continue;  //if discount is end dated, don't worry about the dispered discounts
				
				String membershipSolicitationCd = membership.getPrimaryMember().getSolicitationCd();
				//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
				if (!discount.getDiscountCd().equalsIgnoreCase("JRDR") && membershipSolicitationCd != null ) {
					// membership level sol discounts.
					Solicitation membershipSolicitation = null;
					try {
						membershipSolicitation = Solicitation.getSolicitation(user, membershipSolicitationCd);
					} catch (Exception e) {
						// may not be active
						log.debug("disperseDiscountsByHierarchy: The solicitation code for membership is not active for today");						
					}
					if (membershipSolicitation != null) {
						boolean isDiscountForThisSolCd = false;
						for (SolicitationDiscount sd :  membershipSolicitation.getSolicitationDiscountList()) {
							if (sd.getDiscountCd().equalsIgnoreCase(discount.getDiscountCd()))
							{
								isDiscountForThisSolCd = true;
								break;
							}
						}
						if(isDiscountForThisSolCd){
							boolean isActive = membershipSolicitation.isCurrentActive();
							if(!isActive)  // don't build new components with this discount ; but leave the existing discounts as is...
								continue;
						}
						
					}
				}
				
			}
			catch (Exception ex)
			{
				log.error("Failed in checking if membership discount/sol code attached to discount is active or not");
			}
			
			// reset amount back to original so it can be redistributed
			if (dh.getParentDiscount().isPercent()) {
				dh.setAmount(ZERO);
				dh.setOriginalAt(ZERO);
			}
			else {
				dh.setAmount(dh.getOriginalAt().subtract(alreadyAllocated(dh)));
				if (dh.getAmount().compareTo(ZERO) == 0) continue;
			}
			
			for (PaymentHierarchy ph : hierarchy) {
				for (Member m : membership.getMemberList()) {
					if (!m.getMemberTypeCd().equals(ph.getMemberTypeCd()))
						continue;
					if (m.isCancelled() || m.isFutureCancel())
						continue;
					//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
					if ((discount.isRenewOnly() || discount.isApplyAtRenewal()) && !m.inRenewal())
						continue;
					//ISF Rules : Exclude ISF from applying discounts
		    		if(ph.getFeeTypeCd() !=null && ph.getFeeTypeCd().equals(MembershipFees.FEE_TYPE_IMMEDIATE_SERVICE_FEE))
		    			continue;
		    		
					
					buildComponentDiscounts(m, dh, discount, ph);
					if (!dh.getParentDiscount().isPercent()) {
						if (dh.getAmount().compareTo(ZERO) == 0) {
							continue outer;
						}
					}
				}
			}
		}
		// Next, member level discounts
		BigDecimal memberCt = ZERO;
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			dhLoop: for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.getAttribute("KEEP") != null && !((Boolean)dh.getAttribute("KEEP"))) continue;
				Discount discount = dh.getParentDiscount();
				if (!discountIsQualified(discount,dh,m)) continue;
				try
				{
					//AGI - PC: changes for member level and membership level discounts - to stop discount changes for end dated mkt code
					// and discount code
					java.util.Date date = new java.util.Date();			
					//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
					if (!discount.getDiscountCd().equalsIgnoreCase("JRDR") && discount.getEndDt()!=null && discount.getEndDt().before(new Timestamp(date.getTime())) )
						continue;  //if discount is end dated, don't worry about the dispered discounts
					String memberSolicitationCd = m.getSolicitationCd();
					if (memberSolicitationCd != null) {
						// member level sol discounts.
						Solicitation memberSolicitation = null;
						try {
							memberSolicitation = Solicitation.getSolicitation(user, memberSolicitationCd);
						} catch (Exception e) {
							// may not be active
							log.debug("disperseDiscountsByHierarchy: The solicitation code for member is not active for today");							
						}
						//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
						if (!discount.getDiscountCd().equalsIgnoreCase("JRDR") && memberSolicitation != null  ) {
							boolean isDiscountForThisSolCd = false;
							for (SolicitationDiscount sd :  memberSolicitation.getSolicitationDiscountList()) {
								if (sd.getDiscountCd().equalsIgnoreCase(discount.getDiscountCd()))
								{
									isDiscountForThisSolCd = true;
									break;
								}
							}
							if(isDiscountForThisSolCd)
							{
								    boolean isActive = memberSolicitation.isCurrentActive();
									if(!isActive)  // don't build new components with this discount ; but leave the existing discounts as is...
										continue;
							}
							
						}
					}
					
				}
				catch (Exception ex)
				{
					log.error("Failed in checking if member discount/sol code attached to discount is active or not");
				}
				boolean memberReceived = false;
				if (dh.getParentDiscount().isPercent()) {
					dh.setAmount(ZERO);
					dh.setOriginalAt(ZERO);
				}
				else {
					dh.setAmount(dh.getOriginalAt().subtract(alreadyAllocated(dh)));
					if (dh.getAmount().compareTo(ZERO) == 0) continue;
				}
				for (PaymentHierarchy ph : hierarchy) {
					if (!ph.getMemberTypeCd().equals(m.getMemberTypeCd()))
						continue;
					if (discount.getMemberTypeCd() != null && !discount.getMemberTypeCd().equals(m.getMemberTypeCd()))
						continue;
					if (discount.getMemberCount() != null && discount.getMemberCount().intValue() > 0
							&& discount.getMemberCount().compareTo(memberCt) < 0)
						continue;
					if (discount.isRenewOnly() && !m.inRenewal())
						continue;
					
					memberReceived = buildComponentDiscounts(m, dh, discount, ph);
					if (!dh.getParentDiscount().isPercent()) {
						if (dh.compareTo(ZERO) == 0) {
							continue dhLoop;
						}
					}
				}
				if (memberReceived) {
					// only count the member if they have received the discount
					// after passing through the hierarchy.
					memberCt = memberCt.add(BigDecimal.ONE);
				}
			}
		}
	}
	
	private BigDecimal alreadyAllocated(DiscountHistory dh) throws SQLException {
		BigDecimal result = ZERO;
		for (Member m:membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (PayableComponent pc:m.getPayableComponentList()) {
				for (DiscountHistory pcdh:pc.getDiscountHistoryList()) {
					if (pcdh.isReadOnly() && pcdh.getParentDiscountHistoryKy() != null && pcdh.getParentDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy())== 0) {
						result = result.add(pcdh.getAmount());
					}
					//AGI - PC: 8/30/16: Added for AGI member level discounts with child  sustainable flag = Y and discount with new only flag
					//This is needed to avoid The discount distributing to remaining riders even after the parent amount is completed.
					//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
					else if (!pcdh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR")  &&
							pcdh.isSustainable() && pcdh.getParentDiscountHistoryKy() != null 
							&& pcdh.getParentDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy())== 0
							&& (pcdh.getParentDiscount().appliesToMember() || pcdh.getParentDiscount().appliesToMembership())
							&& pcdh.getParentDiscount().getNewOnlyFl()==true) {
						result = result.add(pcdh.getAmount());
					}
				}
			}
		}
		return result;
	}

	/**
	 * Called by disperseDiscounts to build actual discount history records.
	 * 
	 * @param m
	 * @param dh
	 * @param discount
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	private boolean buildComponentDiscounts(Member m, DiscountHistory dh, Discount discount, PaymentHierarchy ph)
			throws SQLException, ObjectNotFoundException {
		boolean received = false;
		SortedSet<? extends PayableComponent> list = null;
		if (ph.getRiderCompCd() != null) {
			list = m.getRiderList();
		} else if (ph.getFeeTypeCd() != null) {
			list = m.getMembershipFeesList();
		}
		if (list == null) {
			return false;
		}
		outer: for (PayableComponent pc : list) {
			if (!ph.appliesTo(pc))	continue;
			if (pc.getFutureCancelDt() != null)	continue;
			if (pc.getStatus()!=null && pc.getStatus().equalsIgnoreCase("A")) continue;	//Change from Ying Huang, should not check in
			if (discount.isNewOnly() && pc.getEffectiveDt() != null) continue;
			
			/* Changed to offer Renewal discounts regardless of rider billing code (new or upgrade or renewal) 
			//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
			//PC : 11/14/17 : If there is a payment reversal, the billng code for ider changes to PR even though
			//it is still in renewal- so use a combination of membership billing code and rider billing code
			if (discount.isApplyAtRenewal())
			{
				 if(!pc.getBillingCd().equalsIgnoreCase("RM"))
				 {
					 if(!pc.getBillingCd().equalsIgnoreCase("PR") 
						        && m.getParentMembership().getBillingCd().equalsIgnoreCase("RM"))
					    continue;
					 
				 }				 
			}	*/
			
			
			DiscountHistory discountHist = null;
			for (DiscountHistory rdh : pc.getDiscountHistoryList()) {
				if (rdh.getParentDiscountHistoryKy() != null
						&& rdh.getParentDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy()) == 0) {
					// if it's readonly, it means the rider/fee is already active,
					// so we can't change the amount.  Also the amount on the 
					// parent discount has alraady been adjusted for this one.
					if (rdh.isReadOnly()) continue outer;
					//TR5666 : Deleting the zero dollar DH created at rider level when the discount was applied while the mbrship was active
					/*
					if(!rdh.getAmount().equals(ZERO))
					{
						discountHist = rdh;
					}
					*/
					discountHist = rdh;
					break;
				}
			}

			BigDecimal amountDue = amountDue(pc,dh.getDiscountCd());
			//wwei JRDR if it is upgrade and pay in full, don't give upgrade discount
			//condition 1. upgrade  UM 2. PIF membership due <= 0 
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if (amountDue.compareTo(ZERO) <= 0 || 
					( dh.getDiscountCd().equalsIgnoreCase("JRDR") && pc.getBillingCd().equalsIgnoreCase("UM")
							&& membership.getDuesCostAt().compareTo(ZERO) <= 0  ))
				continue; // already discounted all the way down
			
			if (discountHist == null) {
				// we are adding a discount to this component
				discountHist = new DiscountHistory(user, null, false);
				discountHist.setDiscountKy(discount.getDiscountKy());
				discountHist.setCostEffectiveDt(pc.getCostEffectiveDt().after(dh.getCostEffectiveDt()) ? pc
						.getCostEffectiveDt() : dh.getCostEffectiveDt());
				if (ph.getRiderCompCd() != null) {
					discountHist.setParentRider((Rider) pc);
				} else if (ph.getFeeTypeCd() != null) {
					discountHist.setParentMembershipFees((MembershipFees) pc);
				}
				//wwei JRDR set discount history sustainable flag to true
				discountHist.setParentDiscountHistoryKy(dh.getDiscountHistoryKy());
				discountHist.setPaymentMethodCd(dh.getPaymentMethodCd());
				//PC : 7/20/17 : Apply renewal discount via front line for memberships that completed renewals without RE discount
				//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
				if( discount.getDiscountCd().equalsIgnoreCase("JRDR") ||  discount.isApplyAtRenewal())
				{
					discountHist.setSustainableFl(true);
				}
				
				else
				{
					discountHist.setSustainableFl(false);
				}
				discountHist.setDiscountCd(discount.getDiscountCd());
				discountHist.setAttribute("PRIOR_AMOUNT", ZERO);
			}
			discountHist.setAttribute("KEEP",true);
			received = true;
			BigDecimal most = dh.getAmount().abs();
			if (discount.getPercentFl()) {
				most = amountDue.setScale(2).multiply(
						discount.getAmount().abs()).divide(new BigDecimal(100), 4, BigDecimal.ROUND_HALF_UP)
						.setScale(2, BigDecimal.ROUND_HALF_UP);
			}
			//AGI - PC: Data conversion : PC: to ensure the discount amount is not lost for AGI converted member level percentage 
			//discounts which are set Sustainable to Y to ensure pd/ps is generated.
			//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
			if(!discount.getDiscountCd().equalsIgnoreCase("JRDR") &&
					dh.getParentDiscount().isPercent() && discountHist.isSustainable()  && 
					discountHist.getOriginalAt().compareTo(BigDecimal.ZERO) < 0)
			{		
				log.debug("No changes to discount amount " + discountHist.getDiscountHistoryKy() + " -" + discountHist.getOriginalAt());
			}
			else
			{
				if (most.compareTo(amountDue) <= 0) {
						discountHist.setOriginalAt(most.negate());
					} else {
						discountHist.setOriginalAt(amountDue.negate());
				}
				discountHist.setAmount(discountHist.getOriginalAt());
			}
			if (!dh.getParentDiscount().isPercent()) {
				dh.setAmount(dh.getAmount().subtract(discountHist.getAmount()));
			}
		}
		return received;
	}

	/**
	 * Calculates a hashmap which contains the payable component primary key as
	 * the key and the dispersed discount percentage amount as the value. This
	 * is used to disperse membership level discounts.
	 * 
	 * @param dh
	 * @param ms
	 * @return
	 * @throws SQLException
	 */
	private Map<BigDecimal, BigDecimal> buildPercentMap(DiscountHistory dh) throws SQLException {
		Map<BigDecimal, BigDecimal> result = new HashMap<BigDecimal, BigDecimal>();
		BigDecimal totalDues = ZERO;
		BigDecimal memberCt = ZERO;
		// first pass, just record the total dues cost on each
		// component and sum the total
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			memberCt = memberCt.add(BigDecimal.ONE);
			if (dh.getParentDiscount().getMemberCount() != null
					&& dh.getParentDiscount().getMemberCount().intValue() > 0
					&& dh.getParentDiscount().getMemberCount().compareTo(memberCt) < 0)
				continue;
			if (dh.getParentDiscount().isRenewOnly() && !m.inRenewal())
				continue;
			for (PayableComponent pc : m.getPayableComponentList()) {
				if (pc.getFutureCancelDt() != null)
					continue;
				if (pc instanceof DonationHistory)
					continue;
				if (dh.getParentDiscount().isNewOnly() && !"N".equals(pc.getCommissionCd()))
					continue;
				BigDecimal riderCost = pc.getDuesCostAt().add(pc.getDuesAdjustmentAt());
				result.put(pc.getKey(), riderCost);
				totalDues = totalDues.add(riderCost);
			}
		}

		// convert to percentages
		for (BigDecimal ky : result.keySet()) {
			BigDecimal pct = new BigDecimal(
					Math.round(result.get(ky).doubleValue() / totalDues.doubleValue() * 10000) / 10000d).setScale(4,
					BigDecimal.ROUND_HALF_UP);
			result.put(ky, pct.multiply(dh.getAmount()).setScale(2, BigDecimal.ROUND_HALF_UP));
		}

		return result;
	}

	/**
	 * Calculates a hashmap which contains the payable component primary key as
	 * the key and the dispersed discount percentage amount as the value. This
	 * is used to disperse rider level discounts.
	 * 
	 * @param dh
	 * @param m
	 * @return
	 * @throws SQLException
	 */
	private Map<BigDecimal, BigDecimal> buildPercentMap(DiscountHistory dh, Member m) throws SQLException {
		Map<BigDecimal, BigDecimal> result = new HashMap<BigDecimal, BigDecimal>();

		BigDecimal totalDues = ZERO;

		// first pass, just record the total dues cost on each
		// component and sum the total
		if (m.isFutureCancel())
			return result;
		for (PayableComponent pc : m.getPayableComponentList()) {
			if (pc instanceof DonationHistory)
				continue;
			if (pc.getFutureCancelDt() != null)
				continue;
			if (dh.getParentDiscount().isNewOnly() && pc.getEffectiveDt() != null)
				continue;
			BigDecimal riderCost = pc.getDuesCostAt().add(pc.getDuesAdjustmentAt());
			result.put(pc.getKey(), riderCost);
			totalDues = totalDues.add(riderCost);
		}

		// convert to proportional amount
		for (BigDecimal ky : result.keySet()) {
			BigDecimal pct = result.get(ky).divide(totalDues, 6, BigDecimal.ROUND_HALF_UP);
			result.put(ky, pct.multiply(dh.getAmount()).setScale(2, BigDecimal.ROUND_HALF_UP));
		}
		return result;
	}

	/**
	 * Called by disperseDiscounts to build actual discount history records.
	 * 
	 * @param m
	 * @param dh
	 * @param discount
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	private void buildComponentDiscounts(Member m, DiscountHistory dh, Discount discount,
			Map<BigDecimal, BigDecimal> discountMap) throws SQLException, ObjectNotFoundException {
		outer:
		for (PayableComponent pc : m.getPayableComponentList()) {
			if (pc instanceof DonationHistory)
				continue;
			if (pc.getFutureCancelDt() != null)
				continue;
			if (discount.isNewOnly() && pc.getEffectiveDt() != null)
				continue;
			BigDecimal currentDiscounts = ZERO;
			DiscountHistory discountHist = null;
			for (DiscountHistory rdh : pc.getDiscountHistoryList()) {
				if (rdh.getCostEffectiveDt().before(pc.getCostEffectiveDt()))
					continue;
				if (!rdh.getCostEffectiveDt().before(m.getActiveExpirationDt()))
					continue;
				if (rdh.getParentDiscountHistoryKy() != null
						&& rdh.getParentDiscountHistoryKy().compareTo(dh.getDiscountHistoryKy()) == 0) {
					// if it's readonly, it means the rider/fee is already active,
					// so we can't change the amount.  Also the amount on the 
					// parent discount has alraady been adjusted for this one.
					if (rdh.isReadOnly()) continue outer;
					discountHist = rdh;
					continue;
				}
				currentDiscounts = currentDiscounts.add(rdh.getAmount());
			}
			BigDecimal amountDue = amountDue(pc,dh.getDiscountCd());
			if (amountDue.compareTo(ZERO) <= 0) {
				continue; // already discounted all the way down

			} else {
				// we are adding a discount to this component
				if (discountHist == null) {
					discountHist = new DiscountHistory(user, null, false);
					discountHist.setDiscountKy(discount.getDiscountKy());
					discountHist.setCostEffectiveDt(pc.getCostEffectiveDt().after(dh.getCostEffectiveDt()) ? pc
							.getCostEffectiveDt() : dh.getCostEffectiveDt());

					if (pc instanceof Rider) {
						discountHist.setParentRider((Rider) pc);
					} else if (pc instanceof MembershipFees) {
						discountHist.setParentMembershipFees((MembershipFees) pc);
					}

					discountHist.setParentDiscountHistoryKy(dh.getDiscountHistoryKy());
					discountHist.setSustainableFl(false);
					discountHist.setDiscountCd(discount.getDiscountCd());
					discountHist.setPaymentMethodCd(dh.getPaymentMethodCd());
				}
				discountHist.setAttribute("KEEP", true);
				BigDecimal most = ZERO;
				if (discount.getPercentFl()) {
					most = pc.getDuesCostAt().add(pc.getDuesAdjustmentAt()).setScale(2).multiply(
							discount.getAmount().setScale(4).abs().divide(new BigDecimal(100), 4,
									BigDecimal.ROUND_HALF_UP)).setScale(2, BigDecimal.ROUND_HALF_UP);
				} else {
					most = discountMap.get(pc.getKey()).negate();
				}
				if (most.compareTo(amountDue) <= 0) {
					discountHist.setOriginalAt(most.negate());
				} else {
					discountHist.setOriginalAt(amountDue.negate());
				}
				discountHist.setAmount(discountHist.getOriginalAt());
				if (!dh.getParentDiscount().isPercent()) {
					dh.setAmount(dh.getAmount().subtract(discountHist.getAmount()));
				}
			}
		}
	}

	/********************************************************************************
	 * MISCELLANEOUS METHODS *
	 ********************************************************************************/

	/**
	 * Add a referral discount to a membership.
	 * 
	 * @param membership
	 *            Membership receiving the discount
	 * @param referringMembership
	 *            Membership that was created, causing the referral discount
	 * @throws Exception
	 */
	public void generateReferralDiscount(Membership ms, Membership referringMembership) throws Exception {
		membership = ms;
		BigDecimal amount = ClubProperties.getBigDecimal("ReferralCouponAmount", referringMembership.getDivisionKy(),
				referringMembership.getRegionCode());
		if (amount == null || amount.compareTo(ZERO) == 0) {
			throw new RuntimeException("ReferralCouponAmount is invalid and ReferralCouponEnabled is enabled.");
		} else if (amount.compareTo(ZERO) > 0) {
			amount = amount.negate();
		}
		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		criteria.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.EQ, Discount.SYSTEM_REFERRAL_DISCOUNT));
		SortedSet<Discount> discountList = Discount.getDiscountList(user, criteria, null);
		Discount discount = discountList.first();
		DiscountHistory dh = new DiscountHistory(user, null, false);
		if (Discount.APPLIES_TO_RIDER.equals(discount.getAppliesTo())) {
			membership.getPrimaryMember().getBasicRider().addDiscountHistory(dh);
		} else if (Discount.APPLIES_TO_MEMBER.equals(discount.getAppliesTo())) {
			membership.getPrimaryMember().addDiscountHistory(dh);
		} else {
			membership.addDiscountHistory(dh);
		}
		dh.setDiscountKy(discount.getDiscountKy());
		dh.setDiscountCd(Discount.SYSTEM_REFERRAL_DISCOUNT);
		dh.setAmount(amount);
		dh.setOriginalAt(amount);
		dh.setCostEffectiveDt(membership.getPrimaryMember().getBasicRider().getCostEffectiveDt());
		dh.setSustainableFl("Y");
		applyDiscounts(membership);
		MembershipComment cmt = new MembershipComment(user,(BigDecimal)null, false);
		cmt.setAttribute("DiscountBP","Y");
		cmt.setParentMembership(membership);
		cmt.setCommentTypeCd(MembershipComment.TYPE_SYSTEM);
		cmt.setCreateDt(new Timestamp(System.currentTimeMillis()));
		cmt.setCreateUserId(user.userID);
		cmt.setComments("$" + amount.setScale(2).toString()
				+ " Refer a friend discount generated from activity on membership: "
				+ referringMembership.getMembershipId());
		cmt = new MembershipComment(user,(BigDecimal)null, false);
		cmt.setAttribute("DiscountBP","Y");
		cmt.setParentMembership(referringMembership);
		cmt.setCommentTypeCd(MembershipComment.TYPE_SYSTEM);
		cmt.setCreateDt(new Timestamp(System.currentTimeMillis()));
		cmt.setCreateUserId(user.userID);
		cmt.setComments("$" + amount.setScale(2).toString()
				+ " Refer a friend discount given to membership: " + membership.getMembershipId());
	}


	protected void getDiscountPaymentSummaryRecords() throws SQLException {
		Set<PaymentSummary> discountPaymentSummaries = null;
		List<PaymentSummary> results = new ArrayList<PaymentSummary>();
		Map<String,List<PaymentSummary>> tmp = new HashMap<String,List<PaymentSummary>>();
		List<SearchCondition> l = new ArrayList<SearchCondition>();
		l.add(new SearchCondition(PaymentSummary.TRANSACTION_CD, SearchCondition.EQ, PaymentSummary.TC_DISCOUNT));
		l.add(new SearchCondition(PaymentSummary.MEMBERSHIP_KY, SearchCondition.EQ, membership.getMembershipKy()));
		// only interested in payment summaries created today.  Anything else has
		// already been reported (potentially), so we can't alter them.
		l.add(new SearchCondition(PaymentSummary.CREATE_DT, SearchCondition.GE, DateUtilities.getTimestamp(true)));
		List<String> ob = new ArrayList<String>();
		ob.add(PaymentSummary.MEMBERSHIP_PAYMENT_KY);
		discountPaymentSummaries = PaymentSummary.getPaymentSummaryList(user, l, ob);
		dpsLoop: for (PaymentSummary dps : discountPaymentSummaries) {
			
			long dpsKey = dps.getMembershipPaymentKy().longValue();
			if (!tmp.containsKey(dps.getReasonCd())) {
				tmp.put(dps.getReasonCd(),new ArrayList<PaymentSummary>());
			}
			for (PaymentSummary mps : membership.getCurrentPaymentSummaryList()) {
				if (dpsKey == mps.getMembershipPaymentKy().longValue()) {
					tmp.get(dps.getReasonCd()).add(mps);
					continue dpsLoop;
				}
			}
			// not already in membership collection
			dps.setParentMembership(membership);
			tmp.get(dps.getReasonCd()).add(dps);
		}
		
		for (String discountCd:tmp.keySet()) {
			Timestamp createDt = null;
			PaymentSummary keep = null;
			// only keep the most recent one
			for (PaymentSummary ps:tmp.get(discountCd)) {
				if (createDt == null || ps.getCreateDt().after(createDt)) {
					keep = ps;
					createDt = ps.getCreateDt();
				}
			}
			// mark the payment details
			//This is done to handle multiple discount payments on active memberships.
			//New payment line was overriding the old payment line for discounts.
			for (PaymentDetail pd: keep.getPaymentDetailList()) {
				//pd.setAttribute("KEEP",false);
				//pd.setAttribute("PRIOR_AMOUNT",pd.getMembershipPaymentAt());
				if(!"A".equals(membership.getStatus())||membership.isOnPaymentPlan())  /*pbc 10/30/2014 added isOnPaymentPlan check.  getting memberships on install plan to behave like they are pending.  they actually are active but owe money. this is necessary because the pd gets deleted later*/
				{
					pd.setAttribute("KEEP",false);
					pd.setAttribute("PRIOR_AMOUNT",pd.getMembershipPaymentAt());
				}
				else
				{
					String pdDate = null; 
					String psDate = null;					
					psDate = DateUtilities.asString(createDt, "MM/dd/yyyy");
					pdDate = DateUtilities.asString(pd.getLastUpdDt(), "MM/dd/yyyy");
					if(pdDate.equals(psDate))// need to roll up discounts
					{
					    pd.setAttribute("KEEP", true);
					}
					else
					{
						pd.setAttribute("KEEP",false);
					}
					pd.setAttribute("PRIOR_AMOUNT",pd.getMembershipPaymentAt());
				}
				
			}
			paymentSummary.put(discountCd,keep);
		}
	}

	protected void getDiscountCommentRecords() throws SQLException {
		Set<MembershipComment> discountComments = null;
		List<SearchCondition> l = new ArrayList<SearchCondition>();
		l.add(new SearchCondition(MembershipComment.MEMBERSHIP_KY, SearchCondition.EQ, membership.getMembershipKy()));
		l.add(new SearchCondition(MembershipComment.CREATE_DT, SearchCondition.GT, DateUtilities.getTimestamp(true)));
		List<String> ob = new ArrayList<String>();
		ob.add(MembershipComment.MEMBERSHIP_COMMENT_KY);
		discountComments = MembershipComment.getMembershipCommentList(user, l, ob);
		dpsLoop: for (MembershipComment dps : discountComments) {
			
			long dpsKey = dps.getMembershipCommentKy().longValue();
			if (membership.getCurrentMembershipCommentList() != null) {
				for (MembershipComment mc2:membership.getCurrentMembershipCommentList()) {
					if (mc2.getMembershipCommentKy().longValue() == dpsKey) {
						continue dpsLoop;
					}
				}
			}
			// not already in membership object
			dps.setParentMembership(membership);
		}
	}
	/**
	 * <p>
	 * Go through the membership and tag the existing discounts.  We use this
	 * for comparison later to write an adjusting payment summary if necessary
	 * Once we're done, any discount that is no longer applicable will be cancelled.
	 * </p>
	 * <p>
	 * All discount history records get tagged with boolean attribute KEEP set to
	 * FALSE. If the discount history gets reused the KEEP attribute will be set
	 * to TRUE.
	 * </p>
	 * <p>
	 * After this method executes all discount history lists on the membership
	 * objects will contain only relevent data, based on cost effective date.
	 * </p>
	 * 
	 * @throws SQLException on normal DataObject exceptions
	 * @throws ObjectNotFoundException on normal DataObject exceptions
	 */
	protected void saveExistingDiscounts() throws SQLException, ObjectNotFoundException {
		Timestamp costEffectiveDt = null;
		Map<BigDecimal,DiscountHistory> parents = new HashMap<BigDecimal,DiscountHistory>();
		costEffectiveDt = membership.getPrimaryMember().getBasicRider().getCostEffectiveDt();
		List<DiscountHistory> removeList = new ArrayList<DiscountHistory>();
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.getCostEffectiveDt().before(costEffectiveDt)||!dh.getCostEffectiveDt().before(membership.getPrimaryMember().getActiveExpirationDt())) {
				removeList.add(dh);
				continue;
			}
			boolean keep = membership.isActive()||dh.isSustainable();
			if (keep && !dh.getParentDiscount().isPercent()) {
 				parents.put(dh.getDiscountHistoryKy(),dh);
			}
			dh.setAttribute("KEEP", keep);
			//dh.setReadOnly(membership.isActive());
			dh.setAttribute("PRIOR_ORIGINAL_AMOUNT", dh.getOriginalAt());
			dh.setAttribute("PRIOR_AMOUNT", dh.getAmount());
		}
		for (DiscountHistory dh : removeList) {
			// previous membership year, we don't care
			membership.removeDiscountHistory(dh);
		}
		removeList.clear();

		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			costEffectiveDt = m.getBasicRider().getCostEffectiveDt();
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.getCostEffectiveDt().before(costEffectiveDt)||!dh.getCostEffectiveDt().before(m.getActiveExpirationDt())) {
					removeList.add(dh);
					continue;
				}
				//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
				//11/21/17: Make sure the existing JRDR discounts are not lost
				boolean keep = m.isActive()||dh.isSustainable() || (dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR"));
				if (keep && !dh.getParentDiscount().isPercent()) {
	 				parents.put(dh.getDiscountHistoryKy(),dh);
				}
				
				//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
				//11/21/17: Make sure the existing JRDR discounts are not lost
				dh.setAttribute("KEEP", m.isActive()||dh.isSustainable() || (dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR")));
				//dh.setReadOnly(m.isActive());
				dh.setAttribute("PRIOR_ORIGINAL_AMOUNT", dh.getOriginalAt());
				dh.setAttribute("PRIOR_AMOUNT", dh.getAmount());
			}
			for (DiscountHistory dh : removeList) {
				// previous membership year, we don't care
				m.removeDiscountHistory(dh);
			}
			removeList.clear();
			// not a member level
			for (Rider r : m.getRiderList()) {
				for (DiscountHistory dh : r.getDiscountHistoryList()) {
					if (dh.getCostEffectiveDt().before(r.getCostEffectiveDt())||!dh.getCostEffectiveDt().before(m.getActiveExpirationDt())) {
						removeList.add(dh);
						continue;
					}
					
					//TR 5666 Rollback for 1.0.20.0
					//TR 5666 Rollback for 1.0.20.0
					// DO NOT TOUCH conversion discounts.  These were built during implementation
					// and cannot be removed.
					//8/22/2017 : Added this to avoid redistribution of already applied renewal discounts
					//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
					//11/21/17: Make sure the existing JRDR discounts are not lost
					dh.setReadOnly("CONVCH".equals(dh.getDiscountCd() )|| (dh.isSustainable() && dh.getParentDiscount().isApplyAtRenewal())
							||  (dh.isSustainable() && dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR")) );
					//dh.setAttribute("KEEP", r.isActive()||dh.isSustainable()||dh.isReadOnly()||flag);
					dh.setAttribute("KEEP", r.isActive()||dh.isSustainable()||dh.isReadOnly());
					dh.setAttribute("PRIOR_ORIGINAL_AMOUNT", dh.getOriginalAt());
					dh.setAttribute("PRIOR_AMOUNT", dh.getAmount());
					// HLDY speical case for unknown reason, app try to move rider discount from rider discount history 
					//to rider's parent discount history and make rider short of payment and status change to pending due to not pay in full
					String sol = ""; //it is possible solicitation code is null
					if ( !( r.getSolicitationCd() == null ))
					{
						sol = r.getSolicitationCd();
					}
					
					if (!dh.isSustainable() && !dh.isReadOnly() &&  !sol.equalsIgnoreCase("HLDY")) 
					{
					//if (!dh.isSustainable() && !dh.isReadOnly() ) {
						if (dh.getParentDiscountHistoryKy() != null && parents.containsKey(dh.getParentDiscountHistoryKy())) {
							// move the money back to parent
							DiscountHistory parent = parents.get(dh.getParentDiscountHistoryKy());
							parent.setAmount(parent.getAmount().add(dh.getAmount()));
							
						}
						//AGI PC: to ensure the discount amount is not lost for  member level percentage 
						//discounts which are less than 100%
						//wwei remove JRDR function. after diable JRDR function, we don't have JRDR discount anymore
						if(!dh.getParentDiscount().getDiscountCd().equalsIgnoreCase("JRDR") &&
								dh.getParentDiscount().isPercent()  //&& dh.getParentDiscount().getAmount().compareTo(new BigDecimal(100.00)) < 0 
								&& dh.getParentDiscountHistoryKy() !=null
								&& dh.getOriginalAt().compareTo(BigDecimal.ZERO) < 0)
						{		
							log.debug("Don't make changes to already discounted amount " + dh.getDiscountHistoryKy() + " -" + dh.getOriginalAt());
						}
						else
						{
							dh.setAmount(ZERO);
							dh.setOriginalAt(ZERO);
						}
					}
				}
				for (DiscountHistory dh : removeList) {
					// previous membership year, we don't care
					r.removeDiscountHistory(dh);
				}
				removeList.clear();
			}
			for (MembershipFees f : m.getMembershipFeesList()) {
				for (DiscountHistory dh : f.getDiscountHistoryList()) {
					if (dh.getCostEffectiveDt().before(costEffectiveDt)||!dh.getCostEffectiveDt().before(m.getActiveExpirationDt())) {
						removeList.add(dh);
						continue;
					}
					dh.setReadOnly("CONVCH".equals(dh.getDiscountCd()));
					dh.setAttribute("KEEP", f.isActive()||dh.isSustainable()||dh.isReadOnly());
					dh.setAttribute("PRIOR_ORIGINAL_AMOUNT", dh.getOriginalAt());
					dh.setAttribute("PRIOR_AMOUNT", dh.getAmount());
					if (!dh.isSustainable() && !dh.isReadOnly()) {
						if (dh.getParentDiscountHistoryKy() != null && parents.containsKey(dh.getParentDiscountHistoryKy())) {
							// move the money back to parent
							DiscountHistory parent = parents.get(dh.getParentDiscountHistoryKy());
							parent.setAmount(parent.getAmount().add(dh.getAmount()));	
						}
						dh.setAmount(ZERO);
						dh.setOriginalAt(ZERO);
					}
				}
				for (DiscountHistory dh : removeList) {
					// previous membership year, we don't care
					f.removeDiscountHistory(dh);
				}
				removeList.clear();
			}
		}
	}

	@SuppressWarnings("serial")
	protected class NoPaymentPlanException extends Exception {

	}

	//10-9-2017 PC : Remove Renewal Discount
	private void removeRenewalDiscount(Membership membership, String discountCd) throws Exception {	
		
		List<BigDecimal> removDiscountKey= new ArrayList<BigDecimal>();
		PaymentManagerBP pmtMgr = BPF.get(user,PaymentManagerBP.class);
		
		for (DiscountHistory dh : membership.getDiscountHistoryList()) {
			if (dh.getDiscountCd().equalsIgnoreCase(discountCd) && dh.isSustainable()) {
				removDiscountKey.add(dh.getDiscountHistoryKy());
			}
		}		
		
		for (Member m : membership.getMemberList()) {
			if (m.isCancelled() || m.isFutureCancel()) continue;
			for (DiscountHistory dh : m.getDiscountHistoryList()) {
				if (dh.getDiscountCd().equalsIgnoreCase(discountCd) && dh.isSustainable()) {					
					removDiscountKey.add(dh.getDiscountHistoryKy());
				}
			}			 
			for (Rider r : m.getRiderList()) {
				for (DiscountHistory dh : r.getDiscountHistoryList()) {
					if (dh.getDiscountCd().equalsIgnoreCase(discountCd) && dh.isSustainable()
							&& dh.getCostEffectiveDt().compareTo(r.getCostEffectiveDt()) >=0 ) {
						removDiscountKey.add(dh.getDiscountHistoryKy());
					}
				}
			}
		} 
		for (PaymentSummary ps : membership.getPaymentSummaryList()) {
			if (!PaymentSummary.TC_DISCOUNT.equals(ps.getTransactionCd())) continue;			
			boolean foundDiscountPaymentDetail = false;
			for (PaymentDetail pd:ps.getPaymentDetailList()) {
					if (removDiscountKey.contains(pd.getDiscountHistoryKy())) {
						foundDiscountPaymentDetail  = true;						
					}
			}
			if(foundDiscountPaymentDetail)
			{
				pmtMgr.cancelPayment(ps,"M","D",DateUtilities.getTimestamp(true));				
			}
		}	
		membership.addComment("Misapplied the renewal discount  " +  discountCd );
		membership.save();
	}
	//10/9/17 PC : Remove Renewal Discount - getSoliciationCodeForDiscount
	public SimpleVO getSoliciationCodeForDiscount(String discountCd){
    	try{
			
    		SimpleEditor _simpleEditor = new SimpleEditor(user);
			ArrayList<SearchCondition> condList = new ArrayList<SearchCondition>();			
			SearchCondition con= new SearchCondition("DISCOUNT_CD", SearchCondition.EQ, discountCd);
			condList.add(con);
			ArrayList columns = new ArrayList();
            columns.add("SOLICITATION_CD");
            columns.add("auto_renewal_required_fl");
			SimpleVO _solCodes =  _simpleEditor.findByCriteria("mz_solicitation_discount sd join mz_solicitation s on sd.solicitation_ky = s.solicitation_ky ", condList, null, columns);
			return _solCodes;
			
		}
		catch (Exception e){
			log.error("Exception in getSoliciationCodeForDiscount: " + e.toString());
			return null; 
		}
	}
	
	 
	 
	//10/9/17 PC : Remove Renewal Discount - getDiscountCodeForSolicitationCode
		public SimpleVO getDiscountCodeForSolicitationCode(String solCode){
	    	try{
				
	    		SimpleEditor _simpleEditor = new SimpleEditor(user);
				ArrayList<SearchCondition> condList = new ArrayList<SearchCondition>();			
				SearchCondition con= new SearchCondition("SOLICITATION_CD", SearchCondition.EQ, solCode);
				condList.add(con);
				ArrayList columns = new ArrayList();
	            columns.add("DISCOUNT_CD");
				SimpleVO _dicountCodes =  _simpleEditor.findByCriteria("mz_solicitation_discount sd join mz_solicitation s on sd.solicitation_ky = s.solicitation_ky ", condList, null, columns);
				return _dicountCodes;
				
			}
			catch (Exception e){
				log.error("Exception in getDiscountCodeForSolicitationCode: " + e.toString());
				return null; 
			}
		}
		
		//12/1/2017: Moved the function to DiscountBP
				
		public void removeARRenewalDiscount(Membership membership) throws Exception {	
			//12/6/2017 PC: Remove the AR discount provided for this membership at renewal.
			try
			{
				for(Rider r : membership.getRiderList())
				{
					for (DiscountHistory dh : r.getDiscountHistoryList()) {		
					if (dh.isSustainable() && dh.getDiscountCd().contains("AR") && dh.getCostEffectiveDt().compareTo(r.getCostEffectiveDt()) >=0 )
						// implies apply at renewal discount
					{
						this.removeRenewalDiscount(membership, dh.getDiscountCd());						
				    }					
					
				  }
			  }
			}
			catch (Exception ex)
			{
						log.error("Exception caught in finalRejection AR while trying to remove Renewal discounts "  + ex.getMessage());
			}
			
		}
		
		public void removeRenewalDiscountForMarketCode(Membership membership, String _solicitation_cd) throws Exception {	
			try{
				//get the discount code from _solicitation_cd
				SimpleVO solCdVO = this.getDiscountCodeForSolicitationCode(_solicitation_cd);
		        if (solCdVO != null ){
		        	solCdVO.beforeFirst(); 
					while(solCdVO.next()) 
					{ 
						String discountCd = solCdVO.getString("DISCOUNT_CD");                                  
						this.removeRenewalDiscount(membership, discountCd);
					}
		        }
			}catch(Exception e) {
				log.error("Failed to remvove  discounts in removeRenewalDiscount() : " + StackTraceUtil.getStackTrace(e));
			}
		}
	    
		public void removePendingApplyDiscountRecords( Membership mbrs, boolean checkAR) throws Exception
		{
			int count = 0 ; 
			Connection conn = null;
			PreparedStatement pstmt = null;
			try {
				//remove any pending discounts
				conn = ConnectionPool.getConnection(user);
				String sql = "delete from mz_apply_discount where membership_ky =  " + mbrs.getMembershipKy() ;
				if (checkAR)
				{
					sql = sql + " and solicitation_cd in (select distinct s.solicitation_cd from mz_solicitation s where s.auto_renewal_required_fl ='Y'  )" ;
				}
				pstmt = conn.prepareStatement(sql);
				count = count + pstmt.executeUpdate();
				if (!conn.getAutoCommit()) conn.commit();
				pstmt.close();
				pstmt = null;
			    for(Member m: mbrs.getMemberList())
			    {
			    	sql = "delete from mz_apply_discount where member_ky =  " + m.getMemberKy() ;
					if (checkAR)
					{
						sql = sql + " and solicitation_cd in (select distinct s.solicitation_cd from mz_solicitation s where s.auto_renewal_required_fl ='Y'  )" ;
					}
			    	pstmt = conn.prepareStatement(sql);
			    	count = count + pstmt.executeUpdate();
					if (!conn.getAutoCommit()) conn.commit();
					pstmt.close();
					pstmt = null;
			    }
			    for(Rider r: mbrs.getRiderList())
			    {
			    	sql = "delete from mz_apply_discount where rider_ky =  " + r.getRiderKy();
					if (checkAR)
					{
						sql = sql + " and solicitation_cd in (select distinct s.solicitation_cd from mz_solicitation s where s.auto_renewal_required_fl ='Y'  )" ;
					}
			    	pstmt = conn.prepareStatement(sql);
			    	count = count + pstmt.executeUpdate();
					if (!conn.getAutoCommit()) conn.commit();
					pstmt.close();
					pstmt = null;
			    }
			    if(count > 0)
			    {
			    	membership.addComment("Pending Renewal discount has been removed as the membership is not in Auto Renewal");
			    	membership.save();
			    }
			}
			catch (Exception ex)
			{
				log.error("Failed to remvove pending discounts from Mz_ApplY_discount : " + StackTraceUtil.getStackTrace(ex));
			}
			finally{
				if (pstmt != null){
					try{
						pstmt.close();
					}
					catch (Exception ignore){}
				}
				if (conn != null){
					try{
						conn.close();
						conn = null;
					}
					catch (Exception ignore){}
				}
			}
		}
		public boolean addRenewalDiscountsForNextRenewal(String solicitationCode , Membership membership) throws Exception
		{
			Solicitation solicitation = null;
			
			if (solicitationCode != null){
				try{

					solicitation = Solicitation.getSolicitation(user, solicitationCode.toUpperCase());
				}
				catch (Exception e)
				{
					log.error ("Invalid promo code. Please try again");
				}
			}
			/*
			for (Member m: membership.getMemberList()) {
				if(!m.getStatus().equalsIgnoreCase("C") && m.getSolicitationCd()==null) {
				    m.setSolicitationCd(solicitation.getSolicitationCd());
				    m.save();
				    for(Rider r: m.getRiderList())
				    {
				    	if(!r.getStatus().equalsIgnoreCase("C") && r.getSolicitationCd()==null ) {
				    		r.setSolicitationCd(solicitation.getSolicitationCd());
				    		r.save();
				    	}
				    }
				}
			}
			*/
			ArrayList<SearchCondition> startCriteria = new ArrayList<SearchCondition>();
			startCriteria.add(new SearchCondition(Discount.START_DT, SearchCondition.LE, DateUtilities
					.getTimestamp(true)));
			startCriteria.add(new SearchCondition("nvl(" + Discount.END_DT + ",sysdate + 1)",
					SearchCondition.GT, DateUtilities.getTimestamp(true)));
			startCriteria.add(new SearchCondition(Discount.AUTO_FL, SearchCondition.EQ, "N"));
			startCriteria.add(new SearchCondition(Discount.MEMBERSHIP_TYPE_CD, SearchCondition.EQ,
					membership.getMembershipTypeCd()));
			Collection<Discount> solDiscounts = null;
            boolean hasRenewalDiscount = false;
			for (SolicitationDiscount sd : solicitation.getSolicitationDiscountList()) {
				ArrayList<SearchCondition> solcriteria = new ArrayList<SearchCondition>();
				solcriteria.addAll(startCriteria);
				solcriteria.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.EQ, sd
						.getDiscountCd()));
				//Allow only Apply at renewal discounts
				solcriteria.add(new SearchCondition(Discount.APPLY_AT_RENEWAL_FL, SearchCondition.EQ, "Y"));
				solDiscounts = Discount.getDiscountList(user, solcriteria, membership.getDivisionKy(),
						membership.getRegionCode(), membership.getBranchKy());
				for (Discount d : solDiscounts) {
					hasRenewalDiscount = true;
					if (d.appliesToMembership()){
						insertApplyDiscountRecords(membership,membership.getMembershipKy().toString(), "MEMBERSHIP_KY", solicitation.getSolicitationCd());
					}
					else if (d.appliesToMember()){
						if(d.getMemberTypeCd().equalsIgnoreCase("P"))
						{
							insertApplyDiscountRecords(membership,membership.getPrimaryMember().getMemberKy().toString(), "MEMBER_KY", solicitation.getSolicitationCd());
						}
						else if(d.getMemberTypeCd().equalsIgnoreCase("A"))
						{
							for (Member m: membership.getMemberList())
							{
								if(!m.getStatus().equalsIgnoreCase("C") && m.getMemberTypeCd().equalsIgnoreCase("A"))
								{
									insertApplyDiscountRecords(membership,m.getMemberKy().toString(), "MEMBER_KY", solicitation.getSolicitationCd());
								}
							}
						}
					}
					else if (d.appliesToRider()){
						for (Rider r: membership.getRiderList())
						{
							if(!r.getStatus().equalsIgnoreCase("C") )
							{
							  insertApplyDiscountRecords(membership,r.getRiderKy().toString(), "RIDER_KY", solicitation.getSolicitationCd());
							}
						}
					}
				}//end of for (SolicitationDiscount sd : solicitation.getSolicitationDiscountList()) {
			} // end of for (Discount d : solDiscounts) 
			if(hasRenewalDiscount){
			    membership.addComment("Renewal Discount attached to " + solicitation.getSolicitationCd()  + " are added to membership to apply during next Renewal cycle" );
			    membership.save();
			}
			return hasRenewalDiscount;
			
		}

	
    //ww/pc  insert records to apply discount table;
	private void insertApplyDiscountRecords( Membership mbrs, String key, String applyTo, String solicitationCd) throws Exception
	{

				if ( applyTo != null )
				{

					Connection conn = null;
					PreparedStatement inserpreSql=null;
					try
					{
						conn = ConnectionPool.getConnection(user);
						inserpreSql = conn.prepareStatement("insert into mz_apply_discount (" + applyTo + ", expiration_dt, solicitation_cd) values (?,?,?)" );
					    inserpreSql.setBigDecimal(1, new BigDecimal( key)); // key
					    inserpreSql.setTimestamp(2, mbrs.getPrimaryMember().getMemberExpirationDt() ); // member expiration date
					    inserpreSql.setString(3, solicitationCd ); // renewal discount sol cd
					    inserpreSql.executeUpdate();
					    inserpreSql.close();
					    inserpreSql = null;
					    if (!conn.getAutoCommit()) conn.commit();
					}
					catch (Exception e)
					{
						log.error("Failed in insert into mz_apply_discount : " + StackTraceUtil.getStackTrace(e));
						e.printStackTrace(System.err);
						throw e;
					}
					finally{
						if (inserpreSql != null){
							try{
								inserpreSql.close();
							}
							catch (Exception ignore){}
						}
						if (conn != null){
							try{
								conn.close();
								conn = null;
							}
							catch (Exception ignore){}
						}
					}
				}
			}

}
