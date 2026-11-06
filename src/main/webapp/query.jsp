<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html lang="zh-CN">
<head>
    <title>综合查询 · 校运会成绩管理系统</title>
    <%@ include file="common/style.jspf" %>
    <script>
        // 按查询对象切换显示对应的条件区
        function switchType() {
            let t = document.getElementById("qtype").value;
            document.querySelectorAll(".cond").forEach(function (d) { d.style.display = "none"; });
            document.querySelectorAll(".cond-" + t).forEach(function (d) { d.style.display = ""; });
        }
        // JavaScript 有效性验证
        function checkQuery() {
            let t = document.getElementById("qtype").value;
            if (t == "score") {
                let minV = document.getElementById("min").value;
                let maxV = document.getElementById("max").value;
                if (minV != "" && maxV != "" && parseFloat(minV) > parseFloat(maxV)) {
                    alert("成绩下限不能大于上限");
                    return false;
                }
            }
            if (t == "event") {
                let d1 = document.getElementById("date1").value;
                let d2 = document.getElementById("date2").value;
                if (d1 != "" && d2 != "" && d1 > d2) {
                    alert("开始日期不能晚于结束日期");
                    return false;
                }
            }
            return true;
        }
        window.onload = switchType;
    </script>
</head>
<body>
<%@ include file="common/navbar.jspf" %>
<div class="container page-wrap">
<%
    // 综合查询对游客、运动员、管理员全部开放（纯视图，数据由 queryServlet 提供）
    String type = request.getParameter("type");
    if (type == null || type.isEmpty()) type = "score";
    String kw = request.getParameter("kw");
    String kw2 = request.getParameter("kw2");
    String gender = request.getParameter("gender");
    String dept = request.getParameter("dept");
    String min = request.getParameter("min");
    String max = request.getParameter("max");
    String date1 = request.getParameter("date1");
    String date2 = request.getParameter("date2");
    String recordType = request.getParameter("record_type");
    String status = request.getParameter("status");
    String eventId = request.getParameter("event_id");
    List<Map<String, Object>> eventOpts = (List<Map<String, Object>>) request.getAttribute("eventOptions");
%>

