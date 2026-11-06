package servlet;

import bean.User;
import db.DBUtil;
import util.Md5Util;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/loginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        // 防止输入法/复制粘贴带入首尾空格或全角字符导致“账号密码错误”
        if (username != null) username = username.trim();
        if (password != null) password = password.trim();
        // portal=admin 表示来自管理员独立登录页
        String portal = request.getParameter("portal");
        boolean adminPortal = "admin".equals(portal);
        String loginPage = adminPortal ? "adminLogin.jsp" : "login.jsp";
        Connection conn = DBUtil.getConn();
        // 密码 MD5 加密后与库中密文比对
        String sql = "select * from user where username=? and password=?";
        try {
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, Md5Util.md5(password));
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setPassword(rs.getString("password"));
                u.setRole(rs.getString("role"));
                if (adminPortal && !"admin".equals(u.getRole())) {
                    // 管理员入口只允许管理员登录
                    request.setAttribute("msg", "该账号不是管理员，无权进入后台！");
                    request.getRequestDispatcher(loginPage).forward(request, response);
                    DBUtil.close(conn, pstmt, rs);
                    return;
                }
                HttpSession session = request.getSession();
                session.setAttribute("loginUser", u);
                response.sendRedirect("index.jsp");
            } else {
                // 登录失败：给出提示，login.jsp 中 JS 延迟3秒后自动返回干净登录页
                request.setAttribute("msg", "账号密码错误！请重新输入（3秒后自动返回登录界面）");
                request.getRequestDispatcher(loginPage).forward(request, response);
            }
            DBUtil.close(conn, pstmt, rs);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
