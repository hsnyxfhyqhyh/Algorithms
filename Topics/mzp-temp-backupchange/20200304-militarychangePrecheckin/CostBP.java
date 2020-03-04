/*
 *******************************************************************************
 MODULE        :  CostBP
 DESCRIPTION   :  Costing Business Process.  Calculates cost and refund amounts.
 
 Copyright (c) 2005 Ross Group Inc - The source code for
 this program is not published or otherwise divested of its trade secrets,
 irrespective of what has been deposited with the U.S. Copyright office.
 
 *******************************************************************************
 Modification Log:
 Date       |Developer     |Ticket#  |Description
 -----------|--------------|---------|------------------------------------------
 07/19/2006 |Dwayne Gulla  |9854     |Had to remove the premature return within
            |              |         |calculateRiderRefundWholeMonths. This was
            |              |         |not returning the correct amount.
 -----------|--------------|---------|------------------------------------------
 05/02/2010 |Al Moor       |         | Changed refund calculations to base on
            |              |         | how much to keep, for partial pays
 06/04/2010 | Al Moor      |         | Merged some fixes from MCH.
 09/23/2011 | Karan Kapoor | TR 30   | Scenario 1 to 4 Prorate Issue
 09/27/2011 | Karan/Ying   | TR 30   | TR 30 complete fix for Prorate issue implemented
 			|	/Vlad      |         | New method and extra logic was added
 09/28/2011 | Ying/Karan   | TR 30   | Add member fix (Prorate)
 07/02/2012 | Karan Kapoor | TR 229  | Fixed prorates for SPenn
 07/16/2012 | Karan Kapoor | TR 237  | Refund prorates for Southern Penn created a new method for Refund by date
 *******************************************************************************
 */
package com.rossgroupinc.memberz.bp.cost;

import static java.math.BigDecimal.ZERO;

import java.math.BigDecimal;
import java.util.Date;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.SortedSet;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Document;
import org.dom4j.Element;

import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.bp.BusinessProcessException;
import com.rossgroupinc.conxons.dao.DataObject;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.errorhandling.ObjectNotFoundException;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.memberz.ClubProperties;
import com.rossgroupinc.memberz.bp.membership.ExpirationDateBP;
import com.rossgroupinc.memberz.bp.membership.reinstate.ReinstateData;
import com.rossgroupinc.memberz.bp.membership.reinstate.ReinstateMemberData;
import com.rossgroupinc.memberz.bp.membership.reinstate.ReinstateRiderData;
import com.rossgroupinc.memberz.bp.payment.PayableComponent;
import com.rossgroupinc.memberz.model.BatchPayment;
import com.rossgroupinc.memberz.model.Division;
import com.rossgroupinc.memberz.model.Member;
import com.rossgroupinc.memberz.model.Membership;
import com.rossgroupinc.memberz.model.MembershipFees;
import com.rossgroupinc.memberz.model.Revenue;
import com.rossgroupinc.memberz.model.RevenuePeriod;
import com.rossgroupinc.memberz.model.Rider;
import com.rossgroupinc.memberz.model.RiderCost;
import com.rossgroupinc.memberz.model.Solicitation;
import com.rossgroupinc.rowset.CachedRowSet;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.DateUtils;
import com.rossgroupinc.util.NumberUtilities;
import com.rossgroupinc.util.RGILoggerFactory;
import com.rossgroupinc.util.SearchCondition;
import com.rossgroupinc.util.StringUtils;
import com.rossgroupinc.util.ValueHashMap;

/**
 * Centralized Costing process.  Used to calculate refunds, prorations, dues costs, etc.  Most methods 
 * in this class operate at the component level.
 */
public class CostBP extends BusinessProcess {
	private static final long	serialVersionUID	= -5859211989392036482L;
	Document					configuration		= null;
	private static Logger		log					= LogManager.getLogger(CostBP.class.getName(), new RGILoggerFactory());
	private static String		CONFIG_FILE			= "memberz/cost/Cost.xml";
	

	// Used to hold the refund method for a club.  MZP must be restarted for
	// changes to take effect.
	private static HashMap<String, String>	clubRefundMethod	= new HashMap<String, String>();
	protected static int						_cutoffDay			= 99;
	// Variables added for Prorate issue
	protected static int 						_cutoffProrate		= 99; // TR 30 SJ
	protected static String 					_prorateType   		= null; //TR 30 SJ

	/**
	 * 
	 * @param usr
	 */
	public CostBP(User usr ) {
		super();
		this.user = usr;
		configuration = getConfiguration(CONFIG_FILE, user);
		getClubRefundMethod(); // to read _cutoffDay in the first place
		getClubCutOffDate(); // To get the cutoff date for prorate TR 30
	}
	
	/**
	 * Method that reads cutoff date from Cost XML and set its value for the club
	 * 
	 */
	//TR 30 Ying
	@SuppressWarnings( { "unchecked" })
	private void getClubCutOffDate() {
			String clubCd = ClubProperties.getClubCode();
			String method = null;
			// should be configured in the XML
			for (Iterator it = configuration.getRootElement().elementIterator("club"); it.hasNext();){
				Element el = (Element) it.next();
				if (clubCd.equals(el.attributeValue("clubcode")))
				{
					Element elProrating = el.element("prorate-lead-time");
					if (elProrating!= null){
						Element elCutoffDate = elProrating.element("cutoff-dayofmonth");
						if (elCutoffDate != null) {
							String cutoffStr = elCutoffDate.getTextTrim();
							if (StringUtils.isNumeric(cutoffStr)){
								_cutoffProrate = Integer.parseInt(cutoffStr);
							}
						}
					}
				}
			}
	}

	/**
	 * 
	 * @param costData
	 * @return DuesCost
	 * @throws SQLException
	 */
	public DuesCost getCost(CostData costData) throws SQLException, ObjectNotFoundException{
		return getRiderCost(costData);
	}

	/**
	 * Determines the cost of the rider 
	 * @param costData
	 * @return RiderCost
	 * @throws SQLException
	 */
	public RiderCost getRiderCost(CostData costData) throws SQLException, ObjectNotFoundException{
		//all the logic that was here existed in a constructor in Rider Cost - JZ
		//
		if (costData.getCostEffectiveDate() == null) {
			costData.setCostEffectiveDate(costData.getMemberExpiration());
		}
		//Prakash - 07/02/2018 - Dues By State - Start
		return new RiderCost(user, costData.getRiderCompCd(), costData.getBillingCategoryCd(), costData.getMemberType(), costData.getRegionCd(),
				costData.getDivisionKy(), costData.getBranchKy(), costData.getCostEffectiveDate(), costData.getMembershipTypeCd(), costData.getDuesState());
	}

	/**
	 * sets the inital full cost on the costData passed in
	 * @param costData
	 * @param duesCost
	 * @throws SQLException
	 */
	protected void setBaseCost(CostData costData, DuesCost duesCost) throws SQLException{
		costData.setFixedPrice(duesCost.isFixedPrice());
		if ("N".equals(costData.getCommissionCd())){
			BigDecimal tempCost = ((duesCost.getNewAt() == null) ? new BigDecimal("0") : duesCost.getNewAt()).setScale(2, BigDecimal.ROUND_HALF_UP);
			costData.setFullCost(tempCost);
			costData.setFullPremium(((duesCost.getNewPremiumAt() == null) ? new BigDecimal("0") : duesCost.getNewPremiumAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP));
			//Entrance Fees for New members
			BigDecimal feeCost = ((duesCost.getEntranceAt() == null) ? new BigDecimal("0") : duesCost.getEntranceAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP);
			costData.setEnrollmentFee(feeCost);
		}//added the OR block to consider D(dropped as a renew) JSA TT 8166(webmember maintenance)
		else if ("R".equals(costData.getCommissionCd()) || "D".equals(costData.getCommissionCd()) || "T".equals(costData.getCommissionCd())){
			BigDecimal tempCost = ((duesCost.getRenewAt() == null) ? new BigDecimal("0") : duesCost.getRenewAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP);
			costData.setFullCost(tempCost);
			costData.setFullPremium(((duesCost.getRenewPremiumAt() == null) ? new BigDecimal("0") : duesCost.getRenewPremiumAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP));
			//Renewal Fees for Renew/Dropped/Transfer members
			BigDecimal feeCost = ((duesCost.getRenewEntranceAt() == null) ? new BigDecimal("0") : duesCost.getRenewEntranceAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP);
			costData.setEnrollmentFee(feeCost);
		}
		else if ("T1".equals(costData.getCommissionCd())){
			BigDecimal tempCost = new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
			costData.setFullCost(tempCost);
			costData.setFullPremium(tempCost);
		}
		else{
			BigDecimal tempCost = new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
			costData.setFullCost(tempCost);
			costData.setFullPremium(tempCost);
			//Last resort - Entrance Fees set if all else fails
			BigDecimal feeCost = ((duesCost.getEntranceAt() == null) ? new BigDecimal("0") : duesCost.getEntranceAt()).setScale(2,
					BigDecimal.ROUND_HALF_UP);
			costData.setEnrollmentFee(feeCost);
		}
		log.debug("Base DUES_COST=" + costData.getFullCost().toString());
		log.debug("Base PREMIUM=" + costData.getFullPremium().toString());
	}

