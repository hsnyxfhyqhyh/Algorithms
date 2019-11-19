/*
 * ******************************************************************************* 
 * MODULE : LoginBean.java 
 * DESCRIPTION : Helper Bean for login.jsp and passwordadmin.jsp. 
 * Copyright (c) 2003 Ross Group
 * Inc - The source code for this program is not published or otherwise divested of its 
 * trade secrets, irrespective of what has been deposited with the U.S. Copyright office.
 * ******************************************************************************* 
 * Modification Log: Date | Developer |Ticket# | Description ---------|
 * --------------|---------|------------------------------------------ 
 * *******************************************************************************
 */
package com.rossgroupinc.conxons.security;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Calendar;

import javax.servlet.http.Cookie;

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import com.rossgroupinc.conxons.bp.LDAPAuthenticationBP;

import com.rossgroupinc.conxons.PageBaseBean;
import com.rossgroupinc.conxons.model.Iusers;
import com.rossgroupinc.conxons.model.IusersProperties;
import com.rossgroupinc.conxons.model.SecuritySettings;
import com.rossgroupinc.conxons.pool.ConnectionPool;
import com.rossgroupinc.conxons.rule.Validator;
import com.rossgroupinc.conxons.util.ConxonsUtils;
import com.rossgroupinc.errorhandling.StackTraceUtil;
import com.rossgroupinc.resource.Messages;
import com.rossgroupinc.util.DateUtilities;
import com.rossgroupinc.util.RGILoggerFactory;
import com.rossgroupinc.util.StringUtils;

/**
 * JavaBean to be used with login.jsp.
 * It contains processing for authentication,
 * password aging, username and password pattern validation, etc.
 *
 * <p><font size=2><b>Copyright (c) 2003 Ross Group Inc</b> - The source code for
 * this program is not published or otherwise divested of its trade secrets,
 * irrespective of what has been deposited with the U.S. Copyright office.
 * </font></p>
 */
public class LoginBean extends PageBaseBean {
	private String			_pageLocation;
	private boolean			_logout		= false;
	private ConxonsSecurity	cs			= ConxonsSecurity.instance();
	private String			_langCd		= null;

	private User			localUser	= User.getGenericUser();		// just in case a getter is called before it is populated.
	private Logger          pciLog      = LogManager.getLogger("pci.login",new RGILoggerFactory());

	/**
	 * Performs those actions to determine the state of the login.jsp and validate
	 * the login.
	 * <p>
	 * If the Database connection has not been made, the connection is made.
	 * <p>
	 * It checks to see if  cookies have been set with the users EMAIL and password.
	 * If these have been set, then it attempts to get the EMAIL and password from
	 * that; and perform the authentication.  If not, it will set up cookies with
	 * these values.  (This process should be encrypted at a later date).
	 * <p>
	 * The PAGELOCATION parameter is determined depending upon whether the TSID
	 * has been set.  If it has been set, then it is used to go to the corect
	 * page upon login.... (This can be used to set up a default entry page for
	 * each individual user.  Not implemented as of yet.).
	 * <p>
	 * If the username and password validate in the database, then the resulting
	 * USER_ID is set as a session object USER_ID.
	 * @throws SQLException
	 * @throws Exception
	 */

