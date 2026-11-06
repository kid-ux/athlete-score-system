<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="bean.Score" %>
<html lang="zh-CN">
<head>
    <title>编辑成绩 · 校运会成绩管理系统</title>
    <%@ include file="../common/style.jspf" %>
</head>
<body>
<%@ include file="../common/navbar.jspf" %>
<div class="container page-wrap">
<%
    Score s = (Score) request.getAttribute("score");
    List<Map<String, Object>> items = (List<Map<String, Object>>) request.getAttribute("itemOptions");
    List<Map<String, Object>> aths = (List<Map<String, Object>>) request.getAttribute("athleteOptions");
%>
<div class="g-card" style="max-width:560px">
    <div class="g-card-head"><span class="bar"></span><h4>编辑成绩 #<%=s.getId()%></h4></div>
    <div class="g-card-body">
        <form action="${pageContext.request.contextPath}/scoreServlet?op=update" method="post" onsubmit="return checkEdit()">
            <input type="hidden" name="id" value="<%=s.getId()%>">
            <div class="mb-3">
                <label>比赛项目</label>
                <select class="form-select" name="item_id">
                    <%
                        if (items != null) {
                            for (Map<String, Object> it : items) {
                    %>
                    <option value="<%=it.get("id")%>" <%=it.get("id").equals(s.getItemId()) ? "selected" : ""%>><%=it.get("name")%></option>
                    <%}}%>
                </select>
            </div>
            <div class="mb-3">
                <label>运动员</label>
                <select class="form-select" name="athlete_id">
                    <%
                        if (aths != null) {
                            for (Map<String, Object> a : aths) {
                    %>
                    <option value="<%=a.get("id")%>" <%=a.get("id").equals(s.getAthleteId()) ? "selected" : ""%>><%=a.get("name")%>（<%=a.get("department")%>）</option>
                    <%}}%>
                </select>
            </div>
            <div class="mb-3">
                <label>成绩数值</label>
                <input type="number" step="0.01" class="form-control" name="value" id="eval_" value="<%=s.getValue()%>">
            </div>
            <div class="mb-3">
                <label>单位</label>
                <input type="text" class="form-control" name="unit" value="<%=s.getUnit() == null ? "" : s.getUnit()%>">
            </div>
            <div class="mb-3">
                <label>是否犯规</label>
                <select class="form-select" name="is_foul">
                    <option value="0" <%=s.getIsFoul() == 0 ? "selected" : ""%>>否</option>
                    <option value="1" <%=s.getIsFoul() == 1 ? "selected" : ""%>>是</option>
                </select>
            </div>
            <div class="mb-3">
                <label>是否完成比赛</label>
                <select class="form-select" name="is_finished">
                    <option value="1" <%=s.getIsFinished() == 1 ? "selected" : ""%>>是</option>
                    <option value="0" <%=s.getIsFinished() == 0 ? "selected" : ""%>>否</option>
                </select>
            </div>
            <button class="btn btn-primary">保存修改（保存后自动重排名）</button>
            <a href="${pageContext.request.contextPath}/scoreServlet?op=list" class="btn btn-secondary">返回列表</a>
        </form>
    </div>
</div>
</div>
<script>
    function checkEdit() {
        let v = parseFloat(document.getElementById("eval_").value);
        if (isNaN(v) || v < 0) { alert("成绩必须是大于等于0的数字"); return false; }
        return true;
    }
</script>
<%@ include file="../common/scripts.jspf" %>
</body>
</html>
