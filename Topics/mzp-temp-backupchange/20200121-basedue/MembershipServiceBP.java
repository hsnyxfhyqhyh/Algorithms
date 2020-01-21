/**
 * This class is designed to be used as a single container for membership services.
 * Business logic and access to other business processes go here. 
 * @author k.ostrobrod
 *********************************************************************************
 
 */

package com.aaa.soa.object;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.URL;
import java.net.URLConnection;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.SortedMap;
import java.util.TreeMap;

import oracle.jdbc.OracleTypes;

import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMNode;
import org.apache.axiom.om.impl.llom.OMElementImpl;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.Element;
import java.util.SortedSet;

import javax.naming.NamingException;

import com.aaa.soa.object.models.*;
import com.ibm.icu.util.Calendar;
import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.dao.SimpleEditor;
import com.rossgroupinc.conxons.dao.SimpleVO;
import com.rossgroupinc.conxons.pool.ConnectionPool;
import com.rossgroupinc.conxons.reports.ReportBean;
import com.rossgroupinc.conxons.rule.Validator;
import com.rossgroupinc.conxons.security.ConxonsSecurity;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.errorhandling.ObjectNotFoundException;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.errorhandling.ValueObjectException;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.MemberzPlusUser;
import com.rossgroupinc.memberz.action.CommentsAction;
import com.rossgroupinc.memberz.bp.member.EmailTempCardPopupBP;
import com.rossgroupinc.memberz.bp.member.MemberEmailCheckBP;
import com.rossgroupinc.memberz.bp.billing.AutoRenewalBP;
import com.rossgroupinc.memberz.bp.club.DiscountBP;
import com.rossgroupinc.memberz.bp.cost.CostBP;
import com.rossgroupinc.memberz.bp.cost.CostData;
import com.rossgroupinc.memberz.bp.cwp.CWPReEnrollBP;
import com.rossgroupinc.memberz.bp.discountOffer.DiscountOfferBP;
import com.rossgroupinc.memberz.bp.membership.CredentialBP;
import com.rossgroupinc.memberz.bp.membership.MembershipAffiliationBP;
import com.rossgroupinc.memberz.bp.membership.MembershipIdBP;
import com.rossgroupinc.memberz.bp.payment.PayableComponent;
import com.rossgroupinc.memberz.bp.payment.PaymentPlanBP;
import com.rossgroupinc.memberz.bp.payment.PaymentPosterBP;
import com.rossgroupinc.memberz.bp.security.AAANationalEncryptionBP;
import com.rossgroupinc.memberz.bp.webservice.WebLetterBP;
import com.rossgroupinc.memberz.bp.webservice.WebServiceBP;
import com.rossgroupinc.memberz.constants.PaymentMethod;
import com.rossgroupinc.memberz.data.model.ECheck;
import com.rossgroupinc.memberz.data.model.MembershipNumber;
import com.rossgroupinc.memberz.model.AutorenewalCard;
import com.rossgroupinc.memberz.model.BatchHeader;
import com.rossgroupinc.memberz.model.BatchPayment;
import com.rossgroupinc.memberz.model.BillSummary;
import com.rossgroupinc.memberz.model.CoverageLevel;
import com.rossgroupinc.memberz.model.D3kAudit;
import com.rossgroupinc.memberz.model.Discount;
import com.rossgroupinc.memberz.model.DonationHistory;
import com.rossgroupinc.memberz.model.Donor;
import com.rossgroupinc.memberz.model.InternetActivity;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.MemberCode;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.MembershipCode;
import com.rossgroupinc.memberz.model.MembershipFees;
import com.rossgroupinc.memberz.model.OtherPhone;
import com.rossgroupinc.memberz.model.PaymentPlan;
import com.rossgroupinc.memberz.model.PaymentSummary;
import com.rossgroupinc.memberz.model.PlanBilling;
import com.rossgroupinc.memberz.model.SalesAgent;
import com.rossgroupinc.memberz.model.SegmentationSetup;
import com.rossgroupinc.memberz.model.Solicitation;
import com.rossgroupinc.memberz.model.SolicitationDiscount;
import com.rossgroupinc.memberz.model.Territory;
import com.rossgroupinc.memberz.vo.CodesVO;
import com.rossgroupinc.memberz.webservice.model.BlowFishEncryptedCookieValues;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.DateUtils;
import com.rossgroupinc.util.JavaUtilities;
import com.rossgroupinc.util.LogUtils;
import com.rossgroupinc.util.RGILoggerFactory;
import com.rossgroupinc.util.SearchCondition;
import com.rossgroupinc.util.StringUtils;
import com.rossgroupinc.util.ValueHashMap;
import com.rossgroupinc.conxons.cache.DropDownUtil;
import com.rossgroupinc.memberz.bp.payment.CreditCardProcessorBP;
import com.rossgroupinc.memberz.data.model.CreditCard;

public class MembershipServiceBP extends BusinessProcess {

	protected class PaymentResponseInfo {
		
		public String paymentType;
		public String paymentAmount;
		public boolean paymentAttempted = false;
		public boolean isPaymentSuccess = false;
		public String paymentMessage;
		public String paymentAcctNum;
		
		public PaymentResponseInfo() {}

	}
	
	private static final long serialVersionUID = 1L;
	protected static final String	CONFIG_FILE = "memberz/soa/MembershipService.xml";
	protected static Document configuration;
	private static Logger log = LogManager.getLogger(MembershipServiceBP.class.getName(), new RGILoggerFactory());
	private static final String ADD_ASSOCIATE_VALIDATION_XML 				= "memberz/soa/MembershipServiceAddAssociate.xml";
	private static final String CANCEL_ASSOCIATE_VALIDATION_XML 				= "memberz/soa/MembershipServiceCancelAssociate.xml";
	private static final String CHANGE_COVERAGE_VALIDATION_XML 				= "memberz/soa/MembershipServiceChangeCoverage.xml";
	private static final String ENROLL_VALIDATION_XML 				= "memberz/soa/MembershipServiceEnroll.xml";
	private static final String DUPLICATE_MEMBERSHIP_VALIDATION_XML 				= "memberz/soa/MembershipServiceDuplicateMembership.xml";
	private static final String GET_DROP_DOWN_VALIDATION_XML 				= "memberz/soa/MembershipServiceGetDropDown.xml";
	private static final String GET_DUPLICATE_CARD_LIST_VALIDATION_XML 				= "memberz/soa/MembershipServiceGetDuplicateCardHistory.xml";
	private static final String MAKE_PAYMENT_VALIDATION_XML 				= "memberz/soa/MembershipServiceMakePayment.xml";
	private static final String REQUEST_DUPLICATE_CARD_VALIDATION_XML 				= "memberz/soa/MembershipServiceRequestDuplicateCard.xml";
	protected static final String UPDATE_MEMBER_VALIDATION_XML 				= "memberz/soa/MembershipServiceUpdateMember.xml";
	private static final String UPDATE_MEMBERSHIP_HOME_ADDRESS_VALIDATION_XML 				= "memberz/soa/MembershipServiceUpdateMembershipHomeAddress.xml";
	private static final String UPDATE_MEMBER_NAME_VALIDATION_XML 				= "memberz/soa/MembershipServiceUpdateMemberName.xml";
	private static final String UPDATE_MEMBERSHIP_PRIMARY_PHONE_VALIDATION_XML 				= "memberz/soa/MembershipServiceUpdateMembershipPrimaryPhone.xml";
	private static final String UPDATE_MEMBER_EMAIL_VALIDATION_XML 				= "memberz/soa/MembershipServiceUpdateMemberEmail.xml";
	private static final String REGISTER_POS_SALE_VALIDATION_XML 				= "memberz/soa/MembershipServiceRegisterPosSale.xml";
	private static final String APPLY_PAYMENT_VALIDATION_XML 				= "memberz/soa/MembershipServiceApplyPayment.xml";
	private static final String GET_MEMBERSHIP_COMPONENT_DUES_VALIDATION_XML 				= "memberz/soa/MembershipServiceGetMembershipComponentDues.xml";
	private static final String RESET_MEMBER_WEB_PASSWORD_VALIDATION_XML 				= "memberz/soa/MembershipServiceResetMemberWebPassword.xml";
	private static final String ENROLL_MEMBERSHIP_IN_EBILL_VALIDATION_XML 				= "memberz/soa/MembershipServiceEnrollMembershipInEbilling.xml";
	private static final String IS_MEMBERSHIP_ENROLLED_IN_EBILL_VALIDATION_XML 				= "memberz/soa/MembershipServiceIsMembershipEnrolledInEbilling.xml";
	private static final String REMOVE_MEMBERSHIP_FROM_EBILL_VALIDATION_XML 				= "memberz/soa/MembershipServiceRemoveMembershipFromEbilling.xml";	
	//Message constants
	protected static final String genWSExceptionMsg = "Unexpected system error has occurred.";
	protected static final String genValidationMsg = "Failed validation.";
	protected static final String genErrorDuringValidationMsg = "Error during validation.";
	protected static final String genOutOfTerriroryMsg = "Unable to look up Out of Territory memberships.";
	protected static final String genBrandCardListInvalidZipCodeMsg = "invalid zip code";
	protected static final String genInvalidAgentId = "Invalid agent id. Please contact administrator.";
	protected static final String genOneAssociateReq = "At least one associate member is required.";
	protected static final String genMembershipIdInvalid = "Membership ID is invalid. ";
	protected static final String genMembershipIdReq = "Membership ID is required.";
	protected static final String genAssociateValidationMsg = "Failed associate member validation!";
	protected static final String genReviewErrList = "Please review error list.";
	protected static final String genMemberNotFoundMsg = "Member not found. ";
	protected static final String genMembershipNotFoundMsg = "Membership not found. ";
	protected static final String genSalesAgentNotFoundMsg = "Sales agent not found. ";
	protected static final String genDuplicateMembershipFoundMsg = "Duplicate membership(s) found.";
	protected static final String genDuplicateEmailCheckMsg = "Had Error Check Duplicate Email.";
	protected static final String genDuplicateDonorCheckMsg = "Had Error Check Duplicate Donor.";
	protected static final String genNoEmailForEbillingCheckMsg = "Had Error Check Email Address For Enrolling in EBilling.";
	protected static final String genInvalidMarketCodeMsg = "Discount code is not applicable or not valid";	
	protected static final String genMarketCodeRequiredMsg= "Discount code is required";	
	protected static final String genNoPrimaryPhoneMsg = "Had No Primary Phone Information.";
	protected static final String genMembershipIdsNotInSameMembershipMsg = "Invalid membershipIds";
	protected static final String genNoMatchedDonorNumberMsg= "Could not match the donor mumber";
	protected static final String genNoDonorPhoneOrEmailMsg= "Gift Membership must have donor's email and phone";
	protected static final String genNoCreditCardMsg = "Invalid credit card information.";
	protected static final String genNoActiveMembershipAllowedForInstallmentPayEnrollMsg = "Had error trying to enroll active membership to installment plan.";
	protected static final String genUpdateBillingWithSameRenewalMethodValueMsg = "Had error trying to update billing with same renewalMethod value";
	
	protected static final String genEncryptionMsg = "Had Error Encrypt by Blow Fish.";
	protected static final String genDecryptionPOSMsg = "Had Error to Decrypt POS message.";
	protected static final String genBlowFishEncryptionMsg = "Had Error Get Blow Fish Cookie Value.";
	protected static final String genDuplicateEmailMsg = "Email Address already exists.";
	protected static final String getMemberMismatch = "Membership number does not match member information.";
	protected static final String getMemberEmailNotMatched = "Email address does not match information on record.";
	protected static final String genEmailAttachedToWebProfile = "Unable to delete email address.  Email is attached to a web profile.";
	protected static final String genEmailAddressFlagsMsg = "The primary member email address must indicate None or Refused if no email address is provided.";
	protected static final String genPaymentPlanMsg = "Had Error Get Payment Plan Structure.";
	
	protected static final String ERROR_CODE_GENERAL_UNKONWN = "10001";
	protected static final String ERROR_CODE_VALIDATION = "10002";
	protected static final String ERROR_CODE_VALIDATION_UNKNOWN = "10003";
	protected static final String ERROR_CODE_INVALID_SALESAGENT = "10004";
	
	protected static final String ERROR_CODE_REQUEST_TEMP_CARD_INVALID_EMAIL = "10002";
	protected static final String ERROR_CODE_REQUEST_TEMP_CARD_INVALID_SUBJECT = "10003";
	protected static final String ERROR_CODE_REQUEST_TEMP_CARD_INVALID_MESSAGE = "10004";
	protected static final String ERROR_CODE_REQUEST_TEMP_CARD_INVALID_MEMBERSHIP_ID = "10005";
	protected static final String ERROR_CODE_REQUEST_TEMP_CARD_RANDOM_MEMBERSHIP_IDS = "10006";
	
	protected static final String RETURN_CODE_APPLYPAYMENT_SUCCESS = "0";
	protected static final String ERROR_CODE_APPLYPAYMENT_GENERAL = "1";
	
	protected static final String RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT = "2";
	protected static final String RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE = "3";
	
	protected static final String CWP_PROFILE_DESCRIPTION_SUCCESS = "Success";
	protected static final String CWP_PROFILE_DESCRIPTION_UNFOUND = "Unfound";
	protected static final String CWP_PROFILE_DESCRIPTION_ERROR = "Error";
	protected static final String CWP_PROFILE_DESCRIPTION_UNREACHABLE = "Unreachable";
	
	private PaymentResponseInfo paymentResponse = new PaymentResponseInfo();
	protected MembershipUtilBP membershipUtilBP = MembershipUtilBP.getInstance();
	protected MemberEmailCheckBP memberEmailCheckBP = MemberEmailCheckBP.getInstance();
	
	protected boolean deleteWhenValuesAreEmpty = false;
	
	public MembershipServiceBP(User user){
		super();
		this.user = getUser(user);
		configuration = getConfiguration(CONFIG_FILE, user);		
	}
	
	/**
	 * Calculate membership dues for SOA service Dues Calcualtor
	 * @param fullMembershipID
	 * @param memberEmail
	 * @param password
	 * @param passwordHintCode
	 * @param passwordHintAnswer
	 * @return
	 */
	public MembershipDues CalculateDues(String zipCode, int associateCount, String coverageLevel, 
			String marketCode, String[] discounts, String membershipNumber)
	{
		MembershipDues dues = null;		
		try {
			
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Calculate Dues");
				getLogger().debug("Zip Code: " + zipCode);
				getLogger().debug("Associate Count: " + associateCount);
				getLogger().debug("Coverage Level: " + coverageLevel);
				getLogger().debug("Market Code: " + marketCode);
				getLogger().debug("**************************\n");			
			}
						
			//validate input, market code is optional
			//zipCode
			validateZipCode(zipCode, membershipNumber);
			
			//associate count
			validateAssociateCount(associateCount);
			
			BigDecimal branchKy = membershipUtilBP.getBranchKy(zipCode);
			String regionCd = membershipUtilBP.getRegionCd(zipCode);
			BigDecimal divisionKy = membershipUtilBP.getDivisionKy(zipCode);
			String state = membershipUtilBP.getDuesState(zipCode);
			
			//validate coverage
			String covLevCd = null;
			try
			{
				membershipUtilBP.validateCoverageForZip(coverageLevel, regionCd, divisionKy);
				covLevCd = membershipUtilBP.getCoverageByWsType(coverageLevel);
			}
			catch (Exception ex)
			{
				throw new WebServiceException(ex.getMessage());
			}
			
			MembershipDuesCalculatorUtil mDCU = new MembershipDuesCalculatorUtil(user);
			
			Membership membership = null;
			if(membershipNumber != null && !membershipNumber.equals("")) // existing membership
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn = null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipNumber);
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				int cancelledMembers = 0; 
				for(Member member: membership.getMemberList()){
					if ( member.isCancelled()){
						cancelledMembers++;
					}
				}
				int activeAssocCount = membership.getMemberList().size()-cancelledMembers;
				if(activeAssocCount ==0 && associateCount ==0)
				{
					throw new WebServiceException("There are no active members on this membership");
				}
				
				//now we know there is non-cancelled member(s) in membership, for existing membership we can add associate or upgrade cov both no both
				validateUpgradeCoverageOrAddMember(associateCount, membership, covLevCd);  //covLevCd - BS etc.
				
				MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				if (bpMaint.getDoNotRenew(membership)){
					throw new WebServiceException("Future cancel membership can't be upgraded.");
				}
						
				regionCd = membershipUtilBP.getRegionCd(membership.getZip());
				
				int newAssocCount = activeAssocCount-1;
				if(associateCount > 0) //==> implies more associates needs to be added to the mbrship
				{
					newAssocCount = newAssocCount + associateCount;
				}
				