	/**
	 * Sets the prorations days/months based on club properties
	 * @param costData
	 */
	protected void setupLeadProration(CostData costData){
		boolean prorateLeadTime = ClubProperties.getFlag("ProrateLeadTime", costData.getDivisionKy(), costData.getRegionCd());
		//TT 8015 FCW
		int prorateLeadDays = ClubProperties.getBigDecimal("ProrateLeadDays", costData.getDivisionKy(), costData.getRegionCd()).intValue();
		costData.setProrateLeadTime(prorateLeadTime);

		if (costData.isProrateLeadTime()){
			Calendar cal = Calendar.getInstance();
			int today = cal.get(Calendar.DATE);
			costData.setProrateMonth(cal.get(Calendar.MONTH));
			costData.setCurrentMonth(costData.getProrateMonth());
			cal.set(Calendar.MONTH, costData.getProrateMonth() + 1);
			cal.set(Calendar.DATE, 0);

			int lastOfMonth = cal.get(Calendar.DATE);
			int daysBeforeEndOfMonth = lastOfMonth - today;
			log.debug("Today: " + today + " End of month: " + lastOfMonth + "  days diff = " + daysBeforeEndOfMonth);
			//          TT 8015 FCW
			if (daysBeforeEndOfMonth <= prorateLeadDays){
				costData.setProrateMonth(costData.getProrateMonth() + 1); // consider it to be next month for
				// proration purposes
				if (costData.getProrateMonth() == 12) costData.setProrateMonth(0);
			}
			log.debug("proration month = " + costData.getProrateMonth() + "  current month = " + costData.getCurrentMonth());
		}

	}

	/**
	 * Sets the proration to fasle if teh Primary basic status
	 * @param costData
	 */
	protected void setupPrimaryDateType(CostData costData){
		costData.setProrate(!costData.isPrimaryInBilling());
	}

	/**
	 * AddMember, Calculated expiration selected. Charge full amount, don't look at dates at all
	 * @param costData
	 */
	protected void setupCalculatedDateType(CostData costData){
		log.debug("branch five, datetype = calculated");
		costData.setProrateLeadTime(false);
		costData.setProrate(false);
	}

	/**
	 *  1 - If member is pending and member exp = primary exp. PRORATE
	 *  2 - If member is pending and member exp != primary exp. FULL COST
	 *  3 - If member is active PRORATE
	 * 
	 * @param costData
	 */
	protected void setupAddRiderDateType(CostData costData){
		// get the member
		//criteria.add(new SearchCondition(Member.MEMBER_KY, SearchCondition.EQ, pValueHashMap
		//        .getBigDecimal("MEMBER_KY")));
		//Member memberDO = (Member) Member.getMemberList(user, criteria, orderby).first();

		// now, we can figure out how to calc the cost
		// 1 - If member is pending and member exp = primary exp. PRORATE
		// 2 - If member is pending and member exp != primary exp. FULL COST
		// 3 - If member is active PRORATE
		if ("A".equals(costData.getMemberStatus())){
			log.debug("Active member on add rider, prorate = true");
			costData.setProrate(true);
		}
		else{
			// is this the primary?
			if ("P".equals(costData.getMemberType()) && costData.isPrimaryInBilling()){
				// member is the primary and is pending, full cost
				log.debug("Pending member(primary) on add rider, prorate = false");
				costData.setProrate(false);
			}
			else{
				//Member primaryDO = membershipDO.getPrimaryMember();
				java.util.Calendar memberExpiration = java.util.Calendar.getInstance();
				Timestamp mbrexpTS = costData.getMemberExpiration();
				Timestamp primexpTS = costData.getPrimaryExpiration();
				memberExpiration.setTimeInMillis(mbrexpTS.getTime());
				java.util.Calendar primaryExpiration = java.util.Calendar.getInstance();
				primaryExpiration.setTimeInMillis(primexpTS.getTime());

				if ((memberExpiration.get(Calendar.MONTH) == primaryExpiration.get(Calendar.MONTH))
						&& (memberExpiration.get(Calendar.DAY_OF_MONTH) == primaryExpiration.get(Calendar.DAY_OF_MONTH))){
					//Rider pBasicDO = primaryDO.getBasicRider();
					String pbStatus = costData.getPrimaryBasicStatus();
					log.debug("Primary's basic status = " + pbStatus);
					if (costData.isPrimaryInBilling()){
						// primary is pending. charge full amount
						costData.setProrate(false);
					}
					else{
						costData.setProrate(true);
					}
				}
				else{
					// split membership, full amount
					log.debug("Primary's expiration: " + primaryExpiration.get(Calendar.MONTH) + "/" + primaryExpiration.get(Calendar.DAY_OF_MONTH)
							+ "   Member expiration" + memberExpiration.get(Calendar.MONTH) + "/" + memberExpiration.get(Calendar.DAY_OF_MONTH));
					log.debug("Pending member(associate) expiration != primary's expiration, prorate = false");
					costData.setProrate(false);
				}
			}
		}
	}


	/**
	 * Get the number of months to charge or refund when prorating.  If club property
	 * MM_CutoffCostCredit (BigDecimal) integer value is >= today's day of the month,
	 * add one month.
	 * 
	 * @param startDate
	 * @param expirationDate
	 * @param riderCompCd Ignored here, but used in several subclasses
	 * @return int
	 */
	public int getProrationMonths(Timestamp startDate, Timestamp expirationDate, String riderCompCd, BigDecimal divisionKy, String regionCd, boolean refund, String membershipTypeCd){
		int months = DateUtilities.monthDiff(startDate, expirationDate, false);
		//TT 8187 FCW
		Calendar cal = Calendar.getInstance(); 
		cal.setTimeInMillis(startDate.getTime());
		int dayOfMonth = cal.get(Calendar.DATE);
		//if (today >= cutOffCostCredit) {
		//    monthsToUse--;
		//}
		if (dayOfMonth < _cutoffDay){
			months++;
		}
		if (months < 0){
			months = 0;
		}
		if (months > 12){
			log.debug("monthsToUse = " + months);
			months = 12;
		}

		return months;
	}
	
