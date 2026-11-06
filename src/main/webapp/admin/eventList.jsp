<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="bean.Event" %>
<html lang="zh-CN">
<head>
    <title>赛事管理 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<div class="toolbar">
    <div class="section-title" style="margin:0">赛事管理</div>
    <div class="spacer"></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">＋ 新增赛事</button>
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
        <th>赛事名称</th>
        <th>开始日期</th>
        <th>结束日期</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Event> list = (List<Event>) request.getAttribute("eventList");
        if (list != null) {
            for (Event e : list) {
    %>
    <tr>
        <td><%=e.getId()%></td>
        <td><%=e.getName()%></td>
        <td><%=e.getStartDate()%></td>
        <td><%=e.getEndDate()%></td>
        <td>
            <a href="${pageContext.request.contextPath}/eventServlet?op=toUpdate&id=<%=e.getId()%>" class="btn btn-sm btn-warning">编辑</a>
            <a href="${pageContext.request.contextPath}/eventServlet?op=del&id=<%=e.getId()%>" onclick="return confirm('确定删除？')" class="btn btn-sm btn-danger">删除</a>
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
            <form action="${pageContext.request.contextPath}/eventServlet?op=add" method="post" onsubmit="return checkEvent()">
                <div class="modal-header"><h5 class="modal-title">新增赛事</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>赛事名称</label>
                        <input type="text" class="form-control" name="name" id="ename">
                    </div>
                    <div class="mb-3">
                        <label>开始日期</label>
                        <input type="date" class="form-control" name="start_date" required>
                    </div>
                    <div class="mb-3">
                        <label>结束日期</label>
                        <input type="date" class="form-control" name="end_date" required>
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
    function checkEvent() {
        let n = document.getElementById("ename").value.trim();
        if (n == "") {
            alert("赛事名称不能为空");
            return false;
        }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
