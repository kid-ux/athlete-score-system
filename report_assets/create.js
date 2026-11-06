import fs from "node:fs";
import path from "node:path";
import {
  AlignmentType, BorderStyle, Document, Footer, Header, HeadingLevel,
  ImageRun, ImportedXmlComponent, Packer, PageBreak, PageNumber, Paragraph,
  SectionType, ShadingType, Table, TableCell, TableRow, TextRun, WidthType,
  convertInchesToTwip,
} from "docx";

const outputPath = process.argv[2];
if (!outputPath) throw new Error("Usage: node create.js /abs/output.docx");
const assetDir = path.join(path.dirname(outputPath), "report_assets");

const T = String.raw;

/* ---------- 基础样式 ---------- */
const font = { ascii: "Times New Roman", hAnsi: "Times New Roman", cs: "Times New Roman", eastAsia: "SimSun" };
const hei = { ascii: "SimHei", hAnsi: "SimHei", cs: "SimHei", eastAsia: "SimHei" };
const mono = { ascii: "Consolas", hAnsi: "Consolas", cs: "Consolas", eastAsia: "SimSun" };
const INK = "212121";
const GRAY = "616161";
const FILL = "F2F2F2";

const run = (text, o = {}) => new TextRun({ text, font, size: 24, color: INK, ...o });
const para = (children, o = {}) => new Paragraph({
  spacing: { after: 120, line: 360 }, ...o,
  children: Array.isArray(children) ? children : [children],
});
const body = (text) => para(run(text), { indent: { firstLine: convertInchesToTwip(0.33) }, alignment: AlignmentType.JUSTIFIED });
const h1 = (text) => para(run(text, { bold: true, size: 32, font: hei }), {
  heading: HeadingLevel.HEADING_1, spacing: { before: 360, after: 200 },
});
const h2 = (text) => para(run(text, { bold: true, size: 28, font: hei }), {
  heading: HeadingLevel.HEADING_2, spacing: { before: 280, after: 160 },
});
const h3 = (text) => para(run(text, { bold: true, size: 24, font: hei }), {
  heading: HeadingLevel.HEADING_3, spacing: { before: 200, after: 120 },
});
const caption = (text) => para(run(text, { size: 21, color: GRAY }), { alignment: AlignmentType.CENTER, spacing: { before: 60, after: 200 } });
const code = (text) => new Paragraph({
  spacing: { after: 0, line: 280 },
  shading: { type: ShadingType.CLEAR, fill: FILL },
  indent: { left: 240, right: 240 },
  children: [new TextRun({ text, font: mono, size: 18, color: "333333" })],
});
const img = (file, w, h) => new Paragraph({
  alignment: AlignmentType.CENTER, spacing: { before: 120, after: 60 },
  children: [new ImageRun({ type: "png", data: fs.readFileSync(path.join(assetDir, file)), transformation: { width: w, height: h } })],
});
const pageBreak = () => new Paragraph({ children: [new PageBreak()] });

/* ---------- 表格工具 ---------- */
const cw = { page: 9000 };
const cell = (text, o = {}) => new TableCell({
  children: [para(typeof text === "string" ? run(text, { size: 21 }) : text, { spacing: { after: 0, line: 300 }, alignment: o.align || AlignmentType.LEFT })],
  margins: { top: 80, bottom: 80, left: 100, right: 100 },
  width: { size: o.w, type: WidthType.DXA },
  shading: o.fill ? { type: ShadingType.CLEAR, fill: o.fill } : undefined,
});
const table = (widths, rows) => new Table({
  width: { size: widths.reduce((a, b) => a + b, 0), type: WidthType.DXA },
  columnWidths: widths,
  rows: rows.map((r, ri) => new TableRow({
    tableHeader: ri === 0,
    children: r.map((c, ci) => cell(c, ri === 0
      ? { w: widths[ci], fill: "E0E0E0", align: AlignmentType.CENTER, }
      : { w: widths[ci], align: typeof c === "string" && c.length <= 8 ? AlignmentType.CENTER : AlignmentType.LEFT })),
  })),
});
const headerRowCell = (text) => new TableCell; // unused guard

