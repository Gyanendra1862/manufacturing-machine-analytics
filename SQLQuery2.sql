-- level 2


--1.Total production by machine.
select machine_id ,sum(production_units) from [dbo].[machine_operations]
group by machine_id

--2. Total downtime by machine.
select machine_id ,sum(downtime_hours) from [dbo].[machine_operations]
group by machine_id

--3. Total maintenance cost by machine.
select machine_id ,sum(maintenance_cost_inr) from [dbo].[machine_operations]
group by machine_id

--4. Total failures by machine.

select machine_id ,count(failure_flag) from [dbo].[machine_operations]
where failure_flag=1
group by machine_id

--5.Average OEE by machine.
SELECT
    machine_id,
    ROUND(AVG(oee_pct), 2) AS average_oee
FROM [dbo].[machine_operations]
GROUP BY machine_id
ORDER BY average_oee DESC;

--6.Average temperature by machine type.
SELECT
    machine_type,
    ROUND(AVG(temperature_c), 2) 
FROM [dbo].[machine_operations]
GROUP BY machine_type
--7.Downtime by machine type.
select machine_type ,sum(downtime_hours) from [dbo].[machine_operations]
group by machine_type
--8.Production by machine type.
select machine_type ,sum(production_units) from [dbo].[machine_operations]
group by machine_type
--9.Defect rate by machine.

SELECT 
    machine_id,
    ROUND(
        CAST(SUM(defect_units) AS DECIMAL(18,4))
        / NULLIF(SUM(production_units), 0) * 100,
        2
    ) AS defect_rate_pct
FROM [dbo].[machine_operations]
GROUP BY machine_id;
--10. Failure count by failure type.
select failure_type ,count(failure_flag) from [dbo].[machine_operations]
where failure_flag=1
group by failure_type