	//JRDR wwei
	protected void calculateComponentCostFullTerm(CostData costData){
		BigDecimal duesCostPerMonth = costData.getFullCost().divide(new BigDecimal("12"), 4, BigDecimal.ROUND_HALF_UP);
		int expirationMonth = 0;
		//this used to be VHM "MEMBER_EXPIRATION_DT" which was different things from different calling locations
		//It is not the primary's expiration
		//Timestamp primaryExpiration = costData.getMemberExpiration();
		if (costData.isProrateLeadTime()){
			Calendar hc = Calendar.getInstance();
			hc.setTime(costData.getMemberExpiration());
			expirationMonth = hc.get(Calendar.MONTH);
			
		}

		boolean mdProrateOnReinstate = "Y"
				.equals(ClubProperties.getString("ProrateOnReinstate:MD", costData.getDivisionKy(), costData.getRegionCd()));
		log.debug("prorate: " + costData.isProrate());
		log.debug("Rider: " + costData.getRiderCompCd());

		boolean prorate = (!"MD".equals(costData.getRiderCompCd()) && costData.isProrate())
				|| ("MD".equals(costData.getRiderCompCd()) && mdProrateOnReinstate && costData.isProrate())
				|| ("BS".equals(costData.getRiderCompCd()) && costData.isProrate());

		if (costData.isFixedPrice()) {
			prorate = false;
			costData.setProrateLeadTime(false);
		}
		
		// If we are taking the primary's expiration date, and the primary's expiration
		// is past, that means the primary is in renewal and hasn't paid. We are going
		// to charge full price, no proration
		if ("PRIMARY".equals(costData.getDateType()) && costData.isPrimaryInBilling()){
			prorate = false;
		}
		
		if (prorate){
			// Fixed for SPenn - doesn't change anything - KK 07/02/2012
			_prorateType = "Prorate";
			//wwei JRDR This will only get full term cost
			int monthsToUse = 12;
			log.debug("MONTHS_TO_USE=" + String.valueOf(monthsToUse));
			costData.setProratedCost(NumberUtilities.multiply(duesCostPerMonth, monthsToUse).setScale(2, BigDecimal.ROUND_HALF_UP));
			
			if (costData.isProrateLeadTime()){
				// if we bumped up the prorate month because we're past the 20th, the prorate calculation will work
				//just fine, no additional lead time is charged
				if (costData.getCurrentMonth() != costData.getProrateMonth()){
					log.debug("no addition proration required, calculated, currentMonth = prorateMonth");
				}
				// one month otherwise
				else{
					log.debug("additional lead time proration of one month");
					monthsToUse += 1;
				}
			}
		}
		else{
			costData.setProrateLeadMonths(0);
			if (costData.isProrateLeadTime()){
				// this is a much tougher nut to crack
				// we have to add a lead time proration month for each month the prorate month is less than
				//the expiration month, plus 1. So, the only time we wouldn't charge an extra month is if we
				//are after the 20th and the expiration is the last of the same month.
				log.debug("ExpirationMonth: " + expirationMonth + "  prorateMonth: " + costData.getProrateMonth());
				costData.setProrateLeadMonths(0);
				while (expirationMonth != costData.getProrateMonth()){
					expirationMonth--;
					costData.setProrateLeadMonths(costData.getProrateLeadMonths() + 1);
					if (expirationMonth < 0){
						expirationMonth = 11;
					}
				}
				costData.setProrateLeadMonths(costData.getProrateLeadMonths() + 1);
				if (costData.getProrateLeadMonths() > 2){
					// could go negative, which will cause a full year to be scaled back a bit
					costData.setProrateLeadMonths(costData.getProrateLeadMonths() - 12);
				}
				log.debug("prorating an additional " + costData.getProrateLeadMonths());
			}
			// If we are taking the primary's expiration date, and the primary is in renewal, 
			// we are going to charge full price, no proration
			if ("PRIMARY".equals(costData.getDateType()) && costData.isPrimaryInBilling()){
				costData.setProrateLeadMonths(0);
			}

			//TT 6277 FCW must explicitly prevent non-prorate MD from applying lead time proration
			if ("MD".equals(costData.getRiderCompCd()) && !mdProrateOnReinstate){
				costData.setProratedCost(costData.getFullCost());
				log.debug("No additional proration for MD rider");
			}
			else if (costData.isProrateLeadTime() && costData.getProrateLeadMonths() != 0){
				BigDecimal startCost = costData.getFullCost();
				startCost = startCost.add(duesCostPerMonth.multiply(BigDecimal.valueOf(costData.getProrateLeadMonths()))).setScale(2,
						BigDecimal.ROUND_HALF_UP);
				costData.setProratedCost(startCost);
				log.debug("Prorated lead months cost = " + startCost);
			}
			else{
				costData.setProratedCost(costData.getFullCost());
				costData.setProratedPremium(costData.getFullPremium());
				log.debug("No additional proration");
			}
		}
		log.debug("DUES_COST=" + costData.getFullCost().toString());
		log.debug("CALC_COST=" + costData.getProratedCost().toString());
		if (costData.getProratedCost().compareTo(costData.getFullCost()) != 0 && costData.getFullPremium().compareTo(BigDecimal.ZERO) > 0){
			// need to prorate the premium
			if (costData.getProratedCost().compareTo(BigDecimal.ZERO) == 0){
				costData.setProratedPremium(BigDecimal.ZERO);
			}
			else{
				double ratio = costData.getFullPremium().doubleValue() / costData.getFullCost().doubleValue();
				costData.setProratedPremium((new BigDecimal(ratio * costData.getProratedCost().doubleValue())).setScale(2, BigDecimal.ROUND_HALF_UP));
			}
		}
		//log.debug("MONTHS_TO_USE="+pValueHashMap.getInteger("MONTHS_TO_USE").toString());
		//log.debug("DUES_COST_PER_MONTH="+pValueHashMap.getBigDecimal("DUES_COST_PER_MONTH").toString());
	}


	/**
	 * Calculates teh cost of a component
	 * @param costData
	 */
	protected void calculateComponentCost(CostData costData){
		BigDecimal duesCostPerMonth = costData.getFullCost().divide(new BigDecimal("12"), 4, BigDecimal.ROUND_HALF_UP);
		int expirationMonth = 0;
		//this used to be VHM "MEMBER_EXPIRATION_DT" which was different things from different calling locations
		//It is not the primary's expiration
		//Timestamp primaryExpiration = costData.getMemberExpiration();
		if (costData.isProrateLeadTime()){
			Calendar hc = Calendar.getInstance();
			hc.setTime(costData.getMemberExpiration());
			expirationMonth = hc.get(Calendar.MONTH);
			
		}

		boolean mdProrateOnReinstate = "Y"
				.equals(ClubProperties.getString("ProrateOnReinstate:MD", costData.getDivisionKy(), costData.getRegionCd()));
		log.debug("prorate: " + costData.isProrate());
		log.debug("Rider: " + costData.getRiderCompCd());

		boolean prorate = (!"MD".equals(costData.getRiderCompCd()) && costData.isProrate())
				|| ("MD".equals(costData.getRiderCompCd()) && mdProrateOnReinstate && costData.isProrate())
				|| ("BS".equals(costData.getRiderCompCd()) && costData.isProrate());

		if (costData.isFixedPrice()) {
			prorate = false;
			costData.setProrateLeadTime(false);
		}
		
		// If we are taking the primary's expiration date, and the primary's expiration
		// is past, that means the primary is in renewal and hasn't paid. We are going
		// to charge full price, no proration
		if ("PRIMARY".equals(costData.getDateType()) && costData.isPrimaryInBilling()){
			prorate = false;
		}
		
		if (prorate){
			// Fixed for SPenn - doesn't change anything - KK 07/02/2012
			_prorateType = "Prorate";
			int monthsToUse = getProrationMonths(costData.getStartDate(), costData.getActiveExpiration(), costData.getRiderCompCd(), costData
					.getDivisionKy(), costData.getRegionCd(), false, costData.getMembershipTypeCd());
			log.debug("MONTHS_TO_USE=" + String.valueOf(monthsToUse));
			costData.setProratedCost(NumberUtilities.multiply(duesCostPerMonth, monthsToUse).setScale(2, BigDecimal.ROUND_HALF_UP));
			
			if (costData.isProrateLeadTime()){
				// if we bumped up the prorate month because we're past the 20th, the prorate calculation will work
				//just fine, no additional lead time is charged
				if (costData.getCurrentMonth() != costData.getProrateMonth()){
					log.debug("no addition proration required, calculated, currentMonth = prorateMonth");
				}
				// one month otherwise
				else{
					log.debug("additional lead time proration of one month");
					monthsToUse += 1;
				}
			}
		}
		else{
			costData.setProrateLeadMonths(0);
			if (costData.isProrateLeadTime()){
				// this is a much tougher nut to crack
				// we have to add a lead time proration month for each month the prorate month is less than
				//the expiration month, plus 1. So, the only time we wouldn't charge an extra month is if we
				//are after the 20th and the expiration is the last of the same month.
				log.debug("ExpirationMonth: " + expirationMonth + "  prorateMonth: " + costData.getProrateMonth());
				costData.setProrateLeadMonths(0);
				while (expirationMonth != costData.getProrateMonth()){
					expirationMonth--;
					costData.setProrateLeadMonths(costData.getProrateLeadMonths() + 1);
					if (expirationMonth < 0){
						expirationMonth = 11;
					}
				}
				costData.setProrateLeadMonths(costData.getProrateLeadMonths() + 1);
				if (costData.getProrateLeadMonths() > 2){
					// could go negative, which will cause a full year to be scaled back a bit
					costData.setProrateLeadMonths(costData.getProrateLeadMonths() - 12);
				}
				log.debug("prorating an additional " + costData.getProrateLeadMonths());
			}
			// If we are taking the primary's expiration date, and the primary is in renewal, 
			// we are going to charge full price, no proration
			if ("PRIMARY".equals(costData.getDateType()) && costData.isPrimaryInBilling()){
				costData.setProrateLeadMonths(0);
			}

			//TT 6277 FCW must explicitly prevent non-prorate MD from applying lead time proration
			if ("MD".equals(costData.getRiderCompCd()) && !mdProrateOnReinstate){
				costData.setProratedCost(costData.getFullCost());
				log.debug("No additional proration for MD rider");
			}
			else if (costData.isProrateLeadTime() && costData.getProrateLeadMonths() != 0){
				BigDecimal startCost = costData.getFullCost();
				startCost = startCost.add(duesCostPerMonth.multiply(BigDecimal.valueOf(costData.getProrateLeadMonths()))).setScale(2,
						BigDecimal.ROUND_HALF_UP);
				costData.setProratedCost(startCost);
				log.debug("Prorated lead months cost = " + startCost);
			}
			else{
				costData.setProratedCost(costData.getFullCost());
				costData.setProratedPremium(costData.getFullPremium());
				log.debug("No additional proration");
			}
		}
		log.debug("DUES_COST=" + costData.getFullCost().toString());
		log.debug("CALC_COST=" + costData.getProratedCost().toString());
		if (costData.getProratedCost().compareTo(costData.getFullCost()) != 0 && costData.getFullPremium().compareTo(BigDecimal.ZERO) > 0){
			// need to prorate the premium
			if (costData.getProratedCost().compareTo(BigDecimal.ZERO) == 0){
				costData.setProratedPremium(BigDecimal.ZERO);
			}
			else{
				double ratio = costData.getFullPremium().doubleValue() / costData.getFullCost().doubleValue();
				costData.setProratedPremium((new BigDecimal(ratio * costData.getProratedCost().doubleValue())).setScale(2, BigDecimal.ROUND_HALF_UP));
			}
		}
		//log.debug("MONTHS_TO_USE="+pValueHashMap.getInteger("MONTHS_TO_USE").toString());
		//log.debug("DUES_COST_PER_MONTH="+pValueHashMap.getBigDecimal("DUES_COST_PER_MONTH").toString());
	}