	public void process() throws SQLException, Exception{
		debugRequest();
		
		Validator val = this.getValidator("/conxons/security/Login.xml");
		
		if (_logout) return;
		log.debug("in process");

		localUser.connectionPool = "conxons";
		String TSID = req.getParameter("TSID");
		String TSEL = req.getParameter("TSEL");
		if (TSID == null || TSID.equals(""))
			_pageLocation = (String)val.getDefault("StartPage");
		else
			_pageLocation = val.getDefault("StartPage") +"?TSID=" + TSID + "&TSEL=" + TSEL;

		log.debug("user.username = " + localUser.userName);
		log.debug("user.authenticated = " + String.valueOf(localUser.authenticated));
		log.debug("user.login complete = " + String.valueOf(localUser.loginComplete));

		Cookie[] cookies = null;
		String canCookie = (String) sc.getAttribute("CanSavePassword");

		//JZ Added 2/1/06 so that we can know the "timezone" via the offset of the user logging in
		//This has to be negated because the method returns the opposite offset (ie 300 minute offset when it's -300)
		if (!("".equals(getReqParam("CLIENT_TIME_OFFSET")))){
			String clientTimeOffset = getReqParam("CLIENT_TIME_OFFSET");
			if (clientTimeOffset.contains("-")){
				clientTimeOffset = clientTimeOffset.substring(1);
			}
			else{
				clientTimeOffset = "-" + clientTimeOffset;
			}
			req.getSession().setAttribute("CLIENT_TIME_OFFSET", clientTimeOffset);
		}

		// If we are just establishing a new password, the user is already actually
		// logged on.  Hand off to updatePassword()
		if (localUser.authenticated && localUser.passwordExpired){
			String newPwd = req.getParameter("NEW_PASSWORD");
			String confPwd = req.getParameter("VALIDATE_PASSWORD");
			if (confPwd == null || !newPwd.equals(confPwd)){
				localUser.result = Messages.getString("CONFIRM_PASSWORD_NOT_MATCH");
				//"Password and confirmation do not match<BR>Please try again";
				return;
			}
			localUser.result = updatePassword(newPwd);
			if ("SUCCESS".equals(localUser.result)){
				localUser.passwordExpired = false;
				localUser.loginComplete = true;
				req.getSession().setAttribute("User", localUser);
				ArrayList<User> al = new ArrayList<User>();
				al.add(localUser);
				req.getSession().setAttribute("LoginComplete", al);
				pciLog.warn("3: User "+localUser.userName+" successfully reset their password.");
			}
			return;
		}

		// If username and password are not valid, then check for a cookie.
		// This whole cookie thing needs to be encrypted, also....
		// Check out the Cookie API's....
		cookies = req.getCookies();
		if (!isUSERNAMEValid() && (canCookie == null || canCookie.equalsIgnoreCase("Y"))){
			log.debug(" the username is NOT valid.  So lets check the cookies");
			if (cookies != null){
				String name = null;
				for (int i = 0; i < cookies.length; i++){
					name = cookies[i].getName();
					if (name != null) // && (name.equalsIgnoreCase(cookieVar))
					{
						if (name.equalsIgnoreCase("username")){
							localUser.userName = cookies[i].getValue();
						}
						if (name.equalsIgnoreCase("password")){
							localUser.password = cookies[i].getValue();
						}
					}
				}
			}
		}

		try{
			if (_logout){
				//    do nothing
			}
			else if (this.isUSERNAMEValid() && !this.isPASSWORDValid()){
				log.debug("password not present");
				localUser.authenticated = false;
				localUser.result = Messages.getString("PASSWORD_NEED");//"Password is required";
			}
			else if (isUSERNAMEValid()){
				log.debug("verifying login");

				if (!localUser.adAuthenticated) {
					verifyAdLogin();
					if (localUser.adAuthenticated) {
						return;	
					}
					
				} else {
					String mzpId = req.getParameter("mzpIds"); 
					if (mzpId !=null && !mzpId.equalsIgnoreCase("")){
						initializeMzpUser(mzpId);
					}
				}
				
				

				log.debug("verification completed");

				if (localUser.result != null && localUser.result.equals("SUCCESS") && localUser.authenticated){
					localUser.loginComplete = true;
					pciLog.warn("1: User "+localUser.userName+" successfully logged in.");
				}
			}
			else{
				log.debug("USERNAME not set");
			}

			if (localUser.loginComplete){
				finishLogin();
				// Login is complete, signal any Listeners that are waiting for
				// session attribute added

				//adding user property
				try{
					localUser.setUserProperties(IusersProperties.getUserPropertiesList(localUser));
				}
				catch (SQLException se){
					log.debug("Caught SQLException in LoginBean.setUserObject");
					log.error(StackTraceUtil.getStackTrace(se));
				}
				// Login is complete, signal any Listeners that are waiting for session attribute added
				ArrayList<User> al = new ArrayList<User>();
				al.add(localUser);
				//JZ 11/13/2007 Removed as this causes the session to not be serializable an is never used
				//al.add(cookies);
				req.getSession().setAttribute("LoginComplete", al);
			}
			log.debug("Done in loginbean");
			req.getSession().setAttribute("User", localUser);
		}
		catch (SQLException e){
			sc.log("SQLException: " + e.toString(), e);
			throw e;
		}
		catch (Exception e){
			sc.log("Regular exception: " + e.toString(), e);
			throw e;
		}
	}
	
