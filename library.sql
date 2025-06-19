-- 图书管理系统数据库
-- 先删除现有数据库，重新创建
drop database if exists library;
create database library;
use library;

-- 1、读者种类表
drop table if exists r_category;
create table r_category(
    id int primary key auto_increment,
    name varchar(32) unique not null,
    amount int not null,
    lend_period int not null comment '一次借书的期限天数',
    effect_period date not null comment '仅在毕业前借书有效',
    notes varchar(255) null
);


-- 2、读者表
drop table if exists reader;
create table reader(
    id int primary key auto_increment,
    name varchar(32) not null,
    category_id int not null comment '读者种类',
    sex tinyint not null default 1,
    w_address varchar(255) not null,
    h_address varchar(255) not null,
    phone varchar(11) unique not null,
    email varchar(64) null,
    create_time datetime not null default now(),
    notes varchar(255) null
);


-- 3、书籍种类表
drop table if exists b_category;
create table b_category(
    id int primary key auto_increment,
    name varchar(32) unique not null,
    keywords varchar(32) null,
    notes varchar(255) null
);


-- 4、书籍表
drop table if exists book;
create table book(
    id int primary key auto_increment,
    name varchar(32) not null,
    category_id int not null comment '书籍种类',
    author varchar(32) not null,
    press varchar(32) not null,
    publish_date date not null,
    price decimal(10, 2) not null,
    page_number int not null,
    keywords varchar(32) null,
    create_time datetime not null default now(),
    status tinyint not null default 0,
    notes varchar(255) null
);


-- 5、借书还书表
drop table if exists lend_return;
create table lend_return(
    id int primary key auto_increment,
    r_id int not null,
    b_id int not null,
    lend_date date not null default (curdate()),
    return_date date null,
    status int null default 0 comment '归还状态，0: 出借中  1：正常归还  2：逾期归还  3：丢失无法归还  4：损坏归还  5：其他(备注说明)',
    notes varchar(255) null
);
-- 添加外键约束关联: 读者和书籍id
alter table lend_return add constraint fk_r_id foreign key (r_id)
    references reader(id) on update cascade on delete cascade;
alter table lend_return add constraint fk_b_id foreign key (b_id)
    references book(id) on update cascade on delete cascade;
-- return_date可以为null
alter table lend_return modify return_date date null;

-- 6、管理员表
drop table if exists manager;
create table manager(
    id int primary key auto_increment,
    name varchar(32) unique not null,
    password varchar(32) not null
);

-- 示例数据
-- 插入示例数据到 b_category 表中
INSERT INTO b_category (name, keywords, notes) VALUES
('计算机技术', '编程, 软件开发, 人工智能', '计算机科学与技术类书籍，包括编程语言、算法、AI等'),
('商业管理', '管理学, 企业运营, 市场营销', '商业管理类书籍，涵盖企业管理、战略规划、营销等'),
('自然科学', '物理, 化学, 生物学', '自然科学类书籍，包括基础科学和应用科学研究'),
('医学健康', '临床医学, 预防医学, 养生保健', '医学健康类书籍，涵盖医疗、健康、养生等领域'),
('工程技术', '机械工程, 电子工程, 建筑工程', '工程技术类书籍，包括各类工程学科和技术应用'),
('社会科学', '心理学, 社会学, 人类学', '社会科学类书籍，研究人类社会和行为规律'),
('语言文学', '现代文学, 古典文学, 语言学', '语言文学类书籍，包括各国文学作品和语言研究'),
('艺术设计', '视觉设计, 音乐艺术, 影视制作', '艺术设计类书籍，涵盖各种艺术形式和创意设计');

-- 插入更多示例数据到 r_category 表中
-- 向 r_category 表中插入示例数据
INSERT INTO r_category (name, amount, lend_period, effect_period, notes) VALUES
('本科生', 5, 30, '2028-06-30', '本科生借书期限一次30天且最多同时借5本，毕业前有效'),
('硕士生', 10, 60, '2030-06-30', '硕士生借书期限一次60天且最多同时借10本，毕业前有效'),
('博士生', 15, 90, '2034-06-30', '博士生借书期限一次90天且最多同时借15本，毕业前有效'),
('教职工', 20, 180, '9999-12-31', '教职工借书期限一次180天且最多同时借20本，永久有效');

-- 添加外键约束关联: 读者和对应的分类
alter table reader add constraint fk_r_category_id foreign key (category_id)
    references r_category(id) on update cascade on delete cascade;

