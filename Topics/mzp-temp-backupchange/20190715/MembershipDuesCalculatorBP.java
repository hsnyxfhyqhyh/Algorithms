package com.aaa.soa.object;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.SortedSet;
import java.util.TreeSet;

import javax.naming.NamingException;


import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.Element;

import com.aaa.soa.object.MembershipServiceBP.WebServiceException;
import com.aaa.soa.object.models.BaseMembershipDues;
import com.aaa.soa.object.models.Donation;
import com.aaa.soa.object.models.DuesCostItem;
import com.aaa.soa.object.models.DuesDiscountItem;
import com.aaa.soa.object.models.GetMembershipComponentDuesRequest;
import com.aaa.soa.object.models.GetMembershipComponentDuesResponse;
import com.aaa.soa.object.models.MarketCode;
import com.aaa.soa.object.models.MemberComponentDues;
import com.aaa.soa.object.models.MemberDues;
import com.aaa.soa.object.models.MembershipComponentDues;
import com.aaa.soa.object.models.MembershipDues;
import com.aaa.soa.object.models.SimpleMembershipNumber;
import com.aaa.soa.object.models.WebServiceValidationException;
import com.ibm.icu.util.Calendar;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.errorhandling.ValueObjectException;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.bp.cancel.CancelBP;
import com.rossgroupinc.memberz.bp.cost.CostData;
import com.rossgroupinc.memberz.bp.cost.DuesCalculatorCostBP;
import com.rossgroupinc.memberz.bp.membership.MembershipIdBP;
import com.rossgroupinc.memberz.bp.membershipentry.MembershipEntryBP;
import com.rossgroupinc.memberz.bp.payment.PayableComponent;
import com.rossgroupinc.memberz.data.model.MembershipNumber;
import com.rossgroupinc.memberz.model.CoverageLevel;
import com.rossgroupinc.memberz.model.Discount;
import com.rossgroupinc.memberz.model.DiscountHistory;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.Rider;
import com.rossgroupinc.memberz.model.RiderDefinition;
import com.rossgroupinc.memberz.model.Solicitation;
import com.rossgroupinc.memberz.model.SolicitationDiscount;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.DateUtils;
import com.rossgroupinc.util.SearchCondition;
import com.rossgroupinc.util.StringUtils;
import com.rossgroupinc.util.ValueHashMap;
import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.rule.Validator;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.util.RGILoggerFactory;


public class MembershipDuesCalculatorBP extends BusinessProcess {
	
	private static final long serialVersionUID = 1L;
	private  	Logger							log				= LogManager.getLogger(MembershipDuesCalculatorBP.class.getName(), new RGILoggerFactory());
	
	protected static Document configuration;
	
	protected static final String 				genOutOfTerriroryMsg = "Unable to look up Out of Territory memberships.";
	protected static final String 				genMembershipIdInvalid = "Membership ID is invalid. ";
	protected static final String 				genWSExceptionMsg = "Unexpected system error has occurred.";
	protected static final String 				genMembershipNotFoundMsg = "Membership not found. ";
	
	private  	CostData[]						origCdArray				= null;
	private 	User							user					= null;
//	private		boolean							prorate					= false;
	private		Collection<MemberDues>			colMdues				= null;
	private 	String							covLvlDescr				= "";
	private		SortedSet<CoverageLevel>		coverageLevels  		= null;
	Collection<Discount> 						discounts 				= null;
	private 	ArrayList<Donation> 			donations 				= null;
	private 	String 							covLevCd 				= "";
	private 	String 							billingCategoryCd 		= ""; 
	private 	String 							regionCd 				= ""; 
	private 	BigDecimal 						branchKy 				= null; 
	private 	BigDecimal 						divisionKy 				= null; 
	private 	boolean 						inRenewal 				= false;
	
	private		ValueHashMap 					appliedDiscount = new ValueHashMap();				
	protected   MembershipUtilBP 				membershipUtilBP = MembershipUtilBP.getInstance();
	
	private 	Membership 						membership = null;
	
	public MembershipDuesCalculatorBP(User user){
		super();
		this.user = getUser(user);
	}	
	
	public Collection<MemberDues> getMemberDues(){
		return this.colMdues;
	}
	
