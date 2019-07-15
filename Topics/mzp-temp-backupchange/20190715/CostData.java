/*
 ********************************************************************************
 MODULE        :  CostData
 DESCRIPTION   :  Used in CostBP to encapsulate all the various settings.
 
 Copyright (c) 2005 Ross Group Inc - The source code for
 this program is not published or otherwise divested of its trade secrets,
 irrespective of what has been deposited with the U.S. Copyright office.
 
 ********************************************************************************
 Modification Log:
   Date     | Developer     |Ticket#  |Description
 -----------| --------------|---------|------------------------------------------
 ********************************************************************************
 */
package com.rossgroupinc.memberz.bp.cost;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

import com.rossgroupinc.util.JavaUtilities;

public class CostData implements Serializable, Cloneable, Comparable {
	private static final long	serialVersionUID	= 1L;

	private boolean				valid				= false;

	//private CostData[] costCollection 
	private BigDecimal			riderCalcCost		= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal			riderDuesCost		= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal			fullCost			= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal			actualCost			= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal			feeCost				= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	private BigDecimal			isfCost			= new BigDecimal("0").setScale(2, BigDecimal.ROUND_HALF_UP);
	
	
	
	private BigDecimal			fullPremium			= BigDecimal.ZERO;
	private BigDecimal			actualPremium		= BigDecimal.ZERO;
	private boolean				prorateLeadTime		= false;
	private int					prorateLeadMonths	= 0;
	private int					prorateMonth		= 0;
	private int					currentMonth		= 0;
	private boolean				prorate				= false;
	private boolean             fixedPrice          = false;

	private String				riderCompCd			= "";
	private String				regionCd			= "";
	private String				state				= "";
	private BigDecimal			divisionKy			= null;
	private BigDecimal			branchKy			= null;
	//private String billingCd = "";
	//private String membershipStatus = "";
	private String				primaryBasicStatus	= "";
	private String				memberStatus		= "";
	private String				memberType			= "";
	private Timestamp			primaryExpiration	= null;
	private Timestamp			memberExpiration	= null;
	private Timestamp           activeExpiration    = null;
	private Timestamp           primaryActiveExpiration = null;
	private Timestamp			costEffectiveDate	= null;
	private String				billingCategoryCd	= "";
	private String				commissionCd		= "";
	private String				dateType			= "";
	private Timestamp			startDate			= null;
	private String				associateId			= "";
	private String				errorMessage		= null;
	private boolean				memberInBilling		= false;
	private boolean				primaryInBilling	= false;
	private boolean				inBillingSet		= false;
	private String				membershipTypeCd;

	private boolean 			downgrading 		= false; 
	private boolean 			upgrading 			= false;
	
	private String 				associateIdRD		= "";
	
	public CostData() {}

	public boolean isValid(){
		return valid;
	}

	public void setValid(boolean inval){
		valid = inval;
	}

	public void setPrimaryInBilling(boolean flag){
		primaryInBilling = flag;
		inBillingSet = true;
	}

	public boolean isPrimaryInBilling(){
		if (inBillingSet) return primaryInBilling;
		else if (primaryExpiration != null && primaryActiveExpiration != null)
			return primaryExpiration.before(primaryActiveExpiration);
		return ("P".equals(primaryBasicStatus));
	}

	public void setMemberInBilling(boolean flag){
		memberInBilling = flag;
		inBillingSet = true;
	}

	public boolean isMemberInBilling(){
		if (inBillingSet) return memberInBilling;
		else if (memberExpiration != null && activeExpiration != null)
			return memberExpiration.before(activeExpiration);
		return ("P".equals(memberStatus));
	}
	
	public String getAssociateIdRD() {
		return associateIdRD;
	}

	public void setAssociateIdRD(String associateIdRD) {
		this.associateIdRD = associateIdRD;
	}

	public BigDecimal getRiderCalcCost(){
		return riderCalcCost;
	}

	protected void setRiderCalcCost(BigDecimal inval){
		this.riderCalcCost = inval;
	}

	public BigDecimal getProratedCost(){
		return fullCost;
	}

	protected void setProratedCost(BigDecimal inval){
		this.fullCost = inval;
	}

	public BigDecimal getFullCost(){
		return actualCost;
	}

