<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.Event" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html lang="zh-CN">
<head>
    <title>赛事报名 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
    <script>
        function checkApply() {
            let n = document.getElementById("aname").value.trim();
            if (n == "") { alert("请填写真实姓名"); return false; }
            return true;
        }
    </script>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<%
    String msg = (String) request.getAttribute("msg");
    if (msg != null) {
%>
    <div class="alert alert-info"><%=msg%></div>
<%}%>

<div class="g-card mb-4">
    <div class="g-card-head"><span class="bar"></span><h5>📝 我要报名</h5></div>
    <div class="g-card-body">
        <form action="${pageContext.request.contextPath}/applyServlet?op=add" method="post" onsubmit="return checkApply()" class="row g-3">
            <div class="col-md-3">
                <label>选择赛事</label>
                <select class="form-select" name="event_id" required>
                    <%
                        List<Event> events = (List<Event>) request.getAttribute("eventList");
                        if (events != null) {
                            for (Event e : events) {
                    %>
                    <option value="<%=e.getId()%>"><%=e.getName()%>（<%=e.getStartDate()%> ~ <%=e.getEndDate()%>）</option>
                    <%}}%>
                </select>
            </div>
            <div class="col-md-3">
                <label>院系</label>
                <input type="text" class="form-control" name="department" placeholder="如：计算机学院" required>
            </div>
            <div class="col-md-3">
                <label>真实姓名</label>
                <input type="text" class="form-control" name="name" id="aname" required>
            </div>
            <div class="col-md-2">
                <label>性别</label>
                <select class="form-select" name="gender">
                    <option value="男">男</option>
                    <option value="女">女</option>
                </select>
            </div>
            <div class="col-md-1 align-self-end">
                <button type="submit" class="btn btn-primary">报名</button>
            </div>
        </form>
    </div>
</div>

<div class="section-title">我的报名记录</div>
<div class="g-card"><div class="g-card-body">
<table class="table table-striped">
    <thead>
    <tr>
        <th>赛事</th>
        <th>院系</th>
        <th>姓名</th>
        <th>性别</th>
        <th>资格审查</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Map<String, Object>> myApplies = (List<Map<String, Object>>) request.getAttribute("myApplies");
        if (myApplies != null && !myApplies.isEmpty()) {
            for (Map<String, Object> a : myApplies) {
                int st = (Integer) a.get("status");
                String stText = st == 1 ? "通过" : (st == 2 ? "驳回" : "待审核");
                String stBadge = st == 1 ? "bg-success" : (st == 2 ? "bg-danger" : "bg-warning text-dark");
    %>
    <tr>
        <td><%=a.get("eventName")%></td>
        <td><%=a.get("department")%></td>
        <td><%=a.get("name")%></td>
        <td><%=a.get("gender")%></td>
        <td><span class="badge <%=stBadge%>"><%=stText%></span></td>
        <td>
            <a href="${pageContext.request.contextPath}/applyServlet?op=cancel&id=<%=a.get("id")%>" onclick="return confirm('确定取消报名？')" class="btn btn-sm btn-danger">取消报名</a>
        </td>
    </tr>
    <%
            }
        } else {
    %>
    <tr><td colspan="6" class="text-center text-muted">还没有报名任何赛事</td></tr>
    <%}%>
    </tbody>
</table>
</div></div>
</div>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
