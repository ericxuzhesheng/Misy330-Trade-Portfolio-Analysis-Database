import os
from datetime import datetime

import pymysql
from flask import Flask, flash, redirect, render_template, request, session, url_for
from pymysql.cursors import DictCursor


app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY", "misy330-trade-demo")


DEFAULT_DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", ""),
    "database": os.getenv("DB_NAME", "student-z126_Trade"),
    "ssl_enabled": os.getenv("DB_SSL", "false").lower() in {"1", "true", "yes", "on"},
    "charset": "utf8mb4",
    "cursorclass": DictCursor,
    "autocommit": False,
}


def get_db_config():
    config = DEFAULT_DB_CONFIG.copy()
    overrides = session.get("db_config", {})
    for key in ("host", "user", "password", "database"):
        if key in overrides and overrides[key] is not None:
            config[key] = overrides[key]
    if "port" in overrides and overrides["port"]:
        config["port"] = int(overrides["port"])
    if "ssl_enabled" in overrides:
        config["ssl_enabled"] = bool(overrides["ssl_enabled"])
    return config


def build_connect_kwargs(config, autocommit=None):
    kwargs = {
        "host": config["host"],
        "port": int(config["port"]),
        "user": config["user"],
        "password": config["password"],
        "database": config["database"],
        "charset": config["charset"],
        "cursorclass": config["cursorclass"],
        "autocommit": config["autocommit"] if autocommit is None else autocommit,
    }
    if config.get("ssl_enabled"):
        # Match Workbench-style TLS without requiring local certificate files.
        kwargs["ssl"] = {}
    return kwargs


def get_connection():
    return pymysql.connect(**build_connect_kwargs(get_db_config()))


def query_all(sql, params=None):
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql, params or ())
            return cursor.fetchall()


def query_one(sql, params=None):
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql, params or ())
            return cursor.fetchone()


def execute(sql, params=None):
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql, params or ())
        connection.commit()


def normalize_datetime(value):
    if not value:
        return None
    return datetime.strptime(value, "%Y-%m-%dT%H:%M").strftime("%Y-%m-%d %H:%M:%S")


def load_trade_options():
    portfolios = query_all("SELECT PortfolioID, Name FROM Portfolio ORDER BY PortfolioID")
    strategies = query_all("SELECT StrategyID, Name FROM Strategy ORDER BY StrategyID")
    stocks = query_all(
        """
        SELECT s.Code, c.Name AS CompanyName, s.TradeCurrency
        FROM Stock s
        JOIN Company c ON s.Company_Name = c.Name
        ORDER BY s.Code
        """
    )
    return portfolios, strategies, stocks


@app.context_processor
def inject_db_name():
    db_config = get_db_config()
    return {
        "db_name": db_config["database"],
        "db_host": db_config["host"],
        "db_user": db_config["user"],
        "db_ssl": db_config["ssl_enabled"],
    }


@app.route("/settings", methods=["GET", "POST"])
def settings():
    if request.method == "POST":
        form_config = {
            "host": request.form.get("host", "").strip(),
            "port": request.form.get("port", "").strip(),
            "user": request.form.get("user", "").strip(),
            "password": request.form.get("password", ""),
            "database": request.form.get("database", "").strip(),
            "ssl_enabled": request.form.get("ssl_enabled") == "on",
        }
        session["db_config"] = form_config
        try:
            test_config = {
                "host": form_config["host"],
                "port": int(form_config["port"]),
                "user": form_config["user"],
                "password": form_config["password"],
                "database": form_config["database"],
                "ssl_enabled": form_config["ssl_enabled"],
                "charset": "utf8mb4",
                "cursorclass": DictCursor,
                "autocommit": True,
            }
            with pymysql.connect(**build_connect_kwargs(test_config, autocommit=True)) as connection:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT DATABASE() AS db_name, NOW() AS server_time")
                    row = cursor.fetchone()
            flash(
                f"Connected successfully to {row['db_name']} on {form_config['host']} as {form_config['user']} with SSL {'enabled' if form_config['ssl_enabled'] else 'disabled'}.",
                "success",
            )
            return redirect(url_for("dashboard"))
        except Exception as exc:
            flash(f"Connection test failed: {exc}", "error")

    current = get_db_config()
    return render_template("settings.html", current=current)