				//market code
//market code
				
//				String billingCategoryCd = "";
//				if (!marketCode.equalsIgnoreCase("")) {
//					billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);	
//				} else {
//					billingCategoryCd = membership.getBillingCategoryCd();
//				}
				//wwei/yhu  2019/04/01
				//LTV vpp  rule 1. there is no market code (default) or Market code is 'INTD'
	            //                 LTV tier and specialty member  use primary basic rider's billing category, else '0042'
				//         rule 2. default billing category from solicitation;
				String billingCategoryCd = "0042"; 
				if (!marketCode.equalsIgnoreCase("") && !marketCode.equals("INTD")) 
				{
					billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);	
				} 
				else 
				{
				
					if( membership.isOnTier() || membership.isSpecialtyMembership())
					{
						billingCategoryCd = membership.getPrimaryMember().getBasicRider().getBillingCategoryCd();
					}
					else
					{
						billingCategoryCd = "0042";
					}
						
				}
				
				//Prakash - 07/20/2018 - Dues By State - Start
				Collection<Discount> mkDiscounts = mDCU.CalculateMembershipDues(zipCode, newAssocCount, covLevCd.toUpperCase(), marketCode, billingCategoryCd, membership.getBranchKy(), membership.getDivisionKy(), regionCd, membership,membership.getDuesState() );
				//Prakash - 07/20/2018 - Dues By State - End
				ArrayList <DuesDiscountItem> discountItems = new ArrayList<DuesDiscountItem>();
				
				if (mkDiscounts != null) {
					for (Discount d : mkDiscounts) {
						if (d.getAppliesTo()!=null && d.getAppliesTo().equalsIgnoreCase("MBS")) {
							discountItems.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), d.getAppliesTo(), d.getPercentFl()));
						}
					}
				}
				
				ArrayList<Donation> donations = mDCU.getDonations();
				String balance = membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy()));
				dues = new MembershipDues(zipCode, associateCount, mDCU.getCoverageLevelText(), marketCode, mDCU.getMemberDues(), balance, "0.00", discountItems, donations, false);

			}
			else // new membership
			{
				boolean procDiscount = false;				
				ArrayList<DuesDiscountItem> ddis = new ArrayList<DuesDiscountItem>();
				List<String> requestedDisct = new ArrayList<String>();
				String arCd = getSetting("duesCalcAutoRenewCd");
				
				//market code
				String billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);
				
				//discounts are requested
				if(discounts != null && discounts.length > 0){
					//copy user request
					requestedDisct = new ArrayList<String>(Arrays.asList(discounts));					
					//cleanse based on setting
					requestedDisct.retainAll(getAllwedDiscountsSetting());
					
					procDiscount = true;					
				}				
				
				//inspect market code rules for Auto Renewal discount
				if(!StringUtils.blanknull(marketCode).equals("")){
					MarketCode mcd = GetMarketCode(marketCode);
					//market code must be active (by date)
					if(!mcd.isActive()){
						//procDiscount = false;
						dues = new MembershipDues(genInvalidMarketCodeMsg, "1" );
						return dues;
					} else {
						//check if configured in market code discounts list
						if(marketCodeHasAR(mcd, arCd)){
							// add if required
							if(mcd.getAutoRenewalRequired()){
								if(!requestedDisct.contains(arCd)) {
									requestedDisct.add(getAGIArCdByMarketCode(mcd, arCd));
									procDiscount = true;
								} else {
									if(requestedDisct.contains(arCd)) {
										requestedDisct.remove(arCd);
										requestedDisct.add(getAGIArCdByMarketCode(mcd, arCd));
										procDiscount = true;
									}
								}
							} else {
								if(requestedDisct.contains(arCd)) {
									requestedDisct.remove(arCd);
									requestedDisct.add(getAGIArCdByMarketCode(mcd, arCd));
									procDiscount = true;
								}
							}
						} else {
							//remove discount if present (not allowed)
							if(requestedDisct.contains(arCd)){
								requestedDisct.remove(arCd);
							}							
						}
						
						/*
						 if(mcd.getDiscountCodes().contains(arCd)){
							// add if required
							if(mcd.getAutoRenewalRequired()){
								if(!requestedDisct.contains(arCd)) requestedDisct.add(arCd);
								procDiscount = true;
							}							
						} else {
							//remove discount if present (not allowed)
							if(requestedDisct.contains(arCd)){
								requestedDisct.remove(arCd);
							}							
						}
						 */
					}
				}
																
				//Calculate Discounts
				if(procDiscount){
					//rewrite dicounts list bases on market code rules
					discounts = requestedDisct.toArray(new String[0]);
					
					if(discounts.length > 0) {
						ArrayList<SearchCondition> condsDiscountCd = new ArrayList<SearchCondition>();
						condsDiscountCd.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.IN, discounts));
						Collection<Discount> dscItems = Discount.getDiscountList(user, condsDiscountCd, divisionKy, regionCd, branchKy);
						if(dscItems.size() > 0){
							for (Discount d : dscItems){
								ddis.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), d.getAppliesTo()));
							}
						}
					}
				}
				
				//Calculate Dues
				//Prakash - 07/20/2018 - Dues By State - Start
				mDCU.CalculateMembershipDues(zipCode, associateCount, covLevCd.toUpperCase(), marketCode, billingCategoryCd, branchKy, divisionKy, regionCd, null, state);
				//Prakash - 07/20/2018 - Dues By State - End
				dues = new MembershipDues(zipCode, associateCount, mDCU.getCoverageLevelText(), marketCode, mDCU.getMemberDues(), null, null, ddis, null, true);
			}
						
		} catch (WebServiceException e){	
			dues = new MembershipDues(e.getMessage(), "1" );			
		} catch (Exception e) {
			getLogger().error("", e);
			dues = new MembershipDues(genWSExceptionMsg, "1");
		}

		return dues;
	}	

	//help function to solve problem of AGI AR discount situation.  
	private boolean marketCodeHasAR (MarketCode mcd, String arCd) 
	{ 
		boolean result = false ; 
		//assuming mcd is active, because the check is done.  
		if (mcd.getDiscountCodes() != null && mcd.getDiscountCodes().size()> 0 ) { 
			for (String mdc: mcd.getDiscountCodes()) { 
					if (mdc.toUpperCase().startsWith(arCd)) { 
						result = true;  
						break;  
					} 
			} 
		} 
		return result;  
	} 
	
	//help function to get the AGI AR discount, assuming market code has only one AR discount and it starts with "AR" 
	private String getAGIArCdByMarketCode (MarketCode mcd, String arCd) 
	{ 
		String result = ""; 
		
		//assuming mcd is active, because the check is done.  
		if (mcd.getDiscountCodes() != null && mcd.getDiscountCodes().size()> 0 ) { 
			for (String mdc: mcd.getDiscountCodes()) { 
				if (mdc.toUpperCase().startsWith(arCd)) { 
					result = mdc; 
					break;  
				} 
			} 
		} 
		return result;  
	} 

	public BaseMembershipDues CalculateUpgradeDues (String fullMembershipID, String marketCode, String source) {
		//validation of fullMembershipID
		BaseMembershipDues baseDues = null;
		Membership membership = null;
		
		//validate membership id 
		if ( fullMembershipID.length() != 16)
		{						
			return new BaseMembershipDues("membership ID needs to be 16 digits long", "1" );	
		}
		else
		{
			String mbrID = fullMembershipID.substring(6,13);
			try
			{
				membership = new Membership(user, mbrID);
			}
			catch (Exception ex)
			{
				return new BaseMembershipDues("invalid membership ID ", "1" );	
			}					
		}
		
		try {
			//validate marketCode
//			if(StringUtils.blanknull(marketCode).equals("")){
//				marketCode = getSetting("defaultMarketCode");
//			}			

			MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			if (bpMaint.getDoNotRenew(membership)){
				return new BaseMembershipDues("Future cancel membership can't be upgraded.", "1");	
			}
			
			String billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);
			String zipCode = membership.getZip();
			
			BigDecimal branchKy = membershipUtilBP.getBranchKy(zipCode);
			String regionCd = membershipUtilBP.getRegionCd(zipCode);
			BigDecimal divisionKy = membershipUtilBP.getDivisionKy(zipCode);
			//Prakash - 07/20/2018 - Dues By State - Start
			String state = membershipUtilBP.getDuesState(zipCode);
			//Prakash - 07/20/2018 - Dues By State - End
			
			ArrayList<String> coverages = getUpgradeableCoverages(membership.getCoverageLevelCd(), source);
			
			int activeAssocCount = membership.getNonCancelledMemberList().size();
			if(activeAssocCount ==0)
			{
				return new BaseMembershipDues("There are no active members on this membership", "1");
			}
			int existingAssociateCount = activeAssocCount-1;
			
			Collection<Discount> mkDiscounts = null;
			ArrayList <DuesDiscountItem> discountItems = new ArrayList<DuesDiscountItem>();
			boolean isDiscountInitialized = false; 
			
			MembershipDuesCalculatorUtil mcu = new MembershipDuesCalculatorUtil(user);
			Collection<MembershipDues> dues = new ArrayList<MembershipDues>();	
			for(int i=0; i<coverages.size(); i++){			
				String cov = coverages.get(i);
				String covText = membershipUtilBP.getCoverageByMZPType(cov);		
				//Prakash - 07/20/2018 - Dues By State - Start
				mkDiscounts = mcu.CalculateMembershipDues(zipCode, existingAssociateCount, cov, marketCode, billingCategoryCd, branchKy, divisionKy, regionCd, membership, state);
				//Prakash - 07/20/2018 - Dues By State - End
				
				//since discounts are tied to market code, it should be initialzed once no matter coverage levels.
				if (!isDiscountInitialized) {
					isDiscountInitialized = true;
					if (mkDiscounts != null) {
						for (Discount d : mkDiscounts) {
							if (d.getAppliesTo()!=null && d.getAppliesTo().equalsIgnoreCase("MBS")) {
								discountItems.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), d.getAppliesTo(), d.getPercentFl()));
							}
						}
					}
				}
				
				int newAssociateCount = 0;
				ArrayList<Donation> donations = mcu.getDonations();
				
				dues.add(new MembershipDues(zipCode, newAssociateCount, covText, marketCode, mcu.getMemberDues(), "0.00", membership.getPaymentAt().toString(), discountItems, donations, false));			
			}
			
			baseDues = new BaseMembershipDues(dues);
			
		} catch (WebServiceException e){	
			baseDues = new BaseMembershipDues(e.getMessage(), "1" );			
		} catch (Exception e) {
			getLogger().error("", e);
			baseDues = new BaseMembershipDues(genWSExceptionMsg, "1");
		}
		
		return baseDues;
	}
	
	public BaseMembershipDues CalculateBaseDues(String zipCode, int associateCount, String marketCode, String[] cls)
	{
		BaseMembershipDues baseDues = null;
		try {
			
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Calculate Base Dues");
				getLogger().debug("Zip Code: " + zipCode);
				getLogger().debug("Associate Count: " + associateCount);
				getLogger().debug("Market Code: " + marketCode);
				getLogger().debug("**************************\n");			
			}
			String DEBUG_MODULE = "WM_CalculateBaseDues_" + Calendar.getInstance().getTimeInMillis() +"";
			MembershipUtilBP mubp = MembershipUtilBP.getInstance();
			
			long startTime = System.nanoTime(); 
			
			//validate input, market code is optional
			//zipCode
			validateZipCode(zipCode);
			
			//associate count
			validateAssociateCount(associateCount);
			
			BigDecimal branchKy = membershipUtilBP.getBranchKy(zipCode);
			String regionCd = membershipUtilBP.getRegionCd(zipCode);
			BigDecimal divisionKy = membershipUtilBP.getDivisionKy(zipCode);
			//Prakash - 07/20/2018 - Dues By State - Start
			String state = membershipUtilBP.getDuesState(zipCode);
			//Prakash - 07/20/2018 - Dues By State - End
			
			//market code			
			if(StringUtils.blanknull(marketCode).equals("")){
				marketCode = getSetting("defaultMarketCode");
			}
			
//			//validate the market code
//			if(!StringUtils.blanknull(marketCode).equals("")){
//				MarketCode mcd = GetMarketCode(marketCode);
//				//market code must be active (by date)
//				if(!mcd.isActive()){
//					throw new WebServiceException(genInvalidMarketCodeMsg);
//				}
//			}
								
			String billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);
						
			MembershipDuesCalculatorUtil mcu = new MembershipDuesCalculatorUtil(user);
						
			//CALCULATE DUES			
			ArrayList<String> orderBy = new ArrayList<String>();
			orderBy.add(CoverageLevel.RANK);			
			SortedSet<CoverageLevel> coverages = CoverageLevel.getAvailableCoverageLevelList(user, divisionKy, regionCd, orderBy, "STD");
			Collection<MembershipDues> dues = new ArrayList<MembershipDues>();	
			for(CoverageLevel cl : coverages){		
				String clcd = cl.getCoverageLevelCd(); 
				boolean flag = false; 
				if (cls != null) {
					for (int i = 0; i<cls.length; i++ ) {
						if (clcd.equals(cls[i])){
							flag = true; 
							break;
						}
					}
				} else {
					flag = true; 
				}
				
				if (flag) {
					//Prakash - 07/20/2018 - Dues By State - Start
					mcu.CalculateMembershipDues(zipCode, associateCount, cl.getCoverageLevelCd(), marketCode, billingCategoryCd, branchKy, divisionKy, regionCd, null, state);
					//Prakash - 07/20/2018 - Dues By State - End
					dues.add(new MembershipDues(zipCode, associateCount, mcu.getCoverageLevelText(), marketCode, mcu.getMemberDues(), null, null, null, null, true));	
				}
			}
			
			baseDues = new BaseMembershipDues(dues);
			
			mubp.debugExecutionTime(startTime, DEBUG_MODULE, true); 
						
		} catch (WebServiceException e){	
			baseDues = new BaseMembershipDues(e.getMessage(), "1" );			
		} catch (Exception e) {
			getLogger().error("", e);
			baseDues = new BaseMembershipDues(genWSExceptionMsg, "1");
		}

		return baseDues;
	}	

	
	public MarketCode GetMarketCode(String marketCode){
		MarketCode mktCd = null;
		try {
			
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Get Market Code Details");
				getLogger().debug("Market Code: " + marketCode);
				getLogger().debug("**************************\n");			
			}
			
			if(StringUtils.blanknull(marketCode).equals("")){
				throw new WebServiceException(genMarketCodeRequiredMsg);
			}						
			
			Solicitation solicitation = Solicitation.getSolicitation(user, marketCode);
						
			if(!solicitation.getWebIncludeFl()){ /* only send it if it's available on the web */
				throw new WebServiceException(genInvalidMarketCodeMsg);
			}
			
			mktCd = new MarketCode(solicitation);
			
			if(!mktCd.isActive()){
				throw new WebServiceException(genInvalidMarketCodeMsg);
			}
			
		} catch (WebServiceException e){	
			mktCd = new MarketCode(e.getMessage(), "1" );
		} catch (ObjectNotFoundException e){	
			mktCd = new MarketCode(genInvalidMarketCodeMsg, "1" );				
		} catch (Exception e) {
			getLogger().error("", e);
			mktCd = new MarketCode(genWSExceptionMsg, "1");
		}

		return mktCd;
	}
	
	public RequestTempCardResponse RequestTempCard(RequestTempCardRequest request) 
	{
		RequestTempCardResponse response = new RequestTempCardResponse() ;
		
		if (log.isDebugEnabled()){
			log.debug("**************************\n RequestTempCard");
		}
		
		boolean isValidated = true;
		
		String errCode = ERROR_CODE_GENERAL_UNKONWN;
		
		User user = getUser();
		Membership membership  = null;
		try{
			
			String email = request.getEmail();
			
			if(email == null || email.trim().equalsIgnoreCase("")) {
				errCode = ERROR_CODE_REQUEST_TEMP_CARD_INVALID_EMAIL;
				throw new Exception ("Invalid Email Address");
			}
			
			String subject = request.getSubject();
			
			if(subject == null || subject.trim().equalsIgnoreCase("")) {
				errCode = ERROR_CODE_REQUEST_TEMP_CARD_INVALID_SUBJECT;
				throw new Exception ("Invalid Email Subject");
			}
			
			String message = request.getMessage();
			
			if(message == null || message.trim().equalsIgnoreCase("")) {
				message = "";
			}
			
			String[] membershipIds = request.getMembershipIds();
			if(membershipIds == null || membershipIds.length==0) {
				errCode = ERROR_CODE_REQUEST_TEMP_CARD_INVALID_MEMBERSHIP_ID;
				throw new Exception ("No membership id was provided.");
			}
			
			Validator v = new Validator();
			
			String tempMembershipId = "";
			
			//validate 16-digit membershipIds and make sure they belong to the same membership
			for (int i = 0; i < membershipIds.length; i++) {
				String membershipId =membershipIds[i].substring(6, 13);
				
				if (tempMembershipId.equals("")) {
					tempMembershipId = membershipId;
					membership = new Membership(User.getGenericUser(), membershipId);
				} else {
					if (!tempMembershipId.equals(membershipId)) {
						isValidated = false; 
					}
				}
			} //end of validation
			
			if (!isValidated){
				errCode = ERROR_CODE_REQUEST_TEMP_CARD_RANDOM_MEMBERSHIP_IDS;
				throw new Exception ("Ids don't belong to the same membership");
				
			} else {
				for (int i = 0; i < membershipIds.length; i++) {
					ValueHashMap rptParms = new ValueHashMap();
					rptParms.putString("CLUB_CD",ClubProperties.getClubCode()); 
					rptParms.putString("CLUB_NAME",ClubProperties.getString("CLUB_NAME", membership.getDivisionKy(), membership.getRegionCode()));
					rptParms.putString("MEMBER_KY","XXX");
					
					String attachmentLink = ReportBean.getReportLink(user,"TEMPCREDENTIAL",null,rptParms,false,false,"pdf");
					
					attachmentLink = StringUtils.replace("&MEMBER_KY=XXX","",attachmentLink);
					  	
					String fname = DateUtilities.now().getTime() + "TempCard.pdf";
					
					String associateId = membershipIds[i].substring(13, 15);
					
					BigDecimal memberKy = null;
					
					for (Member m: membership.getMemberList()) {
						if (associateId.equals(m.getAssociateId()) ){
							memberKy = m.getMemberKy();
							
							//using the server information "ServiceURL" from webmember configuration currently, should probably be obtained on the java side instead.
							URL url = new URL(
									JavaUtilities.getServerURL()+
									(attachmentLink.startsWith("/")?"":"/") + 
								attachmentLink+
								"&MEMBER_KY=" + memberKy + 
								"&FileName=" + fname);
							URLConnection connection = url.openConnection();
							connection.connect();
							connection.getInputStream().close();
							
							EmailTempCardPopupBP bp = BPF.get(user,EmailTempCardPopupBP.class);
							bp.sendEmail(memberKy, email, System.getProperty("conxons.process.OutputDirectory") + "/", fname, message, v, subject);
						}
					}
				}
				response.setCheckResult(true);
			}
		} catch (Exception e) {
			log.error("", e);
			getLogger().error("", e);		
			
			if (errCode.equals(ERROR_CODE_GENERAL_UNKONWN)){
				response = new RequestTempCardResponse(genWSExceptionMsg, errCode);
			} else {
				response = new RequestTempCardResponse(e.getMessage(), errCode);
			}
				
			response.setErrors(null);
			response.setCheckResult(false);
		}
		
		return response;
	
	}
	
	public IsDuplicateMembershipResponse IsDuplicateMembership(IsDuplicateMembershipRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is Duplicate Membership Request");
			getLogger().debug("Request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		SimpleMembership[] dupMemberships = null;
		Collection<ValidationError> errList = new ArrayList<ValidationError>();
		IsDuplicateMembershipResponse response = new IsDuplicateMembershipResponse();
		String errCode = ERROR_CODE_GENERAL_UNKONWN;
		
		try {
			if(request !=null){				
				try
				{
					//Validation of input values
					errList =  membershipUtilBP.performValidation(request, DUPLICATE_MEMBERSHIP_VALIDATION_XML);
					if (errList !=null && !errList.isEmpty())
					{
						errCode = ERROR_CODE_VALIDATION; 
						throw new WebServiceException(genValidationMsg);
					}
					else
					{
						errList = new ArrayList<ValidationError>();
					}
				}
				catch (Exception e)
				{
					errCode = ERROR_CODE_VALIDATION_UNKNOWN; 
					throw new WebServiceException(genErrorDuringValidationMsg);
				}
				
				MembershipServiceBP serviceBp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
				String salesAgentId = "";
				if(request.getAgentId() !=null && !request.getAgentId().equals(""))
				{
					salesAgentId = request.getAgentId();
				}
				else
				{
					salesAgentId =   serviceBp.getSetting("defaultSalesAgent");
				}
				SalesAgent sa = serviceBp.getSalesAgent(salesAgentId); 
				
				if(sa == null) {
					errCode = ERROR_CODE_INVALID_SALESAGENT;
					throw new Exception ("Failed to get the agent id for the transaction");
				}
				else
				{
					this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
				}
				
				MembershipUtilBP membershipUtilBP = MembershipUtilBP.getInstance();
				DuplicateMembershipCheckBP dbp = DuplicateMembershipCheckBP.getInstance();
				boolean checkEmail = dbp.checkEmail(request);
				
				SimpleMembership sm = request.getSimpleMembership(); 
				if (!checkEmail){
					sm.getPrimaryMember().setEmail("");

					//create associate member(s)
					if(sm.getAssociates() != null && sm.getAssociates().length > 0)
					{
						for(int i = 0; i < sm.getAssociates().length; i++)
						{
							sm.getAssociates()[i].setEmail("");
						}				
					}
				}
				dupMemberships = membershipUtilBP.getDuplicateMemberships(sm, user);
				
				SimpleMembership[] dupMemberships1 = membershipUtilBP.removeCanceled18MonthsMembership(dupMemberships);
				
				if(dupMemberships1.length > 0)
				{
					response.setCheckResult(true);
					response.setDuplicateMemberships(dupMemberships);
				} else {
					//after removal , dupMemberships1.length = 0
					if (dupMemberships.length >0){
						response.setCheckResult(false);
						response.setDuplicateMemberships(dupMemberships);
					} else {
						response.setCheckResult(false);	
					}
				}
				
				response.setSimpleMembership(request.getSimpleMembership());
				response.setErrors(null);
				
			}
		} 
		catch (WebServiceException e){	
			
			response = new IsDuplicateMembershipResponse(e.getMessage(), errCode);	
			
			response.setSimpleMembership(request.getSimpleMembership());
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setCheckResult(false);
			
		} catch (Exception e) {
			getLogger().error("", e);			
			
			if (errCode.equals(ERROR_CODE_GENERAL_UNKONWN)){
				response = new IsDuplicateMembershipResponse(genWSExceptionMsg, errCode);
			} else {
				response = new IsDuplicateMembershipResponse(e.getMessage(), errCode);
			}
			
			response.setErrors(null);
			response.setSimpleMembership(request.getSimpleMembership());
			response.setCheckResult(false);
		}
		return response;
	}
	
	public IsDuplicateEmailResponse IsDuplicateEmail(IsDuplicateEmailRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is Duplicate Email request");
			getLogger().debug("Is Duplicate Email request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		IsDuplicateEmailResponse response = null;
		
		try {
			if(request !=null){	
				try {
					
					String email = request.getEmail();
					if (email==null || email.equalsIgnoreCase("")) {
						response = new IsDuplicateEmailResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid email address");
						response.setInfoList(infoList);						
					}
					
					boolean emailExists = memberEmailCheckBP.isEmailDuplicated(email, null, null);
					if (emailExists) {
						response = new IsDuplicateEmailResponse("Success", "0");
						response.setCheckResult(true);
					} else {
						response = new IsDuplicateEmailResponse("Success", "0");
						response.setCheckResult(false);
					}
				} catch (Exception e) {
					throw new WebServiceException(genDuplicateEmailCheckMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new IsDuplicateEmailResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to validate duplicate email! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public GetBlowFishEncryptedCookieValuesResponse getBlowFishEncryptedCookieValues(GetBlowFishEncryptedCookieValuesRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get BlowFish Encrypted Cookie Values reques");
			getLogger().debug("Get BlowFish Encrypted Cookie Values request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		GetBlowFishEncryptedCookieValuesResponse response = null;
		
		try {
			if(request !=null){	
				try {
					
					String membershipID = request.getMembershipID();
					if (membershipID==null || membershipID.equalsIgnoreCase("")) {
						response = new GetBlowFishEncryptedCookieValuesResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid membershipID");
						response.setInfoList(infoList);						
					} else {
						response = new GetBlowFishEncryptedCookieValuesResponse();
						BlowFishEncryptedCookieValues vals = null;
						
						try {
							
							WebServiceBP bp = (WebServiceBP) BPF.get(User.getGenericUser(), WebServiceBP.class);
							vals = bp.GetEncryptedBlowFishCookieValues(membershipID);
							response.setCookieName(vals.get_cookie_name());
							response.setEmail(vals.get_member_email());
							response.setMemberID(vals.get_member_id());
							response.setMemberIDMa(vals.get_member_id_ma());
							response.setUserName(vals.get_user_name());
							response.setZipCode(vals.get_zip_code());
							response.setMembershipKy(vals.get_membership_key());
							
							String msg = vals.get_message();
							String info = vals.get_result();

						} catch (Exception e) {
							log.error("", e);
						}
					}
					
				} catch (Exception e) {
					throw new WebServiceException(genBlowFishEncryptionMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetBlowFishEncryptedCookieValuesResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to Get BlowFish Encrypted Cookie Values -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public EncryptValueByBlowFishResponse EncryptByBlowFish(EncryptValueByBlowFishRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get BlowFish Encrypted Value request");
			getLogger().debug("Get BlowFish Encrypted Value request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		EncryptValueByBlowFishResponse response = null;
		
		try {
			if(request !=null){	
				try {
					
					String input = request.getInput();
					if (input==null || input.equalsIgnoreCase("")) {
						response = new EncryptValueByBlowFishResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid input");
						response.setInfoList(infoList);						
					} else {
						response = new EncryptValueByBlowFishResponse();
						String output = "";
						
						try {
							WebServiceBP wsBP = BPF.get(user,WebServiceBP.class);
							
							output = wsBP.EncryptByBlowFish(input);
							
							if (!output.equalsIgnoreCase(WebServiceBP.genEncryptionExceptionMsg) ){
								response.setOutput(output);
							} else {
								response = new EncryptValueByBlowFishResponse("Error", "1");	
								response.setErrors(null);
								infoList.add(WebServiceBP.genEncryptionExceptionMsg);
								response.setInfoList(infoList);		
							}
							
							
						} catch (Exception e) {
							log.error("", e);
						}
					}
					
				} catch (Exception e) {
					throw new WebServiceException(this.genEncryptionMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new EncryptValueByBlowFishResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to Get BlowFish Encrypted Value -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	
	public DecryptValueByPosResponse DecryptValueByPos(DecryptValueByPosRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get Decrypt Pos Value request");
			getLogger().debug("Get Decrypt Pos Value request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		DecryptValueByPosResponse response = null;
		
		try {
			if(request !=null){	
				try {
					
					String input = request.getInput();
					if (input==null || input.equalsIgnoreCase("")) {
						response = new DecryptValueByPosResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid input");
						response.setInfoList(infoList);						
					} else {
						response = new DecryptValueByPosResponse();
						String output = "";
						
						try {
							WebServiceBP wsBP = BPF.get(user,WebServiceBP.class);
							
							//disabled the decryption until further notification from Ed. [YHu - 2-29-2016]
							//output = wsBP.DecryptPosMessage(input);
							output = "Decryption Disabled";
							
							if (!output.equalsIgnoreCase(WebServiceBP.genDecryptionPosExceptionMsg) ){
								response.setOutput(output);
							} else {
								response = new DecryptValueByPosResponse("Error", "1");	
								response.setErrors(null);
								infoList.add(WebServiceBP.genDecryptionPosExceptionMsg);
								response.setInfoList(infoList);		
							}
							
							
						} catch (Exception e) {
							log.error("", e);
						}
					}
					
				} catch (Exception e) {
					throw new WebServiceException(this.genDecryptionPOSMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new DecryptValueByPosResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to Decrypt Pos Message -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public InstallmentPaymentPlanDuesResponse GetPaymentPlans(InstallmentPaymentPlanDuesRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get Payment Plan reques");
			getLogger().debug("Get Payment Plan request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		InstallmentPaymentPlanDuesResponse response = null;
		
		try {
			if(request !=null){	
				try {
					response = new InstallmentPaymentPlanDuesResponse();
					BigDecimal totalDues = request.getTotalDues();
					String source = request.getSource();
					
					PaymentPlanBP ppbp = new PaymentPlanBP(user);
					SortedSet<PaymentPlan> pPlans = ppbp.getActivePaymentPlans();
					
					Collection<InstallmentPayPlanItem> plans = new ArrayList<InstallmentPayPlanItem>();
					
					for (PaymentPlan pl : pPlans) {
						InstallmentPayPlanItem ppi = null; 
						ppi = new InstallmentPayPlanItem();
						ppi.setPlanKy(pl.getPaymentPlanKy().toString());
						ppi.setPlanName(pl.getPlanName());
						ppi.setNumberOfPays(pl.getNumberOfPayments().toString());
						ppi.setConvenienceFlag(pl.getConvenienceFl().toString());
						ppi.setConvenienceAt(pl.getConvenienceAt().toString());
						ppi.setMinimumAt(pl.getMinimumAt().toString());
						
						Collection<InstallmentPayItem> pays = calculatePaymentPlanPays(pl.getNumberOfPayments(), totalDues, pl);
						
						ppi.setPays(pays);
						plans.add(ppi);
					}
					
					response.setPlans(plans);
					
				} catch (Exception e) {
					throw new WebServiceException(genPaymentPlanMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new InstallmentPaymentPlanDuesResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to Get Payment Plan Values -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	private Collection<InstallmentPayItem> calculatePaymentPlanPays(BigDecimal numberOfPays, BigDecimal totalAmountDue, PaymentPlan plan ) throws Exception{
		Collection<InstallmentPayItem> pays = new ArrayList<InstallmentPayItem>();
		
		BigDecimal base = totalAmountDue.divide(numberOfPays, 2, BigDecimal.ROUND_FLOOR); 
		BigDecimal remainder = totalAmountDue.subtract(base.multiply(numberOfPays)).setScale(2);
		
		// calculate the final installment amounts. 
		// Configurable, remainder on first or remainder is last 
		int end   = numberOfPays.intValue();
		
		//today
		Calendar firstBillingDate = Calendar.getInstance();
		
		//billing date is the 1st day of current month. 
		Calendar billingDate = Calendar.getInstance(); //new instance for each rider so that the time is set starting from firstPaytment
		billingDate.set(Calendar.DAY_OF_MONTH, 1);
		billingDate.set(Calendar.HOUR_OF_DAY, 0);
		billingDate.set(Calendar.MINUTE, 0);
		billingDate.set(Calendar.SECOND, 0);
		billingDate.set(Calendar.MILLISECOND, 0);
		SimpleDateFormat format1 = new SimpleDateFormat("yyyy-MM-dd");
		
		if (firstBillingDate.get(Calendar.DAY_OF_MONTH) != 1){
			//advance to the 1st of next month
			billingDate.add(Calendar.MONTH, 1);
		} else {
			//today is the 1st of the month, 
		}

		for (int i = 1 ; i<=end ; i++) { 
			InstallmentPayItem pi = new InstallmentPayItem();
			
			
			BigDecimal installmentNumber = new BigDecimal(i); 
			BigDecimal totalInstallment = base;
			
			if (remainder.compareTo(BigDecimal.ZERO) > 0) { 
				if (i == end) { 
					// add the remainder to the last payment. 
					totalInstallment = totalInstallment.add(remainder); 
					remainder = BigDecimal.ZERO; 
				} 
			} 
			pi.setPaymentNumber(new Integer(i).toString());
			pi.setPaymentAmount(totalInstallment.toString());
			
			
			if (i==1) {
				//first payment, use today's date
				pi.setChargeDt( format1.format(firstBillingDate.getTime()));	
			} else {
				billingDate.add(Calendar.MONTH, plan.getMonthsBetweenPayments().intValue()); // for the next one
				pi.setChargeDt( format1.format(billingDate.getTime()));
			}
			
			pi.setConvenienceFee("0.00");
			pi.setStatus("U");
			pays.add(pi);
			
			//installmentMap.put(installmentNumber, totalInstallment); 
		} 
		 
		
		return pays;
	}
	
	public IsDuplicateEmailResponse IsDuplicateEmailExcludeMembership(IsDuplicateEmailExcludeMembershipRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is Duplicate Email Exclude Membership request");
			getLogger().debug("Is Duplicate Email Exclude Membership request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		IsDuplicateEmailResponse response = null;
		
		try {
			if(request !=null){	
				try {
					
					String email = request.getEmail();
					if (email==null || email.equalsIgnoreCase("")) {
						response = new IsDuplicateEmailResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid email address");
						response.setInfoList(infoList);						
					}
					
					String membershipID = request.getMembershipID();
					if (membershipID==null || membershipID.equalsIgnoreCase("")) {
						response = new IsDuplicateEmailResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid membershipID");
						response.setInfoList(infoList);						
					}
					
					String associateID = request.getAssociateID();
					if (associateID==null || associateID.equalsIgnoreCase("")) {
						response = new IsDuplicateEmailResponse("Error", "1");	
						response.setErrors(null);
						infoList.add("Please provide valid associateID");
						response.setInfoList(infoList);						
					}
					
					
					boolean emailExists = memberEmailCheckBP.isEmailDuplicated(email, membershipID, associateID);
					if (emailExists) {
						response = new IsDuplicateEmailResponse("Success", "0");
						response.setCheckResult(true);
					} else {
						response = new IsDuplicateEmailResponse("Success", "0");
						response.setCheckResult(false);
					}
				} catch (Exception e) {
					throw new WebServiceException(genDuplicateEmailCheckMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new IsDuplicateEmailResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to validate duplicate email Exclude Membership! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	/**
	 * For SOA service decrypt Password*/
	public Password DecryptPW(String authPW, String pw){
		
		Password password = null;
		
		try {
			
			if(!authPW.equals(getSetting("authPW"))){
				throw new WebServiceException("Access denied");
			}
			
			if(StringUtils.blanknull(pw).length() == 0){
				throw new WebServiceException("Password is required");
			}
		
		    password = new Password(ConxonsSecurity.instance().decrypt(pw));	

			
		} catch (WebServiceException e){
			password = new Password("1", e.getMessage());
		} catch (Exception e) {
			getLogger().error("", e);
			password = new Password("1", genWSExceptionMsg);
		}
	
		return password;
		
	}	
	
	/**
	 * For SOA service  Customer Id*/
	public CustomerID GetCustomerId(String fullMembershipID){
		
		CustomerID cId = null;
		Member member = null;
		MembershipNumber mn = null;
		
		try {
				
			try {
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				mn =  mbp.parseFullMembershipNumber(fullMembershipID);
				
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				Membership membership = new Membership(user, mn.getMembershipID());
				member = membership.getMember(mn.getAssociateID());
			} catch (Exception e) {
				throw new WebServiceException(e.getMessage());
			}
			
			//check digit
			if(!member.getCheckDigitNr().equals(new BigDecimal(mn.getCheckDigit())))
			{
				throw new WebServiceException("Invalid membership number. Please enter the number exactly as it appears on the card.");
			}
			
			cId = new CustomerID(member.getCustomerId());
			
		} catch (WebServiceException e){
			cId = new CustomerID("1", e.getMessage());
		} catch (Exception e) {
			getLogger().error("", e);
			cId = new CustomerID("1", genWSExceptionMsg);
		}
	
		return cId;
		
	}		

	
	public IsDuplicateDonorResponse IsDuplicateDonor(IsDuplicateDonorRequest request){
		
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is Duplicate Donor request");
			getLogger().debug("Is Duplicate Donor request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		boolean checkResult = false;
		Collection<String> infoList = new ArrayList<String>();
		
		IsDuplicateDonorResponse response = null;
		
		try {
			if(request !=null){	
				try {
					com.aaa.soa.object.models.Donor donor = request.getDonor();
					
					String addressLine1 = donor.getAddress1();
					String city = donor.getCity();
					String state = donor.getState();
					String zip = donor.getZip();
					
					String firstName = donor.getFirstName();
					if (firstName == null) {
						firstName = "";
					} else {
						firstName = firstName.toUpperCase();
					}
					
					String lastName = donor.getLastName();
					if (lastName == null){
						lastName = "";
					} else {
						lastName = lastName.toUpperCase();
					}
					
					if(nvl(addressLine1).equals("") || nvl(city).equals("") || nvl(state).equals("")  || nvl(zip).equals("") || nvl(firstName).equals("") || nvl(lastName).equals("") ){
						String msg = "invalid donor information, address and name can't be blank";
						
						response = new IsDuplicateDonorResponse(msg, "1");	
						response.setErrors(null);
						infoList.add("Failed to validate the duplicate donor -- " + msg);
						response.setInfoList(infoList);
						
						return response;
					}
					
					ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
					if (addressLine1 != null) criteria.add(new SearchCondition("AND", "ADDRESS_LINE1", SearchCondition.EQ, addressLine1.toUpperCase()));
					if (city != null) criteria.add(new SearchCondition("AND", "CITY", SearchCondition.EQ, city.toUpperCase()));
					if (state != null) criteria.add(new SearchCondition("AND", "STATE", SearchCondition.EQ, state.toUpperCase()));
					if (zip != null) criteria.add(new SearchCondition("AND", "ZIP", SearchCondition.EQ, zip));
					
					Iterator<com.rossgroupinc.memberz.model.Donor> donors = 
							com.rossgroupinc.memberz.model.Donor.getDonorList(user, criteria, null).iterator();
					
					while (donors.hasNext()){
						com.rossgroupinc.memberz.model.Donor cur = (com.rossgroupinc.memberz.model.Donor) donors.next();
						String curFN = cur.getFirstName();
						if (curFN == null) curFN = "";
						else curFN = curFN.toUpperCase();
						
						String curLN = cur.getLastName();
						if (curLN == null) curLN = "";
						else curLN = curLN.toUpperCase();
						
						if (curFN.equals(firstName) && curLN.equals(lastName)){
							donor.setDonorNumber(cur.getDonorNr());
							donor.setEmail(cur.getEmail());
							checkResult = true;
							break;
						}
					}
					response = new IsDuplicateDonorResponse("Success", "0");
					response.setCheckResult(checkResult);
					if (checkResult) {
						response.setDonor(donor);	
					}
					
				} catch (Exception e) {
					throw new WebServiceException(genDuplicateDonorCheckMsg);
				}
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new IsDuplicateDonorResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to validate duplicate donor! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	/**
	 * Create new membership  
	 * For SOA service Enroll
	 * @return
	 */
	public MembershipEnrollResponse Enroll(MembershipEnrollRequest enrollReq)
	{
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Enroll");
			getLogger().debug("Enroll Request: " + enrollReq.toString());	
			getLogger().debug("**************************\n");			
		}
		MembershipEnrollResponse response =  null;
		SimpleMembership[] dupMemberships = null;
		Membership msd = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = new ArrayList<ValidationError>();
		
		String DEBUG_MODULE = "WM_Enroll_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		boolean isGiftFreeMembershipEnroll = false;
		
		try {
			//performance test start time
			long startTime = System.nanoTime();
			
			
			if(enrollReq !=null){			
				MembershipEnrollBP enrollBp = MembershipEnrollBP.getInstance();
				
				isGiftFreeMembershipEnroll = mubp.isGiftFreeMembershipEnroll(enrollReq);
				
				try
				{
					//to disable the credit card section validation 
					if (isGiftFreeMembershipEnroll) {
						enrollReq.getPaymentParams().setCard(null);
					}
					//Validation of input values
					errList =  membershipUtilBP.performValidation(enrollReq, ENROLL_VALIDATION_XML);
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					else
					{
						errList = new ArrayList<ValidationError>();
					}
					
					if (!enrollReq.isDonorMembership()) {
						//check to see if email is not present and ensure that there is a reason why it is not present
						if (!areEmailAddressFlagsSpecified(enrollReq.getSimpleMembership()))
						{
							response = new MembershipEnrollResponse(genEmailAddressFlagsMsg, "1");
							errList.add(new ValidationError(enrollReq.getSimpleMembership().getPrimaryMember().getIdentifier(), genEmailAddressFlagsMsg, "Email", enrollReq.getSimpleMembership().getPrimaryMember().getEmail()));
							response.setErrors(errList);
							infoList.add("Failed to Enroll the membership! -- " + genEmailAddressFlagsMsg);						
							response.setInfoList(infoList);						
							return response;
						}
					}
					
					//check for duplicate email
					boolean emailExists = isEnrollmentEmailDuplicated(enrollReq);
					if (emailExists) {
						response = new MembershipEnrollResponse(genDuplicateEmailMsg, "1");	
						response.setErrors(null);
						infoList.add("Failed to Enroll the membership! -- " + genDuplicateEmailMsg);
						
						response.setInfoList(infoList);
						
						return response;
					}
					
					//Make sure ebilling has an email as in primary member 
					if (enrollReq.getEnrollInEbillingFlag()!=null && enrollReq.getEnrollInEbillingFlag().equalsIgnoreCase("YES")) {
						String ebillingEmail = enrollReq.getSimpleMembership().getPrimaryMember().getEmail();
						if (ebillingEmail == null || ebillingEmail.trim().equals("")) {
							response = new MembershipEnrollResponse(genNoEmailForEbillingCheckMsg, "1");	
							response.setErrors(null);
							infoList.add("Failed to Enroll the membership! -- " + genNoEmailForEbillingCheckMsg);
							
							response.setInfoList(infoList);
							
							return response;
						}
					}
					
					//make sure has a primary phone
					SimpleMembership sm = enrollReq.getSimpleMembership();
					boolean hasPhone = false;
					boolean hasPrimaryPhone = false;
					for(Phone p: sm.getPrimaryMember().getPhones()){
						hasPhone = true;
						if (p.getIsPrimary()) {
							hasPrimaryPhone = true;
						}
					}
					
					if (enrollReq.isDonorMembership() && enrollReq.getDonor()!=null) {
						String donorPhone = nvl(enrollReq.getDonor().getPhone());
						String donorEmail = nvl(enrollReq.getDonor().getEmail());
						
						if (donorPhone.trim().equals("") || donorEmail.trim().equals("")){
							response = new MembershipEnrollResponse(genNoDonorPhoneOrEmailMsg, "1");	
							response.setErrors(null);
							infoList.add("Failed to Enroll the membership! -- " + genNoDonorPhoneOrEmailMsg);
							
							response.setInfoList(infoList);
							
							return response;
						} else {
							//even primary member doesn't provide a phone number, a donor's phone number for donor membership is good enough. 
							hasPrimaryPhone =true;
						}
					}
					
					if (!hasPrimaryPhone) {
						response = new MembershipEnrollResponse(genNoPrimaryPhoneMsg, "1");	
						response.setErrors(null);
						infoList.add("Failed to Enroll the membership! -- " + genNoPrimaryPhoneMsg);
						response.setInfoList(infoList);
						
						return response;
					}
					
					//validate the donor number if it is a gift membership and there is a donor number. 
					if (enrollReq.isDonorMembership() && enrollReq.getDonor()!=null) {
						String donorNumber = nvl(enrollReq.getDonor().getDonorNumber());
						
						if (!donorNumber.trim().equals("")){
							if (!enrollBp.isDonorNrValid(donorNumber)) {
								response = new MembershipEnrollResponse(genNoMatchedDonorNumberMsg, "1");	
								response.setErrors(null);
								infoList.add("Failed to Enroll the membership! -- " + genNoMatchedDonorNumberMsg);
								
								response.setInfoList(infoList);
								
								return response;
							}
						}
						
						//if no donor number, add a donor; otherwise update the donor
						enrollBp.addUpdateDonor(enrollReq);
					}
					
				}
				catch (Exception e)
				{
					throw new WebServiceException(genErrorDuringValidationMsg);
				}
				
				//Check for duplicate memberships unless overridden
				if(!enrollReq.isDoNotCheckDuplicateMemberships())
				{
					dupMemberships = enrollBp.getDuplicateMemberships(enrollReq, enrollReq.getSimpleMembership());
					
					if(dupMemberships.length > 0)
					{
						boolean hasNoncancelled = false;
						for (int i1=0 ; i1<dupMemberships.length; i1++) {
							SimpleMembership smst = dupMemberships[i1];
							if (!smst.getStatusMZPValue().equals("C")) {
								hasNoncancelled = true;
								break;
							}
						}
						
						if (!hasNoncancelled) {
							for (int i=0 ; i<dupMemberships.length; i++) {
								SimpleMembership smst = dupMemberships[i];
								if (smst.getCanceled18Months()) {
									msd = membershipUtilBP.checkDuplicateMembership18Month(smst);
									mubp.debug(DEBUG_MODULE, "Old MembershipID: " + msd.getMembershipId(), true);
									break;
								}
							}
						}
						
						if (msd == null) {
							throw new WebServiceException(genDuplicateMembershipFoundMsg);	
						}
					}
				}
				
				try
				{
					Membership ms = null;
					if (isGiftFreeMembershipEnroll){
						ms = enrollBp.processEnrollFreeGift(enrollReq, true,paymentResponse);	
					} else {
						ms = enrollBp.processEnroll(enrollReq, true,paymentResponse);
					}
					
					
					if(ms.getMembershipId() !=null)
					{
						mubp.debug(DEBUG_MODULE, "New MembershipID: " + ms.getMembershipId(), true);
						
						if (isGiftFreeMembershipEnroll){
							mubp.debug(DEBUG_MODULE, "Free Gift Membership Enroll ", true);
						} 
						
						response = new MembershipEnrollResponse();
						
						if (msd !=null) {
							//To call cwp web service to handle the duplicate profile when reenroll a cancelled membership after 18 months
							String email = enrollReq.getSimpleMembership().getPrimaryMember().getEmail();
							
							String newMembershipId16 = "438212" + ms.getMembershipId() + ms.getPrimaryMember().getAssociateId() + ms.getPrimaryMember().getCheckDigitNr();
							String oldMembershipId16 = "438212" + msd.getMembershipId() + msd.getPrimaryMember().getAssociateId() + msd.getPrimaryMember().getCheckDigitNr();
							
							mubp.debug(DEBUG_MODULE, 
									"Old MembershipID: " + oldMembershipId16 + " - New MembershipID:" + newMembershipId16 + " - Email: " , true) ;
							
							updateCWPWithReenroll(response, newMembershipId16, oldMembershipId16, email, DEBUG_MODULE);
							
							mubp.debug(DEBUG_MODULE, 
									"Old MembershipID: " + oldMembershipId16 + 
									" - New MembershipID:" + newMembershipId16 + 
									" - Email: " + email +
									" - Response flag: " + response.isUpdateCWPResult() +
									" - Profile ID: " + response.getProfileId() +
									" - Profile Description: " + response.getProfileDescription(), true) ;
						}
						
						//Donor can be copied from request object to the response object. 
						com.aaa.soa.object.models.Donor donor = enrollReq.getDonor();
						response.setDonor(donor);
						
						String transactionId = null;
						for (InternetActivity ia: ms.getInternetActivityList()) {
							transactionId = ia.getTransactionId().toString();
							break;
						}
						
						if (transactionId != null) {
							response.setMembershipTransactionId(transactionId);
						}
						
						
						String renewMethod = enrollReq.getSimpleMembership().getRenewalMethod();
						
						//EBILLING ENROLLMENT - [YHu ] - START 	
						if (enrollReq.getEnrollInEbillingFlag()!=null && enrollReq.getEnrollInEbillingFlag().equalsIgnoreCase("YES")) {
							if (!renewMethod.equalsIgnoreCase("INSTALLMENT PLAN")) {
								EnrollMembershipInEBillingResponse ebillingResponse = EnrollMembershipInEBilling (ms, enrollReq);
								
								//no need to check the response of EBilling because all the validation was done through membership enrollment already. 
								//It won't get this far if there is error for enrollment. 
								
								//no ebilling confirmation email is sent. it is turned off.
							}
						}
						//EBILLING ENROLLMENT - [YHu ] - END
						
						//send confirmation email.
						sendEnrollConfirmationEmail (ms, enrollReq );
						
						SimpleMembership sm = membershipUtilBP.setStatusForReturn(enrollReq.getSimpleMembership(), ms);				
						
						response.setSimpleMembership(sm);
						response.setPaymentParams(enrollReq.getPaymentParams());
						response.setMembershipBalance(membershipUtilBP.formatAmount(ms.getBalance()));
						response.setErrors(null);
								
						String mbrshipNbr = enrollReq.getSimpleMembership().getPrimaryMember().getNumber().getNumber();
						infoList.add("Membership has been created successfully! The membership number is " +  mbrshipNbr);
						
						if (isGiftFreeMembershipEnroll) {
							//Ignore paymentResponse. 
							infoList.add("Free Gift Membership, no payment was charged. ");
						} else {
							if(paymentResponse.paymentAttempted && paymentResponse.isPaymentSuccess	 )
							{
								//TODO: need to consider the information message for ebilling situation
								infoList.add("Payment amount of " + paymentResponse.paymentAmount + " has been charged to " +  paymentResponse.paymentType  + " account ending in "  + paymentResponse.paymentAcctNum);
							}
							else if(paymentResponse.paymentAttempted && !paymentResponse.isPaymentSuccess	)
							{
								//TODO: need to consider the information message for ebilling situation
								infoList.add("Unable to charge " +  paymentResponse.paymentType  + " account ending in "  + paymentResponse.paymentAcctNum + 
										    ". A bill in the amount of " + paymentResponse.paymentAmount + " will be sent to the mailing address on record. ");
							}
							else
							{
								//TODO: need to consider the information message for ebilling situation
								infoList.add("A bill in the amount of " + paymentResponse.paymentAmount + " will be sent to the mailing address on record.");
							}
						}
						
						response.setInfoList(infoList);			
					}
				}
				catch (Exception e)
				{
					throw new WebServiceException(e.getMessage());
				}
			}
			
			mubp.debugExecutionTime(startTime, DEBUG_MODULE, true); 
		} 
		catch (WebServiceException e){	
			
			if (enrollReq.getPaymentParams() !=null)
			{
				if(enrollReq.getPaymentParams().getCard()!=null && enrollReq.getPaymentParams().getCard().getAccountNumber() !=null &&
					enrollReq.getPaymentParams().getCard().getAccountNumber().length() >=4)
					{
						String acctNbr = enrollReq.getPaymentParams().getCard().getAccountNumber();
						enrollReq.getPaymentParams().getCard().setAccountNumber(acctNbr.substring(acctNbr.length() - 4));
					}
			}
			response = new MembershipEnrollResponse(e.getMessage(), "1");	
			response.setSimpleMembership(enrollReq.getSimpleMembership());
			response.setPaymentParams(enrollReq.getPaymentParams());
			response.setDuplicateMemberships(dupMemberships);
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			
		} catch (Exception e) {
			getLogger().error("", e);			
			if (enrollReq.getPaymentParams() !=null)
			{
				if(enrollReq.getPaymentParams().getCard()!=null && enrollReq.getPaymentParams().getCard().getAccountNumber() !=null &&
					enrollReq.getPaymentParams().getCard().getAccountNumber().length() >=4)
					{
						String acctNbr = enrollReq.getPaymentParams().getCard().getAccountNumber();
						enrollReq.getPaymentParams().getCard().setAccountNumber(acctNbr.substring(acctNbr.length() - 4));
					}
			}
			response = new MembershipEnrollResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			response.setSimpleMembership(enrollReq.getSimpleMembership());
			response.setPaymentParams(enrollReq.getPaymentParams());
		}
		return response;
	}
	
	
	
	public DuplicateCardListResponse getDuplicateCardList(DuplicateCardListRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Dupliate card list request");
			getLogger().debug("Duplicate card list request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		DuplicateCardListResponse response = null;
		
		try {
			if(request !=null){	
				
				try {
					errList =  membershipUtilBP.performValidation(request, GET_DUPLICATE_CARD_LIST_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					CredentialHistoryBP bp = CredentialHistoryBP.getInstance();
					response = bp.processList(request);
				} catch (Exception e) {
					throw new WebServiceException(genValidationMsg);
				}
			}
		} catch (WebServiceException e){	
			response = new DuplicateCardListResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new DuplicateCardListResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the duplicated Card List! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public GetBillSummaryResponse GetBillSummarys(GetBillSummaryRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n BillSummary list request");
			getLogger().debug("BillSummary list request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		GetBillSummaryResponse response = null;
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		try {
			if(request !=null){	
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
				Collection<BillSummaryItem> bsList = new ArrayList<BillSummaryItem>();;
				
				Membership membership = null;
				Member pMember = null;
				MembershipNumber mn =  null;

				//validation


				//Get Sales Agent
				SalesAgent sa = new SalesAgent(user, request.getSalesAgentID());
				if(sa == null) {
					throw new Exception (genInvalidAgentId);
				}
				else
				{
					this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
				}

				//Get membership based on member id passed in
				try	{
					MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
					try
					{
						mn =  mbp.parseFullMembershipNumber(request.getMembershipID());
					}
					catch (Exception e)
					{
						throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
					}
					 
					if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
						throw new WebServiceException(genOutOfTerriroryMsg);
					}						
					membership = new Membership(user, mn.getMembershipID());
					pMember = membership.getPrimaryMember();
					
				}catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + request.getMembershipID());
				}
				
				response = new GetBillSummaryResponse();

				SimpleVO billingSumVo = new SimpleVO();
				SimpleEditor simpleEditor = new SimpleEditor(user);
				ArrayList columns = new ArrayList();
	            columns.add("BILL_SUMMARY_KY");
	            columns.add("MEMBERSHIP_KY");
	            columns.add("codes.get_desc('BLTYPE',BILL_TYPE) BILL_TYPE");
	            columns.add("BALANCE_AT");
	            columns.add("NOTICE_NR");
	            columns.add("TO_CHAR(PROCESS_DT, 'MM/DD/YYYY') PROCESS_DTA");
	            columns.add("EBILL_FL");
	            
	            ArrayList criteria = new ArrayList();
	            criteria.add(new SearchCondition("MEMBERSHIP_KY", SearchCondition.EQ, membership.getMembershipKy()));
	            // CWW For Salvage Bills only amount > 0 are shown, all other bills are shown regardless of amount
	    		SearchCondition endCriteria = new SearchCondition("BILL_TYPE", SearchCondition.EQ, "S");
	    		endCriteria.add("AND", "BALANCE_AT", SearchCondition.NOT_EQ,  BigDecimal.ZERO);
	    		endCriteria.add("OR", "BILL_TYPE", SearchCondition.NOT_EQ, "S");
	    		endCriteria.add("OR", "BILL_TYPE", SearchCondition.ISNULL);
	    		criteria.add(endCriteria);
	    		
	    		ArrayList<String> orderBy = new ArrayList<String>();
				orderBy.add(BillSummary.PROCESS_DT +  " DESC");

	    		billingSumVo = simpleEditor.findByCriteria("MZ_BILL_SUMMARY", criteria, orderBy, columns);
				if (billingSumVo !=null ) {
					billingSumVo.beforeFirst();
					
					while(billingSumVo.next()) {

						BillSummaryItem bsi = new BillSummaryItem();
						
						bsi.setBillAt(billingSumVo.getString("BALANCE_AT"));
						bsi.setBillType(billingSumVo.getString("BILL_TYPE"));
						bsi.setEbillFlag(billingSumVo.getString("EBILL_FL"));
						bsi.setNoticeNumber(billingSumVo.getString("NOTICE_NR"));
						bsi.setProcessDate(billingSumVo.getString("PROCESS_DTA"));
						
						bsList.add(bsi);
					}	
				}
				
				response.setBillSummarys(bsList);
			}
		} catch (WebServiceException e){	
			response = new GetBillSummaryResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetBillSummaryResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the Bill Summary List! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public BrandCardListResponse getBrandCardList(BrandCardListRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Brand card list request");
			getLogger().debug("Brand card list request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		BrandCardListResponse response = null;
		
		String divisionKy = "";
		
		try {
			if(request !=null){	
				//errList =  membershipUtilBP.performValidation(request, GET_DUPLICATE_CARD_LIST_VALIDATION_XML);
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
				Collection<BrandCardItem> cardList = new ArrayList<BrandCardItem>();;
				//Collection<Credential> cList = new ArrayList<Credential>();;
				
				CredentialBP cbp = new CredentialBP(user);
				
				if (request.getZipCode() ==null || request.getZipCode().length()<5) {
					throw new WebServiceException(genBrandCardListInvalidZipCodeMsg);
				}
				
				//cList = cbp.getCredentialInfo(request.getZipCode().substring(0, 5));
				response = new BrandCardListResponse();
				
				SimpleVO credentialList = new SimpleVO();
				credentialList = cbp.getCredentialInfo_VO(request.getZipCode().substring(0, 5));
				if (credentialList !=null ) {
					credentialList.beforeFirst();
					
					while(credentialList.next()) {

						BrandCardItem bci = new BrandCardItem();
						
						bci.setCredentialKy(credentialList.getBigDecimal("CREDENTIAL_KY").toString());
						bci.setCredentialCd(credentialList.getString("CREDENTIAL_CD"));
						bci.setDeleteFlag(credentialList.getString("DELETED_FL"));
						bci.setDescription(credentialList.getString("DESCRIPTION"));
						bci.setDivisionKy(credentialList.getBigDecimal("DIVISION_KY").toString());
						bci.setDivisionCd(credentialList.getString("DIVISION_CD"));
						bci.setRegionCd(credentialList.getString("REGION_CD"));
						bci.setVendorCredentialCd(credentialList.getString("VENDOR_CREDENTIAL_CD"));
						
						cardList.add(bci);
						
						divisionKy = credentialList.getBigDecimal("DIVISION_KY").toString();
					}	
				}
				
				if (cardList == null || cardList.size() == 0) {
					SimpleVO branchVO  = null;

					SimpleEditor simpleEditor = new SimpleEditor(user);;
					ArrayList condList = new ArrayList(1);
					condList.add(new SearchCondition("ZIP", SearchCondition.EQ, request.getZipCode()));
					branchVO = simpleEditor.findByCriteria("MZ_BRANCH", condList); 
					if (branchVO ==null) {
						divisionKy = "";
					} else {
						try {
							branchVO.beforeFirst();
							if (branchVO.next()) {
								divisionKy = branchVO.getString("DIVISION_KY");
							}
						} catch (Exception e){
						}
					}
				} 
				response.setDivisionKy(divisionKy);
				response.setBrandCards(cardList);
			}
		} catch (WebServiceException e){	
			response = new BrandCardListResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new BrandCardListResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the Brand Card List! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}

	public GetRegionInfoResponse GetRegionInfoByZip(GetRegionInfoRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Region Info request");
			getLogger().debug("Region Info Request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		GetRegionInfoResponse response = null;
		
		try {
			if(request !=null){	
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
				
				if (request.getZipCode() ==null || request.getZipCode().length()<5) {
					throw new WebServiceException(genBrandCardListInvalidZipCodeMsg);
				}
				
				response = new GetRegionInfoResponse();
				
				SimpleVO regionInfo_VO = new SimpleVO();
				regionInfo_VO = getRegionInfo_VO(request.getZipCode().substring(0, 5));
				if (regionInfo_VO !=null ) {
					regionInfo_VO.beforeFirst();
					
					while(regionInfo_VO.next()) {

						response.setDivisionCd(regionInfo_VO.getString("DIVISION_CD"));
						response.setDivisionKy(regionInfo_VO.getBigDecimal("DIVISION_KY").toString());
						response.setClubRegionCd(regionInfo_VO.getString("SUB_COMPANY_CD"));
						response.setRegionCd(regionInfo_VO.getString("REGION_CD"));
						response.setBranchCd(regionInfo_VO.getString("BRANCH_CD"));
						response.setBranchKy(regionInfo_VO.getBigDecimal("BRANCH_KY").toString());
						
						break;
					}	
				}
			}
		} catch (WebServiceException e){	
			response = new GetRegionInfoResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetRegionInfoResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the region Info! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	public GetDonorDetailResponse GetDonorDetail(GetDonorDetailRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get Donor Detail request");
			getLogger().debug("Get Donor Detail Request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		SimpleMembership[] mss = null;
		GetDonorDetailResponse response = null;
		
		try {
			if(request !=null){	
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
				
				if (request.getDonor() ==null || request.getDonor().getDonorNumber()== null ) {
					throw new WebServiceException("Invalid donor information");
				}
				
				String donorNumber = request.getDonor().getDonorNumber();
				Donor donor = new Donor(user, donorNumber);
				
				com.aaa.soa.object.models.Donor d = new com.aaa.soa.object.models.Donor();
				d.setDonorNumber(donorNumber);
				d.setLastName(donor.getLastName());
				d.setFirstName(donor.getFirstName());
				d.setAddress1(donor.getAddressLine1());
				d.setAddress2(donor.getAddressLine2());
				d.setCity(donor.getCity());
				d.setState(donor.getState());
				d.setZip(donor.getZip());
				d.setDonorTypeCd(donor.getDonorTypeCd());
				d.setPhone(donor.getPhone());
				d.setAllowAutoRenewalFlag(donor.getAllowAutorenewalFl().toString());
				d.setSendBillTo(donor.getSendBillTo());
				d.setSendCardTo(donor.getSendCardTo());
				d.setBillFlag(donor.getBillFl().toString());
				
				ArrayList<BigDecimal> membershipKeys = new ArrayList <BigDecimal>();
				for (Membership ms: donor.getMembershipList()) {
					if (!ms.isCancelled()){
						membershipKeys.add(ms.getMembershipKy());
					}
				}
				
				if(membershipKeys != null && membershipKeys.size() > 0)
				{
					BigDecimal[] memKeys = membershipKeys.toArray(new BigDecimal[membershipKeys.size()]);
					mss = new SimpleMembership[membershipKeys.size()];
					
					for (int i = 0; i < mss.length; i++)
					{
						Membership donorMembership = new Membership(user, memKeys[i], true);
						MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
						mss[i] = maintBp.getMembershipOverview(donorMembership);
						mss[i].setMembershipBalance(membershipUtilBP.formatAmount(
									donorMembership.getMembershipBalance(user, donorMembership.getMembershipKy())));
					}
				}
				else
				{
					mss = new SimpleMembership[0];
				}
				
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				PaymentParameters paymentParams = maintBp.getDonorAutoRenewalCard(donor);
				
				
				response = new GetDonorDetailResponse("SUCCESS","0");;
				response.setDonor(d);
				response.setDonorMemberships(mss);
				response.setPaymentParams(paymentParams);
				
			}
		} catch (WebServiceException e){	
			response = new GetDonorDetailResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetDonorDetailResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the region Info! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	
	public AddDuplicateCardResponse requestDuplicateCard(AddDuplicateCardRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n request dupliate card");
			getLogger().debug("request duplicate card Request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		AddDuplicateCardResponse response = null;
		
		try {
			if(request !=null){	
				
				try {
					errList =  membershipUtilBP.performValidation(request, REQUEST_DUPLICATE_CARD_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					
					CredentialHistoryBP bp = CredentialHistoryBP.getInstance();
					response = bp.processRequest(request);
					
				} catch (Exception e) {
					throw new WebServiceException(genValidationMsg);
				}
				
			}
		} catch (WebServiceException e){	
			response = new AddDuplicateCardResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new AddDuplicateCardResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to request the duplicated Card! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		
		return response;
	}	
	//wwei GetEmailPaymentConfirmation
	public GetEmailPaymentConfirmationResponse GetEmailPaymentConfirmation(GetEmailPaymentConfirmationRequest request)
	{
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get Payment Details request");
			getLogger().debug("Get Payment Details request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		GetEmailPaymentConfirmationResponse response = null;
		
		try {
			if(request !=null){	
				
				try {
					Validator v = new Validator();
					WebLetterBP webLetterBP = (WebLetterBP) BPF.get(user, WebLetterBP.class);
					String email = request.getEmail();
					String EMAIL_REGEX = "^[\\w-_\\.+]*[\\w-_\\.]\\@([\\w]+\\.)+[\\w]+[\\w]$";				      
				    if  (! email.matches(EMAIL_REGEX))
				    {
				    	return response = new GetEmailPaymentConfirmationResponse("Invalid email: " + email, "1");	
				    }
					String membershipPaymentKy = request.getPaymentKy();
					v = webLetterBP.sendPaymentConfirmationLetter(email, membershipPaymentKy, v);
					response = new GetEmailPaymentConfirmationResponse();
					response.setMsgReturn(v.getMessage());
					
					
					//CredentialHistoryBP bp = CredentialHistoryBP.getInstance();
					//response = bp.processList(request);
				} catch (Exception e) {
					throw new WebServiceException(genValidationMsg);
				}
			}
		} catch (WebServiceException e){	
			response = new GetEmailPaymentConfirmationResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetEmailPaymentConfirmationResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve payment confirmation email! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	//wwei GetSolicitationCDARDiscount
	public GetSolicitationCDARDiscountResponse GetSolicitationCDARDiscount(GetSolicitationCDARDiscountRequest request)
	{
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n GetSolicitationCDARDiscount Request");
			getLogger().debug("GetSolicitationCDARDiscount request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		
		GetSolicitationCDARDiscountResponse response = null;
		
		try {
			if(request !=null){	
				
				try {
					String solicitationCd = request.getSolicitationCD();
					if (solicitationCd == null || solicitationCd.trim().equals("")) {
						return response = new GetSolicitationCDARDiscountResponse("Solicitation Code is empty." , "1");	
						
					}
					Solicitation s = null;
					try
					{
						s = Solicitation.getSolicitation(user, solicitationCd);
					}
					catch(Exception ex)
					{
						return response = new GetSolicitationCDARDiscountResponse("Invalid Solicitation Code: "+ solicitationCd, "1");
					}
					//wwei webmember ARxx issue fix	
					SearchCondition sc = new SearchCondition(SolicitationDiscount.DISCOUNT_CD, SearchCondition.LIKE, "AR%");
					
					ArrayList<SearchCondition> conds = new ArrayList<SearchCondition>();
					conds.add(sc);		
					SortedSet<SolicitationDiscount> sds= s.getSolicitationDiscountList(conds, null);
					
					ArrayList discountCds = new ArrayList();
			       
					for (SolicitationDiscount sd: sds) {
						discountCds.add(sd.getDiscountCd());
					}
					
					if (discountCds == null || discountCds.size() == 0 ) {
						return response = new GetSolicitationCDARDiscountResponse("No AR discount attach to Solicitation Code "+ solicitationCd , "1");
						
					}
					
					ArrayList<SearchCondition> condsDiscountCd = new ArrayList<SearchCondition>();
					condsDiscountCd.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.IN, discountCds));
							
					Collection<Discount> discounts = Discount.getDiscountList(user, condsDiscountCd, null, null, null);
					BigDecimal totalARDisc = BigDecimal.ZERO;
					response = new GetSolicitationCDARDiscountResponse();
					//wwei per conversation with Pat , we assume there is only ONE AR discount for now
					for( Discount d : discounts)
					{
						response.setDiscountAmt( (d.getAmount().setScale(2, BigDecimal.ROUND_DOWN)).toString());
						response.setDiscountName(d.getDiscountCd());
						response.setSolicitationCD(request.getSolicitationCD());
						return response;
					}

					
					
//					response.setDiscountAmt(totalARDisc.toString());
//					response.setDiscountName("AR10");
//					response.setSolicitationCD("JOINAR10");
					
					
					//CredentialHistoryBP bp = CredentialHistoryBP.getInstance();
					//response = bp.processList(request);
				} catch (Exception e) {
					throw new WebServiceException(genValidationMsg);
				}
			}
		} catch (WebServiceException e){	
			response = new GetSolicitationCDARDiscountResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetSolicitationCDARDiscountResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve payment confirmation email! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	
	//wwei getpaymentdetails
	public GetPaymentDetailsResponse GetPaymentDetails(GetPaymentDetailsRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Get Payment Details request");
			getLogger().debug("Get Payment Details request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		
		GetPaymentDetailsResponse response = null;
		
		try {
			if(request !=null){	
				
				try {
//					errList =  membershipUtilBP.performValidation(request, GET_DUPLICATE_CARD_LIST_VALIDATION_XML);
					
//					if (errList !=null && !errList.isEmpty())
//					{
//						throw new WebServiceException(genValidationMsg);
//					}
					String paymentKy = request.getPaymentKy();
					String membershipId = request.getMembershipNumber();
					
					
						
					if ( membershipId.length() != 16)
					{						
						return response = new GetPaymentDetailsResponse("Invalid membership ID: " + membershipId, "1");	
					}
					else
					{
						String mbrID = membershipId.substring(6,13);
						try
						{
							new Membership( user, mbrID   );
						}
						catch (Exception ex)
						{
							return response = new GetPaymentDetailsResponse("Invalid mem1bership ID: " + membershipId, "1");
						}					
						
					}
						
					
					
					response = new GetPaymentDetailsResponse("Success", "0");
					Connection conn = ConnectionPool.getConnection(user);
					//response = response.setPaymentInfo(paymentKy, conn, user,  response);
					String paymentID = StringUtils.blanknull(paymentKy);
					if( paymentID.equals(""))
					{
						throw new WebServiceException("No Membership Payment Key!");
					}
					
					com.aaa.soa.object.models.PaymentSummaryInfo ps1 = new com.aaa.soa.object.models.PaymentSummaryInfo();
					response.setPaymentSummaryInfo(ps1);
					response.getPaymentSummaryInfo().setPaymentID(paymentID);
					SimpleVO paymentSummary;
					try {
						paymentSummary = new SimpleVO();						
					    paymentSummary.setCommand("select mz_payment_summary.*, last_day(CC_EXPIRATION_DT) as CC_EXPIRATION_ENDOFMONTH_DT from mz_payment_summary where membership_payment_ky = ? or parent_payment_ky = ? order by membership_payment_ky");
					    paymentSummary.setString(1, paymentID);
					    paymentSummary.setString(2, paymentID);
					    paymentSummary.execute(conn);
					    paymentSummary.first();
					    //conn.close();
					    
					    //get batch name
					    response.getPaymentSummaryInfo().setBatchName(paymentSummary.getSafeString("BATCH_NAME"));
					    response.getPaymentSummaryInfo().setPaymentAmt( paymentSummary.getBigDecimal("PAYMENT_AT").toString());;
					    response.getPaymentSummaryInfo().setTransType( StringUtils.safeString(DropDownUtil.getCodeValue("PAYTYP",paymentSummary.getSafeString("TRANSACTION_TYPE_CD"))));
					    response.getPaymentSummaryInfo().setPaymentMethod( StringUtils.safeString(DropDownUtil.getCodeValue("PAYMTH",paymentSummary.getSafeString("PAYMENT_METHOD_CD"))));
					    response.getPaymentSummaryInfo().setPaidBy( ((paymentSummary.getSafeString("PAID_BY_CD").equals("D"))?"Donor":"Primary"));
					    response.getPaymentSummaryInfo().setDonor(paymentSummary.getSafeString("DONOR_NR"));
					    response.getPaymentSummaryInfo().setAdjustmentCd(DropDownUtil.getCodeValue("PAYADJ",paymentSummary.getSafeString("ADJUSTMENT_DESCRIPTION_CD")));
					    response.getPaymentSummaryInfo().setCreateDt( paymentSummary.getSafeString("CREATE_DT","MM/dd/yyyy hh:mm a"));
					    response.getPaymentSummaryInfo().setPaidDt( paymentSummary.getSafeString("PAYMENT_DT","MM/dd/yyyy hh:mm a"));
					    
					    PaymentSummary ps = new PaymentSummary(user,paymentSummary);
				      	String rsn = ps.getReasonText();
				        response.getPaymentSummaryInfo().setReason(StringUtils.safeString(rsn));
				        BigDecimal batchKy = paymentSummary.getBigDecimal("BATCH_KY");
				        BatchHeader batchHeader = null;
				        if (batchKy != null) {
				          try 
				          {
				             batchHeader = new BatchHeader(user,batchKy,true);
				          }
				          catch (Exception e) 
				          {
				          }
				        }
				        CreditCardProcessorBP bp = (CreditCardProcessorBP) BPF.get(user, CreditCardProcessorBP.class);
				        if( paymentSummary.getStringNvl("PAYMENT_METHOD_CD","1").equals(PaymentMethod.PAYMTH_CREDIT_CARD))
				        {
				        	response.getPaymentSummaryInfo().setPostDt( ((batchHeader==null || batchHeader.getPostCompleteDt() == null)?"Unknown":DateUtilities.getFormattedDate(batchHeader.getPostCompleteDt(),"MM/dd/yyyy hh:mm a")));
				        	response.getPaymentSummaryInfo().setCcType( StringUtils.safeString(DropDownUtil.getCodeValue("CRTCRD",paymentSummary.getSafeString("CC_TYPE_CD"))));
				        	
				        	String ccNumber = "";
			                try {
				                if(bp.usesToken())
				                {
				                	String ccToken = paymentSummary.getSafeString("CC_TOKEN");
				                	if (ccToken !=null && ccToken.length() >= 15) {
				                		ccNumber = StringUtils.CreditCardEncrypt(ccToken);
				                		response.getPaymentSummaryInfo().setCcNumber(ccNumber);
				                	}
				                	else
				                	{
				                		CreditCard cc = bp.getCreditCard(ccToken, true);
				                		ccNumber = cc.getNumber();
				                		response.getPaymentSummaryInfo().setCcNumber(ccNumber);
				                	}
				                }
				                else
				                {
				                	ccNumber = ConxonsSecurity.instance().decrypt(paymentSummary.getSafeString("CC_NUMBER"));
				                	response.getPaymentSummaryInfo().setCcNumber(ccNumber);
				                }
				
				                if 
				                (!user.inGroup("CCU")) ccNumber = StringUtils.CreditCardEncrypt(ccNumber);
			                }
			                catch (Exception e) 
			                {
			                	response.getPaymentSummaryInfo().setCcNumber("xxxxxxxxxxxxxxxx");
			                	//return  "Error getting credit card data!";
			                }
			                response.getPaymentSummaryInfo().setCcExpDt( paymentSummary.getSafeString("CC_EXPIRATION_ENDOFMONTH_DT"));
						    response.getPaymentSummaryInfo().setCcAuthNbr( paymentSummary.getSafeString("CC_AUTHORIZATION_NR"));
						    response.getPaymentSummaryInfo().setTransDt(((batchHeader==null || batchHeader.getTransactionDt() == null)?"Unknown":DateUtilities.getFormattedDate(batchHeader.getTransactionDt(),"MM/dd/yyyy hh:mm a")));	        
						    
				        }
				      //ACH check
				        else if (paymentSummary.getStringNvl("PAYMENT_METHOD_CD","1").equals(PaymentMethod.PAYMTH_ACH_CHECK)) 
				        {				        	
				        	response.getPaymentSummaryInfo().setPostDt( ((batchHeader==null || batchHeader.getPostCompleteDt() == null)?"Unknown":DateUtilities.getFormattedDate(batchHeader.getPostCompleteDt(),"MM/dd/yyyy hh:mm a")));
				        	response.getPaymentSummaryInfo().setAchBank(paymentSummary.getSafeString("ACH_BANK_NAME"));
				        	String achRoutingNr = "";
							String achAcct = "";
							if (bp.usesToken()){
								String achToken = paymentSummary.getSafeString("ACH_TOKEN");
								if (!((achToken==null) || achToken.equalsIgnoreCase(""))){
									ECheck echeck = bp.getECheck(achToken);
									achAcct = echeck.getBankAccountNr();
									response.getPaymentSummaryInfo().setAchAccount(achAcct);
									achRoutingNr = echeck.getRoutingNr();
									response.getPaymentSummaryInfo().setAchRouting(achRoutingNr);
								}
							}
							else {
								achAcct = ConxonsSecurity.instance().decrypt(paymentSummary.getSafeString("ACH_BANK_ACCOUNT_NUMBER"));
								response.getPaymentSummaryInfo().setAchAccount(achAcct);
								achRoutingNr = paymentSummary.getSafeString("ACH_BANK_ROUTING_NUMBER");
								response.getPaymentSummaryInfo().setAchRouting(achRoutingNr);
							}
							if (!user.inGroup("CCU")){
								achAcct = StringUtils.CreditCardEncrypt(achAcct);
								response.getPaymentSummaryInfo().setAchAccount(achAcct);
							}
							response.getPaymentSummaryInfo().setAchAcctType(StringUtils.safeString(DropDownUtil.getCodeValue("BKATYP",paymentSummary.getSafeString("ACH_BANK_ACCOUNT_TYPE"))));
				        }
				        else
				        {
				        	//this is check, don't know if we need handle or not
				        }
					    
					    //setPaymentDetailInfo(paymentKy,conn);
						//return "";
					    try {
							SimpleVO paymentDetailsVO;
							paymentDetailsVO = new SimpleVO();
							paymentDetailsVO.setCommand("select * from mz_payment_detail_v where membership_payment_ky = ?");
					        paymentDetailsVO.setString(1,paymentKy);
					        paymentDetailsVO.execute(conn);
					        Collection<PaymentDetail> paymentDetailList = new ArrayList<PaymentDetail>();
					        if( paymentDetailsVO.first() )
					        {
					        	PaymentDetail payDetail = null;
					        	paymentDetailsVO.beforeFirst();
					        	while( paymentDetailsVO.next())
					        	{
					        		payDetail = new PaymentDetail();
					        		payDetail.setAssociateID(paymentDetailsVO.getSafeString("Associate_ID"));
					        		payDetail.setMemberName(paymentDetailsVO.getSafeString("Member_name"));
					        		payDetail.setComponent(paymentDetailsVO.getSafeString("component"));
					        		payDetail.setDescription(paymentDetailsVO.getSafeString("description"));
					        		payDetail.setAmount(paymentDetailsVO.getBigDecimal("membership_payment_at"));
					        		payDetail.setUnAppliedAmt(paymentDetailsVO.getBigDecimal("unapplied_used_at"));
					        		payDetail.setCounted(paymentDetailsVO.getSafeString("made_active_flag"));
					        		
					        		
					        		paymentDetailList.add(payDetail);
					        		payDetail = null;	        		
					        	}
					        	response.getPaymentSummaryInfo().setPaymentDetails(paymentDetailList) ;
					        }	        
					        else
					        {
					        	//no detail records?
					        }
					        
						} catch (Exception e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					 
					} 
					catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					finally
					{
						try {
							conn.close();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					}					
					
				} catch (Exception e) {
					throw new WebServiceException(genValidationMsg);
				}
			}
		} catch (WebServiceException e){	
			response = new GetPaymentDetailsResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e){
			getLogger().error("", e);			
			
			response = new GetPaymentDetailsResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to retrieve the payment details! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
		
	}
	
	
	
	public MembershipUpdateMemberResponse UpdateMember(MembershipUpdateMemberRequest request){
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Update member");
			getLogger().debug("Update Member Request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		MembershipUpdateMemberResponse response =  null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		
		VUpdateMember vum = null;
		
		try {
			if(request !=null){				
				try
				{
					vum = new VUpdateMember(request);
					
					//validation of the xml
					errList =  membershipUtilBP.performValidation(vum, UPDATE_MEMBER_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					
					
					String salesAgentId = vum.getSalesAgentID();
					SalesAgent sa = this.getSalesAgent(salesAgentId); 
					if(sa == null) {
						throw new Exception ("Failed to get the agent id for the transaction");
					}
					else
					{
						this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
						
//						salesAgentId = sa.getAgentId();
						String salesAgentBranchCd = sa.getBranchKy().toString();
						String sourceOfSaleCd= sa.getSourceOfSaleCd();
						
						String zipCode = vum.getZip();
						Territory newTerritory = Territory.getTerritoryByZip(user, zipCode);
						
					}
				} catch( WebServiceException we){
					throw new WebServiceException(genValidationMsg);
				} catch (ObjectNotFoundException one) {
					response = new MembershipUpdateMemberResponse("Info", "2");	
					response.setErrors(null);
					infoList.add("Failed to update the membership! -- The new zip code is out of territory");
					response.setInfoList(infoList);					
					
					return response;
				} catch (Exception e) {
					throw new Exception (e.getMessage());
				}
				
				try
				{
					String membershipID = vum.getMembershipID();
					String associateID =  vum.getAssociateID();
					
					String address1 = vum.getAddress1();
					String address2 = vum.getAddress2();
					String city = vum.getCity();
					String state = vum.getState();
					String zip = vum.getZip();
					
//					String phone = vum.getPhone();
					
					String dob = vum.getDob();
					String email =vum.getEmail(); 
					String lastName = vum.getLastName();
					String firstName = vum.getFirstName();
					
					String joinAAADate = "";
					String middleName = "";
					String salutation = "";
					String suffix = "";
					if (request.getSimpleMembership().getAssociates()!=null) {
						SimpleAssociateMember[] sams= (request.getSimpleMembership().getAssociates());
						SimpleAssociateMember sam = sams[0];
						middleName = sam.getName().getMiddleName();
						salutation = sam.getName().getTitle();
						suffix = sam.getName().getSuffix();
						joinAAADate = sam.getJoinAAADate();
						
					} else {
						SimplePrimaryMember pm = request.getSimpleMembership().getPrimaryMember();
						middleName = pm.getName().getMiddleName();
						salutation = pm.getName().getTitle();
						joinAAADate = pm.getJoinAAADate();
						suffix = pm.getName().getSuffix();
					}
					
					Membership ms = new Membership(User.getGenericUser(), membershipID);
					ms.setAddressLine1(address1);
					ms.setAddressLine2(address2);
					ms.setCity(city);
					ms.setState(state);
					ms.setZip(zip);
					//PC : 10/6/16: Resetting the address validation code for Address cleansing to pick up.					
					ms.setAddressValidationCode(null);
					for(Member m : ms.getMemberList()){
						if (m.getAssociateId().equals(associateID)) {
							if (joinAAADate!=null && joinAAADate.length()>=10) {
								joinAAADate = joinAAADate.substring(5,7) + "/" + joinAAADate.substring(8,10 ) + "/" + joinAAADate.substring(0,4);
							}
							
							m.setLastName(lastName);
							m.setFirstName(firstName);
							m.setMiddleName(middleName);
							m.setJoinAaaDt(joinAAADate);
							m.setBirthDt(dob);
							
							//if (hasValueChanged(m.getEmail(), email)) {
								boolean emailExists = memberEmailCheckBP.isEmailDuplicated(email, membershipID, associateID);
								if (emailExists) {
									response = new MembershipUpdateMemberResponse(genDuplicateEmailMsg, "1");	
									response.setErrors(null);
									infoList.add("Failed to update the member! -- " + genDuplicateEmailMsg);
									
									response.setInfoList(infoList);
									
									return response;
								}
								
								m.setEmail(email);
							//}
							
							//translation of the suffix and salutation
							m.setNameSuffix(membershipUtilBP.getSuffixByWsType(suffix));
							m.setSalutation(membershipUtilBP.getSalutationByWsType(salutation));
						}
					}
					
					SimplePrimaryMember pm = request.getSimpleMembership().getPrimaryMember();
					Phone[] phones = pm.getPhones();
					
					//clean every other phones.
					SortedSet<OtherPhone> ops = ms.getOtherPhoneList();
					if (ops !=null && ops.size() > 0){
						for (OtherPhone op : ops){
							op.delete();
						}
					}
					//clean the membership phone 
					ms.setPhone("");
					ms.setOtherPhoneFl("N");
					
					if (phones != null && phones.length > 0){
						for (int ip=0; ip < phones.length; ip++) {
							String pN = "";
							String pT = "";
							String pD = "";
							String pE = "";
							
							Phone p = phones[ip];
							if (p.getPhoneNumber()==null || p.getPhoneNumber().equalsIgnoreCase("")){
								break;
							}
							
							if (p.getPhoneNumber()!=null) pN = p.getPhoneNumber();
							if (p.getPhoneTypeCode()!=null) pT = p.getPhoneTypeCode();
							if (p.getDescription()!=null) pD = p.getDescription();
							if (p.getExtension()!=null) pE = p.getExtension();
							
							if (pT.equalsIgnoreCase("Primary")) {
								ms.setPhone(pN);
							} else {
								ms.setOtherPhoneFl("Y");
								
								OtherPhone op = new OtherPhone(User.getGenericUser(), (BigDecimal) null, false);
								op.setParentMembership(ms);
								op.setPhone(pN);
								
								op.setPhoneType(membershipUtilBP.getPhoneTypeByWsType(pT));
//								if (pT.equalsIgnoreCase("Cell")) {op.setPhoneType("C");}
//								else if (pT.equalsIgnoreCase("Business")) {op.setPhoneType("BS");}
//								else if (pT.equalsIgnoreCase("Work")) {op.setPhoneType("WK");}
//								else if (pT.equalsIgnoreCase("Other")) {op.setPhoneType("OT");}
								op.setUnlistedFl(false);
								op.setExtension(pE);
								op.setDescription(pD);
							}
						}
					}
					
					ms.save();

					response = new MembershipUpdateMemberResponse();
					response.setMessage("Info");
					response.setErrors(null);
								
					infoList.add("Membership has been updated successfully!");
						
					response.setInfoList(infoList);								 
					
				}
				catch (Exception e)
				{
					throw new WebServiceException(e.getMessage());
				}
			}
		} 
		catch (WebServiceException e){	
			response = new MembershipUpdateMemberResponse("Error", "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
			
		} catch (Exception e) {
			getLogger().error("", e);			
			
			response = new MembershipUpdateMemberResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to update the membership! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		
		return response;
	}
	
	/**
	 * For SOA service Change coverage level*/
	public MembershipCoverageUpdateResponse ChangeCoverageLevel(MembershipCoverageUpdateRequest covReq) {
		MembershipCoverageUpdateResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		Membership membershipCheck = null;
		MembershipNumber mn =  null;
		try {

			if (covReq != null) {
				if (getLogger().isDebugEnabled()) {
					getLogger().debug("**************************\n ChangeCoverageLevel Dues");
					getLogger().debug("Cov Request: " + covReq.toString());					
					getLogger().debug("**************************\n");
				}
    			try {
					errList = membershipUtilBP.performValidation(covReq, CHANGE_COVERAGE_VALIDATION_XML);
					if (errList != null && !errList.isEmpty()) {
						throw new WebServiceException(genValidationMsg);
					}
					else
					{
						errList = new ArrayList<ValidationError>();
					}
				} catch (Exception e) {
					throw new WebServiceException(genErrorDuringValidationMsg);
				}
				
				//validate sales agent exists
				SalesAgent sa;
				try {
					sa = new SalesAgent(user, covReq.getAgentId());
					
					if(sa == null)
					{
						throw new WebServiceException(genSalesAgentNotFoundMsg);							
					}
				}				
				catch (Exception e)
				{
					errList.add(new ValidationError("", genSalesAgentNotFoundMsg, "Sales Agent", covReq.getAgentId()));
					throw new WebServiceException(e.getMessage());
				}
				
				//Get membership based on member id passed in
				try	{
					MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
					try
					{
						mn =  mbp.parseFullMembershipNumber(covReq.getMembershipNumber());
					}
					catch (Exception e)
					{
						errList.add(new ValidationError("", genMembershipIdInvalid + e.getMessage(), "Membership Number", covReq.getMembershipNumber()));
						throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
					}
					 
					if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
						errList.add(new ValidationError("", genOutOfTerriroryMsg, "Membership Number", covReq.getMembershipNumber()));
						throw new WebServiceException(genOutOfTerriroryMsg);
					}						
					membershipCheck = new Membership(user, mn.getMembershipID());
					
				}catch (Exception e)
				{
					errList.add(new ValidationError("", genMembershipIdInvalid + e.getMessage(), "Membership Number", covReq.getMembershipNumber()));
					throw new WebServiceException(genMembershipIdInvalid + covReq.getMembershipNumber());
				}
				
				//Temporarilly stopping upgrading coverage to installment plan membership
				String renewalMethodCd = membershipCheck.getPrimaryMember().getRenewMethodCd(); 
				if (renewalMethodCd!=null && renewalMethodCd.trim().equalsIgnoreCase("P")) 
				{
					throw new Exception("Not being able to upgrade coverage to existing installment plan membership");	
				}
				
				Membership membership = MembershipCoverageBP.getInstance().processChangeCoverage(covReq, true);
				if(membership !=null)
				{
					response = new MembershipCoverageUpdateResponse();
					response.setErrors(null);
					infoList.add("Membership coverage level has been updated." );
					response.setInfoList(infoList);
					response.setSimpleMembership(null);
					response.setPaymentParams(null);
					response.setMembershipBalance(membershipUtilBP.formatAmount(Membership.getMembershipBalance(user, membership.getMembershipKy())));
			        response.setMembershipPayments(membershipUtilBP.formatAmount(membership.getPaymentAt()));
				}
			
			}
		} catch (WebServiceException e) {
			getLogger().error("", e);
			response = new MembershipCoverageUpdateResponse(e.getMessage(), "1");	
			response.setSimpleMembership(null);
			response.setPaymentParams(null);
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
		} catch (Exception e) {
			getLogger().error("", e);			
			response = new MembershipCoverageUpdateResponse(e.getMessage(), "1");	
			response.setErrors(null);
			response.setSimpleMembership(null);
			response.setPaymentParams(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);
		}

		return response;
	}	
	
	@SuppressWarnings("unused")
	public AddCancelAssociateMemberResponse AddAssociateMember(AddCancelAssociateMemberRequest addRequest)
	{
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n AddAssociateMember");
			getLogger().debug("Add Member Request: " + addRequest.toString());		
			getLogger().debug("**************************\n");			
		}

		AddCancelAssociateMemberResponse response =  null;
		Collection<ValidationError> errList = new ArrayList<ValidationError>();
		Collection<String> infoList = new ArrayList<String>();
		String membershipId = "";
		
		try {

			if(addRequest != null)
			{
				try
				{
					errList = membershipUtilBP.performValidation(addRequest, ADD_ASSOCIATE_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}						
				} catch (Exception e)
				{
					throw new WebServiceException(genErrorDuringValidationMsg);
				}
				
				Collection<Member> newAssociates = new ArrayList<Member>();
				SimpleAssociateMember[] inAssociates = addRequest.getAssociates();
				Member member = null;
				String marketCode = addRequest.getMarketCode();

				try{				
					membershipId = inAssociates[0].getNumber().getNumber();
				} catch (NullPointerException ex){
					throw new WebServiceException(genMembershipIdReq);
				}
				
				//get user
				SalesAgent sa = this.getSalesAgent(addRequest.getAgentId());
				
				if(sa == null) {
					throw new WebServiceException(genInvalidAgentId);
				}
				
				User u = User.getUserByUserID(String.valueOf(sa.getUserId()));
				
				MembershipUtilBP mUbp = MembershipUtilBP.getInstance();
				MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);				
								
				//check
				if(inAssociates.length == 0)
				{
					throw new WebServiceException(genOneAssociateReq);						
				}
								
				if("".equals(StringUtils.blanknull(membershipId)))
				{					
					throw new WebServiceException(genMembershipIdReq);			
				}
				
				Membership membership = null;
				try
				{
					membership = new Membership(u, membershipId);
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + membershipId);	
				}
				if(membership==null)
				{
					throw new WebServiceException(genMembershipIdInvalid + membershipId);	
				}
				if(membership.isCancelled())
				{
					throw new WebServiceException("Membership is cancelled. Please reinstate the membership before adding associates " + membershipId);	
				}
				
				//Temporarilly stopping adding assoicate to installment plan membership
				String renewalMethodCd = membership.getPrimaryMember().getRenewMethodCd(); 
				if (renewalMethodCd!=null && renewalMethodCd.trim().equalsIgnoreCase("P")) 
				{
					throw new WebServiceException("Not being able to support adding associate to existing installment plan membership");	
				}
				
				ArrayList<String> customerIdList = new ArrayList<String>();	
				if(inAssociates !=null && inAssociates.length >0)
				{
					for (SimpleAssociateMember sam:inAssociates){
						if(sam.getCustomerId() !=null && !sam.getCustomerId().equals(""))
						{
							if(customerIdList.contains(sam.getCustomerId()))
							{
								throw new WebServiceException ("Please send unique customer id for each associates" );
							}
							customerIdList.add(sam.getCustomerId());
						}
					}
				}
				try
				{
					if(customerIdList.size() >0)
					      membershipUtilBP.checkIfDuplicateContact(customerIdList);
					
					for(SimpleAssociateMember sm : inAssociates)
					{
						//add members
						member = mUbp.getMemberFromSimpleMember(sm);	
						member.setAgentId(sa.getAgentId());
						member.setSourceOfSale(sa.getSourceOfSaleCd());

						member = bpMaint.addMember(membership, member, marketCode, u, sa.getAgentId(),true);

						SimpleMembershipNumber number = new SimpleMembershipNumber(member.getAssociateId(),
								member.getCheckDigitNr().toString(),
								member.getClubCode(),
								mUbp.getIsoCode(member.getClubCode()),
								member.getMembershipId() );

						sm.setNumber(number);
						sm.setStatus(mUbp.getStatusByMZPType(member.getStatus()));
						newAssociates.add(member);
						
						//Entitlement start and end date.
						member.setEntitlementStartDt(DateUtilities.today());	
						member.setEntitlementEndDt(membership.getPrimaryMember().getActiveExpirationDt());
						
						D3kAudit d3kAudit = new D3kAudit(user, null, false);
						d3kAudit.setAuditDt(DateUtilities.now());
						d3kAudit.setMembershipKy(member.getMembershipKy());
						d3kAudit.setMemberKy(member.getMemberKy());
						d3kAudit.setEntitlementStartDt(member.getEntitlementStartDt());
						d3kAudit.setEntitlementEndDt(member.getEntitlementEndDt());
						d3kAudit.setProcessName("ADDASSOCIATE_AUTOMATION");
						d3kAudit.setLastUpdDt(DateUtilities.now());
						d3kAudit.setUserId(user.userID);
						member.save(); 
						d3kAudit.save();
					}
					
					
				} catch (NumberFormatException e) {
					String msg = "Failed to add associate! -- Number Formatter Error"  ; 
					throw new WebServiceException (msg);
				} 
				catch (Exception e)
				{
					String msg = e.toString().replace("java.lang.Exception:", ""); 
					throw new WebServiceException (msg);
				}
				if(newAssociates.size() > 0)
				{
					String comment = null;
					if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(addRequest.getSource())))
					{
						comment = membership.getChangeDescription() + "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(addRequest.getSource());
					}
					else
					{
						comment = membership.getChangeDescription();
					}
					membership.addComment(comment);
					membership.save();
					
					response = new AddCancelAssociateMemberResponse();
					response.setAssociates(inAssociates);
					response.setMembershipBalance(membershipUtilBP.formatAmount(Membership.getMembershipBalance(user, membership.getMembershipKy())));
					response.setErrors(null);
							
					infoList.add("Success. Associate(s) added!");
					if ("P".equals(membership.getRenewMethodCd())) {
						infoList.add("Installment Pay membership: New members must be paid in full immediately.");
					}
					
					response.setInfoList(infoList);			
				}
												
			}
			
		} catch (WebServiceException e){	
			if(errList !=null && !errList.isEmpty())
			{
				response = new AddCancelAssociateMemberResponse(e.getMessage(), "1");	
				response.setErrors(errList);
			
				infoList.add(genAssociateValidationMsg);
				infoList.add(genReviewErrList);
				response.setInfoList(infoList);
			}
			else
			{
				response = new AddCancelAssociateMemberResponse(e.getMessage(), "1");	
				response.setErrors(null);
				infoList.add(e.getMessage());
				response.setInfoList(infoList);
			}

		} catch (Exception e) {
			getLogger().error("", e);
			
			response = new AddCancelAssociateMemberResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			
			infoList.add(e.getMessage());
			response.setInfoList(infoList);
		}

		return response;			
		
	}	
	
	@SuppressWarnings("unused")
	public AddCancelAssociateMemberResponse CancelAssociateMember(AddCancelAssociateMemberRequest cancelRequest)
	{
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n CancelAssociateMember");
			getLogger().debug("Cancel Request: " + cancelRequest.toString());		
			getLogger().debug("**************************\n");			
		}

		AddCancelAssociateMemberResponse response =  null;
		Collection<ValidationError> errList = new ArrayList<ValidationError>();
		Collection<String> infoList = new ArrayList<String>();
	
		try {

			if(cancelRequest != null)
			{
				try
				{
					errList = membershipUtilBP.performValidation(cancelRequest, CANCEL_ASSOCIATE_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}						
				} catch (Exception e)
				{
					throw new WebServiceException(genErrorDuringValidationMsg);
				}
				
				SimpleAssociateMember[] cancelAssociates = cancelRequest.getAssociates();
				String membershipId = cancelAssociates[0].getNumber().getFullNumber();
				
				//get user
				SalesAgent sa = this.getSalesAgent(cancelRequest.getAgentId());
				
				if(sa == null) {
					throw new WebServiceException(genInvalidAgentId);
				}
				User u = User.getUserByUserID(String.valueOf(sa.getUserId()));
				
				MembershipUtilBP mUbp = MembershipUtilBP.getInstance();
				MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);				
								
				//check
				if(cancelAssociates.length == 0)
				{
					throw new WebServiceException(genOneAssociateReq);						
				}								
				if("".equals(StringUtils.blanknull(membershipId)))
				{					
					throw new WebServiceException(genMembershipIdReq);			
				}
				Membership membership = null;
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipId);
				}
				catch (Exception e)
				{
					throw new  Exception(genMembershipIdInvalid + e.getMessage());
				}
				
				try
				{
					membership = new Membership(u, mn.getMembershipID());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + membershipId);	
				}

				if(membership==null)
				{
					throw new WebServiceException(genMembershipIdInvalid + membershipId);	
				}
				if(membership.isCancelled())
				{
					throw new WebServiceException("Membership is cancelled. Please reinstate the membership before cancelling associates " + membershipId);	
				}				
				try
				{
					//allow member of membership in renewal only to be canceled. -start 
					boolean isPendingMembershipInRenewal = false;
					Member pm = membership.getPrimaryMember();
					if (membership.isPending()){
						isPendingMembershipInRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
						isPendingMembershipInRenewal = isPendingMembershipInRenewal && 
														(pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
					}
					
					if (!isPendingMembershipInRenewal) {
						throw new WebServiceException("Unable to cancel the membership not in renewal" + membershipId);	
					}
					//allow member of membership in renewal only to be canceled. -end
					
					membership = bpMaint.processMemberCancel(cancelAssociates, membership.getMembershipKy(), u, membershipUtilBP.getMzPSourceCommentByWsSource(cancelRequest.getSource()));
					if(membership==null)
					{
						throw new WebServiceException("Unable to cancel the associate(s) " + membershipId);	
					}
				}
				catch (Exception e)
				{
					String msg = e.toString().replace("java.lang.Exception:", ""); 
					throw new WebServiceException (msg);
				}
				if(membership  !=null)
				{
					response = new AddCancelAssociateMemberResponse();
					for(Member member : membership.getMemberList())
					{
						if (member.isPrimary())
							continue;
						if(cancelAssociates !=null && cancelAssociates.length >0)
						{
							 
							for (SimpleAssociateMember sam:cancelAssociates){						
								try
								{
									mn =  mbp.parseFullMembershipNumber(sam.getNumber().getFullNumber());
								}
								catch (Exception e)
								{
									throw new  Exception(genMembershipIdInvalid + e.getMessage());
								}
								if(mn.getAssociateID().equals(member.getAssociateId()) && 
										mn.getMembershipID().equals(member.getMembershipId()))
								{
									 
									if(member.getCustomerId() != null)
									{
									  sam.setCustomerId(member.getCustomerId().toString() );
									}
									
									if (member.getBirthDt()!=null) {
										sam.setDateOfBirth(DateUtilities.getFormattedDate(member.getBirthDt(), "MM/dd/yyyy"));	
									}
									
									sam.setEmail(member.getEmail());
									sam.setGender(mUbp.getGenderByMZPType(member.getGender()));
									try
									{
										int gradYear;
										gradYear = Integer.parseInt(member.getGraduationYr());
										sam.setGraduationYear(gradYear);
									}
									catch (Exception ignore){}
									sam.setAssociateType(mUbp.getAssociateTypeByMZPType(member.getMemberTypeCd()));
									Name assocName = new Name();
									assocName.setFirstName(member.getFirstName());
									assocName.setLastName(member.getLastName());
									assocName.setMiddleName(member.getMiddleName());
									assocName.setSuffix(member.getNameSuffix());
									assocName.setTitle(member.getSalutation());
									sam.setName(assocName);
									sam.setRelation(mUbp.getRelationByMZPType(member.getAssociateRelationCd()));
									sam.setStatus(mUbp.getStatusByMZPType(member.getStatus()));
									
									SimpleMembershipNumber mbrshipNumber = new SimpleMembershipNumber();
									mbrshipNumber.setCheckDigit(""+member.getCheckDigitNr());
									mbrshipNumber.setClubCode(member.getClubCode());
									String isoCode = mUbp.getIsoCode(member.getClubCode());
									mbrshipNumber.setIsoCode(isoCode);
									mbrshipNumber.setNumber(member.getMembershipId());
									mbrshipNumber.setAssociateId(member.getAssociateId());
									mbrshipNumber.setFullNumber(sam.getNumber().getFullNumber());
									sam.setNumber(mbrshipNumber);
									 
								}
							}
						}

					}		
					
					response.setAssociates(cancelAssociates);
					response.setMembershipBalance(membershipUtilBP.formatAmount(Membership.getMembershipBalance(user, membership.getMembershipKy())));
					response.setErrors(null);
							
					infoList.add("Associate(s) canceled.");
					response.setInfoList(infoList);			
				}												
			}			
		} catch (WebServiceException e){	
			if(errList !=null && !errList.isEmpty())
			{
				response = new AddCancelAssociateMemberResponse(e.getMessage(), "1");	
				response.setErrors(errList);
			
				infoList.add(genAssociateValidationMsg);
				infoList.add(genReviewErrList);
				response.setInfoList(infoList);
			}
			else
			{
				response = new AddCancelAssociateMemberResponse(e.getMessage(), "1");	
				response.setErrors(null);
				
				infoList.add(e.getMessage());
				response.setInfoList(infoList);
			}

		} catch (Exception e) {
			getLogger().error("", e);
			
			response = new AddCancelAssociateMemberResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
		}

		return response;	
	}
	
	/**
	 * For SOA service Get membership balance*/
	@SuppressWarnings("static-access")
	public MembershipSimpleOperationResponse GetMembershipBalance(String membershipNumber ) throws Exception{
		
		MembershipSimpleOperationResponse response = null;
		
		String DEBUG_MODULE = "SOA_GetMembershipBalance_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		mubp.debug(DEBUG_MODULE, "Get Membership Balance For:  " + membershipNumber, false);
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n GetMembershipBalance");
				getLogger().debug(" Request: " + membershipNumber);		
				getLogger().debug("**************************\n");			
			}
			Membership membership = null;
			
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipNumber);
				}
				catch (Exception e)
				{
					mubp.debug(DEBUG_MODULE, "Get Membership Balance Exception, invalid membership ID:  " + membershipNumber, false);
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + membershipNumber);
			}
			response = new MembershipSimpleOperationResponse();
			response.setMembershipBalance(membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy())));
			
		} 
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new MembershipSimpleOperationResponse(e.getMessage(), "1");				 
		} 
		catch (Exception e) {
			getLogger().error("", e);
			
			response = new MembershipSimpleOperationResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
		}
		return response ;
	}
	 
	public MembershipSimpleOperationResponse UpdateMembershipBilling(String membershipNumber, String agentId, String source ) throws Exception{
		
		MembershipSimpleOperationResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		String salesAgentId= null;	
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n UpdateMembershipBilling");
				getLogger().debug(" Membership Number: " + membershipNumber + ", Agent Id: " + agentId);		
				getLogger().debug("**************************\n");			
			}
			if(agentId ==null || agentId.equals("")){
				salesAgentId = this.getSetting("defaultSalesAgent");
			}else{
				salesAgentId =   agentId;
			}
			SalesAgent sa = getSalesAgent(salesAgentId); 
			if(sa == null) {
					throw new WebServiceException (genInvalidAgentId);
			}else{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
				salesAgentId = sa.getAgentId();
			}			
			Membership membership = null;
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipNumber);
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + membershipNumber);
			}
			for(Member m: membership.getMemberList())
			{								
				m.setRenewMethodCd("B");		
			}
			
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(source)))
			{
				membership.addComment("Renewal method was changed to Bill Me.\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(source));
			}
			else
			{
				membership.addComment("Renewal method was changed to Bill Me"); 
			}
			
			membership.save();
			
			response = new MembershipSimpleOperationResponse();
			infoList.add("Success! Renewal method changed to Bill Me." );
			response.setInfoList(infoList);
		} 
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new MembershipSimpleOperationResponse(e.getMessage(), "1");	
		} 
		catch (Exception e) {
			getLogger().error("", e);			
			response = new MembershipSimpleOperationResponse(genWSExceptionMsg, "1");	
		}
		return response ;
	}
	
	/**
	 * For SOA service Get membership */
	@SuppressWarnings("static-access")
	public MembershipSimpleOperationResponse GetMembership(String membershipNumber ) throws Exception{
		
		MembershipSimpleOperationResponse response = null;
		
		String DEBUG_MODULE = "SOA_GetMembership_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n GetMembership");
				getLogger().debug(" Request: " + membershipNumber);		
				getLogger().debug("**************************\n");			
			}
			
			mubp.debug(DEBUG_MODULE, "Get Membership Overview For " + membershipNumber, false);
		
			Membership membership = null;
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					//additional validation for the membershipNumber. 
					if(StringUtils.makeNumeric(membershipNumber).length() != 16){
						throw new Exception("Invalid Membership Length: " + membershipNumber);
					} else {
						mn =  mbp.parseFullMembershipNumber(membershipNumber);	
					}
				}
				catch (Exception e)
				{
					mubp.debug(DEBUG_MODULE, "Invalid Membership Length: " + membershipNumber, true);
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + membershipNumber);
			}
			MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			SimpleMembership sm = maintBp.getMembershipOverview(membership);
			PaymentParameters paymentParams = maintBp.getAutoRenewalCard(membership);
			
			response = new MembershipSimpleOperationResponse();
			
			response.setSimpleMembership(sm);
			response.setMembershipBalance(membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy())));
			response.setMembershipPayments(membershipUtilBP.formatAmount(membership.getPaymentAt()));
			response.setPaymentParams(paymentParams);
			response.setPaymentSummary(maintBp.getPaymentSummary(membership.getMembershipKy().toString(), null));
			
		} 
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new MembershipSimpleOperationResponse(e.getMessage(), "1");				 
		} 
		catch (Exception e) {
			getLogger().error("", e);
			
			response = new MembershipSimpleOperationResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
		}
		return response ;
	}
	
	/**
	 * For SOA service Make Payment */
	@SuppressWarnings("static-access")
	public MembershipSimpleOperationResponse MakePayment(MembershipSimpleOperationRequest req ) throws Exception{
		
		MembershipSimpleOperationResponse response = null;
		Collection<ValidationError> errList = null;
		Collection<String> infoList = new ArrayList<String>();
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n GetMembership");
				getLogger().debug(" Request: " + req.toString());		
				getLogger().debug("**************************\n");			
			}
			try
			{
				//Validation of input values
				errList =  membershipUtilBP.performValidation(req, MAKE_PAYMENT_VALIDATION_XML);
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
			}
			catch (Exception e)
			{
				throw new WebServiceException(genErrorDuringValidationMsg);
			}		
			Membership membership = null;
			MembershipNumber mn =  null;
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMembershipNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMembershipNumber());
			}
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled. Please reinstate the membership before making a payment. " + mn.getMembershipID());	
			}
			String salesAgentId = getSetting("defaultSalesAgent");
			if(req.getAgentId() !=null && !req.getAgentId().equals(""))
			{
				salesAgentId = req.getAgentId();
			}			 
			SalesAgent sa = getSalesAgent(salesAgentId); 
			if(sa == null) {
					throw new WebServiceException (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
				salesAgentId = sa.getAgentId();				
			}
			BigDecimal  amountDue = membership.getMembershipBalance(user, membership.getMembershipKy() );
			
			if(req.getPaymentParams() !=null && ( req.getPaymentParams().getCard()!=null || req.getPaymentParams().getCheck() !=null))
			{
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				if (req.getPaymentParams().getCard()!=null && req.getPaymentParams().getCard().getSaveAsAutoRenewalCard()){				 
					AutorenewalCard card = maintBp.buildAutorenewalCard(membership, req.getPaymentParams());		
					if (card!=null)
					{
						if(amountDue.compareTo( new BigDecimal(0)) ==0)
						{
							membership.getPrimaryMember().setRenewMethodCd("A");							
						}
						card.save();
						
					}	
				}					
				if(amountDue.compareTo( new BigDecimal(0)) ==0 && !req.getPaymentParams().getCard().getSaveAsAutoRenewalCard())
					throw new WebServiceException ("No outstanding dues found. Membership is paid in full.");
				else if(amountDue.compareTo( new BigDecimal(0)) ==0 && req.getPaymentParams().getCard().getSaveAsAutoRenewalCard())
				{
					 infoList.add("No outstanding dues found. Membership is paid in full. Membership switched to Automatic Renewal");
						
				}
				else
				{
					BigDecimal amountTobeCharged = new BigDecimal(0);
					if(req.getPaymentParams().getAmount() !=null && !req.getPaymentParams().getAmount().equals(""))
					{
						amountTobeCharged = new BigDecimal(req.getPaymentParams().getAmount());
						if(amountTobeCharged.compareTo(amountDue)>=0 )
						{
							amountTobeCharged = amountDue;
						}
						
					}
					else
					{
						amountTobeCharged =membership.getMembershipBalance(user, membership.getMembershipKy() );
					}				
					paymentResponse.paymentAmount = amountTobeCharged.toString(); 
					paymentResponse.paymentType="Card";
					paymentResponse.paymentAttempted = true;
					
					boolean paymentSuccessful = maintBp.addPayments(req.getPaymentParams(), membership,  amountTobeCharged, null, sa.getBranchKy().toString(), null);
					if(paymentSuccessful)
					{
						paymentResponse.isPaymentSuccess= true;
						paymentResponse.paymentAcctNum = req.getPaymentParams().getCard().getAccountNumber();
						paymentResponse.paymentMessage= "Sucess! Payment processed.";
					}
					else
					{
						paymentResponse.isPaymentSuccess= false;
						paymentResponse.paymentAcctNum = req.getPaymentParams().getCard().getAccountNumber();
						paymentResponse.paymentMessage= "Unable to process payment.";
					}
				}
				membership.save(true);
			}
			membership = new Membership(user, mn.getMembershipID());
			response = new MembershipSimpleOperationResponse();
			response.setSimpleMembership(null);
			response.setPaymentParams(req.getPaymentParams());
			response.setMembershipBalance(membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy())));
			response.setMembershipPayments(membershipUtilBP.formatAmount(membership.getPaymentAt()));
			response.setErrors(null);
					
			
			 
			if(paymentResponse.paymentAttempted && paymentResponse.isPaymentSuccess	 )
			{
			   infoList.add("Payment in the amount of " + paymentResponse.paymentAmount + " has been charged to " +  paymentResponse.paymentType  + " account ending in "  + paymentResponse.paymentAcctNum);
			}
			else if(paymentResponse.paymentAttempted && !paymentResponse.isPaymentSuccess	)
			{
				infoList.add("Unable to charge the " +  paymentResponse.paymentType  + " account ending in "  + paymentResponse.paymentAcctNum );
			}
			response.setInfoList(infoList);
		} 
		catch (WebServiceException e){	
			getLogger().error("", e);		
			if (req.getPaymentParams() !=null)
			{
				if(req.getPaymentParams().getCard()!=null && req.getPaymentParams().getCard().getAccountNumber() !=null &&
					req.getPaymentParams().getCard().getAccountNumber().length() >=4)
					{
						String acctNbr = req.getPaymentParams().getCard().getAccountNumber();
						req.getPaymentParams().getCard().setAccountNumber(acctNbr.substring(acctNbr.length() - 4));
					}
			}
			response = new MembershipSimpleOperationResponse(e.getMessage(), "1");		
			response.setSimpleMembership(null);
			response.setPaymentParams(req.getPaymentParams());
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
					 
		} 
		catch (Exception e) {
			getLogger().error("", e);
			
			response = new MembershipSimpleOperationResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
		}
		return response ;
	}
	
	/**
	 * New method of retrieving values to populate dropdowns on the web interface.
	 * 
	 * @param name
	 *            the unique name of the dropdown field
	 * @param clubCode
	 *            the code for the club that is requesting it
	 */
	public DropDownListResponse GetDropDown(DropDownListRequest req){
		
		DropDownListResponse response = null;
		Collection<ValidationError> errList = null;
		try {
			if (log.isDebugEnabled()){
				log.debug("**************************\n GetDropDown");
				log.debug("req: " + req.toString());
				log.debug("**************************");
			}
			try
			{
				//Validation of input values
				errList =  membershipUtilBP.performValidation(req, GET_DROP_DOWN_VALIDATION_XML);
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceException(genValidationMsg);
				}
			}
			catch (Exception e)
			{
				throw new WebServiceException(genErrorDuringValidationMsg);
			}		
			SimpleDropDown sdd = null;
			response = new DropDownListResponse();

			Collection<SimpleDropDown> dropDowns = new ArrayList<SimpleDropDown>(); 

			if(req !=null && req.getCodeTypes() !=null)
			{
				for (String codeType:req.getCodeTypes()){

					sdd = null;
					String clubCode = this.getUser().getClubCode();
					SimpleEditor simpleEditor = new SimpleEditor(user);

					if (log.isDebugEnabled()) log.debug("Creating a dropdown from name=" + codeType + " clubcode=" + clubCode);

					CodesVO codesvo = new CodesVO();
					codesvo.addCriteria(new SearchCondition("CODE_TYPE", SearchCondition.EQ, codeType));
					codesvo.addCriteria(new SearchCondition("AVAILABLE_ON_WEB_FL", SearchCondition.EQ, "Y"));
					codesvo.addOrderBy("SORT_NR");
					codesvo.setTableName("CX_CODES");
					codesvo = (CodesVO) simpleEditor.executeQuery(codesvo);
					if (codesvo == null) return null;

					try {

						codesvo.beforeFirst();

						if(codesvo.getHitCount() >0)
						{
							String cd = "";
							sdd = new SimpleDropDown(codeType);
							SortedMap<String, String>  codes = new TreeMap<String, String>();
							while (codesvo.next()) {
								if(codeType.equals("PHNTYP"))
								{
									cd = membershipUtilBP.getPhoneTypeByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd );
								}
								else if(codeType.equals("RDTPCD"))
								{
									cd = membershipUtilBP.getCoverageByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd );
								}
								else if(codeType.equals("RELATN"))
								{
									cd = membershipUtilBP.getRelationByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"), cd );
								}
								else if(codeType.equals("GENDER"))
								{
									cd = membershipUtilBP.getGenderByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd);
								}
								else if(codeType.equals("RENMTH"))
								{
									cd = membershipUtilBP.getRenewalTypeByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"), cd);
								}
								else if(codeType.equals("MEMTYP"))
								{
									cd = membershipUtilBP.getAssociateTypeByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd);
								}
								else if(codeType.equals("SALUCD"))
								{
									cd = membershipUtilBP.getSalutationByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd);
								}
								else if(codeType.equals("SUFFCD"))
								{
									cd = membershipUtilBP.getSuffixByMZPType(codesvo.getString("CODE"));
									if (cd==null || cd.equals(""))continue;
									codes.put(codesvo.getString("CODE_DESC"),cd);
								}
								else
								{
									codes.put( codesvo.getString("CODE_DESC"),codesvo.getString("CODE"));
								}

							}
							sdd.setCodes(codes);
						}
						dropDowns.add(sdd);

					}

					catch (SQLException e) {
						getLogger().error("", e);

					}
				}

			}
			response.setDropDowns(dropDowns);
		}
		catch (Exception e){
			log.error("Unable to create drop down list.", e);
			getLogger().error("", e);

			response = new DropDownListResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
		}
		return  response;
	}
	
	/**
	 * For SOA service Update Membership Home Address */
	@SuppressWarnings("static-access")
	public UpdateMembershipHomeAddressResponse UpdateMembershipHomeAddress(UpdateMembershipHomeAddressRequest req) throws Exception{
		
		UpdateMembershipHomeAddressResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		UpdateMembershipHomeAddressValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Update Membership Home Address");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			Territory newTerritory = null;
			
			//validate
			validationObject = new UpdateMembershipHomeAddressValidate(req.getSalesAgentID(), req.getAddress(), req.getMemberID());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, UPDATE_MEMBERSHIP_HOME_ADDRESS_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = this.getSalesAgent(req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Check new address to see if it is out of territory
			try
			{
				if(hasValueChanged(membership.getZip(), MembershipUtilBP.getZipcode(req.getAddress().getZipCode())))
				{
					newTerritory = Territory.getTerritoryByZip(user, MembershipUtilBP.getZipcode(req.getAddress().getZipCode()));
				}
			}
			catch(ObjectNotFoundException one)
			{
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			//Update Address
			if(hasValueChanged(membership.getAddressLine1(), req.getAddress().getAddressLine1())) membership.setAddressLine1(req.getAddress().getAddressLine1());
			if(hasValueChanged(membership.getAddressLine2(), req.getAddress().getAddressLine2())) membership.setAddressLine2(req.getAddress().getAddressLine2());
			if(hasValueChanged(membership.getCity(), req.getAddress().getCity())) membership.setCity(req.getAddress().getCity());
			if(hasValueChanged(membership.getState(), req.getAddress().getState())) membership.setState(req.getAddress().getState());
			
			if(hasValueChanged(membership.getZip(), MembershipUtilBP.getZipcode(req.getAddress().getZipCode())) || 
					hasValueChanged(membership.getDeliveryRoute(), MembershipUtilBP.getDeliveryRoute(req.getAddress().getZipCode())))
			{
				membership.setZip(MembershipUtilBP.getZipcode(req.getAddress().getZipCode()));
				membership.setDeliveryRoute(MembershipUtilBP.getDeliveryRoute(req.getAddress().getZipCode()));
		
				//Update branch to correct one for the zipcode being changed to.
				try
				{
					membership.resetBranch(null);
				}
				catch (ObjectNotFoundException e)
				{
					//This exception shouldn't happen, but if it does use branch key of new territory.
					membership.setBranchKy(newTerritory.getBranchKy());
				}
			}
			
			String comment = null;
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comment = membership.getChangeDescription() + "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource());
			}
			else
			{
				comment = membership.getChangeDescription();
			}
			
			CommentsAction.createComment(user, membership, comment);
			
			membership.save();
			
			response = new UpdateMembershipHomeAddressResponse("SUCCESS", "0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new UpdateMembershipHomeAddressResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new UpdateMembershipHomeAddressResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to update the membership! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response ;
	}
	
	/**
	 * For SOA service Update Member Name */
	@SuppressWarnings("static-access")
	public UpdateMemberNameResponse UpdateMemberName(UpdateMemberNameRequest req) throws Exception{
		
		UpdateMemberNameResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		UpdateMemberNameValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Update Member Name");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new UpdateMemberNameValidate(req.getSalesAgentID(), req.getMemberID(), req.getName());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, UPDATE_MEMBER_NAME_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = this.getSalesAgent(req.getSalesAgentID()); 
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Update Name
			boolean memberFound = false;
			for(Member m : membership.getMemberList())
			{
				if(m.getAssociateId().equals(mn.getAssociateID()))
				{
					memberFound = true;
					if(hasValueChanged(m.getName().getSalutation(), req.getName().fetchMzPSalutation())) m.setSalutation(req.getName().fetchMzPSalutation());
					if(hasValueChanged(m.getName().getFirstName(), req.getName().getFirstName())) m.setFirstName(req.getName().getFirstName());
					if(hasValueChanged(m.getName().getMiddleName(), req.getName().getMiddleName())) m.setMiddleName(req.getName().getMiddleName());
					if(hasValueChanged(m.getName().getLastName(), req.getName().getLastName())) m.setLastName(req.getName().getLastName());
					if(hasValueChanged(m.getName().getSuffix(), req.getName().fetchMzPSuffix())) m.setNameSuffix(req.getName().fetchMzPSuffix());
				}
			}
			
			if(!memberFound)
				throw new WebServiceException(genMemberNotFoundMsg + req.getMemberID().getFullNumber());
			
			String comment = null;
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comment = membership.getChangeDescription() + "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource());
			}
			else
			{
				comment = membership.getChangeDescription();
			}
			CommentsAction.createComment(user, membership, comment);
			
			membership.save();
			
			response = new UpdateMemberNameResponse("SUCCESS", "0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new UpdateMemberNameResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new UpdateMemberNameResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to update the member! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response ;
	}
	
	/**
	 * For SOA service Update Membership Primary Phone */
	@SuppressWarnings("static-access")
	public UpdateMembershipPrimaryPhoneResponse UpdateMembershipPrimaryPhone(UpdateMembershipPrimaryPhoneRequest req) throws Exception{
		
		UpdateMembershipPrimaryPhoneResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		UpdateMembershipPrimaryPhoneValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Update Membership Primary Phone");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new UpdateMembershipPrimaryPhoneValidate(req.getSalesAgentID(), req.getMemberID(), req.getPrimaryPhoneNumber());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, UPDATE_MEMBERSHIP_PRIMARY_PHONE_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = this.getSalesAgent(req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Update Phone
			if(hasValueChanged(membership.getPhone(), req.getPrimaryPhoneNumber())) membership.setPhone(req.getPrimaryPhoneNumber());
			
			String comment = null;
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comment = membership.getChangeDescription() + "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource());
			}
			else
			{
				comment = membership.getChangeDescription();
			}
			
			CommentsAction.createComment(user, membership, comment);
			
			membership.save();
			
			response = new UpdateMembershipPrimaryPhoneResponse("SUCCESS", "0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new UpdateMembershipPrimaryPhoneResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new UpdateMembershipPrimaryPhoneResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to update the member! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response ;
	}
	
	/**
	 * For SOA service Update Member Email Address */
	@SuppressWarnings("static-access")
	public UpdateMemberEmailResponse UpdateMemberEmail(UpdateMemberEmailRequest req) throws Exception{
		
		UpdateMemberEmailResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		UpdateMemberEmailValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Update Member Email");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new UpdateMemberEmailValidate(req.getSalesAgentID(), req.getMemberID(), req.getEmailAddress());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, UPDATE_MEMBER_EMAIL_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = this.getSalesAgent(req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Update Email
			boolean memberFound = false;
			for(Member m : membership.getMemberList())
			{
				if(m.getAssociateId().equals(mn.getAssociateID()))
				{
					memberFound = true;
					if(hasValueChanged(m.getEmail(), req.getEmailAddress())) {
						boolean emailExists = memberEmailCheckBP.isEmailDuplicated(req.getEmailAddress(), mn.getMembershipID(),mn.getAssociateID());
						if (emailExists) {
							throw new WebServiceException (genDuplicateEmailMsg);
						}
						m.setEmail(req.getEmailAddress());
					}
				}
			}
			
			if(!memberFound)
				throw new WebServiceException(genMemberNotFoundMsg + req.getMemberID().getFullNumber());
			
			String comment = null;
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comment = membership.getChangeDescription() + "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource());
			}
			else
			{
				comment = membership.getChangeDescription();
			}
			
			CommentsAction.createComment(user, membership, comment);
			
			membership.save();
			
			response = new UpdateMemberEmailResponse("SUCCESS","0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new UpdateMemberEmailResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			infoList.add("Failed to update the member! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new UpdateMemberEmailResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to update the member! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response ;
	}
	
	/**
	 * For SOA service Register Pos Sale */
	@SuppressWarnings("static-access")
	public RegisterPosSaleResponse RegisterPosSale(RegisterPosSaleRequest req) throws Exception{
		
		RegisterPosSaleResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		RegisterPosSaleValidate validationObject = null;
		Connection conn = ConnectionPool.getConnection(user);
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Register POS Sale");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new RegisterPosSaleValidate(req.getSalesAgentID(), req.getMemberID(), req.getPosSaleID(), req.getPosCustomerID());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, REGISTER_POS_SALE_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = new SalesAgent(user, req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Insert row into mz_pos_receipt table so sniffer short process will look for payments against sale id specified.
			SimpleVO mzPOSReceiptVO = new SimpleVO();
	        mzPOSReceiptVO.setCommand("select * from mz_pos_receipt where sale_id = ?");
	        mzPOSReceiptVO.setInt(1, Integer.parseInt(req.getPosSaleID()));
	        mzPOSReceiptVO.setTableName("mz_pos_receipt");
	        mzPOSReceiptVO.execute(conn);
	        boolean needInsert = false;
	        if (!mzPOSReceiptVO.first()) {
	        	needInsert = true;
	            mzPOSReceiptVO.moveToInsertRow();
	        }
	        mzPOSReceiptVO.updateString("ofc_id", sa.getPosOffice());
	        mzPOSReceiptVO.updateString("cust_id", req.getPosCustomerID());
	        mzPOSReceiptVO.updateInt("sale_id", Integer.parseInt(req.getPosSaleID()));
	        mzPOSReceiptVO.updateInt("cust_recpt_nr", 0);
	        mzPOSReceiptVO.updateTimestamp("cust_vst_dt", DateUtilities.getTimestamp(false));
	        mzPOSReceiptVO.updateTimestamp("sent_to_pos_dt", DateUtilities.getTimestamp(false));
	        mzPOSReceiptVO.updateInt("cust_pymt_amt", 0);
	        mzPOSReceiptVO.updateString("consultant_id", sa.getPosUser());
	        mzPOSReceiptVO.updateString("MEMBERSHIP_ID", membership.getMembershipId());
	        mzPOSReceiptVO.updateBigDecimal("MEMBERSHIP_KY", membership.getMembershipKy());
	        mzPOSReceiptVO.updateString("AGENT_ID", sa.getAgentId());
	        mzPOSReceiptVO.updateString("USER_ID", user.userID);
	        mzPOSReceiptVO.updateString("PAID_BY_CD", "P");
	        mzPOSReceiptVO.updateString("DELETED_FL", "N");
	        if (needInsert) {
	            mzPOSReceiptVO.insertRow();
	            mzPOSReceiptVO.moveToCurrentRow();
	            mzPOSReceiptVO.last();
	        }
	        else {
	            mzPOSReceiptVO.updateRow();
	        }
	        
	        mzPOSReceiptVO.acceptChanges(conn);
	        if (!conn.getAutoCommit()) conn.commit();
			
			response = new RegisterPosSaleResponse("SUCCESS","0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new RegisterPosSaleResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new RegisterPosSaleResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to register pos sale! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		finally {
            if (conn != null) {
                try {
                    conn.rollback();
                }
                catch (Exception ignore) {
                }
                try {
                    conn.close();
                }
                catch (Exception ignore) {
                }
            }
        }
		return response ;
	}
	
	public EnrollDonorMembershipInARResponse EnrollDonorMembershipInAR(EnrollDonorMembershipInARRequest request){
		
		String DEBUG_MODULE = "WM_EnrollDonorMembershipInAR_" + Calendar.getInstance().getTimeInMillis() +"";
		
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n EnrollDonorMembershipInAR request");
			getLogger().debug("EnrollDonorMembershipInAR request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		SalesAgent sa = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		String renewalMethodCd = null ; 
		String source = null; 
		
		Collection<String> infoList = new ArrayList<String>();
		
		EnrollDonorMembershipInARResponse response = null;
		try {
			if(request ==null){
				throw new WebServiceException("Invalid Request");
			}
				
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, request.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));		
			} catch (Exception e) {
				throw new WebServiceException(genInvalidAgentId);
			}
			
			try
			{
				source = request.getSource();
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				String membershipId = request.getFullMembershipNumber();
				mn =  mbp.parseFullMembershipNumber(membershipId);
				
				membership = new Membership(user, mn.getMembershipID());
				
				renewalMethodCd = membership.getPrimaryMember().getRenewMethodCd();
				
			} catch (Exception e){
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
						
			//Check territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
				
			//can't remove donor from a cancelled membership
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled.");	
			}
			
			//validate whether the membership is already in AR
			if (renewalMethodCd.equalsIgnoreCase("A")) {
				if(request.getPayment() ==null || ( request.getPayment().getCard()==null )) {
					throw new WebServiceException(genNoCreditCardMsg);
				} else if (!request.getPayment().getCard().getSaveAsAutoRenewalCard()) {
					throw new WebServiceException("Please mark the saveAsAutoRenewalCard value as true");
				}
			}
			
			String donorNumber = request.getDonorNumber();
			if (donorNumber== null || donorNumber.equalsIgnoreCase("")) {
				throw new WebServiceException("Please provide valid donor information");
			}
			Donor donor = new Donor(user, donorNumber);
			
			mubp.debug(DEBUG_MODULE, 
					"MembershipID: " + membership.getMembershipId() + 
					" | Donor Number: " + donorNumber + 
					" | Current RenewalMethod: " + renewalMethodCd + 
					" | Current Mbs status: " + membership.getStatus(), true);
			
			if(request.getPayment() ==null || ( request.getPayment().getCard()==null ) || 
					request.getPayment().getCard().getTokenNumber() == null || 
					request.getPayment().getCard().getTokenNumber().equals("")) {
				throw new WebServiceException(genNoCreditCardMsg);
			} else if (!request.getPayment().getCard().getSaveAsAutoRenewalCard()) {
				throw new WebServiceException("Please mark the saveAsAutoRenewalCard value as true");
			}
			
			//Switch from other to AR. 
			if (membership.getStatus().equalsIgnoreCase("P")&& isMembershipExpiringShortly(35, membership)){
				throw new WebServiceException("Can't switch AR when membership status is pending and membership expires in 35 days");
			}
			
			//Update the renewalMethod.
			for(Member m: membership.getMemberList()) {								
				m.setRenewMethodCd("A");		
			}
			
			//create comment. - START 
			String comment = "Renewal method was changed to %s. %s";
			
			String commentSourceSection = "";
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(source))) {
				commentSourceSection = "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(source); 
			}
			
			comment = String.format(comment, "Automatic Renewal", commentSourceSection);
			
			membership.addComment(comment);
			
			//create comment. - END
			
			membership.save();
			
			MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			
			AutorenewalCard card = maintBp.buildAutorenewalCardForDonorEnroll(membership, request.getPayment(), donor);		
			if (card!=null) {
				card.save();
				
				mubp.debug(DEBUG_MODULE, "Donor AR Enrolled, card key is: " + card.getCcToken(), true);
			}	
			
			membership.addComment("Donor Credit card has been saved");
			membership.save();
			
			response = new EnrollDonorMembershipInARResponse("Success", "0");;
				
		} catch (WebServiceException e){
			response = new EnrollDonorMembershipInARResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);	
		} catch (Exception e){
			response = new EnrollDonorMembershipInARResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);						
		}
		
		return response;
	}
	
	public RemoveDonorResponse RemoveDonor(RemoveDonorRequest request){
		
		SalesAgent sa = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		String DEBUG_MODULE = "WM_RemoveDonor_" + Calendar.getInstance().getTimeInMillis() +"";
		
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n RemoveDonor request");
			getLogger().debug("RemoveDonor request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		
		RemoveDonorResponse response = null;
		
		try {
			if(request ==null){
				throw new WebServiceException("Invalid Request");
			}
				
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, request.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));		
			} catch (Exception e) {
				throw new WebServiceException(genInvalidAgentId);
			}
			
			try
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				String membershipId = request.getFullMembershipNumber();
				mn =  mbp.parseFullMembershipNumber(membershipId);
				
				membership = new Membership(user, mn.getMembershipID());
			} catch (Exception e){
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
						
			//Check territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
				
			//can't remove donor from a cancelled membership
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled.");	
			}
			
			boolean donorRemoved = false;
			//remove donor from a non-cancelled membership
			for (Member m: membership.getMemberList()) {
				if (!m.getStatus().equalsIgnoreCase("C")) {
					m.setRenewMethodCd("B");
					m.setSendBillTo("P");
					m.setSendCardTo("P");
					
					for (com.rossgroupinc.memberz.model.Rider r: m.getRiderList()) {
						if (!r.getStatus().equalsIgnoreCase("C")) {
							r.setAutorenewalCardKy(null);
							r.setDonorNr("");
							r.setDonorRenewalCd("");
							r.setPaidByCd("P");
						}
					}
				}
				donorRemoved = true;
			}
			
			for (MembershipFees f: membership.getMembershipFeesList()) {
				if (f.getStatus().equalsIgnoreCase("A")) {
					f.setPaidByCd("P");
					f.setDonorNr("");
				}
			}
			
			String comment = "Donor removed";
			membership.addComment(comment);
			membership.save();
			
			mubp.debug(DEBUG_MODULE, "Donor Removed." , false);
			
			if (donorRemoved) {
				infoList.add("Donor Removed");
			}
			
			response = new RemoveDonorResponse("Success", "0");
			response.setInfoList(infoList);
			
		}  catch (WebServiceException e){
			response = new RemoveDonorResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);	
		} catch (Exception e){
			response = new RemoveDonorResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	@SuppressWarnings("static-access")
	public ApplyDonorPaymentResponse ApplyDonorPayment(ApplyDonorPaymentRequest req){
		
		//handle one membership per time. 
		
		ApplyDonorPaymentResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;

		ApplyPaymentCreditCardValidate validationObject = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		String sequenceNumber = null;
		
		boolean isCreditCardPayment = false;
		boolean isCheckPayment = false;
		boolean isPaymentApplied = false;
		
		boolean isGeneralExceptionCaught = false;
		boolean isCardAuthRevertable = false;
		
		BigDecimal paymentAmount = null;
		
//		String DEBUG_MODULE = "WM_ApplyDonorPayment_" + Calendar.getInstance().getTimeInMillis() +"";
//		
//		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		String returnCode = "0";
		String returnMessage= "Success";
		
		try {
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Donor Payment  \n : " );
				getLogger().info("Donor Number - " + req.getDonorNumber());
				getLogger().info("**************************\n");			
			}
			
			//Get membership based on member id passed in through the 
			DonorPaymentItem[] dpis = req.getDonorPaymentItems();
			if (dpis==null || dpis.length !=1) {
				throw new WebServiceException(genMembershipIdInvalid);
			} 
			
			String membershipId = null;
			MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
			
			for (DonorPaymentItem dpi: dpis) {
				membershipId = dpi.getMembershipNumber();
				try {
					mn =  mbp.parseFullMembershipNumber(membershipId);	
				} catch (Exception e) {
					throw new WebServiceException(genMembershipIdInvalid + membershipId);
				}
				break;
			}
			
			//Check territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			//Find Membership and validate the membership 
			try
			{
				membership = new Membership(user, mn.getMembershipID());
				
				//Check if cancelled.
				if(membership.isCancelled())
				{
					throw new WebServiceException("Membership is cancelled. Please reinstate the membership before making a payment. " + mn.getMembershipID());	
				}
				
			}
			catch (Exception e){
				getLogger().error(e.getMessage(), e);
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			
			String renewalMethodCd = membership.getPrimaryMember().getRenewMethodCd();
			
			//Make sure either credit card or check payment is there
			if(req.getPayment() == null || (req.getPayment().getCard()== null && req.getPayment().getCheck() == null)) {
				throw new WebServiceException("Either Credit Card or Check Payment must be supplied.");
			} else {
				if (req.getPayment().getCard()!= null) {
					//validate credit card information
					isCreditCardPayment = true;
					
					//validate credit card data, and other request data
					SimpleMembershipNumber smn = new SimpleMembershipNumber();
					smn.setFullNumber(membershipId);
					validationObject = new ApplyPaymentCreditCardValidate(req.getSalesAgentID(), smn, req.getPayment().getAmount(), 
																				req.getPayment().getCard());
					errList =  membershipUtilBP.performValidation(validationObject, APPLY_PAYMENT_VALIDATION_XML);
					if (errList !=null && !errList.isEmpty()){
						throw new WebServiceException(genValidationMsg);
					}
					
					//Make sure credit card payment is there with the sequence number  - yhu
					if(req.getPayment().getCard().getSequenceNumber() == null || req.getPayment().getCard().getSequenceNumber().trim().equals("")) {
						throw new WebServiceException("Credit Card Payment was not authorized.");
					} else {
						sequenceNumber = req.getPayment().getCard().getSequenceNumber();
						
						try {
							paymentAmount = new BigDecimal(req.getPayment().getAmount());
						} catch (NumberFormatException nfe) {
							paymentAmount = BigDecimal.ZERO;
						}
						
						isCardAuthRevertable = true;
					}
				} else if (req.getPayment().getCheck()!= null) {
					isCheckPayment = true;
					try {
						paymentAmount = new BigDecimal(req.getPayment().getAmount());
					} catch (NumberFormatException nfe) {
						paymentAmount = BigDecimal.ZERO;
					}
				}
			}
			
			String donorNumber = req.getDonorNumber();
			if (donorNumber== null || donorNumber.equalsIgnoreCase("")) {
				throw new WebServiceException("Please provide valid donor information");
			}
			
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, req.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			} catch (ObjectNotFoundException e){
				isCardAuthRevertable = false;
				throw new WebServiceException(genInvalidAgentId);
			}
			//validation ends here.
			
			
			
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				membership.addComment("\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource()));
				membership.save();
			}
			
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Donor Payment. \n : " );
				getLogger().info("Validation Passed \n");
				
				if (isCreditCardPayment) {
					getLogger().info("Credit Card Pmt detected \n");
					getLogger().info("Sequence Number" + sequenceNumber + "\n");
				} else if (isCheckPayment){
					getLogger().info("Check Pmt detected \n");
				}
				getLogger().info("**************************\n");			
			}

			//Handle Payment
			MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			
			if (isCreditCardPayment) {
				String ccTokenNumber = req.getPayment().getCard().getTokenNumber();
				String ccCardType = req.getPayment().getCard().getCardTypeCode();
				String address = req.getPayment().getCard().getCardHolderStreetAddress();
				String zip = req.getPayment().getCard().getCardHolderZipCode();
				
				Donor donor = new Donor(user, donorNumber);
				
				//Create auto renewal card if needed
				if (req.getPayment().getCard().getSaveAsAutoRenewalCard())
				{
					if (renewalMethodCd!=null && !renewalMethodCd.trim().equalsIgnoreCase("P")) {
						//Payment amount must be equal to the amount due if the membership is in renewal and wishes to be on auto renewal.
						if(req.getPayment().getCard().getSaveAsAutoRenewalCard() && 
								(membership.getPrimaryMember().inRenewal() && "RM".equals(membership.getBillingCd())) &&
								(membership.getBalance().subtract(paymentAmount)).compareTo(getUnderPayWriteOffAmt()) > 0 )
						{
							throw new WebServiceException("Membership must be paid in full before it can be put on auto renewal. ");	
						}
					} 
					
					AutorenewalCard card;
					membership.getPrimaryMember().setRenewMethodCd("A");
					
					try {
						card = maintBp.buildAutorenewalCardForDonorEnroll(membership, req.getPayment(), donor);
					} catch (IllegalArgumentException e) {
						throw new WebServiceException(e.getMessage());
					}
					
					if (card!=null)
					{													
						card.save();
						membership.save(true);
						infoList.add("Membership switched to Automatic Renewal");
					}	
				}
				
				//apply the payment to the membership, not captured yet. 
				isPaymentApplied = maintBp.applyCreditCardPayment(req.getPayment().getCard(), 
						paymentAmount,
						membership, 
						sa, 
						req.getPayment().getCard().getSaveAsAutoRenewalCard());
				
				isCardAuthRevertable = false;
				
				if (isPaymentApplied) {
					//Capture the payment  
					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
					
					OMElement captureRes = ccProcessorBP.captureCreditCard(ccTokenNumber, ccCardType, 
										membership.getMembershipId(), address, zip, paymentAmount, sequenceNumber);
					
					OMElement transactionResultOM = ccProcessorBP.getChildElement(captureRes, "TransactionResult");
					
					if(transactionResultOM!=null){
						String captureResult = ccProcessorBP.getChildElement(transactionResultOM, "ReturnCode").getText();
						
						if (captureResult.equals("0")) {
							membership.addComment("Successfully captured credit card payment inside mzp-webmember!");
							membership.save();
							
							returnCode = this.RETURN_CODE_APPLYPAYMENT_SUCCESS;
							returnMessage = "Success";
							
							infoList.add("Payment in the amount of " + req.getPayment().getAmount() + 
											" has been charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
						} else {
							infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
							infoList.add("Trying to revert the credit card authorization ");
							isCardAuthRevertable = true;
							returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE;
							returnMessage = "Credit card payment not capture successfully";
						}
					}
				} else {
					returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT;
					returnMessage = "Payment not applied, credit payment not captured";
				}
			} else if (isCheckPayment) {
				String salesAgentBranchCd = sa.getBranchKy().toString();
				isPaymentApplied = maintBp.addPayments(req.getPayment(), membership, paymentAmount, sa,salesAgentBranchCd, "MM");
				
				if (isPaymentApplied) {
					infoList.add("Payment in the amount of " + req.getPayment().getAmount() + " has been applied" );
					
					returnCode = RETURN_CODE_APPLYPAYMENT_SUCCESS;
					returnMessage = "Success";
				} else {
					infoList.add("Unable to apply the echeck payment");
					returnCode = RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT;
					returnMessage = "Unable to apply the echeck payment";
				}
			}
			
			//TODO: email confirmation. 
			
			membership.save(true);
			
			response = new ApplyDonorPaymentResponse(returnMessage,returnCode);
			response.setErrors(null);
			response.setInfoList(infoList);			
			
		}
		catch (WebServiceException e){
			isGeneralExceptionCaught = true;
			getLogger().error("", e);		
			response = new ApplyDonorPaymentResponse(e.getMessage(), ERROR_CODE_APPLYPAYMENT_GENERAL);	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			isGeneralExceptionCaught = true;
			
			getLogger().error("", e);			
			response = new ApplyDonorPaymentResponse(genWSExceptionMsg, ERROR_CODE_APPLYPAYMENT_GENERAL);
			response.setErrors(null);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);	
		}
		
		try {
			if (isCardAuthRevertable) {
				CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
				ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
				OMElement revertRes = ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
			}
			
			if (isGeneralExceptionCaught && isCreditCardPayment && !isPaymentApplied)  {
				response.setInfoList(infoList);
			}
			
		}catch (Exception e) {
			e.printStackTrace();
		}
		
		return response;
	}
	
	/**
	 * For SOA service Apply Payment */
	@SuppressWarnings("static-access")
	public ApplyPaymentResponse ApplyPayment(ApplyPaymentRequest req) throws Exception{
		
		ApplyPaymentResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		ApplyPaymentCreditCardValidate validationObject = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Apply Payment");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}
			
			//validate
			
			//Make sure credit card payment is there
			if(req.getPayment() == null || req.getPayment().getCard() == null) throw new WebServiceException("Credit Card Payment must be supplied.");
			
			//validate credit card data, and other request data
			validationObject = new ApplyPaymentCreditCardValidate(req.getSalesAgentID(), req.getMemberID(), req.getPayment().getAmount(), req.getPayment().getCard());
			
			errList =  membershipUtilBP.performValidation(validationObject, APPLY_PAYMENT_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, req.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			catch (ObjectNotFoundException e)
			{
				throw new WebServiceException(genInvalidAgentId);
			}
			
			//Get membership based on member id passed in
			try
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				
				mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Check territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			//Find Membership
			try
			{
				membership = new Membership(user, mn.getMembershipID());
			}
			catch (ObjectNotFoundException onfe)
			{
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			catch (Exception e)
			{
				getLogger().error(e.getMessage(), e);
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			
			//Check if cancelled.
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled. Please reinstate the membership before making a payment. " + mn.getMembershipID());	
			}
			
			//apply renewal discount -start [yhu]
			boolean discountApplied = false;
			try {
				membership.addComment("Before apply the renewal discount: " + req.getMarketCode().trim());
				membership.save();
				
				//apply discount before captured payment applied, to avoid the membership/pm status change and then applying discount failure.
				if (req.getMarketCode()!=null && !req.getMarketCode().trim().equals("")) {
					DiscountBP dbp = (DiscountBP)BPF.get(user, DiscountBP.class);
					dbp.applyDiscountWithMarketCodes(mn.getMembershipID(), req.getMarketCode().trim().toUpperCase());
					discountApplied = true;
				}	
				
				membership.addComment("After apply the renewal discount: " + req.getMarketCode().trim());
				membership.save();
					
			} catch (Exception e) {
				
				//response.setResult("1");
				//infoList.add("Unable to apply discount.  " + e.getMessage());
			}
			//apply renewal discount -end [yhu]
						
			//Handle Card Payment
			if(req.getPayment() != null && req.getPayment().getCard()!= null)
			{
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				BigDecimal paymentAmount = null;
				
				if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
				{
					membership.addComment("\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource()));
				}
				
				try {
					paymentAmount = new BigDecimal(req.getPayment().getAmount());
				} catch (NumberFormatException nfe) {
					paymentAmount = BigDecimal.ZERO;
				}
				
				//Payment amount must be equal to the amount due if the membership is in renewal and wishes to be on auto renewal.
				if(req.getPayment().getCard().getSaveAsAutoRenewalCard() && 
						(membership.getPrimaryMember().inRenewal() && "RM".equals(membership.getBillingCd())) &&
						//membership.getBalance().compareTo(paymentAmount) < 0)
						//wwei webmember bug, need add writeoff amt;
						(membership.getBalance().subtract(paymentAmount)).compareTo(getUnderPayWriteOffAmt()) > 0 ) 
				{
					
					throw new WebServiceException("Membership must be paid in full before it can be put on auto renewal. ");	
				}
				
				//Create auto renewal card if needed
				if (req.getPayment().getCard().getSaveAsAutoRenewalCard())
				{					
					AutorenewalCard card;
					membership.getPrimaryMember().setRenewMethodCd("A");
					
					try {
						card = maintBp.buildAutorenewalCard(membership, req.getPayment());
					} catch (IllegalArgumentException e) {
						throw new WebServiceException(e.getMessage());
					}
					
					if (card!=null)
					{													
						card.save();
						membership.save(true);
						infoList.add("Membership switched to Automatic Renewal");
					}	
				}			
				
				boolean paymentSuccessful = maintBp.applyCreditCardPayment(req.getPayment().getCard(), 
																			paymentAmount,
																			membership, 
																			sa, 
																			req.getPayment().getCard().getSaveAsAutoRenewalCard());
				if(paymentSuccessful)
				{
					infoList.add("Payment in the amount of " + req.getPayment().getAmount() + " has been charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
				}
				else
				{
					infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
				}
				
				membership.save(true);
				
			}  //end handle card payment
			
			//send confirmation email if needed
			if(req.isSendEmailConfirmation())
			{
				//get email address of member in member number sent in
				String email = "";

				for(Member m : membership.getMemberList(true))
				{
					if(m.getAssociateId() != null && m.getAssociateId().equals(mn.getAssociateID()))
					{
						email = m.getEmail();
						break;
					}
				}
				
				//send email
				if(email != null && !"".equals(email))
				{
					WebLetterBP webLetterBP = BPF.get(user.getGenericUser(), WebLetterBP.class);
					Validator valid = new Validator();
					PaymentSummary ps = membershipUtilBP.getMostRecentPayment(membership);
					
					if(ps != null)
					{
						webLetterBP.sendPaymentConfirmationLetter(email, ps.getMembershipPaymentKy().toString(), valid);
						
						if(!valid.isValid())
						{
							infoList.add(valid.getMessage());
						}
						else
						{
							infoList.add("Payment confirmation email sent to " + email);
						}
					}
					else
					{
						infoList.add("Unable to send email confirmation. No payments found for membership.");
					}
				}
				else
				{
					infoList.add("Unable to send email confirmation. Email not found for member.");
				}
			}
			
			membership = new Membership(user, mn.getMembershipID());
			
			response = new ApplyPaymentResponse("SUCCESS","0");
			response.setErrors(null);
			
			if(paymentResponse.paymentAttempted && paymentResponse.isPaymentSuccess	 )
			{
				infoList.add("Payment in the amount of " + paymentResponse.paymentAmount + " has been charged to " +  paymentResponse.paymentType  + " account with a token of "  + paymentResponse.paymentAcctNum);
			}
			else if(paymentResponse.paymentAttempted && !paymentResponse.isPaymentSuccess)
			{
				infoList.add("Unable to charge the " +  paymentResponse.paymentType  + " account ending in "  + paymentResponse.paymentAcctNum );
			}
			
			if (discountApplied) {
				infoList.add("Discount applied:  " + req.getMarketCode().trim());
			}
			response.setInfoList(infoList);			
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new ApplyPaymentResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new ApplyPaymentResponse(genWSExceptionMsg, "1");
			response.setErrors(null);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);	
		}
		
		return response;
	}

	/**
	 * For SOA service Apply Payment */
	@SuppressWarnings("static-access")
	public ApplyPaymentResponse ApplyPaymentWithCapture(ApplyPaymentRequest req) throws Exception{
		
		/*********************************************************************
		  PLEASE READ: 
		  . The authorization code in the original apply payment was used as approve code because the payment was captured later after the call. 
		  . This method is going to use the new sequence number node to tell it needs to capture or reverse authorization   
		  
		  . this method is called from web member one click renewal by passing in the market code. 
		  . this method is called from my account upgrade/add associate path as the last step of the process. market code is not needed for these scenarios
		  . this method is called from installment enrollment for existing membership as the last step. need to pass in the installment plan ky.
		  . this method is called for existing ip membership for processing their payment.  
		
		***********************************************************************/
		ApplyPaymentResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		ApplyPaymentCreditCardValidate validationObject = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		String sequenceNumber = null;
		
		DiscountOfferBP dobp = (DiscountOfferBP) BPF.get(user, DiscountOfferBP.class);
		DiscountBP dbp1 = (DiscountBP) BPF.get(user, DiscountBP.class);
		
		boolean isCreditCardPayment = false;
		boolean isCheckPayment = false;
		boolean discountApplied = false;
		boolean isPaymentApplied = false;
		boolean paymentSuccessful = false;
		
		boolean isGeneralExceptionCaught = false;
		boolean isCardAuthRevertable = false;
		
		BigDecimal paymentAmount = null;
		
		String returnCode = "0";
		
		String returnMessage= "Success";
		
		String DEBUG_MODULE = "WM_ApplyPaymentWithCapture_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Payment With Capture Request. \n : " );
				getLogger().info("Full Membership - " + req.getMemberID().getFullNumber());
				getLogger().info("**************************\n");			
			}
			
			//Get membership based on member id passed in
			try
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
			}catch (Exception e) {
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Check territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			//Find Membership
			try
			{
				membership = new Membership(user, mn.getMembershipID());
			}
			catch (ObjectNotFoundException onfe)
			{
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			catch (Exception e)
			{
				getLogger().error(e.getMessage(), e);
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			
			//Check if cancelled.
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled. Please reinstate the membership before making a payment. " + mn.getMembershipID());	
			}
			
			String renewalMethodCd = membership.getPrimaryMember().getRenewMethodCd();
			
			//at this point, membership is not cancelled, and membership's renewal method has been retrieved.
			//if renewal method is other than IP, and plan key is provided. use the applypaymentWithCapture method dedicated to IP enrollment
			if (renewalMethodCd!=null) {
				if (!renewalMethodCd.trim().equalsIgnoreCase("P")) {
					if (req !=null && req.getPaymentPlanKy()!=null && !req.getPaymentPlanKy().trim().equals("")) {
						//redirect traffic to the overloading function to handle the installment plan enrollment with payment
						return ApplyPaymentWithCaptureIPEnrollment(req, DEBUG_MODULE);
					}
				} else {
					return ApplyPaymentWithCaptureIPExisting(req, DEBUG_MODULE);
				}
			}
			
			//Make sure either credit card or check payment is there
			if(req.getPayment() == null || (req.getPayment().getCard()== null && req.getPayment().getCheck() == null)) {
				throw new WebServiceException("Either Credit Card or Check Payment must be supplied.");
			} else {
				if (req.getPayment().getCard()!= null) {
					//validate credit card information
					isCreditCardPayment = true;
					
					//validate credit card data, and other request data
					validationObject = new ApplyPaymentCreditCardValidate(req.getSalesAgentID(), req.getMemberID(), req.getPayment().getAmount(), 
																				req.getPayment().getCard());
					errList =  membershipUtilBP.performValidation(validationObject, APPLY_PAYMENT_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					
					mubp.debug(DEBUG_MODULE, "membership id: " + membership.getMembershipId() + " Credit card payment passed basic validation,  ", true); 
					
					//Make sure credit card payment is there with the sequence number  - yhu
					if(req.getPayment().getCard().getSequenceNumber() == null || req.getPayment().getCard().getSequenceNumber().trim().equals("")) {
						throw new WebServiceException("Credit Card Payment was not authorized.");
					} else {
						sequenceNumber = req.getPayment().getCard().getSequenceNumber();
						
						try {
							paymentAmount = new BigDecimal(req.getPayment().getAmount());
						} catch (NumberFormatException nfe) {
							paymentAmount = BigDecimal.ZERO;
							throw new WebServiceException("Credit Card Payment Amount is not valid.");
						}
						
						isCardAuthRevertable = true;
						
						mubp.debug(DEBUG_MODULE, "Credit card revertable set to true" , true);
						
//						if (true) {
//							throw new WebServiceException("Test Exception.");
//						}
					}
				} else if (req.getPayment().getCheck()!= null) {
					isCheckPayment = true;
					try {
						paymentAmount = new BigDecimal(req.getPayment().getAmount());
					} catch (NumberFormatException nfe) {
						paymentAmount = BigDecimal.ZERO;
					}
				}
			}
			
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, req.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			catch (ObjectNotFoundException e)
			{
				isCardAuthRevertable = false;
				throw new WebServiceException(genInvalidAgentId);
			}
			
			
			
			//validation ends here.
			
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				membership.addComment("\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource()));
				membership.save();
			}
			
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Payment With Capture Request. \n : " );
				getLogger().info("Validation Passed \n");
				
				if (isCreditCardPayment) {
					getLogger().info("Credit Card Pmt detected \n");
					getLogger().info("Sequence Number" + sequenceNumber + "\n");
				} else if (isCheckPayment){
					getLogger().info("Check Pmt detected \n");
				}
				getLogger().info("**************************\n");			
			}

			//apply renewal discount -start [yhu]
			try {
				//apply discount before captured payment applied, to avoid the membership/pm status change and then applying discount failure.
				if (req.getMarketCode()!=null && !req.getMarketCode().trim().equals("")) {
					if (req.getMarketCode().trim().equals("MILI")) {  //military market code handling
						String militaryBillingCategoryCd = "MILTDS"; 
						membership.setBillingCategoryCd(militaryBillingCategoryCd);
						//shadow membership handling
						SortedSet<MembershipCode> mbsCodesList = membership.getMembershipCodeList();
						boolean isShadow = false; 
						
						if (mbsCodesList !=null && mbsCodesList.size() > 0)
						{
							for(MembershipCode code :  mbsCodesList)
							{
								
								if(code.getCode().equals("SHADOW")) {
									isShadow = true; 
								}
								 
							}
						}
						
						CostBP costBP = (CostBP )BPF.get(user, CostBP.class);
						
						for (com.rossgroupinc.memberz.model.Member m: membership.getCurrentMemberList()) {
							m.setBillingCategoryCd(militaryBillingCategoryCd);
							
							for (com.rossgroupinc.memberz.model.Rider r: m.getRiderList()) {
								if (!r.getStatus().equalsIgnoreCase("C")){
									if (isShadow) {
										if (!r.getRiderCompCd().equals("MC") && !r.getRiderCompCd().equals("RV")) {
											r.setBillingCategoryCd(militaryBillingCategoryCd);
											
											CostData cd = costBP.getRiderCost(membership, r, membership.getClubCode(), militaryBillingCategoryCd,  
													membership.getRegionCode(),
													membership.getDivisionKy(), membership.getBranchKy(), r.getRiderCompCd(), m.getMemberTypeCd(), 
													membership.getPrimaryMember().getActiveExpirationDt(), 
													"PRIMARY", m, "N", membership.getMembershipTypeCd(), membership.getDuesState());
											
											r.setAdmOriginalCostAt(cd.getFullCost());
											r.setDuesAdjustmentAt(BigDecimal.ZERO);
											r.setDuesCostAt(cd.getFullCost());
											
										}	
									} else {
										r.setBillingCategoryCd(militaryBillingCategoryCd);
										
										CostData cd = costBP.getRiderCost(membership, r, membership.getClubCode(), militaryBillingCategoryCd,  
												membership.getRegionCode(),
												membership.getDivisionKy(), membership.getBranchKy(), r.getRiderCompCd(), m.getMemberTypeCd(), 
												membership.getPrimaryMember().getActiveExpirationDt(), 
												"PRIMARY", m, "N", membership.getMembershipTypeCd(), membership.getDuesState());
										
										r.setAdmOriginalCostAt(cd.getFullCost());
										r.setDuesAdjustmentAt(BigDecimal.ZERO);
										r.setDuesCostAt(cd.getFullCost());
									}
									
									
								}
							}
						}
						membership.save(); 
						
					}
					
					DiscountBP dbp = (DiscountBP)BPF.get(user, DiscountBP.class);
					dbp.applyDiscountWithMarketCodes(mn.getMembershipID(), req.getMarketCode().trim().toUpperCase());
					discountApplied = true;
				}	
				
				if (discountApplied) {
					membership.addComment("Applied the discount: " + req.getMarketCode().trim());
					membership.save();
					
					infoList.add("Discount applied:  " + req.getMarketCode().trim());
				}
					
			} catch (Exception e) {
				e.printStackTrace();
				//response.setResult("1");
				//infoList.add("Unable to apply discount.  " + e.getMessage());
			}
			//apply renewal discount -end [yhu]
						
			//Handle Payment
			MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			
			if (isCreditCardPayment) {
				String ccTokenNumber = req.getPayment().getCard().getTokenNumber();
				String ccCardType = req.getPayment().getCard().getCardTypeCode();
				String address = req.getPayment().getCard().getCardHolderStreetAddress();
				String zip = req.getPayment().getCard().getCardHolderZipCode();
				
				if (renewalMethodCd!=null && !renewalMethodCd.trim().equalsIgnoreCase("P")) {
					//Payment amount must be equal to the amount due if the membership is in renewal and wishes to be on auto renewal.
					if(req.getPayment().getCard().getSaveAsAutoRenewalCard() && 
							(membership.getPrimaryMember().inRenewal() && "RM".equals(membership.getBillingCd())) &&
							//membership.getBalance().compareTo(paymentAmount) > 0)
							//wwei webmember bug, need add writeoff amt;
							(membership.getBalance().subtract(paymentAmount)).compareTo(getUnderPayWriteOffAmt()) > 0 )
					{
						throw new WebServiceException("Membership must be paid in full before it can be put on auto renewal. ");	
					}
				} 
				
				if (renewalMethodCd!=null && renewalMethodCd.trim().equalsIgnoreCase("P")) {
					//Payment amount must be equal to the amount due if the membership is in renewal and wishes to be on auto renewal.
					if(membership.getBalance().compareTo(paymentAmount) != 0)
					{
						throw new WebServiceException("Membership must be paid in full for existing installment plan membership ");	
					} else {
						//talked with Pat and Prakash on 2/27. if membership is IP, reset the saveAsAutoRenewalCard flag as false. 
						//so the logic to set the membership to AR below will be skipped. 
						req.getPayment().getCard().setSaveAsAutoRenewalCard(false);
					}
				} 
				
				//Create auto renewal card if needed
				if (req.getPayment().getCard().getSaveAsAutoRenewalCard())
				{					
					AutorenewalCard card;
					membership.getPrimaryMember().setRenewMethodCd("A");
					
					try {
						mubp.debug(DEBUG_MODULE, "Before save autorenewal card", true);
						
						card = maintBp.buildAutorenewalCard(membership, req.getPayment());
					} catch (IllegalArgumentException e) {
						mubp.debug(DEBUG_MODULE, "failed to build autorewnal card", true);
						throw new WebServiceException(e.getMessage());
					}
					
					if (card!=null)
					{													
						card.save();
						membership.addComment(String.format("Via web member, membership %s, was switched to AR", membership.getMembershipId()));
						membership.save(true);
						infoList.add("Membership switched to Automatic Renewal");
					}	
				}
				
				//apply the payment to the membership, not captured yet. 
				isPaymentApplied = maintBp.applyCreditCardPayment(req.getPayment().getCard(), 
						paymentAmount,
						membership, 
						sa, 
						req.getPayment().getCard().getSaveAsAutoRenewalCard());
				
				if (renewalMethodCd!=null && renewalMethodCd.trim().equalsIgnoreCase("P")) {
					//post zero dollars - copied from AutoRenewalBean.
					//for some reason, the above "applyCreditCardPayment" call sometimes doesn't mark every payment as paid even full balance amount has been taken. 
					BPF.get(user,PaymentPosterBP.class).postZeroDollarPayment(membership, "ZP-MakePayment", "MM", ((MemberzPlusUser)user).getBranchKy(), "Y", "A", null);
				} else {
					PaymentPlanBP ppbp = BPF.get(user, PaymentPlanBP.class);
					ppbp.removeUnPaidorRejectedPlanBillingsForNonIPMembership(membership); 
				}
				
				mubp.debug(DEBUG_MODULE, "applied payment to membership before capture, auth non-revertable after this.", true);
				
				isCardAuthRevertable = false;
				
				if (isPaymentApplied) {
					//Capture the payment  
					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
					
					OMElement captureRes = ccProcessorBP.captureCreditCard(ccTokenNumber, ccCardType, 
										membership.getMembershipId(), address, zip, paymentAmount, sequenceNumber);
					
					mubp.debug(DEBUG_MODULE, "capture payment request: " +
											"\n tokenNumber: " + ccTokenNumber +
											"\n cardType: " + ccCardType + 
											"\n address: " + address + 
											"\n zip: " + zip +
											"\n paymentAmount: " + paymentAmount + 
											"\n sequenceNumber: " + sequenceNumber 
									, true);
					
					mubp.debug(DEBUG_MODULE, "capture payment response: " + captureRes, true);
					
					OMElement transactionResultOM = ccProcessorBP.getChildElement(captureRes, "TransactionResult");
					
					if(transactionResultOM!=null){
						String captureResult = ccProcessorBP.getChildElement(transactionResultOM, "ReturnCode").getText();
						
						if (captureResult.equals("0")) {
							membership.addComment("Successfully captured credit card payment inside mzp-webmember!");
							membership.save();
							
							paymentSuccessful = true; //payment captured. 
							returnCode = this.RETURN_CODE_APPLYPAYMENT_SUCCESS;
							returnMessage = "Success";
							
							infoList.add("Payment in the amount of " + req.getPayment().getAmount() + 
											" has been charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
						} else {
							infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
							infoList.add("Trying to revert the credit card authorization ");
							isCardAuthRevertable = true;
							returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE;
							returnMessage = "Credit card payment not capture successfully";
						}
					}
				} else {
//					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class);	
//					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
//					
//					ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
//						
//					membership.addComment("Credit card authorization reversal occured because of capture failure!");
//					membership.save();
					returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT;
					returnMessage = "Payment not applied, credit payment not captured";
				}
			} else if (isCheckPayment) {
				String salesAgentBranchCd = sa.getBranchKy().toString();
				isPaymentApplied = maintBp.addPayments(req.getPayment(), membership, paymentAmount, sa,salesAgentBranchCd, "MM");
				
				if (isPaymentApplied) {
					infoList.add("Payment in the amount of " + req.getPayment().getAmount() + " has been applied" );
					
					returnCode = RETURN_CODE_APPLYPAYMENT_SUCCESS;
					returnMessage = "Success";
				} else {
					infoList.add("Unable to apply the echeck payment");
					returnCode = RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT;
					returnMessage = "Unable to apply the echeck payment";
				}
			}
			
			//TODO: email confirmation. 
			
			membership.save(true);
			
			//add offers if there is any
			if (req.getMarketCode()!=null && !req.getMarketCode().trim().equals("")) {
				dobp.addOffers(membership, req.getMarketCode().toUpperCase().trim());	
			}
			
			response = new ApplyPaymentResponse(returnMessage,returnCode);
			response.setErrors(null);
			response.setInfoList(infoList);			
			
		}
		catch (WebServiceException e){
			isGeneralExceptionCaught = true;
			getLogger().error("", e);		
			response = new ApplyPaymentResponse(e.getMessage(), ERROR_CODE_APPLYPAYMENT_GENERAL);	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			isGeneralExceptionCaught = true;
			
			getLogger().error("", e);			
			response = new ApplyPaymentResponse(genWSExceptionMsg, ERROR_CODE_APPLYPAYMENT_GENERAL);
			response.setErrors(null);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);	
		}
		
		try {
			if (isCardAuthRevertable) {
				CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
				ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
				mubp.debug(DEBUG_MODULE, "trying to revert auth\n sequenceNumber: " + sequenceNumber , true);
				OMElement revertRes = ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
				
				if (revertRes!=null) {
					mubp.debug(DEBUG_MODULE, "revert auth response: " + revertRes.toString(), true);
				} else {
					mubp.debug(DEBUG_MODULE, "revert auth response is null",  true);
				}
			}
			
			if (isGeneralExceptionCaught && isCreditCardPayment && !isPaymentApplied)  {
//				if (!sequenceNumber.equals("") && paymentAmount.compareTo(BigDecimal.ZERO) != 0) {
//					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class);	
//					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
//					
//					ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
//					infoList.add("Reversed the credit card authorization because of general error. ");
//				}
				
				response.setInfoList(infoList);
			}
			
			if (isGeneralExceptionCaught && discountApplied && !paymentSuccessful){
				if (req.getMarketCode()!=null && !req.getMarketCode().trim().equals("")) {
					dbp1.removeRenewalDiscountForMarketCode(membership, req.getMarketCode().toUpperCase().trim());	
				}
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		
		return response;
	}
	
	private ApplyPaymentResponse ApplyPaymentWithCaptureIPEnrollment(ApplyPaymentRequest req, String debugModule) throws Exception{
		String DEBUG_MODULE = debugModule;
		
		ApplyPaymentResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		ApplyPaymentCreditCardValidate validationObject = null;
		
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		String sequenceNumber = null;
		BigDecimal paymentAmount = null;
		
		PaymentPlanBP ppbp = BPF.get(user, PaymentPlanBP.class);
		
		boolean paymentAppliedSuccessful = false;
		boolean isInstallmentFirstPaymentRejected = false;
		boolean isValidationPassed = false;
		String approvalCode = "";
		
		String returnCode = "0";
		String returnMessage= "Success";
		boolean isCardAuthRevertable = false;
		
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Payment With Capture Installment Enrollment Request. \n : " );
				getLogger().info("Full Membership - " + req.getMemberID().getFullNumber());
				getLogger().info("**************************\n");			
			}
			
			mubp.debug(DEBUG_MODULE, "start ApplyPaymentWithCaptureIPEnrollment transaction", true);
			
			//validate start 
			
			//Make sure either credit card or check payment is there
			if(req.getPayment() == null || (req.getPayment().getCard()== null )) {
				throw new WebServiceException("Either Credit Card must be supplied.");
			} 
			
			//sequence number validation
			if(req.getPayment().getCard().getSequenceNumber() == null || req.getPayment().getCard().getSequenceNumber().trim().equals("")) {
				throw new WebServiceException("Credit Card Payment was not authorized.");
			} else {
				sequenceNumber = req.getPayment().getCard().getSequenceNumber();
			}
			
			//validate credit card data, and other request data
			validationObject = new ApplyPaymentCreditCardValidate(req.getSalesAgentID(), req.getMemberID(), req.getPayment().getAmount(), 
																		req.getPayment().getCard());
			errList =  membershipUtilBP.performValidation(validationObject, APPLY_PAYMENT_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//validate the charge Amount in general
			try {
				paymentAmount = new BigDecimal(req.getPayment().getAmount());
			} catch (NumberFormatException nfe) {
				throw new WebServiceException("The charge Amount is not valid");
			}
			
			//Get Sales Agent
			try
			{
				sa = new SalesAgent(user, req.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			catch (ObjectNotFoundException e)
			{
				throw new WebServiceException(genInvalidAgentId);
			}
			
			//enable the card isCardAuthRevertable to true
			isCardAuthRevertable = true;
			
			//Get membership based on member id passed in
			try
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
			}catch (Exception e) {
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//validate territory
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			//Find Membership
			try
			{
				membership = new Membership(user, mn.getMembershipID());
			}
			catch (ObjectNotFoundException onfe)
			{
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			catch (Exception e)
			{
				getLogger().error(e.getMessage(), e);
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			
			//Check if cancelled.
			if(membership.isCancelled())
			{
				throw new WebServiceException("Membership is cancelled. Please reinstate the membership before making a payment. " + mn.getMembershipID());	
			}
			
			//validate the membership's renewal method not in payment plan
			if (ppbp.isOnPaymentPlan(membership)){
				throw new WebServiceException("Membership already on payment plan"); 
			}
			
			//validate to make sure the primary member already has an email address. 
			if ( membership.getPrimaryMember().getEmail() == null){
				throw new WebServiceException("Primary member should have an email address");
			}
			
			//validate the membership is in renewal
			boolean inRenewal = false;
			if (membership.isPending()){
				Member pm = membership.getPrimaryMember();
				inRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
				inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
			}
			
			if (!inRenewal) {
				throw new WebServiceException("Membership must be in renewal to enroll into installment plan"); 
			}
			
			//validate the membership balance is above the minimum pay configured in an xml file. 
			if (!ppbp.isEnoughForPaymentPlan(membership.getBalance())) {
				throw new WebServiceException("Membership must have a minimum balance to enroll into installment plan");
			}
			
			isValidationPassed = true;
			//validation ends here.
			
			if (getLogger().isInfoEnabled()){			
				getLogger().info("**************************\n Apply Payment With Capture Installment Enrollment Request. \n : " );
				getLogger().info("Validation Passed \n");
				
					getLogger().info("Credit Card Pmt detected \n");
					getLogger().info("Sequence Number" + sequenceNumber + "\n");
				getLogger().info("**************************\n");			
			}

			//apply renewal discount -start [yhu]
			try {
				//apply discount before captured payment applied, to avoid the membership/pm status change and then applying discount failure.
				if (req.getMarketCode()!=null && !req.getMarketCode().trim().equals("")) {
					DiscountBP dbp = (DiscountBP)BPF.get(user, DiscountBP.class);
					dbp.applyDiscountWithMarketCodes(mn.getMembershipID(), req.getMarketCode().trim().toUpperCase());
					membership.addComment("Applied the discount: " + req.getMarketCode().trim());
					membership.save();
					
					infoList.add("Discount applied:  " + req.getMarketCode().trim());
				}	
				
					
			} catch (Exception e) {
				e.printStackTrace();
				//response.setResult("1");
				//infoList.add("Unable to apply discount.  " + e.getMessage());
			}
			//apply renewal discount -end [yhu]
			
			isCardAuthRevertable = false;
			
			//capture the payment
			try {
				//capture the credit card payment. 
				String ccTokenNumber = req.getPayment().getCard().getTokenNumber();
				String ccCardType = req.getPayment().getCard().getCardTypeCode();
				String address = req.getPayment().getCard().getCardHolderStreetAddress();
				String zip = req.getPayment().getCard().getCardHolderZipCode();
				
				CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
				ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
				
				OMElement captureRes = ccProcessorBP.captureCreditCard(ccTokenNumber, ccCardType, 
									membership.getMembershipId(), address, zip, paymentAmount, sequenceNumber);
				
				OMElement transactionResultOM = ccProcessorBP.getChildElement(captureRes, "TransactionResult");
				
				if(transactionResultOM!=null){
					String captureResult = ccProcessorBP.getChildElement(transactionResultOM, "ReturnCode").getText();
					
					if (captureResult.equals("0")) {
						membership.addComment("Successfully captured credit card payment inside mzp-webmember!");
						membership.save();
						
						returnCode = this.RETURN_CODE_APPLYPAYMENT_SUCCESS;
						returnMessage = "Success";
						
						OMElement authorizationCaptureReplyOM = ccProcessorBP.getChildElement(captureRes, "AuthorizationCaptureReply");
						approvalCode = ccProcessorBP.getChildElement(authorizationCaptureReplyOM, "ApprovalCode").getText();
							
						infoList.add("Payment in the amount of " + req.getPayment().getAmount() + 
										" has been charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
					} else {
						//payment failed
						isInstallmentFirstPaymentRejected = true;
						
						infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
						returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE;
						returnMessage = "Credit card payment not capture successfully";
					}
				} else {
					isInstallmentFirstPaymentRejected = true;
					
					infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
					returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE;
					returnMessage = "Credit card payment not capture successfully";
					
				}
			} catch (Exception e) {
				//payment failed
				isInstallmentFirstPaymentRejected = true;
				
				infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
				returnCode = this.RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE;
				returnMessage = "Credit card payment not capture successfully";
			}
			
			//successful 1st payment 
			if (!isInstallmentFirstPaymentRejected) {
				cancelDonations(membership);
				
				//post zero dollars - copied from AutoRenewalBean. 
				BPF.get(user,PaymentPosterBP.class).postZeroDollarPayment(membership, "ZP-MakePayment", "MM", ((MemberzPlusUser)user).getBranchKy(), "Y", "A", null);
				
				SortedSet<PlanBilling> UnpaidOrRejectedbillingRecords = ppbp.getAnyUnpaidOrRejectedPlanBillingRecords(membership);
				if(UnpaidOrRejectedbillingRecords !=null && !UnpaidOrRejectedbillingRecords.isEmpty())
				{
					for(PlanBilling pb: ppbp.getAllPlanBillingRecords(membership))
					{
						pb.delete();
						pb.save();
					}
				}
				
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				AutorenewalCard card;
				
				//Create auto renewal card 
				if (req.getPayment().getCard().getSaveAsAutoRenewalCard())
				{
					//membership.getPrimaryMember().setRenewMethodCd("A");
					membership.getPrimaryMember().setRenewMethodCd("P");
					
					try {
						//create auto renewal card, set rider's autorenewalCard ky to the card, 
						//	and set the members' renewalMethod to primary member's renewal method. 
						card = maintBp.buildAutorenewalCard(membership, req.getPayment());
					} catch (IllegalArgumentException e) {
						throw new WebServiceException(e.getMessage());
					}
					
					if (card!=null)
					{													
						card.save();
						membership.save(true);
						//infoList.add("Membership switched to Automatic Renewal");
					}	
				}
				
				//set up payment plan and assuming the plan billing records are all created. 
				for (Member member : membership.getNonCancelledMemberList()) {
					ppbp.markMemberForPaymentPlan(member, new BigDecimal(req.getPaymentPlanKy()), new Timestamp(System.currentTimeMillis()), 1);
					member.setMemberExpirationDt(member.getActiveExpirationDt());
				}
				ppbp.applyPaymentPlan(true, membership);	
				
				membership.addComment("Successfully create plan billing records");
				membership.save();
				
				//overwrite the approval code. 
				req.getPayment().getCard().setAuthorizationNumber(approvalCode);
				
				paymentAppliedSuccessful = maintBp.applyCreditCardPaymentIPProxy(req.getPayment().getCard(), 
						paymentAmount,
						membership, 
						sa, 
						req.getPayment().getCard().getSaveAsAutoRenewalCard(), req.getPaymentPlanKy());
				
				//add the ip enrollment comment -start - [YHU - 2018/06/25]  
				String ipPlanComments = "";
				String ipPlanCommentsFormat = "Membership placed on installment plan: %s ";
				
				SortedSet<PaymentPlan> pPlans = ppbp.getActivePaymentPlans();
				for (PaymentPlan pl : pPlans) {
					if (pl.getPaymentPlanKy().toString().equals(req.getPaymentPlanKy())) {
						ipPlanComments = String.format(ipPlanCommentsFormat, pl.getPlanName());
						break;
					}
				}
				
				membership.addComment(ipPlanComments);
				//add the ip enrollment comment -end - [YHU - 2018/06/25]
				
				membership.setSafetyFundAppliedFl("N");
				
				//membership.addComment("Successfully applied the 1st payment");
				membership.save();
				
				for (PlanBilling pb: ppbp.findPlanBillingForFirstPayment(membership, 1)) {
					pb.setPaymentStatus("P");
					pb.save();
				}	
				
				//membership.addComment("Successfully marked the 1st payment as paid");
				for (Member member : membership.getNonCancelledMemberList()) {
					member.setRenewMethodAtRenewal("P");
				}
				
				membership.save();
				
				//This is copied from AutoRenewalBean - START 
				//remove the membership from ebilling enrollment if it has the flag value as true.
//				if (membership.getEbillFl() && !isInstallmentFirstPaymentRejected) {
//					membership.setEbillFl('N');
//					membership.addComment("Membership removed from ebill due to enrolling on install");
//					membership.save();
//				}
		
				//send webletter Installment Plan Enrollment to the member
				
				//TODO - email value need to be swapped back after testing.
				if (!isInstallmentFirstPaymentRejected) {
					URL letterProcessor = new URL(JavaUtilities.getBaseURL(null) +
							"/process/LetterProcessor?USER_ID="+user.userID+"&LetterCode=WEBIE&FileName=" + File.createTempFile("tmpwebpwletter", null).getName() +
							"&MEMBERSHIP_KY=" + membership.getMembershipKy() +
							//"&EmailTo=yinghuihu@gmail.com");
							"&EmailTo="+ membership.getPrimaryMember().getEmail());
					URLConnection urlConn = letterProcessor.openConnection();
					BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
					if(in.readLine() != null)
						in.close();
		
					membership.addComment("Installment email confirmation has been sent to the Member.");
					membership.save();
				}
				
				//post zero dollars. 
				BPF.get(user,PaymentPosterBP.class).postZeroDollarPayment(membership, "ZP-MakePayment", "MM", ((MemberzPlusUser)user).getBranchKy(), "Y", "A", null);
				
				DiscountBP dbp = BPF.get(user, DiscountBP.class);
				dbp.removePendingApplyDiscountRecords(membership, true); //Remove any AR discounts marked for renewal		
				
				//10/30/17: PC  -- AR discount applied at renewal is staying when the card rejection happens.So remove the AR discount
				if(membership.isPending())  /// remove AR renewal discounts
				{
					  dbp.removeARRenewalDiscount(membership);
				}
				
				BPF.get(user, AutoRenewalBP.class).removeARPromotionFromAuditTable(membership);
				
				//11/3/17 : Remove any AR required offers or the offer attached to the solicitation code entered in the make payment screen
				BPF.get(user, DiscountOfferBP.class).removeOffers(membership, null, true);
			    //This is copied from AutoRenewalBean - END 
			    
				membership.save(true);
				
				response = new ApplyPaymentResponse(returnMessage,returnCode);
				response.setErrors(null);
				response.setInfoList(infoList);			
				return response;
			} else {
				//payment failed, set the renewal method to "B"
				for (Member m: membership.getNonCancelledMemberList()) {
					m.setRenewMethodCd("B");
				}
				membership.save();
				
				response = new ApplyPaymentResponse(returnMessage,returnCode);
				response.setErrors(null);
				
				infoList.add("Failed to capture the payment");
				response.setInfoList(infoList);	
				return response;
			}
			
			//normal processing finished here and returned response.
		}
		catch (WebServiceException e){
			//revert the credit card authorization. 
			if (isCardAuthRevertable) {
				CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
				ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
				OMElement revertRes = ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
			}
			
			getLogger().error("", e);		
			response = new ApplyPaymentResponse(e.getMessage(), ERROR_CODE_APPLYPAYMENT_GENERAL);	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);
			//revert the credit card authorization. 
			try {
				if (isCardAuthRevertable) {
					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
					OMElement revertRes = ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
				}	
			} catch(Exception e1) {
				
			}
			
			response = new ApplyPaymentResponse(genWSExceptionMsg, ERROR_CODE_APPLYPAYMENT_GENERAL);
			response.setErrors(null);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);	
			if (!isInstallmentFirstPaymentRejected ) {
				if (!approvalCode.equals("")) {
					infoList.add("payment captured then exception happened.");
					response = new ApplyPaymentResponse(genWSExceptionMsg, this.RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT);
					response.setInfoList(infoList);	
				} else {
					infoList.add("payment not captured. ");
				}
			} 
			
		}
		return response;
	}
	
	
	private ApplyPaymentResponse ApplyPaymentWithCaptureIPExisting(ApplyPaymentRequest req, String debugModule) throws Exception{ 
		String DEBUG_MODULE = debugModule; //"WM_ApplyPaymentWithCapture_Existing_IP_" + Calendar.getInstance().getTimeInMillis() +"";
		
		ApplyPaymentResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		
		ApplyPaymentCreditCardValidate validationObject = null;
		
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		String sequenceNumber = null;
		BigDecimal paymentAmount = null;
		
		boolean isInstallmentPaymentFailed = false;
		String approvalCode = "";
		
		String returnCode = "0";
		String returnMessage= "Success";
		
		boolean isCardAuthRevertable = false;
		boolean paymentAppliedSuccessful = false; 
		
		MembershipServiceValidationBP msvBP = (MembershipServiceValidationBP)BPF.get(user, MembershipServiceValidationBP.class);
		
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			//validate start 
			if (msvBP.validateAndInitializeApplyPaymentWithCaptureIP(req)){
				this.user = msvBP.getUser(); 
				sa = msvBP.getSalesAgent(); 
				membership = msvBP.getMembership(); 
				sequenceNumber = req.getPayment().getCard().getSequenceNumber();
				paymentAmount = new BigDecimal(req.getPayment().getAmount());
				
				isCardAuthRevertable = true;
				
				//validate credit card data, and other request data
				validationObject = new ApplyPaymentCreditCardValidate(req.getSalesAgentID(), req.getMemberID(), 
																req.getPayment().getAmount(), req.getPayment().getCard());
				errList =  membershipUtilBP.performValidation(validationObject, APPLY_PAYMENT_VALIDATION_XML);
				
				if (errList !=null && !errList.isEmpty())
				{
					throw new WebServiceValidationException(genValidationMsg);
				}
				
				if (paymentAmount.compareTo(getInstallPlanPaymentAmount(membership, user)) != 0 
						&& paymentAmount.compareTo(membership.getBalance())!=0){
					throw new WebServiceValidationException("The amount to charge is not valid"); 
				}
				
				mubp.debug(DEBUG_MODULE, "membership id: " + membership.getMembershipId() + 
										" Credit card payment passed basic validation,  ", true);
				//validation ends. 
				
			} 
		} catch (WebServiceValidationException e ) {
			//revert the credit card authorization. 
			if (isCardAuthRevertable) {
				try {
					CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)
																	BPF.get( user, CreditCardProcessingUtilBP.class); 		
					ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
					OMElement revertRes = ccProcessorBP.revertCreditCardAuthorization(sequenceNumber, paymentAmount);
				} catch (Exception e1) {
					response = new ApplyPaymentResponse("failed to revert the authorization of cc", ERROR_CODE_APPLYPAYMENT_GENERAL);
					return response; 
				} 
			}
			
			response = new ApplyPaymentResponse(e.getMessage(), ERROR_CODE_APPLYPAYMENT_GENERAL);
			
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			infoList.add("Unable to apply payment.  " + e.getMessage());
			response.setInfoList(infoList);
			
			return response; 
		} catch(Exception e) {
			response = new ApplyPaymentResponse("Failed to validate apply payment request: " + e.getMessage(), 
												ERROR_CODE_APPLYPAYMENT_GENERAL);
			return response; 
			
		} //END of validation block. 
			
		try{

			CreditCardProcessingUtilBP ccProcessorBP = (CreditCardProcessingUtilBP)BPF.get( user, CreditCardProcessingUtilBP.class); 		
			ccProcessorBP.initConfiguration(req.getSalesAgentID(), req.getSource());
			
			OMElement captureRes = ccProcessorBP.captureCreditCard(req.getPayment(), membership.getMembershipId(), 
											paymentAmount, sequenceNumber);
			
			if(captureRes!=null && ccProcessorBP.getChildElement(captureRes, "TransactionResult") !=null){
				OMElement transactionResultOM = ccProcessorBP.getChildElement(captureRes, "TransactionResult");	
				String captureResult = ccProcessorBP.getChildElement(transactionResultOM, "ReturnCode").getText();
				
				if (captureResult.equals("0")) {
					membership.addComment("Successfully captured credit card payment inside mzp-webmember!");
					membership.save();
					
					returnCode = RETURN_CODE_APPLYPAYMENT_SUCCESS;
					returnMessage = "Success";
					
					OMElement authorizationCaptureReplyOM = ccProcessorBP.getChildElement(captureRes, "AuthorizationCaptureReply");
					approvalCode = ccProcessorBP.getChildElement(authorizationCaptureReplyOM, "ApprovalCode").getText();
						
					infoList.add("Payment in the amount of " + req.getPayment().getAmount() + 
									" has been charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
				} else {
					throw new WebServiceCreditCardPaymentException("Erro occurred during epayment cc captured "); 
				}
			} else {
				throw new WebServiceCreditCardPaymentException("No response returned from epayment capture"); 
			}
			
			//successful paid 
			if (!isInstallmentPaymentFailed) {
				//post zero dollars - copied from AutoRenewalBean. 
				BPF.get(user,PaymentPosterBP.class).postZeroDollarPayment(membership, "ZP-MakePayment", "MM", 
												((MemberzPlusUser)user).getBranchKy(), "Y", "A", null);
				
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
				AutorenewalCard card;
				
				//Create auto renewal card 
				if (req.getPayment().getCard().getSaveAsAutoRenewalCard())
				{
					try {
						//create auto renewal card, set rider's autorenewalCard ky to the card, 
						//	and set the members' renewalMethod to primary member's renewal method. 
						card = maintBp.buildAutorenewalCard(membership, req.getPayment());
					} catch (IllegalArgumentException e) {
						throw new WebServiceException(e.getMessage());
					}
					
					if (card!=null)
					{													
						card.save();
						membership.save(true);
					}	
				}
				
				//overwrite the approval code. 
				req.getPayment().getCard().setAuthorizationNumber(approvalCode);
				
				paymentAppliedSuccessful = maintBp.applyCreditCardPayment(req.getPayment().getCard(), 
						paymentAmount,
						membership, 
						sa, 
						req.getPayment().getCard().getSaveAsAutoRenewalCard());
				
				//membership.addComment("Successfully applied the 1st payment");
				membership.save();
				
				//post zero dollars. 
				BPF.get(user,PaymentPosterBP.class).postZeroDollarPayment(membership, "ZP-MakePayment", "MM", 
															((MemberzPlusUser)user).getBranchKy(), "Y", "A", null);
				
				membership.save(true);
				
				response = new ApplyPaymentResponse(returnMessage,returnCode);
				response.setErrors(null);
				response.setInfoList(infoList);			
				
				//return response at the end of function ; 
			} 
		} catch(WebServiceCreditCardPaymentException e) {
			infoList.add("Unable to charged to the credit card associated with token " + req.getPayment().getCard().getTokenNumber());
			
			response = new ApplyPaymentResponse("Credit card payment not capture successfully: " + e.getMessage(), 
									RETURN_CODE_APPLYPAYMENT_FAIL_CREDITCARD_CAPTURE);
			response.setErrors(null);
			response.setInfoList(infoList);
						
		} catch (Exception e) {
			response = new ApplyPaymentResponse(genWSExceptionMsg, ERROR_CODE_APPLYPAYMENT_GENERAL);
			response.setErrors(null);
				
			if (!isInstallmentPaymentFailed ) {
				if (!approvalCode.equals("")) {
					infoList.add("payment captured then exception happened.");
					response = new ApplyPaymentResponse(genWSExceptionMsg, 
													RETURN_CODE_APPLYPAYMENT_FAIL_APPLYPAYMENT);
					response.setInfoList(infoList);	
				} else {
					infoList.add("payment not captured. ");
				}
			}
			response.setInfoList(infoList);
		}
		return response;
	}
	
	/**
	 * For SOA service Get Memebrship Component Dues */
	@SuppressWarnings("static-access")
	public GetMembershipComponentDuesResponse GetMembershipComponentDues(GetMembershipComponentDuesRequest req) throws Exception{
		
		GetMembershipComponentDuesResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		GetMembershipComponentDuesValidate validationObject = null;
		Membership membership = null;
		MembershipNumber mn =  null;
		SalesAgent sa = null;
		
		String DEBUG_MODULE = "SOA_GetMembershipComponentDues_" + Calendar.getInstance().getTimeInMillis() +"";
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Get Membership Component Dues");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}
			
			//validate
			validationObject = new GetMembershipComponentDuesValidate(req.getSalesAgentID(), req.getMemberID());
			
			errList =  membershipUtilBP.performValidation(validationObject, GET_MEMBERSHIP_COMPONENT_DUES_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			try
			{
				MembershipServiceBP serviceBp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
				String salesAgentId = "";
                if(req.getSalesAgentID() !=null && !req.getSalesAgentID().equals(""))
                {
                       salesAgentId = req.getSalesAgentID();
                }
                else
                {
                       salesAgentId =   serviceBp.getSetting("defaultSalesAgent");
                }
                sa = serviceBp.getSalesAgent(salesAgentId); 

//				sa = new SalesAgent(user, req.getSalesAgentID().toUpperCase());
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			catch (Exception e)
			{
				mubp.debug(DEBUG_MODULE, "Get Membership Component Dues exception: invalid salesagent: " + req.getSalesAgentID(), true);
				throw new WebServiceException(genInvalidAgentId);
			}
			
			//Get membership based on member id passed in
			try
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				
				mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//Find Membership
			try
			{
				membership = new Membership(user, mn.getMembershipID());
			}
			catch (ObjectNotFoundException onfe)
			{
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
			catch (Exception e)
			{
				getLogger().error(e.getMessage(), e);
				throw new WebServiceException(genMembershipNotFoundMsg);
			}
						
			//initialize counts and objects
			MembershipComponentDues membershipCompDues = getDefaultMembershipComponentDues();
			BigDecimal membershipTotalDues = BigDecimal.ZERO;
			BigDecimal memberTotalDues = null;
			ArrayList<MemberComponentDues> memberCompDuesList = new ArrayList<MemberComponentDues>();
			ArrayList<Rider> riders = null;
			ArrayList<Fee> fees = null;
			ArrayList<Donation> donations = null;
			DiscountBP dbp = BPF.get(user, DiscountBP.class);
			HashMap<BigDecimal, BigDecimal> riderCostMap = dbp.getRiderAmountDueMinusDiscounts(membership);
			
			//Code below was taken from makePayment.jsp with some adjustments
			for (Member m:membership.getMemberList())
			{
				if (m.isCancelled()) continue;
				if ("N".equals(m.getRenewMethodCd()) && m.isFutureCancel() && areAllMemberRidersFutureCancel(m) && m.amountDue().compareTo(BigDecimal.ZERO) == 0) continue;
				if (m.inRenewal() && areAllMemberRidersDoNotRenew(m) && m.amountDue().compareTo(BigDecimal.ZERO) == 0) continue;
			    
			    //initialize collections
			    riders = new ArrayList<Rider>();
		    	fees = new ArrayList<Fee>();
		    	donations = new ArrayList<Donation>();
		    	
			    //set member information
			    MemberComponentDues mcd = new MemberComponentDues();
			    mcd.setMember(getSimpleMemberFromMember(m));
			    memberTotalDues = BigDecimal.ZERO;
			    
			    //set fees and rider information
			    for (PayableComponent pc : m.getNonCanceledPayableComponentList())
			    {
			    	//If member is inRenewal, and rider isDoNotRenew, and rider's amount due equals zero, then remove rider.
			    	if (m.inRenewal() && pc instanceof com.rossgroupinc.memberz.model.Rider &&
			    			((com.rossgroupinc.memberz.model.Rider)pc).isDoNotRenew() &&
			    			((com.rossgroupinc.memberz.model.Rider)pc).amountDue().compareTo(BigDecimal.ZERO) == 0) continue;
			    	//If member is new, and rider's Future Cancel date is today or earlier, and rider's amount due equals zero, then remove rider.
			    	if ("N".equals(m.getRenewMethodCd()) && pc instanceof com.rossgroupinc.memberz.model.Rider &&
			    			DateUtilities.getTimeStamp(true).compareTo((((com.rossgroupinc.memberz.model.Rider)pc).getFutureCancelDt())) <= 0 &&
			    			((com.rossgroupinc.memberz.model.Rider)pc).amountDue().compareTo(BigDecimal.ZERO) == 0) continue;
			    	
			    	BigDecimal amountDue = ((pc instanceof com.rossgroupinc.memberz.model.Rider) || (pc instanceof MembershipFees)) ? riderCostMap.get(pc.getKey()).setScale(2) : pc.amountDue().setScale(2);
			    	
			    	boolean inBill = pc.getAttribute("ARPENDING") != null && ((Boolean)pc.getAttribute("ARPENDING")).booleanValue();
			        if (!inBill) {      
			        	membershipTotalDues = membershipTotalDues.add(amountDue).setScale(2);
			        	memberTotalDues = memberTotalDues.add(amountDue).setScale(2);
			        }
			        
			        //set Rider
			        if(pc instanceof com.rossgroupinc.memberz.model.Rider)
			        {
			        	riders.add(getRiderFromRider((com.rossgroupinc.memberz.model.Rider)pc, amountDue));
			        }
			        
			        //set Fee
			        if(pc instanceof MembershipFees)
			        {
			        	fees.add(getFeeFromMembershipFees((MembershipFees)pc, amountDue));
			        }
			        
			        //set Donations
			        if(pc instanceof DonationHistory)
			        {
			        	donations.add(getDonationFromDonationHistory((DonationHistory)pc, amountDue));
			        }
			    }
			    
			    //set fees, riders, and subtotal for MemberComponentDues
			    if(fees.size() > 0)
			    	mcd.setFees(fees.toArray(new Fee[0]));
			    
			    if(riders.size() > 0)
			    	mcd.setRiders(riders.toArray(new Rider[0]));
			    
			    if(donations.size() > 0)
			    	mcd.setDonations(donations.toArray(new Donation[0]));
			    
			    mcd.setTotalAmountDue(memberTotalDues);
			    memberCompDuesList.add(mcd);			    
			}
			
			//calculate membership totals.  This code is from makePayment.jsp
			membershipCompDues.setSubTotalAmountDue(membershipTotalDues.setScale(2,BigDecimal.ROUND_HALF_UP));
			
			if(membership.getUnappliedAt().compareTo(BigDecimal.ZERO) > 0 || membership.getBalance().compareTo(membershipTotalDues) != 0)
			{				
				if(membership.getUnappliedAt().compareTo(BigDecimal.ZERO) != 0)
				{
					membershipCompDues.setUnappliedAmount(membership.getUnappliedAt().setScale(2,BigDecimal.ROUND_HALF_UP));
				}
				
				if(membership.getBalance().compareTo(membershipTotalDues) != 0)
				{
					membershipCompDues.setPendingCreditAmount(membershipTotalDues.subtract(membership.getBalance().setScale(2,BigDecimal.ROUND_HALF_UP)));
				}
			}
			
			membershipCompDues.setTotalAmountDue(membershipTotalDues.setScale(2,BigDecimal.ROUND_HALF_UP));
			
			if(memberCompDuesList.size() > 0)
				membershipCompDues.setMemberComponentDues(memberCompDuesList.toArray(new MemberComponentDues[0]));
			
			response = new GetMembershipComponentDuesResponse("SUCCESS","0");
			response.setMembershipComponentDues(membershipCompDues);
			
			String coverageLevel = getFutureDNRMembershipCoverageLevel(membership);
			if(coverageLevel != null)
			{
				response.setMembershipCoverageLevel(membershipUtilBP.getCoverageByMZPType(coverageLevel));
			}
			else
			{
				response.setMembershipCoverageLevel(membershipUtilBP.getCoverageByMZPType(membership.getCoverageLevelCd()));
			}
			response.setErrors(null);
			response.setInfoList(infoList);			
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new GetMembershipComponentDuesResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new GetMembershipComponentDuesResponse(genWSExceptionMsg, "1");
			response.setErrors(null);
			infoList.add("Unable to get membership component dues.  " + e.getMessage());
			response.setInfoList(infoList);	
		}
		
		return response;
	}
	
	 /** For SOA service Reset Member Web Password */
	@SuppressWarnings("static-access")
	public ResetMemberWebPasswordResponse ResetMemberWebPassword(ResetMemberWebPasswordRequest req) throws Exception
	{
		
		ResetMemberWebPasswordResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		ResetMemberWebPasswordValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Reset Member Web Password");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			Member member = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new ResetMemberWebPasswordValidate(req.getSalesAgentID(), req.getMemberID(), req.getEmailAddress());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, RESET_MEMBER_WEB_PASSWORD_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = new SalesAgent(user, req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				member = membership.getMember(mn.getAssociateID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			//check digit
			if(!member.getCheckDigitNr().equals(new BigDecimal(mn.getCheckDigit())))
			{
				throw new WebServiceException(getMemberMismatch);
			}
			
			if(!StringUtils.blanknull(member.getEmail()).equalsIgnoreCase(req.getEmailAddress())){
				throw new WebServiceException(getMemberEmailNotMatched);
			}

			if("C".equals(member.getStatus())){
				throw new WebServiceException("Password reset is not allowed. Member is cancelled.");
			}
			
			//check if a web profile exists
			if(StringUtils.blanknull(member.getWebPassword()).length() == 0 || member.getWebDisabledFl()){
				throw new WebServiceException("Password reset is not allowed. Web Profile does not exist or is disabled");
			}
			
			//Reset password
			String randPWord = StringUtils.getRandomString(10);
			
			member.setWebPassword(randPWord);
			member.setWebPasswordSetDt(DateUtilities.getTimestamp(false));
			member.setWebPasswordMustSetFl(true);
			member.setWebDisabledFl(false);
			
			String comment = "Member requested a password reset by email.";
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comment += "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource());
			}
			membership.addComment(comment);
			membership.save();
						
			//send email update	
			URL letterProcessor = new URL(JavaUtilities.getBaseURL(null) + 
					"/process/LetterProcessor?USER_ID="+user.getGenericUser().userID+"&LetterCode=CMSTPW&FileName=" + File.createTempFile("tmpwebpwletter", null).getName() + 
					"&MEMBER_KY=" + member.getMemberKy() + 
					"&PASSWORD=" + randPWord +
					"&EmailTo="+member.getEmail());

			URLConnection urlConn = letterProcessor.openConnection();						
			BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
			if(in.readLine() != null)
				in.close();
			
			response = new ResetMemberWebPasswordResponse("SUCCESS","0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new ResetMemberWebPasswordResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new ResetMemberWebPasswordResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to reset member web password! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response;
	}

	//this is used by Enroll as a proxy method to EnrollMembershipInEBilling 
	private EnrollMembershipInEBillingResponse EnrollMembershipInEBilling (Membership ms, MembershipEnrollRequest enrollReq) throws Exception {
		EnrollMembershipInEBillingResponse response = null;
		EnrollMembershipInEBillingRequest req = new EnrollMembershipInEBillingRequest();
		req.setEmailAddress(enrollReq.getSimpleMembership().getPrimaryMember().getEmail());
		
		//This might be needed down the road
		req.setMarketCode(enrollReq.getSimpleMembership().getMarketCode());
		SimpleMembershipNumber smn = new SimpleMembershipNumber();
		smn.setFullNumber("438212" + ms.getPrimaryMember().getMembershipId() + ms.getPrimaryMember().getAssociateId() + ms.getPrimaryMember().getCheckDigitNr());
		
		req.setMemberID(smn);
		req.setSalesAgentID(enrollReq.getAgentId());
		
		boolean bSendNotification = false;
		if (enrollReq.getEbillingEmailNotificationFlag()!=null && enrollReq.getEbillingEmailNotificationFlag().trim().equalsIgnoreCase("YES")){
			bSendNotification = true;
		} 
		
		//enroll doesn't need email confirmation anymore, turn it off
		//req.setSendEmailConfirmation(bSendNotification);
		req.setSendEmailConfirmation(false);
		
		req.setSource(enrollReq.getSource());
		
		try {
			response = EnrollMembershipInEBilling(req);
		} catch (Exception e) {
			
		}
		
		return response;
	}
	
	private void sendEnrollConfirmationEmail(Membership membership, MembershipEnrollRequest enrollReq) throws Exception {
		boolean isDonorMembership = false ;
		com.rossgroupinc.memberz.model.Donor donor = null;
		String donorEmail = "";
		
		if (enrollReq.isDonorMembership() && enrollReq.getDonor()!=null) {
			isDonorMembership = true;
			String donorNumber = nvl(enrollReq.getDonor().getDonorNumber());
			donorEmail = nvl(enrollReq.getDonor().getEmail());

			if (!donorNumber.equals("")) {
	        	donor = new com.rossgroupinc.memberz.model.Donor(User.getGenericUser(), donorNumber, true);
	        }
		}
		
		SimpleMembership simpleMembership = enrollReq.getSimpleMembership(); 
		
		//get primary member email  
		SimplePrimaryMember smPrimaryMember = simpleMembership.getPrimaryMember();
		String pmEmail = smPrimaryMember.getEmail();
		
		if (!isDonorMembership) {
			
			WebLetterBP webLetterBP = (WebLetterBP) BPF.get(user, WebLetterBP.class);
			webLetterBP.sendJoinConfirmationLetter(pmEmail, membership, null);
			
			membership.addComment("Join confirmation email has been sent to the Member.");
			membership.save();
			
			String renewMethod = enrollReq.getSimpleMembership().getRenewalMethod();
			if (renewMethod.equalsIgnoreCase("INSTALLMENT PLAN")) {
				webLetterBP.sendInstallEnrollLetter(pmEmail, membership, null, null);
				
				membership.addComment("Installment Plan Join confirmation email has been sent to the Member.");
				membership.save();
			}
		} else {
			String renewMethod = enrollReq.getSimpleMembership().getRenewalMethod();
			
			//AUTOMATIC RENEWAL confirmation email 
			if (renewMethod.equalsIgnoreCase("AUTOMATIC RENEWAL")) {
				WebLetterBP webLetterBP = (WebLetterBP) BPF.get(user, WebLetterBP.class);
				webLetterBP.sendGiftAutomaticRenewalEnrollConfirmationLetter(donorEmail, membership, donor, null);
				
				membership.addComment("Join confirmation AR email has been sent to the Donor.");
				membership.save();
				
				webLetterBP.sendGiftJoinConfirmationLetter(donorEmail, membership, donor, null);
				
				membership.addComment("Join confirmation email has been sent to the Donor.");
				membership.save();
				
			} else {
				WebLetterBP webLetterBP = (WebLetterBP) BPF.get(user, WebLetterBP.class);
				webLetterBP.sendGiftJoinConfirmationLetter(donorEmail, membership, donor, null);
				
				membership.addComment("Join confirmation email has been sent to the Donor.");
				membership.save();
			}
		}
		
	}
	
	/** For SOA service Enroll Membership In Ebilling */
	@SuppressWarnings("static-access")
	public EnrollMembershipInEBillingResponse EnrollMembershipInEBilling(EnrollMembershipInEBillingRequest req) throws Exception
	{
		
		EnrollMembershipInEBillingResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		EnrollMembershipInEbillingValidate validationObject = null;
		SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Enroll Membership In Ebilling");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			Member pMember = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new EnrollMembershipInEbillingValidate(req.getSalesAgentID(), req.getMemberID(), req.getEmailAddress(), req.getMarketCode());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, ENROLL_MEMBERSHIP_IN_EBILL_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = new SalesAgent(user, req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				pMember = membership.getPrimaryMember();
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			if(membership.getEbillFl())
			{
				throw new WebServiceException("Membership already on ebilling.");
			}
			
			//update email address
			if(hasValueChanged(pMember.getEmail(), req.getEmailAddress()))
			{
				try //handle duplicate email if any
				{
					pMember.setEmail(req.getEmailAddress());
				}
				catch(SQLException e)
				{
					throw new WebServiceException(e.getMessage());
				}
				membership.addComment("Via web member, Ebilling Email address changed from: "+membership.getEbillEmail()+ " to: "+ req.getEmailAddress());
			}
			
			//Enrolling membership to ebill
			membership.setEbillFl("Y");
			membership.setTermsFl("Y");
			membership.setEbillLastUpdDt(new Timestamp(System.currentTimeMillis()));
			membership.setTermsLastUpdDt(new Timestamp(System.currentTimeMillis()));
			
			//send confirmation email
			if(req.isSendEmailConfirmation())
			{
				URL letterProcessor = new URL(JavaUtilities.getBaseURL(null) + 
						"/process/LetterProcessor?USER_ID="+User.getGenericUser().userID+"&LetterCode=EBELET&FileName=" + File.createTempFile("tmpwebpwletter", null).getName() + 
						"&MEMBERSHIP_ID=" + membership.getMembershipId() +
						"&EmailTo="+ req.getEmailAddress());
				URLConnection urlConn = letterProcessor.openConnection();						
				BufferedReader in = new BufferedReader(new InputStreamReader(urlConn.getInputStream()));
				if(in.readLine() != null)
					in.close();	
				membership.addComment("eBilling email confirmation has been sent to the Member, changes via web member.");
			}
			
			membership.addComment("Membership "+ membership.getMembershipId() + " placed on Electronic Billing on "+ format.format(DateUtils.now()).toString() + " via web member");
			membership.addComment("Member agreed to E-Notice Terms and Conditions on "+ format.format(DateUtils.now()).toString() + " via web member");
			
			//segmentation
			if (membership.getSegmentationSetupKy()!=null){ 	/*take off of segmentation if on segmentation*/
				SegmentationSetup segSetup = new SegmentationSetup(User.getGenericUser(),membership.getSegmentationSetupKy());  /*add the comments*/
				membership.addComment("Membership signed up for e-bill and has been removed from " + segSetup.getName() + " in the " + membership.getSegmentationCd() + " panel.");			/*write a membership comment*/
				membership.setSegmentationCd(null);															/*clear out the segmentation code and setup ky*/
				membership.setSegmentationSetupKy(null);
			}
			
			//market code
			if (req.getMarketCode() != null)
			{
				membership.setPromoCode(req.getMarketCode());
				membership.addComment("Membership eBilling promo code is: " + req.getMarketCode());
			}
			
			pMember.save();
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				//membership.addComment("\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource()));
			}
			membership.save();			
			response = new EnrollMembershipInEBillingResponse("SUCCESS","0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new EnrollMembershipInEBillingResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new EnrollMembershipInEBillingResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to enroll membership in ebilling! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response;
	}
	
	/** For SOA service Remove Membership From Ebilling */
	@SuppressWarnings("static-access")
	public RemoveMembershipFromEBillingResponse RemoveMembershipFromEBilling(RemoveMembershipFromEBillingRequest req) throws Exception
	{
		
		RemoveMembershipFromEBillingResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		RemoveMembershipFromEbillingValidate validationObject = null;
		SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyyy");
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Remove Membership From Ebilling");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new RemoveMembershipFromEbillingValidate(req.getSalesAgentID(), req.getMemberID());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, REMOVE_MEMBERSHIP_FROM_EBILL_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = new SalesAgent(user, req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			if(!membership.getEbillFl())
			{
				throw new WebServiceException("Membership is not enrolled in ebilling.");
			}
			
			//Remove membership from ebilling			
			membership.setEbillFl("N");
			membership.setTermsFl("N");
			membership.setEbillLastUpdDt(new Timestamp(System.currentTimeMillis()));
			membership.setTermsLastUpdDt(new Timestamp(System.currentTimeMillis()));
			String comments = "Membership "+ membership.getMembershipId() + " taken off of E-Billing on "+ format.format(DateUtils.now()).toString(); 
			
			if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource())))
			{
				comments = comments + " via " + membershipUtilBP.getMzPSourceCommentByWsSource(req.getSource()); 
			}
			membership.addComment(comments);
			
			membership.save();			
			response = new RemoveMembershipFromEBillingResponse("SUCCESS","0");
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new RemoveMembershipFromEBillingResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);	
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new RemoveMembershipFromEBillingResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to remove membership from ebilling! -- " + e.getMessage());
			response.setInfoList(infoList);	
		}
		return response;
	}
	
	/** For SOA service Is Membership Enrolled in Ebilling */
	@SuppressWarnings("static-access")
	public IsMembershipEnrolledInEBillingResponse IsMembershipEnrolledInEBilling(IsMembershipEnrolledInEBillingRequest req) throws Exception
	{
		
		IsMembershipEnrolledInEBillingResponse response = null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		IsMembershipEnrolledInEbillingValidate validationObject = null;
		
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Is Membership Enrolled in Ebilling");
				getLogger().debug(" Request: " + req.getMemberID().getFullNumber());		
				getLogger().debug("**************************\n");			
			}			
			
			Membership membership = null;
			MembershipNumber mn =  null;
			
			//validate
			validationObject = new IsMembershipEnrolledInEbillingValidate(req.getSalesAgentID(), req.getMemberID());
			
			//validation of the xml
			errList =  membershipUtilBP.performValidation(validationObject, IS_MEMBERSHIP_ENROLLED_IN_EBILL_VALIDATION_XML);
			
			if (errList !=null && !errList.isEmpty())
			{
				throw new WebServiceException(genValidationMsg);
			}
			
			//Get Sales Agent
			SalesAgent sa = new SalesAgent(user, req.getSalesAgentID());
			if(sa == null) {
				throw new Exception (genInvalidAgentId);
			}
			else
			{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));				
			}
			
			//Get membership based on member id passed in
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				try
				{
					mn =  mbp.parseFullMembershipNumber(req.getMemberID().getFullNumber());
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + req.getMemberID().getFullNumber());
			}
			
			response = new IsMembershipEnrolledInEBillingResponse("SUCCESS","0");
			if(membership.getEbillFl())
			{
				response.setEnrolledInEBilling(true);
			}
			else
			{
				response.setEnrolledInEBilling(false);
			}
			
		}
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new IsMembershipEnrolledInEBillingResponse(e.getMessage(), "1");	
			if(errList !=null && !errList.isEmpty())
			{
				response.setErrors(errList);
			}
			response.setErrors(errList);
			response.setInfoList(infoList);
			response.setEnrolledInEBilling(false);
		}
		catch (Exception e) {
			getLogger().error("", e);			
			response = new IsMembershipEnrolledInEBillingResponse(genWSExceptionMsg, "1");	
			response.setErrors(null);
			infoList.add("Failed to determine if membership is enrolled in ebilling! -- " + e.getMessage());
			response.setInfoList(infoList);
			response.setEnrolledInEBilling(false);
		}
		return response;
	}
	
	
	/**
	 * Utility functions go BELOW this comment 
	 **/
	  
	@SuppressWarnings("unused")
	public SalesAgent getSalesAgent(String salesAgentId)
    {
    	SalesAgent sa = null;
    	try
    	{
    		sa = new SalesAgent(user, salesAgentId);         	
    		if(sa == null) {
    			salesAgentId = this.getSetting("defaultSalesAgent");
    			sa = new SalesAgent(user, salesAgentId); 
    		}
    	}
    	catch (Exception e)
    	{
    		log.error("Unable to configure sales agent based on Agent Id : " + salesAgentId);
    	}
    	
		return sa;
    }
	
	private User getUser(User genericUser){
		User result = null;
		try {
			BigDecimal webserviceId = ClubProperties.getBigDecimal("WebServicesID", null, null);
            result = User.getUserByUserID(webserviceId.toString());

		}
		catch(Exception e){
			getLogger().error("Unable to retrieve user object, please check your configuration");
			getLogger().error(StackTraceUtil.getStackTrace(e));
		}
		return result;
	}
	
	private SimpleMember getSimpleMemberFromMember(Member m) throws SQLException
	{
		SimpleMember sm = new SimpleMember();
		sm.setAssociateType(membershipUtilBP.getAssociateTypeByMZPType(m.getMemberTypeCd()));
		if(m.getCustomerId() != null)
		{
			sm.setCustomerId(m.getCustomerId().toString() );
		}
		sm.setDateOfBirth(DateUtilities.asString(m.getBirthDt()));
		sm.setJoinAAADate(DateUtilities.asString(m.getJoinAaaDt()));
		sm.setEmail(m.getEmail());
		sm.setGender(membershipUtilBP.getGenderByMZPType(m.getGender()));
		try
		{
			int gradYear;
			gradYear = Integer.parseInt(m.getGraduationYr());
			sm.setGraduationYear(gradYear);
		}
		catch (Exception ignore){}
		Name name = new Name();
		name.setFirstName(m.getFirstName());
		name.setLastName(m.getLastName());
		name.setMiddleName(m.getMiddleName());
		name.setSuffix(membershipUtilBP.getSuffixByMZPType(m.getNameSuffix()));
		name.setTitle(membershipUtilBP.getSalutationByMZPType(m.getSalutation()));

		sm.setName(name);
		SimpleMembershipNumber mbrshipNumber = new SimpleMembershipNumber();
		mbrshipNumber.setNumber(m.getMembershipId());
		mbrshipNumber.setAssociateId(m.getAssociateId());
		sm.setNumber(mbrshipNumber);
		sm.setRelation(membershipUtilBP.getRelationByMZPType(m.getAssociateRelationCd()));

		SortedSet<MemberCode> assocMbrCodesList = m.getMemberCodeList();
		if (assocMbrCodesList !=null && assocMbrCodesList.size() > 0)
		{
			for(MemberCode code :  assocMbrCodesList)
			{				
				if(code.getCode().equals("DNAE"))
					sm.setDoNotAskForEmail(true);
				else if(code.getCode().equals("DNE"))
					sm.setDoNotEmail(true);
				else if(code.getCode().equals("DNC"))
					sm.setDoNotCall(true);
				else if(code.getCode().equals("DNM"))
					sm.setDoNotMail(true);
				 
			}
		}
		
		return sm;
	}
	
	private Rider getRiderFromRider(com.rossgroupinc.memberz.model.Rider r, BigDecimal amountDue) throws SQLException
	{
		Rider rOut = new Rider();
		
		rOut.setAmountDue(amountDue);
		rOut.setCostEffectiveDate(DateUtilities.asString(r.getCostEffectiveDt()));
		rOut.setDescription(r.getIdentifier());
		rOut.setDuesAdjustmentAmount(r.getDuesAdjustmentAt().setScale(2));
		rOut.setDuesCostAmount(r.getDuesCostAt().setScale(2));
		rOut.setEffectiveDate(DateUtilities.asString(r.getEffectiveDt()));
		rOut.setFutureCancelCreditAmount(r.getFutureCancelCreditAt().setScale(2));
		rOut.setOriginalCostAmount(r.getAdmOriginalCostAt().setScale(2));
		rOut.setPaymentAmount(r.getPaymentAt().setScale(2));
		rOut.setStatus(membershipUtilBP.getStatusByMZPType(r.getStatus()));
		rOut.setType(membershipUtilBP.getRiderCompCodeByMZPType(r.getRiderCompCd()));
		
		return rOut;
		
	}
	
	private Fee getFeeFromMembershipFees(MembershipFees mf, BigDecimal amountDue) throws SQLException
	{
		Fee fee = new Fee();
		
		fee.setAmountDue(amountDue);
		fee.setCostEffectiveDate(DateUtilities.asString(mf.getCostEffectiveDt()));
		fee.setDescription(mf.getIdentifier());
		fee.setDuesAdjustmentAmount(mf.getDuesAdjustmentAt().setScale(2));
		fee.setDuesCostAmount(mf.getDuesCostAt().setScale(2));
		fee.setEffectiveDate(DateUtilities.asString(mf.getEffectiveDt()));
		fee.setFutureCancelCreditAmount(mf.getFutureCancelCreditAt().setScale(2));
		fee.setOriginalCostAmount(mf.getAdmOriginalCostAt().setScale(2));
		fee.setPaymentAmount(mf.getPaymentAt().setScale(2));
		fee.setStatus(membershipUtilBP.getStatusByMZPType(mf.getStatus()));
		fee.setType(mf.getFeeType());
		fee.setWaived(mf.getWaivedFl());
		
		return fee;
		
	}
	
	private Donation getDonationFromDonationHistory(DonationHistory dh, BigDecimal amountDue) throws SQLException
	{
		Donation d = new Donation();
		
		d.setAmountDue(amountDue);
		d.setCostEffectiveDate(DateUtilities.asString(dh.getCostEffectiveDt()));
		d.setDescription(dh.getIdentifier());
		d.setDuesAdjustmentAmount(dh.getDuesAdjustmentAt().setScale(2));
		d.setDuesCostAmount(dh.getDuesCostAt().setScale(2));
		d.setEffectiveDate(DateUtilities.asString(dh.getEffectiveDt()));
		d.setFutureCancelCreditAmount(dh.getFutureCancelCreditAt().setScale(2));
		d.setOriginalCostAmount(dh.getAdmOriginalCostAt().setScale(2));
		d.setPaymentAmount(dh.getPaymentAt().setScale(2));
		d.setStatus(membershipUtilBP.getStatusByMZPType(dh.getStatus()));
		
		return d;
		
	}
	
	private MembershipComponentDues getDefaultMembershipComponentDues()
	{
		MembershipComponentDues mcd = new MembershipComponentDues();
		
		mcd.setPendingCreditAmount(BigDecimal.ZERO.setScale(2));
		mcd.setSubTotalAmountDue(BigDecimal.ZERO.setScale(2));
		mcd.setTotalAmountDue(BigDecimal.ZERO.setScale(2));
		mcd.setUnappliedAmount(BigDecimal.ZERO.setScale(2));
		
		return mcd;
	}

	private boolean isEnrollmentEmailDuplicated (MembershipEnrollRequest enrollReq){
		boolean result = false;
		
		try {
			if (enrollReq ==null || enrollReq.getSimpleMembership() == null || enrollReq.getSimpleMembership().getPrimaryMember() == null) {
				return result;
			}
			
			SimpleMembership simpleMembership = enrollReq.getSimpleMembership(); 
			//Primary member email handling. 
			SimplePrimaryMember smPrimaryMember = simpleMembership.getPrimaryMember();
			String email = smPrimaryMember.getEmail();
			if (email!=null && !email.trim().equals("")) {
				result = memberEmailCheckBP.isEmailDuplicated(email,null, null);
			}
			
			//if the primary member has the duplicated email, return here. 
			if (result) {
				return result;
			} else {
				if (simpleMembership.getAssociates()==null || simpleMembership.getAssociates().length ==0 ) {
					return result;
				}
				
				//otherwise, loop through the associates and check duplicated email. 
				for (SimpleAssociateMember sam:simpleMembership.getAssociates()){
					//Validate this email below
					String emailAssociate = sam.getEmail();
					if (emailAssociate!=null && !emailAssociate.trim().equals("")) {
						result = memberEmailCheckBP.isEmailDuplicated(emailAssociate, null, null);
					}
					
					if (result) {
						return result;
					}
				}
			}
			
			
		} catch(Exception e) {
			//ignore the exception and return false; 
		}
		
		return false;
	}
	
	private boolean areEmailAddressFlagsSpecified(SimpleMembership membership)
	{
		boolean result = false;
		
		if(membership == null || membership.getPrimaryMember() == null)
			return result;
		
		SimplePrimaryMember primary = membership.getPrimaryMember();
		
		//if either NoEmail XOR EmailRefused is true and email address not specified return true
		try{
			if(primary.getEmail() == null || primary.getEmail().trim().length() == 0)
			{
				if( (primary.getIsEmailRefused() != null && primary.getIsEmailRefused().booleanValue()) ^
					(primary.getIsNoEmail() != null && primary.getIsNoEmail().booleanValue()) )
				{
					result = true;
				}
			}
			else
			{
				result = true;
			}
		}
		catch(Exception e){	}
		
		return result;
	}

	private boolean areAllMemberRidersDoNotRenew(Member member) throws Exception
	{
		for(PayableComponent pc : member.getNonCanceledPayableComponentList())
		{
			if(pc instanceof com.rossgroupinc.memberz.model.Rider && !((com.rossgroupinc.memberz.model.Rider)pc).isDoNotRenew())
			{
				return false;
			}
		}
		return true;
	}
	
	private boolean areAllMemberRidersFutureCancel(Member member) throws Exception
	{
		for(PayableComponent pc : member.getNonCanceledPayableComponentList())
		{
			if(pc instanceof com.rossgroupinc.memberz.model.Rider &&
					DateUtilities.getTimeStamp(true).after(((com.rossgroupinc.memberz.model.Rider)pc).getFutureCancelDt()))
			{
				return false;
			}
		}
		return true;
	}
	
	private boolean validateUpgradeCoverageOrAddMember(int associateCount, Membership ms, String coverageCD) throws WebServiceException {
		//This function is trying to validate upgrade coverage only or add associate only to eliminate the complexity of dues calculation
		//of combination of this 2
		
		boolean result = false;
		
		try {
			if (associateCount>0) {
				if (ms.getCoverageLevelCd().trim().equalsIgnoreCase(coverageCD)) {
					//add associate only
					result = true;
				} else {
					throw new WebServiceException("Please don't add associate and upgrade coverage at the same time");	
				}
			} else {
				//associate == 0 and further validation rule can be implemented here to validate upgrade only
				if (!ms.getCoverageLevelCd().trim().equalsIgnoreCase(coverageCD)) {
					result = true;
				} else {
					throw new WebServiceException("Need to add associate or upgrade coverage.");
				}
			}
		} catch (Exception e) {
			throw new WebServiceException(e.toString());
		}
		 
		return result;
	}
	
	private boolean validateZipCode(String zipCode) throws WebServiceException, SQLException, NamingException, ValueObjectException{
		//zipCode
		if(zipCode == null){
			throw new WebServiceException("Zip code is required");
		} else if (StringUtils.makeNumeric(zipCode).length() != 5){
			throw new WebServiceException("Zip code " + zipCode + " is not valid");
		}
		Validator v = new Validator();
		v.add("ZIP");
		v.setFormatType("ZIP", Validator.ZIP_FMT);

		if(!v.validate("ZIP", zipCode)){
			throw new WebServiceException("Zip code " + zipCode + " is not valid");
		}
		String validZip = null;
		validZip = membershipUtilBP.zipInTerritory(user, zipCode);
		if (validZip != "SUCCESS"){
			throw new WebServiceException("Zip code " + zipCode + " is outside of club territory");
		}
		
		return true;
	}
	
	private boolean validateZipCode(String zipCode, String membershipID) throws WebServiceException, SQLException, NamingException, ValueObjectException{
		//zipCode
		if(zipCode == null){
			throw new WebServiceException("Zip code is required");
		} else if (StringUtils.makeNumeric(zipCode).length() != 5){
			throw new WebServiceException("Zip code " + zipCode + " is not valid");
		}
		Validator v = new Validator();
		v.add("ZIP");
		v.setFormatType("ZIP", Validator.ZIP_FMT);

		if(!v.validate("ZIP", zipCode)){
			throw new WebServiceException("Zip code " + zipCode + " is not valid");
		}
		
		//if membership is null , which means it is new membership, need to do in territory check. 
		if (membershipID ==null || membershipID.trim().equals("")){
			String validZip = null;
			
			validZip = membershipUtilBP.zipInTerritory(user, zipCode);
			if (validZip != "SUCCESS"){
				throw new WebServiceException("Zip code " + zipCode + " is outside of club territory");
			}
		}
		return true;
	}
	
	private boolean validateAssociateCount(int associateCount) throws WebServiceException{
		//associate count
		if(associateCount < 0 || associateCount > 99){
			throw new WebServiceException("Associate count must be between 0 and 99");
		}		
		return true;
	}
	
	
	private Logger getLogger(){
		if(log == null){
			log = LogManager.getLogger(MembershipServiceBP.class.getName(), new RGILoggerFactory());
		}
		return log;
	}
	
	//YH - keep this method for existing logic. 
	protected boolean hasValueChanged(String currentValue, String newValue)
	{
		return hasValueChanged(currentValue, newValue, deleteWhenValuesAreEmpty);
		
		/*
		if(newValue != null && newValue.trim().length() == 0 && deleteWhenValuesAreEmpty)
		{
			return true;  //allow empty values to "delete" only when specified.
		}
		if(newValue == null || newValue.trim().length() == 0)
			return false;  //we don't want to overwrite existing data with no data
		
		if(currentValue != null && currentValue.trim().length() > 0)
			return !currentValue.trim().equalsIgnoreCase(newValue.trim());
		
		if(currentValue == null && newValue != null && newValue.trim().length() > 0)
			return true;
		
		return false;
		*/
	}
	
	
	//YH - new overloading method to provide flexibility. 
	protected boolean hasValueChanged(String currentValue, String newValue, boolean canDelete)
	{
		newValue = formatString(newValue);
		currentValue = formatString(currentValue);
		
		if (newValue.equalsIgnoreCase(currentValue)) {
			return false;
		} else {
			if (newValue.length() >0 ){
				return true;
			} else {
				if (canDelete){
					return true;
				}
			}
		}
		
		return false;
	}
	
	public String formatString(String s){
		if (s ==null) {
			return "";
		}
		else {
			return s.trim();
		}
	}
	
	protected boolean hasWebProfile(Member m)
	{
		if(m == null)
			return false;
		
		try
		{
			if(m.getWebPassword() != null && !m.getWebPassword().isEmpty())
				return true;
		} catch (SQLException e) {
			getLogger().error("Unable to determine if member has a web profile", e);
			return false;
		}
		
		return false;
	}
	
	private String getFutureDNRMembershipCoverageLevel(Membership membership)
	{
		if(membership == null) return null;
		
		try {
			Member primary = membership.getPrimaryMember();
			
			if(primary.inRenewal() && "RM".equals(membership.getBillingCd()) && !primary.isCancelled())
			{
				HashSet<String> riderCompCodes = new HashSet<String>();
				
				for(com.rossgroupinc.memberz.model.Rider r : primary.getNonCancelledRiderListFromCache())
				{
					if(r.isDoNotRenew())
						continue;
					
					riderCompCodes.add(r.getRiderCompCd());
				}

				if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL") && riderCompCodes.contains("PM") && riderCompCodes.contains("RV") && riderCompCodes.contains("BP"))
				{
					//PremierRVBattery
					return "BR";
				}				
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL") && riderCompCodes.contains("PM") && riderCompCodes.contains("BP"))
				{
					//PremierBattery
					return "BP";
				}				
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL") && riderCompCodes.contains("RV") && riderCompCodes.contains("PM"))
				{
					//PremierRV
					return "PR";
				}
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL") && riderCompCodes.contains("PM"))
				{
					//Premier
					return "PM";
				}
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL") && riderCompCodes.contains("RV"))
				{
					//PlusRV
					return "RV";
				}
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("PL"))
				{
					//Plus
					return "PL";
				}
				else if(riderCompCodes.contains("BS") && riderCompCodes.contains("MC"))
				{
					//Motorcycle
					return "MC";
				}
				else if(riderCompCodes.contains("BS"))
				{
					//Basic
					return "BS";
				}
				else
				{
					return null;
				}
				
			}
			
			return null;
			
		} catch (SQLException e) {
			getLogger().error("SQL Exception in getFutureDNRMembershipCoverageLevel", e);
			return null;
		}
		
	}
	
	public SimpleVO getMembershipCommentsVO (String membershipKy ) throws SQLException {
		LogUtils.logFramedMessage(log, "getMembershipComments");
		
		Connection conn = getConnection();
			
		SimpleVO commentsList = new SimpleVO();
		try {
			commentsList.setCommand("select c.membership_comment_ky, c.comments FROM mz_membership_comment c WHERE c.membership_ky =" + "'"+ membershipKy +"'" );
		  
			commentsList.setReadOnly(false);
			commentsList.execute(conn);
			commentsList.beforeFirst();
		}
		catch (Exception e){
			log.error(StackTraceUtil.getStackTrace(e));
		}
		finally{
			if (conn != null){
				try{
					conn.close();
					conn = null;
				}
				catch (Exception ignore){}
			}
		}
		return commentsList;
	}
	
    /**
     * Retrieve the value of particular setting from a configuration file
     * @param setting
     * @return
     */
    public String getSetting(String setting)
    {
        Element root = configuration.getRootElement();
        String result = root.elementText(setting);
        if (result == null) return "";
        return result;
    }

    public ArrayList<String> getAllwedDiscountsSetting(){
    	ArrayList<String> outL = new ArrayList<String>();
    	Element dcADscs = configuration.getRootElement().element("duesCalcAllowedDiscount");
        if  (dcADscs != null) {
            for (Iterator it = dcADscs.elementIterator("cd"); it.hasNext();) {
                Element defaultElement = (Element) it.next();
                outL.add((defaultElement.getTextTrim()));
            }            
        }        
        return outL;
    }
    
    public MembershipSimpleOperationResponse UpdateBilling(MembershipSimpleOperationRequest req) throws Exception{
		
    	MembershipSimpleOperationResponse response = null;
		
		String membershipNumber = req.getMembershipNumber();
		String agentId = req.getAgentId();
		String source = req.getSource();
		String marketCode = req.getMarketCode();
		
		String renewalMethod = "B";		//default value
		String rm = req.getRenewalMethod();
		
		boolean hasSwitchRenewalMethod = false;
		boolean hasSaveCreditCard	= false;
		String commentARCreditCardUpdate = "";
		
		boolean isInstallmentPlan = false;
		
		boolean hasAutoRenewalSwitch = false;
		
		if (rm.equalsIgnoreCase("Automatic Renewal")) { 
			renewalMethod = "A";		//overwrite target value to "A"
		} else if  (rm.equalsIgnoreCase("Installment Plan")) { 
			renewalMethod = "P";		//overwrite target value to "P"
		} 
		
		String salesAgentId= null;	
		try {
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n UpdateBilling");
				getLogger().debug(" Membership Number: " + membershipNumber + ", Agent Id: " + agentId);		
				getLogger().debug("**************************\n");			
			}
			if(agentId ==null || agentId.equals("")){
				salesAgentId = this.getSetting("defaultSalesAgent");
			}else{
				salesAgentId =   agentId;
			}
			SalesAgent sa = getSalesAgent(salesAgentId); 
			if(sa == null) {
					throw new WebServiceException (genInvalidAgentId);
			}else{
				this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
				salesAgentId = sa.getAgentId();
			}
			
			Membership membership = null;
			try	{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn =  null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipNumber);
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
			}catch (Exception e)
			{
				throw new WebServiceException(genMembershipIdInvalid + membershipNumber);
			}
			
			if (renewalMethod.equalsIgnoreCase("B")) {
				//switch from Bill to Bill, nothing to update 
				if (membership.getRenewMethodCd().equals(renewalMethod)){
					throw new WebServiceException(genUpdateBillingWithSameRenewalMethodValueMsg);
				} else {
					hasSwitchRenewalMethod = true;
				}
			}
			
			if (renewalMethod.equalsIgnoreCase("A")) {
				if(req.getPaymentParams() ==null || ( req.getPaymentParams().getCard()==null )) {
					throw new WebServiceException(genNoCreditCardMsg);
				} else if (!req.getPaymentParams().getCard().getSaveAsAutoRenewalCard()) {
					throw new WebServiceException("Please mark the saveAsAutoRenewalCard value as true");
				}
				
				if (membership.getRenewMethodCd().equals(renewalMethod)){
					//switch from AR to AR, need to update the credit card.
					hasSaveCreditCard = true;
				} else {
					//Switch from other to AR. 
					if (membership.getStatus().equalsIgnoreCase("P")&& isMembershipExpiringShortly(35, membership)){
						throw new WebServiceException("Can't switch AR when membership status is pending and membership expires in 35 days");
					}
					
					hasSaveCreditCard = true;
					hasSwitchRenewalMethod = true;
					
					//set the flag so can add the offer/discount/auditing for next term
					if (membership.getStatus().equalsIgnoreCase("A")){
						hasAutoRenewalSwitch = true;
					}
				}
			}
			
			//TODO: installment situation will be handled later. 
			if (renewalMethod.equalsIgnoreCase("P")) {
				
				//switch from installment plan to installment plan, need to update the credit card.  
				if (membership.getRenewMethodCd().equals(renewalMethod)){
					hasSaveCreditCard = true;
				} else {
					if (membership.getStatus().equalsIgnoreCase("A")) {
						throw new WebServiceException(genNoActiveMembershipAllowedForInstallmentPayEnrollMsg);
					}
					
					//INSTALLMENT PLAN -VALIDATION  [YHu ] - START
					if (req.getPaymentPlanKy() == null ) {
						throw new Exception ("Please provide a payment plan id for Installment Plan" );
					} else {
						isInstallmentPlan = true;
					}
					
					//Switch from other to Installment Plan. 
					hasSaveCreditCard = true;
					hasSwitchRenewalMethod = true;
				}
				
				if(req.getPaymentParams() ==null || ( req.getPaymentParams().getCard()==null )) {
					throw new WebServiceException(genNoCreditCardMsg);
				} else if (!req.getPaymentParams().getCard().getSaveAsAutoRenewalCard()) {
					throw new WebServiceException("Please mark the saveAsAutoRenewalCard value as true");
				}
			}
			
			//Update the renewalMethod.
			if (hasSwitchRenewalMethod) {
				for(Member m: membership.getMemberList()) {								
					m.setRenewMethodCd(renewalMethod);		
				}
				
				//create comment. - START 
				String comment = "Renewal method was changed to %s. %s";
				
				String commentSourceSection = "";
				if(!"".equals(membershipUtilBP.getMzPSourceCommentByWsSource(source))) {
					commentSourceSection = "\nChanges made via " + membershipUtilBP.getMzPSourceCommentByWsSource(source); 
				}
				
				if (renewalMethod.equalsIgnoreCase("B")) {
					comment = String.format(comment, "Bill me", commentSourceSection);
				} else if (renewalMethod.equalsIgnoreCase("A")) {
					comment = String.format(comment, "Automatic Renewal", commentSourceSection);
				} else if (renewalMethod.equalsIgnoreCase("P")) {
					comment = String.format(comment, "Installment Plan", commentSourceSection);
				}
				
				membership.addComment(comment); 
				//create comment. - END
				
				membership.save();
			}
			
			if (hasSaveCreditCard) {
				MaintenanceBP maintBp = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
								 
				AutorenewalCard card = maintBp.buildAutorenewalCard(membership, req.getPaymentParams());		
				if (card!=null) {
					card.save();
					membership.save();
				}	
				
				//membership.addComment("Credit card has been saved");
					
				String ct =  "\nRenewal change for member %s - %s %s: Billing Updated.";
				commentARCreditCardUpdate  = "via web member";
				for (Member m: membership.getNonCancelledMemberList()) {
					commentARCreditCardUpdate  = commentARCreditCardUpdate  + String.format(ct, m.getAssociateId(), m.getFirstName(),  m.getLastName()); 
				}

				//membership.save();
				
				if (isInstallmentPlan) {
					PaymentPlanBP ppbp = new PaymentPlanBP(user);
					for (Member member : membership.getMemberList()) {
						ppbp.markMemberForPaymentPlan(member, new BigDecimal(req.getPaymentPlanKy()), new Timestamp(System.currentTimeMillis()), 1);
						member.setMemberExpirationDt(member.getActiveExpirationDt());
					}
					ppbp.applyPaymentPlan(false, membership);	
					
//					for (PlanBilling pb: ppbp.findPlanBillingForFirstPayment(membership, 1)) {
//						pb.setPaymentStatus("P");
//						pb.save();
//					}	
				}
				
				membership.save();
				
				membership.addComment(commentARCreditCardUpdate); 
				membership.save();
			}
			
			if (hasAutoRenewalSwitch) {
				//check the market code
				if (marketCode!= null && !marketCode.equalsIgnoreCase("")) {
					DiscountOfferBP dobp = (DiscountOfferBP) BPF.get(user, DiscountOfferBP.class);
					DiscountBP dbp = (DiscountBP) BPF.get(user, DiscountBP.class);
					AutoRenewalBP abp = (AutoRenewalBP) BPF.get(user, AutoRenewalBP.class);
					
					//add the discount in the apply discount table.
					dbp.addRenewalDiscountsForNextRenewal(marketCode, membership);
					
					//add offer
					dobp.addOffers(membership, req.getMarketCode().toUpperCase().trim());	
					
					//add auditing
					abp.insertARAuditing(membership,renewalMethod, marketCode);
					
					membership.addComment(String.format("Via web member, membership %s, was switched to AR", membership.getMembershipId()));
				}
			}
			
			response = new MembershipSimpleOperationResponse();
		} 
		catch (WebServiceException e){	
			getLogger().error("", e);		
			response = new MembershipSimpleOperationResponse(e.getMessage(), "1");	
		} 
		catch (Exception e) {
			getLogger().error("", e);			
			response = new MembershipSimpleOperationResponse(genWSExceptionMsg, "1");	
		}
		return response ;
	}
    
    public MembershipSaveMembershipResponse SaveMembership(MembershipSaveMembershipRequest request) {
    	//Important - 
		//handle one transaction at a time; 
		//or the combination of add associates and upgrade coverage together are also allowed.
    	
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is Save Membership  request");
			getLogger().debug("Is Save Membership request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = new ArrayList<ValidationError>();
		
		SaveMembershipTransformationUtilBP tuBP = new SaveMembershipTransformationUtilBP(user);
		MembershipSaveMembershipResponse response = null;
		
		try {
			if(request !=null){	
				if (!tuBP.canPassInitialValidation(request)){
					response = new MembershipSaveMembershipResponse("Error", "1");
					Collection errs = tuBP.getErrors();
					
					if (errs !=null) {
						response.setInfoList(errs);
						return response;
					}
				}
				
				boolean isToadd = true;
				boolean isTocancel = true;
				boolean isToUpdate = true;
				boolean isToCV = true;
				boolean isToUB = true; 
				
				infoList.add("save membership transaction started.");
				
				//Cancel memeber
				AddCancelAssociateMemberRequest cr = tuBP.getCancelMemberRequest(request);
				if (cr!=null && isTocancel) {
					infoList.add("Cancel associate(s) transaction started.");
					AddCancelAssociateMemberResponse crs = CancelAssociateMember(cr);
					
					if (crs!=null ) {
						//response will not be null if atomic cancel member transaction has error
						response = appendInfoAndError (infoList, errList, crs.getInfoList(), crs.getErrors(), crs.getResult(), crs.getMessage());
					
						if (response == null) {
							infoList.add("Cancel associate(s) transaction ended.");
						} else {
							return response;
						}
					}
				} else {
					if (tuBP.hasErrors() ) {
						if (tuBP.getErrors() !=null) {
							response = new MembershipSaveMembershipResponse("Error", "1");	
							response.setInfoList(tuBP.getErrors());
							return response;
						}
					}
				}
				
				//add member
				AddCancelAssociateMemberRequest ar = tuBP.getAddMemberRequest(request);
				if (ar!=null && isToadd) {
					infoList.add("Add associate(s) transaction started.");
					AddCancelAssociateMemberResponse ars = AddAssociateMember(ar);
					
					if (ars!=null ) {
						//response will not be null if atomic add member transaction has error 
						response = appendInfoAndError (infoList, errList, ars.getInfoList(), ars.getErrors(), ars.getResult(), ars.getMessage());
					
						if (response==null) {
							infoList.add("Add associate(s) transaction ended.");
						} else {
							return response;
						}
					} 
				} else {
					if (tuBP.hasErrors() ) {
						if (tuBP.getErrors() !=null) {
							response = new MembershipSaveMembershipResponse("Error", "1");
							Collection errors = tuBP.getErrors(); 
							
							Iterator iterator = errors.iterator();
							while (iterator.hasNext()){
								response.setMessage("Error: " + iterator.next().toString()); 
								break; 
							}
							
							response.setInfoList(tuBP.getErrors());
							return response;
						}
					}
				}
				
				//change coverage
				MembershipCoverageUpdateRequest chcr = tuBP.getChangeCoverageRequest(request);
				if (chcr !=null && isToCV) {
					infoList.add("Change Coverage transaction started.");
					MembershipCoverageUpdateResponse chcrs = ChangeCoverageLevel(chcr);
					
					if (chcrs !=null) {
						response = appendInfoAndError (infoList, errList, chcrs.getInfoList(), chcrs.getErrors(),chcrs.getResult(), chcrs.getMessage());
						
						if (response==null) {
							infoList.add("Change Coverage  transaction ended.");
						} else {
							return response;
						}
					} 
				} else {
					if (tuBP.hasErrors() ) {
						if (tuBP.getErrors() !=null) {
							response = new MembershipSaveMembershipResponse("Error", "1");	
							
							Collection errors = tuBP.getErrors(); 
							
							Iterator iterator = errors.iterator();
							while (iterator.hasNext()){
								response.setMessage("Error: " + iterator.next().toString()); 
								break; 
							}
							
							response.setInfoList(tuBP.getErrors());
							return response;
						}
					}
				}
				//update member
				MembershipUpdateMemberRequest ur = tuBP.getUpdateMemberRequest(request);
				if (ur !=null && isToUpdate) {
					infoList.add("Update associate(s) transaction started.");
					MembershipUpdateMemberResponse urs = UpdateMembership(ur);
					
					if (urs!=null) {
						response = appendInfoAndError (infoList, errList, urs.getInfoList(), urs.getErrors(), urs.getResult(), urs.getMessage());
						
						if (response==null) {
							infoList.add("Update associate(s) transaction ended.");
						} else {
							return response;
						}
					} 
				} else {
					if (tuBP.hasErrors() ) {
						if (tuBP.getErrors() !=null) {
							response = new MembershipSaveMembershipResponse("Error", "1");	
							
							Collection errors = tuBP.getErrors(); 
							
							Iterator iterator = errors.iterator();
							while (iterator.hasNext()){
								response.setMessage("Error: " + iterator.next().toString()); 
								break; 
							}
							
							response.setInfoList(tuBP.getErrors());
							return response;
						}
					}
				}
				
				
				//update billing
				MembershipSimpleOperationRequest ubr = tuBP.getUpdateBillingRequest(request);
				if (ubr !=null && isToUB) {
					infoList.add("Update billing transaction started.");
					MembershipSimpleOperationResponse ubrs = UpdateBilling(ubr);
					
					if (ubrs !=null) {
						response = appendInfoAndError (infoList, errList, ubrs.getInfoList(), ubrs.getErrors(),ubrs.getResult(), ubrs.getMessage());
						
						if (response==null) {
							infoList.add("Update Billing transaction ended.");
						} else {
							return response;
						}
					} 
				} else {
					if (tuBP.hasErrors() ) {
						if (tuBP.getErrors() !=null) {
							response = new MembershipSaveMembershipResponse("Error", "1");
							
							Collection errors = tuBP.getErrors(); 
							
							Iterator iterator = errors.iterator();
							while (iterator.hasNext()){
								response.setMessage("Error: " + iterator.next().toString()); 
								break; 
							}
							response.setInfoList(tuBP.getErrors());
							return response;
						}
					}
				}
				
				if (cr==null && ar==null && ur==null && chcr==null && ubr==null ) {
					response = new MembershipSaveMembershipResponse("Error: have nothing to update", "1");
					Collection<String> infos = new ArrayList(); 
					infos.add("have nothing to update");
					response.setInfoList(infos);
					return response;
				}
				
				infoList.add("save membership transaction ended.");
				
				response = new MembershipSaveMembershipResponse("Success", "0");
				response.setInfoList(infoList);
				
				return response;
			}
		}  catch (Exception e){
			getLogger().error("", e);			
			
			response = new MembershipSaveMembershipResponse("Error", "1");	
			response.setErrors(null);
			infoList.add("Failed to Save membership! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
	}
	
	private MembershipUpdateMemberResponse UpdateMembership(MembershipUpdateMemberRequest request) {
		if (getLogger().isDebugEnabled()){			
			getLogger().debug("**************************\n Is update Membership  request");
			getLogger().debug("Is update Membership request: " + request.toString());	
			getLogger().debug("**************************\n");			
		}
		
		MembershipUpdateMemberResponse response =  null;
		Collection<String> infoList = new ArrayList<String>();
		Collection<ValidationError> errList = null;
		
		String infoMemberTemplate = "Info of member %s %s has been updated";
		String infoMembershipTemplate = "Info of all members has been updated";
		
		String exceptionMsgMembershipID = "Membership id invalid";
		String exceptionMsgSalesAgentID = "Failed to get the agent id for the transaction";
		
		String commentTemplate = "Via Web Member, associate %s updated. " ; 
		
		SimplePrimaryMember pm = null;
		
		try {
			if(request !=null){			
				Membership ms = null;
				
				try
				{
					
					pm = request.getSimpleMembership().getPrimaryMember();
					
					String salesAgentId = request.getSalesAgentID();
					SalesAgent sa = this.getSalesAgent(salesAgentId); 
					if(sa == null) {
						throw new Exception (exceptionMsgSalesAgentID); //"Failed to get the agent id for the transaction"
					}
					
					this.user = User.getUserByUserID(String.valueOf(sa.getUserId()));
					
					
					String membershipID = "";
					
					if (pm!= null) {
						membershipID = pm.getNumber().getNumber();
						ms = new Membership(this.user, membershipID);
					}
					
					if (ms==null) {
						throw new Exception(exceptionMsgMembershipID);
					}
					
					
					if (isMembershipOOTAndDNT(ms) && isEnrollMembershipMilitary (ms, request)) {
						//enroll membership military if needed.
						enrollingMembershipMilitary(ms, request);
						
						response = new MembershipUpdateMemberResponse("Success", "0");
						response.setErrors(null);
									
						infoList.add(String.format(infoMembershipTemplate));
						response.setInfoList(infoList);				
						return response;
						
					}
					
					String zipCode = pm.getAddress().getZipCode();
					Territory newTerritory = Territory.getTerritoryByZip(user, zipCode);
						
					

					//validation of the xml
					errList =  null; //membershipUtilBP.performValidation(vum, UPDATE_MEMBER_VALIDATION_XML);
					
					if (errList !=null && !errList.isEmpty())
					{
						throw new WebServiceException(genValidationMsg);
					}
					
					
					
				} catch( WebServiceException we){
					//validation error
					response = new MembershipUpdateMemberResponse("Error", "1");	
					response.setErrors(errList);
					return response;			
					
				} catch (ObjectNotFoundException one) {
					response = new MembershipUpdateMemberResponse("Error: Failed to update the membership! -- The new zip code is out of territory", "1");	
					response.setErrors(null);
					
					infoList.add("Failed to update the membership! -- The new zip code is out of territory");
					response.setInfoList(infoList);					
					
					return response;
				} catch (Exception e) {
					response = new MembershipUpdateMemberResponse("Error: Failed to update the membership! -- " + e.getMessage(), "1");	
					response.setErrors(null);
					
					infoList.add("Failed to update the membership! -- " + e.getMessage());
					response.setInfoList(infoList);		
					
					return response;		
				}
				
				//passed object validation and the salesagent ID check and the membership validation check. 
				
				//update membership and primary member if need to. 
				if (pm.getAction().equalsIgnoreCase(SaveMembershipTransformationUtilBP.ACTION_UPDATE_MEMBER)){
					
					Member m = ms.getPrimaryMember();
					String comments = String.format(commentTemplate, m.getAssociateId());
					boolean hasChange = false;
					
					String address1 = pm.getAddress().getAddressLine1().toUpperCase();
					String address2 = "";
					if (pm.getAddress().getAddressLine2()!=null) {
						address2 = pm.getAddress().getAddressLine2().toUpperCase();
					}

					String city = pm.getAddress().getCity().toUpperCase();
					String state = pm.getAddress().getState().toUpperCase();
					String zip = pm.getAddress().getZipCode();
					
					if (hasValueChanged(ms.getAddressLine1(), address1)) {
						hasChange = true;
						comments = comments
									+ String.format("\n Address Line 1 changed from %s to %s", ms.getAddressLine1(), address1); 
						ms.setAddressLine1(address1);
					}
					
					if (hasValueChanged(ms.getAddressLine2(), address2)) {
						hasChange = true;
						comments = comments
									+ String.format("\n Address Line 2 changed from %s to %s", ms.getAddressLine2(), address2); 
						ms.setAddressLine2(address2);
					}
					
					if (hasValueChanged(ms.getCity(), city)) {
						hasChange = true;
						comments = comments
									+ String.format("\n city changed from %s to %s", ms.getCity(), city); 
						ms.setCity(city);
					}
					
					if (hasValueChanged(ms.getState(), state)) {
						hasChange = true;
						comments = comments
									+ String.format("\n state changed from %s to %s", ms.getState(), state); 
						ms.setState(state);
					}
					
					if (hasValueChanged(ms.getZip(), zip)) {
						hasChange = true;
						comments = comments
									+ String.format("\n zip changed from %s to %s", ms.getZip(), zip); 
						ms.setZip(zip);
						
						Territory newTerritory = null;
						newTerritory = Territory.getTerritoryByZip(user, MembershipUtilBP.getZipcode(zip));
						
						//Update branch to correct one for the zipcode being changed to.
						try
						{
							ms.resetBranch(null);
						}
						catch (ObjectNotFoundException e)
						{
							//This exception shouldn't happen, but if it does use branch key of new territory.
							ms.setBranchKy(newTerritory.getBranchKy());
						}
						
					}
					
					//PC : 10/6/16: Resetting the address validation code for Address cleansing to pick up.					
					ms.setAddressValidationCode(null);
					
					String dob = pm.getDateOfBirth();
					String email = pm.getEmail();
					String lastName = pm.getName().getLastName().toUpperCase();
					String firstName = pm.getName().getFirstName().toUpperCase();
					String middleName = pm.getName().getMiddleName();
					String membershipID = pm.getNumber().getNumber();
					String associateID =  pm.getNumber().getAssociateId();
					
					String salutation = pm.getName().getTitle();
					String joinAAADate = pm.getJoinAAADate();
					String suffix = pm.getName().getSuffix();
					
					
					
					if (!m.isCancelled()) {
//							if (joinAAADate!=null && joinAAADate.length()>=10) {
//								joinAAADate = joinAAADate.substring(5,7) + "/" + joinAAADate.substring(8,10 ) + "/" + joinAAADate.substring(0,4);
//							}
						
						if (hasValueChanged(m.getLastName(), lastName)) {
							hasChange = true;
							comments = comments
										+ String.format("\n Last Name changed from %s to %s", m.getLastName(), lastName); 
							m.setLastName(lastName);
						}
						
						if (hasValueChanged(m.getFirstName(), firstName)) {
							hasChange = true;
							comments = comments
										+ String.format("\n First Name changed from %s to %s", m.getFirstName(), firstName); 
							m.setFirstName(firstName);
						}
						
						
						m.setMiddleName(middleName);
//							m.setJoinAaaDt(joinAAADate);
						m.setBirthDt(dob);
						
//							boolean emailExists = memberEmailCheckBP.isEmailDuplicated(email, membershipID, associateID);
//							if (emailExists) {
//								response = new MembershipUpdateMemberResponse(genDuplicateEmailMsg, "1");	
//								response.setErrors(null);
//								infoList.add("Failed to update the member! -- " + genDuplicateEmailMsg);
//								
//								response.setInfoList(infoList);
//								
//								return response;
//							}
							
							if (hasValueChanged(m.getEmail(), email)) {
								hasChange = true;
								comments = comments
											+ String.format("\n Email changed from %s to %s", m.getEmail(), email); 
								m.setEmail(email);
							}
							
							
						
						//translation of the suffix and salutation
						m.setNameSuffix(membershipUtilBP.getSuffixByWsType(suffix));
						m.setSalutation(membershipUtilBP.getSalutationByWsType(salutation));
						
						Phone[] phones = pm.getPhones();
						
						//clean every other phones.
						SortedSet<OtherPhone> ops = ms.getOtherPhoneList();
						if (ops !=null && ops.size() > 0){
							for (OtherPhone op : ops){
								op.delete();
							}
						}
						
						//old primary phone 
						String oldMsPrimaryPhone = ms.getPhone();
						String newMsPrimaryPhone = "";
						
						//clean the membership phone 
						ms.setPhone("");
						ms.setOtherPhoneFl("N");
						
						if (phones != null && phones.length > 0){
							for (int ip=0; ip < phones.length; ip++) {
								String pN = "";
								String pT = "";
								String pD = "";
								String pE = "";
								
								Phone p = phones[ip];
								if (p.getPhoneNumber()==null || p.getPhoneNumber().equalsIgnoreCase("")){
									break;
								}
								
								if (p.getPhoneNumber()!=null) pN = p.getPhoneNumber();
								if (p.getPhoneTypeCode()!=null) pT = p.getPhoneTypeCode();
								if (p.getDescription()!=null) pD = p.getDescription();
								if (p.getExtension()!=null) pE = p.getExtension();
								
								if (p.getIsPrimary()) {
									newMsPrimaryPhone = pN; 
									ms.setPhone(pN);
									
									if (hasValueChanged(oldMsPrimaryPhone, newMsPrimaryPhone)) {
										hasChange = true;
										comments = comments
													+ String.format("\n Primary Phone changed from %s to %s", oldMsPrimaryPhone, newMsPrimaryPhone); 
									}
								} else {
									ms.setOtherPhoneFl("Y");
									
									OtherPhone op = new OtherPhone(User.getGenericUser(), (BigDecimal) null, false);
									op.setParentMembership(ms);
									op.setPhone(pN);
									
									op.setPhoneType(membershipUtilBP.getPhoneTypeByWsType(pT));
									op.setUnlistedFl(false);
									op.setExtension(pE);
									op.setDescription(pD);
									op.save();
								}
							}
						}
						
						infoList.add(String.format(infoMemberTemplate, firstName, lastName));
						
						if (pm.getCredentialKy()!=null && !pm.getCredentialKy().trim().equals("")) {
							m.setCredentialKy(new BigDecimal(pm.getCredentialKy().trim()));
						}
						
						if (hasChange) {
							ms.addComment(comments);
						}
						
						ms.save();
					}
				}
				
				//update associate member's information if need to 
				if (request.getSimpleMembership().getAssociates()!=null && request.getSimpleMembership().getAssociates().length >0) {
					for (SimpleAssociateMember sam:request.getSimpleMembership().getAssociates()){
						if (sam.getAction().equalsIgnoreCase(SaveMembershipTransformationUtilBP.ACTION_UPDATE_MEMBER))  { 	
							String dob = sam.getDateOfBirth();
							String email = sam.getEmail();
							String lastName = sam.getName().getLastName().toUpperCase();
							String firstName = sam.getName().getFirstName().toUpperCase();
							String middleName = sam.getName().getMiddleName();
							String membershipID = sam.getNumber().getNumber();
							String associateID =  sam.getNumber().getAssociateId();
							
							String salutation = sam.getName().getTitle();
							String suffix = sam.getName().getSuffix();
//								String joinAAADate = sam.getJoinAAADate();
							
							for(Member m : ms.getNonCancelledMemberList()){
								if (m.getAssociateId().equals(associateID)) {
//										if (joinAAADate!=null && joinAAADate.length()>=10) {
//											joinAAADate = joinAAADate.substring(5,7) + "/" + joinAAADate.substring(8,10 ) + "/" + joinAAADate.substring(0,4);
//										}
									
									String comments = String.format(commentTemplate, m.getAssociateId());
									boolean hasChange = false;
									
									if (hasValueChanged(m.getLastName(), lastName)) {
										hasChange = true;
										comments = comments
													+ String.format("\n Last Name changed from %s to %s", m.getLastName(), lastName); 
										m.setLastName(lastName);
									}
									
									if (hasValueChanged(m.getFirstName(), firstName)) {
										hasChange = true;
										comments = comments
													+ String.format("\n First Name changed from %s to %s", m.getFirstName(), firstName); 
										m.setFirstName(firstName);
									}
									
									
									m.setMiddleName(middleName);
//										m.setJoinAaaDt(joinAAADate);
									m.setBirthDt(dob);
									
//										boolean emailExists = memberEmailCheckBP.isEmailDuplicated(email, membershipID, associateID);
//										if (emailExists) {
//											response = new MembershipUpdateMemberResponse(genDuplicateEmailMsg, "1");	
//											response.setErrors(null);
//											infoList.add("Failed to update the member! -- " + genDuplicateEmailMsg);
//											
//											response.setInfoList(infoList);
//											
//											return response;
//										}
//										
									if (hasValueChanged(m.getEmail(), email, true)) {
										hasChange = true;
										comments = comments
													+ String.format("\n Email changed from %s to %s", m.getEmail(), email); 
										m.setEmail(email);
									}
									
									//translation of the suffix and salutation
									m.setNameSuffix(membershipUtilBP.getSuffixByWsType(suffix));
									m.setSalutation(membershipUtilBP.getSalutationByWsType(salutation));
									
									if (sam.getCredentialKy()!=null && !sam.getCredentialKy().trim().equals("")) {
										m.setCredentialKy(new BigDecimal(sam.getCredentialKy().trim()));
									}
									
									infoList.add(String.format(infoMemberTemplate, firstName, lastName));
									
									if (hasChange) {
										ms.addComment(comments);
									}
									
								}
							}
						}
						
					}
				}
				
				//enroll membership military if needed
				enrollingMembershipMilitary (ms, request);
				
				ms.save();

				response = new MembershipUpdateMemberResponse("Success", "0");
				response.setErrors(null);
							
				infoList.add(String.format(infoMembershipTemplate));
				response.setInfoList(infoList);								 
				
			}
		}  catch (NumberFormatException e) {
			getLogger().error("", e);			
			
			response = new MembershipUpdateMemberResponse("Error: Failed to update the membership! -- Number Formatter Error", "1");	
			response.setErrors(null);
			
			infoList.add("Failed to update the membership! -- Number Formatter Error"  );
			response.setInfoList(infoList);						
		} catch (Exception e) {
			getLogger().error("", e);			
			
			response = new MembershipUpdateMemberResponse("Error: Failed to update the membership! -- " + e.getMessage(), "1");	
			response.setErrors(null);
			
			infoList.add("Failed to update the membership! -- " + e.getMessage());
			response.setInfoList(infoList);						
		}
		
		return response;
		
	}
	
	private boolean isMembershipOOTAndDNT (Membership ms) throws Exception{
		boolean result = false; 
		if (ms != null && !ms.isCancelled()) {
			String ooTFlValue = ms.getOutOfTerritoryCd(); 
			if (ooTFlValue!=null && ooTFlValue.equalsIgnoreCase("D")) { 	//membership is oot with do not transfer.
				result = true; 
			}
		}
		
		return result; 
	}
	
	private boolean isEnrollMembershipMilitary (Membership ms, MembershipUpdateMemberRequest request) throws Exception {
		boolean result = false; 
		if (request !=null && request.getSimpleMembership() != null) {
			MembershipAffiliationBP abp = (MembershipAffiliationBP) BPF.get(this.user, MembershipAffiliationBP.class);
			if (!abp.isMilitaryMembership(ms)) {						//membership is not military yet. and want to enroll. 
				if (request.getSimpleMembership().getMilitaryFlag()!=null && request.getSimpleMembership().getMilitaryFlag()) {
					result = true;	
				}
			}
		}
		
		return result;
	}
	
	private void enrollingMembershipMilitary (Membership ms, MembershipUpdateMemberRequest request) throws Exception {
		//TODO - military membership flag
		MembershipAffiliationBP abp = (MembershipAffiliationBP) BPF.get(this.user, MembershipAffiliationBP.class);
		if (!abp.isMilitaryMembership(ms)) {
			if (request.getSimpleMembership().getMilitaryFlag()!=null && request.getSimpleMembership().getMilitaryFlag()) {
				abp.insertMmembershipCd(ms, "MS");
				ms.addComment("Military status enrolled");
				
				//change bill category of the membership for next renewal 
				String mkCode = "MILI";
				MembershipUtilBP membershipUtilBP = MembershipUtilBP.getInstance();
				String billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(mkCode);
				
				ms.setBillingCategoryOnAll(billingCategoryCd);
				
				//request credential cards. 
				CredentialBP credBP = new CredentialBP(user);
				
				for (Member m: ms.getNonCancelledMemberList()) {
//					if (m.getAssociateId().equals("00")){
						String reasonCode = "MS"; 
						boolean waiveFeeFl = true;
						String sourceCode = "DCRQ";
						String sendCardTo = "P";
						
						credBP.requestCard(m, reasonCode, sourceCode, waiveFeeFl, sendCardTo);
						
						String cmt = "Duplicate card for Associate ID # "
				                + m.getAssociateId() 
				                + " requested " 
				                + "on "
				                + DateUtilities.getFormattedDate(DateUtilities.getTimestamp(true), "MM/dd/yyyy") 
				                + ".";
						ms.addComment(cmt);		
//					}
				}
				
				ms.save();
			}
		}
	}
	
	
	private MembershipSaveMembershipResponse appendInfoAndError(Collection<String> infoList, Collection<ValidationError> errList, 
			Collection<String> infoListAtomic, Collection<ValidationError> errListAtomic, String transactionResult , String transactionMsg) {
				MembershipSaveMembershipResponse response = null;
				
			if (infoListAtomic == null ){
				infoListAtomic =  new ArrayList<String>();
			}
			
			if (transactionResult.equals("0")) {
				for (String info: infoListAtomic) {
					infoList.add(info);
				}
			}  else {
				for (String info: infoListAtomic) {
					infoList.add(info);
				}
				
				if (errListAtomic !=null) {
					for (ValidationError ve: errListAtomic) {
						errList.add(ve);
					}
				}
				
				if (transactionMsg!=null && transactionMsg.startsWith("Error:" )) {
					response = new MembershipSaveMembershipResponse(transactionMsg, "1");	
				} else {
					response = new MembershipSaveMembershipResponse("Error:" + transactionMsg, "1");
				}
					
				response.setErrors(errList);
				response.setInfoList(infoList);
			}
			
			return response;
		}
     
    protected class WebServiceException extends Exception
    {
		private static final long serialVersionUID = 1L;

		public WebServiceException(String message){
    		super(message);
    	}
    }

	public MembershipDues GetMembershipBalanceWithMarketCode(String zipCode, String marketCode, String membershipNumber, String salesAgentID) {
		MembershipDues dues = null;		
		try {
			
			if (getLogger().isDebugEnabled()){			
				getLogger().debug("**************************\n Get Membership Balance by Market code");
				getLogger().debug("Zip Code: " + zipCode);
				getLogger().debug("Market Code: " + marketCode);
				getLogger().debug("**************************\n");			
			}
						
			//validate input, market code is optional
			//zipCode
			validateZipCode(zipCode);
			
			String regionCd = membershipUtilBP.getRegionCd(zipCode);
			
			MembershipDuesCalculatorUtil mDCU = new MembershipDuesCalculatorUtil(user);
			
			Membership membership = null;
			if(membershipNumber != null && !membershipNumber.equals("")) // existing membership
			{
				MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
				MembershipNumber mn = null;
				try
				{
					mn =  mbp.parseFullMembershipNumber(membershipNumber);
				}
				catch (Exception e)
				{
					throw new WebServiceException(genMembershipIdInvalid + e.getMessage());
				}
				 
				if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
					throw new WebServiceException(genOutOfTerriroryMsg);
				}						
				membership = new Membership(user, mn.getMembershipID());
				
				
				//handle whether membership is in renewal -start
				boolean inRenewal = false;
				
				Member pm = membership.getPrimaryMember();
				if (membership.isPending()){
					inRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
					inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
				}		
				
				if (!inRenewal) {
					throw new WebServiceException("Membership not in renewal");
				}
				//handle whether membership is in renewal -end
				
				GetMembershipComponentDuesRequest cdRequest = new GetMembershipComponentDuesRequest();
				SimpleMembershipNumber nm = new SimpleMembershipNumber();
				nm.setFullNumber(membershipNumber);
				cdRequest.setMemberID(nm);
				cdRequest.setSalesAgentID(salesAgentID);
				
				GetMembershipComponentDuesResponse cdResponse = GetMembershipComponentDues(cdRequest); 
				MembershipComponentDues mcDues = cdResponse.getMembershipComponentDues();
				
				ArrayList<Donation> donations = null;
				MemberComponentDues[] mDuesArray = mcDues.getMemberComponentDues();
				for (MemberComponentDues mDues: mDuesArray){
					String memberType = mDues.getMember().fetchMzPAssociateType();
					
					if (memberType.equalsIgnoreCase("P")) {
						if (mDues.getDonations()!=null && mDues.getDonations().length > 0) {
							donations = new ArrayList(Arrays.asList(mDues.getDonations()));
						}
					} 
				}
				
				regionCd = membershipUtilBP.getRegionCd(membership.getZip());
				
				Collection<Discount> discounts = mDCU.CalculateMembershipDuesByMarketCode(mcDues, marketCode, membership,  membership.getDivisionKy(), regionCd);
				ArrayList <DuesDiscountItem> discountItems = new ArrayList<DuesDiscountItem>();
				
				if (discounts != null) {
					for (Discount d : discounts) {
						if (d.getAppliesTo()!=null && d.getAppliesTo().equalsIgnoreCase("MBS")) {
							discountItems.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), d.getAppliesTo(), d.getPercentFl()));
						}
					}
				}
				
				dues = new MembershipDues(zipCode,  membership.getCurrentMemberList().size() -1, mDCU.getCoverageLevelText(), marketCode, mDCU.getMemberDues(), "0.00", null, discountItems, donations, true);

			}
						
		} catch (WebServiceException e){	
			dues = new MembershipDues(e.getMessage(), "1" );			
		} catch (Exception e) {
			getLogger().error("", e);
			dues = new MembershipDues(genWSExceptionMsg, "1");
		}

		return dues;
	}
	
	private boolean isMembershipExpiringShortly(int dayCount, Membership ms) throws Exception{
		boolean result = false;
	    if (ms!=null &&  ms.getPrimaryMember()!=null && ms.getStatus().equalsIgnoreCase("P")) {
	    	Calendar calendarExp = Calendar.getInstance();
			calendarExp.setTimeInMillis(ms.getPrimaryMember().getMemberExpirationDt().getTime());
			
			Calendar calendarToday = Calendar.getInstance();
			calendarToday.add(Calendar.DATE, dayCount);  //Going back days of dayCount in the past. 
			
			//after advance to the days of value dayCount from today's date, the date is later than the expiration date. 
			if (calendarToday.compareTo(calendarExp)>0) {
				result = true;
			} else {
				result = false;
			}
	    }
		return result;
	}
	
	private ArrayList<String> getUpgradeableCoverages(String baseCoverageLevelCd, String source) {
		ArrayList<String> covs = new ArrayList<String>();
		
		MembershipUtilBP utilBp = MembershipUtilBP.getInstance();
		covs = utilBp.getUpgradeableCoverages(baseCoverageLevelCd, source);
		
		return covs;
	}
	
	private void cancelDonations(Membership membership) throws SQLException{
		SortedSet<DonationHistory> list = membership.getPendingDonationList();
		for (DonationHistory dh : list){
			for (PlanBilling pb : dh.getPlanBillingList()) {
				if (PlanBilling.PAYMENT_STATUSES.UNPAID.equals(pb.getPaymentStatus())) {
					pb.delete();
				}
			}
			dh.setStatus("C");
			dh.save();
		}
	}
	
	//for reenroll a membership who cancelled over 18 months, need to contact cwp and update
	private void updateCWPWithReenroll(MembershipEnrollResponse response, String newMembershipId16, String oldMembershipId16, String email, String module) {
		String DEBUG_MODULE = module;
		MembershipUtilBP mubp = MembershipUtilBP.getInstance();
		
		if (email!= null && !email.equals("")) {
			CWPReEnrollBP cwpRep = (CWPReEnrollBP) BPF.get(User.getGenericUser(), CWPReEnrollBP.class);
			OMElement cwpResponse = cwpRep.getProfileInfo(newMembershipId16, oldMembershipId16, email);
			
			if (cwpResponse!= null) {
				
				mubp.debug(DEBUG_MODULE, cwpResponse.toString(), true) ;
				
				String resultCode = "";
				String resultMessage = "";
				String profileId = "";
				
				try {
					Iterator iter = cwpResponse.getChildrenWithLocalName("AAA_WebProfile_UpdateWithPurge_RS");
					while (iter.hasNext()) {
						OMNode n = (OMNode)iter.next();
						if (n instanceof OMElementImpl){
							OMElement elementResult = (OMElement) n;
							if (elementResult.getLocalName().equalsIgnoreCase("Response")){
								Iterator iterResult = elementResult.getChildren();
								while (iterResult.hasNext()) {
									OMNode node = (OMNode)iterResult.next();
									if (node instanceof OMElementImpl){
										OMElement e = (OMElement) node;
										if (e.getLocalName().equalsIgnoreCase("ReturnCode")){
											resultCode = e.getText();
										} else if (e.getLocalName().equalsIgnoreCase("ReturnMessage")){
											resultMessage = e.getText();
										}
									}
								}
								
							} else if (elementResult.getLocalName().equalsIgnoreCase("ProfileId")){
								profileId = elementResult.getText();
							} 
						}
					}
				} catch(Exception e) {
					response.setUpdateCWPResult(true);
					response.setProfileId("");
					response.setProfileDescription(CWP_PROFILE_DESCRIPTION_ERROR);
				}
				
				
				if (profileId!=null && !profileId.equals("")){
					response.setUpdateCWPResult(true);
					
					if (resultCode.equals("0")){
						if (profileId.equals("0")) {
							response.setProfileId("");
							response.setProfileDescription(CWP_PROFILE_DESCRIPTION_UNFOUND);
						} else {
							response.setProfileId(profileId);
							response.setProfileDescription(CWP_PROFILE_DESCRIPTION_SUCCESS);
						}
					} else {
						response.setProfileId("");
						response.setProfileDescription(CWP_PROFILE_DESCRIPTION_ERROR);
					}
				}
			}
		} else {
			//handle error
			response.setUpdateCWPResult(true);
			response.setProfileId("");
			response.setProfileDescription(CWP_PROFILE_DESCRIPTION_UNREACHABLE);
		}
	}
	
	//wwei webmember bug, need add writeoff amt;
	private BigDecimal getUnderPayWriteOffAmt(){
		BigDecimal writeOffAmt = ClubProperties.getBigDecimal("UnderPayWriteOffThreshold", getUser().getAttributeAsBigDecimal("DIVISION_KY"), getUser().getAttributeAsString("REGION_CD"));
			if (writeOffAmt != null ) {
				return writeOffAmt;
		}
		return BigDecimal.ZERO;
	}
	
	public SimpleVO getRegionInfo_VO (String zipCode ) throws SQLException {
		LogUtils.logFramedMessage(log, "getRegionInfo_VO");
		
		Connection conn = getConnection();
			
		if (zipCode == null || zipCode.equalsIgnoreCase("")){
			log.debug("Error in getRegionInfo_VO: zipCode is invalid");
			return null;
		}
	
		SimpleVO regionInfoVO= new SimpleVO();
		try {
			regionInfoVO.setCommand("select t.branch_ky, b.branch_cd, b.region_cd, b.sub_company_cd, d.division_ky, d.division_cd " +
									"from mz_territory t " +
									"inner join mz_branch b on t.branch_ky = b.branch_ky " + 
									"inner join mz_division d on b.division_ky = d.division_ky " +
									"where t.zip = '" + zipCode + "'");  
			  
			regionInfoVO.setReadOnly(false);
			regionInfoVO.execute(conn);
				
			regionInfoVO.beforeFirst();
			
		}
		catch (Exception e){
			log.error(StackTraceUtil.getStackTrace(e));
		}
		finally{
			if (conn != null){
				try{
					conn.close();
					conn = null;
				}
				catch (Exception ignore){}
			}
		}
		return regionInfoVO;
	}

	public MembershipInstallmentPaymentPlanResponse getMembershipPaymentPlan(MembershipInstallmentPaymentPlanRequest request) {
		String DEBUG_MODULE = "WM_GetPaymentPlan_" + Calendar.getInstance().getTimeInMillis() +"";
		
		SalesAgent sa = null;
		Membership membership = null;

		InstallmentPayPlanItem ppi = null; 
		
		BigDecimal paymentPlanKy = null; 
		
		Collection<String> infoList = new ArrayList<String>();
		MembershipServiceValidationBP msvBP = (MembershipServiceValidationBP)BPF.get(user, MembershipServiceValidationBP.class);
		
		MembershipInstallmentPaymentPlanResponse response = null;
		
		try {
			if (msvBP.validateAndInitializeGetMembershipPaymentPlan(request)){
				this.user = msvBP.getUser();
				sa = msvBP.getSalesAgent(); 
				membership  = msvBP.getMembership(); 
				
				paymentPlanKy =  getMembershipPaymentPlanKy(membership, user);
				if (paymentPlanKy != null) {
					PaymentPlan pl = new PaymentPlan(user, paymentPlanKy);
					
					ppi = new InstallmentPayPlanItem();
					ppi.setPlanKy(paymentPlanKy.toString());
					ppi.setPlanName(pl.getPlanName());
					ppi.setNumberOfPays(pl.getNumberOfPayments().toString());
					
					Collection<InstallmentPayItem> pays = new ArrayList<InstallmentPayItem> (); 
					pays = getInstallPlanPayItems(membership, user); 
				    ppi.setPays(pays);		
				} 
			}
			
			response = new MembershipInstallmentPaymentPlanResponse("Success", "0");
			String membershipBalance = membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy())); 
			response.setMembershipBalance(membershipBalance); 
			
			response.setPlan(ppi); 
			response.setInfoList(infoList);
			
		}  catch (WebServiceValidationException e){
			response = new MembershipInstallmentPaymentPlanResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);	
		} catch (Exception e){
			response = new MembershipInstallmentPaymentPlanResponse("Error", "1");	
			response.setErrors(null);
			infoList.add(e.getMessage());
			response.setInfoList(infoList);						
		}
		return response;
		
	}
	
	private BigDecimal getInstallPlanPaymentAmount(Membership ms, User user) throws WebServiceException{
		
		BigDecimal retVal = null; 
		Collection<InstallmentPayItem> pays = getInstallPlanPayItems(ms, user); 
		
		if (pays == null || pays.size() == 0) throw new WebServiceException ("Invalid Payment Plan Amount"); 
		
		Iterator<InstallmentPayItem> iterator = pays.iterator();
		 
        // while loop
        while (iterator.hasNext()) {
        	InstallmentPayItem pay = iterator.next();
        	if (!pay.getStatus().equals("P")) {
        		retVal = new BigDecimal (pay.getPaymentAmount()); 
        		break ; 
        	}
        }
        
        if (retVal == null ) 
        	throw new WebServiceException("Invalid Payment Plan Amount"); 
        
        return retVal;  
	}
	
	private Collection<InstallmentPayItem> getInstallPlanPayItems(Membership ms, User user) {
		Connection conn = null;
		CallableStatement pstmt = null;
		ResultSet rs = null;
		
		Collection<InstallmentPayItem> pays = new ArrayList<InstallmentPayItem> (); 
		
		try {
		    conn = null;
			conn = ConnectionPool.getConnection(user);
			
			pstmt = conn.prepareCall("{? = call MZ_GET_PAYMENT_PLAN(?)}");
			pstmt.registerOutParameter(1, OracleTypes.CURSOR);
			pstmt.setString(2, ms.getMembershipKy().toString());
			
			boolean ok = pstmt.execute();
			rs = (ResultSet) pstmt.getObject(1);
			
			while (rs.next()){
				InstallmentPayItem item = new InstallmentPayItem(); 
				item.setChargeDt(DateUtilities.getFormattedDate(rs.getTimestamp("CHARGE_DT"), "MM/dd/yyyy")); 
				item.setConvenienceFee(rs.getBigDecimal("CONVENIENCE_AT").setScale(2).toString()); 
				item.setPaymentAmount(rs.getBigDecimal("PAYMENT_AT").setScale(2).toString()); 
				item.setPaymentNumber(rs.getString("PAYMENT_NUMBER")); 
				item.setStatus(rs.getString("PAYMENT_STATUS")); 
				item.setPaymentSummaryKy(nvl(rs.getString("membership_payment_ky"))); 
				
				pays.add(item); 
			}
		} catch(Exception e) {
			String msg = e.getMessage();
		} finally {
			if (rs != null){
				try{
					rs.close();
				}
				catch (Exception ignore){}
			}
			if (pstmt != null){
				try{
					pstmt.close();
				}
				catch (Exception ignore){}
			}
			if (conn != null) {
				try {
					conn.close();
				}
				catch (java.sql.SQLException e) {
					log.warn("Warning: error closing connection: " + e.toString());
				}
			}
		}
		
		return pays; 
	}
	
	private BigDecimal getMembershipPaymentPlanKy (Membership membership, User user) {
		BigDecimal ppk = null; 
		
		try {
			if (membership!=null && membership.getPrimaryMember().getRenewMethodCd().equalsIgnoreCase("P")){
				PaymentPlanBP ppbp = new PaymentPlanBP(user);
				ppk = ppbp.findCurrentPaymentPlanOnMember(membership);
			} 	
		} catch (SQLException e) {
			//do nothing
		}
		
		return ppk; 
	}
	
}
