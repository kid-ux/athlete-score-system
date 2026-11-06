package servlet;

import bean.Athlete;
import db.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/athleteServlet")
public class AthleteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        String op = request.getParameter("op");
        if (op == null) op = "list";
        Connection conn = DBUtil.getConn();

        if ("list".equals(op)) {
            List<Athlete> list = new ArrayList<>();
            // 联表带出用户名和赛事名，管理界面不再显示裸 ID
            String sql = "select a.*, u.username, e.name ename from athlete a " +
                    "left join user u on a.user_id=u.id left join event e on a.event_id=e.id";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Athlete a = new Athlete();
                    a.setId(rs.getInt("id"));
                    a.setUserId(rs.getInt("user_id"));
                    a.setEventId(rs.getInt("event_id"));
                    a.setDepartment(rs.getString("department"));
                    a.setName(rs.getString("name"));
                    a.setGender(rs.getString("gender"));
                    a.setStatus(rs.getInt("status"));
                    a.setUsername(rs.getString("username"));
                    a.setEventName(rs.getString("ename"));
                    list.add(a);
                }
                rs.close();
                pstmt.close();

                // 新增表单下拉数据：运动员账号、赛事
                List<Map<String, Object>> users = new ArrayList<>();
                PreparedStatement pu = conn.prepareStatement("select id,username from user where role='athlete'");
                ResultSet ru = pu.executeQuery();
                while (ru.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", ru.getInt("id"));
                    m.put("username", ru.getString("username"));
                    users.add(m);
                }
                ru.close(); pu.close();

                List<Map<String, Object>> events = new ArrayList<>();
                PreparedStatement pe = conn.prepareStatement("select id,name from event order by start_date");
                ResultSet re = pe.executeQuery();
                while (re.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", re.getInt("id"));
                    m.put("name", re.getString("name"));
                    events.add(m);
                }
                DBUtil.close(conn, pe, re);

                request.setAttribute("athleteList", list);
                request.setAttribute("userOptions", users);
                request.setAttribute("eventOptions", events);
                Object errMsg = request.getSession().getAttribute("errMsg");
                if (errMsg != null) {
                    request.setAttribute("errMsg", errMsg);
                    request.getSession().removeAttribute("errMsg");
                }
                request.getRequestDispatcher("admin/athleteList.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("add".equals(op)) {
            int userId = Integer.parseInt(request.getParameter("user_id"));
            int eventId = Integer.parseInt(request.getParameter("event_id"));
            String dept = request.getParameter("department");
            String name = request.getParameter("name");
            String gender = request.getParameter("gender");
            String sql = "insert into athlete(user_id,event_id,department,name,gender) values(?,?,?,?,?)";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, userId);
                pstmt.setInt(2, eventId);
                pstmt.setString(3, dept);
                pstmt.setString(4, name);
                pstmt.setString(5, gender);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("athleteServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("del".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "delete from athlete where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("athleteServlet?op=list");
            } catch (Exception e) {
                e.printStackTrace();
                // 外键约束：该运动员已有成绩记录时删除失败，给出友好提示
                request.getSession().setAttribute("errMsg", "该运动员已有成绩记录，不能删除！");
                response.sendRedirect("athleteServlet?op=list");
            }
        } else if ("review".equals(op)) {
            // 资格审查：status 1=通过 2=驳回
            int id = Integer.parseInt(request.getParameter("id"));
            int status = Integer.parseInt(request.getParameter("status"));
            String sql = "update athlete set status=? where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, status);
                pstmt.setInt(2, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("athleteServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