@app.route("/")
def dashboard():
    try:
        counts = {
            "companies": query_one("SELECT COUNT(*) AS value FROM Company")["value"],
            "stocks": query_one("SELECT COUNT(*) AS value FROM Stock")["value"],
            "portfolios": query_one("SELECT COUNT(*) AS value FROM Portfolio")["value"],
            "trades": query_one("SELECT COUNT(*) AS value FROM TradeRecord")["value"],
        }
        latest_trades = query_all(
            """
            SELECT tr.TradeID, tr.Time, tr.Direction, tr.ExecutionPrice, tr.Volume,
                   p.Name AS PortfolioName, s.Code AS StockCode
            FROM TradeRecord tr
            JOIN Portfolio p ON tr.Portfolio_PortfolioID = p.PortfolioID
            JOIN Stock s ON tr.Stock_Code = s.Code
            ORDER BY tr.Time DESC, tr.TradeID DESC
            LIMIT 5
            """
        )
        pnl_rows = query_all(
            """
            SELECT s.TradeCurrency AS Currency,
                   p.Name AS PortfolioName,
                   ROUND(SUM(
                       (tr.ExecutionPrice * tr.Volume) - tr.StampDuty - tr.CapitalGainTax
                   ), 2) AS SellAmountAfterTax
            FROM TradeRecord tr
            JOIN Stock s ON tr.Stock_Code = s.Code
            JOIN Portfolio p ON tr.Portfolio_PortfolioID = p.PortfolioID
            WHERE tr.Direction = 'Sell'
            GROUP BY s.TradeCurrency, p.Name
            ORDER BY p.Name, s.TradeCurrency
            """
        )
        return render_template(
            "dashboard.html",
            counts=counts,
            latest_trades=latest_trades,
            pnl_rows=pnl_rows,
            error=None,
        )
    except Exception as exc:
        return render_template(
            "dashboard.html",
            counts={},
            latest_trades=[],
            pnl_rows=[],
            error=str(exc),
        )


@app.route("/companies")
def companies():
    try:
        rows = query_all(
            """
            SELECT c.Name, c.Industry, c.Country, c.NetProfitGrowth,
                   COUNT(s.Code) AS ListedTickers
            FROM Company c
            LEFT JOIN Stock s ON s.Company_Name = c.Name
            GROUP BY c.Name, c.Industry, c.Country, c.NetProfitGrowth
            ORDER BY c.Name
            """
        )
        return render_template("companies.html", rows=rows, error=None)
    except Exception as exc:
        return render_template("companies.html", rows=[], error=str(exc))


@app.route("/trades")
def trades():
    portfolio_filter = request.args.get("portfolio", type=int)
    sql = """
        SELECT tr.TradeID, tr.Time, tr.Direction, tr.ExecutionPrice, tr.Volume,
               tr.StampDuty, tr.CapitalGainTax,
               p.Name AS PortfolioName,
               st.Name AS StrategyName,
               s.Code AS StockCode,
               c.Name AS CompanyName
        FROM TradeRecord tr
        JOIN Portfolio p ON tr.Portfolio_PortfolioID = p.PortfolioID
        JOIN Strategy st ON tr.Strategy_StrategyID = st.StrategyID
        JOIN Stock s ON tr.Stock_Code = s.Code
        JOIN Company c ON s.Company_Name = c.Name
    """
    params = []
    if portfolio_filter:
        sql += " WHERE p.PortfolioID = %s"
        params.append(portfolio_filter)
    sql += " ORDER BY tr.Time DESC, tr.TradeID DESC"

    try:
        rows = query_all(sql, params)
        portfolios = query_all("SELECT PortfolioID, Name FROM Portfolio ORDER BY PortfolioID")
        return render_template(
            "trades.html",
            rows=rows,
            portfolios=portfolios,
            selected_portfolio=portfolio_filter,
            error=None,
        )
    except Exception as exc:
        return render_template(
            "trades.html",
            rows=[],
            portfolios=[],
            selected_portfolio=portfolio_filter,
            error=str(exc),
        )


