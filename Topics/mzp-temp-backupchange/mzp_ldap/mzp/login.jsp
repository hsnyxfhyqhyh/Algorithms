<%--
********************************************************************************
   TITLE         :  login.jsp
   DEVELOPER     :  Stephen L. McConnell
   DATE          :  May 15, 2001
   DESCRIPTION   :  This is the inital screen one sees upon entry to the
                    Con-X-ons framework.  Uses LoginBean to perform the intial
                    processing in the page.

                    The bean will perform the initial validation of the user
                    ID and passoword.

                    If the userid is validated by the login user e-mail and
                    password, the USER_ID is saved in the session object and
                    the user is re-directed to the default.jsp

                    If not, the login screen is shown again with an Incorrect
                    Login Message.

                    Parameters Received: (Case sensitive)
                        From
                           USERNAME   - the user's login name
                           PASSWORD   - password.

                        From other pages.
                           TSID       - the default tabset entry if re-logging in.
                           TSEL       - the default tab entry if re-logiing in.
                        Set:
                           Session parameters.
                           USER_ID      - the USER_ID for the user.
                           USER_NAME    - the user's login name
                           USER_EMAIL   - the user's email address.
                           BROWSER      - The browser type.
                           PAGELOCATION - The location of the page which to
                                          redirect.

********************************************************************************
Modification Log:
  Date     | Developer     |R        |Description
  ---------| --------------|---------|------------------------------------------
07/04/02     Al                       Modified to use login name instead of email
03/06/03   | Al            |         | turned off debugging

********************************************************************************
--%>
<%@ page contentType="text/html;charset=WINDOWS-1252"%>
<%@ page errorPage="error.jsp" %>
<%@ page import="com.rossgroupinc.conxons.security.User" %>
<%@ page import="com.rossgroupinc.util.*" %>
<%@ page import="java.util.*" %>

<!-- CSS BEGIN --> 
<STYLE TYPE="text/CSS">
   
   .loginText
   	{
    	font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size : 9pt;
		font-style : normal;
		font-weight : bold;
		color: #000000;
   	}
   #LoginLogoLayer
      {
         position : relative;
      }
   #LoginInfoLayer
      {
         position : relative;

      }
   #LoginRedirectInfoLayer
      {
         position : relative;
      }
   #LoginCopyRightInfoLayer
      {
         position : relative;
      }
   #LoginSubmit
      {
         position :relative;
         top : 20px;
      }
</STYLE>
<!-- CSS END -->
<%
   // To be included in every main and popup page.
   response.setHeader("Pragma", "no-cache");
   response.setHeader("Cashe-Control", "no-store");
   response.setDateHeader("Expires", 0);

%>
<jsp:useBean id="loginBean" class="com.rossgroupinc.conxons.security.LoginBean"/>
<%
   loginBean.setServletContext(application);
   loginBean.setServletRequest(request);
   loginBean.setServletResponse(response);
   String PATH = (String)application.getAttribute("path");
   String TSID= (String)request.getParameter("TSID");
   String TSEL= (String)request.getParameter("TSEL");
   String action= PATH +"/login.jsp";
   if (TSID!=null)
      action+="?TSID=" +TSID +"&TSEL=" +TSEL;
   String logout = request.getParameter("logout");
   String deepLinkMsg = request.getParameter("DEEPLINKERROR");
   User _user = (User) session.getAttribute("User");
   if (_user == null) _user = User.getInstance();
   loginBean.setUserObject(_user);
   %>
<jsp:setProperty name="loginBean" property="*"/>
<jsp:setProperty name="loginBean" property="userID" value='<%=(String)session.getAttribute("USER_ID")%>'/>
   <%
   loginBean.process();
%>
<HTML>
<!--
  Copyright (c) 2003 Ross Group Inc - The source code for
  this program is not published or otherwise divested of its trade secrets,
  irrespective of what has been deposited with the U.S. Copyright office.