/* ---------- TOC ---------- */
const xmlEscape = (v) => String(v).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
const tocEntries = [
  ["1．程序设计任务与目标", 1, 1],
  ["1.1 任务", 2, 1],
  ["1.2 目标", 2, 1],
  ["1.3 需求分析", 2, 1],
  ["2．方案设计", 1, 4],
  ["2.1 系统架构设计", 2, 4],
  ["2.2 数据库设计", 2, 5],
  ["2.3 界面与安全设计", 2, 7],
  ["3．核心算法与关键实现", 1, 8],
  ["3.1 成绩排名算法", 2, 8],
  ["3.2 破纪录判定", 2, 9],
  ["3.3 跨表聚合统计", 2, 10],
  ["3.4 登录验证与安全防护", 2, 11],
  ["4．程序流程图", 1, 12],
  ["5．程序运行的测试与分析", 1, 13],
  ["5.1 测试环境", 2, 13],
  ["5.2 测试用例与结果", 2, 13],
  ["5.3 系统运行截图", 2, 15],
  ["6．存在的问题与心得体会", 1, 18],
  ["6.1 存在的问题", 2, 18],
  ["6.2 心得体会", 2, 18],
  ["附录A 建表 SQL 脚本（含测试数据）", 1, 19],
];
const toc = () => {
  const cached = tocEntries.map(([title, level, page]) => {
    const indent = Math.max(0, level - 1) * 360;
    return `<w:p><w:pPr><w:pStyle w:val="TOC${level}"/>
      <w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9000"/></w:tabs>
      <w:ind w:left="${indent}"/></w:pPr>
      <w:r><w:t>${xmlEscape(title)}</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>${page}</w:t></w:r></w:p>`;
  }).join("");
  return ImportedXmlComponent.fromXmlString(`<w:sdt xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:sdtPr><w:alias w:val="目录"/></w:sdtPr>
    <w:sdtContent>
      <w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/>
        <w:instrText xml:space="preserve"> TOC \\o &quot;1-3&quot; \\h \\z \\u </w:instrText>
        <w:fldChar w:fldCharType="separate"/></w:r></w:p>
      ${cached}
      <w:p><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>
    </w:sdtContent>
  </w:sdt>`).root[0];
};

/* ---------- 封面 ---------- */
const coverInfoTable = () => {
  const widths = [2000, 6200];
  const rows = [
    ["课程名称：", "Web应用开发实训"],
    ["院系名称：", ""],
    ["专　　业：", ""],
    ["学生姓名：", ""],
    ["学　　号：", ""],
  ];
  return new Table({
    width: { size: 8200, type: WidthType.DXA },
    columnWidths: widths,
    alignment: AlignmentType.CENTER,
    rows: rows.map(([k, v]) => new TableRow({
      height: { value: 700 },
      children: [
        new TableCell({
          width: { size: widths[0], type: WidthType.DXA },
          borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.NONE }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
          children: [para(run(k, { size: 32, font }), { alignment: AlignmentType.LEFT, spacing: { after: 0 } })],
        }),
        new TableCell({
          width: { size: widths[1], type: WidthType.DXA },
          borders: { top: { style: BorderStyle.NONE }, bottom: { style: BorderStyle.SINGLE, size: 6, color: "000000" }, left: { style: BorderStyle.NONE }, right: { style: BorderStyle.NONE } },
          children: [para(run(v, { size: 32 }), { alignment: AlignmentType.CENTER, spacing: { after: 0 } })],
        }),
      ],
    })),
  });
};

const coverChildren = [
  para(run(" ", { size: 24 }), { spacing: { after: 0 } }),
  para(run(" ", { size: 24 }), { spacing: { after: 0 } }),
  para(run("运动员比赛成绩管理系统", { bold: true, size: 52, font: hei }), { alignment: AlignmentType.CENTER, spacing: { after: 200 } }),
  para(run("课程设计报告", { bold: true, size: 52, font: hei }), { alignment: AlignmentType.CENTER, spacing: { after: 1200 } }),
  coverInfoTable(),
  para(run(" ", { size: 24 }), { spacing: { after: 600 } }),
  para(run("2026 年 11 月 5 日", { size: 32 }), { alignment: AlignmentType.CENTER }),
];

/* ---------- 正文 ---------- */
const bodyChildren = [];