<div class="g-card mb-4">
    <div class="g-card-head"><span class="bar"></span><h5>综合查询 <small class="text-muted">赛事 / 项目 / 运动员 / 成绩</small></h5></div>
    <div class="g-card-body">
        <form action="${pageContext.request.contextPath}/queryServlet" method="get" onsubmit="return checkQuery()" class="row g-3">
            <div class="col-auto">
                <label>查询对象</label>
                <select class="form-select" name="type" id="qtype" onchange="switchType()">
                    <option value="score" <%="score".equals(type) ? "selected" : ""%>>成绩</option>
                    <option value="event" <%="event".equals(type) ? "selected" : ""%>>赛事</option>
                    <option value="item" <%="item".equals(type) ? "selected" : ""%>>比赛项目</option>
                    <option value="athlete" <%="athlete".equals(type) ? "selected" : ""%>>运动员</option>
                </select>
            </div>
            <div class="col-auto cond cond-score cond-event cond-item">
                <label>名称关键词</label>
                <input type="text" class="form-control" name="kw" value="<%=kw == null ? "" : kw%>" placeholder="项目/赛事名称，模糊匹配">
            </div>
            <div class="col-auto cond cond-score cond-athlete" style="display:none">
                <label>运动员姓名</label>
                <input type="text" class="form-control" name="kw2" value="<%=kw2 == null ? "" : kw2%>" placeholder="如：张三">
            </div>
            <div class="col-auto cond cond-score cond-athlete">
                <label>性别</label>
                <select class="form-select" name="gender">
                    <option value="">全部</option>
                    <option value="男" <%="男".equals(gender) ? "selected" : ""%>>男</option>
                    <option value="女" <%="女".equals(gender) ? "selected" : ""%>>女</option>
                </select>
            </div>
            <div class="col-auto cond cond-score cond-athlete">
                <label>院系</label>
                <input type="text" class="form-control" name="dept" value="<%=dept == null ? "" : dept%>" placeholder="如：计算机学院">
            </div>
            <div class="col-auto cond cond-score">
                <label>成绩下限</label>
                <input type="number" step="0.01" class="form-control" name="min" id="min" value="<%=min == null ? "" : min%>">
            </div>
            <div class="col-auto cond cond-score">
                <label>成绩上限</label>
                <input type="number" step="0.01" class="form-control" name="max" id="max" value="<%=max == null ? "" : max%>">
            </div>
            <div class="col-auto cond cond-score align-self-end">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" name="includeInvalid" value="1" id="inv" <%="1".equals(request.getParameter("includeInvalid")) ? "checked" : ""%>>
                    <label class="form-check-label" for="inv">包含犯规/未完成记录</label>
                </div>
            </div>
            <div class="col-auto cond cond-event" style="display:none">
                <label>开始日期从</label>
                <input type="date" class="form-control" name="date1" id="date1" value="<%=date1 == null ? "" : date1%>">
            </div>
            <div class="col-auto cond cond-event" style="display:none">
                <label>到</label>
                <input type="date" class="form-control" name="date2" id="date2" value="<%=date2 == null ? "" : date2%>">
            </div>
            <div class="col-auto cond cond-item" style="display:none">
                <label>所属赛事</label>
                <select class="form-select" name="event_id">
                    <option value="">全部</option>
                    <%
                        if (eventOpts != null) {
                            for (Map<String, Object> eo : eventOpts) {
                    %>
                    <option value="<%=eo.get("id")%>" <%=String.valueOf(eo.get("id")).equals(eventId) ? "selected" : ""%>><%=eo.get("name")%></option>
                    <%}}%>
                </select>
            </div>
            <div class="col-auto cond cond-item" style="display:none">
                <label>成绩类型</label>
                <select class="form-select" name="record_type">
                    <option value="">全部</option>
                    <option value="time" <%="time".equals(recordType) ? "selected" : ""%>>计时（越小越好）</option>
                    <option value="distance" <%="distance".equals(recordType) ? "selected" : ""%>>距离/高度（越大越好）</option>
                </select>
            </div>
            <div class="col-auto cond cond-item" style="display:none">
                <label>性别限制</label>
                <select class="form-select" name="item_gender">
                    <option value="">全部</option>
                    <option value="男">男</option>
                    <option value="女">女</option>
                    <option value="不限">不限</option>
                </select>
            </div>
            <div class="col-auto cond cond-athlete" style="display:none">
                <label>审核状态</label>
                <select class="form-select" name="status">
                    <option value="">全部</option>
                    <option value="0" <%="0".equals(status) ? "selected" : ""%>>待审核</option>
                    <option value="1" <%="1".equals(status) ? "selected" : ""%>>通过</option>
                    <option value="2" <%="2".equals(status) ? "selected" : ""%>>驳回</option>
                </select>
            </div>
            <div class="col-auto align-self-end">
                <button type="submit" class="btn btn-primary">查 询</button>
            </div>
        </form>
    </div>
</div>

