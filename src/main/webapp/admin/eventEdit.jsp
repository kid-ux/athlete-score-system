<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.Event" %>
<html lang="zh-CN">
<head>
    <title>编辑赛事 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<%
    Event e = (Event) request.getAttribute("event");
%>
<div class="g-card" style="max-width:560px">
    <div class="g-card-head"><span class="bar"></span><h4>编辑赛事</h4></div>
    <div class="g-card-body">
        <form action="${pageContext.request.contextPath}/eventServlet?op=update" method="post">
            <input type="hidden" name="id" value="<%=e.getId()%>">
            <div class="mb-3">
                <label>赛事名称</label>
                <input type="text" class="form-control" name="name" value="<%=e.getName()%>">
            </div>
            <div class="mb-3">
                <label>开始日期</label>
                <input type="date" class="form-control" name="start_date" value="<%=e.getStartDate()%>">
            </div>
            <div class="mb-3">
                <label>结束日期</label>
                <input type="date" class="form-control" name="end_date" value="<%=e.getEndDate()%>">
            </div>
            <button class="btn btn-primary">保存修改</button>
            <a href="${pageContext.request.contextPath}/eventServlet?op=list" class="btn btn-secondary">返回列表</a>
        </form>
    </div>
</div>
</div>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