-->
<script language="JavaScript">
<!--
function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v3.0
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<link rel="stylesheet" href="themes/custom.css">
<HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=WINDOWS-1252">
<TITLE>
<%=application.getAttribute("Title")%>
</TITLE>
</HEAD>
<%
   if(_user.loginComplete && (logout == null) )
   {
%>
<BODY class="login_background" onload="if (parent.frames.length!= 0) open (document.URL, '_top');" >
<table height="80%" width="100%">
	<tr>
    	<td align="center" valign="middle"> 
    		<span class="loginText">Please wait... Your custom profile is being built.<br></span><br>
      		<img src="images/aaa_generic_logo.gif"> 
     	</td>
  	</tr>
</table>
<form METHOD="POST" action="<%=PATH%>/<%=loginBean.getPAGELOCATION()%>" name="form1">
	<input type=hidden name=garbagedata value="<%=PATH%>/<%=loginBean.getPAGELOCATION()%>">
 </form>

<script language="javascript">
	document.form1.submit();
</script>
</BODY>

<%
     return;
   }else{

%>
<script language=javascript>
  if (parent.frames.length != 0) {
    open(document.URL,'_top');
  }
</script>
<script language="javascript">
<!--
    function onPageLoad() {
        MM_preloadImages('images/custom/login_button_on.gif');
        <%
        if (_user.result != null && (_user.result.startsWith("Password") || _user.result.startsWith("Invalid password"))) {
            %>
            document.getElementById("PASSWORD").focus();
            <%
        }
        else {
            %>
            // result = "<%=((_user==null)?"usernull":_user.result)%>"
            document.getElementById("form1").elements[0].focus();
            <%
        }
        %>
    }
//-->
</script>
<BODY class="login_background" onload="onPageLoad();" onkeydown="if (event.keyCode=='13'){document.form1.submit();};" >
<DIV ID="LoginBackground"></DIV>
<DIV ID="LoginLogoLayer">
<table border="0" cellspacing="0" width="100%">
   <tr>
      <td class="login_label" valign="top" align="center">
      	<br><b><font size="2"><br></font></b> 
      </td>
   </tr>
</table>
</DIV>

<!-- rounded corner table // OPEN // -->
<table border="0" cellspacing="0" cellpadding="0" width="600" height="100" align = "center" bgcolor="#ffffff">
	<tr>
	  	<td colspan="2" bgcolor="A30018" align="left" valign="top"><img src="images/pixel.gif" width="1" height="1"></td>
	  	<td bgcolor="A30018" rowspan="2" align="right" valign="top" width="1"><img src="images/pixel.gif" width="1" height="1"></td>
	</tr>
	<tr> 
    	<td bgcolor="A30018" align="left" valign="top" width="1"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td nowrap rowspan="2" align="center" class="loginLabel" background="images/custom/login_bg_image_ma.jpg">
    		<div class="loginForm">
				<table width="400" border="0" cellspacing="0" cellpadding="0" height="0">
	 				<tr> 
				    	<td width="1" height="1"><img src="images/pixel.gif" width="1" height="1"></td>
				    	<td width="168"><img src="images/pixel.gif" width="1" height="1"></td>
				    	<td width="164"><img src="images/pixel.gif" width="1" height="1"></td>
				    	<td width="167"><img src="images/pixel.gif" width="1" height="1"></td>
				  	</tr>
				  	<tr>
				    	<td width="1" height="1"><img src="images/pixel.gif" width="1" height="1"></td>
				    	<td colspan="3" height="2">&nbsp;</td>
				  	</tr>
				  	<tr> 
				    	<td width="1" height="0"><img src="images/pixel.gif" width="1" height="1"></td>
				    	<td colspan="3" valign="top"> 
							<!--<div id="LoginInfoLayer">-->
							 
							<!--</div>-->
							 
							<!--<div id="LoginRedirectInfoLayer">-->
							 
							<!-- <center>-->
							 
							<!--</center>-->
							 
							<!--</div>-->
							 
							<!--<div id="LoginSubmit"></div>-->
				
				
							<form method="POST" action="<%=action%>" id="form1" name="form1" autocomplete=on>
							  	<!-- ttable main inside rounded corner table // OPEN // -->
							  	<div class="cust_errorWarning">
								<% 
								if(deepLinkMsg != null && !"".equals(deepLinkMsg.trim())) {
									out.println(deepLinkMsg);
								}
								%>               
							  	</div> 
							  	<table border="0" cellspacing="0" width="100%">
							    <%if(_user.result != null && !_user.result.equals("SUCCESS")){%>
								    <tr> 
								        <td width="60%" class="cust_errorWarning" align="center">
								        	<%=loginBean.getResult()%>                   	
								       	</td>
								        <td width="40%"></td>
								    </tr>
							    <%}%>
							    	<tr> 
							      		<td valign="top" align="center" colspan=2> 
								        <!-- table border outline // OPEN // -->
								         
								        <!-- table border outline // CLOSE // -->
							         
							        		<table border="0" cellpadding="0" cellspacing="3" align="left">
												<% if (_user.passwordExpired) {%>
										        <tr> 
										                <td class="loginText" align="right">&nbsp;</td>
										                <td class="loginText" align="right">&nbsp;&nbsp;New Password:</td>
										                <td> 
										                	<input type="password" name="NEW_PASSWORD" class="login_input" size="34" ID="Password3" value="">&nbsp;&nbsp;
										                </td>
										        </tr>
										        <tr> 
										                <td class="loginText" align="right">&nbsp;</td>
										                <td class="loginText" align="right">&nbsp;&nbsp;Retype Password:</td>
										                <td> 
										                	<input type="password" name="VALIDATE_PASSWORD" class="login_input" size="34" ID="Password1" value="">&nbsp;&nbsp;
										                </td>
										        </tr>
												<% } else if (!_user.adAuthenticated){ %>
												<tr> 
													<td class="loginText" align = "right" height="27" width="4">&nbsp;</td>
												  	<td class="loginText" align = "right" height="27" width="103">&nbsp;&nbsp;Login Name:</td>
												  	<td height="27" width="241"> 
												    	<input type="text" class="login_input" name="USERNAME" size="30" maxlength="256" value="<%=StringUtils.blanknull(_user.userName)%>">
												    	&nbsp;&nbsp;
												    </td>
												</tr>
												<tr> 
												 		<td class="loginText" align = "right" height="26" width="4">&nbsp;</td>
												  	<td class="loginText" align = "right" height="26" width="103">&nbsp;&nbsp;Password:</td>
												  	<td height="26" width="241"> 
												    	<input type="password" name="PASSWORD" class = "login_input" size="30" maxlength="56">
												    	&nbsp;&nbsp;
												   	</td>
												</tr>
												<% } else if (_user.adAuthenticated) {%>
												<tr> 
													<td class="loginText" align = "right" height="27" width="4">&nbsp;</td>
												  	<td class="loginText" align = "right" height="27" width="103">&nbsp;&nbsp;MZP ID:</td>
												  	<td height="27" width="241"> 
												    	<select name="mzpIds">
												    	  <option value=""></option>
														  <option value="yhu">Ying Hu</option>
														  <option value="wwei">Wei Wei</option>
														  <option value="admin">Administrator Conxons</option>
														</select>
												    	&nbsp;&nbsp;
												    </td>
												</tr>
												<%
												String savePossible = (String) application.getAttribute("CanSavePassword");
												loginBean.dbg("can save password = "+savePossible);
												if (savePossible == null || savePossible.equalsIgnoreCase("Y")) {
												%>
												<tr> 
													<td  colspan="3" align="center">&nbsp;&nbsp; 
												    	<input login_checkbox  type="checkbox" name="Cookie" value="ON">
												    	<span class="loginLabel">Save Password</span>
												   	</td>
												</tr>
												<%
													}
												}
												%>
												<% if (!_user.adAuthenticated){ %>
												<tr> 
												  	<td class="save_label" colspan="3" align="center" height="9"><img src="images/pixel.gif" width="1" height="1"></td>
												</tr>
												<tr> 
												  	<td class="save_label" colspan="3" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href=# onClick="document.form1.submit();return false;" onMouseOut="MM_swapImgRestore()" onMouseOver="MM_swapImage('Image37','','images/custom/login_button_on.gif',1)"><img name="Image37" border="0" src="images/custom/login_button_off.gif" ></a>
												     		<button type="submit" name="Submit" value="Submit" style=display:none></button>
												   	</td>
											 	</tr>
											 	<% }  else {%>
											 	<tr> 
												  	<td class="save_label" colspan="3" align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
												     		<button type="submit" name="Submit" value="Next" ></button>
												   	</td>
											 	</tr>
											 	<% } %>
											</table>
				             			</td>
			           				</tr>
				         		</table>
	              				<!-- table main inside rounded corner table  // CLOSE // -->
	           				</form>
	          			</td>
	        		</tr>
			        <tr> 
			        	<td width="1"><img src="images/pixel.gif" width="1" height="1"></td>
			          	<td colspan="3" height="20">&nbsp;</td>
			        </tr>
			        <tr> 
			          	<td width="1" height="2"><img src="images/pixel.gif" width="1" height="1"></td>
			          	<td width="168" height="2"><img src="images/pixel.gif" width="1" height="1"></td>
			          	<td width="164" height="2"><img src="images/pixel.gif" width="1" height="1"></td>
			          	<td width="167" height="2"><img src="images/pixel.gif" width="1" height="1"></td>
			        </tr>
	      		</table>
      		</div>
    	</td>
  	</tr>
	<tr> 
		<td height="1" bgcolor="A30018" width = "1"><img src="images/pixel.gif" width="1" height="1"></td>
	  	<td height="1" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
	</tr>
 	<tr> 
    	<td height="1" bgcolor="A30018" width = "1"><img src="images/pixel.gif" width="1" height="1"></td>
		<td height="7" align="left" valign="bottom"> 
			<table width="200" border="0" cellspacing="0" cellpadding="0">
			    <tr bgcolor="#dceaf4">
		      		<th align="left" valign="top" width="9" bgcolor="E6E6E6">&nbsp;</th>
			      	<td align="center"  width="125" bgcolor="E6E6E6" ><a href="popup/emailpassword.jsp" class="loginLink">Email Password</a></td>
			    </tr>
		  	</table>
		</td>
    	<td height="1" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
  	</tr>
  	<tr> 
    	<td height="1" width = "1" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td height="7" bgcolor="EEC100"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td height="1" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
  	</tr>
  	<tr> 
    	<td height="15" width = "1" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td height="15" align="right" bgcolor="A30018"></td>
    	<td height="15" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
  	</tr>
  	<tr> 
    	<td height="2" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td height="2" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
    	<td height="2" bgcolor="A30018"><img src="images/pixel.gif" width="1" height="1"></td>
  	</tr>
</table>
<!-- rounded corner tabel // CLOSE // -->

<%
   // Clear the user object
   	}
	loginBean.releaseDBConnection();
%>


</BODY>
</HTML>