	/**
	 * Validates the required pieces of a costData object
	 * 
	 * @param costData
	 */
	protected void validateCostData(CostData costData){
		String billcat = costData.getBillingCategoryCd();
		String dateType = costData.getDateType();
		String commcd = costData.getCommissionCd();
		Timestamp primExpTS = costData.getPrimaryExpiration();
		Timestamp memExpTS = costData.getMemberExpiration();
		String memType = costData.getMemberType();
		String memStat = costData.getMemberStatus();
		String primStatBS = costData.getPrimaryBasicStatus();
		String compcd = costData.getRiderCompCd();

		StringBuffer buf = new StringBuffer();
		if (StringUtils.blanknull(billcat).equals("")){
			buf.append("BillingCategoryCd is required\n");
		}
		if (StringUtils.blanknull(dateType).equals("")){
			buf.append("DateType is required\n");
		}
		if (StringUtils.blanknull(commcd).equals("")){
			buf.append("CommissionCd is required\n");
		}
		if (StringUtils.blanknull(memType).equals("")){
			buf.append("MemberType is required\n");
		}
		if (StringUtils.blanknull(memStat).equals("")){
			buf.append("MemberStatus is required\n");
		}
		if (StringUtils.blanknull(primStatBS).equals("")){
			buf.append("PrimaryBasicStatus is required\n");
		}
		//TT 6247 FCW blank region code is ok. should map to cost records that have null region_cd
		//if (StringUtils.blanknull(regioncd).equals("")) {
		//    buf.append("RegionCd is required\n");
		//}
		if (StringUtils.blanknull(compcd).equals("")){
			buf.append("RiderCompCd is required\n");
		}

		if (primExpTS == null){
			buf.append("PrimaryExpiration is required\n");
		}
		if (memExpTS == null){
			buf.append("MemberExpiration is required\n");
		}

		if (buf.length() > 0){
			throw new BusinessProcessException("CostData not setup properly:\n" + buf.toString());
		}
	}

	private ExpirationDateBP	expBP	= null;

	private ExpirationDateBP getExpirationBP(){
		if (expBP == null){
			expBP = BPF.get(user, ExpirationDateBP.class);
		}
		return expBP;
	}

	/**
	 * Initializes a CostData object for use in the costing methods based on the
	 * information contained in the given payable component.  The component must be attached to 
	 * a valid membership and the billing category code, commission code, rider
	 * comp code must all be valid.
	 * @param pc
	 * @return CostData
	 * @throws SQLException
	 */
	public CostData initializeCostData(PayableComponent pc) throws SQLException, ObjectNotFoundException {
		return initializeCostData(pc, pc.getSolicitationCd(), pc.getBillingCategoryCd(), null);
	}
	
	/**
	 * Initializes a CostData object for use in the costing methods based on the
	 * information contained in the given payable component.  The component must be attached to 
	 * a valid membership and the billing category code, commission code, rider
	 * comp code must all be valid.
	 * 
	 * ReinstateMemberData is only used from the reinstate screen this is to allow us get get the right pricing
	 * based on switching the primay member on teh screen - via the ajax calls
	 * 
	 * @param pc
	 * @return CostData
	 * @throws SQLException
	 */
	public CostData initializeCostData(PayableComponent pc, ReinstateData rd) throws SQLException, ObjectNotFoundException {	
		return initializeCostData(pc, rd.getSolicitationCd(), rd.getBillingCategoryCd(), rd);
	}
		
	public CostData initializeCostData(PayableComponent pc, String solicitationCd, String billingCategoryCd, ReinstateData rd) throws SQLException, ObjectNotFoundException {

        CostData cd = new CostData();
        Member member = pc.getParentMember();
        Member primary = member;
        _prorateType = "Prorate";
        // Set Prorate type as prorate to be used in cost_212
        
        //The memberType is hardcoded to P when the member is Primary becauase in the reinstate screen it is 
        //possible for the member to be slated to be the Primary but the MemberType isn't actually switched yet
        if(rd != null){
        	if(rd.isPrimary()){
        		if(rd instanceof ReinstateMemberData ){
        			primary = ((ReinstateMemberData)rd).getMember();
        		}
        		else{
        			primary = ((ReinstateRiderData)rd).getRider().getParentMember();
        		}
	        	cd.setMemberType("P");
        	}
        	else{
        		primary = member.getParentMembership().getPrimaryMember();
        		cd.setMemberType("A");
        		member.getActiveExpirationDt();
        	}
        }
        else{
        	cd.setMemberType(member.getMemberTypeCd());
	        if (!member.isPrimary()){
	        	primary = member.getParentMembership().getPrimaryMember(false);
	        }
        }    
        cd.setActiveExpiration(member.getActiveExpirationDt());
        cd.setMemberExpiration(member.getMemberExpirationDt());
        cd.setPrimaryActiveExpiration(primary.getActiveExpirationDt());
        cd.setPrimaryExpiration(primary.getMemberExpirationDt());
        
        if (pc instanceof Rider) {
        	cd.setBillingCategoryCd(getSolicitationBillingCategoryForCosting(member.getParentMembership(), pc, solicitationCd, billingCategoryCd));
	        cd.setCommissionCd(((Rider)pc).getCommissionCd());
	        cd.setRiderCompCd(((Rider)pc).getRiderCompCd()); //Basic, Plus, ...
	        if (primary.isCancelled()) {
	        	cd.setPrimaryExpiration(getExpirationBP().getNextExpirationDate(false));
	        	cd.setPrimaryActiveExpiration(getExpirationBP().getNextExpirationDate(true));
	        }
	        else {
	        	cd.setPrimaryExpiration(primary.getMemberExpirationDt());
	        }
	        if (member.isCancelled()) {
	        	cd.setMemberExpiration(cd.getPrimaryExpiration());
	        	cd.setActiveExpiration(cd.getPrimaryActiveExpiration());	        
	        }
	        else {
	        	cd.setMemberExpiration(member.getMemberExpirationDt());
	        }
        }       
        cd.setMemberInBilling(member.inRenewal());
        cd.setPrimaryInBilling(primary.inRenewal());        
        cd.setMemberStatus(member.getStatus());
        cd.setPrimaryBasicStatus(primary.getStatus());
        cd.setRegionCd(member.getParentMembership().getRegionCode());
      //Prakash - 07/02/2018 - Dues By State - Start
        cd.setDuesState(member.getParentMembership().getState());
      //Prakash - 07/02/2018 - Dues By State - Start
        cd.setDivisionKy(member.getParentMembership().getDivisionKy());
        cd.setBranchKy(member.getParentMembership().getBranchKy());
        cd.setCommissionCd(pc.getCommissionCd());
        cd.setMembershipTypeCd(member.getParentMembership().getMembershipTypeCd());
        
        if (!member.isNew()) {
        	cd.setDateType("ADDRIDER");
        	//TR 30 Vlad Moldovan 09-14-2011------------------------------------------
        	//Add a day --------------------------------------------------------------
        	//If we prorating existing members, then they should be prorated starting on
        	//the 1st of the month after the members expiration date
        	//Your Condition to check if the associate is new or old
			//if it is new then set it to today's date
			//ELSE getMemberExpirationDate + 1 day
        	cd.setStartDate(member.getActiveExpirationDt());
        	SimpleDateFormat dateFormat = new SimpleDateFormat( "yyyy-MM-dd 00:00:00" ); 
        	String sDate = cd.getStartDate().toString();
        	String sCurrDate = Calendar.getInstance().toString();  // Current date
        	Calendar cal = Calendar.getInstance(); 
        	//TR 30 SJ [KK] Change to handle Group memberships
        	//While adding existing memberships to group
        try {
			cal.setTime( dateFormat.parse( sDate ) );
			cal.add( Calendar.DATE, 1 );
			if (member.getBillingCd()!= null)
			{
				if(exprNotInPast(member.getActiveExpirationDt())) //Method to check if the membership is past its expiration date
				{
					//Code will reach here if the membership expiration date is in the current month or in future
					cal.add(Calendar.YEAR, -1);
					sDate = dateFormat.format(cal.getTime());
					Timestamp timestamp = Timestamp.valueOf(sDate);
					cd.setStartDate(timestamp);
					//Start date set, The dues will be generated from this start date to group's end date
				}
				else
				{
					//Will reach here if the membership expiration was in past
					int date = Calendar.getInstance().get(Calendar.DAY_OF_MONTH);
					//Cut off prorate is used to check from when the dues should start on this membership
					//For club 071 we use cutoffprorate as 20
					if(date <= _cutoffProrate)
					{
						//today is less than prorate than include current month for calculating dues
						Calendar cal1 = Calendar.getInstance();
						cal1.set(Calendar.DAY_OF_MONTH, 1);
						sDate = dateFormat.format(cal1.getTime());
						Timestamp timestamp = Timestamp.valueOf(sDate);
						cd.setStartDate(timestamp);
					}
					else
					{
						//today is more than prorate than exclude current month for calculating dues
						Calendar cal1 = Calendar.getInstance();
						cal1.add(Calendar.MONTH, 1);
						cal1.set(Calendar.DAY_OF_MONTH, 1);
						sDate = dateFormat.format(cal1.getTime());
						Timestamp timestamp = Timestamp.valueOf(sDate);
						cd.setStartDate(timestamp);
						//Next month's first day
					}
				}
			}
			//TR 30 SJ [KK] Changes ends
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			log.error("Unable to add 1 day ");
		} 
        //cd.setStartDate(cal.add( Calendar.DATE, 1 )); 
        }
        //End of TR-30 ----------------------------------------------------------------------   
        else {
            boolean splitMemberships = ClubProperties.getFlag(ClubProperties.SPLIT_MEMBERSHIPS_FL, cd.getDivisionKy(), cd.getRegionCd());
            if (splitMemberships) cd.setDateType("CALCULATED");
            else cd.setDateType("PRIMARY");
           
        }
        validateCostData(cd);
        return cd;
    }
	/**
	 * Method to check if the expiration date of the member was in past or not 
	 * 
	 */
	//Method by Ying TR 30 SJ
	private boolean exprNotInPast(Timestamp activeExpirationDate) {

		Date activateExpirationDateLastYear = DateUtils.lastYearSameDate(activeExpirationDate);
		if (activateExpirationDateLastYear.compareTo(DateUtils.endOfLastMonth()) <= 0) 
		{
			return false;
		}
			return true;
	}



