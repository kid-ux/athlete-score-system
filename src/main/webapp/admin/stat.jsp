<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html lang="zh-CN">
<head>
    <title>多维成绩统计 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">

<div class="section-title">按项目 × 院系统计参赛人数、最好成绩</div>
<div class="g-card mb-4"><div class="g-card-body">
<table class="table table-striped">
    <thead>
    <tr>
        <th>项目名称</th>
        <th>院系</th>
        <th>参赛人数</th>
        <th>最好成绩</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Map<String, Object>> statList = (List<Map<String, Object>>) request.getAttribute("statList");
        if (statList != null && !statList.isEmpty()) {
            for (Map<String, Object> row : statList) {
    %>
    <tr>
        <td><%=row.get("itemName")%></td>
        <td><%=row.get("dept")%></td>
        <td><%=row.get("countNum")%></td>
        <td class="score-val"><%=row.get("bestScore") == null ? "-" : row.get("bestScore")%></td>
    </tr>
    <%
            }
        } else {
    %>
    <tr><td colspan="4" class="text-center text-muted">暂无统计数据</td></tr>
    <%}%>
    </tbody>
</table>
</div></div>

<div class="section-title">按项目 × 性别统计参赛人数、最好成绩</div>
<div class="g-card mb-4"><div class="g-card-body">
<table class="table table-striped">
    <thead>
    <tr>
        <th>项目名称</th>
        <th>性别</th>
        <th>参赛人数</th>
        <th>最好成绩</th>
    </tr>
    </thead>
    <tbody>
    <%
        List<Map<String, Object>> genderStatList = (List<Map<String, Object>>) request.getAttribute("genderStatList");
        if (genderStatList != null && !genderStatList.isEmpty()) {
            for (Map<String, Object> row : genderStatList) {
    %>
    <tr>
        <td><%=row.get("itemName")%></td>
        <td><%=row.get("gender")%></td>
        <td><%=row.get("countNum")%></td>
        <td class="score-val"><%=row.get("bestScore") == null ? "-" : row.get("bestScore")%></td>
    </tr>
    <%
            }
        } else {
    %>
    <tr><td colspan="4" class="text-center text-muted">暂无统计数据</td></tr>
    <%}%>
    </tbody>
</table>
</div></div>

<div class="section-title">统计图表</div>
<div class="row">
    <div class="col-md-7 mb-3">
        <div class="g-card">
            <div class="g-card-head"><span class="bar"></span><h5>各院系有效成绩数量</h5></div>
            <div class="g-card-body"><canvas id="deptChart"></canvas></div>
        </div>
    </div>
    <div class="col-md-5 mb-3">
        <div class="g-card">
            <div class="g-card-head"><span class="bar"></span><h5>报名运动员男女比例</h5></div>
            <div class="g-card-body"><canvas id="genderChart"></canvas></div>
        </div>
    </div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    Chart.defaults.color = '#6b7382';
    Chart.defaults.borderColor = 'rgba(21,24,30,.08)';
    new Chart(document.getElementById('deptChart'), {
        type: 'bar',
        data: {
            labels: [<%=request.getAttribute("deptLabels")%>],
            datasets: [{
                label: '有效成绩数',
                data: [<%=request.getAttribute("deptCounts")%>],
                backgroundColor: 'rgba(21, 24, 30, 0.8)',
                borderColor: '#15181e',
                borderWidth: 1,
                borderRadius: 4
            }]
        },
        options: {scales: {y: {beginAtZero: true, ticks: {precision: 0}}}}
    });
    new Chart(document.getElementById('genderChart'), {
        type: 'pie',
        data: {
            labels: [<%=request.getAttribute("genderLabels")%>],
            datasets: [{
                data: [<%=request.getAttribute("genderCounts")%>],
                backgroundColor: ['rgba(21, 24, 30, 0.85)', 'rgba(122, 130, 143, 0.85)', 'rgba(182, 189, 203, 0.9)'],
                borderColor: '#ffffff'
            }]
        }
    });
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
