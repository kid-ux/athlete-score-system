package filter;

import bean.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 后台权限拦截器：管理端页面和接口必须是已登录的管理员，
 * 未登录踢回管理员登录页，非管理员踢回前台首页
 */
@WebFilter(urlPatterns = {"/admin/*", "/eventServlet", "/itemServlet",
        "/athleteServlet", "/scoreServlet", "/statServlet"})
public class AdminFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;
        HttpSession session = request.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            response.sendRedirect(request.getContextPath() + "/adminLogin.jsp");
            return;
        }
        if (!"admin".equals(u.getRole())) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }
        chain.doFilter(req, resp);
    }
}
