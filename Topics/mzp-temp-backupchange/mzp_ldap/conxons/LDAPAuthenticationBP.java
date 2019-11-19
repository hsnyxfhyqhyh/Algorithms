/*
 ********************************************************************************
 * MODULE        :  LDAPAuthenticationBP.java
 * DESCRIPTION   :  to test using ldap authentication
 * 
 * Copyright (c) 2009 Ross Group Inc - The source code for
 * this program is not published or otherwise divested of its trade secrets,
 * irrespective of what has been deposited with the U.S. Copyright office.
 * 
 * ********************************************************************************
 * Modification Log:
 * Date     | Developer     |Ticket#  |Description
 * ---------| --------------|---------|------------------------------------------
 *          |               |         |
 *********************************************************************************
 */
package com.rossgroupinc.conxons.bp;

import java.util.Hashtable;

import javax.naming.AuthenticationException;
import javax.naming.Context;
import javax.naming.NamingException;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dom4j.Document;

import com.rossgroupinc.conxons.bp.BusinessProcess;
import com.rossgroupinc.conxons.security.User;
import com.rossgroupinc.util.RGILoggerFactory;
/**
 * Business process wrapper for LDAP Authentication. 
 * @author alan.moor
 *
 */
public class LDAPAuthenticationBP extends BusinessProcess {
	private static final long	serialVersionUID	= 1L;
	private static Logger		log					= LogManager.getLogger(LDAPAuthenticationBP.class.getName(), new RGILoggerFactory());
	
	private static final LDAPAuthenticationBP theInstance = new LDAPAuthenticationBP(User.getGenericUser());  
	protected static final String	CONFIG_FILE = "memberz/soa/MembershipService.xml";
	protected static Document configuration;
	
	private static final String LDAP_SERVER_URL = "LDAP://ldap.AAACorp.com/";
	private static final String LDAP_SECURITY_AUTHENICATION = "simple"; 
	private static final String LDAP_INITIAL_CONTEXT_FACTORY = "com.sun.jndi.ldap.LdapCtxFactory";
	private static final String LDAP_SECURITY_PRINCIPLE_PREFIX = "aaacorp\\"; 
	private static final String LDAP_SECURITY_PRINCIPLE_SUFFIX = ""; 
	
	public LDAPAuthenticationBP(User user) {
		
		super();
		this.user = user;

		log = LogManager.getLogger(this.getClass().getName(), new RGILoggerFactory());
		
		configuration = getConfiguration(CONFIG_FILE, user);		
	}
	
	public static LDAPAuthenticationBP getInstance()
	{
		return theInstance;
	}
	
	
	public boolean authenticate(String userName, String pwd) {
		
		boolean result = false; 
        
        
        String dn = LDAP_SECURITY_PRINCIPLE_PREFIX + userName;
      //Overwrite password for testing. 
        //pwd = "******";
        
        Hashtable authEnv = new Hashtable(11);

        authEnv.put(Context.INITIAL_CONTEXT_FACTORY, LDAP_INITIAL_CONTEXT_FACTORY);
		authEnv.put(Context.PROVIDER_URL, LDAP_SERVER_URL);
		authEnv.put(Context.SECURITY_AUTHENTICATION, LDAP_SECURITY_AUTHENICATION);
		authEnv.put(Context.SECURITY_PRINCIPAL, dn);
		authEnv.put(Context.SECURITY_CREDENTIALS, pwd);

        try {
            DirContext authContext = new InitialDirContext(authEnv);
            result = true; 
            System.out.println("Authentication Success!");
        } catch (AuthenticationException authEx) {
            System.out.println("Authentication failed!");
        } catch (NamingException namEx) {
            System.out.println("Something went wrong!");
            namEx.printStackTrace();
        }
        return result;
    }

	
}