	private void verifyAdLogin() throws Exception{
		LDAPAuthenticationBP ldapBP = LDAPAuthenticationBP.getInstance();
		boolean result = ldapBP.authenticate("yhu", localUser.password);
		
		if (result ) {
			localUser.adAuthenticated = true;
			return; 
		}
		
	}
	
	private void initializeMzpUser(String mzpId) throws Exception{
		boolean failedLogin = false;
		
		try{

			//tries to retrieve the record matching the user-entered user id
			Iusers userRec = Iusers.getIusersByUsername(User.getGenericUser(), mzpId.toUpperCase());
			if (userRec != null){
				localUser.result = "SUCCESS";//the username is found in the database
				SecuritySettings setting = new SecuritySettings(User.getGenericUser());//retrieves the record from security settings
				//for time comparisons
				Calendar todayCal = Calendar.getInstance();
				Timestamp today = DateUtilities.getTimestamp(true);
				todayCal.setTimeInMillis(today.getTime());
				Calendar userSetCal = Calendar.getInstance();
				userSetCal.setTimeInMillis(userRec.getPasswordSetDate().getTime());

				//checks to see if the account has been deleted
				
				//checks if the account is disabled
				
				//checks if the acount should be disabled

				//checks if the account has been idle for longer than the allowed amount of days

				//Checks to see if password is changeable and compares the date of last change to the days allowed

				//Compares the user-entered password to the stored password and compares the number of failed logins to the number allowed
				
				//checks to see if they need to reset their password
				userSetCal.setTimeInMillis(userRec.getPasswordSetDate().getTime());
				
				if (failedLogin == false){
					localUser.authenticated = true;
					localUser.result = "SUCCESS";
					localUser.passwordExpired = false;
					localUser.email = userRec.getEmail();
					localUser.langCd = userRec.getLangCode();
					localUser.userID = (userRec.getUserId().toString());
					userRec.setLastLogin(today);
					userRec.setFailedLogins(new BigDecimal(0));
				}
				
				userRec.save();
			}
			else{
				localUser.result = "Username not found";
				localUser.authenticated = false;
			}

		}
		catch (SQLException e){
			e.printStackTrace(System.err);
			log.error("user not found()", e);
		}

	}


