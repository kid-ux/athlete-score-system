package servlet;

import bean.Score;
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
 * 成绩管理：
 * op=list     成绩列表（联表带项目名/运动员名）+ 录入表单下拉数据
 * op=add      录入成绩（含破纪录判定），随后自动重排名
 * op=toUpdate 成绩编辑页
 * op=update   保存修改，随后自动重排名
 * op=rank     自动排名（计时升序/距离降序，犯规和未完成不参与）
 * op=del      删除
 */
@WebServlet("/scoreServlet")
public class ScoreServlet extends HttpServlet {

    /** 加载录入表单所需的联动数据：赛事、项目、审核通过的运动员 */
    private void loadFormData(Connection conn, HttpServletRequest request) throws Exception {
        List<Map<String, Object>> events = new ArrayList<>();
        PreparedStatement p1 = conn.prepareStatement("select id,name from event order by start_date");
        ResultSet r1 = p1.executeQuery();
        while (r1.next()) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r1.getInt("id"));
            m.put("name", r1.getString("name"));
            events.add(m);
        }
        r1.close(); p1.close();

        List<Map<String, Object>> items = new ArrayList<>();
        PreparedStatement p2 = conn.prepareStatement("select id,event_id,name,unit,record_type from sport_item");
        ResultSet r2 = p2.executeQuery();
        while (r2.next()) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r2.getInt("id"));
            m.put("eventId", r2.getInt("event_id"));
            m.put("name", r2.getString("name"));
            m.put("unit", r2.getString("unit"));
            m.put("recordType", r2.getString("record_type"));
            items.add(m);
        }
        r2.close(); p2.close();

        // 只有资格审查通过的运动员才能录入成绩
        List<Map<String, Object>> athletes = new ArrayList<>();
        PreparedStatement p3 = conn.prepareStatement(
                "select id,event_id,name,department from athlete where status=1");
        ResultSet r3 = p3.executeQuery();
        while (r3.next()) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r3.getInt("id"));
            m.put("eventId", r3.getInt("event_id"));
            m.put("name", r3.getString("name"));
            m.put("department", r3.getString("department"));
            athletes.add(m);
        }
        r3.close(); p3.close();

        request.setAttribute("eventOptions", events);
        request.setAttribute("itemOptions", items);
        request.setAttribute("athleteOptions", athletes);
    }

    /**
     * 破纪录判定：纪录基准 = 同名项目在"更早举办的赛事"中的历史最好成绩（即赛前纪录）。
     * 同届比赛内互相超过不算破纪录；首届比赛没有历史纪录可破。
     */
    private boolean checkRecord(Connection conn, int itemId, double val, int isFoul, int isFin,
                                Integer excludeId, HttpServletRequest request, String unit) throws Exception {
        if (isFoul == 1 || isFin == 0) return false;
        String sql = "SELECT s.value, sp.record_type FROM score s " +
                "JOIN sport_item sp ON s.item_id = sp.id " +
                "JOIN event e ON sp.event_id = e.id " +
                "WHERE sp.name = (SELECT name FROM sport_item WHERE id=?) " +
                "AND e.start_date < (SELECT e2.start_date FROM sport_item sp2 JOIN event e2 ON sp2.event_id=e2.id WHERE sp2.id=?) " +
                "AND s.is_foul=0 AND s.is_finished=1";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, itemId);
        ps.setInt(2, itemId);
        ResultSet rs = ps.executeQuery();
        String recordType = null;
        Double best = null;
        while (rs.next()) {
            recordType = rs.getString("record_type");
            double v = rs.getDouble("value");
            if (best == null) best = v;
            else best = "time".equals(recordType) ? Math.min(best, v) : Math.max(best, v);
        }
        rs.close(); ps.close();
        if (best == null || recordType == null) return false;
        boolean broken = "time".equals(recordType) ? val < best : val > best;
        if (broken) {
            request.getSession().setAttribute("recordMsg",
                    "成绩 " + val + unit + " 打破赛前历史纪录 " + best + unit + "，已标记为破纪录！");
        }
        return broken;
    }

    /** 性别校验：项目有性别限制时，运动员性别必须匹配；返回错误信息或 null */
    private String checkGender(Connection conn, int itemId, int athleteId) throws Exception {
        PreparedStatement ps = conn.prepareStatement(
                "SELECT sp.gender item_gender, sp.name item_name, a.gender ath_gender, a.name ath_name " +
                "FROM sport_item sp, athlete a WHERE sp.id=? AND a.id=?");
        ps.setInt(1, itemId);
        ps.setInt(2, athleteId);
        ResultSet rs = ps.executeQuery();
        String err = null;
        if (rs.next()) {
            String ig = rs.getString("item_gender");
            String ag = rs.getString("ath_gender");
            if (ig != null && !"不限".equals(ig) && !ig.equals(ag)) {
                err = "项目「" + rs.getString("item_name") + "」限" + ig + "性参加，运动员「"
                        + rs.getString("ath_name") + "」性别为" + ag + "，不能录入该项目成绩！";
            }
        }
        rs.close(); ps.close();
        return err;
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
            // 按「赛事 -> 项目 -> 名次」分组排序，便于页面分榜展示；
            // 每组内：有名次的有效成绩按名次排，其次是无名次的有效成绩（非个人最好），犯规/未完成沉底
            List<Map<String, Object>> list = new ArrayList<>();
            String sql = "SELECT s.*, sp.name item_name, sp.record_type, sp.gender item_gender, " +
                    "e.id eid, e.name event_name, e.start_date, e.end_date, " +
                    "a.name athlete_name, a.department FROM score s " +
                    "LEFT JOIN sport_item sp ON s.item_id=sp.id " +
                    "LEFT JOIN event e ON sp.event_id=e.id " +
                    "LEFT JOIN athlete a ON s.athlete_id=a.id " +
                    "ORDER BY e.start_date DESC, e.id DESC, sp.id, " +
                    "(CASE WHEN s.is_foul=1 OR s.is_finished=0 THEN 2 WHEN s.rank IS NULL THEN 1 ELSE 0 END), s.rank, s.id";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("itemId", rs.getInt("item_id"));
                    m.put("value", rs.getDouble("value"));
                    m.put("unit", rs.getString("unit"));
                    m.put("isFoul", rs.getInt("is_foul"));
                    m.put("isFinished", rs.getInt("is_finished"));
                    m.put("isRecord", rs.getInt("is_record"));
                    int rk = rs.getInt("rank");
                    m.put("rank", rs.wasNull() ? null : rk);
                    m.put("eventId", rs.getObject("eid"));
                    m.put("eventName", rs.getString("event_name"));
                    m.put("startDate", rs.getString("start_date"));
                    m.put("endDate", rs.getString("end_date"));
                    m.put("itemName", rs.getString("item_name"));
                    m.put("recordType", rs.getString("record_type"));
                    m.put("itemGender", rs.getString("item_gender"));
                    m.put("athleteName", rs.getString("athlete_name"));
                    m.put("department", rs.getString("department"));
                    list.add(m);
                }
                rs.close(); pstmt.close();
                loadFormData(conn, request);
                DBUtil.close(conn, null, null);
                request.setAttribute("scoreList", list);
                // 破纪录提示（录入/修改成绩后由 add/update 写入 session）
                Object recordMsg = request.getSession().getAttribute("recordMsg");
                if (recordMsg != null) {
                    request.setAttribute("recordMsg", recordMsg);
                    request.getSession().removeAttribute("recordMsg");
                }
                // 性别限制等校验错误提示
                Object scoreErr = request.getSession().getAttribute("scoreErr");
                if (scoreErr != null) {
                    request.setAttribute("scoreErr", scoreErr);
                    request.getSession().removeAttribute("scoreErr");
                }
                request.getRequestDispatcher("admin/scoreList.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("add".equals(op)) {
            int itemId = Integer.parseInt(request.getParameter("item_id"));
            int athleteId = Integer.parseInt(request.getParameter("athlete_id"));
            double val = Double.parseDouble(request.getParameter("value"));
            String unit = request.getParameter("unit");
            if (unit == null) unit = "";
            int isFoul = Integer.parseInt(request.getParameter("is_foul"));
            int isFin = Integer.parseInt(request.getParameter("is_finished"));
            try {
                // 性别校验：项目有性别限制时运动员性别必须匹配
                String genderErr = checkGender(conn, itemId, athleteId);
                if (genderErr != null) {
                    request.getSession().setAttribute("scoreErr", genderErr);
                    DBUtil.close(conn, null, null);
                    response.sendRedirect("scoreServlet?op=list");
                    return;
                }
                boolean isRecord = checkRecord(conn, itemId, val, isFoul, isFin, null, request, unit);
                String sql = "insert into score(item_id,athlete_id,value,unit,is_foul,is_finished,is_record) values(?,?,?,?,?,?,?)";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, itemId);
                pstmt.setInt(2, athleteId);
                pstmt.setDouble(3, val);
                pstmt.setString(4, unit);
                pstmt.setInt(5, isFoul);
                pstmt.setInt(6, isFin);
                pstmt.setInt(7, isRecord ? 1 : 0);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("scoreServlet?op=rank");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("toUpdate".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            try {
                PreparedStatement pstmt = conn.prepareStatement("select * from score where id=?");
                pstmt.setInt(1, id);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    Score s = new Score();
                    s.setId(rs.getInt("id"));
                    s.setItemId(rs.getInt("item_id"));
                    s.setAthleteId(rs.getInt("athlete_id"));
                    s.setValue(rs.getDouble("value"));
                    s.setUnit(rs.getString("unit"));
                    s.setIsFoul(rs.getInt("is_foul"));
                    s.setIsFinished(rs.getInt("is_finished"));
                    s.setIsRecord(rs.getInt("is_record"));
                    request.setAttribute("score", s);
                }
                rs.close(); pstmt.close();
                loadFormData(conn, request);
                DBUtil.close(conn, null, null);
                request.getRequestDispatcher("admin/scoreEdit.jsp").forward(request, response);
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("update".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            int itemId = Integer.parseInt(request.getParameter("item_id"));
            int athleteId = Integer.parseInt(request.getParameter("athlete_id"));
            double val = Double.parseDouble(request.getParameter("value"));
            String unit = request.getParameter("unit");
            if (unit == null) unit = "";
            int isFoul = Integer.parseInt(request.getParameter("is_foul"));
            int isFin = Integer.parseInt(request.getParameter("is_finished"));
            try {
                // 性别校验：项目有性别限制时运动员性别必须匹配
                String genderErr = checkGender(conn, itemId, athleteId);
                if (genderErr != null) {
                    request.getSession().setAttribute("scoreErr", genderErr);
                    DBUtil.close(conn, null, null);
                    response.sendRedirect("scoreServlet?op=list");
                    return;
                }
                // 修改后的成绩重新做破纪录判定（与赛前历史纪录比对）
                boolean isRecord = checkRecord(conn, itemId, val, isFoul, isFin, id, request, unit);
                String sql = "update score set item_id=?,athlete_id=?,value=?,unit=?,is_foul=?,is_finished=?,is_record=? where id=?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, itemId);
                pstmt.setInt(2, athleteId);
                pstmt.setDouble(3, val);
                pstmt.setString(4, unit);
                pstmt.setInt(5, isFoul);
                pstmt.setInt(6, isFin);
                pstmt.setInt(7, isRecord ? 1 : 0);
                pstmt.setInt(8, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("scoreServlet?op=rank");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("rank".equals(op)) {
            // 自动排名：先取"每人每项的最好成绩"（真实运动会规则：同一运动员在同一项目只占一个名次），
            // 再按项目分区排名：计时类升序、距离类降序；犯规和未完成不参与
            String rankSql = "UPDATE score sc LEFT JOIN (\n" +
                    "SELECT b.id, RANK() OVER (PARTITION BY b.item_id ORDER BY\n" +
                    "CASE WHEN sp.record_type='time' THEN b.value END ASC,\n" +
                    "CASE WHEN sp.record_type='distance' THEN b.value END DESC\n" +
                    ") rk FROM score b JOIN sport_item sp ON b.item_id=sp.id\n" +
                    "WHERE b.is_foul=0 AND b.is_finished=1\n" +
                    "AND NOT EXISTS (\n" +
                    "  SELECT 1 FROM score s2 WHERE s2.item_id=b.item_id AND s2.athlete_id=b.athlete_id\n" +
                    "  AND s2.is_foul=0 AND s2.is_finished=1\n" +
                    "  AND ((sp.record_type='time' AND s2.value < b.value)\n" +
                    "    OR (sp.record_type='distance' AND s2.value > b.value)\n" +
                    "    OR (s2.value = b.value AND s2.id < b.id))\n" +
                    ")\n" +
                    ") t ON sc.id = t.id SET sc.rank = t.rk";
            try {
                PreparedStatement pstmt = conn.prepareStatement(rankSql);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("scoreServlet?op=list");
            } catch (Exception e) { e.printStackTrace(); }
        } else if ("del".equals(op)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String sql = "delete from score where id=?";
            try {
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, id);
                pstmt.executeUpdate();
                DBUtil.close(conn, pstmt, null);
                response.sendRedirect("scoreServlet?op=rank");
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}
