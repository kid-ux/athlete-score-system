<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="zh-CN">
<head>
    <title>运动员注册 · 校运会成绩管理系统</title>
    <%@ include file="common/style.jspf" %>
    <script>
        function checkReg() {
            let u = document.getElementById("uname").value.trim();
            let p = document.getElementById("pwd").value;
            let p2 = document.getElementById("pwd2").value;
            if (u == "") { alert("用户名不能为空"); return false; }
            if (p.length < 6) { alert("密码至少6位"); return false; }
            if (p != p2) { alert("两次输入的密码不一致"); return false; }
            return true;
        }
    </script>
</head>
<body>
<canvas id="bg3d" data-density="high"></canvas>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="logo-zone">
            <svg width="62" height="62" viewBox="0 0 24 24" fill="none">
                <path d="M8 2.5l4 5.2 4-5.2" stroke="#6b7382" stroke-width="2" stroke-linecap="round"/>
                <circle cx="12" cy="14.5" r="5.6" fill="#2c313a"/>
                <circle cx="12" cy="14.5" r="5.6" stroke="#6b7382" stroke-width="1.4"/>
                <path d="M12 11.6l.9 1.8 2 .3-1.45 1.4.35 2-1.8-.95-1.8.95.35-2-1.45-1.4 2-.3z" fill="#fff"/>
            </svg>
        </div>
        <h3>运动员账号注册</h3>
        <div class="sub">注册后即可报名赛事、查看个人参赛成绩</div>
        <%
            String msg = (String) request.getAttribute("msg");
            if (msg != null) {
        %>
            <div class="alert alert-danger"><%=msg%></div>
        <%}%>
        <form action="registerServlet" method="post" onsubmit="return checkReg()">
            <div class="mb-3">
                <label>用户名</label>
                <input type="text" class="form-control" name="username" id="uname" placeholder="请设置用户名" required>
            </div>
            <div class="mb-3">
                <label>密码（至少6位）</label>
                <input type="password" class="form-control" name="password" id="pwd" placeholder="至少 6 位" required>
            </div>
            <div class="mb-3">
                <label>确认密码</label>
                <input type="password" class="form-control" name="password2" id="pwd2" placeholder="再次输入密码" required>
            </div>
            <div class="d-grid gap-2 mt-4">
                <button type="submit" class="btn btn-info">注 册</button>
                <a href="login.jsp" class="btn btn-outline-secondary">返回登录</a>
            </div>
        </form>
    </div>
</div>
<%@ include file="common/scripts.jspf" %>
</body>
</html>