/* 第1章 */
bodyChildren.push(
  h1(T`1．程序设计任务与目标`),
  h2(T`1.1 任务`),
  body(T`本课程设计的任务是运用 JSP + Servlet + JavaBean + JavaScript + CSS + MySQL 技术栈（不使用 Maven、SpringBoot 等框架），开发一个面向校内体育赛事的运动员比赛成绩管理系统（Web 应用程序），实现完整模块的数据增、删、改、查。系统需支持赛事信息管理、运动员报名与资格审查、成绩录入、自动排名、破纪录判定与多维度统计，并要求连接数据库进行登录验证：登录成功进入网站主页，登录失败给出提示并延迟 3 秒后自动返回登录界面；页面使用 Bootstrap 美化，并使用 JavaScript 对表单输入进行有效性验证。`),
  h2(T`1.2 目标`),
  body(T`系统分为前台（游客/运动员端）与后台（管理员/裁判端）两部分。前台无需登录即可浏览赛事、参赛项目与已公布的成绩、排名；运动员注册登录后可报名参加赛事、查看个人参赛记录与成绩；前台支持按项目、性别、成绩区间等条件进行综合查询。后台使用独立登录入口，管理员可进行赛事与项目管理、运动员报名与资格审查、成绩录入（成绩值、单位、是否犯规、是否完成等标记），系统自动完成排名计算与破纪录判定，并可按项目、院系、性别等多维度进行统计。`),
  body(T`本题目的核心难点在于两点：一是成绩排名计算——不同项目的成绩单位与排序方向不同（计时型越小越好，距离/高度型越大越好），需要统一处理，且犯规、未完成成绩不计入排名；二是跨表聚合统计——按项目、院系、性别使用 GROUP BY 汇总参赛人数、最好成绩等。`),
  h2(T`1.3 需求分析`),
  h3(T`1.3.1 功能列表`),
);

bodyChildren.push(table([1100, 1700, 5400], [
  ["端", "模块", "功能说明"],
  [T`前台（游客）`, T`赛事/成绩浏览`, T`无需登录浏览赛事列表、参赛项目、已公布的成绩与分项目排名榜`],
  [T`前台（游客）`, T`综合查询`, T`对赛事、项目、运动员、成绩四类对象进行组合条件查询（名称、性别、院系、成绩区间、日期区间等）`],
  [T`前台（运动员）`, T`注册/登录`, T`注册运动员账号并登录，JavaScript 前端校验 + 服务器端数据库验证`],
  [T`前台（运动员）`, T`报名/参赛记录`, T`报名参加赛事（提交院系等信息，等待资格审查），查看个人参赛记录与成绩排名`],
  [T`后台（管理员）`, T`赛事管理`, T`赛事的增、删、改、查（名称、起止日期）`],
  [T`后台（管理员）`, T`项目管理`, T`比赛项目的增、删、改、查（所属赛事、名称、单位、成绩类型、性别限制）`],
  [T`后台（管理员）`, T`运动员管理`, T`报名信息的增、删、改、查与资格审查（通过/驳回）`],
  [T`后台（管理员）`, T`成绩管理`, T`成绩录入、修改、删除；自动排名刷新；犯规/未完成标记；破纪录判定`],
  [T`后台（管理员）`, T`多维统计`, T`按项目×院系、项目×性别 GROUP BY 汇总参赛人数与最好成绩，图表展示`],
]));

bodyChildren.push(
  h3(T`1.3.2 数据流分析`),
  body(T`系统的数据来源与流向如图 1 所示。游客仅产生只读的数据流；运动员产生注册、报名等写入流并读取个人成绩；管理员/裁判对五张核心表进行读写，其中成绩写入会触发排名与破纪录的自动计算。`),
  img("fig_dfd.png", 460, Math.round(460 * 848 / 1456)),
  caption(T`图 1  系统数据流图`),
  h3(T`1.3.3 数据模型（ER 图）`),
  body(T`系统围绕五个核心实体建模：用户（user）、赛事（event）、比赛项目（sport_item）、运动员报名（athlete）、成绩（score）。一个用户可报名多届赛事，一届赛事包含多个项目、拥有多名报名运动员，一名运动员在一个项目下可产生多条成绩记录（多次试跳/多枪成绩，取最好成绩排名）。实体关系如图 2 所示。`),
  img("fig_er.png", 470, Math.round(470 * 982 / 1520)),
  caption(T`图 2  系统 ER 图`),
);

