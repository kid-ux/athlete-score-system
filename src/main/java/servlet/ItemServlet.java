package servlet;

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

@WebServlet("/itemServlet")
public class ItemServlet extends HttpServlet {

    /** 赛事下拉数据（新增/编辑项目时用） */
    private void loadEventOptions(Connection conn, HttpServletRequest request) throws Exception {
        List<Map<String, Object>> events = new ArrayList<>();
        PreparedStatement p = conn.prepareStatement("select id,name from event order by start_date");
        ResultSet r = p.executeQuery();
        while (r.next()) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r.getInt("id"));
            m.put("name", r.getString("name"));
            events.add(m);
        }
        r.close(); p.close();
        request.setAttribute("eventOptions", events);
    }

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
            List<SportItem> list = new ArrayList<>();
            String sql = "select sp.*, e.name ename from sport_item sp left join event e on sp.event_id=e.id";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    SportItem item = new SportItem();
                    item.setId(rs.getInt("id"));
                    item.setEventId(rs.getInt("event_id"));
                    item.setName(rs.getString("name"));
                    item.setUnit(rs.getString("unit"));
                    item.setRecordType(rs.getString("record_type"));
                    item.setGender(rs.getString("gender"));
                    item.setEventName(rs.getString("ename"));
                    list.add(item);
                }
                rs.close(); pstmt.close();
                loadEventOptions(conn, request);
                DBUtil.close(conn, null, null);
                request.setAttribute("itemList", list);
                Object errMsg = request.getSession().getAttribute("errMsg");
                if (errMsg != null) {
                    request.setAttribute("errMsg", errMsg);
                    request.getSession().removeAttribute("errMsg");
                }
                request.getRequestDispatcher("admin/itemList.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("add".equals(op)) {
            int eventId = Integer.parseInt(request.getParameter("event_id"));
            String name = request.getParameter("name");
            String unit = request.getParameter("unit");
            String recordType = request.getParameter("record_type");
            String gender = request.getParameter("gender");
            String sql = "insert into sport_item(event_id,name,unit,record_type,gender) values(?,?,?,?,?)";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, eventId);
                pstmt.setString(2, name);
                pstmt.setString(3, unit);
                pstmt.setString(4, recordType);
                pstmt.setString(5, gender);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("itemServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("toUpdate".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            try {
                PreparedStatement pstmt = conn.prepareStatement("select * from sport_item where id=?");
                pstmt.setInt(1, id);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    SportItem item = new SportItem();
                    item.setId(rs.getInt("id"));
                    item.setEventId(rs.getInt("event_id"));
                    item.setName(rs.getString("name"));
                    item.setUnit(rs.getString("unit"));
                    item.setRecordType(rs.getString("record_type"));
                    item.setGender(rs.getString("gender"));
                    request.setAttribute("item", item);
                }
                rs.close(); pstmt.close();
                loadEventOptions(conn, request);
                DBUtil.close(conn, null, null);
                request.getRequestDispatcher("admin/itemEdit.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("update".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            int eventId = Integer.parseInt(request.getParameter("event_id"));
            String name = request.getParameter("name");
            String unit = request.getParameter("unit");
            String recordType = request.getParameter("record_type");
            String gender = request.getParameter("gender");
            String sql = "update sport_item set event_id=?,name=?,unit=?,record_type=?,gender=? where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, eventId);
                pstmt.setString(2, name);
                pstmt.setString(3, unit);
                pstmt.setString(4, recordType);
                pstmt.setString(5, gender);
                pstmt.setInt(6, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("itemServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("del".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "delete from sport_item where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("itemServlet?op=list");
            } catch (Exception e) {
                e.printStackTrace();
                // 外键约束：该项目下已有成绩时不能删除
                request.getSession().setAttribute("errMsg", "该项目下已有成绩数据，不能删除！");
                response.sendRedirect("itemServlet?op=list");
            }
        }
    }
}
