<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="bean.SportItem" %>
<html lang="zh-CN">
<head>
    <title>编辑项目 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<%
    SportItem item = (SportItem) request.getAttribute("item");
    List<Map<String, Object>> eventOptions = (List<Map<String, Object>>) request.getAttribute("eventOptions");
%>
<div class="g-card" style="max-width:560px">
    <div class="g-card-head"><span class="bar"></span><h4>编辑项目</h4></div>
    <div class="g-card-body">
        <form action="${pageContext.request.contextPath}/itemServlet?op=update" method="post" onsubmit="return checkItem()">
            <input type="hidden" name="id" value="<%=item.getId()%>">
            <div class="mb-3">
                <label>所属赛事</label>
                <select class="form-select" name="event_id">
                    <%
                        if (eventOptions != null) {
                            for (Map<String, Object> e : eventOptions) {
                    %>
                    <option value="<%=e.get("id")%>" <%=e.get("id").equals(item.getEventId()) ? "selected" : ""%>><%=e.get("name")%></option>
                    <%}}%>
                </select>
            </div>
            <div class="mb-3">
                <label>项目名称</label>
                <input type="text" class="form-control" name="name" id="iname" value="<%=item.getName()%>">
            </div>
            <div class="mb-3">
                <label>单位</label>
                <input type="text" class="form-control" name="unit" value="<%=item.getUnit() == null ? "" : item.getUnit()%>">
            </div>
            <div class="mb-3">
                <label>成绩类型</label>
                <select class="form-select" name="record_type">
                    <option value="time" <%="time".equals(item.getRecordType()) ? "selected" : ""%>>time（计时，越小越好）</option>
                    <option value="distance" <%="distance".equals(item.getRecordType()) ? "selected" : ""%>>distance（距离/高度，越大越好）</option>
                </select>
            </div>
            <div class="mb-3">
                <label>性别限制</label>
                <select class="form-select" name="gender">
                    <option value="男" <%="男".equals(item.getGender()) ? "selected" : ""%>>男</option>
                    <option value="女" <%="女".equals(item.getGender()) ? "selected" : ""%>>女</option>
                    <option value="不限" <%="不限".equals(item.getGender()) ? "selected" : ""%>>不限</option>
                </select>
            </div>
            <button class="btn btn-primary">保存修改</button>
            <a href="${pageContext.request.contextPath}/itemServlet?op=list" class="btn btn-secondary">返回列表</a>
        </form>
    </div>
</div>
</div>
<script>
    function checkItem() {
        let n = document.getElementById("iname").value.trim();
        if (n == "") { alert("项目名称不能为空"); return false; }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