/* 第2章 */
bodyChildren.push(
  h1(T`2．方案设计`),
  h2(T`2.1 系统架构设计`),
  body(T`系统采用典型的 MVC 三层架构，不使用任何第三方 Web 框架，全部基于 Servlet 原生 API 实现，如图 3 所示：`),
  body(T`视图层（V）：JSP 页面负责数据渲染，统一引入 Bootstrap 进行界面美化，并使用 JavaScript 完成表单有效性验证（非空、数值范围、两次密码一致等）。`),
  body(T`控制层（C）：Servlet 负责接收请求、调用模型层、转发/重定向到视图；LoginFilter 与 AdminFilter 两个过滤器负责登录态与权限拦截。`),
  body(T`模型层（M）：JavaBean 封装实体数据，DAO/Servlet 内通过 JDBC（MySQL Connector/J）操作 MySQL 数据库，所有 SQL 均使用 PreparedStatement 预编译执行。`),
  img("fig_mvc.png", 450, Math.round(450 * 720 / 1456)),
  caption(T`图 3  MVC 分层架构图`),
  h2(T`2.2 数据库设计`),
  body(T`数据库 sportsdb（MySQL 8.0，utf8mb4 字符集）包含五张核心表，如表 2 至表 6 所示。设计上的两个关键点：其一，项目表 sport_item 中的 record_type 字段记录成绩排序方向（time 表示计时型、越小越好；distance 表示距离/高度型、越大越好），这是统一排名算法的基础；其二，成绩表 score 中的 is_foul（是否犯规）与 is_finished（是否完成）字段用于标记无效成绩，无效成绩保留在数据库中但不参与排名，rank 字段置空。`),
  para(run(T`表 2  用户表 user`, { bold: true, size: 21 }), { alignment: AlignmentType.CENTER, spacing: { before: 160, after: 80 } }),
  table([1800, 1800, 4600], [
    ["字段", "类型", "说明"],
    ["id", "INT PK 自增", T`主键`],
    ["username", "VARCHAR(50)", T`登录名，唯一约束`],
    ["password", "VARCHAR(64)", T`密码 MD5 摘要，不存明文`],
    ["role", "VARCHAR(20)", T`角色：admin 管理员 / athlete 运动员`],
  ]),
  para(run(T`表 3  赛事表 event`, { bold: true, size: 21 }), { alignment: AlignmentType.CENTER, spacing: { before: 160, after: 80 } }),
  table([1800, 1800, 4600], [
    ["字段", "类型", "说明"],
    ["id", "INT PK 自增", T`主键`],
    ["name", "VARCHAR(100)", T`赛事名称，如“2026年春季运动会”`],
    ["start_date / end_date", "DATE", T`起止日期`],
  ]),
  para(run(T`表 4  比赛项目表 sport_item`, { bold: true, size: 21 }), { alignment: AlignmentType.CENTER, spacing: { before: 160, after: 80 } }),
  table([1800, 1800, 4600], [
    ["字段", "类型", "说明"],
    ["id", "INT PK 自增", T`主键`],
    ["event_id", "INT FK", T`所属赛事，外键引用 event(id)`],
    ["name", "VARCHAR(100)", T`项目名称，如“男子100米”`],
    ["unit", "VARCHAR(20)", T`成绩单位（秒/米）`],
    ["record_type", "VARCHAR(20)", T`time 计时型（越小越好）/ distance 距离型（越大越好）`],
    ["gender", "VARCHAR(10)", T`性别限制：男 / 女 / 不限`],
  ]),
  para(run(T`表 5  运动员报名表 athlete`, { bold: true, size: 21 }), { alignment: AlignmentType.CENTER, spacing: { before: 160, after: 80 } }),
  table([1800, 1800, 4600], [
    ["字段", "类型", "说明"],
    ["id", "INT PK 自增", T`主键`],
    ["user_id / event_id", "INT FK", T`对应账号、所报赛事`],
    ["department", "VARCHAR(100)", T`院系，用于按院系统计`],
    ["name / gender", "VARCHAR", T`姓名、性别`],
    ["status", "INT", T`资格审查：0 待审核 / 1 通过 / 2 驳回，默认 0`],
  ]),
  para(run(T`表 6  成绩表 score`, { bold: true, size: 21 }), { alignment: AlignmentType.CENTER, spacing: { before: 160, after: 80 } }),
  table([1800, 1800, 4600], [
    ["字段", "类型", "说明"],
    ["id", "INT PK 自增", T`主键`],
    ["item_id / athlete_id", "INT FK", T`所属项目、运动员`],
    ["value / unit", "DOUBLE / VARCHAR(20)", T`成绩值与单位`],
    ["is_foul", "INT", T`0 正常 / 1 犯规，犯规成绩不计入排名`],
    ["is_finished", "INT", T`0 未完成 / 1 完成，未完成任务不计入排名`],
    ["is_record", "INT", T`0 普通 / 1 破纪录（与历届同名项目赛前最好成绩比较得出）`],
    ["rank", "INT 可空", T`排名；rank 是 MySQL 8.0 保留字，建表需加反引号`],
    ["create_time", "TIMESTAMP", T`录入时间，默认当前时间`],
  ]),
  body(T`完整建表 SQL 脚本（含测试数据）见附录 A。测试数据设计了两届赛事：2025 年秋季运动会作为“历史纪录”基准（男子 100 米 11.40 秒、男子跳远 6.30 米），2026 年春季运动会中包含破纪录、抢跑犯规、未完成、同一运动员多条成绩等各类典型数据，便于验证算法正确性。`),
  h2(T`2.3 界面与安全设计`),
  body(T`界面方面，全部页面引入 Bootstrap 统一美化，导航、卡片、表格、表单控件风格一致；成绩展示采用“赛事 → 项目”分榜结构，每个项目独立成榜，前三名以金、银、铜牌样式突出显示，符合真实运动会的呈现习惯。登录失败时页面显示错误提示，并通过 JavaScript 的 setTimeout 延迟 3 秒后自动跳转回登录界面。`),
  body(T`安全方面：密码以 MD5 摘要存储与比对，数据库不落明文；所有 SQL 使用 PreparedStatement 参数化，防止 SQL 注入；LoginFilter 拦截未登录用户访问运动员页面，AdminFilter 拦截非管理员访问后台（302 重定向到管理员登录页）；前台登录与后台登录为两个独立入口，运动员账号无法从管理员入口登录。`),
);