	//wwei JRDR
	 public CostData getComponentCostFullTerm(CostData costData){
	//public CostData getComponentCost(CostData costData){
		/*
		 * if dateType = PRIMARY or CALCULATED, it is coming from add member if dateType = ADDRIDER, it is coming from
		 * Add Rider
		 */

		long startTime = System.currentTimeMillis();

		validateCostData(costData);

		try{
			DuesCost costDO = getCost(costData);
			if (costDO == null){
				return costData;
			}
			setBaseCost(costData, costDO);
			// TR 30 Add Member [KK]
			costData.setStartDate(new Timestamp(DateUtils.today().getTime()));

			// If necessary, prorate lead time when added a component (add member, add plus) to a membership
			// in renewal billing with an expiration out more than 1 month.
			setupLeadProration(costData);

			if ("PRIMARY".equals(costData.getDateType())){
				setupPrimaryDateType(costData);
			}
			else if ("CALCULATED".equals(costData.getDateType())){
				setupCalculatedDateType(costData);
			}
			else if ("ADDRIDER".equals(costData.getDateType())){
				setupAddRiderDateType(costData);
			}
			else if ("PRORATE".equals(costData.getDateType())){ // explicitly showing the logic here 
				costData.setProrate(true);
			}
			else{
				// have no idea where it came from, prorate it.
				log.debug("branch six, dateType not set");
				costData.setProrate(true);
			}
			
			calculateComponentCostFullTerm(costData);

			costData.setValid(true);

		}
		catch (Exception e){
			if (costData != null){
				log.error("Error in calculateCost: costData = " + costData.toString());
			}
			log.error(StackTraceUtil.getStackTrace(e));
			throw new BusinessProcessException(e.getMessage());
		}
		return costData;
	}
	/**
	 * get the cost of a single component, based on the CostData parameter.  Data is 
	 * modified and returned.  The return object and the parameter point to the 
	 * same object, internally.  The CostData object passed in WILL be modified.
	 * @param costData
	 * @return CostData
	 */
	 public CostData getComponentCost(CostData costData){
	//public CostData getComponentCost(CostData costData){
		/*
		 * if dateType = PRIMARY or CALCULATED, it is coming from add member if dateType = ADDRIDER, it is coming from
		 * Add Rider
		 */

		long startTime = System.currentTimeMillis();

		validateCostData(costData);

		try{
			DuesCost costDO = getCost(costData);
			if (costDO == null){
				return costData;
			}
			setBaseCost(costData, costDO);
			// TR 30 Add Member [KK]
			costData.setStartDate(new Timestamp(DateUtils.today().getTime()));

			// If necessary, prorate lead time when added a component (add member, add plus) to a membership
			// in renewal billing with an expiration out more than 1 month.
			setupLeadProration(costData);

			if ("PRIMARY".equals(costData.getDateType())){
				setupPrimaryDateType(costData);
			}
			else if ("CALCULATED".equals(costData.getDateType())){
				setupCalculatedDateType(costData);
			}
			else if ("ADDRIDER".equals(costData.getDateType())){
				setupAddRiderDateType(costData);
			}
			else if ("PRORATE".equals(costData.getDateType())){ // explicitly showing the logic here 
				costData.setProrate(true);
			}else if ("PRORATEME".equals(costData.getDateType())){
				 if(costData.getMemberExpiration().before(costData.getStartDate()) && costData.getMemberStatus().equals("P") ) {
					 setupAddRiderDateType(costData);
				 }else{
					 costData.setProrate(true);
				 }
				
			}else if ("REINSTATE".equals(costData.getDateType())){
				 if(costData.getMemberExpiration().before(costData.getStartDate()) && costData.getMemberStatus().equals("P") ) {
					 setupAddRiderDateType(costData);
				 } else{
					 costData.setProrate(true);
				 }				
			}else{
				// have no idea where it came from, prorate it.
				log.debug("branch six, dateType not set");
				costData.setProrate(true);
			}
			
			calculateComponentCost(costData);

			costData.setValid(true);

		}
		catch (Exception e){
			if (costData != null){
				log.error("Error in calculateCost: costData = " + costData.toString());
			}
			log.error(StackTraceUtil.getStackTrace(e));
			throw new BusinessProcessException(e.getMessage());
		}
		return costData;
	}
	 
	 
	 private Timestamp getTimeStamp(){
		 String t2;
		 String st = "01/10/2011 00:00:00";
		 SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		 Date date;
		 Timestamp timestamp = null;
		 try {
		 date = sdf.parse(st);
		 timestamp = new Timestamp(date.getTime());
		 t2 = timestamp.toString();
		 //System.out.println(t2);
		 } catch (Exception e) {
		 // TODO Auto-generated catch block
		 e.printStackTrace();
		 }
		return timestamp;

		}




