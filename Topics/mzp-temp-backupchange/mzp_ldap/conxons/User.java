/*
 ********************************************************************************
 MODULE        :  User.java
 DESCRIPTION   :  User information used throughout conxons.
 
 Copyright (c) 2004 Ross Group Inc - The source code for
 this program is not published or otherwise divested of its trade secrets,
 irrespective of what has been deposited with the U.S. Copyright office.
 
 ********************************************************************************
 Modification Log:
 Date     | Developer     |Ticket#  |Description
 ---------|--------------|---------|--------------------------------------------
 04/25/04 |Moor          | N/A     |Completed javadocs
 ---------|--------------|---------|--------------------------------------------
 05/26/06 |Dwayne Gulla  |9554     |Removed the ClubProperties from being 
          |              |         |displayed in the debug message. Tom Lutz 
          |              |         |of ACNY requested the ADNWebPassword not be
          |              |         |displayed.
 ---------|--------------|---------|--------------------------------------------
 03/12/08 |Al Moor       | HP      | Made abstract to support application specific
----------|--------------|---------|--------------------------------------------
 04/20/08 |Sam Shieh     | n/a     | Added code to allow junit testing 
*******************************************************************************
 */
package com.rossgroupinc.conxons.security;

import java.lang.reflect.Constructor;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.SortedSet;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.rossgroupinc.conxons.ConXonsHttpListener;
import com.rossgroupinc.conxons.bp.PermissionMaster;
import com.rossgroupinc.conxons.dao.SimpleVO;
import com.rossgroupinc.conxons.model.DrawResultPref;
import com.rossgroupinc.conxons.model.IuserProperty;
import com.rossgroupinc.conxons.model.IuserValue;
import com.rossgroupinc.conxons.model.IusersProperties;
import com.rossgroupinc.conxons.pool.ConnectionPool;
import com.rossgroupinc.errorhandling.ObjectNotFoundException;
import com.rossgroupinc.errorhandling.ValueObjectException;
import com.rossgroupinc.util.JavaUtilities;
import com.rossgroupinc.util.RGILogger;
import com.rossgroupinc.util.SearchCondition;
import com.rossgroupinc.util.StringUtils;
import com.rossgroupinc.util.ValueHashMap;

/**
 * Simple Value Object to store user state information. Contains fields for user id, name, status, etc. It is stored in
 * the Session Object and used by login.jsp, default.jsp and others when user information is needed.
 * How to override the default com.rossgroupinc.conxons.security.ConxonsUser
 * class:
 * <li>Create a class that extends com.rossgroupinc.conxons.security.ConxonsUser</li>
 * <li>Record this name in System property "conxons.userClass".  This is most reliably
 * done in an HTTP Listener class (see com.rossgroupinc.conxons.ConxosnHttpListener)</li>
 * <li>Always use the User.getUserByID() or User.getUserByUsername() static methods</li>  
 */
public abstract class User implements java.io.Serializable, Cloneable {
	public SortedSet<DrawResultPref> userDrawResultPreferences = null;
    private static final long serialVersionUID = 1L;
	// a user can be authenticated, but not logged in when they need to select a new password.
	/**
	 * Flag to indicate user has successfully identified themselves to the system.
	 */
	public boolean				authenticated	= false;
	/**
	 * Flag to indicate whether their password has expired.
	 */
	public boolean				passwordExpired	= false;
	/**
	 * Flag to indicate the entire login process is complete.
	 */
	public boolean				loginComplete	= false;
	
