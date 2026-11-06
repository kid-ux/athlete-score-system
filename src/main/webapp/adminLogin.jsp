<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="zh-CN">
<head>
    <title>管理员登录 · 校运会成绩管理系统</title>
    <%@ include file="common/style.jspf" %>
    <script>
        // JavaScript 表单有效性验证
        function checkLogin() {
            let u = document.getElementById("uname").value.trim();
            let p = document.getElementById("pwd").value;
            if (u == "") { alert("用户名不能为空"); return false; }
            if (p == "") { alert("密码不能为空"); return false; }
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
                <circle cx="12" cy="14.5" r="5.6" fill="#15181e"/>
                <circle cx="12" cy="14.5" r="5.6" stroke="#6b7382" stroke-width="1.4"/>
                <path d="M12 11.6l.9 1.8 2 .3-1.45 1.4.35 2-1.8-.95-1.8.95.35-2-1.45-1.4 2-.3z" fill="#fff"/>
            </svg>
        </div>
        <h3>后台管理端登录</h3>
        <div class="sub">管理员 / 裁判专用入口</div>
        <%
            String msg = (String) request.getAttribute("msg");
            if (msg != null) {
        %>
            <div class="alert alert-danger"><%=msg%></div>
            <script>
                // 登录失败：延迟3秒后自动返回管理员登录界面
                setTimeout(function () {
                    window.location.href = "adminLogin.jsp";
                }, 3000);
            </script>
        <%}%>
        <form action="loginServlet" method="post" onsubmit="return checkLogin()">
            <input type="hidden" name="portal" value="admin">
            <div class="mb-3">
                <label>管理员账号</label>
                <input type="text" class="form-control" name="username" id="uname" placeholder="请输入管理员账号">
            </div>
            <div class="mb-3">
                <label>密码</label>
                <input type="password" class="form-control" name="password" id="pwd" placeholder="请输入密码">
            </div>
            <div class="d-grid gap-2 mt-4">
                <button type="submit" class="btn btn-danger">进入后台</button>
                <a href="login.jsp" class="btn btn-outline-secondary">返回前台登录</a>
            </div>
        </form>
    </div>
</div>
<%@ include file="common/scripts.jspf" %>
</body>
</html>
