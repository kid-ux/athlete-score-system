<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="bean.SportItem" %>
<html lang="zh-CN">
<head>
    <title>运动项目管理 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<div class="toolbar">
    <div class="section-title" style="margin:0">运动项目管理</div>
    <div class="spacer"></div>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">＋ 新增项目</button>
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
        <th>所属赛事</th>
        <th>项目名称</th>
        <th>单位</th>
        <th>成绩类型</th>
        <th>性别限制</th>
        <th>操作</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<SportItem> list = (List<SportItem>) request.getAttribute("itemList");
        if (list != null) {
            for (SportItem item : list) {
    %>
    <tr>
        <td><%=item.getId()%></td>
        <td><%=item.getEventName() == null ? ("ID:" + item.getEventId()) : item.getEventName()%></td>
        <td><%=item.getName()%></td>
        <td><%=item.getUnit()%></td>
        <td><%="time".equals(item.getRecordType()) ? "计时（越小越好）" : "距离/高度（越大越好）"%></td>
        <td><%=item.getGender()%></td>
        <td>
            <a href="${pageContext.request.contextPath}/itemServlet?op=toUpdate&id=<%=item.getId()%>" class="btn btn-sm btn-warning">编辑</a>
            <a href="${pageContext.request.contextPath}/itemServlet?op=del&id=<%=item.getId()%>" onclick="return confirm('确定删除？')" class="btn btn-sm btn-danger">删除</a>
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
            <form action="${pageContext.request.contextPath}/itemServlet?op=add" method="post" onsubmit="return checkItem()">
                <div class="modal-header"><h5 class="modal-title">新增项目</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>所属赛事</label>
                        <select class="form-select" name="event_id">
                            <%
                                java.util.List<java.util.Map<String, Object>> eventOptions =
                                        (java.util.List<java.util.Map<String, Object>>) request.getAttribute("eventOptions");
                                if (eventOptions != null) {
                                    for (java.util.Map<String, Object> e : eventOptions) {
                            %>
                            <option value="<%=e.get("id")%>"><%=e.get("name")%></option>
                            <%}}%>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>项目名称</label>
                        <input type="text" class="form-control" name="name" id="iname">
                    </div>
                    <div class="mb-3">
                        <label>单位</label>
                        <input type="text" class="form-control" name="unit">
                    </div>
                    <div class="mb-3">
                        <label>成绩类型 time计时(越小越好)/distance距离(越大越好)</label>
                        <select class="form-select" name="record_type">
                            <option value="time">time</option>
                            <option value="distance">distance</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>性别</label>
                        <select class="form-select" name="gender">
                            <option value="男">男</option>
                            <option value="女">女</option>
                            <option value="不限">不限</option>
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
    function checkItem() {
        let n = document.getElementById("iname").value.trim();
        if (n == "") {
            alert("项目名称不能为空");
            return false;
        }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