	/**
	 * verifies user's credentials against CX_IUSERS
	 * Event codes:
	 *   100 - login successful
	 *   101 - invalid password
	 *   102 - attempt to login to deleted account
	 *   103 - attempt to login to disabled account
	 *   104 - account disabled - expired
	 *   105 - account disabled - max attempts exceeded
	 *   106 - account disabled - inactivity
	 *   107 - account disabled - password expired and user not authorized to set password
	 *   110 - user reset their password
	 *   111 - user logged out ( see conxonshttplistener )
	 *   
	 * @throws Exception
	 */
	private void verifyLogin() throws Exception{
		String enPwd = cs.encrypt(localUser.password);
		boolean failedLogin = false;
		
		String mzpId = req.getParameter("mzpIds"); 
		if (mzpId ==null) {
			mzpId = ""; 
		}

		try{

			//tries to retrieve the record matching the user-entered user id
			Iusers userRec = Iusers.getIusersByUsername(User.getGenericUser(), localUser.userName);
			if (userRec != null){
				localUser.result = "SUCCESS";//the username is found in the database
				SecuritySettings setting = new SecuritySettings(User.getGenericUser());//retrieves the record from security settings
				//for time comparisons
				Calendar todayCal = Calendar.getInstance();
				Timestamp today = DateUtilities.getTimestamp(true);
				todayCal.setTimeInMillis(today.getTime());
				Calendar userSetCal = Calendar.getInstance();
				userSetCal.setTimeInMillis(userRec.getPasswordSetDate().getTime());

				//checks to see if the account has been deleted
				if ("Y".equals(userRec.getDeleted())){
					localUser.result = "Your account has been deleted. Please contact your administrator.";
					localUser.authenticated = false;//sets authenticated flag to false	
					pciLog.warn("4: Attempt to log in to deleted account: "+localUser.userName);
					failedLogin = true;
				}

				//checks if the account is disabled
				if (!failedLogin && "Y".equals(userRec.getDisabled())){
					localUser.result = "Your account has been disabled. Please contact your administrator.";
					localUser.authenticated = false;//sets authenticated flag to false
					pciLog.warn("5: Attempt to log in to disabled account: "+localUser.userName);
					failedLogin = true;
				}

				//checks if the acount should be disabled
				if (!failedLogin && userRec.getDisableOnDate() != null ){
					userSetCal.setTimeInMillis(userRec.getDisableOnDate().getTime());
					if ((DateUtilities.dateDiff(userSetCal, todayCal)) >= 0){
						userRec.setDisabled("Y");
						localUser.authenticated = false;
						localUser.result = "Your account has been disabled. Please contact your administrator.";
						pciLog.error("6: Account disabled, expired: "+localUser.userName);
						failedLogin = true;
					}
				}
				//checks if the account has been idle for longer than the allowed amount of days
				if (!failedLogin && setting.getUnusedDaysAllowed() != null && userRec.getLastLogin() != null){
					userSetCal.setTimeInMillis(userRec.getLastLogin().getTime());
					if ((DateUtilities.dateDiff(userSetCal, todayCal)) > (setting.getUnusedDaysAllowed().intValue())){
						userRec.setDisabled("Y");
						userRec.setDisableOnDate(today);
						localUser.authenticated = false;
						localUser.result = "Your account has not been used in more than " + (setting.getUnusedDaysAllowed())
								+ " days and has been disabled. Please contact your administrator.";
						pciLog.error("7: Account disabled, inactivity: "+localUser.userName);
						failedLogin = true;
					}
				}
				//Checks to see if password is changeable and compares the date of last change to the days allowed
				if (!failedLogin && userRec.getPasswordSetDate() != null){
					userSetCal.setTimeInMillis(userRec.getPasswordSetDate().getTime());
					if (("N".equals(userRec.getPasswordChangeable()))
							&& (DateUtilities.dateDiff(userSetCal, todayCal) > setting.getPasswordExpireDays().intValue())
							&& ("N".equals(userRec.getPasswordNeverExpires()))){
						userRec.setDisabled("Y");
						userRec.setDisableOnDate(today);//sets the disabled on date to today
						localUser.authenticated = false;
						localUser.result = "Your password has expired and your account has been disabled. Please contact your administrator.";
						pciLog.error("7: Account disabled, password expired: "+localUser.userName);
						failedLogin = true;
					}
				}
				//Compares the user-entered password to the stored password and compares the number of failed logins to the number allowed
				if (!failedLogin && !userRec.getPassword().equals(enPwd)){
					BigDecimal failedLogins = userRec.getFailedLogins();
					if(failedLogins == null && BigDecimal.ZERO.compareTo(setting.getLoginsFailedAllowed()) >= 0){
						userRec.setDisabled("Y");//disables the password
						userRec.setDisableOnDate(today);//sets the disabled on date to today
						localUser.authenticated = false;//sets authenticated flag to false
						localUser.result = "You have exceeded the allowed failed logins and your account has been disabled. Please contact your administrator.";
						pciLog.error("6: Account disabled - maximum login attempts reached by "+localUser.userName);
						failedLogin = true;
					}
					else if (failedLogins != null && failedLogins.compareTo(setting.getLoginsFailedAllowed()) >= 0){
						userRec.setDisabled("Y");//disables the password
						userRec.setDisableOnDate(today);//sets the disabled on date to today
						localUser.authenticated = false;//sets authenticated flag to false
						localUser.result = "You have exceeded the allowed failed logins and your account has been disabled. Please contact your administrator.";
						pciLog.error("6: Account disabled - maximum login attempts reached by "+localUser.userName);
						failedLogin = true;
					}

					//Increment the number of failed logins
					else{
						localUser.authenticated = false;
						localUser.result = "Invalid password. Please try again.";
						pciLog.warn("2: Invalid login attempt by "+localUser.userName);
						failedLogin = true;
					}
				}

				//checks to see if they need to reset their password
				userSetCal.setTimeInMillis(userRec.getPasswordSetDate().getTime());
				if (!failedLogin
						&& ("Y".equals(userRec.getPasswordExpired()) || (DateUtilities.dateDiff(userSetCal, todayCal) > setting
								.getPasswordExpireDays().intValue())) && "N".equals(userRec.getPasswordNeverExpires())){
					userRec.setPasswordExpired("Y");
					localUser.passwordExpired = true;
					localUser.authenticated = true;
					localUser.result = "Your password has expired. Please choose a new password.";
					failedLogin = true;
				}
				if (failedLogin == false){
					localUser.authenticated = true;
					localUser.result = "SUCCESS";
					localUser.passwordExpired = false;
					localUser.email = userRec.getEmail();
					localUser.langCd = userRec.getLangCode();
					localUser.userID = (userRec.getUserId().toString());
					userRec.setLastLogin(today);
					userRec.setFailedLogins(new BigDecimal(0));
				}
				else{
					BigDecimal failedLogins = userRec.getFailedLogins();
					if(failedLogins == null)
						userRec.setFailedLogins(new BigDecimal("1"));
					else
						userRec.setFailedLogins(failedLogins.add(new BigDecimal("1")));
					
				}

				userRec.save();
			}
			else{
				localUser.result = "Username not found";
				localUser.authenticated = false;
			}

		}
		catch (SQLException e){
			e.printStackTrace(System.err);
			log.error("user not found()", e);
		}

	}
	
