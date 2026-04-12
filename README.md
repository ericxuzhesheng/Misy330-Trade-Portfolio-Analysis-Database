<h1 align="center">MISY330 Trade Portfolio Analysis Database</h1>

<p align="center"><strong>Trade Portfolio Analysis Database | 交易与投资组合分析数据库</strong></p>

<p align="center">
  <a href="#zh-cn">
    <img alt="Chinese" src="https://img.shields.io/badge/LANGUAGE-%E4%B8%AD%E6%96%87-E74C3C?style=for-the-badge&logo=googletranslate&logoColor=white">
  </a>
  <a href="#english">
    <img alt="English" src="https://img.shields.io/badge/LANGUAGE-ENGLISH-2F80ED?style=for-the-badge&logo=googletranslate&logoColor=white">
  </a>
</p>

---

<a id="zh-cn"></a>

## 简体中文

<p>
  <strong>当前语言：</strong>中文 | <a href="#english">Switch to English</a>
</p>

### 项目简介

这是一个为 `MISY330 Database Design and Implementation` 课程完成的期末数据库项目。  
项目主题是一个 **交易与投资组合分析数据库系统**，用于支持股票交易记录管理、市场数据分析、税费计算、因子筛选、策略建模，以及投资组合绩效分析。

本项目不仅包含完整的数据库设计与 SQL 实现，还额外完成了一个本地可运行的 **Flask + MySQL bonus prototype**，用于演示数据库如何被简单网页应用调用。

### 项目目标

本项目希望解决以下业务需求：

- 统一管理公司、交易所、股票、市场数据、投资组合和交易记录
- 根据不同交易所规则计算印花税和资本利得税
- 基于 FIFO 成本法匹配买卖交易
- 进行已实现盈亏分析
- 基于财务指标和技术指标进行股票筛选
- 通过一个简单的网页原型展示数据库的实际使用方式

### 主要内容

#### 1. 数据库设计

项目包含以下核心实体：

- `Company`
- `Exchange`
- `Stock`
- `MarketData`
- `Portfolio`
- `Strategy`
- `Factor`
- `FactorUsageRule`
- `TradeRecord`

数据库设计包含：

- ER Diagram
- Logical Data Model
- 主键与外键约束
- 样例数据

#### 2. SQL 实现

项目 SQL 文件包括：

- `GroupProject.sql`  
  用于创建数据库、表结构、主键外键以及插入样例数据

- `TradeQuery.sql`  
  用于实现项目中的业务查询与更新逻辑

这些 SQL 逻辑覆盖了：

- 多表连接查询
- 嵌套查询
- 更新操作
- 分组统计
- FIFO 成本匹配
- 税费更新
- 已实现盈亏分析

#### 3. Bonus Prototype

项目额外实现了一个简单的本地网页原型，满足课程 bonus 要求。

技术栈：

- `Flask`
- `PyMySQL`
- `MySQL`
- HTML templates + CSS

原型包含以下页面：

- `/`：Dashboard
- `/companies`：公司信息浏览
- `/trades`：交易记录浏览与 CRUD
- `/reports`：报表示例
- `/settings`：数据库连接配置与测试

这个原型的作用是证明：  
**本项目不仅完成了数据库设计和 SQL 分析，也可以进一步支持简单的应用层演示。**

### 项目文件说明

- `MISY330_Final_Project_Presentation.tex`：最终 Beamer 演示文稿源码
- `MISY330_Final_Project_Presentation.pdf`：最终演示文稿 PDF
- `MISY330_Final_Project_Speaking_Script.tex`：英文讲稿源码
- `MISY330_Final_Project_Speaking_Script.pdf`：英文讲稿 PDF
- `GroupProject.sql`：数据库创建与样例数据脚本
- `TradeQuery.sql`：业务查询脚本
- `ER Diagram.png`：ER 图
- `Trade ER Model.png`：逻辑数据模型图
- `query 1.png` 到 `query 6.png`：查询结果截图
- `app.py`：Flask bonus prototype 主程序
- `templates/`：网页模板
- `static/`：网页样式文件
- `requirements.txt`：Python 依赖

### 如何运行 Bonus Prototype

#### 1. 安装依赖

