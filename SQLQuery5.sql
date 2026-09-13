--level 5

--1.Find the top 5 machines by total financial loss.
select top 5 machine_id ,round(sum(total_loss_inr),2) from machine_operations
group by machine_id
order by sum(total_loss_inr) desc
--2.Find the top machine in each machine type.
SELECT
    machine_type,
    machine_id,
    SUM(total_loss_inr) AS total_loss,
    ROW_NUMBER() OVER (
        PARTITION BY machine_type
        ORDER BY SUM(total_loss_inr) DESC
    ) AS rnk
FROM machine_operations
GROUP BY machine_type, machine_id;
--3.Find monthly production.
select Month,sum(production_units) from machine_operations
group by month
order by month asc
--4.Find monthly downtime.
select Month,round(sum(downtime_hours),2) from machine_operations
group by month
order by month asc
--5.Find monthly OEE.
select Month,round(sum(oee_pct),2) from machine_operations
group by month
order by month asc
--6.Find machines whose downtime increased compared with the previous month.
WITH monthly_downtime AS (
    SELECT
        machine_id,
        DATEFROMPARTS(
            YEAR(Time),
            MONTH(Time),
            1
        ) AS month,
        SUM(downtime_hours) AS total_downtime
    FROM machine_operations
    GROUP BY
        machine_id,
        YEAR(Time),
        MONTH(Time)
),
downtime_comparison AS (
    SELECT
        machine_id,
        month,
        total_downtime,
        LAG(total_downtime) OVER (
            PARTITION BY machine_id
            ORDER BY month
        ) AS previous_month_downtime
    FROM monthly_downtime
)
SELECT
    machine_id,
    month,
    total_downtime,
    previous_month_downtime
FROM downtime_comparison
WHERE total_downtime > previous_month_downtime;
--7.Find repeated failures for the same machine
SELECT
    machine_id,
    COUNT(*) AS failure_count
FROM machine_operations
WHERE failure_flag = 1
GROUP BY machine_id
HAVING COUNT(*) > 1
ORDER BY failure_count DESC;
--8.Percentage contribution of each machine to total downtime
SELECT
    machine_id,
    ROUND(
        SUM(downtime_hours) * 100.0 /
        SUM(SUM(downtime_hours)) OVER (),
        2
    ) AS downtime_contribution_pct
FROM machine_operations
GROUP BY machine_id
ORDER BY downtime_contribution_pct DESC;
--9.Percentage contribution to total financial loss
SELECT
    machine_id,
    ROUND(
        SUM(total_loss_inr) * 100.0 /
        SUM(SUM(total_loss_inr)) OVER (),
        2
    ) AS loss_contribution_pct
FROM machine_operations
GROUP BY machine_id
ORDER BY loss_contribution_pct DESC;
--10.Rank machines by OEE using RANK()
SELECT
    machine_id,
    ROUND(AVG(oee_pct), 2) AS average_oee,
    RANK() OVER (
        ORDER BY AVG(oee_pct) DESC
    ) AS oee_rank
FROM machine_operations
GROUP BY machine_id
ORDER BY oee_rank;
--11.Rank machines by downtime using DENSE_RANK()
SELECT
    machine_id,
    ROUND(SUM(downtime_hours), 2) AS total_downtime,
    DENSE_RANK() OVER (
        ORDER BY SUM(downtime_hours) DESC
    ) AS downtime_rank
FROM machine_operations
GROUP BY machine_id
ORDER BY downtime_rank;
--12.Use a CTE to identify high-risk machines
WITH machine_metrics AS (
    SELECT
        machine_id,
        SUM(downtime_hours) AS total_downtime,
        AVG(oee_pct) AS average_oee,
        SUM(CASE WHEN failure_flag = 1 THEN 1 ELSE 0 END) AS failure_count
    FROM machine_operations
    GROUP BY machine_id
)
SELECT
    machine_id,
    ROUND(total_downtime, 2) AS total_downtime,
    ROUND(average_oee, 2) AS average_oee,
    failure_count
FROM machine_metrics
WHERE total_downtime > 100
  AND average_oee < 70
  AND failure_count > 5;
  --13.Compare machine performance against overall average
  SELECT
    machine_id,
    ROUND(AVG(oee_pct), 2) AS machine_oee,
    ROUND(
        (SELECT AVG(oee_pct)
         FROM machine_operations), 2
    ) AS overall_average_oee
FROM machine_operations
GROUP BY machine_id;
--14.High downtime + high maintenance cost + low OEE
WITH machine_metrics AS (
    SELECT
        machine_id,
        SUM(downtime_hours) AS total_downtime,
        SUM(maintenance_cost_inr) AS total_maintenance_cost,
        AVG(oee_pct) AS average_oee
    FROM machine_operations
    GROUP BY machine_id
)
SELECT
    machine_id,
    ROUND(total_downtime, 2) AS total_downtime,
    ROUND(total_maintenance_cost, 2) AS total_maintenance_cost,
    ROUND(average_oee, 2) AS average_oee
FROM machine_metrics
WHERE total_downtime > 100
  AND total_maintenance_cost > 100000
  AND average_oee < 70
ORDER BY total_downtime DESC;