	public boolean 				adAuthenticated = false; 
	/**
	 * User Name.
	 */
	public String				userName		= null;
	/**
	 * Password.
	 */
	public String				password		= null;
	/**
	 * Numeric user ID.
	 */
	public String				userID			= null;
	/**
	 * Language Code
	 */
	public String				langCd			= null;
	/**
	 * Email address.
	 */
	public String				email			= null;
	/**
	 * Middle Name.
	 */
	public String				mname			= null;
	/**
	 * First Name.
	 */
	public String				fname			= null;
	/**
	 * Last Name.
	 */
	public String				lname			= null;
	/**
	 * Return message from the login procedure.
	 */
	public String				result			= null;
	/**
	 * Database UserName
	 */
	public String				dbUserName		= null;
	/**
	 * Database Password
	 */
	public String				dbPwd			= null;
	/**
	 * Database URL
	 */
	public String				dbUrl			= null;
	/**
	 * Database Driver
	 */
	public String				dbDriver		= null;
	/**
     * Connection Pool name, used in ConnectionPool.getConnection(User).
	 */
	public String				connectionPool	= null;
	/**
     * Business Process Suffix is used in deterimining which business rule
     * or report to run.  If "007" is the suffix, "myreport.rpt" becomes 
     * "myreport_007.rpt" and "SomeRule.xml" becomes "SomeRule_007.xml".
	 */
	public String				bpSuffix		= null;
	/**
	 * Web user.
	 * 
	 * @deprecated
	 */
	public String				webUser			= null;
	/**
	 * Web password.
	 * 
	 * @deprecated
	 */
	public String				webPassword		= null;

	/**
	 * Groups the user belongs to.
	 */
	public java.util.ArrayList<String>	groups			= new java.util.ArrayList<String>();

	/**
	 * Functions available to the user.
	 */
	public java.util.ArrayList	functions		= new java.util.ArrayList();

	public java.util.SortedSet<Object>	userProperties	= null;

	public HashMap<String,String> iuserPropertyMap = new HashMap<String,String>();
	
	protected static User genericUser = null;
	
	private static Logger log = RGILogger.getLogger(User.class);
	
	/**
     * Preferences to be used for draw results
     * @return
     * @throws SQLException
     */
    public SortedSet<DrawResultPref> getDrawResultUserPreferences() throws SQLException{
    	if (userDrawResultPreferences==null){
    		ArrayList<SearchCondition> criteria = new ArrayList<SearchCondition>();
    		criteria.add(new SearchCondition(DrawResultPref.USER_ID,SearchCondition.EQ,this.userID));
    		userDrawResultPreferences = DrawResultPref.getDrawResultPrefList(this, criteria, null);
    	}
    	return userDrawResultPreferences;
    }
    
    public void setDrawResultUserPreferences(SortedSet<DrawResultPref> inPrefs) throws SQLException{
    		userDrawResultPreferences = inPrefs;
    }    
    
    
    /**
     * Sets a user property.  If it doesn't already exist, it will create and
     * save it to the database
     */
    public void setUserProperty(String propertyName, String propertyValue){
    	try{

        	//find the property, if not create one
	    	IuserProperty property = findProperty(propertyName);
	    	IuserValue value = findValue(propertyName);
	    	boolean newPropertyAdded = false;
	    	
	    	if(property!=null && value!=null)
	    	{
	    		if(!(value.getPropertyValue().equals(propertyValue))){
	    			value.setPropertyValue(propertyValue);
	    		}
	    	}
	    	
	    	if(property == null){
	    		property = new IuserProperty(this, (BigDecimal)null, false);
	    		property.setPropertyName(propertyName);
	    		//userPropertyKy should be set in the initialization
	    				//property.setUserPropertyKy(new BigDecimal(this.));
	    		newPropertyAdded = true;
	    	}//end if
	    	if(value == null){
	    		value = new IuserValue(this, (BigDecimal)null, false);
	    		value.setUserId(this.userID);
	    		//userValueKy should be set in the initialization
	    		value.setUserPropertyKy(property.getUserPropertyKy());
	    	}
	    	value.setPropertyValue(propertyValue);
	    	property.save();
	    	
	    	//if we've added a new property, update the property list
	    	if(newPropertyAdded){
				this.setHashMap();
	    	}
	    		
	    	//end if
    	}catch (Exception e) {
			throw new RuntimeException("Error in setUserProperty() " + 
					e.getMessage());
		}//end try/catch
    }//setUserProperty    
    
