USE `student-z126_Trade`;



/* =========================================================
   1. Update StampDuty
   ========================================================= */

UPDATE TradeRecord tr
JOIN Stock s ON tr.Stock_Code = s.Code
JOIN Exchange e ON s.Exchange_Code = e.Code
SET tr.StampDuty = ROUND(
    CASE 
        -- HK stocks: both buy and sell are charged
        WHEN e.Code = 'HKEX' 
            THEN tr.ExecutionPrice * tr.Volume * e.StampDutyRate

        -- A-shares: only sell is charged
        WHEN e.Code IN ('SSE', 'SZSE') AND tr.Direction = 'Sell' 
            THEN tr.ExecutionPrice * tr.Volume * e.StampDutyRate

        -- US stocks or A-share buys
        ELSE 0
    END
, 2);



/* =========================================================
   2. Check FIFO Cost Basis
   Logic fix:
   ========================================================= */

WITH TradeFlow AS (
    SELECT
        tr.*,
        SUM(CASE WHEN tr.Direction = 'Buy' THEN tr.Volume ELSE 0 END)
            OVER (
                PARTITION BY tr.Stock_Code, tr.Portfolio_PortfolioID
                ORDER BY tr.Time ASC, tr.TradeID ASC
            ) AS Cum_Buy,
        SUM(CASE WHEN tr.Direction = 'Sell' THEN tr.Volume ELSE 0 END)
            OVER (
                PARTITION BY tr.Stock_Code, tr.Portfolio_PortfolioID
                ORDER BY tr.Time ASC, tr.TradeID ASC
            ) AS Cum_Sell
    FROM TradeRecord tr
)
SELECT 
    tf.TradeID,
    tf.Portfolio_PortfolioID,
    tf.Stock_Code,
    tf.Direction,
    tf.Volume,
    tf.ExecutionPrice,
    CASE 
        WHEN tf.Direction = 'Sell' THEN (
            SELECT tr_b.ExecutionPrice
            FROM TradeRecord tr_b
            WHERE tr_b.Stock_Code = tf.Stock_Code
              AND tr_b.Portfolio_PortfolioID = tf.Portfolio_PortfolioID
              AND tr_b.Direction = 'Buy'
              AND (
                    SELECT SUM(tr_x.Volume)
                    FROM TradeRecord tr_x
                    WHERE tr_x.Stock_Code = tf.Stock_Code
                      AND tr_x.Portfolio_PortfolioID = tf.Portfolio_PortfolioID
                      AND tr_x.Direction = 'Buy'
                      AND (
                            tr_x.Time < tr_b.Time
                            OR (tr_x.Time = tr_b.Time AND tr_x.TradeID <= tr_b.TradeID)
                          )
                  ) >= tf.Cum_Sell
            ORDER BY tr_b.Time ASC, tr_b.TradeID ASC
            LIMIT 1
        )
        ELSE NULL
    END AS FIFO_Cost_Basis
FROM TradeFlow tf;



/* =========================================================
   3. Update CapitalGainTax
   ========================================================= */

SET SQL_SAFE_UPDATES = 0;

UPDATE TradeRecord tr
JOIN (
    SELECT 
        t_all.TradeID,
        (
            SELECT t_b.ExecutionPrice
            FROM TradeRecord t_b
            WHERE t_b.Stock_Code = t_all.Stock_Code
              AND t_b.Portfolio_PortfolioID = t_all.Portfolio_PortfolioID
              AND t_b.Direction = 'Buy'
              AND (
                    SELECT SUM(tb2.Volume)
                    FROM TradeRecord tb2
                    WHERE tb2.Direction = 'Buy'
                      AND tb2.Stock_Code = t_all.Stock_Code
                      AND tb2.Portfolio_PortfolioID = t_all.Portfolio_PortfolioID
                      AND (
                            tb2.Time < t_b.Time
                            OR (tb2.Time = t_b.Time AND tb2.TradeID <= t_b.TradeID)
                          )
                  ) >= (
                    SELECT SUM(ts2.Volume)
                    FROM TradeRecord ts2
                    WHERE ts2.Direction = 'Sell'
                      AND ts2.Stock_Code = t_all.Stock_Code
                      AND ts2.Portfolio_PortfolioID = t_all.Portfolio_PortfolioID
                      AND (
                            ts2.Time < t_all.Time
                            OR (ts2.Time = t_all.Time AND ts2.TradeID <= t_all.TradeID)
                          )
                  )
            ORDER BY t_b.Time ASC, t_b.TradeID ASC
            LIMIT 1
        ) AS FIFO_Cost
    FROM TradeRecord t_all
    WHERE t_all.Direction = 'Sell'
) AS fifo ON tr.TradeID = fifo.TradeID
JOIN Stock s ON tr.Stock_Code = s.Code
JOIN Exchange e ON s.Exchange_Code = e.Code
SET tr.CapitalGainTax = ROUND(
    GREATEST(tr.ExecutionPrice - fifo.FIFO_Cost, 0) * tr.Volume * e.CapitalGainTaxRate,
    2
)
WHERE e.CapitalGainTaxRate > 0;