-- 添加外键约束关联: 书籍和对应的分类
alter table book add constraint fk_b_category_id foreign key (category_id)
    references b_category(id) on update cascade on delete cascade;

-- 插入全新的书籍数据
INSERT INTO book (name, category_id, author, press, publish_date, price, page_number, keywords, create_time, status, notes)
VALUES
    ('Python机器学习实战', 1, '张伟', '机械工业出版社', '2024-01-15', 89.99, 450, 'Python, 机器学习', NOW(), 0, '从零开始学习Python机器学习，包含大量实战案例'),
    ('Java高并发编程详解', 1, '李强', '电子工业出版社', '2024-02-20', 95.00, 520, 'Java, 并发编程', NOW(), 0, '深入解析Java高并发编程技术和最佳实践'),
    ('现代企业管理学', 2, '王建华', '清华大学出版社', '2024-03-10', 78.50, 380, '企业管理, 组织行为', NOW(), 0, '系统介绍现代企业管理理论与实践方法'),
    ('市场营销策略与实务', 2, '陈明', '北京大学出版社', '2024-04-05', 72.00, 350, '市场营销, 品牌策略', NOW(), 0, '全面阐述市场营销的核心理念和实操技巧'),
    ('量子物理学导论', 3, '刘教授', '科学出版社', '2024-05-12', 105.00, 580, '量子物理, 理论物理', NOW(), 0, '深入浅出地介绍量子物理学的基本原理和应用'),
    ('有机化学实验指导', 3, '赵博士', '化学工业出版社', '2024-06-18', 68.00, 320, '有机化学, 实验技术', NOW(), 0, '有机化学实验的详细操作指南和安全规范'),
    ('临床医学诊断手册', 4, '孙医生', '人民卫生出版社', '2024-07-22', 128.00, 720, '临床诊断, 医学手册', NOW(), 0, '临床医生必备的诊断参考工具书'),
    ('中医养生保健大全', 4, '周中医', '中医古籍出版社', '2024-08-15', 85.00, 420, '中医养生, 保健方法', NOW(), 0, '传统中医养生理论与现代保健方法的完美结合');
-- 继续插入更多书籍数据
INSERT INTO book (name, category_id, author, press, publish_date, price, page_number, keywords, create_time, status, notes)
VALUES
('智能制造系统设计', 5, '马工程师', '机械工业出版社', '2024-09-08', 92.00, 480, '智能制造, 系统设计', NOW(), 0, '工业4.0时代智能制造系统的设计理念和实施方案'),
('电路分析基础教程', 5, '林电工', '电子工业出版社', '2024-10-12', 76.50, 360, '电路分析, 电子技术', NOW(), 0, '电子工程专业学生必备的电路分析基础教材'),
('认知心理学研究方法', 6, '吴心理师', '北京师范大学出版社', '2024-11-20', 88.00, 440, '认知心理学, 研究方法', NOW(), 0, '系统介绍认知心理学的实验设计和数据分析方法'),
('社会学理论与实践', 6, '郑社会学家', '社会科学文献出版社', '2024-12-05', 82.00, 400, '社会学理论, 社会实践', NOW(), 0, '当代社会学主要理论流派及其实际应用'),
('现代汉语语法研究', 7, '黄语言学家', '商务印书馆', '2024-01-28', 75.00, 340, '现代汉语, 语法研究', NOW(), 0, '深入分析现代汉语语法结构和语言规律'),
('世界文学经典导读', 7, '钱文学教授', '北京大学出版社', '2024-02-14', 69.00, 310, '世界文学, 经典作品', NOW(), 0, '精选世界文学经典作品的深度解读和赏析'),
('数字媒体艺术创作', 8, '宋设计师', '中国美术学院出版社', '2024-03-25', 98.00, 520, '数字艺术, 媒体创作', NOW(), 0, '数字时代艺术创作的新理念、新技术和新方法'),
('影视后期制作技术', 8, '田导演', '中国电影出版社', '2024-04-18', 86.00, 410, '影视制作, 后期技术', NOW(), 0, '专业影视后期制作的技术要点和创作技巧');