    /**
     * Sets the property hashMap for the userID parameter.
     * 
     * @param usr
     * @throws SQLException
     * @throws ValueObjectException
     */
    public void setHashMap()throws SQLException, ValueObjectException{
    	Connection conn = null;
    	try{
    		conn = ConnectionPool.getConnection(this);
	    	SimpleVO propertyVO = new SimpleVO();
	    	propertyVO.setCommand("select v.property_value, p.property_name from cx_iuser_property p, cx_iuser_value v where v.user_property_ky = p.user_property_ky and user_id=?");
	    	propertyVO.setBigDecimal(1, new BigDecimal(this.userID));
	    	propertyVO.execute(conn);
	    	
	    	while(propertyVO.next()){
	    		iuserPropertyMap.put(propertyVO.getColumn("PROPERTY_NAME"), propertyVO.getColumn("PROPERTY_VALUE"));
	    	}
    	}
    	finally{
    		if (conn != null) {
    			try {conn.close();} catch(Exception ignore) { }
    			conn = null;
    		}
    	}
    }    
    
    /**
     * Finds the property with the given name
     * @param property
     * @return null if not found
     * @throws SQLException
     */
    protected IuserProperty findProperty(String propertyName) throws SQLException{
    	IuserProperty iuserProp = null;
		try{
			iuserProp = new IuserProperty(this, propertyName);
		} catch (ObjectNotFoundException e){
			log.error("No propertyName='" + propertyName + "' found");
		}
    	return iuserProp;
    }    
    
    
	protected IuserValue findValue(String propertyName) throws SQLException {
		IuserProperty iuserProp = findProperty(propertyName);
		IuserValue iuserVal = null;
		try{
			iuserVal = new IuserValue(this, iuserProp.getUserPropertyKy(), new BigDecimal(this.userID));
		} catch (ObjectNotFoundException e){
			log.error("No value found for propertyName=" + propertyName);
		}
		return iuserVal;
	}
	
    /**
     * Returns the value of the given property
     * @param property
     * @return null if the property doesn't exist
     */
   public String getUserPropertyValue(String propertyName){
	   return iuserPropertyMap.get(propertyName);
    }//end getProperty	
	
	/**
	 * Get a user by their username.  
	 * @param userName
	 * @return Some concrete implementation of this abstract class.
	 */
    public static User getUserByUserName(String userName) {
    	User u = getUser();
    	u.getByUserName(userName);
    	return u;
    }
    
	/**
	 * Get user with user ID "1".  
	 * @return Some concrete implementation of this abstract class.
	 */
	public static User getGenericUser(){
		if (genericUser == null || genericUser.bpSuffix == null) {
			genericUser = getUserByUserID("1");
		}
		return genericUser;
	}
	
	/**
	 * Call this in your HTTPListener class so the next call
	 * will pick up the customizations for your project.
	 */
	public static void clearGenericUser() {
		genericUser = null;
	}
	
	/**
	 * Get empty user object.  
	 * @return Some concrete implementation of this abstract class.
	 */
	public static User getInstance(){
		return getUser();
	}
	
	/**
	 * Get a user by their cx_iusers user_id.  
	 * @param inUserID
	 * @return Some concrete implementation of this abstract class.
	 */
	public static User getUserByUserID(String inUserID){
    	User u = getUser();
		u.getByID(inUserID);
    	return u;
	}
	/**
	 * Instantiates the appropriate class.
	 * @return
	 */
    private static User getUser() {
    	User u = null;
    	try {
	    	if (userClass == null) resetClass();
	    	Class typenoarg[] = new Class[0];
	        Object obj[] = new Object[0];
	        Constructor ct = userClass.getConstructor(typenoarg);
	        u = (User) ct.newInstance(obj);
    	}
    	catch (Exception e) {
    		e.printStackTrace(System.err);
    		u = new ConxonsUser();
    	}
    	return u;
    }
    private static Class userClass = null;
    