	protected void setFullCost(BigDecimal inval){
		this.actualCost = inval;
	}
	
	//JS - new method for Dues Calculator Web Service
	public void setFullCostDC(BigDecimal inval){
		this.actualCost = inval;
	}
	
	//YH- Renewal Discount for Dues Calculator Web Service
	public void setFullCostRD(BigDecimal inval){
		this.fullCost = inval;
	}

	public BigDecimal getProratedPremium(){
		return fullPremium;
	}

	protected void setProratedPremium(BigDecimal inval){
		this.fullPremium = inval;
	}

	public BigDecimal getFullPremium(){
		return actualPremium;
	}

	protected void setFullPremium(BigDecimal inval){
		this.actualPremium = inval;
	}
	
	//JS - new method for Dues Calculator Web Service
	public void setFullPremiumDC(BigDecimal inval){
		this.actualPremium = inval;
	}

	public BigDecimal getEnrollmentFee(){
		return feeCost;
	}

	protected void setEnrollmentFee(BigDecimal inval){
		this.feeCost = inval;
	}
	public BigDecimal getISFFee(){
		return isfCost;
	}

	protected void setISFFee(BigDecimal inval){
		this.isfCost = inval;
	}
	
	//JS - new method for Dues Calculator Web Service
	public void setEnrollmentFeeDC(BigDecimal inval){
		this.feeCost = inval;
	}

	public boolean isProrateLeadTime(){
		return prorateLeadTime;
	}

	protected void setProrateLeadTime(boolean inval){
		prorateLeadTime = inval;
	}
	
	//JS - new setprorateleadtime for use with dues calculator webservice
	public void setProrateLeadTimeDC(boolean inval){
		prorateLeadTime = inval;
	}

	public int getProrateLeadMonths(){
		return prorateLeadMonths;
	}

	protected void setProrateLeadMonths(int inval){
		this.prorateLeadMonths = inval;
	}
	
	//JS - New set prorate lead months for dues calculator webservice
	public void setProrateLeadMonthsDC(int inval){
		this.prorateLeadMonths = inval;
	}

	public int getProrateMonth(){
		return prorateMonth;
	}

	protected void setProrateMonth(int inval){
		this.prorateMonth = inval;
	}

	public int getCurrentMonth(){
		return currentMonth;
	}

	protected void setCurrentMonth(int inval){
		this.currentMonth = inval;
	}

	public boolean isFixedPrice() {
		return fixedPrice;
	}
	
	public void setFixedPrice(boolean fl) {
		fixedPrice = fl;
	}
	
	public boolean isProrate(){
		return prorate;
	}

	protected void setProrate(boolean inval){
		prorate = inval;
	}
	
	//JS - new setprorate for use with dues calculator webservice
	public void setProrateDC(boolean inval){
		prorate = inval;
	}

	/* FOLLOWING SUPPLIED BY BEAN/PAGE */
	public String getRiderCompCd(){
		return riderCompCd;
	}

	public void setRiderCompCd(String inval){
		this.riderCompCd = inval;
	}

	public String getRegionCd(){
		return regionCd;
	}

	public void setRegionCd(String inval){
		this.regionCd = inval;
	}
	//Prakash - 07/02/2018 - Dues By State - Start
	public String getDuesState(){
		return state;
	}
	
	public void setDuesState(String inval){
		this.state = inval;
	}
	//Prakash - 07/02/2018 - Dues By State - End	
	public String getPrimaryBasicStatus(){
		return primaryBasicStatus;
	}

	public void setPrimaryBasicStatus(String inval){
		this.primaryBasicStatus = inval;
	}

	public String getMemberStatus(){
		return memberStatus;
	}

	public void setMemberStatus(String inval){
		this.memberStatus = inval;
	}

	public String getMemberType(){
		return memberType;
	}

	public void setMemberType(String inval){
		this.memberType = inval;
	}

	public Timestamp getMemberExpiration(){
		return memberExpiration;
	}

	public void setMemberExpiration(Timestamp inval){
		this.memberExpiration = inval;
	}

	public Timestamp getPrimaryExpiration(){
		return primaryExpiration;
	}

	public void setPrimaryExpiration(Timestamp inval){
		this.primaryExpiration = inval;
	}

	public String getBillingCategoryCd(){
		return billingCategoryCd;
	}