	private void finishAdLogin(String mzpId) {
		// These need to be removed at some point, when the rest of the code is finished.
		req.getSession().setAttribute("USER_ID", localUser.userID);
		req.getSession().setAttribute("USER_NAME", mzpId);
		req.getSession().setAttribute("USER_EMAIL", localUser.email);
		String qry = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		// Set groups
		try{
			conn = ConnectionPool.getConnection(localUser);
			qry = "select GROUP_CODE from CX_GROUPS, CX_GROUP_TO_USER where USER_ID = ? and CX_GROUPS.group_id = CX_GROUP_TO_USER.group_id";
			ps = conn.prepareStatement(qry);
			ps.setString(1, localUser.userID);
			ArrayList<String> groupList = new ArrayList<String>();
			rs = ps.executeQuery();
			while (rs.next()){
				String grpCode = rs.getString("GROUP_CODE");
				groupList.add(grpCode);
				log.debug("Added group " + grpCode);
			}
			rs.close();
			rs = null;
			if (ps != null){
				ps.close();
				ps = null;
			}

			qry = "select * from CX_IUSERS where USER_ID = ?";
			ps = conn.prepareStatement(qry);
			ps.setString(1, localUser.userID);
			rs = ps.executeQuery();
			while (rs.next()){
				localUser.fname = rs.getString("FNAME");
				localUser.lname = rs.getString("LNAME");
				localUser.mname = rs.getString("MNAME");
			}
			rs.close();
			rs = null;
			if (ps != null){
				ps.close();
				ps = null;
			}

			localUser.setGroups(groupList);
		}
		catch (SQLException eee){
			log.debug("Error getting groups: " + eee.toString());
		}
		finally{
			if (rs != null) try{
				rs.close();
				rs = null;
			}
			catch (Exception csqle){
				log.error("error closing resultset: " + csqle.toString());
			}
			if (ps != null) try{
				ps.close();
				ps = null;
			}
			catch (Exception csqle){
				log.error("error closing statement: " + csqle.toString());
			}
			if (conn != null){
				try{
					conn.close();
				}
				catch (Exception e){
					log.error("error closing connection: " + e.toString());
				}
			}
		}
		// Set location attributes in user object
		localUser.setAttribute("HOST", req.getRemoteHost());
		localUser.setAttribute("REMOTE_USER", req.getRemoteUser());
		localUser.setAttribute("IP_ADDRESS", req.getRemoteAddr());

		// Set cookie with the EMAIL & password parameters set
		// and set the UserID in the session ID..
		String canCookie = (String) sc.getAttribute("CanSavePassword");
		if (canCookie == null || canCookie.equalsIgnoreCase("Y")){
			Integer cookieTime = (Integer) sc.getAttribute("CookieTime");
			if (cookieTime == null){
				cookieTime = new Integer(300);
			}

			String cookieVar = (String) sc.getAttribute("CookieVar");
			if (cookieVar == null){
				cookieVar = "test"; // just some value for test purposes.
			}
			if (req.getParameter("Cookie") != null){ //they are saving their password.
				Cookie emailCookie = new Cookie("username", mzpId);
				Cookie passwordCookie = new Cookie("password", localUser.password);
				emailCookie.setMaxAge(cookieTime.intValue());
				passwordCookie.setMaxAge(cookieTime.intValue());
				emailCookie.setComment(cookieVar);
				passwordCookie.setComment(cookieVar + " " + mzpId);
				res.addCookie(emailCookie);
				res.addCookie(passwordCookie);
			}
		}
	}