/* 第3章 */
bodyChildren.push(
  h1(T`3．核心算法与关键实现`),
  h2(T`3.1 成绩排名算法`),
  body(T`排名是本系统的核心难点，需要同时解决三个问题：不同项目的排序方向不同；同一运动员在同一项目可能有多条成绩（真实运动会规则为每人每项只占一个名次）；犯规与未完成成绩不参与排名。`),
  body(T`排序方向的统一处理依赖项目表的 record_type 字段：在 ORDER BY 中使用 CASE WHEN，计时型项目按成绩升序、距离型项目按成绩降序，一段 SQL 同时适配两类项目。每人每项只取最好成绩通过 NOT EXISTS 子查询实现——仅当“不存在同一运动员在同一项目中更好的另一条有效成绩”时，该条成绩才进入排名。“更好”的比较同样按 record_type 分方向，并以成绩相等时 id 较小者优先作为决胜规则，保证结果确定性。排名计算使用 MySQL 8.0 窗口函数 RANK() OVER (PARTITION BY item_id …)，按项目分区排名，核心 SQL 如下（ScoreServlet 中 op=rank 分支）：`),
);
bodyChildren.push(
  code(T`UPDATE score sc LEFT JOIN (`),
  code(T`  SELECT b.id, RANK() OVER (PARTITION BY b.item_id ORDER BY`),
  code(T`    CASE WHEN sp.record_type='time'     THEN b.value END ASC,`),
  code(T`    CASE WHEN sp.record_type='distance' THEN b.value END DESC) rk`),
  code(T`  FROM score b JOIN sport_item sp ON b.item_id = sp.id`),
  code(T`  WHERE b.is_foul = 0 AND b.is_finished = 1   -- 犯规/未完成不排名`),
  code(T`  AND NOT EXISTS (   -- 每人每项仅保留最好成绩`),
  code(T`    SELECT 1 FROM score s2`),
  code(T`    WHERE s2.item_id = b.item_id AND s2.athlete_id = b.athlete_id`),
  code(T`      AND s2.is_foul = 0 AND s2.is_finished = 1`),
  code(T`      AND ((sp.record_type='time'     AND s2.value < b.value)`),
  code(T`        OR (sp.record_type='distance' AND s2.value > b.value)`),
  code(T`        OR (s2.value = b.value AND s2.id < b.id))))`),
  code(T`) t ON sc.id = t.id SET sc.rank = t.rk;`),
  para(run(""), { spacing: { after: 120 } }),
  body(T`由于采用 LEFT JOIN 回写，未进入排名子查询的成绩（犯规、未完成、非本人最好成绩）其 rank 自然保持 NULL，页面上显示为“—”，实现“犯规成绩不计入排名”的要求。成绩的录入、修改、删除操作完成后都会重定向到排名刷新逻辑，保证榜单始终为最新。`),
  h2(T`3.2 破纪录判定`),
  body(T`破纪录判定在成绩录入/修改时完成。系统查找“更早举办的赛事中同名项目”的历史最好有效成绩作为赛前纪录：计时型项目取 MIN(value)，距离型项目取 MAX(value)；若新成绩优于该纪录（计时型更小、距离型更大），则将 is_record 置 1。只与更早的赛事比较而忽略同届赛事，避免了同届运动员互超被反复标记为破纪录的问题；若该项目历史上从未举办过，则无纪录可破。页面榜单中破纪录成绩以“破纪录”徽标显示。`),
  h2(T`3.3 跨表聚合统计`),
  body(T`多维统计在 StatServlet 中实现，将成绩表 score、项目表 sport_item、运动员表 athlete 三表连接后按不同维度 GROUP BY 汇总。两个维度（项目×院系、项目×性别）共用同一段聚合 SQL，仅维度列不同。“最好成绩”的计算同样区分排序方向：计时型取最小值、距离型取最大值，使用带条件的聚合函数实现，避免 MIN() 对距离型项目算出错误的“最好成绩”。核心 SQL 如下：`),
  code(T`SELECT sp.name item_name, <维度列> dim, COUNT(*) countNum,`),
  code(T`  MIN(CASE WHEN sp.record_type='time'     THEN s.value END) bestTime,`),
  code(T`  MAX(CASE WHEN sp.record_type='distance' THEN s.value END) bestDist,`),
  code(T`  sp.record_type recordType`),
  code(T`FROM score s`),
  code(T`LEFT JOIN sport_item sp ON s.item_id = sp.id`),
  code(T`LEFT JOIN athlete  ath ON s.athlete_id = ath.id`),
  code(T`WHERE s.is_foul = 0 AND s.is_finished = 1`),
  code(T`GROUP BY sp.name, <维度列>, sp.record_type;   -- 维度列取 ath.department 或 ath.gender`),
  para(run(""), { spacing: { after: 120 } }),
  body(T`统计页面除两张汇总表格外，还使用 Chart.js 绘制各院系有效成绩数量柱状图与报名运动员男女比例饼图，直观呈现统计结果。`),
  h2(T`3.4 登录验证与安全防护`),
  body(T`登录验证流程：用户在登录页提交账号密码 → JavaScript 先进行非空等有效性验证 → Servlet 接收参数（先做 trim 处理，防止空格绕过唯一性判断）→ 将密码做 MD5 后与数据库比对 → 成功则写入 Session 并按角色跳转主页，失败则返回登录页显示错误提示并延迟 3 秒自动返回。后台管理员使用独立登录页与独立 Servlet 分支，验证时额外要求 role 为 admin，运动员账号无法登录后台。过滤器 LoginFilter、AdminFilter 在请求到达页面前统一检查 Session 中的登录态与角色，未通过者 302 重定向到对应登录页。`),
);