	public String getCoverageLevelText(){
		return this.covLvlDescr;
	}
	
	
	/**
	 * Calculate membership dues for SOA service Dues Calcualtor, for shopping card experience of existing membership
	 */
	public MembershipDues CalculateDuesSC(
			String zipCode, 
			int associateCount,		//brand new associate requested. 
			String coverageLevel, 
			String marketCode, 
			String[] requestDiscounts, 
			String membershipNumber
		)
	{
		MembershipDues dues = null;		
		
		try {
			//validate input and initialize stuff
			validateAndInitializeCalculateDues(zipCode, associateCount, coverageLevel, marketCode, membershipNumber); 
			
			//non-primary non-cancelled members, of existing membership
			int totalFutureNoncancelledAMCount = membership.getCurrentMemberList().size() - 1;	 
			
			if(associateCount > 0) //==> implies more associates needs to be added to the membership
			{
				totalFutureNoncancelledAMCount = totalFutureNoncancelledAMCount + associateCount;
			}
				
			calculateMembershipDuesSC(zipCode, totalFutureNoncancelledAMCount, marketCode, covLevCd);
			
			ArrayList <DuesDiscountItem> discountItems = new ArrayList<DuesDiscountItem>();
			
			setDiscounts(marketCode); 
			if (discounts != null) {
				for (Discount d : discounts) {
					if (d.getAppliesTo()!=null && d.getAppliesTo().equalsIgnoreCase("MBS")) {
						discountItems.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), 
																d.getAppliesTo(), d.getPercentFl()));
					}
				}
			}
			
			ArrayList<Donation> donations = getDonations();
			
			String balance = membershipUtilBP.formatAmount(membership.getMembershipBalance(user, membership.getMembershipKy()));
			
			dues = new MembershipDues(zipCode, associateCount, getCoverageLevelText(), marketCode, 
					getMemberDues(), balance, "0.00", discountItems, donations, false);

			
		} catch (WebServiceException e){	
			dues = new MembershipDues(e.getMessage(), "1" );			
		} catch (Exception e) {
			getLogger().error("", e);
			dues = new MembershipDues(genWSExceptionMsg, "1");
		}

		return dues;
	}
	
	
	public BaseMembershipDues CalculateUpgradeDuesSC (
				String fullMembershipID, int newAssociateCount,	
				String marketCode, String source) 
	{
		BaseMembershipDues baseDues = null;
		String s = ""; //Membership membership = null;
		
		try {
			//validation
			validateAndInitializeCalculateUpgradeDues(marketCode, fullMembershipID); 
			
			String zipCode = membership.getZip();
			
			int existingAssociateCount = membership.getNonCancelledMemberList().size() - 1;
			int totalFutureNoncancelledAMCount = newAssociateCount + existingAssociateCount; 
			
			//Collection<Discount> mkDiscounts = null;
			ArrayList <DuesDiscountItem> discountItems = new ArrayList<DuesDiscountItem>();
			
			setDiscounts(marketCode);
			if (discounts != null) {
				for (Discount d : discounts) {
					if (d.getAppliesTo()!=null && d.getAppliesTo().equalsIgnoreCase("MBS")) {
						discountItems.add(new DuesDiscountItem(d.getDiscountCd(), d.getName(), d.getAmount(), 
																d.getAppliesTo(), d.getPercentFl()));
					}
				}
			}
			
			ArrayList<Donation> donations = getDonations();
			
//			MembershipDuesCalculatorUtil mcu1 = new MembershipDuesCalculatorUtil(user);
			
			Collection<MembershipDues> dues = new ArrayList<MembershipDues>();
			
			//get each possible upgradeable coverages, do calculate 
			for(String cov: getUpgradeableCoverages(membership.getCoverageLevelCd(), source)){			
				String covText = membershipUtilBP.getCoverageByMZPType(cov);		
				
				//reset memberDues
				colMdues = new ArrayList<MemberDues>();
				
				calculateMembershipDuesSC(zipCode, totalFutureNoncancelledAMCount, marketCode, cov);
				
				dues.add(new MembershipDues(zipCode, newAssociateCount, covText, marketCode, colMdues, "0.00", 
								membership.getPaymentAt().toString(), discountItems, donations, false));			
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
    
    private Logger getLogger(){
		if(log == null){
			log = LogManager.getLogger(MembershipServiceBP.class.getName(), new RGILoggerFactory());
		}
		return log;
	}
    
    private String getBillingCategoryCD (String marketCode) throws WebServiceException{
    	String billingCategoryCd = "0042";
    	
    	try {
    		if (!marketCode.equalsIgnoreCase("") && !marketCode.equals("INTD")) 
    		{
    			billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);	
    		} else {
    			if( membership.isOnTier() || membership.isSpecialtyMembership()) {
    				billingCategoryCd = membership.getPrimaryMember().getBasicRider().getBillingCategoryCd();
    			} 
    		}	
    	} catch (Exception e) {
    		throw new WebServiceException("invalid billing category cd "); 
    	}
    	
    	return billingCategoryCd; 
    }
    
    
    private boolean validateAndInitializeCalculateUpgradeDues(String marketCode, String fullMembershipID) throws WebServiceException{
    	
    	boolean result = false;
    	String 	errMsg 	= ""; 
    	
    	try {
    		
    		if ( fullMembershipID.length() != 16) {
    			throw new WebServiceException("membership ID needs to be 16 digits long");
    		} else {
    			errMsg = "invalid membership ID";
    			String mbrID = fullMembershipID.substring(6,13);
   				membership = new Membership(user, mbrID);
   				
   				String zipCode = membership.getZip();
   				
   				billingCategoryCd = membershipUtilBP.getBillingCdByMarketCd(marketCode);
   				branchKy = membershipUtilBP.getBranchKy(zipCode);
   				regionCd = membershipUtilBP.getRegionCd(zipCode);
   				divisionKy = membershipUtilBP.getDivisionKy(zipCode);
    		}
    		
    		MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			if (bpMaint.getDoNotRenew(membership)){
				throw new WebServiceException("Future cancel membership can't be upgraded");
			}
			
			if(membership.getNonCancelledMemberList().size() == 0) {
				throw new WebServiceException("There are no active members on this membership");
			}
			
    	} catch (WebServiceException e) {
    		throw new WebServiceException(e.getMessage()) ; 
    	} catch (Exception e) {
    		if (nvl(errMsg).equals("")) {
    			errMsg = e.getMessage(); 
    		}
    		throw new WebServiceException(errMsg); 
    	}
    	
    	return result;
    }
    
    private boolean validateAndInitializeCalculateDues(String zipCode, int addNewAssociateCount, String coverageLevel, 
			String marketCode, String membershipNumber) throws WebServiceException{
    	
    	boolean result = false;
    	String 	errMsg 	= ""; 
    	
    	try {
    		result = validateZipCode(zipCode);
    		
    		//market code is optional
    		
    		//associate count
			validateAssociateCount(addNewAssociateCount);
			
			branchKy = membershipUtilBP.getBranchKy(zipCode);
			regionCd = membershipUtilBP.getRegionCd(zipCode);
			divisionKy = membershipUtilBP.getDivisionKy(zipCode);
			
			//validate coverage
			membershipUtilBP.validateCoverageForZip(coverageLevel, regionCd, divisionKy);
			
			covLevCd = membershipUtilBP.getCoverageByWsType(coverageLevel);
			
			//assuming it is existing membership
			MembershipIdBP mbp = (MembershipIdBP) BPF.get( user, MembershipIdBP.class);
			MembershipNumber mn = mbp.parseFullMembershipNumber(membershipNumber);
			
			if(!mn.getClubCode().equals(ClubProperties.getClubCode())){
				throw new WebServiceException(genOutOfTerriroryMsg);
			}
			
			errMsg 	= genMembershipNotFoundMsg;
			
			membership = new Membership(user, mn.getMembershipID());
			
			//existing non-cancelled members in mzp
			int activeAssocCount = membership.getCurrentMemberList().size();
			if(activeAssocCount ==0 && addNewAssociateCount ==0)
			{
				throw new Exception("There are no active members on this membership");
			}
			
			//now we know there is non-cancelled member(s) in membership, for existing membership we can add associate or upgrade cov both no both
			validateUpgradeCoverageOrAddMemberSC(addNewAssociateCount, membership, covLevCd);  //covLevCd - BS etc.
			
			MaintenanceBP bpMaint = (MaintenanceBP) BPF.get(user, MaintenanceBP.class);
			if (bpMaint.getDoNotRenew(membership)){
				throw new WebServiceException("Future cancel membership can't be upgraded.");
			}
			
			billingCategoryCd = getBillingCategoryCD(marketCode);
			regionCd = membershipUtilBP.getRegionCd(membership.getZip());
			
			Member pm = membership.getPrimaryMember();
			if (membership.isPending()){
				inRenewal = (!"NM".equalsIgnoreCase(membership.getBillingCd()));  /*as long as code is not NM*/
				inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
			}		
			
    	} catch (WebServiceException e) {
    		throw new WebServiceException(e.getMessage()) ; 
    	} catch (Exception e) {
    		if (nvl(errMsg).equals("")) {
    			errMsg = e.getMessage(); 
    		}
    		throw new WebServiceException(errMsg); 
    	}
    	
    	return result;
    
    }
    
    private boolean validateZipCode(String zipCode) throws Exception{
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
	
	private boolean validateUpgradeCoverageOrAddMemberSC(int associateCount, Membership ms, String coverageCD) throws WebServiceException {
		boolean result = false;
		
		try {
			if (associateCount==0 && ms.getCoverageLevelCd().trim().equalsIgnoreCase(coverageCD))  {
				throw new WebServiceException("dues calculation request not valid");  	
			}
		} catch (Exception e) {
			throw new WebServiceException(e.toString());
		}
		 
		return result;
	}
	
	private boolean validateAssociateCount(int associateCount) throws WebServiceException{
		//associate count
		if(associateCount < 0 || associateCount > 99){
			throw new WebServiceException("Associate count must be between 0 and 99");
		}		
		return true;
	}
	
	protected class WebServiceException extends Exception
    {
		private static final long serialVersionUID = 1L;

		public WebServiceException(String message){
    		super(message);
    	}
    }
	
	public void calculateMembershipDuesSC(String zip, int totalFutureNoncancelledAMCount, String marketCode, String coverageLeverCd)
	{
		String commissionCd = "N";
		ValueHashMap _origHashMap = new ValueHashMap();
		CostData[] newCdArray = null;
		CostData[] finalCdArray = null;
		String primBSRdrStatus = "P";
		boolean isExisting  = true;
		Timestamp passExpiration = null;
		String covLevCdUpperCase = coverageLeverCd.toUpperCase(); 
		
		String state = membership.getDuesState();
		
		try {
			
			passExpiration = membership.getPrimaryMember().getMemberExpirationDt();
			
			//set market code to the members in memory for dues calculation
			if (!nvl(marketCode).equals("")){ 
				SortedSet<Member> mbsMembers = membership.getNonCancelledMemberList();
				Iterator<Member> iter = mbsMembers.iterator();
				while (iter.hasNext()){
					Member curMember = iter.next();
					curMember.setSolicitationCd(marketCode);
				}
			}
						
			SortedSet<Rider> mbsRiders = membership.getPrimaryMember().getRiderList();
			Iterator<Rider> iter = mbsRiders.iterator();
			while (iter.hasNext()){
				Rider curRider = iter.next();
				if ("BS".equals(curRider.getRiderCompCd())) primBSRdrStatus = curRider.getStatus();
			}
			
			//first collect the coverage levels for the entire region
			ArrayList<String> orderBy = new ArrayList<String>();
			orderBy.add(CoverageLevel.RANK);
			coverageLevels = CoverageLevel.getAvailableCoverageLevelList(user, divisionKy, regionCd, orderBy, "STD");
			
			DuesCalculatorCostBP dcBP = BPF.get(user, DuesCalculatorCostBP.class); 
			
			int existingAMCount = membership.getNonCancelledMemberList().size() - 1;  
			
			//this is going to get all exists components for membership with existing billingCategoryCd and coverageLevel etc. 
			origCdArray =  dcBP.findRiderCosts(membership.getBillingCategoryCd(), commissionCd, existingAMCount, 
					membership.getCoverageLevelCd(), primBSRdrStatus, regionCd, divisionKy, branchKy, _origHashMap, passExpiration, membership, state);
			debug(origCdArray, "OLD", true);
			
			newCdArray =  dcBP.findRiderCosts(billingCategoryCd, commissionCd, totalFutureNoncancelledAMCount, 
					covLevCdUpperCase, primBSRdrStatus, regionCd, divisionKy, branchKy, new ValueHashMap(), passExpiration, membership, state);
			debug(newCdArray, "NEW~0", true);
			
			//non primary, AM, new requested to add. 
			int newAssociateCount = totalFutureNoncancelledAMCount - existingAMCount;
			
			finalCdArray = getFinalCostData(origCdArray, newCdArray, newAssociateCount, membership);
			debug(finalCdArray, "NEW~m", true);

			//because associate id was numbered differently as the real associate id in mzp. so we need to fix it.
			finalCdArray = fixCdArrayAssociateId(finalCdArray , membership, totalFutureNoncancelledAMCount);
			debug(finalCdArray, "NEW~s", true);
			
			//override existing riders with items from GetMembershipComponent dues, 
			//		also calculate refund if detect a downgrading coverage and overwrite the amount 
			finalCdArray = getFinalCostDataRefreshed(finalCdArray, membership);
			debug(finalCdArray, "NEW~r", true);
				
			covLvlDescr = membershipUtilBP.getCoverageByMZPType(covLevCdUpperCase);		
			colMdues = createMembershipDues(finalCdArray, totalFutureNoncancelledAMCount, coverageLevels, isExisting, membership, false);
			
		} catch (Exception e) {
			log.error("Error initializing membership in CalculateMembershipDues", e);
		}
	}
	
	private void setDiscounts(String marketCode) { 
		try {
			//set market code to the members in memory for dues calculation
			if (!nvl(marketCode).equals("")){ 
				discounts = getDiscount(marketCode, null);
			}
		} catch (Exception e) {
			
		}
	}
	
	private CostData[] getFinalCostData(CostData[] originalCosts, CostData[] newCosts, int newAssociateCount, Membership ms) throws Exception
	{
		//existing membership only, can be complicated; new enrollment won't come here. 
		//one click renewal won't come here. 
		
		ArrayList<CostData> finalCosts = new ArrayList<CostData>();
		
		//cancel associate is not considered at this moment. 
		if (newAssociateCount >= 0 && originalCosts != null && newCosts != null) {
			
			//add in all old, no matter whether it is in new. 
				//mark as downgrade, if not in new before adding to final. 
			for(CostData cd: originalCosts)
			{
				if (!inRenewal) {
					//current old one, if it is not in new, mark it as downgrade. 
					if (!hasSameRider(newCosts, cd)){
						cd.setDowngrading(true); 
					}
				}
				
				finalCosts.add(cd);
			}
			
			//add in all new upgrade not in old to final, mark it as upgrade. 
			for(CostData cd: newCosts)
			{
				//every item in newCosts but not in originalCosts should be considered a upgrade
				if (!hasSameRider(originalCosts, cd)){
					cd.setUpgrading(true);
					finalCosts.add(cd);
				} 
			}
			
			
			//Sort it by using comparable interface implementation 
			Collections.sort(finalCosts); 
		}
		return finalCosts.toArray(new CostData[finalCosts.size()]);
	}
	
	private void debug(CostData[] cds, String label, boolean flag) {
		if (flag) {
			String DEBUG_MODULE = "WM_DC_SC_" + label + "-" +Calendar.getInstance().getTimeInMillis() +"";
			
			MembershipUtilBP mubp = MembershipUtilBP.getInstance(); mubp.debug(DEBUG_MODULE, "" + cds.length, true);
			for(CostData cd: cds){
				mubp.debug(DEBUG_MODULE, cd.toShortString(), true);
			}	
		}
		
	}
	
	/**   CALCULATE DUES
	 * Calculate dues based on parameters and return a Member Dues Collection
	 * 
	 * @param usr
	 * @param Zip
	 * @return branch key big decimal
	 */
	public Collection<Discount> calculateMembershipDues(String zip, int assCnt, String covLevel, String marketCode, String billingCatCd, 
										BigDecimal branchKey, BigDecimal divisionKey, String regionCode, Membership ms, String state){
		String commissionCd = "";
		ValueHashMap _origHashMap = new ValueHashMap();
		CostData[] newCdArray = null;
		CostData[] finalCdArray = null;
		String primBSRdrStatus = "P";
		boolean isExisting  = true;
		Timestamp passExpiration = null;
		try {
			
			if(ms == null)
			{
				//This function for dues calculation won't waste membership id. 
				//This was used in production for a month, so remove previous version's switch.  
				ms = getMembershipEntryBP().buildMembershipForDuesCalculation();	
				
				ms.setBranchKy(branchKey);
				ms.setZip(zip);
				ms.setCoverageLevelCd(covLevel);
				ms.getPrimaryMember().getBasicRider().setCostEffectiveDt(DateUtilities.getTimestamp(true));
				ms.getPrimaryMember().setParentMembership(ms);
				ms.setBillingCategoryOnAll(billingCatCd);							
				isExisting = false;
			}
			
			passExpiration = ms.getPrimaryMember().getMemberExpirationDt();
			
			//set initial membership info based on parameters
			String rC = regionCode;						
			commissionCd = "N";
			
			//reset market code if needed when market code passed in is empty and membership exists
			if (isExisting) {
				//TODO: get membership's current market code  
				//one click renewal will come here because method "CalculateMembershipDuesByMarketCode" is called
				if (marketCode==null || marketCode.trim().equals("")){
					marketCode = null; //getMembershipMarketCode(ms);
				}
			}
			
			if (marketCode != null){
				SortedSet<Member> mbsMembers = ms.getNonCancelledMemberList();
				Iterator<Member> iter = mbsMembers.iterator();
				while (iter.hasNext()){
					Member curMember = iter.next();
					curMember.setSolicitationCd(marketCode);
				}
				discounts = getDiscount(marketCode, null);
			}
						
			SortedSet<Rider> mbsRiders = ms.getPrimaryMember().getRiderList();
			Iterator<Rider> iter = mbsRiders.iterator();
			while (iter.hasNext()){
				Rider curRider = iter.next();
				if ("BS".equals(curRider.getRiderCompCd())) primBSRdrStatus = curRider.getStatus();
			}
			
			//first collect the coverage levels for the entire region
			ArrayList<String> orderBy = new ArrayList<String>();
			orderBy.add(CoverageLevel.RANK);
			SortedSet<CoverageLevel> coverageLevels = CoverageLevel.getAvailableCoverageLevelList(user, divisionKey, regionCode, orderBy, "STD");
			DuesCalculatorCostBP dcBP = BPF.get(user, DuesCalculatorCostBP.class); 
			
			int newAssociateCount = 0; //final result should be associate count besides existing associate members (not include primary). 
			
			if(isExisting)
			{
				//Prakash - 07/20/2018 - Dues By State - Start
				origCdArray =  dcBP.findRiderCosts(ms.getBillingCategoryCd(), commissionCd, ms.getNonCancelledMemberList().size() - 1, ms.getCoverageLevelCd(),
						primBSRdrStatus, rC, divisionKey, branchKey, _origHashMap, passExpiration, ms, state);
				//Prakash - 07/20/2018 - Dues By State - End
				
				int existingAssociateCount = ms.getNonCancelledMemberList().size() -1;
				newAssociateCount = assCnt - existingAssociateCount;
			}
			else
			{
				origCdArray = new CostData[0];
			}
			//Prakash - 07/20/2018 - Dues By State - Start
			newCdArray =  dcBP.findRiderCosts(billingCatCd, commissionCd, assCnt, covLevel,	primBSRdrStatus, rC, divisionKey, branchKey, new ValueHashMap(), passExpiration, ms, state);
			//Prakash - 07/20/2018 - Dues By State - End
			if (isExisting) {
				finalCdArray = getFinalCostData(origCdArray, newCdArray, newAssociateCount, ms);

				//because associate id was numbered differently as the real associate id in mzp. so we need to fix it.
				finalCdArray = fixCdArrayAssociateId(finalCdArray , ms, assCnt);  	
				
				//override existing riders with items from GetMembershipComponent dues, also calculate refund if detect a downgrading coverage and overwrite the amount 
				finalCdArray = getFinalCostDataRefreshed(finalCdArray, ms);
				
			} else {
				finalCdArray = newCdArray;
			}
			
			covLvlDescr = membershipUtilBP.getCoverageByMZPType(covLevel);		
			colMdues = createMembershipDues(finalCdArray, assCnt, coverageLevels, isExisting, ms, false);
			
		} catch (Exception e) {
			log.error("Error initializing membership in CalculateMembershipDues", e);
		}
		
		return discounts;
	}
	
	private CostData[] getFinalCostDataRefreshed(CostData[] newCdArrays, Membership ms) throws Exception {
		CostData[] existingCdArray = null;
		
		//if (!ms.isActive()) {
			//get dues structure from GetMembershipComponentDues, then extract cd array items from the dues structure and then put them into the newCdAarrays
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			
			GetMembershipComponentDuesRequest cdRequest = new GetMembershipComponentDuesRequest();
			SimpleMembershipNumber nm = new SimpleMembershipNumber();
			nm.setFullNumber("438212" +ms.getPrimaryMember().getMembershipId() + ms.getPrimaryMember().getAssociateId() + ms.getPrimaryMember().getCheckDigitNr());
			cdRequest.setMemberID(nm);
			
			//get default sales agent
			MembershipServiceBP serviceBp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			String salesAgentId =   serviceBp.getSetting("defaultSalesAgent");
			cdRequest.setSalesAgentID(salesAgentId);
			
			GetMembershipComponentDuesResponse cdResponse = bp.GetMembershipComponentDues(cdRequest); 
			MembershipComponentDues mcDues = cdResponse.getMembershipComponentDues();
			
			MemberComponentDues[] mDuesArray = mcDues.getMemberComponentDues();
			
			//handle donations also, this is a side job
			for (MemberComponentDues mDues: mDuesArray){
				String memberType = mDues.getMember().fetchMzPAssociateType();
				
				if (memberType.equalsIgnoreCase("P")) {
					if (mDues.getDonations()!=null && mDues.getDonations().length > 0) {
						donations = new ArrayList(Arrays.asList(mDues.getDonations()));
					}
				} 
			}
			
			String regionCd = membershipUtilBP.getRegionCd(ms.getZip());
					
			//first collect the coverage levels for the entire region
			ArrayList<String> orderBy = new ArrayList<String>();
			orderBy.add(CoverageLevel.RANK);
			SortedSet<CoverageLevel> coverageLevels = CoverageLevel.getAvailableCoverageLevelList(user, ms.getDivisionKy(), regionCd, orderBy, "STD");

			existingCdArray = extractCdArray(mcDues);
			existingCdArray = sortCdArray(existingCdArray, coverageLevels);
			
			for(int i= 0; i < newCdArrays.length; i++)
			{
				 CostData cd = newCdArrays[i]; 
				 if (!cd.isDowngrading() && !cd.isUpgrading()) {
					 //existing rider
					String associateID = cd.getAssociateIdRD();
					String riderCompCd = cd.getRiderCompCd();
					 
					for(int j= 0; j < existingCdArray.length; j++)
					{
						CostData cde = existingCdArray[j];
						if (cde.getAssociateIdRD().equalsIgnoreCase(associateID) && cde.getRiderCompCd().equalsIgnoreCase(riderCompCd)) {
							cd.setFullCostRD(cde.getProratedCost());
							break;
						}
					}
				 }
			}
		//}
		
		//dealing with down grading for mc riders if they are marked as down grading. 
		CancelBP cancelBP = BPF.get(User.getGenericUser(), CancelBP.class);
		
	    Timestamp today = new Timestamp(DateUtils.today().getTime()); 
		
		SortedSet<Member> members = ms.getNonCancelledMemberList();
		
		for(int i= 0; i < newCdArrays.length; i++)
		{
			CostData cd = newCdArrays[i]; 
			 if (cd.isDowngrading() ) {
				String associateID = cd.getAssociateIdRD();
				String riderCompCd = cd.getRiderCompCd();
				
				for (Member m: members) {
					if (m.getAssociateId().equals(associateID)) {
						SortedSet<Rider> riders = m.getRiderList(true);
						
						for (Rider r: riders) {
							if (r.getRiderCompCd().equals(riderCompCd)){
								BigDecimal creditAt = cancelBP.calculateCreditAmount(r, today);
								cd.setFullCostRD(creditAt);
							}
						}
					}
				}
			 }
		}
		
		return newCdArrays;
	}

	//copied from MembershipServiceBP.java for getMembershipComponentDues.
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
	
	public ArrayList<Donation> getDonations() {
		return donations;
	}
	
	private CostData[] fixCdArrayAssociateId (CostData[] origCdArray, Membership ms, int assCnt) throws Exception{
		if (ms == null || ms.getStatus().equals("C"))  return origCdArray;  
		
		ArrayList<CostData> finalCosts = new ArrayList<CostData>();
		ArrayList<CostData> origCosts = new ArrayList<CostData>(Arrays.asList(origCdArray));
		
		//prepare order by criteria for get the member list
		ArrayList<String> orderBy = new ArrayList<String>();
		orderBy.add(Member.ASSOCIATE_ID +" ASC");
		
		//how many active members in the existing membership
		int nonCancelCount = 0; 
		for(Member member: ms.getNonCancelledMemberList()){
			nonCancelCount++;
		}
		
		//existing members max associate ID
		int idMax = 0;
		for (Member m: ms.getMemberList(null, orderBy, true)) {
			int tId1 = Integer.parseInt(stripLeadingZero(m.getAssociateId()));
			
			if (idMax< tId1){
				idMax = tId1;
			}
		}
		
		assCnt = assCnt + 1;
		
		if (assCnt == nonCancelCount) {
			//upgrade, like BS to PL
			for (Member m: ms.getNonCancelledMemberList() ) {
				if (m.getStatus().equals("C")){
					continue;
				}
				
				String associateId = m.getAssociateId();
				
				//primary member 
				if (m.getMemberTypeCd().equals("P")){
					for (Iterator<CostData> iterator = origCosts.iterator(); iterator.hasNext();) {
						CostData cd = iterator.next();
						if (cd.getAssociateId().equals("1")&& cd.getMemberType().equals("P")){
							cd.setAssociateIdRD(associateId);
							finalCosts.add(cd);
							iterator.remove();	//remove it from the origCosts safely by iterator
						}
					}
				} else {
					//if 0, means not initialized; if other than 0, only process the cdArray item with the same id
					int iCurrentCdId = 0;
					
					for (Iterator<CostData> iterator = origCosts.iterator(); iterator.hasNext();) {
						CostData cd = iterator.next();
						
						int iCdAssociateId = Integer.parseInt(cd.getAssociateId());
						if (iCurrentCdId == 0 ) {
							iCurrentCdId = iCdAssociateId;
						}
						
						if (iCdAssociateId>1 && cd.getMemberType().equals("A") ){
							if (iCdAssociateId == iCurrentCdId) {
								cd.setAssociateIdRD(associateId);
								finalCosts.add(cd);
								iterator.remove();	//remove it from the origCosts safely by iterator	
							} 
						}
					}
				}
			}
		} else if (assCnt > nonCancelCount) {
			//-- means adding associates, no primary member's cd item involved. 
			//use idMax+1 for the next associateIdRD
			
			//process the riders of existing members first.
			for (Member m: ms.getNonCancelledMemberList() ) {
				if (m.getStatus().equals("C")){
					continue;
				}
				
				String associateId = m.getAssociateId();
				
				//primary member 
				if (m.getMemberTypeCd().equals("P")){
					for (Iterator<CostData> iterator = origCosts.iterator(); iterator.hasNext();) {
						CostData cd = iterator.next();
						if (cd.getAssociateId().equals("1")&& cd.getMemberType().equals("P")){
							cd.setAssociateIdRD(associateId);
							finalCosts.add(cd);
							iterator.remove();	//remove it from the origCosts safely by iterator
						}
					}
				} else {
					//if 0, means not initialized; if other than 0, only process the cdArray item with the same id
					int iCurrentCdId = 0;
					
					for (Iterator<CostData> iterator = origCosts.iterator(); iterator.hasNext();) {
						CostData cd = iterator.next();
						
						int iCdAssociateId = Integer.parseInt(cd.getAssociateId());
						if (iCurrentCdId == 0 ) {
							iCurrentCdId = iCdAssociateId;
						}
						
						if (iCdAssociateId>1 && cd.getMemberType().equals("A") ){
							if (iCdAssociateId == iCurrentCdId) {
								cd.setAssociateIdRD(associateId);
								finalCosts.add(cd);
								iterator.remove();	//remove it from the origCosts safely by iterator	
							} 
						}
					}
				}
			}
			
			int newAssociate = assCnt - nonCancelCount;
			
			for (int i=0; i< newAssociate; i++) {
				//if 0, means not initialized; if other than 0, only process the cdArray item with the same id
				int iCurrentCdId = 0;
				
				for (Iterator<CostData> iterator = origCosts.iterator(); iterator.hasNext();) {
					CostData cd = iterator.next();
					
					int iCdAssociateId = Integer.parseInt(cd.getAssociateId());
					if (iCurrentCdId == 0 ) {
						iCurrentCdId = iCdAssociateId;
					}
					
					if (iCdAssociateId>1 && cd.getMemberType().equals("A") ){
						if (iCdAssociateId == iCurrentCdId) {
							cd.setAssociateIdRD(getNextNewAssociateIdRD(idMax));
							finalCosts.add(cd);
							iterator.remove();	//remove it from the origCosts safely by iterator	
						} 
					}
				}
				
				idMax++;
			}
			
		}
		
		return finalCosts.toArray(new CostData[finalCosts.size()]);
	}
	
	private String getNextNewAssociateIdRD (int idMax) {
		idMax++;
		if (idMax< 10) {
			return "0" + idMax;
		} else {
			return "" + idMax;
		}
	}
	
	private ArrayList<String> getUpgradeableCoverages(String baseCoverageLevelCd, String source) {
		ArrayList<String> covs = new ArrayList<String>();
		
		MembershipUtilBP utilBp = MembershipUtilBP.getInstance();
		covs = utilBp.getUpgradeableCoverages(baseCoverageLevelCd, source);
		
		return covs;
	}
	
	/*
	//this function is used by one click renewal only
	public Collection<Discount>  CalculateMembershipDuesByMarketCode (MembershipComponentDues mcDues, String renewalMarketCode, Membership ms, BigDecimal divisionKey, 
			String regionCode)
	{
		try {
			CostData[] finalCdArray = null;
			boolean isExisting  = true;
			
			if (renewalMarketCode != null){
				discounts = getDiscount(renewalMarketCode, divisionKey);
			}
			
			//first collect the coverage levels for the entire region
			ArrayList<String> orderBy = new ArrayList<String>();
			orderBy.add(CoverageLevel.RANK);
			SortedSet<CoverageLevel> coverageLevels = CoverageLevel.getAvailableCoverageLevelList(user, divisionKey, regionCode, orderBy, "STD");

			finalCdArray = extractCdArray(mcDues);
			finalCdArray = sortCdArray(finalCdArray, coverageLevels);
			covLvlDescr = membershipUtilBP.getCoverageByMZPType(ms.getCoverageLevelCd());	
			colMdues = createMembershipDues(finalCdArray, ms.getCurrentMemberList().size() - 1, coverageLevels, isExisting, ms, true);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		return discounts;
	}
	*/
	
	private CostData[] sortCdArray (CostData[] costDataArray, SortedSet<CoverageLevel> coverageLevels) {
		ArrayList<CostData> al = new ArrayList<CostData> ();
		for (CostData cd: costDataArray) {
			al.add(cd);
		} 
		
		ArrayList<CostData> alFinal = new ArrayList<CostData> ();
		
		String associateID = "";
		
		ArrayList<CostData> alMember = new ArrayList<CostData>(); 
		for (int i=0; i<al.size(); i++) {
			CostData c = (CostData) (al.get(i)) ;
			
			String aID = c.getAssociateId();
			if (!aID.equals(associateID)){
				associateID = aID; 
				
				//when it is an item of a new member, add the items of alMember to the final return arraylist 
				for (CostData c1: alMember) {
					alFinal.add(c1);
				}
				
				//reinitialize the alMember
				alMember = new ArrayList<CostData> ();
				alMember.add(c);
			}  else {
				alMember.add(c);
				sortCdArrayByMember (alMember, coverageLevels);
			}
		}
		
		//This is for the last member's Cost Data
		if (alMember!=null && alMember.size()>0) {
			for (CostData c1: alMember) {
				alFinal.add(c1);
			}
		}
		
		//Now everything is in the ArrayList, need to return an array.
		return alFinal.toArray(new CostData[alFinal.size()]);
	}
	
	private ArrayList<CostData> sortCdArrayByMember ( ArrayList<CostData> alCdArrayMember, SortedSet<CoverageLevel> coverageLevels) {
		if (alCdArrayMember==null || alCdArrayMember.size()==0) {
			return new ArrayList<CostData>();
		}
		
		CostData cdC = alCdArrayMember.get(0);
		int rankC = getCoverageLevelRank (alCdArrayMember.get(0).getRiderCompCd(), coverageLevels);
		
		for (int i = 1 ; i< alCdArrayMember.size(); i++) {
			CostData cdT = alCdArrayMember.get(i);
			int rankT = getCoverageLevelRank (cdT.getRiderCompCd(), coverageLevels);
			
			if (rankC > rankT) {
				//swap only when current is higher then next
				alCdArrayMember.set(i-1, cdT);
				alCdArrayMember.set(i, cdC);
			} else {
				//stop sorting because it is in the right order already.
				break;
			}
		}
		
		return alCdArrayMember;
	}
	
	private int getCoverageLevelRank (String coverageLevel, SortedSet<CoverageLevel> coverageLevels) {
		try {
			BigDecimal rankBD = null;
			for (CoverageLevel cl: coverageLevels) {
				if (cl.getCoverageLevelCd().equalsIgnoreCase(coverageLevel)) {
					 rankBD = cl.getRank();
					 break;
				}
			}
			
			return new Integer(rankBD.toString());	
		} catch(Exception e) {
			e.printStackTrace();
		}
		return 0;
		
	}
	
	
	public CostData[] extractCdArray (MembershipComponentDues mcDues) {
		MemberComponentDues[] mDuesArray = mcDues.getMemberComponentDues();
		
		ArrayList<CostData> returnCosts = new ArrayList<CostData>();
		
		int associateCount = 1;
		
		for (MemberComponentDues mDues: mDuesArray){
			String memberType = mDues.getMember().fetchMzPAssociateType();
			
			String associateId = "";
			
			if (memberType.equalsIgnoreCase("P")) {
				associateId = "1";
			} else {
				associateCount ++;
				associateId = new Integer(associateCount).toString();
			}
			
			for (com.aaa.soa.object.models.Rider r: mDues.getRiders()) {
				CostData cd = new CostData();
				cd.setRiderCompCd(membershipUtilBP.getCoverageByWsType(r.getType()));
				cd.setFullCostRD(r.getAmountDue());
				cd.setEnrollmentFeeDC(new BigDecimal("0.00"));
				cd.setMemberType(memberType);
				cd.setAssociateId(associateId);
				cd.setAssociateIdRD(mDues.getMember().getNumber().getAssociateId());
				returnCosts.add(cd);
			}
		}
		
		return returnCosts.toArray(new CostData[returnCosts.size()]);
	}
	
	
	
	/**
	 * Create and return a collection of member dues from the cost data array.
	 * 
	 * @param cdArray
	 * @param assCnt
	 * @return colMdues
	 */
	private  Collection<MemberDues> createMembershipDues(CostData[] cdArray, int assCnt, SortedSet<CoverageLevel> coverageLevels, boolean isExistingMembership, Membership ms, boolean isRenewal) {
		Collection<DuesCostItem> colDCI;
		Collection<MemberDues> colMdues = new ArrayList<MemberDues>();
		int memberCnt = assCnt + 2;
		try{
			if (isExistingMembership){
				initializeAppliedDiscountHashMap (ms);
			}
			
			
			//Loop through array and and create collection of member dues
			for (int i = 1; i < memberCnt; i++){
				colDCI = new ArrayList<DuesCostItem>();
				
				String associateID = "";
				
				
				String covLvl = "";
				for (CostData cd : cdArray){
					if (cd.getAssociateId().equals(String.valueOf(i))){
						for(CoverageLevel cl : coverageLevels){
							if(cl.getCoverageLevelCd().equals(cd.getRiderCompCd())){
								covLvl = cl.getCoverageLevelCd();
								break;
							}
						}
						
						associateID = stripLeadingZero(cd.getAssociateIdRD());
						
						//look up coverage level from WS/MZP conversion list [KO]
						String covLvlDescription = "";
						covLvlDescription = membershipUtilBP.getCoverageByMZPType(covLvl);
						
						if(isExistingMembership)
						{
							if (cd.isDowngrading()){
								colDCI.add(new DuesCostItem(cd.getRiderCompCd(), covLvlDescription, cd.getProratedCost().negate(), new BigDecimal("0.00")));
							} else {
								if(discounts != null && discounts.size() > 0){
									colDCI.add(new DuesCostItem(cd.getRiderCompCd(), covLvlDescription, calculateCostDataWithDiscount(cd, i, false, cd.getProratedCost(), ms, isRenewal), new BigDecimal("0.00")));								
								} else {								
									colDCI.add(new DuesCostItem(cd.getRiderCompCd(), covLvlDescription, cd.getProratedCost(), new BigDecimal("0.00")));
								}
								
								
							}
							
						}
						else
						{
							//if discounts list is not empty, let's see if we can apply to this set of dues 
							if(discounts != null && discounts.size() > 0){
								colDCI.add(new DuesCostItem(cd.getRiderCompCd(), covLvlDescription, calculateCostDataWithDiscountNew(cd, i, true), cd.getEnrollmentFee()));								
							} else {								
								colDCI.add(new DuesCostItem(cd.getRiderCompCd(), covLvlDescription, cd.getFullCost(), cd.getEnrollmentFee()));
							}
						}
						
					}
				}
				if (isExistingMembership){
					if (colDCI.size()>0) {
						if (associateID.equals("")) {
							colMdues.add(new MemberDues((i-1), (i==1)? "Primary" : "Associate", colDCI));	
						} else {
							colMdues.add(new MemberDues(Integer.parseInt(associateID), (i==1)? "Primary" : "Associate", colDCI));
						}	
					}
				} else {
					colMdues.add(new MemberDues((i-1), (i==1)? "Primary" : "Associate", colDCI));	
				}
					
			}
						
		} catch (Exception e) {
			log.error("Error initializing collection of member dues in CalculateMembershipDues", e);
		}		
		
		return colMdues;
	}

	
	private String stripLeadingZero(String associateID) {
		
		if (associateID!=null && associateID.length()== 2 && associateID.startsWith("0")){
			return associateID.substring(1);
		} else {
			return associateID;
		}
		
	}
		
	private  SortedSet<RiderDefinition> getMemberLevelRiderList(BigDecimal divisionKey, String regionCd, Membership membership, SortedSet<RiderDefinition> memberRiderList){
		if (memberRiderList == null){
			try{
				memberRiderList = RiderDefinition.getLevelRiderDefinitionList(user, divisionKey, regionCd, RiderDefinition.APPLIES_TO_MEMBER, true);
			}
			catch (java.sql.SQLException e){
				log.error(StackTraceUtil.getStackTrace(e));
				log.error("Setting Member Level Rider VO empty");
				memberRiderList = null;
			}
			
		}
		return memberRiderList;
	}
	
	
//	private  void buildOrigHashMap(Membership membership, ValueHashMap _origHashMap){
//		
//		int origAssociateCount = 0;
//		try{
//			Iterator<Member> memberIterator = membership.getMemberList().iterator();
//			origAssociateCount = 0;
//			int i = -1;
//			while (memberIterator.hasNext()){
//				i++;
//				Member curMember = memberIterator.next();
//				if (!curMember.getStatus().equals("C")) origAssociateCount++;
//
//				SortedSet<RiderDefinition> tempList = getMemberLevelRiderList(membership.getDivisionKy(), membership.getRegionCode(), membership, memberRiderList);
//				for (RiderDefinition def : tempList){
//					String memType = curMember.getMemberTypeCd();
//					String riderCode = def.getRiderCompCd();
//	
//					SortedSet<Rider> riders = new TreeSet<Rider>();
//					for(Rider r: curMember.getNonCancelledRiderListFromCache()){
//						if(r.getRiderCompCd().equals(riderCode)){
//							riders.add(r);
//						}
//					}
//					Iterator<Rider> riderIterator = riders.iterator();
//					//JZ - This is priceless - I don't know who did it but it made me laugh - so I saved it for you
//					for (; riderIterator.hasNext();){
//						Rider Rdr = riderIterator.next();
//
//						log.debug("status:" + Rdr.getStatus());
//						if (riders.size() > 0){
//							if ("P".equals(Rdr.getStatus()) || "A".equals(Rdr.getStatus())){
//								String key = memType + ":" + riderCode + ":" + "A" + ":" + (i + 1);
//								_origHashMap.putInt(key, 1);
//							}
//						}
//					}
//				}
//			}
//		}
//		catch (Exception e){
//			log.error("error in DuesCalculatorBean: " + StackTraceUtil.getStackTrace(e));
//		}
//		log.debug("ORIGINAL HASHMAP " + _origHashMap.toString());
//	}
	
	
	
	private CostData[] getFinalCostDataOld(CostData[] originalCosts, CostData[] newCosts, int newAssociateCount, Membership ms) throws Exception
	{
		//existing membership only, can be complicated; new enrollment won't come here. 
		//one click renewal won't come here. 
		
		ArrayList<CostData> finalCosts = new ArrayList<CostData>();
		
		//cancel associate is not considered at this moment. 
		if (newAssociateCount >= 0 && originalCosts != null && newCosts != null) {
			if (newAssociateCount > 0) {
				//if newAssociateCount > 0, means adding associate, 
				//and after that there is no downgrade item possible 
				for(int i= 0; i < newCosts.length; i++)
				{
					//every item in newCosts but not in originalCosts should be considered a upgrade
					if (!hasSameRider(originalCosts, newCosts[i])){
						CostData cd = newCosts[i];
						cd.setUpgrading(true);
						finalCosts.add(newCosts[i]);
					} else {
						//existing coverages, add it as place holder. dues need to be calculated differently 
						finalCosts.add(newCosts[i]);
					}
				}
			} else {
				//if in this block, it should be a coverage upgade. So MC membership has downgrade.
				//but if membership is Basic, then there can be a upgrade to MC. 
				
				//to handle new rider level
				for(int i= 0; i < newCosts.length; i++)
				{
					if (!hasSameRider(originalCosts, newCosts[i])){
						CostData cd = newCosts[i];
						cd.setUpgrading(true);
						finalCosts.add(newCosts[i]);
					} else {
						//existing coverages, add it as place holder. dues need to be calculated differently 
						finalCosts.add(newCosts[i]);
					}
				}
				
				//to handle downgraded MC level, this is for place holding purpose also, because we need to calculate refund later. 
				boolean inRenewal = false;
				
				Member pm = ms.getPrimaryMember();
				if (ms.isPending()){
					inRenewal = (!"NM".equalsIgnoreCase(ms.getBillingCd()));  /*as long as code is not NM*/
					inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
				}		
				
				if (!inRenewal) {
					for(int i= 0; i < originalCosts.length; i++)
					{
						if (!hasSameRider(newCosts, originalCosts[i])){
							CostData cd = originalCosts[i];
							cd.setDowngrading(true);
							
							finalCosts.add(cd);
						}
					}
				}
			}
		
		}
		return finalCosts.toArray(new CostData[finalCosts.size()]);
	}
	
	
	
	//Copied from RiderBP [KO]  - existing membership
	//isNew value true means to find discounts applied to the new membership
	//		otherwise, will find discounts applied to the existing membership
	private BigDecimal calculateCostDataWithDiscount(CostData c, int associateNum, boolean isNew, BigDecimal cost, Membership ms, boolean isRenewal) {
		//YH - associateNum 1 means it is primary. 
		//CostData coming to this function are for the new riders either added by add_member or upgrade coverage. 
		BigDecimal result = cost;
		boolean noCalculationNeeded = false;  //false means need to calculate the difference. 
		
		//if there is no discounts for this solicitation, return full cost of the cost data; if cost is 0, then return 0 back without consider the discounts. 
		if (discounts == null) {
			return result;
		}
		
		if ( result.compareTo(BigDecimal.ZERO)==0) {
			noCalculationNeeded = true;			//true means that we still need to increase the applied count but don't need to consider the discount in the cost difference. 
		}
		
		try {
			for (Discount d: discounts) {
				if (!StringUtils.blanknull(d.getMemberTypeCd()).equals(c.getMemberType()) && 
					!StringUtils.blanknull(d.getRiderCompCd()).equals(c.getRiderCompCd()) ) {
						continue;
				}
				
				//only recalculate the cost when member type and rider comp cd match
				int applyToCount = 0; 
				if (d.getMemberCount() !=null ) {
					applyToCount = d.getMemberCount().intValue();
				} else {
					if (d.getAppliesTo().equals("MBR") || d.getAppliesTo().equals("RDR") ) {
						applyToCount = 1;
					}
				}
				
				boolean isPercent = d.getPercentFl();
				BigDecimal amount = d.getAmount();
				
				boolean isNewAtOnly = d.getNewOnlyFl();
				boolean isToApply = false; 
				
				//called from upgrade such as addmember or upgrade coverage				
				if (isNewAtOnly && !isRenewal) {
					if (d.getAppliesTo().equals("RDR") && !isRiderExisting(ms, c.getAssociateIdRD(), c.getRiderCompCd())) {
						isToApply = true;	
					} else if (d.getAppliesTo().equals("MBR") && !isMemberExisting(ms, c.getAssociateIdRD())) {
						isToApply = true;	
					}
					
				}
				
				//called from getmembershipBalanceByMarketCode
				if (!isNewAtOnly && isRenewal) {
					isToApply = true;
				}
				
				//YH - if not isNew, means existing membership. 
				//TODO: Enrollment calculation won't come here, parameter can be removed later.
				if (!isNew )
				{ 
					if (isToApply){
						
						//for discount applied to associate only need to compare the appliedDiscount count. 
						if (applyToCount <= getAppliedDiscountCount(d.getDiscountCd())){
							continue;
						}
						
						if (d.getAppliesTo().equals("MBR") ) {
							if (StringUtils.blanknull(d.getMemberTypeCd()).equals(c.getMemberType())) {
								if (StringUtils.blanknull(d.getRiderCompCd()).trim().equals("")){
									if (!isPercent) {
										//absolute amount discount, deduct it once
										if (!noCalculationNeeded) {
											result = result.subtract(amount);	
										}
										//since there is not rider comp cd defined in the discount, increased the applied count only once per membership. 
										if (c.getRiderCompCd().equalsIgnoreCase(ms.getCoverageLevelCd())) {
											appliedDiscount.put(d.getDiscountCd(), appliedDiscount.getInt(d.getDiscountCd()) +1);	
										}
										
									} else {
										if (!noCalculationNeeded) {
											result = result.subtract(result.multiply(amount).divide(new BigDecimal("100")));	
										}
										
										//if it is percentage type of discount, and without rider comp cd, increased the applied count only for the highest coverage level. 
										if (c.getRiderCompCd().equalsIgnoreCase(ms.getCoverageLevelCd())) {
											appliedDiscount.put(d.getDiscountCd(), appliedDiscount.getInt(d.getDiscountCd()) +1);
										}
									}	
								} 
								else if (StringUtils.blanknull(d.getRiderCompCd()).equals(c.getRiderCompCd())) {
									if (!isPercent) {
										if (!noCalculationNeeded) {
											result = result.subtract(amount);											
										}
									} else {
										if (!noCalculationNeeded) {
											result = result.subtract(result.multiply(amount).divide(new BigDecimal("100")));	
										}
									}	
									
									appliedDiscount.put(d.getDiscountCd(), appliedDiscount.getInt(d.getDiscountCd()) +1);
								}
							}
						} else if (d.getAppliesTo().equals("RDR") ) {
							//rider level discount.
							
							if (StringUtils.blanknull(d.getMemberTypeCd()).equals(c.getMemberType()) && 
									StringUtils.blanknull(d.getRiderCompCd()).equals(c.getRiderCompCd()) ) 
							{
								if (!isPercent) {
									if (!noCalculationNeeded) {
										result = result.subtract(amount);	
									}
								} else {
									if (!noCalculationNeeded) {
										result = result.subtract(result.multiply(amount).divide(new BigDecimal("100")));	
									}
								}
								appliedDiscount.put(d.getDiscountCd(), appliedDiscount.getInt(d.getDiscountCd()) +1);
							}
						}
					}
				}	
			}
		} catch (Exception e) {
			log.error("Dues Calculator : Discount Error");
			log.error(StackTraceUtil.getStackTrace(e));
		}
		return result;
	}
	
	//Copied from RiderBP [KO] - enrollment
	//isNew value true means to find discounts applied to the new membership
	//		otherwise, will find discounts applied to the renewed membership
	private BigDecimal calculateCostDataWithDiscountNew(CostData c, int associateNum, boolean isNew) {
		BigDecimal result = c.getFullCost();
		
		//if there is no discounts for this solicitation, return full cost of the cost data 
		if (discounts == null) {
			return result;
		}
		
		try {
			for (Discount d: discounts) {
				if (!StringUtils.blanknull(d.getMemberTypeCd()).equals(c.getMemberType()) || 
					!StringUtils.blanknull(d.getRiderCompCd()).equals(c.getRiderCompCd()) ) {
						continue;
				}
				
				//only recalculate the cost when member type and rider comp cd match
				
				int applyToCount = d.getMemberCount().intValue();
				if (d.getMemberTypeCd().equals("A") && applyToCount < (associateNum-1)){
					return result;
				}
				
				boolean isPercent = d.getPercentFl();
				BigDecimal amount = d.getAmount();
				
				boolean isApplyRenewalAt = d.getApplyAtRenewalFl();
				boolean isRenewalAtOnly = d.getRenewOnlyFl();
				boolean isNewAtOnly = d.getNewOnlyFl();
				
				if (isNew && isNewAtOnly){
					if (!isPercent) {
						result = result.subtract(amount);
					} else {
						result = result.subtract(result.multiply(amount).divide(new BigDecimal("100")));
					}
				}
				
				if (!isNew  && (isRenewalAtOnly || isApplyRenewalAt)) {
					if (!isPercent) {
						result = result.subtract(amount);
					} else {
						result = result.subtract(result.multiply(amount).divide(new BigDecimal("100")));
					}
				}
			}
		} catch (Exception e) {
			log.error("Dues Calculator : Discount Error");
			log.error(StackTraceUtil.getStackTrace(e));
		}
		return result;
	}	
	
	private boolean isRiderExisting(Membership ms, String associateID, String riderCompCD) throws Exception {
		boolean isResult = false;
		if (ms != null && ! ms.getStatus().equals("C")) {
			SortedSet<Member> members = ms.getNonCancelledMemberList();
			for (Member m: members) {
				if (m.getAssociateId().equals(associateID)) {
					SortedSet<Rider> riders = m.getRiderList();
					for (Rider r: riders) {
						if (!r.getStatus().equals("C") && r.getRiderCompCd().equalsIgnoreCase(riderCompCD)){
							isResult = true;
							break;
						}
					}
					
					if (isResult) {
						break;
					}
				}
			}
		}
		
		return isResult;
	}
	
	private boolean isMemberExisting(Membership ms, String associateID) throws Exception {
		boolean isResult = false;
		if (ms != null && ! ms.getStatus().equals("C")) {
			SortedSet<Member> members = ms.getNonCancelledMemberList();
			for (Member m: members) {
				if (m.getAssociateId().equals(associateID)) {
					isResult = true;
					break;
				}
			}
		}
		
		return isResult;
	}
	
	
	//discounts has the member count property. This is to search the discount history of existing members for each discount and sum up the times 
	// has been used before. The result is stored in a hash map and used in the discount calculation of the final cost data later. 
	private void initializeAppliedDiscountHashMap(Membership ms) {
		if (discounts == null){
			return;
		}
		try {
			for (Discount d: discounts) {
				int appliedTimes = 0;
				if (d.getMemberTypeCd()!=null && !d.getMemberTypeCd().equals("A")) continue;
				
				//int memberCount = d.getMemberCount().intValue();
				
				if (d.getAppliesTo()!=null && d.getAppliesTo().equals("MBR")) {
					for (Member m: ms.getCurrentMemberList()) {
						if (hasRelatedDiscountHistory(d.getDiscountKy(), m)){
							appliedTimes ++;
						}
					}
				} else if (d.getAppliesTo()!=null && d.getAppliesTo().equals("RDR")) {
					String riderCompCd = d.getRiderCompCd();
					
					for (Member m: ms.getCurrentMemberList()) {
						for (Rider r: m.getRiderList()) {
							if (r.getRiderCompCd().equals(riderCompCd)) {
								if (hasRelatedDiscountHistory(d.getDiscountKy(), r)){
									appliedTimes ++;
								}	
							}
						}
					}
				}
				
				//after looping through existing records, initial the discount entry in the map with applied times
				appliedDiscount.put(d.getDiscountCd(), appliedTimes);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	//get the discount applied time of a particular discount. 
	//This will count for discount applied to members already exist or previous "new" member of this dues calculating process. 
	private int getAppliedDiscountCount(String discountCd) {
		return appliedDiscount.getInt(discountCd);
	}
	
	//parameter o can be either a member or rider depends on the discount type of "MBR" or "RDR"
	private boolean hasRelatedDiscountHistory(BigDecimal discountKy, Object o) throws Exception{
		if (o instanceof Member) {
			Member m = (Member) o; 
			for (DiscountHistory dh: m.getDiscountHistoryList()) {
				if (dh.getDiscountKy().equals(discountKy)) {
					return true;
				}
			}
		} else if (o instanceof Rider) {
			Rider r = (Rider) o;
			for (DiscountHistory dh: r.getDiscountHistoryList()) {
				if (dh.getDiscountKy().equals(discountKy)) {
					return true;
				}
			}
		}
		
		return false; 
	}

	public Collection<Discount> getDiscount(String solicitationCd, BigDecimal divisionKy) throws Exception{
		if (solicitationCd == null || solicitationCd.trim().equals("")) {
			return null;
		}
		Solicitation s = Solicitation.getSolicitation(user, solicitationCd);
		//wwei webmember ARxx issue fix	
		SearchCondition sc = new SearchCondition(SolicitationDiscount.DISCOUNT_CD, +SearchCondition.NOT+ SearchCondition.LIKE, "AR%");
		
		ArrayList<SearchCondition> conds = new ArrayList<SearchCondition>();
		conds.add(sc);		
		SortedSet<SolicitationDiscount> sds= s.getSolicitationDiscountList(conds, null);
		
		ArrayList discountCds = new ArrayList();
       
		for (SolicitationDiscount sd: sds) {
			discountCds.add(sd.getDiscountCd());
		}
		
		if (discountCds == null || discountCds.size() == 0 ) {
			return null;
		}
		
		ArrayList<SearchCondition> condsDiscountCd = new ArrayList<SearchCondition>();
		condsDiscountCd.add(new SearchCondition(Discount.DISCOUNT_CD, SearchCondition.IN, discountCds));
				
		return Discount.getDiscountList(user, condsDiscountCd, divisionKy, null, null);
		
	}	
	
	/**
	 * 
	 * @param curCostData
	 * @param origCostData
	 * @return boolean
	 */
	private boolean isSameRider(CostData curCostData, CostData origCostData){
		if (curCostData.getAssociateId().equals(origCostData.getAssociateId()) && curCostData.getRiderCompCd().equals(origCostData.getRiderCompCd())){
			return true;
		}
		return false;
	}
	
	private boolean hasSameRider(CostData[] lCostData, CostData cd) {
		boolean result = false;
		for(int i= 0; i < lCostData.length; i++)
		{
			if(isSameRider(lCostData[i], cd))
			{
				result = true;
				break;
			}
		}
		return result;
	}
	
	
	private  MembershipEntryBP getMembershipEntryBP(){
		MembershipEntryBP mbp= (MembershipEntryBP) BPF.get(user, MembershipEntryBP.class);
		return mbp;
	}
	
	private User getUser(User genericUser){
		User result = null;
		try {
			BigDecimal webserviceId = ClubProperties.getBigDecimal("WebServicesID", null, null);
            result = User.getUserByUserID(webserviceId.toString());

		}
		catch(Exception e){
			log.error("Unable to retrieve user object, please check your configuration");
			log.error(StackTraceUtil.getStackTrace(e));
		}
		return result;
	}    
}