	/**
	 * Calculates refund amount due on an existing component. 
	 * 
	 * @param pc
	 * @param cancelDate
	 * @return BigDecimal
	 * @throws CostException
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	public BigDecimal calculateRefund(PayableComponent pc, Timestamp cancelDate) throws CostException, SQLException, ObjectNotFoundException{
		_prorateType	=	"Refund";
		// Set Prorate type as refund
		return calculateRefund(pc, cancelDate, null);
	}
	
	/**
	 * Calculates refund amount due on an existing component. 
	 * 
	 * @param pc
	 * @param cancelDate
	 * @param basicRider
	 * @return BigDecimal
	 * @throws CostException
	 * @throws SQLException
	 * @throws ObjectNotFoundException
	 */
	public BigDecimal calculateRefund(PayableComponent pc, Timestamp cancelDate, Rider basicRider) throws CostException, SQLException, ObjectNotFoundException{

		BigDecimal refundAt = null;
		String method = getClubRefundMethod();

		if ("daily".equals(method)){
			// Since we conveniently did the daily proration enhancement along
			// with revenue, let's use the revenue record to determine the
			// duration of the rider
			try{
				Revenue rev = pc.getActiveRevenue();
				if (!cancelDate.after(rev.getRevenueStartDt())) return BigDecimal.ZERO;

				int totaldays = 0;
				int keepdays = 0;

				totaldays = RevenuePeriod.daysBetween(rev.getRevenueStartDt(), rev.getRevenueEndDt());
				keepdays = RevenuePeriod.daysBetween(rev.getRevenueStartDt(), cancelDate);
				if (totaldays == 0){
					throw new CostException("Unable to determine length of rider for " + pc);
				}
				double keepPct = (double) keepdays / (double) totaldays;
				double keepAt = rev.getOriginalDuesAt().doubleValue() * keepPct;
				double refund = rev.getOriginalDuesAt().doubleValue() - keepAt;
				if (refund <= .05)
					refundAt = BigDecimal.ZERO;
				else if (Math.abs(refund - rev.getOriginalDuesAt().doubleValue()) < .05)
					refundAt = rev.getOriginalDuesAt();
				else
					refundAt = (new BigDecimal(refund)).setScale(2, BigDecimal.ROUND_HALF_UP);
			}
			catch (ObjectNotFoundException e){
				log.error("Unable to find active revenue record for " + pc);
				refundAt = BigDecimal.ZERO;
			}
		}
		else{
			BigDecimal monthlyCost = calculateMonthlyCost(pc);

			if ("whole-month".equals(method)){
				refundAt = calculateRefundWholeMonths(pc, cancelDate, monthlyCost, basicRider);

				BigDecimal paymentAt = pc.getPaymentAt();
				if (refundAt.compareTo(paymentAt) > 0){
					refundAt = paymentAt.setScale(2, BigDecimal.ROUND_HALF_UP);
				}
			}
			else if ("end-of-month".equals(method)){
				refundAt = calculateRefundEOM(pc, cancelDate, monthlyCost);
			}
			else if ("".equals(method))
			{
				// Logic for prorating by a date
				// if we want to refund for a month based on a prorate date
				// For example: if today is > 15 dont refund for this month
				// Karan Kapoor - 07/16/2012 - TR 237 southern penn
				refundAt = calculateRefundbyDate(pc, cancelDate, monthlyCost, basicRider);
			}
			else{
				throw new CostException("Costing method for club " + ClubProperties.getClubCode() + ".  Method = " + method);
			}
		}
		return refundAt;
	}

	/**
	 * Get the monthly cost for this component.
	 * @param pc
	 * @param origCost
	 * @return
	 * @throws SQLException
	 * @throws CostException
	 */
	protected BigDecimal calculateMonthlyCost(PayableComponent pc) throws SQLException, CostException, ObjectNotFoundException{
		// everything is based on original cost
		BigDecimal origCost = pc.getDuesCostAt().add(pc.getDuesAdjustmentAt()).add(pc.getDiscountAt());
		if (origCost == null || origCost.compareTo(BigDecimal.ZERO) == 0) return BigDecimal.ZERO;

		Timestamp expirationDt = pc.getParentMember().getActiveExpirationDt();
		int months = DateUtilities.monthDiff(pc.getCostEffectiveDt(), expirationDt, true);
		// it is possible the membership was extended, so we cannot assume 12 months.
		boolean countExtendedMonths = false;
		int extendedMonths = 0;
		if (pc.getParentMember().getExtendCyclesCt() != null) {
			countExtendedMonths = pc.getParentMember().isExtendCharge();
			extendedMonths = pc.getParentMember().getExtendCyclesCt().intValue();
		}
		if (extendedMonths > 0 && !countExtendedMonths) {
			months -= extendedMonths;
		}
		
		BigDecimal result = origCost;
		if (months > 0){
			result = new BigDecimal(origCost.doubleValue() / (double)months).setScale(4, BigDecimal.ROUND_HALF_UP);
		}
		return result;
	}

	/**
	* Calculates refund amount due on an existing rider.  
	* @param pUser
	* @param vhm
	* @return BigDecimal
	* @throws CostException if xml contains an invalid costing method.
	* @throws ObjectNotFoundException when Rider can not be found.
	* @throws SQLException
	*/
	public BigDecimal calculateRiderRefund(User pUser, ValueHashMap vhm) throws CostException, SQLException, ObjectNotFoundException{
		Timestamp cancelDt = vhm.getTimestamp("CancelDt");
		BigDecimal riderKy = vhm.getBigDecimal("RiderKy");
		Rider rider = new Rider(pUser, riderKy);

		return calculateRefund(rider, cancelDt);
	}

	/**
	 * Figure out which method to use (whole month, end of month, etc.)
	 * @return
	 */
	@SuppressWarnings( { "unchecked" })
	private String getClubRefundMethod(){
		String clubCd = ClubProperties.getClubCode();
		boolean saveMethod = true;
		String method = clubRefundMethod.get(clubCd);
		if (method == null){
			// should be configured in the XML
			for (Iterator it = configuration.getRootElement().elementIterator("club"); it.hasNext();){
				Element el = (Element) it.next();
				if (clubCd.equals(el.attributeValue("clubcode"))){
					Element methodElement = el.element("refund-method");
					if (methodElement != null){
						method = methodElement.getTextTrim();
					}
					Element cutoff = el.element("cutoff-dayofmonth");
					if (cutoff != null){
						String cutoffStr = cutoff.getTextTrim();
						if (StringUtils.isNumeric(cutoffStr)){
							_cutoffDay = Integer.parseInt(cutoffStr);
						}
					}
				}
				else if ("always-load-config".equals(el.getName())){
					saveMethod = false;
				}
			}
		}
		if (saveMethod){
			clubRefundMethod.put(clubCd, method);
		}
		return method;
	}
	
	/**
	 * Overridden in child classes.
	 * Returns a boolean indicating if the last month should be refunded
	 * if within 30 days of expiration date. Will return true unless special logic exists
	 * in a club-specific version of CostBP
	 * @return
	 */
	protected boolean refundFinalMonth(){
		return true;
	}

	/**
	 * Refunds the membership based on number of months it should prorate
	 * Takes the cutoff date from cost.xml for prorate.
	 * @return The prorated refund amount, or zero if no refund is due.
	 */
	
	// No implementation before existed for refund based on a prorate date
	// This method handles that, if you want to prorate using a date make sure that your xml for club code doesn't have anything in "<refund-method>" tag
	// make that tag null and then this logic will work. 
	// Karan Kapoor - 07/16/2012 - TR 237 southern penn
	private BigDecimal calculateRefundbyDate(PayableComponent pc, Timestamp cancelDt, BigDecimal monthlyCost, Rider basic) throws SQLException, ObjectNotFoundException {
		Member member = pc.getParentMember();
		Rider basicRider = basic;
		if(basicRider == null)
			basicRider = member.getBasicRider();
		Timestamp expirationDt = member.getActiveExpirationDt();
		BigDecimal calcRefund = new BigDecimal("0");

		BigDecimal paymentAt = new BigDecimal(pc.getPaymentAt().toString()).setScale(2,BigDecimal.ROUND_HALF_UP);
		Timestamp futureCancelDt = pc.getFutureCancelDt();
		BigDecimal futureCancelCreditAt = pc.getFutureCancelCreditAt();

		//keep variable defines months money we are keeping with us
		int keep = DateUtilities.monthDiff(pc.getCostEffectiveDt(),cancelDt,true);
		int cutoff = 0;
		cutoff = _cutoffDay;
		Calendar cal = Calendar.getInstance();
		int dayOfMonth = cal.get(Calendar.DATE);
		if (dayOfMonth > cutoff) {
			keep = keep + 1;
		}
		// Adding 1 to keep to keep this month's money and refund from next month
		BigDecimal keepAt = new BigDecimal((double)keep * monthlyCost.doubleValue()).setScale(2,BigDecimal.ROUND_HALF_UP);
		if (keepAt.compareTo(paymentAt) >=0) {
			calcRefund = ZERO;
		}
		else {
			// Payment - keep = refund
			calcRefund = paymentAt.subtract(keepAt);
		}
		return calcRefund;
	}
	