/* =========================================================
   4. Check updated tax result
   ========================================================= */

SELECT 
    tr.TradeID,
    tr.Stock_Code,
    tr.Direction,
    e.Code AS Exch,
    tr.ExecutionPrice,
    tr.Volume,
    tr.StampDuty,
    tr.CapitalGainTax
FROM TradeRecord tr
JOIN Stock s ON tr.Stock_Code = s.Code
JOIN Exchange e ON s.Exchange_Code = e.Code
ORDER BY tr.Time ASC, tr.TradeID ASC;



/* =========================================================
   5. Total realized PNL by portfolio and currency
   ========================================================= */

SELECT 
    s.TradeCurrency AS Currency,
    p.Name AS Portfolio_Name,
    ROUND(SUM(
        (
            tr_sell.ExecutionPrice - (
                SELECT t_b.ExecutionPrice
                FROM TradeRecord t_b
                WHERE t_b.Stock_Code = tr_sell.Stock_Code
                  AND t_b.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                  AND t_b.Direction = 'Buy'
                  AND (
                        SELECT SUM(tb2.Volume)
                        FROM TradeRecord tb2
                        WHERE tb2.Direction = 'Buy'
                          AND tb2.Stock_Code = tr_sell.Stock_Code
                          AND tb2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                          AND (
                                tb2.Time < t_b.Time
                                OR (tb2.Time = t_b.Time AND tb2.TradeID <= t_b.TradeID)
                              )
                      ) >= (
                        SELECT SUM(ts2.Volume)
                        FROM TradeRecord ts2
                        WHERE ts2.Direction = 'Sell'
                          AND ts2.Stock_Code = tr_sell.Stock_Code
                          AND ts2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                          AND (
                                ts2.Time < tr_sell.Time
                                OR (ts2.Time = tr_sell.Time AND ts2.TradeID <= tr_sell.TradeID)
                              )
                      )
                ORDER BY t_b.Time ASC, t_b.TradeID ASC
                LIMIT 1
            )
        ) * tr_sell.Volume
        - tr_sell.StampDuty
        - tr_sell.CapitalGainTax
    ), 2) AS Total_Realized_PNL
FROM TradeRecord tr_sell
JOIN Stock s ON tr_sell.Stock_Code = s.Code
JOIN Portfolio p ON tr_sell.Portfolio_PortfolioID = p.PortfolioID
WHERE tr_sell.Direction = 'Sell'
  AND tr_sell.Portfolio_PortfolioID = 1
GROUP BY s.TradeCurrency, p.Name;



/* =========================================================
   6. Transaction-level realized profit detail
   ========================================================= */