/* 第4章 */
bodyChildren.push(
  h1(T`4．程序流程图`),
  body(T`成绩录入与排名、破纪录判定是系统最核心的业务流程，如图 4 所示：裁判录入成绩后经服务器端校验写入数据库；若成绩被标记为犯规或未完成，则 rank 置空不参与排名；有效成绩进入 RANK() 窗口函数按项目分区排名，并与赛前历史纪录比较，优于纪录者标记破纪录；最后将排名与纪录标记回写数据库。`),
  img("fig_flow.png", 330, Math.round(330 * 1366 / 1200)),
  caption(T`图 4  成绩排名与破纪录判定流程`),
  body(T`其余主要流程：用户登录流程为“提交表单 → JS 校验 → 数据库验证 → 成功进入主页 / 失败提示并 3 秒后返回登录页”；运动员报名流程为“选择赛事 → 填写院系等信息 → 提交（status=0）→ 管理员资格审查（通过/驳回）→ 运动员在个人中心查看审核结果与成绩”。`),
);

/* 第5章 */
bodyChildren.push(
  h1(T`5．程序运行的测试与分析`),
  h2(T`5.1 测试环境`),
  body(T`操作系统 Windows；JDK 17；Web 服务器 Apache Tomcat 10.1；数据库 MySQL 8.0（数据库名 sportsdb，账号 root）；浏览器 Microsoft Edge / Chrome。部署方式：编译后的 class 文件与 JSP、静态资源部署在 Tomcat 的 webapps/javaweb 目录下，访问入口 http://localhost:8080/javaweb/。测试账号：管理员 admin/123456，运动员 zhangsan/123456 等（密码均存 MD5 摘要）。`),
  h2(T`5.2 测试用例与结果`),
);