	/**
	 * Calculate credit for cancelling a component - whole months method.
	 * 
	 * 05/02/10 AM: Refactored to focus on how much money to keep rather
	 *  than how much to refund.  This was due to illogical refund amounts
	 *  on partially paid components.
	 * 
	 * @return The prorated refund amount, or zero if no refund is due.
	 */
	protected BigDecimal calculateRefundWholeMonths(PayableComponent pc, Timestamp cancelDt, BigDecimal monthlyCost, Rider basic) throws SQLException, ObjectNotFoundException{
		Member member = pc.getParentMember();
		Rider basicRider = basic;
		if(basicRider == null)
			basicRider = member.getBasicRider();
		Timestamp expirationDt = member.getActiveExpirationDt();
		BigDecimal calcRefund = new BigDecimal("0");

		BigDecimal paymentAt = new BigDecimal(pc.getPaymentAt().toString()).setScale(2,BigDecimal.ROUND_HALF_UP);
		Timestamp futureCancelDt = pc.getFutureCancelDt();
		BigDecimal futureCancelCreditAt = pc.getFutureCancelCreditAt();

		if (cancelDt.getTime() == pc.getCostEffectiveDt().getTime()){
			// cancel date = cost effective date: full refund
			calcRefund = paymentAt;
		}
		else if (!expirationDt.after(cancelDt)){
			// cancelDate on or after expDate no refund
			calcRefund = BigDecimal.valueOf(0);
		}
//		else if (pc.getCostEffectiveDt().before(basicRider.getCostEffectiveDt())){
//			// prior year add that wasn't cycled, and is now getting cancelled.  Refund whatever was calculated last year.
//			if (futureCancelDt != null && futureCancelDt.before(basicRider.getCostEffectiveDt())){
//				return futureCancelCreditAt;
//			}
//			return BigDecimal.ZERO;
//		}
		else if (ClubProperties.isFullRefundWithin30Days(member.getParentMembership()) && cancelDt.before(DateUtilities.timestampAdd(Calendar.DATE, 30, pc.getCostEffectiveDt()))){
			//
			// Within thirty days, give full refund
			//
			calcRefund = paymentAt;
		}
		else if (cancelDt.before(pc.getCostEffectiveDt())){
			// refund the payment_at
			calcRefund = paymentAt;
		}
		else{
			// it is possible the membership was extended, so we cannot assume 12 months.
			String clubCd = ClubProperties.getClubCode(); 
			boolean countExtendedMonths = false;
			int extendedMonths = 0;
			if (member.getExtendCyclesCt() != null) {
				countExtendedMonths = member.isExtendCharge();
				extendedMonths = member.getExtendCyclesCt().intValue();
			}

			// how many months do we have to keep money for?
			int keep = DateUtilities.monthDiff(pc.getCostEffectiveDt(),cancelDt,true);
			// do we always refund final month when cancel date < expiration?			
			
			// how many months do we have to keep money for?
			//int keep = DateUtilities.monthDiff(pc.getCostEffectiveDt(),cancelDt,true);
			// do we always refund final month when cancel date < expiration?
			if (refundFinalMonth() && keep == 12 + extendedMonths && cancelDt.before(expirationDt)) {
				if (countExtendedMonths) {
					keep = 12 + extendedMonths - 1;
				}
				else {
					keep = 11;
				}
			}
			if (keep == 12 + extendedMonths) {
				calcRefund = paymentAt;
			}
			else {
				BigDecimal keepAt = new BigDecimal((double)keep * monthlyCost.doubleValue()).setScale(2,BigDecimal.ROUND_HALF_UP);
				if (keepAt.compareTo(paymentAt) >=0) {
					calcRefund = ZERO;
				}
				else {
					calcRefund = paymentAt.subtract(keepAt);
				}
			}
		}

		return calcRefund;
	}

	/**
	 * Calculate credit for cancelling a component - End-of-month (097).
	 * 
	 * @return The prorated refund amount, or zero if no refund is due.
	 */
	private BigDecimal calculateRefundEOM(PayableComponent pc, Timestamp cancelDt, BigDecimal monthlyCost) throws SQLException{
		Member member = pc.getParentMember();
		Rider basicRider = member.getBasicRider();
		Timestamp expirationDt = member.getMemberExpirationDt();
		BigDecimal calcRefund = new BigDecimal("0");

		// If the expiration hasn't been rolled, set it out a year for calculation purposes.
		if (!expirationDt.after(basicRider.getCostEffectiveDt())){
			Calendar cal = Calendar.getInstance();
			cal.setTimeInMillis(expirationDt.getTime());
			cal.set(Calendar.YEAR, cal.get(Calendar.YEAR) + 1);
			expirationDt = new Timestamp(cal.getTimeInMillis());
		}
		Timestamp futureCancelDt = null;
		BigDecimal futureCancelCreditAt = null;

		if (pc instanceof Rider){
			futureCancelDt = ((Rider) pc).getFutureCancelDt();
			futureCancelCreditAt = ((Rider) pc).getFutureCancelCreditAt();
		}

		BigDecimal paymentAt = pc.getPaymentAt();
		log.debug("******MDC3 Exp_dt = " + expirationDt + "   Cancel_dt = " + cancelDt);

		if (pc.getEffectiveDt() == null){
			//
			// Rider was never effective, refund full amount
			//
			calcRefund = new BigDecimal(paymentAt.doubleValue()).setScale(2, BigDecimal.ROUND_HALF_UP);
			log.debug("Payable Component was never in effect. Refund full amount paid");
		}
		else if (member.getMemberExpirationDt().compareTo(basicRider.getCostEffectiveDt()) == 0){
			//
			// member went into renewal and was never made active, so refund the full amount
			//
			calcRefund = new BigDecimal(paymentAt.doubleValue()).setScale(2, BigDecimal.ROUND_HALF_UP);
			log.debug("Member never active after new/renewal. Refund full amount paid");
		}
		else if (!expirationDt.after(cancelDt)){
			// cancelDate on or after expDate no refund
			calcRefund = BigDecimal.valueOf(0);
		}
		else if (pc.getCostEffectiveDt().before(basicRider.getCostEffectiveDt())){
			// prior year add that wasn't cycled, and is now getting cancelled.  Refund whatever was calculated last year.
			if (futureCancelDt != null && futureCancelDt.before(basicRider.getCostEffectiveDt())){
				return futureCancelCreditAt;
			}
			return BigDecimal.ZERO;
		}
		else if (cancelDt.before(DateUtilities.timestampAdd(Calendar.DATE, 30, pc.getEffectiveDt()))){
			//
			// Within thirty days, give full refund
			//
			log.debug("Cancellation within first thirty days. Refund full amount paid");
			calcRefund = new BigDecimal(paymentAt.doubleValue()).setScale(2, BigDecimal.ROUND_HALF_UP);
		}
		else if (cancelDt.compareTo(pc.getCostEffectiveDt()) <= 0){
			// refund the payment_at
			log.debug("Cancel date before costEffective, refunding the full amount");
			calcRefund = new BigDecimal(paymentAt.doubleValue()).setScale(2, BigDecimal.ROUND_HALF_UP);
		}
		else{
			// prorate the credit amount
			int cancelMonth = (DateUtilities.date2calendar(cancelDt)).get(Calendar.MONTH);
			int expirationMonth = (DateUtilities.date2calendar(expirationDt)).get(Calendar.MONTH);
			int monthsLeft = 0;
			while (cancelMonth != expirationMonth){
				monthsLeft++;
				cancelMonth++;
				if (cancelMonth == 12){
					cancelMonth = 0;
				}
			}
			//TT 8187 FCW
			int today = (DateUtilities.date2calendar(cancelDt)).get(Calendar.DATE);
			if (today < _cutoffDay){
				monthsLeft++;
			}
			// Special case, if monthsLeft = 12, just refund the whole amount
			if (monthsLeft == 12){
				calcRefund = paymentAt;
			}
			else{

				calcRefund = monthlyCost.multiply(new BigDecimal(monthsLeft)).setScale(2, BigDecimal.ROUND_HALF_UP);
				// never refund more than they've paid
				if (paymentAt.compareTo(calcRefund) < 0){
					calcRefund = paymentAt;
				}
			}
			log.debug("refund calculation = " + calcRefund);
		}

		return new BigDecimal(calcRefund.toString());
	}

	/**
	 * Recosts the primary rider when adding a member to the membership.   
	 * 
	 * @param membership
	 * @param rider
	 * @param numCurrentMembersBefore the number of non-cancelled members before a new member is added
	 * @param numCurrentMembersAfter
	 * @return an increase amount dues to the change of number of members
	 * @throws Exception
	 */
	public BigDecimal recostPrimaryRiderWhenMembersAdded(Membership membership, Rider rider, int numCurrentMembersBefore, int numCurrentMembersAfter)
			throws Exception{
		// do nothing here, to be overwritten in children classes
		return ZERO;
	}

	/**
	 * Recosts the primary rider when cancelling a member.   
	 * 
	 * @param rider
	 * @param numberOfCurrentMembers number of current members after the cancellation
	 * @param cancelDt
	 * @return a decrease amount dues to the change of number of members
	 * @throws Exception
	 */
	public BigDecimal recostPrimaryRiderOnCancellation(Rider rider, int numberOfCurrentMembers, Timestamp cancelDt, String originalCd) throws Exception{
		// to be overwritten in children classes
		return BigDecimal.ZERO;
	}

	/**
	 * Moved here from MemberzPlusServiceCostBP.java.
	 * 
	 * @param club_cd
	 * @param billing_cat_cd
	 * @param region_cd
	 * @param divisionKy
	 * @param branchKy
	 * @param rider_comp_cd
	 * @param member_type
	 * @param expirationDate
	 * @return
	 * @throws Exception
	 */
	public CostData getRiderCost(Membership membership, PayableComponent pc, String club_cd, String billing_cat_cd, String region_cd, BigDecimal divisionKy, BigDecimal branchKy,
			String rider_comp_cd, String member_type, Timestamp expirationDate, String state) throws Exception{
		return getRiderCost(membership, pc, club_cd, billing_cat_cd, region_cd, divisionKy, branchKy, rider_comp_cd, member_type, expirationDate, "PRIMARY", null,
				"N", "STD", state);
	}

