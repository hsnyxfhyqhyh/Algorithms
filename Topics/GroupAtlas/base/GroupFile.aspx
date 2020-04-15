<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.Master" AutoEventWireup="true" CodeFile="GroupFile.aspx.cs" Inherits="GroupFile" %>


<asp:Content ID="Content1" ContentPlaceHolderID="mainContent" Runat="Server">
    <table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td class="hdr" id="hdr" runat="server" valign="top">File Storage for Group:&nbsp; <asp:Label runat="server" ID="lblGroup"></asp:Label></td>
			<td align="right">

              <%-- <asp:button id="Files" runat="server" Text="Files" Width="85px" CssClass="button" TabIndex="-1" CausesValidation="False" OnClick="Files_Click"></asp:button>&nbsp;
                <asp:button id="flyer" runat="server" Text="Flyer Detail" Width="85px" CssClass="button" TabIndex="-1" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="newbooking" runat="server" Text="New Booking" Width="85px" CssClass="button" TabIndex="-1" ToolTip="New booking for group" CausesValidation="False"></asp:button>&nbsp;
                <asp:button id="bookings" runat="server" Text="Bookings" Width="75px" CssClass="button" TabIndex="-1" ToolTip="Bookings for group" CausesValidation="False"></asp:button>&nbsp;--%>
                <asp:button id="cancel" runat="server" Text="&lt;&lt;Back" Width="95px" CssClass="button" CausesValidation="False" OnClick="cancel_Click"></asp:button>&nbsp;
            </td>
		</tr>
		<tr>
			<td width="100%" colspan="2" class="line" height="1"></td>
		</tr>
	</table>
	<table cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td><span id="message" class="message" runat="server" EnableViewState="false"></span><br></td>
            <td align="right">
              <%-- <a href="GroupFile.aspx?groupid=<%=groupid%>">[Add to Waiting List]</a> --%>
            </td>
		</tr>
	</table>

    <asp:FileUpload ID="FileUpload1" runat="server" Width="500px" Height="23px"/>
    <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="UploadFile" />
    <hr />
        <asp:GridView ID="Grid" runat="server" AutoGenerateColumns="false" EmptyDataText = "No files uploaded">
            <AlternatingRowStyle BackColor="Linen" />
            <Columns>
                <asp:BoundField DataField="Text" HeaderText="File Name" ItemStyle-Width="300px" HeaderStyle-Font-Bold="true" HeaderStyle-Font-Size="Medium" />
                <asp:TemplateField ItemStyle-Width="60px">
                    <ItemTemplate>
                        <asp:Button ID="lnkDownload" Text = "Open" CommandArgument = '<%# Eval("Value") %>' runat="server" OnClick = "DownloadFile"></asp:Button>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField ItemStyle-Width="60px">
                    <ItemTemplate>
                        <asp:Button ID = "lnkDelete" Text = "Delete" CommandArgument = '<%# Eval("Value") %>' runat = "server" OnClick = "DeleteFile" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>

</asp:Content>