	/**
	 * finishes the user's login process
	 */
	private void finishLogin(){
		// These need to be removed at some point, when the rest of the code is finished.
		req.getSession().setAttribute("USER_ID", localUser.userID);
		req.getSession().setAttribute("USER_NAME", localUser.userName);
		req.getSession().setAttribute("USER_EMAIL", localUser.email);
		String qry = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		// Set groups
		try{
			conn = ConnectionPool.getConnection(localUser);
			qry = "select GROUP_CODE from CX_GROUPS, CX_GROUP_TO_USER where USER_ID = ? and CX_GROUPS.group_id = CX_GROUP_TO_USER.group_id";
			ps = conn.prepareStatement(qry);
			ps.setString(1, localUser.userID);
			ArrayList<String> groupList = new ArrayList<String>();
			rs = ps.executeQuery();
			while (rs.next()){
				String grpCode = rs.getString("GROUP_CODE");
				groupList.add(grpCode);
				log.debug("Added group " + grpCode);
			}
			rs.close();
			rs = null;
			if (ps != null){
				ps.close();
				ps = null;
			}

			qry = "select * from CX_IUSERS where USER_ID = ?";
			ps = conn.prepareStatement(qry);
			ps.setString(1, localUser.userID);
			rs = ps.executeQuery();
			while (rs.next()){
				localUser.fname = rs.getString("FNAME");
				localUser.lname = rs.getString("LNAME");
				localUser.mname = rs.getString("MNAME");
			}
			rs.close();
			rs = null;
			if (ps != null){
				ps.close();
				ps = null;
			}

			localUser.setGroups(groupList);
		}
		catch (SQLException eee){
			log.debug("Error getting groups: " + eee.toString());
		}
		finally{
			if (rs != null) try{
				rs.close();
				rs = null;
			}
			catch (Exception csqle){
				log.error("error closing resultset: " + csqle.toString());
			}
			if (ps != null) try{
				ps.close();
				ps = null;
			}
			catch (Exception csqle){
				log.error("error closing statement: " + csqle.toString());
			}
			if (conn != null){
				try{
					conn.close();
				}
				catch (Exception e){
					log.error("error closing connection: " + e.toString());
				}
			}
		}
		// Set location attributes in user object
		localUser.setAttribute("HOST", req.getRemoteHost());
		localUser.setAttribute("REMOTE_USER", req.getRemoteUser());
		localUser.setAttribute("IP_ADDRESS", req.getRemoteAddr());

		// Set cookie with the EMAIL & password parameters set
		// and set the UserID in the session ID..
		String canCookie = (String) sc.getAttribute("CanSavePassword");
		if (canCookie == null || canCookie.equalsIgnoreCase("Y")){
			Integer cookieTime = (Integer) sc.getAttribute("CookieTime");
			if (cookieTime == null){
				cookieTime = new Integer(300);
			}

			String cookieVar = (String) sc.getAttribute("CookieVar");
			if (cookieVar == null){
				cookieVar = "test"; // just some value for test purposes.
			}
			if (req.getParameter("Cookie") != null){ //they are saving their password.
				Cookie emailCookie = new Cookie("username", localUser.userName);
				Cookie passwordCookie = new Cookie("password", localUser.password);
				emailCookie.setMaxAge(cookieTime.intValue());
				passwordCookie.setMaxAge(cookieTime.intValue());
				emailCookie.setComment(cookieVar);
				passwordCookie.setComment(cookieVar + " " + localUser.userName);
				res.addCookie(emailCookie);
				res.addCookie(passwordCookie);
			}
		}
	}

