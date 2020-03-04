package com.aaa.soa.object;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;


import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.aaa.soa.object.MembershipServiceBP.WebServiceException;
import com.aaa.soa.object.models.Donation;
import com.aaa.soa.object.models.DuesCostItem;
import com.aaa.soa.object.models.GetMembershipComponentDuesRequest;
import com.aaa.soa.object.models.GetMembershipComponentDuesResponse;
import com.aaa.soa.object.models.MemberComponentDues;
import com.aaa.soa.object.models.MemberDues;
import com.aaa.soa.object.models.MembershipComponentDues;
import com.aaa.soa.object.models.SimpleMembershipNumber;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.bp.cancel.CancelBP;
import com.rossgroupinc.memberz.bp.cost.CostBP;
import com.rossgroupinc.memberz.bp.cost.CostData;
import com.rossgroupinc.memberz.bp.cost.DuesCalculatorCostBP;
import com.rossgroupinc.memberz.bp.membershipentry.MembershipEntryBP;
import com.rossgroupinc.memberz.bp.payment.PayableComponent;
import com.rossgroupinc.memberz.model.CoverageLevel;
import com.rossgroupinc.memberz.model.Discount;
import com.rossgroupinc.memberz.model.DiscountHistory;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.MembershipCode;
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
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.util.RGILoggerFactory;

public class MembershipDuesCalculatorUtil extends BusinessProcess {
	
	private static final long serialVersionUID = 1L;
	private  	Logger							log				= LogManager.getLogger(MembershipDuesCalculatorUtil.class.getName(), new RGILoggerFactory());
	private  	SortedSet<RiderDefinition>		memberRiderList	= null;
	private  	CostData[]						origCdArray			= null;
	private 	User							user			= null;
	private		boolean							prorate			= false;
	private		Collection<MemberDues>			colMdues		= new ArrayList<MemberDues>();
	private 	String							covLvlDescr		= "";
	private		SortedSet<CoverageLevel>		coverageLevels  = null;
	Collection<Discount> 						discounts 		= null;
	private 	ArrayList<Donation> 			donations 		= null;
	
	private		ValueHashMap 					appliedDiscount = new ValueHashMap();				
	protected   MembershipUtilBP membershipUtilBP = MembershipUtilBP.getInstance();
	
	private 	Membership 						ms 				=null;
	
	
	public MembershipDuesCalculatorUtil(User user){
		super();
		this.user = getUser(user);
	}	
	
	public Collection<MemberDues> getMemberDues(){
		return this.colMdues;
	}
	
	public String getCoverageLevelText(){
		return this.covLvlDescr;
	}
	
	
	/**   CALCULATE DUES
	 * Calculate dues based on parameters and return a Member Dues Collection
	 * 
	 * @param usr
	 * @param Zip
	 * @return branch key big decimal
	 */
	public Collection<Discount> CalculateMembershipDues(String zip, int assCnt, String covLevel, String marketCode, String billingCatCd, 
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
				this.ms=ms;
				isExisting = false;
			}
			
			//This functions does nothing, because no member level rider is in the current mzp db. 
			buildOrigHashMap(ms, _origHashMap);
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
	
