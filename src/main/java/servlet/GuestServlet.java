package servlet;

import bean.Event;
import bean.SportItem;
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
 * 游客免登录浏览：赛事、参赛项目、已公布的成绩与排名
 * 无需登录即可访问，只读，不做任何写操作
 */
@WebServlet("/guestServlet")
public class GuestServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        Connection conn = DBUtil.getConn();
        try {
            // 1. 所有赛事
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

            // 2. 所有参赛项目（带赛事名称）
            List<Map<String, Object>> items = new ArrayList<>();
            PreparedStatement p2 = conn.prepareStatement(
                    "select sp.*, e.name ename from sport_item sp left join event e on sp.event_id=e.id");
            ResultSet r2 = p2.executeQuery();
            while (r2.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("eventName", r2.getString("ename"));
                m.put("name", r2.getString("name"));
                m.put("unit", r2.getString("unit"));
                m.put("recordType", r2.getString("record_type"));
                m.put("gender", r2.getString("gender"));
                items.add(m);
            }
            r2.close();
            p2.close();

            // 3. 已公布的成绩与排名：只公布正常完赛（不犯规且完成）的成绩
            //    按「赛事 -> 项目 -> 名次」排序，页面分榜展示（不同赛事的同名项目不能合并）
            List<Map<String, Object>> scores = new ArrayList<>();
            PreparedStatement p3 = conn.prepareStatement(
                    "SELECT e.name event_name, e.start_date, sp.name item_name, sp.record_type, " +
                    "a.name athlete_name, a.department, a.gender, " +
                    "s.value, s.unit, s.is_record, s.`rank` " +
                    "FROM score s JOIN sport_item sp ON s.item_id=sp.id " +
                    "JOIN event e ON sp.event_id=e.id " +
                    "JOIN athlete a ON s.athlete_id=a.id " +
                    "WHERE s.is_foul=0 AND s.is_finished=1 " +
                    "ORDER BY e.start_date DESC, e.id DESC, sp.id, (s.`rank` IS NULL), s.`rank`");
            ResultSet r3 = p3.executeQuery();
            while (r3.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("eventName", r3.getString("event_name"));
                m.put("startDate", r3.getString("start_date"));
                m.put("itemName", r3.getString("item_name"));
                m.put("recordType", r3.getString("record_type"));
                m.put("athleteName", r3.getString("athlete_name"));
                m.put("department", r3.getString("department"));
                m.put("gender", r3.getString("gender"));
                m.put("value", r3.getDouble("value"));
                m.put("unit", r3.getString("unit"));
                m.put("isRecord", r3.getInt("is_record"));
                int rk = r3.getInt("rank");
                m.put("rank", r3.wasNull() ? null : rk);
                scores.add(m);
            }
            DBUtil.close(conn, p3, r3);

            request.setAttribute("eventList", events);
            request.setAttribute("itemList", items);
            request.setAttribute("scoreList", scores);
            request.getRequestDispatcher("guest.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
