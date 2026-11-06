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
 * 多维统计：按 项目×院系、项目×性别 两个维度 GROUP BY 汇总参赛人数与最好成绩。
 * 计时类取最小值、距离类取最大值，避免 MIN() 对距离类项目算错"最好成绩"。
 */
@WebServlet("/statServlet")
public class StatServlet extends HttpServlet {

    /** 共用一段聚合 SQL，只是 GROUP BY 的维度列不同 */
    private List<Map<String, Object>> runStat(Connection conn, String dimCol, String dimKey) throws Exception {
        String sql = "SELECT sp.name item_name, " + dimCol + " dim, COUNT(*) countNum, " +
                "MIN(CASE WHEN sp.record_type='time' THEN s.value END) bestTime, " +
                "MAX(CASE WHEN sp.record_type='distance' THEN s.value END) bestDist, " +
                "sp.record_type recordType " +
                "FROM score s LEFT JOIN sport_item sp ON s.item_id=sp.id LEFT JOIN athlete ath ON s.athlete_id=ath.id " +
                "WHERE s.is_foul=0 AND s.is_finished=1 GROUP BY sp.name, " + dimCol + ", sp.record_type";
        List<Map<String, Object>> list = new ArrayList<>();
        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> map = new HashMap<>();
            map.put("itemName", rs.getString("item_name"));
            map.put(dimKey, rs.getString("dim"));
            map.put("countNum", rs.getInt("countNum"));
            double bestTime = rs.getDouble("bestTime");
            double bestDist = rs.getDouble("bestDist");
            Object best = "time".equals(rs.getString("recordType"))
                    ? (rs.wasNull() ? null : bestTime) : null;
            if (best == null) {
                best = rs.getDouble("bestDist");
                if (rs.wasNull()) best = null;
            }
            map.put("bestScore", best);
            list.add(map);
        }
        rs.close();
        pstmt.close();
        return list;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    /** 把聚合结果拼成 Chart.js 可直接使用的 JS 数组片段（标签带单引号） */
    private String jsArray(List<Map<String, Object>> rows, String key, boolean quote) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) sb.append(",");
            Object v = rows.get(i).get(key);
            if (quote) {
                sb.append("'").append(String.valueOf(v).replace("'", "\\'")).append("'");
            } else {
                sb.append(v);
            }
        }
        return sb.toString();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("utf-8");
        Connection conn = DBUtil.getConn();
        try {
            // 维度一：项目 × 院系
            request.setAttribute("statList", runStat(conn, "ath.department", "dept"));
            // 维度二：项目 × 性别
            request.setAttribute("genderStatList", runStat(conn, "ath.gender", "gender"));

            // 图表数据一：各院系有效成绩数量（柱状图）
            List<Map<String, Object>> deptChart = new ArrayList<>();
            PreparedStatement p1 = conn.prepareStatement(
                    "SELECT ath.department dim, COUNT(*) cnt FROM score s JOIN athlete ath ON s.athlete_id=ath.id " +
                            "WHERE s.is_foul=0 AND s.is_finished=1 GROUP BY ath.department ORDER BY cnt DESC");
            ResultSet r1 = p1.executeQuery();
            while (r1.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("label", r1.getString("dim"));
                m.put("cnt", r1.getInt("cnt"));
                deptChart.add(m);
            }
            r1.close(); p1.close();

            // 图表数据二：报名运动员男女比例（饼图）
            List<Map<String, Object>> genderChart = new ArrayList<>();
            PreparedStatement p2 = conn.prepareStatement("SELECT gender dim, COUNT(*) cnt FROM athlete GROUP BY gender");
            ResultSet r2 = p2.executeQuery();
            while (r2.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("label", r2.getString("dim"));
                m.put("cnt", r2.getInt("cnt"));
                genderChart.add(m);
            }
            r2.close(); p2.close();

            request.setAttribute("deptLabels", jsArray(deptChart, "label", true));
            request.setAttribute("deptCounts", jsArray(deptChart, "cnt", false));
            request.setAttribute("genderLabels", jsArray(genderChart, "label", true));
            request.setAttribute("genderCounts", jsArray(genderChart, "cnt", false));

            DBUtil.close(conn, null, null);
            request.getRequestDispatcher("admin/stat.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