	public void setBillingCategoryCd(String inval){
		this.billingCategoryCd = inval;
	}

	public String getCommissionCd(){
		return commissionCd;
	}

	public void setCommissionCd(String inval){
		this.commissionCd = inval;
	}

	public String getDateType(){
		return dateType;
	}

	public void setDateType(String inval){
		this.dateType = inval;
	}

	public Timestamp getStartDate(){
		return startDate;
	}

	public void setStartDate(Timestamp inval){
		this.startDate = inval;
	}

	public String getAssociateId(){
		return associateId;
	}

	public void setAssociateId(String inval){
		this.associateId = inval;
	}

	/* non-Javadoc)
	 * @see java.lang.Object#toString()
	 * Constructs a <code>String</code> with all attributes
	 * in name = value format.
	 *
	 * @return a <code>String</code> representation 
	 * of this object.
	 */
	public String toString(){
		final String TAB = "\n";

		String retValue = "";

		retValue = "CostData ( " + TAB + "valid = " + this.valid + TAB + "fullCost = " + this.fullCost + TAB + "actualCost = " + this.actualCost
				+ TAB + "isfCost = " + this.isfCost + TAB 
				+ TAB + "feeCost = " + this.feeCost + TAB + "fullPremium = " + this.fullPremium + TAB + "actualPremium = " + this.actualPremium + TAB
				+ "prorateLeadTime = " + this.prorateLeadTime + TAB + "prorateLeadMonths = " + this.prorateLeadMonths + TAB + "prorateMonth = "
				+ this.prorateMonth + TAB + "currentMonth = " + this.currentMonth + TAB + "prorate = " + this.prorate + TAB + "riderCompCd = "
				+ this.riderCompCd + TAB + "regionCd = " + this.regionCd + TAB + "divisionKy = " + this.divisionKy + TAB + "branchKy = "
				+ this.branchKy + TAB + "primaryBasicStatus = " + this.primaryBasicStatus + TAB + "memberStatus = " + this.memberStatus + TAB
				+ "memberType = " + this.memberType + TAB + "primaryExpiration = " + this.primaryExpiration + TAB + "memberExpiration = "
				+ this.memberExpiration + TAB + "costEffectiveDate = " + this.costEffectiveDate + TAB + "billingCategoryCd = "
				+ this.billingCategoryCd + TAB + "commissionCd = " + this.commissionCd + TAB + "dateType = " + this.dateType + TAB + "startDate = "
				+ this.startDate + TAB + "associateId = " + this.associateId + TAB + "associateIdRD = " + this.associateIdRD + TAB 
				+ "isUpgrading = " + this.upgrading + TAB
				+ "isDowngrading = " + this.downgrading + TAB
				+ "errorMessage = " + this.errorMessage + TAB
				+ "memberInBilling = " + this.memberInBilling + TAB + "primaryInBilling = " + this.primaryInBilling + TAB + "inBillingSet = "
				+ this.inBillingSet + TAB + "membershipTypeCd = " + this.membershipTypeCd + TAB
				//Prakash - 07/02/2018 - Dues By State - Start
				+ "state = " + this.state + TAB + " )";

		return retValue;
	}