```powershell
pip install -r requirements.txt
```

#### 2. 启动 Flask 应用

```powershell
python app.py
```

#### 3. 打开网页

浏览器访问：

```text
http://127.0.0.1:5000
```

#### 4. 配置数据库连接

进入：

```text
http://127.0.0.1:5000/settings
```

填写：

- MySQL host
- port
- username
- password
- database name
- SSL 选项（如果服务器要求）

连接成功后即可浏览真实项目数据库数据。

### 适用说明

- 本项目用于课程学习与展示
- 原型仅用于本地 demo，不包含认证与部署
- 不建议直接作为生产系统使用

---

<a id="english"></a>

## English

<p>
  <strong>Current Language:</strong> English | <a href="#zh-cn">切换到中文</a>
</p>

### Project Overview

This repository contains a final database project for `MISY330 Database Design and Implementation`.
The project is a **Trade and Portfolio Analysis Database System** designed to support stock trading records, market data analysis, tax calculation, factor-based screening, strategy modeling, and portfolio performance analysis.

In addition to the database design and SQL implementation, this project also includes a **local Flask + MySQL bonus prototype** that demonstrates how the database can be used through a simple web application.

### Project Objectives

This project is designed to support the following business needs:

- Manage companies, exchanges, stocks, market data, portfolios, and trade records in a structured way
- Calculate stamp duty and capital gain tax under different exchange rules
- Match buy and sell trades using FIFO cost basis logic
- Analyze realized profit and loss
- Screen stocks using both fundamental and technical indicators
- Demonstrate a simple application layer on top of the database

### Main Components

#### 1. Database Design

The project includes the following major entities:

- `Company`
- `Exchange`
- `Stock`
- `MarketData`
- `Portfolio`
- `Strategy`
- `Factor`
- `FactorUsageRule`
- `TradeRecord`

The database design includes:

- an ER diagram
- a logical data model
- primary key and foreign key constraints
- sample records

#### 2. SQL Implementation

The main SQL files are:

- `GroupProject.sql`  
  Creates the database, tables, keys, and sample data

- `TradeQuery.sql`  
  Contains the business queries and update logic used in the project

The SQL logic covers:

- multi-table joins
- nested queries
- update operations
- grouping and aggregation
- FIFO trade matching
- tax updates
- realized P&L analysis

#### 3. Bonus Prototype

The project also includes a simple local web prototype created to satisfy the course bonus requirement.

Tech stack:

- `Flask`
- `PyMySQL`
- `MySQL`
- HTML templates + CSS

The prototype includes the following routes:

- `/` : dashboard
- `/companies` : company browser
- `/trades` : trade record browser and CRUD
- `/reports` : sample report pages
- `/settings` : database connection configuration and testing

This bonus prototype shows that the project is not only a SQL assignment, but also a working database-backed application demo.

### Project Files

- `MISY330_Final_Project_Presentation.tex`: final Beamer slide source
- `MISY330_Final_Project_Presentation.pdf`: final presentation PDF
- `MISY330_Final_Project_Speaking_Script.tex`: English speaking script source
- `MISY330_Final_Project_Speaking_Script.pdf`: English speaking script PDF
- `GroupProject.sql`: schema creation and sample data
- `TradeQuery.sql`: business query script
- `ER Diagram.png`: ER diagram
- `Trade ER Model.png`: logical data model image
- `query 1.png` to `query 6.png`: query result screenshots
- `app.py`: Flask bonus prototype entry point
- `templates/`: HTML templates
- `static/`: CSS assets
- `requirements.txt`: Python dependencies

### How to Run the Bonus Prototype

#### 1. Install dependencies

```powershell
pip install -r requirements.txt
```

#### 2. Start the Flask app

```powershell
python app.py
```

#### 3. Open the web app

Visit:

```text
http://127.0.0.1:5000
```

#### 4. Configure the database connection

Go to:

```text
http://127.0.0.1:5000/settings
```

Enter:

- MySQL host
- port
- username
- password
- database name
- SSL option if required by the server

After a successful connection, the prototype will display live data from the project database.

### Notes

- This project was built for academic use and classroom presentation
- The prototype is intended for local demo only
- No authentication or production deployment is included
