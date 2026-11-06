<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.User" %>
<html lang="zh-CN">
<head>
    <title>首页 · 校运会成绩管理系统</title>
    <%@ include file="common/style.jspf" %>
</head>
<body>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isAdmin = "admin".equals(loginUser.getRole());
    request.setAttribute("bgDensity", "high");
%>
<%@ include file="common/navbar.jspf" %>
<div class="container page-wrap">
    <div class="hero">
        <h1><%=isAdmin ? "管理" : "运动员"%><span class="hl">控制台</span></h1>
        <p><%=loginUser.getUsername()%> · <%=isAdmin ? "管理赛事、项目、报名与成绩，实时自动排名" : "报名参加校内赛事，随时查看个人成绩与排名"%></p>
    </div>

    <% if (isAdmin) { %>
    <div class="menu-grid">
        <a class="menu-tile" href="eventServlet?op=list">
            <span class="num">01</span>
            <span><b>赛事管理</b><small>创建与维护运动会赛事信息</small></span>
        </a>
        <a class="menu-tile cyan" href="itemServlet?op=list">
            <span class="num">02</span>
            <span><b>项目管理</b><small>设置项目单位、类型与性别限制</small></span>
        </a>
        <a class="menu-tile green" href="athleteServlet?op=list">
            <span class="num">03</span>
            <span><b>运动员管理</b><small>报名登记与资格审查</small></span>
        </a>
        <a class="menu-tile violet" href="scoreServlet?op=list">
            <span class="num">04</span>
            <span><b>成绩管理</b><small>成绩录入、犯规标记与自动排名</small></span>
        </a>
        <a class="menu-tile cyan" href="statServlet">
            <span class="num">05</span>
            <span><b>多维统计</b><small>按项目 / 院系 / 性别聚合统计</small></span>
        </a>
        <a class="menu-tile green" href="queryServlet">
            <span class="num">06</span>
            <span><b>综合查询</b><small>赛事、项目、运动员、成绩组合查询</small></span>
        </a>
    </div>
    <% } else { %>
    <div class="menu-grid">
        <a class="menu-tile" href="applyServlet">
            <span class="num">01</span>
            <span><b>赛事报名</b><small>选择赛事提交报名，等待资格审查</small></span>
        </a>
        <a class="menu-tile cyan" href="myScoreServlet">
            <span class="num">02</span>
            <span><b>我的成绩</b><small>按项目查看个人成绩与排名</small></span>
        </a>
        <a class="menu-tile green" href="queryServlet">
            <span class="num">03</span>
            <span><b>综合查询</b><small>按项目、性别、成绩区间等条件查询</small></span>
        </a>
        <a class="menu-tile violet" href="guestServlet">
            <span class="num">04</span>
            <span><b>游客浏览</b><small>浏览全部赛事、项目与已公布排名</small></span>
        </a>
    </div>
    <% } %>
</div>
<%@ include file="common/scripts.jspf" %>
</body>
</html>
