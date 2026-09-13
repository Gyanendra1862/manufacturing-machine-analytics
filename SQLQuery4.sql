--level 4
select * from [dbo].[machine_operations]
select * from machine_master
--1.Find machines with more than 100 hours of downtime.
select machine_id,sum(downtime_hours) from machine_operations
group by machine_id
having sum(downtime_hours)>100

--2. Find machines with average OEE below 70%.
select machine_id,avg(oee_pct) from machine_operations
group by machine_id
having avg(oee_pct) <70
--3. Categorize machines:
--OEE ≥ 85 → Excellent
--Categorize machines:
--OEE ≥ 85 → Excellent
--70–85 → Good
--<70 → Poor
SELECT
    machine_id,
    ROUND(AVG(oee_pct), 2) AS average_oee,
    CASE
        WHEN AVG(oee_pct) >= 85 THEN 'Excellent'
        WHEN AVG(oee_pct) >= 70 THEN 'Good'
        ELSE 'Poor'
    END AS category
FROM machine_operations
GROUP BY machine_id;
--4. Categorize machines based on downtime:
--<50 → Low
--50–100 → Medium
--100 → High
--<70 → Poor
SELECT
    machine_id,
    SUM(downtime_hours) AS total_downtime,
    CASE
        WHEN SUM(downtime_hours) < 50 THEN 'Low'
        WHEN SUM(downtime_hours) <= 100 THEN 'Medium'
        ELSE 'High'
    END AS downtime_category
FROM machine_operations
GROUP BY machine_id;
--5.Find machines whose failure count is above the average failure count.
SELECT 
    machine_id,
    COUNT(*) AS failure_count
FROM machine_operations
WHERE failure_flag = 1
GROUP BY machine_id
HAVING COUNT(*) > (
    SELECT AVG(failure_count)
    FROM (
        SELECT 
            machine_id,
            COUNT(*) AS failure_count
        FROM machine_operations
        WHERE failure_flag = 1
        GROUP BY machine_id
    ) AS machine_failures
);