	//wwei JRDR 
	public CostData getRiderCostFullTerm(Membership membership, PayableComponent pc, String club_cd, String billing_cat_cd, String region_cd, BigDecimal divisionKy, BigDecimal branchKy,
			String rider_comp_cd, String member_type, Timestamp expirationDate, String dateType, Member member, String commissionCd,
			String membershipTypeCd, String state) throws Exception{
		if (expirationDate == null) expirationDate = DateUtilities.timestampAdd(Calendar.YEAR, 1, DateUtilities.getTimestamp(true));

		//now get  prorated cost
		CostData cd = new CostData();
		cd.setPrimaryExpiration(expirationDate);
		cd.setMemberExpiration(expirationDate);
		String memberStatus = "P";
		String primaryBasicStatus = "P";

		if (member != null){
			try{
				memberStatus = member.getStatus();
				primaryBasicStatus = member.getParentMembership().getPrimaryMember().getBasicRider().getStatus();
			}
			catch (NullPointerException ne){
				primaryBasicStatus = "P";
			}
			cd.setPrimaryInBilling(member.getParentMembership().getPrimaryMember().inRenewal());
			cd.setPrimaryActiveExpiration(member.getParentMembership().getPrimaryMember().getActiveExpirationDt());
			cd.setPrimaryExpiration(member.getParentMembership().getPrimaryMember().getMemberExpirationDt());
			
			cd.setMemberExpiration(member.getMemberExpirationDt());
			cd.setActiveExpiration(member.getActiveExpirationDt());
			cd.setMemberInBilling(member.inRenewal());
		}

		cd.setMembershipTypeCd(membershipTypeCd);
		cd.setBillingCategoryCd(getSolicitationBillingCategoryForCosting(membership, pc, pc.getSolicitationCd(), billing_cat_cd));
		cd.setCommissionCd(commissionCd);
		cd.setMemberType(member_type);
		cd.setMemberStatus(memberStatus);
		cd.setPrimaryBasicStatus(primaryBasicStatus);
		cd.setRiderCompCd(rider_comp_cd);
		cd.setStartDate(pc.getCostEffectiveDt());
		cd.setRegionCd(region_cd);
		cd.setDivisionKy(divisionKy);
		//Prakash - 07/16/2018 - Dues By State - Start
		cd.setDuesState(state);
		//Prakash - 07/16/2018 - Dues By State - End
		cd.setBranchKy(branchKy);
		cd.setDateType(dateType);
		cd = getComponentCostFullTerm(cd);
		return cd;
	}
	/**
	*returns an array of two riders costed, one element is full cost, one is prorated cost
	*
	* changed signature from CostData[] to CostData
	*
	*
	**/
	public CostData getRiderCost(Membership membership, PayableComponent pc, String club_cd, String billing_cat_cd, String region_cd, BigDecimal divisionKy, BigDecimal branchKy,
			String rider_comp_cd, String member_type, Timestamp expirationDate, String dateType, Member member, String commissionCd,
			String membershipTypeCd, String state) throws Exception{
		if (expirationDate == null) expirationDate = DateUtilities.timestampAdd(Calendar.YEAR, 1, DateUtilities.getTimestamp(true));

		//now get  prorated cost
		CostData cd = new CostData();
		cd.setPrimaryExpiration(expirationDate);
		cd.setMemberExpiration(expirationDate);
		String memberStatus = "P";
		String primaryBasicStatus = "P";

		if (member != null){
			try{
				memberStatus = member.getStatus();
				primaryBasicStatus = member.getParentMembership().getPrimaryMember().getBasicRider().getStatus();
			}
			catch (NullPointerException ne){
				primaryBasicStatus = "P";
			}
			cd.setPrimaryInBilling(member.getParentMembership().getPrimaryMember().inRenewal());
			cd.setPrimaryActiveExpiration(member.getParentMembership().getPrimaryMember().getActiveExpirationDt());
			cd.setPrimaryExpiration(member.getParentMembership().getPrimaryMember().getMemberExpirationDt());
			
			cd.setMemberExpiration(member.getMemberExpirationDt());
			cd.setActiveExpiration(member.getActiveExpirationDt());
			cd.setMemberInBilling(member.inRenewal());
		}

		cd.setMembershipTypeCd(membershipTypeCd);
		cd.setBillingCategoryCd(getSolicitationBillingCategoryForCosting(membership, pc, pc.getSolicitationCd(), billing_cat_cd));
		cd.setCommissionCd(commissionCd);
		cd.setMemberType(member_type);
		cd.setMemberStatus(memberStatus);
		cd.setPrimaryBasicStatus(primaryBasicStatus);
		cd.setRiderCompCd(rider_comp_cd);
		cd.setStartDate(pc.getCostEffectiveDt());
		cd.setRegionCd(region_cd);
		cd.setDivisionKy(divisionKy);
		//Prakash - 07/16/2018 - Dues By State - Start
		cd.setDuesState(state);
		//Prakash - 07/16/2018 - Dues By State - End
		cd.setBranchKy(branchKy);
		cd.setDateType(dateType);
		cd = getComponentCost(cd);
		return cd;
	}
	
	/**
	 * Returns the proper billing category cd to be used for costing based off rules on the solicitation cd.
	 * Returns the current billing category cd if the solicitation cd it's tied to has not met its max
	 * number of associates. Returns the club's default billing category cd if the max number of associates
	 * @param membership
	 * @param solicitationCd
	 * @return String Billing Category Code
	 * @throws ObjectNotFoundException
	 * @throws SQLException
	 */
	public String getSolicitationBillingCategoryForCosting(Membership membership, PayableComponent pc, String solicitationCd, String billingCategoryCd)
			throws ObjectNotFoundException, SQLException{
		Solicitation solicitation = null;
		if (!"".equals(StringUtils.blanknull(solicitationCd))){
			try {
				solicitation = Solicitation.getSolicitation(user, solicitationCd);
			}
			catch (ObjectNotFoundException e) {
				// old solicitation, just return the billing category
				return billingCategoryCd;
			}
			int maxAssociates = (solicitation.getAssociateCt() != null && solicitation.getAssociateCt().compareTo(BigDecimal.ZERO) > 0) ? solicitation
					.getAssociateCt().intValue()
					: 99;
			//we only need to check the riders of non-cancelled members riders.
			for (Member member : membership.getMemberList()){
				if (!member.isCancelled()
						|| (member.getAttribute("CAN_REINSTATE") != null && Boolean.parseBoolean(member.getAttribute("CAN_REINSTATE").toString()))){
					if (!member.isPrimary() && pc.getMemberKy().compareTo(membership.getPrimaryMember().getMemberKy()) != 0){
						for (Rider rider : member.getRiderList()){
							//if this member is the parent member for this payable component, and they have not yet met the max associate ct, let them have the free code.
							if (pc.getMemberKy().compareTo(member.getMemberKy()) == 0 && maxAssociates > 0){
								return billingCategoryCd;
							}
							//check each rider to see if it is the same one on the component being costed
							//we only decrement once per member
							if (rider.getSolicitationCd() != null && rider.getSolicitationCd().equals(solicitationCd)){
								maxAssociates--;
								break;
							}
						}

						//if max associates for this solicitation has been reached, cost with the default billing category cd
						if (maxAssociates <= 0){
							return billingCategoryCd = ClubProperties.getDefaultBillingCategory(membership.getDivisionKy(), membership
									.getRegionCode());
						}
					}
				}
			}
		}
		return billingCategoryCd;
	}
	//PC:ISF 06/27/2016: To include Same day service fee or Immediatye Service Feee
	public BigDecimal getISFCost(Membership membership,BigDecimal divisionKy, Timestamp effectiveDate) throws Exception{
		
		
		BigDecimal isfFee = new BigDecimal(0);
		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
		criteria.add(new SearchCondition(RiderCost.RIDER_COMP_CD, SearchCondition.EQ, "ISF"));
		criteria.add(new SearchCondition(RiderCost.BEGIN_DT, SearchCondition.LT + SearchCondition.EQ, effectiveDate));
		SearchCondition endCondition = new SearchCondition(RiderCost.END_DT, SearchCondition.GT + SearchCondition.EQ, effectiveDate);
		endCondition.add("OR", RiderCost.END_DT, SearchCondition.ISNULL);
		criteria.add(endCondition);
		
		Division d = new Division(user,divisionKy,true);
		SortedSet<RiderCost> riderCostList = RiderCost.getRiderCostList(user, d,criteria, null);
		if (riderCostList !=null && !riderCostList.isEmpty())
		{
			for (RiderCost rc : riderCostList) { 
				isfFee =  rc.getNewAt();				                                
				break;
			}
	
		}
		return isfFee;
		
		
	}	
		
		
		
		
		
		
		
		
		
		
	
}