INSERT INTO reader (name, category_id, sex, w_address, h_address, phone, email, create_time, notes) VALUES
('陈一', 1, 1, '北京市东城区东华门街道', '北京市朝阳区酒仙桥街道', '12345678901', 'chenyi@example.com', NOW(), '喜欢看历史类书籍'),
('李二', 2, 0, '上海市黄浦区南京东路街道', '上海市徐汇区漕河泾街道', '98765432101', 'lier@example.com', NOW(), '热爱科技类书籍'),
('张三', 3, 1, '广州市越秀区北京路街道', '广州市天河区珠江新城街道', '55555555551', 'zhangsan@example.com', NOW(), '喜欢音乐类书籍'),
('李四', 1, 1, '深圳市福田区华强北街道', '深圳市南山区高新南街道', '12345678902', 'lisi@example.com', NOW(), '热爱旅游类书籍'),
('王五', 2, 0, '武汉市江汉区建设大道街道', '武汉市洪山区关山街道', '98765432102', 'wangwu@example.com', NOW(), '喜欢电影类书籍'),
('赵六', 3, 1, '重庆市渝中区解放碑街道', '重庆市九龙坡区华岩镇', '55555555552', 'zhaoliu@example.com', NOW(), '热爱艺术类书籍'),
('孙七', 1, 1, '成都市锦江区春熙路街道', '成都市武侯区高升桥街道', '12345678903', 'sunqi@example.com', NOW(), '喜欢动漫类书籍'),
('周八', 2, 0, '南京市玄武区中山门街道', '南京市鼓楼区华侨路街道', '98765432103', 'zhouba@example.com', NOW(), '热爱历史类书籍'),
('吴九', 3, 1, '杭州市上城区湖滨街道', '杭州市滨江区长河街道', '55555555553', 'wuwu@example.com', NOW(), '喜欢外语类书籍'),
('郑十', 1, 1, '苏州市姑苏区虎丘街道', '苏州市相城区元和街道', '12345678904', 'zhengshi@example.com', NOW(), '热爱心理学类书籍'),
('冯十一', 2, 0, '济南市历下区趵突泉街道', '济南市历城区华龙街道', '98765432104', 'fengfeng@example.com', NOW(), '喜欢文学类书籍'),
('陈十二', 3, 1, '青岛市市南区台东街道', '青岛市市北区浮山所街道', '55555555554', 'chenchen@example.com', NOW(), '热爱经济类书籍'),
('卫十三', 1, 1, '天津市和平区劝业场街道', '天津市河西区梅江街道', '12345678905', 'weishi@example.com', NOW(), '喜欢哲学类书籍'),
('蒋十四', 2, 0, '西安市新城区长乐西路街道', '西安市雁塔区小寨路街道', '98765432105', 'jiangjiang@example.com', NOW(), '热爱教育类书籍'),
('沈十五', 3, 1, '长沙市芙蓉区五一广场街道', '长沙市岳麓区岳麓山街道', '55555555555', 'shenshen@example.com', NOW(), '喜欢自然科学类书籍'),
('韩十六', 1, 1, '南昌市东湖区东湖街道', '南昌市西湖区八一桥街道', '12345678906', 'hanhan@example.com', NOW(), '热爱计算机类书籍'),
('杨十七', 2, 0, '郑州市管城回族区紫荆山路街道', '郑州市中原区二七街道', '98765432106', 'yangyang@example.com', NOW(), '喜欢体育类书籍'),
('朱十八', 3, 1, '哈尔滨市道里区松花江街道', '哈尔滨市南岗区革新街道', '55555555556', 'zhuzhu@example.com', NOW(), '热爱军事类书籍'),
('秦十九', 1, 1, '石家庄市裕华区世纪公园街道', '石家庄市长安区胜利北街道', '12345678907', 'qinqin@example.com', NOW(), '喜欢政治类书籍'),
('尤二十', 2, 0, '太原市杏花岭区迎泽西街道', '太原市小店区南内环街道', '98765432107', 'youyou@example.com', NOW(), '热爱法律类书籍'),
('许二十一', 3, 1, '合肥市蜀山区望江西路街道', '合肥市包河区金寨路街道', '55555555557', 'xuxu@example.com', NOW(), '喜欢艺术类书籍'),
('何二十二', 1, 1, '济南市历下区趵突泉南路街道', '济南市天桥区中心街道', '12345678908', 'hehe@example.com', NOW(), '热爱旅游类书籍'),
('吕二十三', 2, 0, '青岛市市南区海泊桥街道', '青岛市市北区浮山路街道', '98765432108', 'lvlu@example.com', NOW(), '喜欢哲学类书籍'),
('施二十四', 3, 1, '天津市和平区南市街道', '天津市河东区大王庄街道', '55555555558', 'shishi@example.com', NOW(), '热爱心理学类书籍'),
('张二十五', 1, 1, '西安市雁塔区小寨路街道', '西安市未央区辛家庙街道', '12345678909', 'zhangzhang@example.com', NOW(), '喜欢电影类书籍'),
('孔二十六', 2, 0, '长沙市岳麓区望月湖街道', '长沙市开福区马王堆街道', '98765432109', 'kongkong@example.com', NOW(), '热爱历史类书籍'),
('曹二十七', 3, 1, '南昌市西湖区孺子路街道', '南昌市青山湖区西湖街道', '55555555559', 'caocao@example.com', NOW(), '喜欢文学类书籍'),
('严二十八', 1, 1, '郑州市金水区经三路街道', '郑州市二七区嵩山路街道', '12345678910', 'yanyan@example.com', NOW(), '热爱哲学类书籍'),
('华二十九', 2, 0, '哈尔滨市南岗区南岗街道', '哈尔滨市道里区松北街道', '98765432110', 'huahua@example.com', NOW(), '喜欢外语类书籍'),
('胡三十', 3, 1, '石家庄市长安区裕华西路街道', '石家庄市桥西区桥西街道', '55555555560', 'huhu@example.com', NOW(), '热爱科幻类书籍');
INSERT INTO reader (name, category_id, sex, w_address, h_address, phone, email, create_time, notes) VALUES
('王小明', 1, 1, '湖南省长沙市雨花区芙蓉中路', '四川省成都市武侯区高升桥街道', '13612345678', 'wangxiaoming@example.com', NOW(), '研究教育理论的学者'),
('李小红', 2, 0, '四川省成都市锦江区春熙路', '湖南省长沙市天心区解放西路', '13987654322', 'lixiaohong@example.com', NOW(), '关注教育改革的教师'),
('张小刚', 3, 1, '湖南省湘潭市雨湖区潇湘南路', '四川省成都市青羊区人民中路', '13776543210', 'zhangxiaogang@example.com', NOW(), '教育行业从业者'),
('赵小伟', 4, 1, '四川省绵阳市涪城区红星路', '湖南省株洲市天元区芦淞北路', '13876543210', 'zhaoxiaowei@example.com', NOW(), '关注学生心理健康的辅导员'),
('钱小芳', 1, 0, '湖南省衡阳市石鼓区城南路', '四川省成都市武侯区天府大道', '13598765438', 'qianxiaofang@example.com', NOW(), '学前教育工作者'),
('孙小强', 2, 1, '四川省成都市金牛区西安中路', '湖南省湘潭市雨湖区雨湖路', '13976543240', 'sunxiaoqiang@example.com', NOW(), '研究教育心理学的专家'),
('周小艾', 3, 1, '湖南省株洲市荷塘区东塘路', '四川省德阳市旌阳区凤鸣南路', '13676543240', 'zhouxiaoa@example.com', NOW(), '中小学教师'),
('吴小娜', 4, 0, '四川省成都市锦江区大慈寺路', '湖南省衡阳市蒸湘区中心路', '13787654341', 'wuxiaona@example.com', NOW(), '关注教育行政的工作人员'),
('朱小明', 1, 1, '湖南省长沙市芙蓉区芙蓉中路', '四川省成都市青羊区青羊大道', '13987654321', 'zhuxiaoming@example.com', NOW(), '关注教育行政的工作人员'),
('陈小红', 2, 0, '四川省成都市武侯区桂溪街道', '湖南省株洲市天元区栗树街道', '13698764432', 'chenxiaohong@example.com', NOW(), '热爱教育类书籍'),
('林小刚', 3, 1, '湖南省湘潭市雨湖区潇湘南路', '四川省成都市青羊区人民中路', '13598764432', 'linxiaogang@example.com', NOW(), '喜欢体育类书籍'),
('黄小伟', 4, 1, '四川省绵阳市涪城区红星路', '湖南省株洲市天元区芦淞北路', '13898765442', 'huangxiaowei@example.com', NOW(), '喜欢科幻类书籍'),
('徐小芳', 1, 0, '湖南省衡阳市石鼓区城南路', '四川省成都市武侯区天府大道', '13987654341', 'xuxiaofang@example.com', NOW(), '喜欢文学类书籍'),
('胡小强', 2, 1, '四川省成都市金牛区西安中路', '湖南省湘潭市雨湖区雨湖路', '13674543240', 'huxiaoqiang@example.com', NOW(), '喜欢历史类书籍'),
('朱小艾', 3, 1, '湖南省株洲市荷塘区东塘路', '四川省德阳市旌阳区凤鸣南路', '13774543240', 'zhuxiaoa@example.com', NOW(), '喜欢哲学类书籍'),
('刘小娜', 4, 0, '四川省成都市锦江区大慈寺路', '湖南省衡阳市蒸湘区中心路', '13887654341', 'liuxiaona@example.com', NOW(), '喜欢艺术类书籍'),
('丁小明', 1, 1, '湖南省长沙市芙蓉区芙蓉中路', '四川省成都市青羊区青羊大道', '13698762432', 'dingxiaoming@example.com', NOW(), '喜欢心理学类书籍'),
('许小红', 2, 0, '四川省成都市武侯区桂溪街道', '湖南省株洲市天元区栗树街道', '13798762432', 'xuxiaohong@example.com', NOW(), '喜欢经济类书籍'),
('曹小刚', 3, 1, '湖南省湘潭市雨湖区潇湘南路', '四川省成都市青羊区人民中路', '13598469432', 'caoxiaogang@example.com', NOW(), '喜欢政治类书籍'),
('程小伟', 4, 1, '四川省绵阳市涪城区红星路', '湖南省株洲市天元区芦淞北路', '13781654391', 'chengxiaowei@example.com', NOW(), '喜欢法律类书籍'),
('苏小芳', 1, 0, '湖南省衡阳市石鼓区城南路', '四川省成都市武侯区天府大道', '13681654391', 'suxiaofang@example.com', NOW(), '喜欢教育类书籍'),
('杨小强', 2, 1, '四川省成都市金牛区西安中路', '湖南省湘潭市雨湖区雨湖路', '13571543290', 'yangxiaoqiang@example.com', NOW(), '喜欢心理学类书籍'),
('秦小艾', 3, 1, '湖南省株洲市荷塘区东塘路', '四川省德阳市旌阳区凤鸣南路', '13771543290', 'qinxiaoai@example.com', NOW(), '喜欢经济类书籍'),
('许小娜', 4, 0, '四川省成都市锦江区大慈寺路', '湖南省衡阳市蒸湘区中心路', '13881654391', 'xuxiaona@example.com', NOW(), '喜欢政治类书籍'),
('黄小明', 1, 1, '湖南省长沙市芙蓉区芙蓉中路', '四川省成都市青羊区青羊大道', '13198762332', 'huangxiaoming@example.com', NOW(), '喜欢科幻类书籍'),
('徐小红', 2, 0, '四川省成都市武侯区桂溪街道', '湖南省株洲市天元区栗树街道', '13198764332', 'xuxiaohong@example.com', NOW(), '喜欢文学类书籍'),
('胡小刚', 3, 1, '湖南省湘潭市雨湖区潇湘南路', '四川省成都市青羊区人民中路', '13198766432', 'huxiaogang@example.com', NOW(), '喜欢历史类书籍'),
('朱小伟', 4, 1, '四川省绵阳市涪城区红星路', '湖南省株洲市天元区芦淞北路', '13671543290', 'zhuxiaowei@example.com', NOW(), '喜欢哲学类书籍');

