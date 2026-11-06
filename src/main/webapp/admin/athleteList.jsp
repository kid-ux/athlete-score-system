<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="bean.Athlete" %>
<html lang="zh-CN">
<head>
    <title>运动员管理 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<div class="toolbar">
    <div class="section-title" style="margin:0">运动员管理</div>
    <div class="spacer"></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">＋ 新增运动员报名</button>
</div>
<%
    String errMsg = (String) request.getAttribute("errMsg");
    if (errMsg != null) {
%>
<div class="alert alert-danger"><%=errMsg%></div>
<%}%>
<div class="g-card"><div class="g-card-body">
<table class="table table-striped">
    <thead>
    <tr>
        <th>ID</th>
        <th>账号</th>
        <th>报名赛事</th>
        <th>院系</th>
        <th>姓名</th>
        <th>性别</th>
        <th>资格审查</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Athlete> list = (List<Athlete>) request.getAttribute("athleteList");
        if (list != null) {
            for (Athlete a : list) {
                int st = a.getStatus() == null ? 0 : a.getStatus();
                String stText = st == 1 ? "通过" : (st == 2 ? "驳回" : "待审核");
                String stBadge = st == 1 ? "bg-success" : (st == 2 ? "bg-danger" : "bg-warning text-dark");
    %>
    <tr>
        <td><%=a.getId()%></td>
        <td><%=a.getUsername() == null ? ("ID:" + a.getUserId()) : a.getUsername()%></td>
        <td><%=a.getEventName() == null ? ("ID:" + a.getEventId()) : a.getEventName()%></td>
        <td><%=a.getDepartment()%></td>
        <td><%=a.getName()%></td>
        <td><%=a.getGender()%></td>
        <td><span class="badge <%=stBadge%>"><%=stText%></span></td>
        <td>
            <a href="${pageContext.request.contextPath}/athleteServlet?op=review&id=<%=a.getId()%>&status=1" class="btn btn-sm btn-success">通过</a>
            <a href="${pageContext.request.contextPath}/athleteServlet?op=review&id=<%=a.getId()%>&status=2" class="btn btn-sm btn-warning">驳回</a>
            <a href="${pageContext.request.contextPath}/athleteServlet?op=del&id=<%=a.getId()%>" onclick="return confirm('确定删除？')" class="btn btn-sm btn-danger">删除</a>
        </td>
    </tr>
    <%}}%>
    </tbody>
</table>
</div></div>
</div>
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/athleteServlet?op=add" method="post" onsubmit="return checkAth()">
                <div class="modal-header"><h5 class="modal-title">新增运动员报名</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>运动员账号</label>
                        <select class="form-select" name="user_id">
                            <%
                                List<Map<String, Object>> users = (List<Map<String, Object>>) request.getAttribute("userOptions");
                                if (users != null) {
                                    for (Map<String, Object> u : users) {
                            %>
                            <option value="<%=u.get("id")%>"><%=u.get("username")%></option>
                            <%}}%>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>报名赛事</label>
                        <select class="form-select" name="event_id">
                            <%
                                List<Map<String, Object>> events = (java.util.List<Map<String, Object>>) request.getAttribute("eventOptions");
                                if (events != null) {
                                    for (Map<String, Object> e : events) {
                            %>
                            <option value="<%=e.get("id")%>"><%=e.get("name")%></option>
                            <%}}%>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>院系</label>
                        <input type="text" class="form-control" name="department" placeholder="如：计算机学院">
                    </div>
                    <div class="mb-3">
                        <label>姓名</label>
                        <input type="text" class="form-control" name="name" id="aname">
                    </div>
                    <div class="mb-3">
                        <label>性别</label>
                        <select class="form-select" name="gender">
                            <option value="男">男</option>
                            <option value="女">女</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">提交</button>
                </div>
            </form>
        </div>
    </div>
</div>
<script>
    function checkAth() {
        let n = document.getElementById("aname").value.trim();
        if (n == "") {
            alert("运动员姓名不能为空");
            return false;
        }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
