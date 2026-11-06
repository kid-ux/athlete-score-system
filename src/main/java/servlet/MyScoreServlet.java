package servlet;

import bean.User;
import db.DBUtil;

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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 我的参赛成绩（MVC 的 C）：查询当前登录运动员的全部成绩，按项目分组展示。
 * JSP 只负责展示。
 */
@WebServlet("/myScoreServlet")
public class MyScoreServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        HttpSession session = request.getSession();
        User loginUser = (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        Connection conn = DBUtil.getConn();
        try {
            List<Map<String, Object>> rows = new ArrayList<>();
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT e.name event_name, e.start_date, sp.name item_name, sp.record_type, " +
                    "s.value, s.unit, s.is_foul, s.is_finished, s.is_record, s.`rank`, s.create_time " +
                    "FROM score s JOIN athlete a ON s.athlete_id = a.id " +
                    "LEFT JOIN sport_item sp ON s.item_id = sp.id " +
                    "LEFT JOIN event e ON sp.event_id = e.id " +
                    "WHERE a.user_id = ? ORDER BY e.start_date DESC, e.id DESC, sp.id, " +
                    "(CASE WHEN s.is_foul=1 OR s.is_finished=0 THEN 2 WHEN s.`rank` IS NULL THEN 1 ELSE 0 END), s.`rank`, s.create_time DESC");
            ps.setInt(1, loginUser.getId());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("eventName", rs.getString("event_name"));
                m.put("startDate", rs.getString("start_date"));
                m.put("itemName", rs.getString("item_name"));
                m.put("recordType", rs.getString("record_type"));
                m.put("value", rs.getDouble("value"));
                m.put("unit", rs.getString("unit"));
                m.put("isFoul", rs.getInt("is_foul"));
                m.put("isFinished", rs.getInt("is_finished"));
                m.put("isRecord", rs.getInt("is_record"));
                int rk = rs.getInt("rank");
                m.put("rank", rs.wasNull() ? null : rk);
                m.put("createTime", rs.getTimestamp("create_time"));
                rows.add(m);
            }
            DBUtil.close(conn, ps, rs);
            request.setAttribute("scoreRows", rows);
            request.getRequestDispatcher("athlete/myScore.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
