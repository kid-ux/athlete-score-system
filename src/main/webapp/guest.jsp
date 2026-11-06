<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="bean.Event" %>
<html lang="zh-CN">
<head>
    <title>游客浏览 · 校运会成绩管理系统</title>
    <%@ include file="common/style.jspf" %>
</head>
<body>
<%@ include file="common/navbar.jspf" %>
<div class="container page-wrap">

    <div class="section-title">赛事信息公开浏览</div>

    <ul class="nav nav-tabs" id="guestTab" role="tablist">
        <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#pane-event" type="button">赛事信息</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#pane-item" type="button">参赛项目</button></li>
        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#pane-score" type="button">成绩与排名</button></li>
    </ul>
    <div class="tab-shell">
        <div class="tab-content">
            <!-- 赛事信息 -->
            <div class="tab-pane fade show active" id="pane-event">
                <table class="table table-striped">
                    <thead><tr><th>赛事名称</th><th>开始日期</th><th>结束日期</th></tr></thead>
                    <tbody>
                    <%
                        List<Event> events = (List<Event>) request.getAttribute("eventList");
                        if (events != null && !events.isEmpty()) {
                            for (Event e : events) {
                    %>
                    <tr><td><%=e.getName()%></td><td><%=e.getStartDate()%></td><td><%=e.getEndDate()%></td></tr>
                    <%
                            }
                        } else {
                    %>
                    <tr><td colspan="3" class="text-center text-muted">暂无赛事信息</td></tr>
                    <%}%>
                    </tbody>
                </table>
            </div>
            <!-- 参赛项目 -->
            <div class="tab-pane fade" id="pane-item">
                <table class="table table-striped">
                    <thead><tr><th>所属赛事</th><th>项目名称</th><th>单位</th><th>成绩类型</th><th>性别限制</th></tr></thead>
                    <tbody>
                    <%
                        List<Map<String, Object>> items = (List<Map<String, Object>>) request.getAttribute("itemList");
                        if (items != null && !items.isEmpty()) {
                            for (Map<String, Object> it : items) {
                    %>
                    <tr>
                        <td><%=it.get("eventName")%></td>
                        <td><%=it.get("name")%></td>
                        <td><%=it.get("unit")%></td>
                        <td><%="time".equals(it.get("recordType")) ? "计时（越小越好）" : "距离/高度（越大越好）"%></td>
                        <td><%=it.get("gender")%></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr><td colspan="5" class="text-center text-muted">暂无参赛项目</td></tr>
                    <%}%>
                    </tbody>
                </table>
            </div>
            <!-- 成绩与排名：按赛事 -> 项目分榜展示（仅公布正常完赛成绩） -->
            <div class="tab-pane fade" id="pane-score">
                <%
                    List<Map<String, Object>> scores = (List<Map<String, Object>>) request.getAttribute("scoreList");
                    if (scores != null && !scores.isEmpty()) {
                        Object curEvent = null;
                        Object curItem = null;
                        boolean cardOpen = false;
                        for (Map<String, Object> s : scores) {
                            String evName = String.valueOf(s.get("eventName"));
                            String itemName = String.valueOf(s.get("itemName"));
                            // ===== 赛事分组 =====
                            if (!evName.equals(curEvent)) {
                                if (cardOpen) { %></tbody></table></div></div><% cardOpen = false; }
                                if (curEvent != null) { %></div></div><% }
                                curEvent = evName; curItem = null;
                %>
                <div class="event-block">
                    <div class="event-head">
                        <h3><%=evName%></h3>
                        <span class="dates"><%=s.get("startDate") == null ? "" : s.get("startDate")%></span>
                    </div>
                    <div class="lb-grid">
                <%
                            }
                            // ===== 项目分榜 =====
                            if (curItem == null || !itemName.equals(curItem)) {
                                if (cardOpen) { %></tbody></table></div></div><% }
                                curItem = itemName; cardOpen = true;
                                String rt = String.valueOf(s.get("recordType"));
                %>
                        <div class="g-card lb-card">
                            <div class="lb-head">
                                <b class="lb-name"><%=itemName%></b>
                                <span class="meta-tag"><%="time".equals(rt) ? "计时 · 越小越好" : "距离/高度 · 越大越好"%></span>
                                <span class="meta-tag">单位：<%=s.get("unit")%></span>
                            </div>
                            <div class="table-responsive">
                            <table class="table mb-0">
                                <thead><tr><th style="width:70px">排名</th><th>运动员</th><th>成绩</th></tr></thead>
                                <tbody>
                <%
                            }
                            Integer rk = (Integer) s.get("rank");
                %>
                                <tr class="<%=rk != null && rk == 1 ? "row-champ" : ""%>">
                                    <td class="rank-cell">
                                        <% if (rk == null) { %>
                                            <span class="rank-none">—</span>
                                        <% } else if (rk == 1) { %>
                                            <span class="medal m1">1</span>
                                        <% } else if (rk == 2) { %>
                                            <span class="medal m2">2</span>
                                        <% } else if (rk == 3) { %>
                                            <span class="medal m3">3</span>
                                        <% } else { %>
                                            <span class="medal mn"><%=rk%></span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <b><%=s.get("athleteName")%></b>
                                        <div class="cell-sub"><%=s.get("department")%> · <%=s.get("gender")%></div>
                                    </td>
                                    <td>
                                        <span class="score-val"><%=s.get("value")%></span>
                                        <span class="unit-sub"><%=s.get("unit")%></span>
                                        <% if (Integer.valueOf(1).equals(s.get("isRecord"))) { %>
                                            <span class="badge bg-danger">破纪录</span>
                                        <% } %>
                                    </td>
                                </tr>
                <%
                        }
                        if (cardOpen) { %></tbody></table></div></div><% }
                %>
                    </div>
                </div>
                <%
                    } else {
                %>
                <div class="text-center text-muted">暂无已公布的成绩</div>
                <%}%>
            </div>
        </div>
    </div>
</div>
<%@ include file="common/scripts.jspf" %>
</body>
</html>
