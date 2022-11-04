-- Big project for SQL
-- Link instruction: https://docs.google.com/spreadsheets/d/1WnBJsZXj_4FDi2DyfLH1jkWtfTridO2icWbWCh7PLs8/edit#gid=0


-- Query 01: calculate total visit, pageview, transaction and revenue for Jan, Feb and March 2017 order by month
#standardSQL
SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE('%Y%m%d', date)) AS month, 
    SUM(totals.visits) AS visits, 
    SUM(totals.pageviews) AS pageviews, 
    SUM(totals.transactions) AS transactions, 
    SUM(totals.totalTransactionRevenue) / 1000000 AS revenue 
    FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` 
WHERE _table_suffix BETWEEN '0101' AND '0331'
GROUP BY month
ORDER BY month;


-- Query 02: Bounce rate per traffic source in July 2017
#standardSQL
SELECT 
    trafficSource.source AS source,
    SUM(totals.visits) AS total_visits,
    SUM(totals.bounces) AS total_no_of_bounces,
    SUM(totals.bounces) / SUM(totals.visits) * 100 AS bounce_rate

FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*` 
GROUP BY source
ORDER BY total_visits DESC;


-- Query 03: Revenue by traffic source by week, by month in June 2017
-- week data
SELECT 
    "Week" AS time_type,
    FORMAT_DATE("%Y%W", PARSE_DATE("%Y%m%d", date)) as time,
    trafficSource.source AS source,
    SUM(totals.totalTransactionRevenue) / 1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
GROUP BY time, source
UNION ALL
SELECT 
    "Month" AS time_type,
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) as time,
    trafficSource.source AS source,
    SUM(totals.totalTransactionRevenue) / 1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
GROUP BY time, source
ORDER BY revenue DESC;

--Query 04: Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017. Note: totals.transactions >=1 for purchaser and totals.transactions is null for non-purchaser
#standardSQL
WITH purchase AS (
  SELECT 
      FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
      SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId) AS avg_pageviews_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  WHERE 
      _table_suffix BETWEEN '0601' AND '0731'
    AND totals.transactions >= 1 
  GROUP BY month
),
non_purchase AS (
  SELECT 
      FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
      SUM(totals.pageviews)/COUNT(DISTINCT fullVisitorId) AS avg_pageviews_non_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  WHERE 
      _table_suffix BETWEEN '0601' AND '0731'
      AND totals.transactions IS NULL 
  GROUP BY month
)

SELECT P.month, P.avg_pageviews_purchase, N.avg_pageviews_non_purchase
FROM purchase AS P
INNER JOIN non_purchase AS N
ON P.month = N.month
ORDER BY P.month;



-- Query 05: Average number of transactions per user that made a purchase in July 2017
SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    SUM(totals.transactions) / COUNT(DISTINCT fullVisitorId) AS Avg_total_transactions_per_user
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
WHERE totals.transactions >= 1
GROUP BY month;

-- Query 06: Average amount of money spent per session
#standardSQL
SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    FORMAT("%'.2f",SUM(totals.totalTransactionRevenue) / SUM(totals.visits)) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
WHERE totals.transactions >= 1
GROUP BY month;


-- Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
#standardSQL
WITH youtube_buy AS (
  SELECT DISTINCT fullVisitorId AS youtube_id
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
  UNNEST(hits) AS hit,
  UNNEST(hit.product) AS product
  WHERE product.v2ProductName = "YouTube Men's Vintage Henley"  
    AND product.productRevenue IS NOT NULL
)

SELECT 
    product.v2ProductName AS other_purchased_products, 
    SUM(product.productQuantity) AS quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
UNNEST(hits) AS hit,
UNNEST(hit.product) AS product
INNER JOIN youtube_buy AS Y
ON fullVisitorId = youtube_id
WHERE product.productRevenue IS NOT NULL
  AND product.v2ProductName <> "YouTube Men's Vintage Henley"
GROUP BY other_purchased_products
ORDER BY quantity DESC;


--Query 08: Calculate cohort map from pageview to addtocart to purchase in last 3 month. For example, 100% pageview then 40% add_to_cart and 10% purchase.
#standardSQL
WITH product_view AS (
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    SUM(CASE 
          WHEN hit.eCommerceAction.action_type = '2' THEN 1
          ELSE 0
        END
    ) AS num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) AS hit
  WHERE _table_suffix BETWEEN '0101' AND '0331'
  GROUP BY month
),
add_to_cart AS (
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    SUM(CASE 
          WHEN hit.eCommerceAction.action_type = '3' THEN 1
          ELSE 0
        END
    ) AS num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) AS hit
  WHERE _table_suffix BETWEEN '0101' AND '0331'
  GROUP BY month
), 
purchase AS (
  SELECT 
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month,
    SUM(CASE 
          WHEN hit.eCommerceAction.action_type = '6' THEN 1
          ELSE 0
        END
    ) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
  UNNEST (hits) AS hit
  WHERE _table_suffix BETWEEN '0101' AND '0331'
  GROUP BY month
)

SELECT 
    v.month, 
    v.num_product_view, 
    a.num_addtocart, 
    p.num_purchase, 
    ROUND(a.num_addtocart / v.num_product_view * 100, 2) AS add_to_cart_rate,
    ROUND(p.num_purchase / v.num_product_view * 100, 2) AS purchase_rate
FROM product_view AS v
INNER JOIN add_to_cart AS a
ON v.month = a.month
INNER JOIN purchase AS p
ON v.month = p.month
ORDER BY v.month;

-- Unnest sử dụng khi mình làm việc với các array (hay dạng struct). Khi cậu không unnest thì nó sẽ báo lỗi.
-- Ví dụ như ở câu 7:
-- FROM
--   bigquery-public-data.google_analytics_sample.ga_sessions_201707*,
--   UNNEST (hits) hits,
--   UNNEST (hits.product) product
-- where product.v2ProductName="YouTube Men's Vintage Henley"

-- Mọi người chú ý những dấu , dấu "" nhé
-- Nếu mình ko có bước
-- UNNEST (hits) hits,
-- UNNEST (hits.product) product

-- mà mình dùng hits.product.v2ProductName thì nó sẽ báo lỗi do bên trong nó là 1 cái array.
-- Bản chất của unnest nó giống như cross join ấy. Nó giúp mình tách từng thành phần bên trong array đó ra.
-- Ví dụ như data mình có 2 cột, giá trị là:

-- col1      col2
-- X       [1,2,3,4]

-- Sau khi unnest(col2) thì output sẽ như sau:
-- X   1
-- X   2
-- X   3
-- X   4"