bodyChildren.push(table([700, 2600, 2600, 1150, 1150], [
  ["编号", "测试内容", "输入/操作", "预期结果", "实际结果"],
  ["T01", T`管理员登录`, "admin / 123456", T`进入后台主页`, T`通过`],
  ["T02", T`错误密码登录`, "admin / 错误密码", T`提示错误，3 秒后自动返回登录页`, T`通过`],
  ["T03", T`运动员闯后台入口`, "zhangsan / 123456 在管理员登录页登录", T`拒绝并提示非管理员`, T`通过`],
  ["T04", T`未登录访问后台`, T`直接访问 scoreServlet`, T`302 重定向到管理员登录页`, T`通过`],
  ["T05", T`运动员注册`, T`填写表单注册新账号`, T`注册成功并可登录`, T`通过`],
  ["T06", T`运动员报名与审核`, T`报名赛事，管理员通过/驳回`, T`状态正确流转并可见`, T`通过`],
  ["T07", T`成绩录入与自动排名`, T`录入 2026 春男子 100 米成绩后刷新排名`, T`按用时升序排名，取每人最好成绩`, T`通过`],
  ["T08", T`犯规成绩不排名`, T`录入 is_foul=1 的成绩`, T`成绩保留但 rank 为空，不占用名次`, T`通过`],
  ["T09", T`破纪录判定`, T`李四 100 米 11.20 < 历史 11.40`, T`标记“破纪录”徽标`, T`通过`],
  ["T10", T`同届互超不算破纪录`, T`同届多人依次刷新最好成绩`, T`仅与赛前纪录比较`, T`通过`],
  ["T11", T`按姓名查询成绩`, T`综合查询输入“张三”`, T`列出张三各项成绩`, T`通过`],
  ["T12", T`按成绩区间查询`, T`100 米成绩区间 11.0~11.5 秒`, T`仅列出区间内成绩`, T`通过`],
  ["T13", T`多维统计`, T`打开多维统计页`, T`项目×院系、项目×性别汇总正确`, T`通过`],
  ["T14", T`表单 JS 校验`, T`登录/注册/录入留空或非法输入`, T`前端即时提示，不提交`, T`通过`],
]));

bodyChildren.push(
  para(run(T`测试分析：`, { bold: true }), { indent: { firstLine: convertInchesToTwip(0.33) } }),
  body(T`T07～T10 覆盖了排名算法的四个关键边界：方向统一（计时升序/距离降序）、每人取最好成绩、犯规与未完成剔除、破纪录仅与赛前纪录比较。其中 T08 验证了“犯规成绩保留在成绩单中展示但不计入排名”这一题目关键要求；T10 验证了破纪录判定的届次边界。T11、T12 验证了综合查询的组合条件能力，测试中发现并修复了“按运动员姓名查询无结果”的缺陷（查询条件原本只匹配项目名，修复后姓名作为独立条件 kw2 参与匹配）。`),
  h2(T`5.3 系统运行截图`),
  img("shot_login.png", 360, Math.round(360 * 1516 / 1288)),
  caption(T`图 5  登录页面`),
  img("shot_guest.png", 360, Math.round(360 * 1516 / 1288)),
  caption(T`图 6  游客首页（免登录浏览赛事与成绩排名）`),
  img("shot_score.png", 360, Math.round(360 * 1516 / 1288)),
  caption(T`图 7  成绩管理——按“赛事→项目”分榜展示排名、破纪录与犯规标记`),
  img("shot_stat.png", 360, Math.round(360 * 1516 / 1288)),
  caption(T`图 8  多维统计——按项目×院系、项目×性别汇总`),
  img("shot_query.png", 360, Math.round(360 * 1516 / 1288)),
  caption(T`图 9  综合查询页面`),
);

