package com.aaa.soa.services;

import java.util.Calendar;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.aaa.soa.object.MembershipDuesCalculatorBP;
import com.aaa.soa.object.MembershipServiceBP;
import com.aaa.soa.object.MembershipUtilBP;
import com.aaa.soa.object.models.InstallmentPaymentPlanDuesRequest;
import com.aaa.soa.object.models.InstallmentPaymentPlanDuesResponse;
import com.aaa.soa.object.models.MarketCode;
import com.aaa.soa.object.models.MembershipDues;
import com.aaa.soa.object.models.BaseMembershipDues;
import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.util.RGILoggerFactory;


/**
 * Membership dues calculator utility web service. All public methods are exposed as web methods.
 * @author konstantin.ostrobrod
 *
 */
public class MembershipDuesCalculator {

	private static Logger	log				= LogManager.getLogger(MembershipDuesCalculator.class.getName(), new RGILoggerFactory());
	
	/**
	 * Will attempt to calculate membership dues for single coverage level.
	 * @param zipCode
	 * @param associateCount
	 * @param coverageLevel
	 * @param marketCode
	 */
	public MembershipDues CalculateDues(String zipCode, int associateCount, String coverageLevel, String marketCode, String[] discounts, String membershipNumber){
		
		MembershipDues dues = null;
		
		String DEBUG_MODULE = "SOA_CalculateDues_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			mubp.debug(DEBUG_MODULE, "Get dues: zip -   " + zipCode 
					+ " | mbs# - " + membershipNumber
					+ " | associateCount - " + associateCount
					+ " | coverageLevel - " + coverageLevel
					+ " | marketCode - " + marketCode, true);
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			dues = bp.CalculateDues(zipCode, associateCount, coverageLevel, marketCode, discounts, membershipNumber);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return dues;		
	}
	
	public MembershipDues CalculateDuesSC(String zipCode, int associateCount, String coverageLevel, 
								String marketCode, String[] discounts, String membershipNumber){
		
		MembershipDues dues = null;
		
		String DEBUG_MODULE = "SOA_CalculateDuesSC_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			mubp.debug(DEBUG_MODULE, "Get dues: zip -   " + zipCode 
					+ " | mbs# - " + membershipNumber
					+ " | associateCount - " + associateCount
					+ " | coverageLevel - " + coverageLevel
					+ " | marketCode - " + marketCode, true);
			
			MembershipDuesCalculatorBP bp = (MembershipDuesCalculatorBP) BPF.get(User.getGenericUser(), MembershipDuesCalculatorBP.class);
			dues = bp.CalculateDuesSC(zipCode, associateCount, coverageLevel, marketCode, discounts, membershipNumber);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return dues;		
	}
	
	/**
	 * Will attempt to calculate dues for all membership coverage levels.
	 * @param zipCode
	 * @param associateCount
	 * @param marketCode
	 */
	public BaseMembershipDues CalculateBaseDues(String zipCode, int associateCount, String marketCode){
		
		BaseMembershipDues baseDues = null;
		
		String DEBUG_MODULE = "SOA_CalculateBaseDues_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			mubp.debug(DEBUG_MODULE, "Get base dues: zip -   " + zipCode 
					+ " | associateCount - " + associateCount 
					+ " | marketCode - " + marketCode, true);
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			baseDues = bp.CalculateBaseDues(zipCode, associateCount, marketCode);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return baseDues;		
	}
	
	/**
	 * Will attempt to calculate dues for all membership coverage levels.
	 * @param zipCode
	 * @param associateCount
	 * @param marketCode
	 */
	public BaseMembershipDues CalculateUpgradeDues(String membershipNumber, String marketCode, String source){
		
		BaseMembershipDues baseDues = null;
		
		String DEBUG_MODULE = "SOA_CalculateUpgradeDues_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			
			mubp.debug(DEBUG_MODULE, "Get upgrade dues: mbs# - " + membershipNumber
					+ " | marketCode - " + marketCode, true);
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			baseDues = bp.CalculateUpgradeDues(membershipNumber, marketCode, source);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return baseDues;		
	}
	
	
	/**
	 * Will attempt to get rules/details of a specific market code
	 * @param marketCode
	 */
	public MarketCode GetMarketCode(String marketCode){
		
		MarketCode mktCd = null;
		
		try {
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			mktCd = bp.GetMarketCode(marketCode);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return mktCd;		
	}	
	
	/**
	 * Will attempt to get payment plans of mzp
	 * @param marketCode
	 */
	public InstallmentPaymentPlanDuesResponse GetPaymentPlans(InstallmentPaymentPlanDuesRequest request){
		InstallmentPaymentPlanDuesResponse response = null;
		
		if (log.isDebugEnabled()){
			log.debug("**************************\n Get payment plans");
		}
		
		try {
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			response = bp.GetPaymentPlans(request);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return response;
	}
	
	public MembershipDues GetMembershipBalanceWithMarketCode(String zipCode, String marketCode, String membershipNumber, String salesAgentID){
		
		MembershipDues dues = null;
		
		try {
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			dues = bp.GetMembershipBalanceWithMarketCode(zipCode, marketCode, membershipNumber, salesAgentID);
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return dues;		
	}
}
