package servlet;

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

/**
 * 综合查询（MVC 的 C）：赛事 / 比赛项目 / 运动员 / 成绩 四类对象组合查询。
 * 对游客、运动员、管理员全部开放；只读，JSP 只负责展示。
 */
@WebServlet("/queryServlet")
public class QueryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    private static boolean notBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        String type = request.getParameter("type");
        String kw = request.getParameter("kw");
        String kw2 = request.getParameter("kw2");
        String gender = request.getParameter("gender");
        String dept = request.getParameter("dept");
        String min = request.getParameter("min");
        String max = request.getParameter("max");
        String date1 = request.getParameter("date1");
        String date2 = request.getParameter("date2");
        String recordType = request.getParameter("record_type");
        String itemGender = request.getParameter("item_gender");
        String eventId = request.getParameter("event_id");
        String status = request.getParameter("status");
        boolean includeInvalid = "1".equals(request.getParameter("includeInvalid"));

        Connection conn = DBUtil.getConn();
        try {
            // "所属赛事"下拉数据（项目查询条件用）
            List<Map<String, Object>> eventOpts = new ArrayList<>();
            PreparedStatement p0 = conn.prepareStatement("select id,name from event order by start_date");
            ResultSet r0 = p0.executeQuery();
            while (r0.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", r0.getInt("id"));
                m.put("name", r0.getString("name"));
                eventOpts.add(m);
            }
            r0.close(); p0.close();
            request.setAttribute("eventOptions", eventOpts);

            if (type == null) {
                // 未查询，仅展示表单
            } else if ("score".equals(type)) {
                // 默认只查有效成绩（正常完赛）；勾选后才包含犯规/未完成记录
                // kw=项目名称关键词，kw2=运动员姓名关键词（用户最常按姓名查成绩）
                StringBuilder sql = new StringBuilder(
                        "SELECT e.name event_name, e.start_date, sp.name item_name, sp.record_type, a.name aname, a.department, a.gender, " +
                        "s.value, s.unit, s.is_record, s.is_foul, s.is_finished, s.`rank` " +
                        "FROM score s LEFT JOIN sport_item sp ON s.item_id=sp.id " +
                        "LEFT JOIN event e ON sp.event_id=e.id " +
                        "LEFT JOIN athlete a ON s.athlete_id=a.id WHERE 1=1");
                if (!includeInvalid) sql.append(" AND s.is_foul=0 AND s.is_finished=1");
                if (notBlank(kw)) sql.append(" AND sp.name LIKE ?");
                if (notBlank(kw2)) sql.append(" AND a.name LIKE ?");
                if (notBlank(gender)) sql.append(" AND a.gender = ?");
                if (notBlank(dept)) sql.append(" AND a.department LIKE ?");
                if (notBlank(min)) sql.append(" AND s.value >= ?");
                if (notBlank(max)) sql.append(" AND s.value <= ?");
                sql.append(" ORDER BY e.start_date DESC, e.id DESC, sp.id, " +
                        "(CASE WHEN s.is_foul=1 OR s.is_finished=0 THEN 2 WHEN s.`rank` IS NULL THEN 1 ELSE 0 END), s.`rank`");
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                int i = 1;
                if (notBlank(kw)) ps.setString(i++, "%" + kw.trim() + "%");
                if (notBlank(kw2)) ps.setString(i++, "%" + kw2.trim() + "%");
                if (notBlank(gender)) ps.setString(i++, gender.trim());
                if (notBlank(dept)) ps.setString(i++, "%" + dept.trim() + "%");
                if (notBlank(min)) ps.setDouble(i++, Double.parseDouble(min));
                if (notBlank(max)) ps.setDouble(i++, Double.parseDouble(max));
                ResultSet rs = ps.executeQuery();
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("eventName", rs.getString("event_name"));
                    m.put("startDate", rs.getString("start_date"));
                    m.put("itemName", rs.getString("item_name"));
                    m.put("recordType", rs.getString("record_type"));
                    m.put("aname", rs.getString("aname"));
                    m.put("department", rs.getString("department"));
                    m.put("gender", rs.getString("gender"));
                    m.put("value", rs.getDouble("value"));
                    m.put("unit", rs.getString("unit"));
                    m.put("isRecord", rs.getInt("is_record"));
                    m.put("isFoul", rs.getInt("is_foul"));
                    m.put("isFinished", rs.getInt("is_finished"));
                    int rk = rs.getInt("rank");
                    m.put("rank", rs.wasNull() ? null : rk);
                    rows.add(m);
                }
                rs.close(); ps.close();
                request.setAttribute("scoreRows", rows);
            } else if ("event".equals(type)) {
                StringBuilder sql = new StringBuilder("SELECT * FROM event WHERE 1=1");
                if (notBlank(kw)) sql.append(" AND name LIKE ?");
                if (notBlank(date1)) sql.append(" AND start_date >= ?");
                if (notBlank(date2)) sql.append(" AND start_date <= ?");
                sql.append(" ORDER BY start_date");
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                int i = 1;
                if (notBlank(kw)) ps.setString(i++, "%" + kw.trim() + "%");
                if (notBlank(date1)) ps.setString(i++, date1.trim());
                if (notBlank(date2)) ps.setString(i++, date2.trim());
                ResultSet rs = ps.executeQuery();
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("name"));
                    m.put("startDate", rs.getDate("start_date"));
                    m.put("endDate", rs.getDate("end_date"));
                    rows.add(m);
                }
                rs.close(); ps.close();
                request.setAttribute("eventRows", rows);
            } else if ("item".equals(type)) {
                StringBuilder sql = new StringBuilder(
                        "SELECT sp.*, e.name ename FROM sport_item sp LEFT JOIN event e ON sp.event_id=e.id WHERE 1=1");
                if (notBlank(kw)) sql.append(" AND sp.name LIKE ?");
                if (notBlank(eventId)) sql.append(" AND sp.event_id = ?");
                if (notBlank(recordType)) sql.append(" AND sp.record_type = ?");
                if (notBlank(itemGender)) sql.append(" AND sp.gender = ?");
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                int i = 1;
                if (notBlank(kw)) ps.setString(i++, "%" + kw.trim() + "%");
                if (notBlank(eventId)) ps.setInt(i++, Integer.parseInt(eventId));
                if (notBlank(recordType)) ps.setString(i++, recordType.trim());
                if (notBlank(itemGender)) ps.setString(i++, itemGender.trim());
                ResultSet rs = ps.executeQuery();
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("eventName", rs.getString("ename"));
                    m.put("name", rs.getString("name"));
                    m.put("unit", rs.getString("unit"));
                    m.put("recordType", rs.getString("record_type"));
                    m.put("gender", rs.getString("gender"));
                    rows.add(m);
                }
                rs.close(); ps.close();
                request.setAttribute("itemRows", rows);
            } else if ("athlete".equals(type)) {
                StringBuilder sql = new StringBuilder(
                        "SELECT a.*, e.name ename FROM athlete a LEFT JOIN event e ON a.event_id=e.id WHERE 1=1");
                if (notBlank(kw2)) sql.append(" AND a.name LIKE ?");
                if (notBlank(gender)) sql.append(" AND a.gender = ?");
                if (notBlank(dept)) sql.append(" AND a.department LIKE ?");
                if (notBlank(status)) sql.append(" AND a.status = ?");
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                int i = 1;
                if (notBlank(kw2)) ps.setString(i++, "%" + kw2.trim() + "%");
                if (notBlank(gender)) ps.setString(i++, gender.trim());
                if (notBlank(dept)) ps.setString(i++, "%" + dept.trim() + "%");
                if (notBlank(status)) ps.setInt(i++, Integer.parseInt(status));
                ResultSet rs = ps.executeQuery();
                List<Map<String, Object>> rows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("name"));
                    m.put("department", rs.getString("department"));
                    m.put("gender", rs.getString("gender"));
                    m.put("eventName", rs.getString("ename"));
                    m.put("status", rs.getInt("status"));
                    rows.add(m);
                }
                rs.close(); ps.close();
                request.setAttribute("athleteRows", rows);
            }
            DBUtil.close(conn, null, null);
            request.getRequestDispatcher("query.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
