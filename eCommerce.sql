-- Big project for SQL
-- Link instruction: https://docs.google.com/spreadsheets/d/1WnBJsZXj_4FDi2DyfLH1jkWtfTridO2icWbWCh7PLs8/edit#gid=0


-- Query 01: calculate total visit, pageview, transaction and revenue for Jan, Feb and March 2017 order by month
#standardSQL
SELECT *
FROM 


-- Query 02: Bounce rate per traffic source in July 2017
#standardSQL


-- Query 03: Revenue by traffic source by week, by month in June 2017


--Query 04: Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017. Note: totals.transactions >=1 for purchaser and totals.transactions is null for non-purchaser
#standardSQL




-- Query 05: Average number of transactions per user that made a purchase in July 2017
#standardSQL


-- Query 06: Average amount of money spent per session
#standardSQL



-- Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
#standardSQL



--Query 08: Calculate cohort map from pageview to addtocart to purchase in last 3 month. For example, 100% pageview then 40% add_to_cart and 10% purchase.
#standardSQL

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