	public Membership getMembership() {
		return ms;
	}

	
	public Collection<Discount> CalculateMembershipDuesEnroll(String zip, int assCnt, String covLevel, String marketCode, String billingCatCd, 
			BigDecimal branchKey, BigDecimal divisionKey, String regionCode, String state, SortedSet<CoverageLevel> coverageLevels)
	{
			String commissionCd = "N";
			CostData[] finalCdArray = null;
			
			String primBSRdrStatus = "P";
			Timestamp passExpiration = null;
			try {
				
				if (ms==null) {
					ms = getMembershipEntryBP().buildMembershipForDuesCalculation();	
					
					ms.setBranchKy(branchKey);
					ms.setZip(zip);
					ms.setCoverageLevelCd(covLevel);
					ms.getPrimaryMember().getBasicRider().setCostEffectiveDt(DateUtilities.getTimestamp(true));
					ms.getPrimaryMember().setParentMembership(ms);
					ms.setBillingCategoryOnAll(billingCatCd);							
					
					passExpiration = ms.getPrimaryMember().getMemberExpirationDt();
					
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
				} else {
					ms.setCoverageLevelCd(covLevel);
				}
				
				DuesCalculatorCostBP dcBP = BPF.get(user, DuesCalculatorCostBP.class); 
				
				finalCdArray =  dcBP.findRiderCosts(billingCatCd, commissionCd, assCnt, covLevel,	primBSRdrStatus, 
									regionCode, divisionKey, branchKey, new ValueHashMap(), passExpiration, ms, state);
				
				covLvlDescr = membershipUtilBP.getCoverageByMZPType(covLevel);		
				colMdues = createMembershipDues(finalCdArray, assCnt, coverageLevels, false, ms, false);
			
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
	
	//TODO: get market code
	private String getMembershipMarketCode(Membership ms) {
		return "";
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
			
			//Fix the billing category related rider cost issue, for military membership one click renewal situation. - Start [YH]
			if (renewalMarketCode.equals("MILI")) {
				boolean inRenewal = false;
				
				Member pm = ms.getPrimaryMember();
				if (ms.isPending()){
					inRenewal = (!"NM".equalsIgnoreCase(ms.getBillingCd()));  /*as long as code is not NM*/
					inRenewal = inRenewal && (pm.getMemberExpirationDt().before(pm.getActiveExpirationDt()));  /*and as long as the active expiration date has been pushed out from the current expiration date on primary member*/
				}		
				
				if (inRenewal) {
					String billingCategoryCd = MembershipUtilBP.getInstance().getBillingCdByMarketCd(renewalMarketCode);

					CostBP costBP = (CostBP )BPF.get(user, CostBP.class);
					
					for (CostData cd : finalCdArray){
					
						Rider r = getRiderFromMembership(ms, cd.getMemberType().toUpperCase(), cd.getRiderCompCd().toUpperCase());
						
						if (r!=null) {
							Member m = r.getParentMember(); 
 							CostData cdFixValue = costBP.getRiderCost(ms, r, ms.getClubCode(), billingCategoryCd, ms.getRegionCode(),
									ms.getDivisionKy(), ms.getBranchKy(), r.getRiderCompCd(), m.getMemberTypeCd(), pm.getActiveExpirationDt(), 
									"PRIMARY", m, "N", ms.getMembershipTypeCd(), ms.getDuesState());

							//handle partial payment
							BigDecimal adjDuesAmount = r.getDuesAdjustmentAt(); 
							BigDecimal paymentAt = r.getPaymentAt();
							
							BigDecimal fAmount = cdFixValue.getFullCost().subtract(adjDuesAmount).subtract( paymentAt);  
							if (fAmount.compareTo(BigDecimal.ZERO)<=0) {
								fAmount = BigDecimal.ZERO; 
							}
							
							cd.setFullCostRD(fAmount);	
						}
					}
				}
			}
			//Fix the billing category related rider cost issue, for military membership one click renewal situation. - End [YH]
			
			covLvlDescr = membershipUtilBP.getCoverageByMZPType(ms.getCoverageLevelCd());	
			colMdues = createMembershipDues(finalCdArray, ms.getCurrentMemberList().size() - 1, coverageLevels, isExisting, ms, true);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		return discounts;
	}
	
	private Rider getRiderFromMembership (Membership ms, String memberType, String riderCompCd) {
		Rider r = null; 
		try {
			if (ms!=null) {
				//shadow membership handling
				SortedSet<MembershipCode> mbsCodesList = ms.getMembershipCodeList();
				boolean isShadow = false; 
				
				if (mbsCodesList !=null && mbsCodesList.size() > 0)
				{
					for(MembershipCode code :  mbsCodesList)
					{
						
						if(code.getCode().equals("SHADOW")) {
							isShadow = true; 
							if (riderCompCd.equalsIgnoreCase("RV") || riderCompCd.equalsIgnoreCase("MC")) {
								return null;
							}
						}
						 
					}
				}
				
				
				if (memberType.equalsIgnoreCase("P")) {
					Member pm = ms.getPrimaryMember(); 
					
					for (Rider r1: pm.getRiderList()) {
						if (r1.getRiderCompCd().equalsIgnoreCase(riderCompCd)){
							r = r1; 
							break; 
						}
					}
				} else{
					Member am = null; 
					for (Member m: ms.getNonCancelledMemberList())  {
						if (!m.getMemberTypeCd().equalsIgnoreCase("P")) {
							am = m; 
							break; 
						}
					}
					
					if (am!=null) {
						for (Rider r1: am.getRiderList()) {
							if (r1.getRiderCompCd().equalsIgnoreCase(riderCompCd)){
								r = r1; 
								break; 
							}
						}	
					}
					
				}
			}
		} catch (Exception e) {
			
		}
		return r; 
	}
	
	
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
	
	
	private  void buildOrigHashMap(Membership membership, ValueHashMap _origHashMap){
		
		int origAssociateCount = 0;
		try{
			Iterator<Member> memberIterator = membership.getMemberList().iterator();
			origAssociateCount = 0;
			int i = -1;
			while (memberIterator.hasNext()){
				i++;
				Member curMember = memberIterator.next();
				if (!curMember.getStatus().equals("C")) origAssociateCount++;

				SortedSet<RiderDefinition> tempList = getMemberLevelRiderList(membership.getDivisionKy(), membership.getRegionCode(), membership, memberRiderList);
				for (RiderDefinition def : tempList){
					String memType = curMember.getMemberTypeCd();
					String riderCode = def.getRiderCompCd();
	
					SortedSet<Rider> riders = new TreeSet<Rider>();
					for(Rider r: curMember.getNonCancelledRiderListFromCache()){
						if(r.getRiderCompCd().equals(riderCode)){
							riders.add(r);
						}
					}
					Iterator<Rider> riderIterator = riders.iterator();
					//JZ - This is priceless - I don't know who did it but it made me laugh - so I saved it for you
					for (; riderIterator.hasNext();){
						Rider Rdr = riderIterator.next();

						log.debug("status:" + Rdr.getStatus());
						if (riders.size() > 0){
							if ("P".equals(Rdr.getStatus()) || "A".equals(Rdr.getStatus())){
								String key = memType + ":" + riderCode + ":" + "A" + ":" + (i + 1);
								_origHashMap.putInt(key, 1);
							}
						}
					}
				}
			}
		}
		catch (Exception e){
			log.error("error in DuesCalculatorBean: " + StackTraceUtil.getStackTrace(e));
		}
		log.debug("ORIGINAL HASHMAP " + _origHashMap.toString());
	}
	
	private CostData[] getFinalCostData(CostData[] originalCosts, CostData[] newCosts, int newAssociateCount, Membership ms) throws Exception
	{
		//existing membership only, can be complicated; new enrollment won't come here. 
		//one click renewal won't come here. 
		
		ArrayList<CostData> finalCosts = new ArrayList<CostData>();
		
		if(originalCosts != null && newCosts != null)
		{
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
	
	/**
	 * Get instance of MembershipEntryBP
	 * @return
	 */
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
