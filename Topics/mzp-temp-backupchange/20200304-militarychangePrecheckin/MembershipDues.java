package com.aaa.soa.object.models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Collection;


/**
 * This is the value object returned as payload of the MembershipDuesCalculator Calculate web service call. 
 * @author konstantin.ostrobrod
 *
 */
public class MembershipDues extends WebServiceResponseBase implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	//payload
	private String _zipCode;
	private int _associateCount;
	private String _marketCode;
	private String _coverageLevel;
	private Collection<MemberDues> _mDues = null;
	private Collection<DuesDiscountItem> _mDiscnt = null;
	
	private Collection <com.aaa.soa.object.models.Donation> donations ;
	
	//private Collection<>
	private Double _total = 0.00;
	private String _membershipBalance;
	private String _membershipPayments ;
	private String militaryDiscount ; 
	


	/**
	 * MembershipDues.java
	 *
	 * This file was auto-generated from WSDL
	 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
	 */

	  public MembershipDues(
	           java.lang.String _message,
	           java.lang.String _result) {
	        super(
	            _message,
	            _result);
	    }
	
	
	public MembershipDues(String zipCode, int associateCount, String coverageLevel, 
			String marketCode, Collection<MemberDues> mDues, String balance, String payments, Collection<DuesDiscountItem> discounts, Collection<Donation> donations, boolean includeDonationIntotal){
		super();
		this._zipCode = zipCode;
		this._associateCount = associateCount;
		this._coverageLevel = coverageLevel;
		this._marketCode = marketCode;
		this._mDues = mDues;
		this._mDiscnt = discounts;
		this._membershipBalance = balance;
		this._membershipPayments = payments;
		this.donations = donations;
		
		for(MemberDues md : _mDues){
			_total += Double.parseDouble(md.getTotal());
		}
		
		if(_mDiscnt != null && _mDiscnt.size() > 0){
			for(DuesDiscountItem di : _mDiscnt){
				boolean isPercent = di.isPercentageFl();
				if (!isPercent) {
					_total -= Double.parseDouble(di.getAmount());
				} else {
					BigDecimal t = BigDecimal.valueOf(_total);
					t = t.subtract(t.multiply(new BigDecimal(di.getAmount())).divide(new BigDecimal("100")));
					_total = t.doubleValue();
				}
				
			}
		}
		
		if (balance ==null){
			balance = "0.00";
		}
		
		//_total += Double.parseDouble(balance);
		BigDecimal bd = new BigDecimal(_total);
	    bd = bd.setScale(2, RoundingMode.HALF_UP);
	   _total = bd.doubleValue();
	   
	   if (includeDonationIntotal) {
	   if(donations != null && donations.size() > 0){
			for(Donation d : donations){
				_total += Double.parseDouble(d.getAmountDue().toString());
				BigDecimal bd1 = new BigDecimal(_total);
			    bd1 = bd1.setScale(2, RoundingMode.HALF_UP);
			   _total = bd1.doubleValue();
				
			}
	   }
	   }
	}
	
	public Collection<MemberDues> getMemberDues() {
		return _mDues;
	}

	public Collection<DuesDiscountItem> getDuesDiscountItem() {
		return _mDiscnt;
	}
	
	public Collection<Donation> getDonationItem() {
		return donations;
	}
		
	public String getZipCode() {
		return _zipCode;
	}

	public String getAssociateCount() {
		return String.valueOf(_associateCount);
	}

	public String getMarketCode() {
		return _marketCode;
	}

	public String getCoverageLevel() {
		return _coverageLevel;
	}

	public String getTotal() {		
		return _total.toString();
	}
	
	public String getMembershipBalance() {
		return _membershipBalance;
	}

	public String getMembershipPayments() {
		return _membershipPayments;
	}
	
	public String getMilitaryDiscount() {
		return militaryDiscount;
	}


	public void setMilitaryDiscount(String militaryDiscount) {
		this.militaryDiscount = militaryDiscount;
	}
	
	private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof MembershipDues)) return false;
        MembershipDues other = (MembershipDues) obj;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = super.equals(obj)&& 
        ((this._zipCode==null && other.getZipCode()==null) || 
                (this._zipCode!=null &&
                 this._zipCode== other.getZipCode())) &&
        ((other.getAssociateCount()==null) || 
                (this.getAssociateCount().equals(other.getAssociateCount())) &&
        ((this._marketCode==null && other.getMarketCode()==null) || 
                 (this._marketCode!=null &&
                  this._marketCode== other.getMarketCode())) &&
        ((this._coverageLevel==null && other.getCoverageLevel()==null) || 
                 (this._coverageLevel!=null &&
                  this._coverageLevel== other.getCoverageLevel())) &&
        ((this._mDues==null && getMemberDues()==null) || 
                  (this._mDues!=null &&
                   this._mDues== other.getMemberDues())) &&
        ((this._mDiscnt==null && getDuesDiscountItem()==null) || 
               (this._mDiscnt!=null &&
                this._mDiscnt== other.getDuesDiscountItem())) &&                   
        ((this._total==null && getTotal()==null) || 
                  (this._total!=null &&
                   this.getTotal()== other.getTotal())) &&
         ((this._membershipBalance==null && other.getMembershipBalance()==null) || 
                   (this._membershipBalance!=null &&
                    this._membershipBalance== other.getMembershipBalance())) &&
          ((this._membershipPayments==null && other.getMembershipPayments()==null) || 
                    (this._membershipPayments!=null &&
                     this._membershipPayments== other.getMembershipPayments()))  
                                             
         );
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = super.hashCode();
        if (getMemberDues() != null) {
            _hashCode += getMemberDues().hashCode();
        }
        if (getDuesDiscountItem() != null) {
            _hashCode += getDuesDiscountItem().hashCode();
        }        
        if (getZipCode() != null) {
            _hashCode += getZipCode().hashCode();
        }
        if (getAssociateCount() != null) {
            _hashCode += getAssociateCount().hashCode();
        }
        if (getMarketCode() != null) {
            _hashCode += getMarketCode().hashCode();
        }
        if (getCoverageLevel() != null) {
            _hashCode += getCoverageLevel().hashCode();
        }
        if (getTotal() != null) {
            _hashCode += getTotal().hashCode();
        }
        if (getMembershipBalance () != null) {
            _hashCode += getMembershipBalance().hashCode();
        }
        if (getMembershipPayments() != null) {
            _hashCode += getMembershipPayments().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(MembershipDues.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "MembershipDues"));
        
    }

    /**
     * Return type metadata object
     */
    public static org.apache.axis.description.TypeDesc getTypeDesc() {
        return typeDesc;
    }

    /**
     * Get Custom Serializer
     */
    public static org.apache.axis.encoding.Serializer getSerializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanSerializer(
            _javaType, _xmlType, typeDesc);
    }

    /**
     * Get Custom Deserializer
     */
    public static org.apache.axis.encoding.Deserializer getDeserializer(
           java.lang.String mechType, 
           java.lang.Class _javaType,  
           javax.xml.namespace.QName _xmlType) {
        return 
          new  org.apache.axis.encoding.ser.BeanDeserializer(
            _javaType, _xmlType, typeDesc);
    }

}