@app.route("/trades/new", methods=["GET", "POST"])
def trade_create():
    if request.method == "POST":
        try:
            next_trade_id = query_one("SELECT COALESCE(MAX(TradeID), 0) + 1 AS next_id FROM TradeRecord")["next_id"]
            execute(
                """
                INSERT INTO TradeRecord
                    (TradeID, Time, Direction, ExecutionPrice, Volume, StampDuty,
                     CapitalGainTax, Portfolio_PortfolioID, Strategy_StrategyID, Stock_Code)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    next_trade_id,
                    normalize_datetime(request.form["time"]),
                    request.form["direction"],
                    request.form["execution_price"],
                    request.form["volume"],
                    request.form.get("stamp_duty", 0) or 0,
                    request.form.get("capital_gain_tax", 0) or 0,
                    request.form["portfolio_id"],
                    request.form["strategy_id"],
                    request.form["stock_code"],
                ),
            )
            flash(f"Trade {next_trade_id} created.", "success")
            return redirect(url_for("trades"))
        except Exception as exc:
            flash(f"Failed to create trade: {exc}", "error")

    try:
        portfolios, strategies, stocks = load_trade_options()
        return render_template(
            "trade_form.html",
            trade=None,
            portfolios=portfolios,
            strategies=strategies,
            stocks=stocks,
            mode="Create",
        )
    except Exception as exc:
        flash(f"Database connection failed: {exc}", "error")
        return redirect(url_for("dashboard"))


@app.route("/trades/<int:trade_id>/edit", methods=["GET", "POST"])
def trade_edit(trade_id):
    if request.method == "POST":
        try:
            execute(
                """
                UPDATE TradeRecord
                SET Time = %s,
                    Direction = %s,
                    ExecutionPrice = %s,
                    Volume = %s,
                    StampDuty = %s,
                    CapitalGainTax = %s,
                    Portfolio_PortfolioID = %s,
                    Strategy_StrategyID = %s,
                    Stock_Code = %s
                WHERE TradeID = %s
                """,
                (
                    normalize_datetime(request.form["time"]),
                    request.form["direction"],
                    request.form["execution_price"],
                    request.form["volume"],
                    request.form.get("stamp_duty", 0) or 0,
                    request.form.get("capital_gain_tax", 0) or 0,
                    request.form["portfolio_id"],
                    request.form["strategy_id"],
                    request.form["stock_code"],
                    trade_id,
                ),
            )
            flash(f"Trade {trade_id} updated.", "success")
            return redirect(url_for("trades"))
        except Exception as exc:
            flash(f"Failed to update trade: {exc}", "error")

    try:
        trade = query_one("SELECT * FROM TradeRecord WHERE TradeID = %s", (trade_id,))
        if not trade:
            flash(f"Trade {trade_id} not found.", "error")
            return redirect(url_for("trades"))
        portfolios, strategies, stocks = load_trade_options()
        return render_template(
            "trade_form.html",
            trade=trade,
            portfolios=portfolios,
            strategies=strategies,
            stocks=stocks,
            mode="Edit",
        )
    except Exception as exc:
        flash(f"Database connection failed: {exc}", "error")
        return redirect(url_for("dashboard"))


@app.route("/trades/<int:trade_id>/delete", methods=["POST"])
def trade_delete(trade_id):
    try:
        execute("DELETE FROM TradeRecord WHERE TradeID = %s", (trade_id,))
        flash(f"Trade {trade_id} deleted.", "success")
    except Exception as exc:
        flash(f"Failed to delete trade: {exc}", "error")
    return redirect(url_for("trades"))


@app.route("/reports")
def reports():
    try:
        negative_growth_rows = query_all(
            """
            SELECT c.Name AS CompanyName,
                   s.Code AS StockCode,
                   s.TradeCurrency AS Currency,
                   e.Name AS ExchangeName,
                   c.NetProfitGrowth AS GrowthRate,
                   CASE
                       WHEN md.EPS IS NOT NULL AND md.EPS <> 0
                           THEN ROUND(md.Close / md.EPS, 2)
                       ELSE NULL
                   END AS PERatio
            FROM Stock s
            JOIN Company c ON s.Company_Name = c.Name
            JOIN Exchange e ON s.Exchange_Code = e.Code
            JOIN MarketData md ON s.Code = md.Stock_Code
            WHERE c.NetProfitGrowth < 0
              AND md.Date = (SELECT MAX(Date) FROM MarketData)
            ORDER BY c.NetProfitGrowth ASC, s.Code
            """
        )
        sell_activity_rows = query_all(
            """
            SELECT p.PortfolioID,
                   p.Name AS PortfolioName,
                   s.TradeCurrency,
                   COUNT(*) AS NumSellTrades,
                   ROUND(SUM((tr.ExecutionPrice * tr.Volume) - tr.StampDuty - tr.CapitalGainTax), 2)
                       AS TotalSellAmountAfterTax
            FROM TradeRecord tr
            JOIN Portfolio p ON tr.Portfolio_PortfolioID = p.PortfolioID
            JOIN Stock s ON tr.Stock_Code = s.Code
            WHERE tr.Direction = 'Sell'
            GROUP BY p.PortfolioID, p.Name, s.TradeCurrency
            HAVING COUNT(*) >= 2
            ORDER BY p.PortfolioID, s.TradeCurrency
            """
        )
        return render_template(
            "reports.html",
            negative_growth_rows=negative_growth_rows,
            sell_activity_rows=sell_activity_rows,
            error=None,
        )
    except Exception as exc:
        return render_template(
            "reports.html",
            negative_growth_rows=[],
            sell_activity_rows=[],
            error=str(exc),
        )


if __name__ == "__main__":
    app.run(debug=True, port=5000)
