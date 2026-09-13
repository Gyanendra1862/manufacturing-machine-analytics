create database Mechine
use mechine

select top 10 * from [dbo].[machine_operations]

--1. How many machines are there?
select count(distinct machine_id) from [dbo].[machine_operations]
--2.How many operation records are there?
select count(*) from [dbo].[machine_operations]
--3.What are the different machine types?
select distinct machine_type from [dbo].[machine_operations]
--4.What is the total production?
select sum(production_units) from [dbo].[machine_operations]
--5.What is the total downtime?
select round(sum(downtime_hours),2) from [dbo].[machine_operations]
--6.What is the total maintenance cost?
select round(sum(maintenance_cost_inr),2) from [dbo].[machine_operations]
--7.What is the total revenue?
select round(sum(revenue_inr),2) from [dbo].[machine_operations]
--8.How many failures occurred?
select count(failure_flag) from [dbo].[machine_operations]
where failure_flag=1
--9.What is the average temperature?
select avg(temperature_c) from [dbo].[machine_operations]
--10.What is the average vibration?
select avg(vibration_mm_s) from [dbo].[machine_operations]