    public static void resetClass() {
    	userClass = getUserClass();
    }
    /**
     * Get the class that is the "user" class for this application.  
     * @return
     */
    private static Class getUserClass() {
    	Class c = null;
    	String myClass = System.getProperty("conxons.userClass");
    	if (myClass == null) {
    		try{
    			myClass = ConXonsHttpListener.servletContext.getInitParameter("userClass");
    		}catch(Exception e){
    			myClass = "com.rossgroupinc.conxons.security.ConxonsUser";
    		}
    	}
    	if (myClass == null) {
    		c = com.rossgroupinc.conxons.security.ConxonsUser.class;
    	}
    	else {
    		try {
    	    	c = Class.forName(myClass);
    		}
    		catch (Exception e) {
        		c = com.rossgroupinc.conxons.security.ConxonsUser.class;
    		}
    	}
    	return c;
    }
    /**
     * Loads properties from database, based on userName
     * @param userName
     */
    protected abstract void getByUserName(String userName);
    /**
     * Loads properties from database, based on userID
     * @param userName
     */
    protected abstract void getByID(String inUserID);
    
    public static void getGroups(Connection conn, User usr) throws SQLException{
    	if (conn == null || conn.isClosed() || (usr.getGroups() != null && usr.getGroups().size() > 0)) return;
        // reset groups
        com.rossgroupinc.conxons.dao.SimpleVO groups = new com.rossgroupinc.conxons.dao.SimpleVO();
        groups.setCommand("select group_code from cx_groups g left join cx_group_to_user gu on gu.group_id= g.GROUP_ID where user_id = ?");
        groups.setString(1, usr.userID);
        groups.execute(conn);
        groups.beforeFirst();
        ArrayList groupList = new ArrayList();
        while (groups.next()) {
            groupList.add(groups.getString(1));
        }
        usr.setGroups(groupList);

    }

	/**
	 * Establish the functions list.
	 * 
	 * @param functionList
	 *            List of functions the user has access to.
	 */
	public void setFunctions(java.util.ArrayList functionList){
		functions = functionList;
	}

	/**
	 * Get the function list.
	 * @return java.util.ArrayList
	 */
	public java.util.ArrayList getFunctions(){
		return functions;
	}

	/**
     * Is this user a super user?
     * @return
     */
    public boolean isSuperUser() {
        return groups.contains("SUPER_GROUP");
    }
    /**
	 * Does the user have access to the specified function?
	 * 
	 * @param functionName
	 *            Function to test. Case-sensitive.
	 * @return boolean
	 */
	public boolean inFunction(String functionName){
		return groups.contains("SUPER_GROUP") || functions.contains(functionName);
	}

	/**
	 * Establish the group access list.
	 * 
	 * @param groupList
	 *            List of groups the user has access to.
	 */
	public void setGroups(java.util.ArrayList<String> groupList){
		groups = groupList;
	}

	/**
	 * Get the group list.
	 * @return java.util.ArrayList
	 */
	public java.util.ArrayList<String> getGroups(){
		return groups;
	}

	/**
	 * Does the user have access to the specified group?
	 * 
	 * @param groupName
	 *            Group to test. Case-sensitive.
	 * @return boolean
	 */
	public boolean inGroup(String groupName){
		return isSuperUser() || groups.contains(groupName);
	}

	/**
	 * Does this user have permissions for the given PermissionSet?
	 * @param permissionSet
	 * @return boolean
	 */
	public boolean hasPermission(String permissionSet){
		return isSuperUser() || PermissionMaster.instance().hasPermission(this, permissionSet);
	}

	/**
	 * Get a String attribute.
	 * 
	 * @param attributeName
	 *            The String attribute to get. Case-sensitive.
	 * @return The value, or null if not found.
	 */
	public String getStringAttribute(String attributeName){
		if (_attributes.containsKey(attributeName)){
			Object obj = _attributes.get(attributeName);
			if (obj instanceof String){
				return (String) obj;
			}
		}
		return null;
	}


