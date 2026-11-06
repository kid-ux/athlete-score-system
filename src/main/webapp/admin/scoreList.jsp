<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<html lang="zh-CN">
<head>
    <title>成绩管理 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<div class="toolbar">
    <div class="section-title" style="margin:0">成绩管理</div>
    <div class="spacer"></div>
    <a href="${pageContext.request.contextPath}/scoreServlet?op=rank" class="btn btn-success">⟳ 自动刷新排名</a>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">＋ 录入成绩</button>
</div>
<%
    Object recordMsg = request.getAttribute("recordMsg");
    if (recordMsg != null) {
%>
<div class="alert alert-danger"><b>破纪录！</b><%=recordMsg%></div>
<%}%>
<%
    Object scoreErr = request.getAttribute("scoreErr");
    if (scoreErr != null) {
%>
<div class="alert alert-warning"><b>录入失败：</b><%=scoreErr%></div>
<%}%>

<%
    List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("scoreList");
    if (list == null || list.isEmpty()) {
%>
<div class="g-card"><div class="g-card-body text-center text-muted" style="padding:40px">暂无成绩记录，点击右上角「录入成绩」开始登记</div></div>
<%
    } else {
        // 赛事筛选 pills（按列表中出现的赛事去重）
%>
<div class="filter-pills" id="eventPills">
    <button class="fp active" data-ev="all">全部赛事</button>
    <%
        Object lastEv = null;
        for (Map<String, Object> s : list) {
            Object ev = s.get("eventId");
            if (ev != null && !ev.equals(lastEv)) {
                lastEv = ev;
    %>
    <button class="fp" data-ev="<%=ev%>"><%=s.get("eventName")%></button>
    <%}}%>
</div>
<%
        Object curEvent = null;
        Object curItem = null;
        boolean cardOpen = false;   // 是否已打开项目榜卡片
        boolean dividerShown = false; // 当前项目内是否已输出"无效成绩"分隔行
        for (Map<String, Object> s : list) {
            Object evId = s.get("eventId");
            Object itId = s.get("itemId");
            // ===== 赛事分组 =====
            if (evId == null ? curEvent != null : !evId.equals(curEvent)) {
                if (cardOpen) { %></tbody></table></div></div><% cardOpen = false; }
                if (curEvent != null) { %></div></div><% } // 关闭上一赛事的 lb-grid 与 event-block
                curEvent = evId; curItem = null;
%>
<div class="event-block" data-ev="<%=evId == null ? "none" : evId%>">
    <div class="event-head">
        <h3><%=s.get("eventName") == null ? "未关联赛事" : s.get("eventName")%></h3>
        <span class="dates"><%=s.get("startDate") == null ? "" : s.get("startDate")%> ~ <%=s.get("endDate") == null ? "" : s.get("endDate")%></span>
    </div>
    <div class="lb-grid">
<%
            }
            // ===== 项目分榜 =====
            if (curItem == null || !itId.equals(curItem)) {
                if (cardOpen) { %></tbody></table></div></div><% }
                curItem = itId; cardOpen = true; dividerShown = false;
                String rt = String.valueOf(s.get("recordType"));
%>
        <div class="g-card lb-card">
            <div class="lb-head">
                <b class="lb-name"><%=s.get("itemName") == null ? ("项目ID:" + itId) : s.get("itemName")%></b>
                <span class="meta-tag"><%="time".equals(rt) ? "计时 · 越小越好" : "距离/高度 · 越大越好"%></span>
                <span class="meta-tag">单位：<%=s.get("unit")%></span>
                <% if (s.get("itemGender") != null && !"不限".equals(s.get("itemGender"))) { %>
                <span class="meta-tag">限<%=s.get("itemGender")%></span>
                <% } %>
            </div>
            <div class="table-responsive">
            <table class="table mb-0">
                <thead>
                <tr><th style="width:70px">排名</th><th>运动员</th><th>成绩</th><th>状态</th><th style="width:130px">操作</th></tr>
                </thead>
                <tbody>
<%
            }
            // ===== 成绩行 =====
            boolean invalid = (Integer) s.get("isFoul") == 1 || (Integer) s.get("isFinished") == 0;
            if (invalid && !dividerShown) {
                dividerShown = true;
%>
                <tr class="invalid-divider"><td colspan="5">— 以下成绩犯规 / 未完成，不参与排名 —</td></tr>
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
                        <b><%=s.get("athleteName") == null ? "已删除运动员" : s.get("athleteName")%></b>
                        <div class="cell-sub"><%=s.get("department") == null ? "" : s.get("department")%></div>
                    </td>
                    <td>
                        <span class="score-val"><%=s.get("value")%></span>
                        <span class="unit-sub"><%=s.get("unit")%></span>
                    </td>
                    <td>
                        <% if ((Integer) s.get("isRecord") == 1 && !invalid) { %><span class="badge bg-danger">破纪录</span><% } %>
                        <% if ((Integer) s.get("isFoul") == 1) { %><span class="badge bg-danger">犯规</span><% } %>
                        <% if ((Integer) s.get("isFinished") == 0) { %><span class="badge bg-secondary-soft">未完成</span><% } %>
                    </td>
                    <td>
                        <a href="${pageContext.request.contextPath}/scoreServlet?op=toUpdate&id=<%=s.get("id")%>" class="btn btn-sm btn-warning">编辑</a>
                        <a href="${pageContext.request.contextPath}/scoreServlet?op=del&id=<%=s.get("id")%>" onclick="return confirm('确定删除该成绩？')" class="btn btn-sm btn-danger">删除</a>
                    </td>
                </tr>
<%
        }
        if (cardOpen) { %></tbody></table></div></div><% } // 关闭最后一个项目卡
%>
    </div>
</div>
<%
    }
%>
</div>

<!-- 录入成绩弹窗：赛事 -> 项目 -> 运动员 三级联动，单位自动带出 -->
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="${pageContext.request.contextPath}/scoreServlet?op=add" method="post" onsubmit="return checkScore()">
                <div class="modal-header"><h5 class="modal-title">录入成绩</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label>所属赛事</label>
                        <select class="form-select" id="selEvent" onchange="onEventChange()">
                            <option value="">请选择赛事</option>
                            <%
                                List<Map<String, Object>> events = (List<Map<String, Object>>) request.getAttribute("eventOptions");
                                if (events != null) {
                                    for (Map<String, Object> e : events) {
                            %>
                            <option value="<%=e.get("id")%>"><%=e.get("name")%></option>
                            <%}}%>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>比赛项目 <span id="typeHint" class="text-muted"></span></label>
                        <select class="form-select" name="item_id" id="selItem" onchange="onItemChange()">
                            <option value="">请先选择赛事</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>运动员（仅列出资格审查通过的）</label>
                        <select class="form-select" name="athlete_id" id="selAth">
                            <option value="">请先选择赛事</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>成绩数值</label>
                        <input type="number" step="0.01" class="form-control" name="value" id="sval">
                    </div>
                    <div class="mb-3">
                        <label>单位（由项目自动带出，可改）</label>
                        <input type="text" class="form-control" name="unit" id="sunit">
                    </div>
                    <div class="mb-3">
                        <label>是否犯规</label>
                        <select class="form-select" name="is_foul">
                            <option value="0">否</option>
                            <option value="1">是</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>是否完成比赛</label>
                        <select class="form-select" name="is_finished">
                            <option value="1">是</option>
                            <option value="0">否</option>
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
    // 赛事筛选 pills
    document.querySelectorAll('#eventPills .fp').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('#eventPills .fp').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
            var ev = btn.getAttribute('data-ev');
            document.querySelectorAll('.event-block').forEach(function (blk) {
                blk.style.display = (ev === 'all' || blk.getAttribute('data-ev') === ev) ? '' : 'none';
            });
        });
    });

    // 联动数据（由 scoreServlet 查询后传入）
    var items = [
        <%
            List<Map<String, Object>> items = (List<Map<String, Object>>) request.getAttribute("itemOptions");
            if (items != null) {
                for (int i = 0; i < items.size(); i++) {
                    Map<String, Object> it = items.get(i);
        %>
        {id:<%=it.get("id")%>, eventId:<%=it.get("eventId")%>, name:"<%=it.get("name")%>", unit:"<%=it.get("unit") == null ? "" : it.get("unit")%>", recordType:"<%=it.get("recordType")%>"}<%=i < items.size() - 1 ? "," : ""%>
        <%}}%>
    ];
    var athletes = [
        <%
            List<Map<String, Object>> aths = (List<Map<String, Object>>) request.getAttribute("athleteOptions");
            if (aths != null) {
                for (int i = 0; i < aths.size(); i++) {
                    Map<String, Object> a = aths.get(i);
        %>
        {id:<%=a.get("id")%>, eventId:<%=a.get("eventId")%>, name:"<%=a.get("name")%>", dept:"<%=a.get("department") == null ? "" : a.get("department")%>"}<%=i < aths.size() - 1 ? "," : ""%>
        <%}}%>
    ];

    function onEventChange() {
        let eid = document.getElementById("selEvent").value;
        let selItem = document.getElementById("selItem");
        let selAth = document.getElementById("selAth");
        selItem.innerHTML = "<option value=''>请选择项目</option>";
        selAth.innerHTML = "<option value=''>请选择运动员</option>";
        if (eid == "") return;
        items.forEach(function (it) {
            if (it.eventId == eid) {
                selItem.innerHTML += "<option value='" + it.id + "'>" + it.name + "</option>";
            }
        });
        athletes.forEach(function (a) {
            if (a.eventId == eid) {
                selAth.innerHTML += "<option value='" + a.id + "'>" + a.name + "（" + a.dept + "）</option>";
            }
        });
        document.getElementById("sunit").value = "";
        document.getElementById("typeHint").innerText = "";
    }

    function onItemChange() {
        let iid = document.getElementById("selItem").value;
        items.forEach(function (it) {
            if (it.id == iid) {
                document.getElementById("sunit").value = it.unit;
                document.getElementById("typeHint").innerText =
                    it.recordType == "time" ? "（计时型：越小越好）" : "（距离/高度型：越大越好）";
            }
        });
    }

    // JavaScript 有效性验证
    function checkScore() {
        if (document.getElementById("selEvent").value == "") { alert("请选择赛事"); return false; }
        if (document.getElementById("selItem").value == "") { alert("请选择比赛项目"); return false; }
        if (document.getElementById("selAth").value == "") { alert("请选择运动员"); return false; }
        let v = parseFloat(document.getElementById("sval").value);
        if (isNaN(v) || v < 0) { alert("成绩必须是大于等于0的数字"); return false; }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
