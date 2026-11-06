# -*- coding: utf-8 -*-
"""生成课程设计报告插图：数据流图、ER图、MVC架构图、排名算法流程图"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch
import os

plt.rcParams["font.family"] = ["Microsoft YaHei", "SimHei"]
plt.rcParams["axes.unicode_minus"] = False

OUT = os.path.dirname(os.path.abspath(__file__))

INK = "#263238"
BOX_FC = "#FFFFFF"
BOX_EC = "#37474F"
ACCENT = "#546E7A"
LIGHT = "#ECEFF1"


def box(ax, x, y, w, h, text, fc=BOX_FC, ec=BOX_EC, fs=11, bold=False, rounded=True):
    style = "round,pad=0.02,rounding_size=0.06" if rounded else "square,pad=0.02"
    p = FancyBboxPatch((x - w / 2, y - h / 2), w, h, boxstyle=style,
                       fc=fc, ec=ec, lw=1.4)
    ax.add_patch(p)
    ax.text(x, y, text, ha="center", va="center", fontsize=fs,
            color=INK, fontweight="bold" if bold else "normal")


def arrow(ax, x1, y1, x2, y2, text=None, fs=9, rad=0.0, toffset=(0, 0.12)):
    a = FancyArrowPatch((x1, y1), (x2, y2), arrowstyle="-|>",
                        mutation_scale=14, lw=1.3, color=ACCENT,
                        connectionstyle=f"arc3,rad={rad}")
    ax.add_patch(a)
    if text:
        ax.text((x1 + x2) / 2 + toffset[0], (y1 + y2) / 2 + toffset[1], text,
                ha="center", va="center", fontsize=fs, color=ACCENT)


# ============ 图1 数据流图 ============
fig, ax = plt.subplots(figsize=(9.2, 5.4), dpi=160)
ax.set_xlim(0, 10); ax.set_ylim(0, 6); ax.axis("off")

box(ax, 1.3, 4.7, 1.9, 0.8, "游客", LIGHT)
box(ax, 1.3, 3.2, 1.9, 0.8, "运动员", LIGHT)
box(ax, 1.3, 1.5, 1.9, 0.9, "管理员/裁判", LIGHT)

box(ax, 5.0, 4.7, 2.6, 0.9, "前台浏览/查询\nJSP + QueryServlet", "#FFFFFF", fs=10)
box(ax, 5.0, 3.2, 2.6, 0.9, "报名/个人成绩\nAthleteServlet", "#FFFFFF", fs=10)
box(ax, 5.0, 1.5, 2.6, 1.0, "后台管理\n各管理Servlet", "#FFFFFF", fs=10)

box(ax, 8.6, 3.1, 1.7, 1.6, "MySQL\nsportsdb\n五张核心表", "#E3E8EA", fs=10, bold=True)

arrow(ax, 2.25, 4.7, 3.7, 4.7, "浏览请求", toffset=(0, 0.16))
arrow(ax, 2.25, 3.2, 3.7, 3.2, "注册/报名", toffset=(0, 0.16))
arrow(ax, 2.25, 1.5, 3.7, 1.5, "管理指令", toffset=(0, 0.16))
arrow(ax, 6.3, 4.7, 8.0, 3.6, "读", toffset=(0.05, 0.14), rad=-0.15)
arrow(ax, 6.3, 3.2, 7.75, 3.2, "读/写", toffset=(0, 0.16))
arrow(ax, 6.3, 1.5, 8.0, 2.6, "读/写", toffset=(0.05, -0.2), rad=0.15)
arrow(ax, 3.7, 4.35, 2.25, 4.35, "", rad=0.0)
ax.text(3.0, 4.08, "成绩/排名", ha="center", fontsize=9, color=ACCENT)

ax.text(5.0, 0.35, "图1  系统数据流图", ha="center", fontsize=12, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(os.path.join(OUT, "fig_dfd.png"), bbox_inches="tight", facecolor="white")
plt.close(fig)

# ============ 图2 ER 图 ============
fig, ax = plt.subplots(figsize=(9.6, 6.2), dpi=160)
ax.set_xlim(0, 12); ax.set_ylim(0, 8); ax.axis("off")

def entity(ax, x, y, title, attrs, w=2.9):
    h = 0.55 + 0.34 * len(attrs)
    ax.add_patch(FancyBboxPatch((x - w / 2, y - h / 2), w, h,
                 boxstyle="square,pad=0.02", fc="#FFFFFF", ec=BOX_EC, lw=1.4))
    ax.add_patch(mpatches.Rectangle((x - w / 2, y + h / 2 - 0.5), w, 0.5,
                 fc=ACCENT, ec=BOX_EC, lw=1.2))
    ax.text(x, y + h / 2 - 0.25, title, ha="center", va="center",
            fontsize=11, color="white", fontweight="bold")
    for i, a in enumerate(attrs):
        ax.text(x - w / 2 + 0.14, y + h / 2 - 0.5 - 0.17 - 0.34 * i, a,
                ha="left", va="center", fontsize=9, color=INK)
    return (x, y, w, h)

def diamond(ax, x, y, text, w=1.5, h=0.66):
    ax.add_patch(mpatches.FancyBboxPatch((x - w / 2, y - h / 2), w, h,
                 boxstyle="round,pad=0.02", fc=LIGHT, ec=ACCENT, lw=1.2))
    ax.text(x, y, text, ha="center", va="center", fontsize=9.5, color=INK)

def link(ax, p1, p2, label1=None, label2=None):
    ax.plot([p1[0], p2[0]], [p1[1], p2[1]], color=ACCENT, lw=1.2)
    if label1:
        ax.text(p1[0] + 0.08, p1[1] - 0.22, label1, fontsize=9, color=ACCENT)
    if label2:
        ax.text(p2[0] - 0.3, p2[1] - 0.22, label2, fontsize=9, color=ACCENT)

u = entity(ax, 2.0, 6.3, "user 用户", ["id (PK)", "username", "password(MD5)", "role"])
e = entity(ax, 9.9, 6.3, "event 赛事", ["id (PK)", "name", "start_date", "end_date"])
a = entity(ax, 2.0, 2.6, "athlete 运动员", ["id (PK)", "user_id (FK)", "event_id (FK)",
            "department", "name", "gender", "status"])
i = entity(ax, 9.9, 2.6, "sport_item 项目", ["id (PK)", "event_id (FK)", "name",
            "unit", "record_type", "gender"])
s = entity(ax, 6.0, 1.0, "score 成绩", ["id (PK)", "item_id (FK)", "athlete_id (FK)",
            "value", "is_foul", "is_finished", "is_record", "rank"], w=3.3)

link(ax, (u[0], u[1] - u[3] / 2), (a[0], a[1] + a[3] / 2))
ax.text(2.25, 4.55, "1 : n  注册", fontsize=9.5, color=ACCENT)
link(ax, (e[0], e[1] - e[3] / 2), (i[0], i[1] + i[3] / 2))
ax.text(9.6, 4.55, "1 : n  包含", fontsize=9.5, color=ACCENT)
link(ax, (e[0] - e[2] / 2, e[1]), (a[0] + a[2] / 2, a[1] + 0.6))
ax.text(6.0, 5.7, "1 : n  报名", fontsize=9.5, color=ACCENT)
link(ax, (a[0] + a[2] / 2, a[1] - 0.4), (s[0] - 1.0, s[1] + s[3] / 2))
ax.text(3.9, 2.9, "1 : n", fontsize=9.5, color=ACCENT)
link(ax, (i[0] - i[2] / 2, i[1] - 0.4), (s[0] + 1.0, s[1] + s[3] / 2))
ax.text(7.35, 3.0, "1 : n  产生", fontsize=9.5, color=ACCENT)

ax.text(6.0, 7.7, "图2  系统 ER 图", ha="center", fontsize=12, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(os.path.join(OUT, "fig_er.png"), bbox_inches="tight", facecolor="white")
plt.close(fig)

# ============ 图3 MVC 架构图 ============
fig, ax = plt.subplots(figsize=(9.2, 4.6), dpi=160)
ax.set_xlim(0, 10); ax.set_ylim(0, 5); ax.axis("off")

box(ax, 1.2, 2.6, 1.6, 1.1, "浏览器\n(Bootstrap/JS)", LIGHT, fs=10)
box(ax, 4.0, 3.7, 2.0, 0.95, "V 视图层\nJSP 页面", "#FFFFFF", fs=10, bold=True)
box(ax, 4.0, 1.6, 2.0, 0.95, "C 控制层\nServlet/Filter", "#FFFFFF", fs=10, bold=True)
box(ax, 6.9, 2.6, 1.9, 1.1, "M 模型层\nJavaBean + DAO\n(JDBC)", "#FFFFFF", fs=10, bold=True)
box(ax, 9.2, 2.6, 1.1, 1.1, "MySQL\n数据库", "#E3E8EA", fs=10, bold=True)

arrow(ax, 2.0, 2.95, 3.0, 3.55, "请求", toffset=(-0.05, 0.14))
arrow(ax, 3.0, 3.35, 2.0, 2.35, "渲染HTML", toffset=(0.3, -0.1))
arrow(ax, 2.0, 2.25, 3.0, 1.7, "", rad=0.0)
arrow(ax, 5.0, 3.7, 5.0, 2.1, "转发/分发", toffset=(0.62, 0))
arrow(ax, 5.0, 1.85, 6.0, 2.35, "", rad=0.0)
arrow(ax, 6.0, 2.85, 5.0, 3.45, "", rad=0.0)
arrow(ax, 7.85, 2.6, 8.65, 2.6, "SQL", toffset=(0, 0.16))
ax.text(8.25, 2.3, "结果集", ha="center", fontsize=9, color=ACCENT)

ax.text(5.0, 0.3, "图3  MVC 分层架构图", ha="center", fontsize=12, color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(os.path.join(OUT, "fig_mvc.png"), bbox_inches="tight", facecolor="white")
plt.close(fig)

# ============ 图4 排名算法流程图 ============
fig, ax = plt.subplots(figsize=(7.6, 8.6), dpi=160)
ax.set_xlim(0, 8); ax.set_ylim(0, 12); ax.axis("off")

box(ax, 4, 11.4, 2.6, 0.7, "裁判录入成绩", ACCENT, fs=11, bold=True)
ax.texts[-1].set_color("white")
box(ax, 4, 10.2, 3.2, 0.75, "服务器端校验\n(数值合法性/运动员资格审核)", fs=10)
box(ax, 4, 9.0, 2.6, 0.85, "写入 score 表\n(is_foul / is_finished)", fs=10)

# 判定菱形
ax.add_patch(mpatches.Polygon([(4, 6.95), (5.9, 7.7), (4, 8.45), (2.1, 7.7)],
             fc=LIGHT, ec=BOX_EC, lw=1.4))
ax.text(4, 7.7, "犯规或未\n完成?", ha="center", va="center", fontsize=10, color=INK)

box(ax, 6.9, 7.0, 1.8, 0.8, "rank 置空\n不参与排名", "#FFFFFF", fs=9.5)
box(ax, 4, 5.85, 3.4, 0.95, "RANK() 窗口函数\n按 record_type 统一排序方向\n(time 升序 / distance 降序)", fs=9.5)
box(ax, 4, 4.55, 3.2, 0.8, "NOT EXISTS 过滤\n每人每项仅保留最好成绩", fs=9.5)

ax.add_patch(mpatches.Polygon([(4, 2.6), (5.7, 3.3), (4, 4.0), (2.3, 3.3)],
             fc=LIGHT, ec=BOX_EC, lw=1.4))
ax.text(4, 3.3, "优于赛前\n历史纪录?", ha="center", va="center", fontsize=10, color=INK)

box(ax, 6.9, 3.0, 1.7, 0.7, "标记\nis_record=1", "#FFFFFF", fs=9.5)
box(ax, 4, 1.4, 3.0, 0.7, "回写 rank / is_record", fs=10)
box(ax, 4, 0.4, 2.2, 0.6, "结束", ACCENT, fs=10, bold=True)
ax.texts[-1].set_color("white")

arrow(ax, 4, 11.05, 4, 10.6)
arrow(ax, 4, 9.82, 4, 9.45)
arrow(ax, 4, 8.57, 4, 8.47)
arrow(ax, 5.9, 7.7, 6.9, 7.41, "是", toffset=(0.25, 0.1))
arrow(ax, 4, 6.95, 4, 6.35, "否", toffset=(0.25, 0.05))
arrow(ax, 6.9, 6.6, 5.75, 5.85, "", rad=-0.25)
arrow(ax, 4, 5.37, 4, 4.97)
arrow(ax, 4, 4.14, 4, 4.02)
arrow(ax, 5.7, 3.3, 6.03, 3.3, "是", toffset=(0, 0.16))
arrow(ax, 4, 2.6, 4, 1.77, "否", toffset=(0.25, 0))
arrow(ax, 6.9, 2.65, 5.55, 1.55, "", rad=-0.2)
arrow(ax, 4, 1.05, 4, 0.72)

ax.text(4, -0.35, "图4  成绩排名与破纪录判定流程", ha="center", fontsize=12,
        color=INK, fontweight="bold")
fig.tight_layout()
fig.savefig(os.path.join(OUT, "fig_flow.png"), bbox_inches="tight", facecolor="white")
plt.close(fig)

print("figures done:", os.listdir(OUT))
