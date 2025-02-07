SELECT
    CASE WHEN (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60 ) >= 0 THEN (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60 ) ELSE (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60 ) + 1600 END AS duration
FROM downtime_analysis.line_productivity;


-- Add the above column as a permanent column into the table for easier access
ALTER TABLE downtime_analysis.line_productivity
ADD COLUMN duration numeric GENERATED ALWAYS AS (
  CASE
    WHEN (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60) >= 0
      THEN (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60)
    ELSE (EXTRACT(EPOCH FROM ("End Time" - "Start Time")) / 60) + 1600
  END
) STORED;

-- Just to check if it worked
SELECT * FROM downtime_analysis.line_productivity;

-- The below query is to see how many days of data do we have
SELECT  (MAX(date) - MIN(date)) AS timeframe
FROM downtime_analysis.line_productivity;

-- The date is for 5 days, which seems to be the working week


-- With this done, now my job is to see what the line efficiency was
-- The formula I am using for efficiency is (Minimum Time / Total Time) * 100

SELECT batch, operator, duration, "Min batch time", ROUND(("Min batch time"/(duration * 1.0)) * 100.0, 2)AS efficiency
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON lp.product = p.product;


SELECT lp.product, COUNT(*) AS row_count
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
  ON p.product = lp.product
GROUP BY lp.product;
-- Now I want to determine how much volume total was produced in the timeframe

SELECT SUM("Size(in ml)") AS total_volume_produced
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON p.product = lp.product;

-- The plant produced 29800 ml

-- Now we know that this works, now I want to see the line efficiency of this plant
SELECT AVG(ROUND(("Min batch time"/(duration * 1.0)) * 100.0, 2))
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON lp.product = p.product;

-- The Line Efficiency for this plant for the week was 65.98 %. We need past data or average data from other weeks to compare


-- Now our job is to see if any operators are under performing based on the metrics we decided
-- First, we do the operator efficiency rate discussed in the original documentation.

SELECT operator, ROUND(AVG("Min batch time"/(duration * 1.0) * 100.0), 2) AS average_efficiency
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON lp.product = p.product
GROUP BY operator
ORDER BY average_efficiency DESC;

-- Charlie is the most efficient at 70.97, followed by Dee and 66.81, then Dennis at 65.9q, and Mac at 58.06

-- But as discussed in the documentation, with a small sample like this, it can be misleading and such we only need to incorporate errors as some of them weren't caused by operator errors
SELECT operator, ROUND(SUM(value)/(SUM("Min batch time")*1.0),2) AS operator_error
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON lp.product = p.product
INNER JOIN downtime_analysis.line_downtime ld
ON lp.batch = ld.batch
INNER JOIN downtime_analysis.downtime_factors df
ON df.factor = ld.factor AND df."Operator Error" = 'Yes'
GROUP BY operator
ORDER BY operator_error DESC;

-- Looks like Mac has the highest operator error at 0.42, followed by Dennis at 0.38, Then Charlie at 0.37, Then Dee at 0.32

-- The next step was to see which operators product the most volume of product
SELECT operator, SUM("Size(in ml)") AS total_volume
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.products p
ON lp.product = p.product
GROUP BY operator
ORDER BY total_volume DESC;

-- Charlie produced the most in the week with 10800 mL, followed by Dee at 6600, then Mac and Dennis both at 6200

SELECT description, SUM(value) as downtime_caused
FROM downtime_analysis.line_downtime ld
INNER JOIN downtime_analysis.downtime_factors df
ON ld.factor = df.factor
GROUP BY description
ORDER BY downtime_caused DESC;

-- Machine Adjustment caused the most downtime at 332 minutes
-- Then Machine Failure at 254 minutes,
-- Inventory Shortage at 225 minutes,

-- The issues that caused the least downtime are Conveyor Belt Jam at 17 minutes and Label Switch at 33 minutes

-- Now I want to do it by product to see if any of the products have anything to do with per minute

SELECT flavor, ROUND(SUM(value)/(SUM("Size(in ml)") * 1.0),2) AS downtime_per_product
FROM downtime_analysis.products p
INNER JOIN downtime_analysis.line_productivity lp
ON p.product = lp.product
INNER JOIN downtime_analysis.line_downtime ld
ON lp.batch = ld.batch
INNER JOIN downtime_analysis.downtime_factors df
ON df.factor = ld.factor
GROUP BY flavor
ORDER BY downtime_per_product DESC;

-- Looks like Orange for some reason gives the most trouble, by a lot, at 0.06 minutes of downtime caused per 1 ml produced,
-- The most efficient is Cola at 0.02 downtime caused per mL produced.


-- Operator Struggles

SELECT operator, description, SUM(ld.value) as downtime
FROM downtime_analysis.line_productivity lp
INNER JOIN downtime_analysis.line_downtime ld
ON lp.batch = ld.batch
INNER JOIN downtime_analysis.downtime_factors df
ON ld.factor = df.factor AND df."Operator Error" = 'Yes'
GROUP BY operator, description
ORDER BY downtime DESC
