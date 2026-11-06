package servlet;

import db.DBUtil;
import util.Md5Util;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/registerServlet")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String password2 = request.getParameter("password2");

        // 基本校验
        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.setAttribute("msg", "用户名和密码不能为空");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (!password.equals(password2)) {
            request.setAttribute("msg", "两次输入的密码不一致");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        username = username.trim();

        Connection conn = DBUtil.getConn();
        try {
            // 检查用户名是否已存在
            PreparedStatement check = conn.prepareStatement("select id from user where username=?");
            check.setString(1, username);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                DBUtil.close(null, check, rs);
                request.setAttribute("msg", "用户名已被注册，请换一个");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            rs.close();
            check.close();

            // 注册的新账号一律是运动员角色；密码 MD5 加密存储
            PreparedStatement pstmt = conn.prepareStatement(
                    "insert into user(username,password,role) values(?,?,'athlete')");
            pstmt.setString(1, username);
            pstmt.setString(2, Md5Util.md5(password));
            pstmt.executeUpdate();
            DBUtil.close(conn, pstmt, null);
            request.setAttribute("msg", "注册成功，请登录");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