	/**
	 * Get an attribute.
	 * 
	 * @param attributeName
	 *            The attribute to get. Case-sensitive.
	 * @return The value, or null if not found.
	 */
	public Object getAttribute(String attributeName){
		if (_attributes.containsKey(attributeName)){
			return _attributes.get(attributeName);
		}
		return null;
	}
	
	/**
	 * Get an attribute as a BigDecimal, requires that the object was
	 * originally stored as a BigDecimal.
	 * @param attributeName
	 * @return The value, or null if not found.
	 */
	public BigDecimal getAttributeAsBigDecimal(String attributeName){
		Object obj = getAttribute(attributeName);
		if (obj != null){
			if(obj instanceof String){
				return new BigDecimal((String)obj);
			}
			return (BigDecimal)obj;
		}
		return null;
	}
	
	/**
	 * Get an attribute as a Timestamp, requires that the object was
	 * originally stored as a Timestamp.
	 * @param attributeName
	 * @return The value, or null if not found.
	 */
	public Timestamp getAttributeAsTimestamp(String attributeName){
		Object obj = getAttribute(attributeName);
		if (obj != null){
			return (Timestamp)obj;
		}
		return null;
	}
	
	/**
	 * Get an attribute as a boolean, requires that the object was
	 * originally stored as a boolean.
	 * @param attributeName
	 * @param defaultValue
	 * @return The value, or the defaultValue if not found.
	 */
	public boolean getAttributeAsBoolean(String attributeName, boolean defaultValue){
		Object obj = getAttribute(attributeName);
		if (obj != null){
			return (Boolean)obj;
		}
		return defaultValue;
	}
	
	/**
	 * Get an attribute as a boolean, requires that the object was
	 * originally stored as a boolean.
	 * @param attributeName
	 * @param defaultValue
	 * @return The value, or the defaultValue if not found.
	 */
	public String getAttributeAsString(String attributeName){
		Object obj = getAttribute(attributeName);
		if (obj != null){
			return (String)obj;
		}
		return null;
	}
	

	/**
	 * 
	 * Set an arbitrary attribute.
	 * 
	 * @param attributeName
	 *            The name of the attribute. Case-sensitive.
	 * @param attribute
	 *            The object. Should be serializable. Must conform to restrictions of HashMap objects.
	 */
	public void setAttribute(String attributeName, Object attribute){
		if (attributeName != null){
			if (attribute != null && !(attribute instanceof String || attribute instanceof BigDecimal || attribute instanceof Date)){
				Object c = JavaUtilities.cloneSerializable(attribute);
				if (c == null){
					try{
						throw new Exception(attributeName + " is not serializable!");
					}
					catch (Exception e){
						e.printStackTrace(System.err);
					}
				}
			}
			if (attribute == null){
				_attributes.remove(attributeName);
			}
			else{
				_attributes.put(attributeName, attribute);
			}
		}
	}

	protected java.util.HashMap	_attributes	= new java.util.HashMap();

	@Override
	public Object clone(){
		return com.rossgroupinc.util.JavaUtilities.cloneSerializable(this);
	}


	public String getClubCode(){
		return getStringAttribute("ClubCode");
	}


	/**
	 * Establish the userProperties list.
	 * 
	 * @param userList
	 *            List of functions the user has access to.
	 */
	public void setUserProperties(java.util.SortedSet userList){
		userProperties = userList;
	}

	/**
	 * Get the iUserProperties list
	 * @return java.util.SortedSet
	 */
	public java.util.SortedSet getUserProperties(){
		return userProperties;
	}

    /**
     * Get a ValueHashMap attribute.
     * 
     * @param attributeName
     *            The String attribute to get. Case-sensitive.
     * @return The value, or null if not found.
     */
    public ValueHashMap getValueHashMapAttribute(String attributeName) {
        if (_attributes.containsKey(attributeName)) {
            Object obj = _attributes.get(attributeName);
            if (obj instanceof ValueHashMap) {
                return (ValueHashMap) obj;
            }
        }
        return null;
    }
	
