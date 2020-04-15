<%@ Page Language="c#" MasterPageFile="Setup.master" %>
<%@ Import Namespace="GM" %>

<script language="C#" runat="server">

    void Page_Load(object sender, System.EventArgs e)
    {
        if (!IsPostBack)
            message.InnerHtml  = Request.QueryString ["msg"];
        int RowCount = Grid.Rows.Count;
        Session["RowCount"] = RowCount;
    }

    protected void Grid_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {
        if (e.Exception == null)
            message.InnerHtml = "Question was successfully deleted.";
        else
        {
            message.InnerHtml = e.Exception.InnerException.Message;
            e.ExceptionHandled = true;
        }
    }

    //protected void bntQuestionSort_Click(object sender, EventArgs e)
    //{

    //}

    protected void bntQuestionSort_Click(object sender, EventArgs e)
    {
        Response.Redirect("QuestionSort.aspx");
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="setupContent" runat="server">

    <script type="text/javascript">
        function confirmDelete(paxExist) {
            if (paxExist == 'Y')
                return confirm('THE SELECTED QUESTION IS CURRENTLY IN USE!!!\nProceeding will remove the answers already provided!!!\n\nAre you sure you wish to delete?');
            else
                return confirm('Are you sure you wish to delete?');
        }
    </script>

    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td class="hdr" valign="bottom">Passenger Questions</td>
            <td align="right">
               <%--&nbsp;&nbsp;<asp:Button ID="bntQuestionSort" runat="server" Text="Sort Questions" OnClick="bntQuestionSort_Click" />--%>
                 &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionSort.aspx';return false;" value="Sort Questions" />
                &nbsp;&nbsp;<input type="button" onclick="javascript:window.location.href='QuestionEdit.aspx?questionid=0';return false;" value="Add Question" />
             </td>
        </tr>
        <tr>
            <td width="100%" class="line" colspan="2" height="1"></td>
        </tr>
        <tr>
            <td>
                <span id="message" class="message" runat="server" enableviewstate="false"></span>
                &nbsp;
            </td>
        </tr>
    </table>
    <asp:GridView ID="Grid" runat="server" Width="100%" CssClass="list" CellPadding="3" PageSize="100" GridLines="Horizontal" AllowPaging="true" AllowSorting="true" DataSourceID="gridSource"
        AutoGenerateColumns="False" DataKeyNames="questionid" onrowdeleted="Grid_RowDeleted">
        <HeaderStyle CssClass="listhdr" />
        <Columns>
	        <asp:HyperLinkField DataTextField="questionname" HeaderText="Question Name" HeaderStyle-HorizontalAlign="Left" SortExpression="questionname" DataNavigateUrlFormatString="QuestionEdit.aspx?questionid={0}" DataNavigateUrlFields="questionid" />  
            <asp:BoundField DataField="QuestionGroup" HeaderText="Group Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="QuestionGroup" />
            <asp:BoundField DataField="revtypedesc" HeaderText="Travel Type" HeaderStyle-HorizontalAlign="Left"  SortExpression="revtypedesc" />
            <asp:BoundField DataField="groupidlist" HeaderText="Group # List" HeaderStyle-HorizontalAlign="Left"  SortExpression="groupidlist" />
            <asp:TemplateField HeaderText="Display Type" HeaderStyle-HorizontalAlign="Left" SortExpression="type">
                <ItemTemplate>
                    <%# GM.PickList.GetQuestionTypeDesc(Eval("type").ToString()) %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="list" HeaderText="Answer List" HeaderStyle-HorizontalAlign="Left"  SortExpression="list" />
            <asp:BoundField DataField="QuestionSort" HeaderText="Display Order" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" SortExpression="QuestionSort" />
            <asp:BoundField DataField="paxexist" HeaderText="In Use" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" SortExpression="paxexist" />
            <asp:TemplateField HeaderText="Delete" HeaderStyle-Width="25px"  ItemStyle-Width="25px" >
                <ItemTemplate>
                    <asp:LinkButton ID="LnkDelete" runat="server" CausesValidation="False" CommandName="Delete" OnClientClick='<%# "return (confirmDelete(" + (char)(39) + Eval("paxExist") + (char)(39) + "));" %>' Text="Delete" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            <p class="message">
                No records found....</p>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:ObjectDataSource ID="gridSource" runat="server" SelectMethod="GetList" DeleteMethod="Delete" TypeName="GM.Question" />
</asp:Content>
