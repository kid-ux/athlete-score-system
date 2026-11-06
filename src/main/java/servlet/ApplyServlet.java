package servlet;

import bean.Event;
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
 * 运动员自助报名
 * op=list   列出所有赛事 + 我的报名记录
 * op=add    报名某个赛事（user_id 取自登录会话，防冒充、防重复）
 * op=cancel 取消自己的报名
 */
@WebServlet("/applyServlet")
public class ApplyServlet extends HttpServlet {
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
        String op = request.getParameter("op");
        if (op == null) op = "list";
        Connection conn = DBUtil.getConn();

        if ("add".equals(op)) {
            int eventId = Integer.parseInt(request.getParameter("event_id"));
            String dept = request.getParameter("department");
            String name = request.getParameter("name");
            String gender = request.getParameter("gender");
            try {
                // 防止重复报名同一赛事
                PreparedStatement check = conn.prepareStatement(
                        "select id from athlete where user_id=? and event_id=?");
                check.setInt(1, loginUser.getId());
                check.setInt(2, eventId);
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    DBUtil.close(conn, check, rs);
                    session.setAttribute("applyMsg", "你已报名该赛事，请勿重复报名");
                    response.sendRedirect("applyServlet");
                    return;
                }
                rs.close();
                check.close();

                PreparedStatement pstmt = conn.prepareStatement(
                        "insert into athlete(user_id,event_id,department,name,gender) values(?,?,?,?,?)");
                pstmt.setInt(1, loginUser.getId());
                pstmt.setInt(2, eventId);
                pstmt.setString(3, dept);
                pstmt.setString(4, name);
                pstmt.setString(5, gender);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                session.setAttribute("applyMsg", "报名成功！");
                response.sendRedirect("applyServlet");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("cancel".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            // 只能取消自己的报名
            String sql = "delete from athlete where id=? and user_id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.setInt(2, loginUser.getId());
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                session.setAttribute("applyMsg", "已取消报名");
                response.sendRedirect("applyServlet");
            } catch (Exception e) { e.printStackTrace(); }
        } else { // list
            try {
                // 所有赛事
                List<Event> events = new ArrayList<>();
                PreparedStatement p1 = conn.prepareStatement("select * from event order by start_date");
                ResultSet r1 = p1.executeQuery();
                while (r1.next()) {
                    Event e = new Event();
                    e.setId(r1.getInt("id"));
                    e.setName(r1.getString("name"));
                    e.setStartDate(r1.getDate("start_date"));
                    e.setEndDate(r1.getDate("end_date"));
                    events.add(e);
                }
                r1.close();
                p1.close();

                // 我的报名记录（带赛事名称）
                List<Map<String, Object>> myApplies = new ArrayList<>();
                PreparedStatement p2 = conn.prepareStatement(
                        "select a.id aid, a.department, a.name, a.gender, a.status, e.name ename " +
                        "from athlete a left join event e on a.event_id=e.id where a.user_id=?");
                p2.setInt(1, loginUser.getId());
                ResultSet r2 = p2.executeQuery();
                while (r2.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", r2.getInt("aid"));
                    m.put("department", r2.getString("department"));
                    m.put("name", r2.getString("name"));
                    m.put("gender", r2.getString("gender"));
                    m.put("status", r2.getInt("status"));
                    m.put("eventName", r2.getString("ename"));
                    myApplies.add(m);
                }
                DBUtil.close(conn, p2, r2);

                request.setAttribute("eventList", events);
                request.setAttribute("myApplies", myApplies);
                Object msg = session.getAttribute("applyMsg");
                if (msg != null) {
                    request.setAttribute("msg", msg);
                    session.removeAttribute("applyMsg");
                }
                request.getRequestDispatcher("athlete/apply.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
