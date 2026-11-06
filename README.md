# 运动员比赛成绩管理系统

面向校内体育赛事的运动员比赛成绩管理系统（Web 应用开发实训课程设计，题目八）。

## 技术栈

JSP + Servlet + JavaBean + JavaScript + Bootstrap + MySQL 8.0（MVC 分层，无 Maven / SpringBoot 等框架），Tomcat 10.1，JDK 17。

## 功能

**前台（游客 / 运动员）**

- 游客免登录浏览赛事、参赛项目、已公布成绩与分项目排名榜
- 运动员注册登录、报名参赛（等待资格审查）、查看个人参赛记录与成绩
- 综合查询：赛事 / 项目 / 运动员 / 成绩四类对象，支持项目、性别、院系、成绩区间、日期区间等组合条件

**后台（管理员 / 裁判，独立登录入口）**

- 赛事管理、项目管理（记录成绩单位与排序方向：计时型越小越好 / 距离型越大越好）
- 运动员报名与资格审查（通过 / 驳回）
- 成绩录入（成绩值、单位、犯规、未完成标记）
- 自动排名（RANK() 窗口函数，犯规 / 未完成不计入排名，每人每项取最好成绩）
- 破纪录判定（与历届同名项目赛前最好成绩比较）
- 多维统计（按项目 × 院系、项目 × 性别 GROUP BY 汇总，Chart.js 图表）

## 数据库

`sportsdb.sql`：建库建表脚本（含测试数据），五张核心表 user / event / sport_item / athlete / score。

> 注意：`rank` 是 MySQL 8.0 保留字，建表语句中必须使用反引号。

测试账号：管理员 `admin / 123456`，运动员 `zhangsan / 123456` 等（密码均存 MD5 摘要）。

## 部署

1. MySQL 中执行 `sportsdb.sql`
2. 修改 `src/main/java/util/DBUtil.java` 中的数据库账号密码
3. 将 `src/main/webapp` 部署为 Tomcat 的 `javaweb` 应用，编译 `src/main/java` 到 `WEB-INF/classes`
4. 访问 `http://localhost:8080/javaweb/`

## 文档

`Web应用开发实训课程设计报告-运动员比赛成绩管理系统.docx`：课程设计报告（需求分析、数据流图、ER 图、排名算法与统计 SQL、测试用例、运行截图）。`report_assets/` 内含报告插图源码与生成脚本。
