<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html lang="zh-CN">
<head>
    <title>我的参赛成绩 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%
    // 纯视图：数据由 myScoreServlet 查询后传入
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<div class="section-title">我的参赛成绩（<%=loginUser.getUsername()%>）</div>
<%
    List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("scoreRows");
    if (rows == null || rows.isEmpty()) {
%>
<div class="g-card"><div class="g-card-body text-center text-muted" style="padding:40px">暂无参赛成绩记录</div></div>
<%
    } else {
        Object curEvent = null;
        Object curItem = null;
        boolean cardOpen = false;
        boolean dividerShown = false;
        for (Map<String, Object> s : rows) {
            String evName = s.get("eventName") == null ? "未关联赛事" : String.valueOf(s.get("eventName"));
            String itemName = s.get("itemName") == null ? "未知项目" : String.valueOf(s.get("itemName"));
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
                curItem = itemName; cardOpen = true; dividerShown = false;
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
                <thead>
                <tr><th style="width:70px">排名</th><th>成绩</th><th>状态</th><th>录入时间</th></tr>
                </thead>
                <tbody>
<%
            }
            int foul = (Integer) s.get("isFoul");
            int fin = (Integer) s.get("isFinished");
            boolean invalid = foul == 1 || fin == 0;
            if (invalid && !dividerShown) {
                dividerShown = true;
%>
                <tr class="invalid-divider"><td colspan="4">— 以下成绩犯规 / 未完成，不参与排名 —</td></tr>
<%
            }
            Integer rk = (Integer) s.get("rank");
%>
                <tr class="<%=invalid ? "row-invalid" : (rk != null && rk == 1 ? "row-champ" : "")%>">
                    <td class="rank-cell">
                        <% if (invalid || rk == null) { %>
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
                        <span class="score-val"><%=s.get("value")%></span>
                        <span class="unit-sub"><%=s.get("unit")%></span>
                        <% if (Integer.valueOf(1).equals(s.get("isRecord")) && !invalid) { %>
                            <span class="badge bg-danger">破纪录</span>
                        <% } %>
                    </td>
                    <td>
                        <% if (foul == 1) { %><span class="badge bg-danger">犯规</span><% }
                           else if (fin == 0) { %><span class="badge bg-secondary-soft">未完成</span><% }
                           else { %><span class="badge bg-success">有效</span><% } %>
                    </td>
                    <td class="text-muted" style="font-size:12.5px"><%=s.get("createTime")%></td>
                </tr>
<%
        }
        if (cardOpen) { %></tbody></table></div></div><% }
%>
    </div>
</div>
<%
    }
%>
</div>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