/* 第6章 */
bodyChildren.push(
  h1(T`6．存在的问题与心得体会`),
  h2(T`6.1 存在的问题`),
  body(T`（1）密码使用 MD5 摘要存储，MD5 已不属于强哈希算法，生产环境应改用 BCrypt 等带盐的慢哈希；（2）报名与成绩录入尚无并发控制，极端情况下同一运动员可能出现重复报名记录，可通过数据库唯一约束进一步约束；（3）统计维度目前固定为项目×院系与项目×性别两组，暂不支持自定义维度组合；（4）成绩录入为逐条手工录入，缺少 Excel 批量导入能力。`),
  h2(T`6.2 心得体会`),
  body(T`通过本次课程设计，完整地走通了一个 Web 应用从需求分析、数据库设计、编码实现到测试部署的全过程。最大的收获是对“把业务规则翻译成 SQL”的理解：排名问题表面上是排序，实际涉及排序方向建模（record_type）、“每人每项一个名次”的业务约束（NOT EXISTS）、无效数据剔除（WHERE 过滤）与窗口函数（RANK()）的综合运用；统计问题则训练了多表连接配合条件聚合（CASE WHEN + MIN/MAX）的写法。其次，不依赖框架手写 MVC 分层，让我真正理解了请求从浏览器到数据库再渲染回页面的完整链路，以及过滤器在权限控制中的作用。UI 调优过程中也体会到“界面是为数据服务的”——成绩榜按项目分类、奖牌样式突出前三名等细节，比花哨的视觉效果更能提升可用性。`),
);

/* 附录 */
bodyChildren.push(
  pageBreak(),
  h1(T`附录A 建表 SQL 脚本（含测试数据）`),
  body(T`以下为数据库 sportsdb 的完整建库建表与测试数据脚本（sportsdb.sql）。注意 rank 为 MySQL 8.0 保留字，建表时必须使用反引号。`),
);
const sqlLines = fs.readFileSync(path.join(path.dirname(outputPath), "sportsdb.sql"), "utf8")
  .split(/\r?\n/).filter((l) => l.trim().length > 0);
for (const line of sqlLines) bodyChildren.push(code(line));

/* ---------- 文档组装 ---------- */
const doc = new Document({
  features: { updateFields: true },
  sections: [
    { // 封面：无页眉页脚页码
      properties: { page: { margin: { top: 1440, bottom: 1440, left: 1800, right: 1800 } } },
      children: coverChildren,
    },
    { // 目录+正文
      properties: {
        type: SectionType.NEXT_PAGE,
        page: {
          margin: { top: 1440, bottom: 1440, left: 1800, right: 1800 },
          pageNumbers: { start: 1, formatType: "decimal" },
        },
      },
      headers: {
        default: new Header({
          children: [para(run(T`Web应用开发实训课程设计报告`, { size: 18, color: GRAY }), {
            alignment: AlignmentType.CENTER,
            border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "9E9E9E", space: 4 } },
            spacing: { after: 0 },
          })],
        }),
      },
      footers: {
        default: new Footer({
          children: [para(new TextRun({ children: [PageNumber.CURRENT], font, size: 18, color: GRAY }), { alignment: AlignmentType.CENTER })],
        }),
      },
      children: [
        para(run(T`目　　录`, { bold: true, size: 32, font: hei }), { alignment: AlignmentType.CENTER, spacing: { before: 240, after: 240 } }),
        toc(),
        pageBreak(),
        ...bodyChildren,
      ],
    },
  ],
});

fs.writeFileSync(outputPath, await Packer.toBuffer(doc));
console.log("written:", outputPath);
