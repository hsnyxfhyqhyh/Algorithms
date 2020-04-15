
using System;
using System.Collections;
using System.Security.Principal;

namespace GM
{

    public class CustomPrincipal : WindowsPrincipal
    {
        private ArrayList m_Roles;

        public CustomPrincipal(WindowsIdentity identity)
            : base(identity)
        {
            m_Roles = new ArrayList();
        }

        /// <summary>Checks if windows user has a valid role. If not access is denied to application.</summary>
        public override bool IsInRole(string role)
        {
            if (m_Roles.Contains(role))
                return true;
            else
                return false;
        }

        /// <summary>Calls from WindowsAuthentication_OnAuthenticate to populate user role based on PQM setup</summary>
        public void AddRole(string role)
        {
            m_Roles.Add(role);
        }
    }
}