    /**
     * Validates the credentials and returns the matching user object.  loginComplete will be true if everything
     * validated successfully. result will contain the reason if it was not successful.
     * @param username
     * @param password
     * @return the user object for the given user
     * @throws SQLException
     * @throws EncryptionException
     */
    public static User login(String username, String password) throws SQLException, EncryptionException {
		User user = getGenericUser();
		Connection conn = null;
		CallableStatement chkLogin;
		String enPwd = ConxonsSecurity.instance().encrypt(password);
		try{
		conn = ConnectionPool.getConnection(getGenericUser());
		// Get the user authority and userid from the database.
		String proc = "{call cx_sec_chklogin (?,?,?,?,?,?,?,?,?)}";
		chkLogin = conn.prepareCall(proc);
		chkLogin.setString(1, username);
		chkLogin.setString(2, enPwd); // passwords in cx_iusers are encrypted
		chkLogin.registerOutParameter(3, Types.VARCHAR); // valid_yn
		chkLogin.registerOutParameter(4, Types.VARCHAR); // account_disabled_yn
		chkLogin.registerOutParameter(5, Types.VARCHAR); // webpwd_expired_yn
		chkLogin.registerOutParameter(6, Types.VARCHAR); // numeric user_id for _user.userName/_password
		chkLogin.registerOutParameter(7, Types.VARCHAR); // email address
		chkLogin.registerOutParameter(8, Types.VARCHAR); // language code
		chkLogin.registerOutParameter(9, Types.VARCHAR); // result message

		chkLogin.execute();

		user.userName = username;
		user.password = password;
		user.authenticated = "Y".equals(chkLogin.getString(3));
		user.passwordExpired = "Y".equals(chkLogin.getString(5));
		user.userID = chkLogin.getString(6);
		user.email = chkLogin.getString(7);
		user.langCd = StringUtils.nvl(chkLogin.getString(8), "EN");
		if (user.langCd == "")
			user.langCd = "EN";
		user.result = chkLogin.getString(9);

		user.loginComplete = ("SUCCESS".equals(user.result) && user.authenticated);
		if (user.loginComplete) {
			String qry = null;
			PreparedStatement ps = null;
			ResultSet rs = null;
			// Set groups
			try {
				qry = "select GROUP_CODE from CX_GROUPS, CX_GROUP_TO_USER where USER_ID = ? and CX_GROUPS.group_id = CX_GROUP_TO_USER.group_id";
				ps = conn.prepareStatement(qry);
				ps.setString(1, user.userID);
				ArrayList groupList = new ArrayList();
				rs = ps.executeQuery();
				while (rs.next()) {
					String grpCode = rs.getString("GROUP_CODE");
					groupList.add(grpCode);
				}
				rs.close();
				rs = null;
				if (ps != null) {
					ps.close();
					ps = null;
				}

				qry = "select * from CX_IUSERS where USER_ID = ?";
				ps = conn.prepareStatement(qry);
				ps.setString(1, user.userID);
				rs = ps.executeQuery();
				while (rs.next()) {
					user.fname = rs.getString("FNAME");
					user.lname = rs.getString("LNAME");
					user.mname = rs.getString("MNAME");
				}
				rs.close();
				rs = null;
				if (ps != null) {
					ps.close();
					ps = null;
				}

				user.setGroups(groupList);

				//adding user property
				user.setUserProperties(IusersProperties.getUserPropertiesList(user));

			}
			finally {
				if (rs != null)
					try {
						rs.close();
						rs = null;
					}
					catch (Exception csqle) {
					}
				if (ps != null)
					try {
						ps.close();
						ps = null;
					}
					catch (Exception csqle) {
					}
			}
		}
		}
		finally {
			if (conn != null)
				try {
					conn.close();
				}
				catch (Exception e) {
				}
		}
		return user;
	}
    
}
