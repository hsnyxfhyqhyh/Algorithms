/**
 * MembershipComponentDues.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis 1.4 Apr 22, 2006 (06:55:48 PDT) WSDL2Java emitter.
 */

package com.aaa.soa.object.models;

public class MembershipComponentDues  implements java.io.Serializable {
    private com.aaa.soa.object.models.MemberComponentDues[] memberComponentDues;

    private java.math.BigDecimal subTotalAmountDue;

    private java.math.BigDecimal unappliedAmount;

    private java.math.BigDecimal pendingCreditAmount;

    private java.math.BigDecimal totalAmountDue;
    
    
    //this value is going to reflect the Total Cost value on the mzp payment screen, top section. 
    private String totalCost; 

    public MembershipComponentDues() {
    }

    public MembershipComponentDues(
           com.aaa.soa.object.models.MemberComponentDues[] memberComponentDues,
           java.math.BigDecimal subTotalAmountDue,
           java.math.BigDecimal unappliedAmount,
           java.math.BigDecimal pendingCreditAmount,
           java.math.BigDecimal totalAmountDue) {
           this.memberComponentDues = memberComponentDues;
           this.subTotalAmountDue = subTotalAmountDue;
           this.unappliedAmount = unappliedAmount;
           this.pendingCreditAmount = pendingCreditAmount;
           this.totalAmountDue = totalAmountDue;
    }


    /**
     * Gets the memberComponentDues value for this MembershipComponentDues.
     * 
     * @return memberComponentDues
     */
    public com.aaa.soa.object.models.MemberComponentDues[] getMemberComponentDues() {
        return memberComponentDues;
    }


    /**
     * Sets the memberComponentDues value for this MembershipComponentDues.
     * 
     * @param memberComponentDues
     */
    public void setMemberComponentDues(com.aaa.soa.object.models.MemberComponentDues[] memberComponentDues) {
        this.memberComponentDues = memberComponentDues;
    }

    public com.aaa.soa.object.models.MemberComponentDues getMemberComponentDues(int i) {
        return this.memberComponentDues[i];
    }

    public void setMemberComponentDues(int i, com.aaa.soa.object.models.MemberComponentDues _value) {
        this.memberComponentDues[i] = _value;
    }


    /**
     * Gets the subTotalAmountDue value for this MembershipComponentDues.
     * 
     * @return subTotalAmountDue
     */
    public java.math.BigDecimal getSubTotalAmountDue() {
        return subTotalAmountDue;
    }


    /**
     * Sets the subTotalAmountDue value for this MembershipComponentDues.
     * 
     * @param subTotalAmountDue
     */
    public void setSubTotalAmountDue(java.math.BigDecimal subTotalAmountDue) {
        this.subTotalAmountDue = subTotalAmountDue;
    }

    public String getTotalCost() {
		return totalCost;
	}


	public void setTotalCost(String totalCost) {
		this.totalCost = totalCost;
	}
	
	

    /**
     * Gets the unappliedAmount value for this MembershipComponentDues.
     * 
     * @return unappliedAmount
     */
    public java.math.BigDecimal getUnappliedAmount() {
        return unappliedAmount;
    }


    /**
     * Sets the unappliedAmount value for this MembershipComponentDues.
     * 
     * @param unappliedAmount
     */
    public void setUnappliedAmount(java.math.BigDecimal unappliedAmount) {
        this.unappliedAmount = unappliedAmount;
    }


    /**
     * Gets the pendingCreditAmount value for this MembershipComponentDues.
     * 
     * @return pendingCreditAmount
     */
    public java.math.BigDecimal getPendingCreditAmount() {
        return pendingCreditAmount;
    }


    /**
     * Sets the pendingCreditAmount value for this MembershipComponentDues.
     * 
     * @param pendingCreditAmount
     */
    public void setPendingCreditAmount(java.math.BigDecimal pendingCreditAmount) {
        this.pendingCreditAmount = pendingCreditAmount;
    }


    /**
     * Gets the totalAmountDue value for this MembershipComponentDues.
     * 
     * @return totalAmountDue
     */
    public java.math.BigDecimal getTotalAmountDue() {
        return totalAmountDue;
    }