SELECT 
    p.PortfolioID AS PID,
    p.Name AS Portfolio_Name,
    tr_sell.Time AS Transaction_Time,
    tr_sell.Stock_Code AS Company_Code,
    c.Name AS Company_Name,
    e.Name AS Exchange,
    s.TradeCurrency AS Currency,
    tr_sell.Volume,
    (
        SELECT tr_b.ExecutionPrice
        FROM TradeRecord tr_b
        WHERE tr_b.Stock_Code = tr_sell.Stock_Code
          AND tr_b.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
          AND tr_b.Direction = 'Buy'
          AND (
                SELECT SUM(tb2.Volume)
                FROM TradeRecord tb2
                WHERE tb2.Direction = 'Buy'
                  AND tb2.Stock_Code = tr_sell.Stock_Code
                  AND tb2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                  AND (
                        tb2.Time < tr_b.Time
                        OR (tb2.Time = tr_b.Time AND tb2.TradeID <= tr_b.TradeID)
                      )
              ) >= (
                SELECT SUM(ts2.Volume)
                FROM TradeRecord ts2
                WHERE ts2.Direction = 'Sell'
                  AND ts2.Stock_Code = tr_sell.Stock_Code
                  AND ts2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                  AND (
                        ts2.Time < tr_sell.Time
                        OR (ts2.Time = tr_sell.Time AND ts2.TradeID <= tr_sell.TradeID)
                      )
              )
        ORDER BY tr_b.Time ASC, tr_b.TradeID ASC
        LIMIT 1
    ) AS Matching_Buy_Price,
    tr_sell.ExecutionPrice AS Selling_Price,
    tr_sell.StampDuty,
    tr_sell.CapitalGainTax,
    ROUND(
        (
            tr_sell.ExecutionPrice - (
                SELECT tr_b.ExecutionPrice
                FROM TradeRecord tr_b
                WHERE tr_b.Stock_Code = tr_sell.Stock_Code
                  AND tr_b.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                  AND tr_b.Direction = 'Buy'
                  AND (
                        SELECT SUM(tb2.Volume)
                        FROM TradeRecord tb2
                        WHERE tb2.Direction = 'Buy'
                          AND tb2.Stock_Code = tr_sell.Stock_Code
                          AND tb2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                          AND (
                                tb2.Time < tr_b.Time
                                OR (tb2.Time = tr_b.Time AND tb2.TradeID <= tr_b.TradeID)
                              )
                      ) >= (
                        SELECT SUM(ts2.Volume)
                        FROM TradeRecord ts2
                        WHERE ts2.Direction = 'Sell'
                          AND ts2.Stock_Code = tr_sell.Stock_Code
                          AND ts2.Portfolio_PortfolioID = tr_sell.Portfolio_PortfolioID
                          AND (
                                ts2.Time < tr_sell.Time
                                OR (ts2.Time = tr_sell.Time AND ts2.TradeID <= tr_sell.TradeID)
                              )
                      )
                ORDER BY tr_b.Time ASC, tr_b.TradeID ASC
                LIMIT 1
            )
        ) * tr_sell.Volume
        - tr_sell.StampDuty
        - tr_sell.CapitalGainTax
    , 2) AS Net_Realized_Profit
FROM TradeRecord tr_sell
JOIN Portfolio p ON tr_sell.Portfolio_PortfolioID = p.PortfolioID
JOIN Stock s ON tr_sell.Stock_Code = s.Code
JOIN Company c ON s.Company_Name = c.Name
JOIN Exchange e ON s.Exchange_Code = e.Code
WHERE tr_sell.Direction = 'Sell'
  AND p.PortfolioID = 1
ORDER BY s.TradeCurrency, tr_sell.Time, tr_sell.TradeID;



/* =========================================================
   7. Negative growth companies with PE ratio
   ========================================================= */

SELECT 
    c.Name AS Company_Name,
    s.Code AS Stock_Code,
    s.TradeCurrency AS Currency,
    e.Name AS Exchange_Name,
    s.Industry,
    c.NetProfitGrowth AS Growth_Rate,
    CASE
        WHEN md.EPS IS NOT NULL AND md.EPS <> 0
            THEN ROUND(md.Close / md.EPS, 2)
        ELSE NULL
    END AS PE_Ratio
FROM Stock s
JOIN Company c ON s.Company_Name = c.Name
JOIN Exchange e ON s.Exchange_Code = e.Code
JOIN MarketData md ON s.Code = md.Stock_Code
WHERE c.NetProfitGrowth < 0
  AND DATE(md.Date) = '2026-04-02'
ORDER BY c.NetProfitGrowth ASC;

/* =========================================================
   8. Find portfolios with at least two sell transactions by currency
   ========================================================= */
SELECT 
    p.PortfolioID,
    p.Name AS Portfolio_Name,
    s.TradeCurrency,
    COUNT(*) AS Num_Sell_Trades,
    ROUND(SUM((tr.ExecutionPrice * tr.Volume) - tr.StampDuty - tr.CapitalGainTax), 2) AS Total_Sell_Amount_After_Tax
FROM TradeRecord tr
JOIN Portfolio p ON tr.Portfolio_PortfolioID = p.PortfolioID
JOIN Stock s ON tr.Stock_Code = s.Code
WHERE tr.Direction = 'Sell'
GROUP BY p.PortfolioID, p.Name, s.TradeCurrency
HAVING COUNT(*) >= 2;