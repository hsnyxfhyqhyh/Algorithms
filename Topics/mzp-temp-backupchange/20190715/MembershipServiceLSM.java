package com.aaa.soa.services;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.aaa.soa.object.MembershipServiceBP;
import com.aaa.soa.object.TestUtilBP;
import com.aaa.soa.object.models.MembershipInstallmentPaymentPlanRequest;
import com.aaa.soa.object.models.MembershipInstallmentPaymentPlanResponse;
import com.aaa.soa.object.models.MembershipSimpleOperationRequest;
import com.aaa.soa.object.models.MembershipSimpleOperationResponse;
import com.rossgroupinc.conxons.bp.BPF;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.util.RGILoggerFactory;

/**
 * Membership web service. All public methods are exposed as web methods.
 * @author Ying Hu
 *
 */

public class MembershipServiceLSM{
	
	private static Logger	log	= LogManager.getLogger(MembershipServiceLSM.class.getName(), new RGILoggerFactory());
	
	public MembershipSimpleOperationResponse GetMembership( MembershipSimpleOperationRequest getMembershipRequest){
		
		MembershipSimpleOperationResponse res = null;
				
		if (log.isDebugEnabled()){
			log.debug("**************************\n GetMembership");
		}		
		try {	
			TestUtilBP tubp = (TestUtilBP) BPF.get(User.getGenericUser(), TestUtilBP.class); 
			tubp.testEntry(); 
			//tubp.Process("07/01/2019", "07/01/2020", "0664394", "DB", false); 
			
			MembershipServiceBP bp = (MembershipServiceBP) BPF.get(User.getGenericUser(), MembershipServiceBP.class);
			return bp.GetMembership(getMembershipRequest.getMembershipNumber());
			
		} catch (Exception e) {
			log.error("", e);
		}
		
		return res;
	}
}