-- 插入借还书记录测试数据（用于统计功能）
INSERT INTO lend_return (r_id, b_id, lend_date, return_date, status, notes) VALUES
-- 最近7天的借书记录
(1, 1, CURDATE(), NULL, 0, '借阅中'),
(2, 2, CURDATE(), NULL, 0, '借阅中'),
(3, 3, DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 0, '借阅中'),
(1, 4, DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 0, '借阅中'),
(4, 5, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), 1, '正常归还'),
(5, 6, DATE_SUB(CURDATE(), INTERVAL 2 DAY), NULL, 0, '借阅中'),
(2, 7, DATE_SUB(CURDATE(), INTERVAL 3 DAY), CURDATE(), 1, '正常归还'),
(3, 8, DATE_SUB(CURDATE(), INTERVAL 3 DAY), NULL, 0, '借阅中'),
(1, 2, DATE_SUB(CURDATE(), INTERVAL 4 DAY), DATE_SUB(CURDATE(), INTERVAL 2 DAY), 1, '正常归还'),
(4, 1, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_SUB(CURDATE(), INTERVAL 3 DAY), 1, '正常归还'),
(5, 3, DATE_SUB(CURDATE(), INTERVAL 6 DAY), DATE_SUB(CURDATE(), INTERVAL 4 DAY), 1, '正常归还'),
(2, 4, DATE_SUB(CURDATE(), INTERVAL 6 DAY), NULL, 0, '借阅中'),
-- 更早的一些记录
(1, 5, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 8 DAY), 1, '正常归还'),
(3, 6, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 1, '正常归还'),
(4, 7, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), 1, '正常归还');

select count(id) from lend_return WHERE (return_date is null or return_date >= 2024-05-16) and r_id = 207;