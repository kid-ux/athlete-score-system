package servlet;

import bean.Event;
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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet("/eventServlet")
public class EventServlet extends HttpServlet {
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
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        if ("list".equals(op)) {
            List<Event> list = new ArrayList<>();
            String sql = "select * from event";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Event e = new Event();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setStartDate(rs.getDate("start_date"));
                    e.setEndDate(rs.getDate("end_date"));
                    list.add(e);
                }
                DBUtil.close(conn, pstmt, rs);
                request.setAttribute("eventList", list);
                Object errMsg = request.getSession().getAttribute("errMsg");
                if (errMsg != null) {
                    request.setAttribute("errMsg", errMsg);
                    request.getSession().removeAttribute("errMsg");
                }
                request.getRequestDispatcher("admin/eventList.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("add".equals(op)) {
            String name = request.getParameter("name");
            String sStart = request.getParameter("start_date");
            String sEnd = request.getParameter("end_date");
            try {
                Date start = sdf.parse(sStart);
                Date end = sdf.parse(sEnd);
                String sql = "insert into event(name,start_date,end_date) values(?,?,?)";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setDate(2, new java.sql.Date(start.getTime()));
                pstmt.setDate(3, new java.sql.Date(end.getTime()));
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("eventServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("del".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "delete from event where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("eventServlet?op=list");
            } catch (Exception e) {
                e.printStackTrace();
                // 外键约束：有项目/报名/成绩关联时删除失败，给出友好提示
                request.getSession().setAttribute("errMsg", "该赛事下存在项目、报名或成绩数据，不能删除！");
                response.sendRedirect("eventServlet?op=list");
            }
        } else if ("toUpdate".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "select * from event where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    Event e = new Event();
                    e.setId(rs.getInt("id"));
                    e.setName(rs.getString("name"));
                    e.setStartDate(rs.getDate("start_date"));
                    e.setEndDate(rs.getDate("end_date"));
                    request.setAttribute("event", e);
                }
                DBUtil.close(conn, pstmt, rs);
                request.getRequestDispatcher("admin/eventEdit.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("update".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String sStart = request.getParameter("start_date");
            String sEnd = request.getParameter("end_date");
            try {
                Date start = sdf.parse(sStart);
                Date end = sdf.parse(sEnd);
                String sql = "update event set name=?,start_date=?,end_date=? where id=?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, name);
                pstmt.setDate(2, new java.sql.Date(start.getTime()));
                pstmt.setDate(3, new java.sql.Date(end.getTime()));
                pstmt.setInt(4, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("eventServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