	/**
	 * updates the user's password
	 * @param inPassword
	 * @return localUser.result
	 */
	private String updatePassword(String inPassword){
		try{
			log.debug("In updatePassword");

			// get user object
			localUser = (User) req.getSession().getAttribute("User");
			if (localUser == null){
				localUser = User.getGenericUser();
				req.getSession().setAttribute("User", localUser);
				return Messages.getString("NOT_LOG_ON");//"Not Logged On";
			}
			Iusers pwUserRec = Iusers.getIusersByUsername(User.getGenericUser(), localUser.userName);//retrieves a user's record

			validateUserPW(pwUserRec, inPassword);

			if ("SUCCESS".equals(localUser.result)){
				Calendar todayCal = Calendar.getInstance();
				Timestamp today = DateUtilities.getTimestamp(true);
				todayCal.setTimeInMillis(today.getTime());
				String encPassword = cs.encrypt(inPassword);
				pwUserRec.setPassword(encPassword);
				pwUserRec.setPasswordExpired("N");
				pwUserRec.setPasswordSetDate(today);
				localUser.password = inPassword;
				localUser.loginComplete = true;
				localUser.passwordExpired = false;
				finishLogin();
				req.getSession().setAttribute("User", localUser);
				pwUserRec.save();
			}
			return localUser.result;
		}
		catch (SQLException e){
			log.debug(StackTraceUtil.getStackTrace(e));
			return Messages.getString("ERROR_MSG") + e.toString();
		}
		catch (Exception e){
			log.debug(StackTraceUtil.getStackTrace(e));
			return Messages.getString("ERROR_MSG") + e.toString();
		}
	}

	/**
	 * validates the user's new password against password requirements in CX_SECURITY_SETTINGS
	 * @param pwUserRec
	 * @param newPassword
	 * @throws Exception
	 */
	private void validateUserPW(Iusers pwUserRec, String newPassword) throws Exception{

		SecuritySettings pwSettings = new SecuritySettings(User.getGenericUser());//retrieves the record from security settings
		Integer mc_count = 0;
		localUser.result = "";

		//rejects and empty password
		if ("".equals(newPassword)){
			localUser.result = "Invalid Password, cannot be empty.";
			return;
		}
		//makes sure the new password meets minimum length requirements
		if (newPassword.length() < pwSettings.getPasswordSizeMin().intValue()){
			localUser.result = "Password must be at least " + pwSettings.getPasswordSizeMin() + " characters. ";
		}
		//makes sure new password meets maximum length requirements
		else if (newPassword.length() > pwSettings.getPasswordSizeMax().intValue()){
			localUser.result = "Password must be less than " + pwSettings.getPasswordSizeMax() + " characters. ";
		}

		mc_count = 0;
		//checks for use of required characters and minimum number of required characters
		if (pwSettings.getPasswordMustContain() != null && pwSettings.getPasswordMustContainCt() != null
				&& pwSettings.getPasswordMustContainCt().intValue() > 0){
			for (int i = 0; i < pwSettings.getPasswordMustContain().length(); i++){
				String mustContain = pwSettings.getPasswordMustContain().substring(i, i + 1);
				if (newPassword.contains(mustContain)){
					mc_count = mc_count + 1;

				}
			}
			if (mc_count < pwSettings.getPasswordMustContainCt().intValue()){
				localUser.result = localUser.result + " Password must contain at least " + pwSettings.getPasswordMustContainCt()
						+ " of these characters: " + pwSettings.getPasswordMustContain() + ".";
			}
		}

		mc_count = 0;
		//checks for use of forbidden characters
		if (pwSettings.getPasswordCantContain() != null){
			for (int i = 0; i < pwSettings.getPasswordCantContain().length(); i++){
				String cantContain = pwSettings.getPasswordCantContain().substring(i, i + 1);
				if (newPassword.contains(cantContain)){
					mc_count = 1;
				}
			}
			if (mc_count > 0){
				localUser.result = localUser.result + " Password connot contain any of these characters " + pwSettings.getPasswordCantContain() + ".";
			}

		}

		mc_count = 0;
		//checks for the use of the required minimum number of digits used
		if (pwSettings.getPasswordNumNumerics() != null && pwSettings.getPasswordNumNumerics().intValue() > 0){
			for (int i = 0; i < newPassword.length(); i++){
				char ch = newPassword.charAt(i);
				if (Character.isDigit(ch)){
					mc_count = mc_count + 1;
				}
			}
			if (mc_count < pwSettings.getPasswordNumNumerics().intValue()){
				localUser.result = localUser.result + " Password must contain at least " + pwSettings.getPasswordNumNumerics()
						+ " numeric characters.";
			}

		}

		//checks to see if a different password is required
		if ("Y".equals(pwSettings.getRequireDifferentPassword())){
			String existingPassword = cs.decrypt(pwUserRec.getPassword());
			if (newPassword.equals(existingPassword)){
				localUser.result = localUser.result + "Password cannot be the same as your previous password.";
			}
		}
		//sets the result to sucess if the password has not been failed above
		if ("".equals(localUser.result)){
			localUser.result = "SUCCESS";

		}
	}

