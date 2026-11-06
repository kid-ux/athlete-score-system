-- 运动员成绩管理系统 建库建表脚本
-- 对应代码中的字段；注意 rank 是 MySQL 8.0 保留字，必须用反引号

CREATE DATABASE IF NOT EXISTS sportsdb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE sportsdb;

-- 用户表：admin 管理员 / athlete 运动员；密码存 MD5 摘要
CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(64) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'athlete'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 赛事表
CREATE TABLE IF NOT EXISTS event (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 比赛项目表
CREATE TABLE IF NOT EXISTS sport_item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_id INT,
    name VARCHAR(100) NOT NULL,
    unit VARCHAR(20),
    record_type VARCHAR(20),   -- time 计时(越小越好) / distance 距离(越大越好)
    gender VARCHAR(10),        -- 男 / 女 / 不限
    FOREIGN KEY (event_id) REFERENCES event(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 运动员报名表
CREATE TABLE IF NOT EXISTS athlete (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    event_id INT,
    department VARCHAR(100),
    name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    status INT DEFAULT 0,       -- 资格审查状态：0待审核 1通过 2驳回
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (event_id) REFERENCES event(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 成绩表
CREATE TABLE IF NOT EXISTS score (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
    athlete_id INT,
    value DOUBLE,
    unit VARCHAR(20),
    is_foul INT DEFAULT 0,      -- 0正常 1犯规
    is_finished INT DEFAULT 0,  -- 0未完成 1完成
    is_record INT DEFAULT 0,    -- 0普通 1破纪录（录入时与历届同名项目的赛前最好成绩比较得出）
    `rank` INT NULL,            -- 排名（保留字需反引号；代码中用 sc.rank 限定名访问没问题）
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES sport_item(id),
    FOREIGN KEY (athlete_id) REFERENCES athlete(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============ 测试数据 ============

-- 账号：admin/123456（管理员），其余为运动员账号，密码均 123456（存 MD5 摘要）
INSERT INTO user (username, password, role) VALUES
('admin', 'e10adc3949ba59abbe56e057f20f883e', 'admin'),
('zhangsan', 'e10adc3949ba59abbe56e057f20f883e', 'athlete'),
('lisi', 'e10adc3949ba59abbe56e057f20f883e', 'athlete'),
('wangwu', 'e10adc3949ba59abbe56e057f20f883e', 'athlete'),
('zhaoliu', 'e10adc3949ba59abbe56e057f20f883e', 'athlete');

-- 赛事：2025 秋季在前，作为 2026 春季的"历史纪录"基准
INSERT INTO event (name, start_date, end_date) VALUES
('2025年秋季运动会', '2025-10-16', '2025-10-18'),
('2026年春季运动会', '2026-04-10', '2026-04-12'),
('2026年秋季运动会', '2026-10-15', '2026-10-17');

-- 比赛项目：time 用时型(越小越好) / distance 距离型(越大越好)
INSERT INTO sport_item (event_id, name, unit, record_type, gender) VALUES
(1, '男子100米', '秒', 'time', '男'),
(1, '男子跳远', '米', 'distance', '男'),
(2, '男子100米', '秒', 'time', '男'),
(2, '男子跳远', '米', 'distance', '男'),
(2, '女子800米', '秒', 'time', '女'),
(2, '铅球', '米', 'distance', '不限');

-- 运动员报名（含一条待审核、一条驳回，方便演示资格审查；含上届赛事报名）
INSERT INTO athlete (user_id, event_id, department, name, gender, status) VALUES
(2, 2, '计算机学院', '张三', '男', 1),
(3, 2, '机械学院', '李四', '男', 1),
(4, 2, '外国语学院', '王五', '女', 1),
(5, 2, '计算机学院', '赵六', '女', 0),
(3, 3, '机械学院', '李四', '男', 2),
(3, 1, '机械学院', '李四', '男', 1);

-- 成绩（含犯规、未完成、破纪录示例；rank 已按规则预排，管理端点"自动刷新排名"可复算）
-- 破纪录基准：2025 秋季 男子100米 11.40 秒、男子跳远 6.30 米
INSERT INTO score (item_id, athlete_id, value, unit, is_foul, is_finished, is_record, `rank`) VALUES
(1, 6, 11.40, '秒', 0, 1, 0, 1),   -- 2025秋 李四 100米（历史纪录基准，首届无纪录可破）
(2, 6, 6.30, '米', 0, 1, 0, 1),    -- 2025秋 李四 跳远（历史纪录基准）
(3, 1, 11.50, '秒', 0, 1, 0, NULL),-- 2026春 张三 100米（非本人最好成绩，不参与排名）
(3, 2, 11.20, '秒', 0, 1, 1, 1),   -- 2026春 李四 100米 11.20 < 11.40，破纪录
(3, 2, 10.90, '秒', 1, 1, 0, NULL),-- 李四抢跑犯规，不计排名
(4, 1, 6.10, '米', 0, 1, 0, 2),    -- 张三 跳远（未超 6.30）
(4, 2, 6.50, '米', 0, 1, 1, 1),    -- 李四 跳远 6.50 > 6.30，破纪录
(4, 1, 0.00, '米', 0, 0, 0, NULL), -- 张三 跳远 未完成，不计排名
(5, 3, 150.50, '秒', 0, 1, 0, 1),  -- 王五 女子800米（无历史同名项目，无纪录可破）
(6, 1, 10.20, '米', 0, 1, 0, 1),   -- 张三 铅球
(3, 1, 10.40, '秒', 0, 1, 1, 1);   -- 张三 100米 10.40 < 11.40，破纪录（同一运动员取最好成绩排第1）
