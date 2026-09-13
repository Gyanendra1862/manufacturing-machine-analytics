select * from [dbo].[machine_operations]
select * from machine_master

--Level-3
--1.Show machine ID, machine type, installation year and total production.
SELECT 
    mo.machine_id,
    mm.machine_type,
    mm.installation_year,
    mm.maintenance_team,
    SUM(mo.production_units) AS total_production
FROM [dbo].[machine_operations] mo
INNER JOIN [dbo].[machine_master] mm
    ON mo.machine_id = mm.machine_id
GROUP BY
    mo.machine_id,
    mm.machine_type,
    mm.installation_year,
    mm.maintenance_team;

--2.Find the machine type having the highest downtime.
SELECT 
    machine_type,
    SUM(downtime_hours) AS total_downtime
FROM [dbo].[machine_operations]
GROUP BY machine_type
ORDER BY total_downtime DESC;

--3.Find total maintenance cost by machine type.
select  machine_type,sum(maintenance_cost_inr) from machine_operations
group by machine_type

--4.Find average OEE for each machine type.
select machine_type,avg(oee_pct) from machine_operations
group by machine_type

--5.Find the maintenance team responsible for machines with the highest downtime.
SELECT TOP 1
    mo.machine_id,
    mm.maintenance_team,
    SUM(mo.downtime_hours) AS total_downtime
FROM [dbo].[machine_operations] mo
INNER JOIN [dbo].[machine_master] mm
    ON mo.machine_id = mm.machine_id
GROUP BY
    mo.machine_id,
    mm.maintenance_team
ORDER BY total_downtime DESC;

--6. Find the top 10 machines by financial loss.
SELECT TOP 10
    machine_id,
    SUM(total_loss_inr) AS total_financial_loss
FROM machine_operations
GROUP BY machine_id
ORDER BY total_financial_loss DESC;