    /**
     * Sets the totalAmountDue value for this MembershipComponentDues.
     * 
     * @param totalAmountDue
     */
    public void setTotalAmountDue(java.math.BigDecimal totalAmountDue) {
        this.totalAmountDue = totalAmountDue;
    }

    private java.lang.Object __equalsCalc = null;
    public synchronized boolean equals(java.lang.Object obj) {
        if (!(obj instanceof MembershipComponentDues)) return false;
        MembershipComponentDues other = (MembershipComponentDues) obj;
        if (obj == null) return false;
        if (this == obj) return true;
        if (__equalsCalc != null) {
            return (__equalsCalc == obj);
        }
        __equalsCalc = obj;
        boolean _equals;
        _equals = true && 
            ((this.memberComponentDues==null && other.getMemberComponentDues()==null) || 
             (this.memberComponentDues!=null &&
              java.util.Arrays.equals(this.memberComponentDues, other.getMemberComponentDues()))) &&
            ((this.subTotalAmountDue==null && other.getSubTotalAmountDue()==null) || 
             (this.subTotalAmountDue!=null &&
              this.subTotalAmountDue.equals(other.getSubTotalAmountDue()))) &&
            ((this.unappliedAmount==null && other.getUnappliedAmount()==null) || 
             (this.unappliedAmount!=null &&
              this.unappliedAmount.equals(other.getUnappliedAmount()))) &&
            ((this.pendingCreditAmount==null && other.getPendingCreditAmount()==null) || 
             (this.pendingCreditAmount!=null &&
              this.pendingCreditAmount.equals(other.getPendingCreditAmount()))) &&
            ((this.totalAmountDue==null && other.getTotalAmountDue()==null) || 
             (this.totalAmountDue!=null &&
              this.totalAmountDue.equals(other.getTotalAmountDue())));
        __equalsCalc = null;
        return _equals;
    }

    private boolean __hashCodeCalc = false;
    public synchronized int hashCode() {
        if (__hashCodeCalc) {
            return 0;
        }
        __hashCodeCalc = true;
        int _hashCode = 1;
        if (getMemberComponentDues() != null) {
            for (int i=0;
                 i<java.lang.reflect.Array.getLength(getMemberComponentDues());
                 i++) {
                java.lang.Object obj = java.lang.reflect.Array.get(getMemberComponentDues(), i);
                if (obj != null &&
                    !obj.getClass().isArray()) {
                    _hashCode += obj.hashCode();
                }
            }
        }
        if (getSubTotalAmountDue() != null) {
            _hashCode += getSubTotalAmountDue().hashCode();
        }
        if (getUnappliedAmount() != null) {
            _hashCode += getUnappliedAmount().hashCode();
        }
        if (getPendingCreditAmount() != null) {
            _hashCode += getPendingCreditAmount().hashCode();
        }
        if (getTotalAmountDue() != null) {
            _hashCode += getTotalAmountDue().hashCode();
        }
        __hashCodeCalc = false;
        return _hashCode;
    }

    // Type metadata
    private static org.apache.axis.description.TypeDesc typeDesc =
        new org.apache.axis.description.TypeDesc(MembershipComponentDues.class, true);

    static {
        typeDesc.setXmlType(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "MembershipComponentDues"));
        org.apache.axis.description.ElementDesc elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("memberComponentDues");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "MemberComponentDues"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "MemberComponentDues"));
        elemField.setNillable(false);
        elemField.setMaxOccursUnbounded(true);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("subTotalAmountDue");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "SubTotalAmountDue"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("unappliedAmount");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "UnappliedAmount"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("pendingCreditAmount");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "PendingCreditAmount"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("totalAmountDue");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "TotalAmountDue"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "decimal"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
        
        elemField = new org.apache.axis.description.ElementDesc();
        elemField.setFieldName("totalCost");
        elemField.setXmlName(new javax.xml.namespace.QName("http://aaa.midatlantic.membership.services", "TotalCost"));
        elemField.setXmlType(new javax.xml.namespace.QName("http://www.w3.org/2001/XMLSchema", "string"));
        elemField.setNillable(false);
        typeDesc.addFieldDesc(elemField);
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