	//for wm debugging purpose
	public String toShortString(){
		final String TAB = "\n";

		String retValue = "";

		retValue = "CostData ( "
				+ TAB + "memberType = " + this.memberType 
				+ TAB + "associateId = " + this.associateId 
				+ TAB + "associateIdRD = " + this.associateIdRD  
				+ TAB + "riderCompCd = " + this.riderCompCd 
				+ TAB + "isUpgrading = " + this.upgrading 
				+ TAB + "isDowngrading = " + this.downgrading
//				+ TAB + "fullCost = " + this.fullCost + TAB + "actualCost = " + this.actualCost
//				+ TAB + "isfCost = " + this.isfCost + TAB 
//				+ TAB + "feeCost = " + this.feeCost + TAB + "fullPremium = " + this.fullPremium + TAB + "actualPremium = " + this.actualPremium + TAB
//				+ "prorateLeadTime = " + this.prorateLeadTime + TAB + "prorateLeadMonths = " + this.prorateLeadMonths + TAB + "prorateMonth = "
//				+ this.prorateMonth + TAB + "currentMonth = " + this.currentMonth + TAB + "prorate = " + this.prorate + TAB + "regionCd = " + this.regionCd + TAB + "divisionKy = " + this.divisionKy + TAB + "branchKy = "
//				+ this.branchKy + TAB + "primaryBasicStatus = " + this.primaryBasicStatus + TAB + "memberStatus = " + this.memberStatus + TAB + "primaryExpiration = " + this.primaryExpiration + TAB + "memberExpiration = "
//				+ this.memberExpiration + TAB + "costEffectiveDate = " + this.costEffectiveDate + TAB + "billingCategoryCd = "
//				+ this.billingCategoryCd + TAB + "commissionCd = " + this.commissionCd + TAB + "dateType = " + this.dateType + TAB + "startDate = "
//				+ this.startDate + TAB 
//				+ "errorMessage = " + this.errorMessage + TAB
//				+ "memberInBilling = " + this.memberInBilling + TAB + "primaryInBilling = " + this.primaryInBilling + TAB + "inBillingSet = "
//				+ this.inBillingSet + TAB + "membershipTypeCd = " + this.membershipTypeCd + TAB
				//Prakash - 07/02/2018 - Dues By State - Start
//				+ "state = " + this.state 
				+ TAB + " )";

		return retValue;
	}
	
	/**
	 * @return Returns the errorMessage.
	 */
	public String getErrorMessage(){
		return errorMessage;
	}

	/**
	 * @param errorMessage The errorMessage to set.
	 */
	public void setErrorMessage(String errorMessage){
		this.errorMessage = errorMessage;
	}

	/**
	 * @return Returns the costEffectiveDate.  If the cost effective date has 
	 * not been set, returns the primaryExpiration.  This value is used to
	 * select the date range for the rider cost record.
	 */
	public Timestamp getCostEffectiveDate(){
		if (costEffectiveDate == null)
			return getPrimaryExpiration();
		else
			return costEffectiveDate;
	}

	/**
	 * @param costEffectiveDate The costEffectiveDate to set.
	 */
	public void setCostEffectiveDate(Timestamp costEffectiveDate){
		this.costEffectiveDate = costEffectiveDate;
	}

	@Override
	public Object clone() throws CloneNotSupportedException{
		return JavaUtilities.cloneSerializable(this);
	}

	public BigDecimal getDivisionKy(){
		return divisionKy;
	}

	public void setDivisionKy(BigDecimal divisionKy){
		this.divisionKy = divisionKy;
	}

	public BigDecimal getBranchKy(){
		return branchKy;
	}

	public void setBranchKy(BigDecimal branchKy){
		this.branchKy = branchKy;
	}

	public String getMembershipTypeCd(){
		return membershipTypeCd;
	}

	public void setMembershipTypeCd(String membershipTypeCd){
		this.membershipTypeCd = membershipTypeCd;
	}

	public Timestamp getActiveExpiration(){
		// temporary to avoid npe on older code.
		// SET ACTIVE EXPIRATION DATE!!!
		if (activeExpiration == null) return memberExpiration;
		return activeExpiration;
	}

	public void setActiveExpiration(Timestamp activeExpiration){
		this.activeExpiration = activeExpiration;
	}

	public Timestamp getPrimaryActiveExpiration(){
		// temporary to avoid npe on older code.
		// SET ACTIVE EXPIRATION DATE!!!
		if (primaryActiveExpiration == null) return primaryExpiration;
		return primaryActiveExpiration;
	}

	public void setPrimaryActiveExpiration(Timestamp primaryActiveExpiration){
		this.primaryActiveExpiration = primaryActiveExpiration;
	}

	public boolean isDowngrading() {
		return downgrading;
	}

	public void setDowngrading(boolean downgrading) {
		this.downgrading = downgrading;
	}
	
	public boolean isUpgrading() {
		return upgrading;
	}

	public void setUpgrading(boolean upgrading) {
		this.upgrading = upgrading;
	}

	@Override
	public int compareTo(Object o) {
		int result = 0; 
		CostData dest = (CostData) o; 
		if (this.getAssociateId().compareTo(dest.getAssociateId()) <0) {
			result  = -1;
		} else if (this.getAssociateId().compareTo(dest.getAssociateId()) > 0) {
			result = 1; 
		}
		
		return result;
	}

}