	/**
	 * setEMAIL
	 *
	 * @param email java.lang.String email - email name of the user loggin in.
	 */
	public void setEMAIL(String email){
		localUser.email = email;
	}

	/**
	 * setUSERNAME
	 *
	 * @param val java.lang.String login username.
	 */
	public void setUSERNAME(String val){
		log.debug("in setUSERNAME, value = " + val);
		localUser.userName = StringUtils.safeString(val).toUpperCase();
	}

	/**
	 * 
	 * @param val
	 */
	public void setUSERNAME(String[] val){
		log.debug("in setUSERNAME[], value = " + val[0]);
		localUser.userName = val[0].toUpperCase();
	}

	/**
	 * getUSERNAME
	 *
	 * @return java.lang.String login username.
	 */
	public String getUSERNAME(){
		return StringUtils.blanknull(localUser.userName);
	}

	/**
	 * 
	 * @return integer
	 */
	public Integer getCookieTime(){
		return (Integer) sc.getAttribute("CookieTime");
	}

	/**
	 * getEMAIL
	 *
	 * @return java.lang.String email - email name of the user loggin in.
	 */
	public String getEMAIL(){
		return StringUtils.blanknull(localUser.email);
	}

	/**
	 * 
	 * @return boolean
	 */
	public boolean isUSERNAMEValid(){
		if ((localUser.userName == null) || (localUser.userName.equalsIgnoreCase("null")) || (localUser.userName.equals(""))){
			return false;
		}
		return true;
	}

	/**
	 * setPASSWORD
	 * 
	 * @param val java.lang.String
	 *            password - password name of the user loggin in.
	 */
	public void setPASSWORD(String val){
		localUser.password = val;
	}

	/**
	 * getPASSWORD
	 *
	 * @return java.lang.String password - password name of the user loggin in.
	 */
	public String getPASSWORD(){
		if (localUser.password == null) return "";
		return localUser.password;
	}

	/**
	 * isPASSWORDValid() - checks to see if password property has been set
	 * correctly.  If it is null or blank, this method returns false.
	 *
	 * @return boolaen
	 */
	public boolean isPASSWORDValid(){
		if ((localUser.password == null) || (localUser.password.equalsIgnoreCase("null")) || (localUser.password.equals(""))){
			return false;
		}
		return true;
	}

	/**
	 * getPAGELOCATION - READ ONLY parameter to set up URL to call default.jsp
	 * with the correct Query sting.
	 * @return String
	 */
	public String getPAGELOCATION(){	
		if (_pageLocation == null) return "";
		return _pageLocation;
	}

	/**
	 * getResult
	 *
	 * @return java.lang.String processing result.
	 */
	public String getResult(){
		if (localUser.result == null) return "";
		return localUser.result;
	}

	/**
	 * getResult: get result in different language
	 * @param langCd
	 * @return String
	 */
	public String getResult(String langCd){
		if (localUser.result == null || "".equals(localUser.result.trim())) return "";
		if ("SUCCESS".equalsIgnoreCase(localUser.result)) return "SUCCESS";
		if (langCd == null || "".equals(langCd) || "EN".equals(langCd)) return localUser.result;
		try{
			String ret = ConxonsUtils.getTranslation(sc, localUser.result, langCd);
			return ret;
		}
		catch (Exception e){
			log.error(StackTraceUtil.getStackTrace(e));
			return null;
		}
	}

	/**
	 * getPwdExpired
	 *
	 * @return java.lang.String Y if expired, N otherwise
	 */
	public String getPwdExpired(){
		return (localUser.passwordExpired) ? "Y" : "N";
	}

	/**
	 * 
	 * @param val
	 */
	public void setUserObject(User val){
		localUser = val;
		log.debug("setting userobject");
		if (localUser == null){
			localUser = User.getInstance();
		}
	}

	/**
	 * 
	 * @param val
	 */
	public void setlogout(String val){
		if (val.equalsIgnoreCase("Y")) _logout = true;
	}

	/**
	 * 
	 * @return boolean
	 */
	public boolean islogout(){
		return _logout;
	}

	/**
	 * 
	 * @return String
	 */
	public String getLANGCD(){
		return _langCd;
	}

	/**
	 * 
	 * @param val
	 */
	public void setLANGCD(String val){
		log.debug("setLangCode: " + val);
		_langCd = val;
	}
}