<%
    if ("score".equals(type) && request.getAttribute("scoreRows") != null) {
        List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("scoreRows");
%>
<div class="section-title" style="flex-wrap:wrap">成绩查询结果 <small class="text-muted" style="font-size:13px;font-weight:400;flex-basis:100%">按赛事 → 项目分榜；犯规/未完成不参与排名，默认不列出</small></div>
<%
        if (rows.isEmpty()) {
%>
<div class="g-card"><div class="g-card-body text-center text-muted" style="padding:30px">没有符合条件的记录</div></div>
<%
        } else {
            Object curEvent = null;
            Object curItem = null;
            boolean cardOpen = false;
            boolean dividerShown = false;
            for (Map<String, Object> s : rows) {
                String evName = s.get("eventName") == null ? "未关联赛事" : String.valueOf(s.get("eventName"));
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
                <thead><tr><th style="width:70px">排名</th><th>运动员</th><th>成绩</th><th>状态</th></tr></thead>
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
                        <b><%=s.get("aname") == null ? "已删除运动员" : s.get("aname")%></b>
                        <div class="cell-sub"><%=s.get("department") == null ? "" : s.get("department")%> · <%=s.get("gender") == null ? "" : s.get("gender")%></div>
                    </td>
                    <td>
                        <span class="score-val"><%=s.get("value")%></span>
                        <span class="unit-sub"><%=s.get("unit")%></span>
                        <% if (Integer.valueOf(1).equals(s.get("isRecord")) && !invalid) { %><span class="badge bg-danger">破纪录</span><% } %>
                    </td>
                    <td>
                        <% if (foul == 1) { %><span class="badge bg-danger">犯规</span><% }
                           else if (fin == 0) { %><span class="badge bg-secondary-soft">未完成</span><% }
                           else { %><span class="badge bg-success">有效</span><% } %>
                    </td>
                </tr>
<%
            }
            if (cardOpen) { %></tbody></table></div></div><% }
%>
    </div>
</div>
<%
        }
    } else if ("event".equals(type) && request.getAttribute("eventRows") != null) {
        List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("eventRows");
%>
<div class="section-title">赛事查询结果</div>
<div class="g-card"><div class="g-card-body">
<table class="table table-striped">
    <thead><tr><th>赛事名称</th><th>开始日期</th><th>结束日期</th></tr></thead>
    <tbody>
    <%
        for (Map<String, Object> e : rows) {
    %>
    <tr><td><%=e.get("name")%></td><td><%=e.get("startDate")%></td><td><%=e.get("endDate")%></td></tr>
    <%
        }
        if (rows.isEmpty()) out.print("<tr><td colspan='3' class='text-center text-muted'>没有符合条件的记录</td></tr>");
    %>
    </tbody>
</table>
</div></div>
<%
    } else if ("item".equals(type) && request.getAttribute("itemRows") != null) {
        List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("itemRows");
%>
<div class="section-title">比赛项目查询结果</div>
<div class="g-card"><div class="g-card-body">
<table class="table table-striped">
    <thead><tr><th>所属赛事</th><th>项目名称</th><th>单位</th><th>成绩类型</th><th>性别限制</th></tr></thead>
    <tbody>
    <%
        for (Map<String, Object> it : rows) {
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
        if (rows.isEmpty()) out.print("<tr><td colspan='5' class='text-center text-muted'>没有符合条件的记录</td></tr>");
    %>
    </tbody>
</table>
</div></div>
<%
    } else if ("athlete".equals(type) && request.getAttribute("athleteRows") != null) {
        List<Map<String, Object>> rows = (List<Map<String, Object>>) request.getAttribute("athleteRows");
%>
<div class="section-title">运动员查询结果</div>
<div class="g-card"><div class="g-card-body">
<table class="table table-striped">
    <thead><tr><th>姓名</th><th>院系</th><th>性别</th><th>报名赛事</th><th>审核状态</th></tr></thead>
    <tbody>
    <%
        for (Map<String, Object> a : rows) {
            int st = (Integer) a.get("status");
            String stText = st == 1 ? "通过" : (st == 2 ? "驳回" : "待审核");
            String stBadge = st == 1 ? "bg-success" : (st == 2 ? "bg-danger" : "bg-warning text-dark");
    %>
    <tr>
        <td><%=a.get("name")%></td>
        <td><%=a.get("department")%></td>
        <td><%=a.get("gender")%></td>
        <td><%=a.get("eventName")%></td>
        <td><span class="badge <%=stBadge%>"><%=stText%></span></td>
    </tr>
    <%
        }
        if (rows.isEmpty()) out.print("<tr><td colspan='5' class='text-center text-muted'>没有符合条件的记录</td></tr>");
    %>
    </tbody>
</table>
</div></div>
<%
    } else {
%>
<div class="text-muted text-center">选择查询对象和条件后点击查询</div>
<%}%>
</div>
<%@ include file="common/scripts.jspf" %>
</body>
</html>
