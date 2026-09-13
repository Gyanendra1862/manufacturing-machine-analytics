# Manufacturing Machine Performance, Downtime & Predictive Maintenance Analytics

## Dashboard

**Manufacturing Performance Dashboard**
### Dashboard Link :https://app.powerbi.com/groups/me/reports/d601a8be-a9b1-4501-b80e-6eee093a7176/3d2da8b750c3072502ba?experience=power-bi

## Problem Statement

This project analyzes manufacturing machine operations to help
management monitor production, OEE, downtime, failures, defects,
maintenance activity, and financial losses. The goal is to identify
underperforming and high-risk machines and support data-driven
maintenance decisions.

The project combines Mechanical Engineering, Data Analytics, SQL,
Python, Power BI, and Smart Manufacturing / Industry 4.0 concepts.

## Project Objectives

1.  Monitor overall production performance.
2.  Measure machine effectiveness using OEE.
3.  Identify machines with high downtime.
4.  Identify machines with frequent failures.
5.  Analyze failure and downtime reasons.
6.  Evaluate maintenance cost and maintenance hours.
7.  Identify high-risk machines.
8.  Analyze defect rates and quality.
9.  Quantify downtime, scrap, and total financial losses.
10. Track monthly production, downtime, failures, and financial loss.

## Tools & Technologies

- Python: Pandas, NumPy, Matplotlib, Seaborn
- SQL: SELECT, WHERE, GROUP BY, HAVING, JOIN, CASE, subqueries, CTEs,
  window functions, RANK, DENSE_RANK, ROW_NUMBER, LAG
- Power BI: Power Query, Data Modeling, DAX, KPI Cards, Bar Charts, Line
  Charts, Scatter Plot, Slicers, Tables
- GitHub for project documentation

## Dataset

### machine_operations

15,000 operational records and 29 columns.

Important fields: `timestamp`, `machine_id`, `machine_type`,
`machine_age_years`, `operating_hours`, `load_pct`, `temperature_c`,
`vibration_mm_s`, `pressure_bar`, `rpm`, `failure_flag`, `failure_type`,
`downtime_hours`, `downtime_reason`, `production_units`, `defect_units`,
`good_units`, `energy_kwh`, `maintenance_hours`, `maintenance_cost_inr`,
`setup_hours`, `revenue_inr`, `downtime_loss_inr`, `scrap_cost_inr`,
`total_loss_inr`, `availability_pct`, `performance_pct`, `quality_pct`,
`oee_pct`.

### machine_master

30 machines with: `machine_id`, `machine_type`, `installation_year`,
`rated_capacity_units_hr`, `maintenance_team`.

### Relationship

`machine_master[machine_id]` (1) → `machine_operations[machine_id]` (\*)

## Complete Workflow

``` text
RAW DATA
   ↓
Python Cleaning
   ↓
Python EDA
   ↓
Cleaned Dataset
   ↓
SQL Business Analysis
   ↓
Power BI Data Model
   ↓
DAX Measures
   ↓
Interactive Dashboard
   ↓
SQL ↔ Power BI Validation
   ↓
Business Insights
   ↓
Maintenance Recommendations
```

## Step 1 – Load Data

Loaded the machine-operation and machine-master CSV files into Python
with Pandas and inspected rows, columns, data types, missing values,
duplicates, and descriptive statistics.

``` python
import pandas as pd

df = pd.read_csv("machine_operations_15000.csv")
machine_master = pd.read_csv("machine_master.csv")
```

## Step 2 – Data Cleaning

Converted the timestamp column:

``` python
df['timestamp'] = pd.to_datetime(df['timestamp'])
```

Checked missing values. Missing values were present in selected
sensor/operational fields including temperature, vibration, pressure,
and energy. The missing proportion was small.

For temperature, mean imputation was used/considered appropriate because
the distribution was approximately normal, the mean and median were
close, and the missing proportion was small.

Interview explanation: \> I used mean imputation for temperature because
it was approximately normally distributed, the mean and median were very
close, and the proportion of missing values was small.

The cleaned data was saved separately:

``` python
df.to_csv("machine_operations_cleaned.csv", index=False)
```

## Step 3 – Python EDA

Performed: - Missing-value analysis - Distribution analysis -
Boxplots/outlier analysis - Correlation analysis - Production analysis -
Downtime analysis - Failure analysis - Maintenance-cost analysis - OEE
analysis - Defect analysis - Financial-loss analysis - Business-focused
visualizations

## Step 4 – Basic SQL Analysis

Examples:

``` sql
SELECT COUNT(DISTINCT machine_id) AS total_machines
FROM machine_operations;
```

``` sql
SELECT COUNT(*) AS operation_records
FROM machine_operations;
```

``` sql
SELECT SUM(production_units) AS total_production
FROM machine_operations;
```

``` sql
SELECT ROUND(SUM(downtime_hours),2) AS total_downtime
FROM machine_operations;
```

``` sql
SELECT ROUND(SUM(maintenance_cost_inr),2) AS total_maintenance_cost
FROM machine_operations;
```

``` sql
SELECT ROUND(SUM(revenue_inr),2) AS total_revenue
FROM machine_operations;
```

``` sql
SELECT COUNT(*) AS failure_count
FROM machine_operations
WHERE failure_flag = 1;
```

## Step 5 – GROUP BY Analysis

Analyzed: - Production by machine - Downtime by machine - Maintenance
cost by machine - Failures by machine - Average OEE by machine -
Temperature by machine type - Downtime by machine type - Production by
machine type - Defect rate by machine - Failure count by failure type

Example:

``` sql
SELECT machine_id,
       ROUND(AVG(oee_pct),2) AS average_oee
FROM machine_operations
GROUP BY machine_id
ORDER BY average_oee DESC;
```

Defect rate:

``` sql
SELECT machine_id,
       ROUND(
           CAST(SUM(defect_units) AS DECIMAL(18,4))
           / NULLIF(SUM(production_units),0) * 100,
           2
       ) AS defect_rate_pct
FROM machine_operations
GROUP BY machine_id;
```

## Step 6 – JOIN Analysis

Joined machine operations with machine master:

``` sql
SELECT mo.machine_id,
       mm.machine_type,
       mm.installation_year,
       mm.maintenance_team,
       SUM(mo.production_units) AS total_production
FROM machine_operations mo
INNER JOIN machine_master mm
    ON mo.machine_id = mm.machine_id
GROUP BY mo.machine_id,
         mm.machine_type,
         mm.installation_year,
         mm.maintenance_team;
```

## Step 7 – HAVING and CASE

Machines with high downtime:

``` sql
SELECT machine_id,
       SUM(downtime_hours) AS total_downtime
FROM machine_operations
GROUP BY machine_id
HAVING SUM(downtime_hours) > 100;
```

Machine OEE classification:

``` sql
SELECT machine_id,
       ROUND(AVG(oee_pct),2) AS average_oee,
       CASE
           WHEN AVG(oee_pct) >= 85 THEN 'Excellent'
           WHEN AVG(oee_pct) >= 70 THEN 'Good'
           ELSE 'Poor'
       END AS category
FROM machine_operations
GROUP BY machine_id;
```

Downtime classification:

``` sql
SELECT machine_id,
       SUM(downtime_hours) AS total_downtime,
       CASE
           WHEN SUM(downtime_hours) < 50 THEN 'Low'
           WHEN SUM(downtime_hours) <= 100 THEN 'Medium'
           ELSE 'High'
       END AS downtime_category
FROM machine_operations
GROUP BY machine_id;
```

Key learning: - WHERE filters rows. - HAVING filters grouped results. -
Machine-level questions require machine-level aggregation before
classification.

## Step 8 – Advanced SQL

Repeated failures:

``` sql
SELECT machine_id,
       COUNT(*) AS failure_count
FROM machine_operations
WHERE failure_flag = 1
GROUP BY machine_id
HAVING COUNT(*) > 1
ORDER BY failure_count DESC;
```

Downtime contribution:

``` sql
SELECT machine_id,
       ROUND(
           SUM(downtime_hours) * 100.0 /
           SUM(SUM(downtime_hours)) OVER (),
           2
       ) AS downtime_contribution_pct
FROM machine_operations
GROUP BY machine_id
ORDER BY downtime_contribution_pct DESC;
```

OEE ranking:

``` sql
SELECT machine_id,
       ROUND(AVG(oee_pct),2) AS average_oee,
       RANK() OVER (ORDER BY AVG(oee_pct) DESC) AS oee_rank
FROM machine_operations
GROUP BY machine_id
ORDER BY oee_rank;
```

Downtime ranking:

``` sql
SELECT machine_id,
       ROUND(SUM(downtime_hours),2) AS total_downtime,
       DENSE_RANK() OVER (
           ORDER BY SUM(downtime_hours) DESC
       ) AS downtime_rank
FROM machine_operations
GROUP BY machine_id
ORDER BY downtime_rank;
```

## Step 9 – CTE High-Risk Analysis

``` sql
WITH machine_metrics AS (
    SELECT machine_id,
           SUM(downtime_hours) AS total_downtime,
           AVG(oee_pct) AS average_oee,
           SUM(CASE WHEN failure_flag = 1 THEN 1 ELSE 0 END) AS failure_count
    FROM machine_operations
    GROUP BY machine_id
)
SELECT machine_id,
       ROUND(total_downtime,2) AS total_downtime,
       ROUND(average_oee,2) AS average_oee,
       failure_count
FROM machine_metrics
WHERE total_downtime > 100
  AND average_oee < 70
  AND failure_count > 5;
```

## Step 10 – Monthly Downtime with LAG

``` sql
WITH monthly_downtime AS (
    SELECT machine_id,
           DATEFROMPARTS(YEAR(timestamp), MONTH(timestamp), 1) AS month,
           SUM(downtime_hours) AS total_downtime
    FROM machine_operations
    GROUP BY machine_id, YEAR(timestamp), MONTH(timestamp)
),
downtime_comparison AS (
    SELECT machine_id,
           month,
           total_downtime,
           LAG(total_downtime) OVER (
               PARTITION BY machine_id ORDER BY month
           ) AS previous_month_downtime
    FROM monthly_downtime
)
SELECT machine_id,
       month,
       total_downtime,
       previous_month_downtime
FROM downtime_comparison
WHERE total_downtime > previous_month_downtime;
```

## Step 11 – Power BI Data Model

Imported both tables and created:

``` text
machine_master (1)
        |
        | machine_id
        ↓
machine_operations (*)
```

Checked the relationship and machine IDs.

## Step 12 – Month-Year Column and Sorting

Created:

``` dax
Month Year =
FORMAT(
    DATE(
        machine_operations[Year],
        machine_operations[Month],
        1
    ),
    "MMM-yyyy"
)
```

Created chronological sort key:

``` dax
Month Year Sort =
machine_operations[Year] * 100
    + machine_operations[Month]
```

Configured `Month Year` to sort by `Month Year Sort`.

## Step 13 – DAX Measures

Total Production:

``` dax
Total Production =
SUM(machine_operations[production_units])
```

Good Units:

``` dax
Good Units =
SUM(machine_operations[good_units])
```

Total Defects:

``` dax
Total Defects =
SUM(machine_operations[defect_units])
```

Total Downtime:

``` dax
Total Downtime =
SUM(machine_operations[downtime_hours])
```

Revenue:

``` dax
Total Revenue =
SUM(machine_operations[revenue_inr])
```

Maintenance:

``` dax
Maintenance Cost =
SUM(machine_operations[maintenance_cost_inr])
```

Financial Loss:

``` dax
Financial Loss =
SUM(machine_operations[total_loss_inr])
```

Failure Count:

``` dax
Failure Count =
CALCULATE(
    COUNTROWS(machine_operations),
    machine_operations[failure_flag] = 1
)
```

Average OEE:

``` dax
Average OEE =
AVERAGE(machine_operations[oee_pct])
```

Defect Rate:

``` dax
Defect Rate =
DIVIDE(
    [Total Defects],
    [Total Production],
    0
) * 100
```

## Step 14 – OEE

OEE was analyzed as:

``` text
OEE = Availability × Performance × Quality
```

The dataset contains: - Availability % - Performance % - Quality % - OEE
%

OEE was used as a core manufacturing KPI.

## Step 15 – Scatter Plot

Created **OEE vs Downtime** scatter plot.

Configuration:

``` text
X-axis  → Sum of downtime_hours
Y-axis  → Average of oee_pct
Legend  → machine_id
```

Each point represents a machine. The purpose is to identify machines
with high downtime and low OEE.

## Step 16 – Final Power BI Dashboard

The final report contains **5 pages**.

### Page 1 – Manufacturing Performance Dashboard

Purpose: Executive overview.

KPI cards: - Total Production - Good Units - Total Downtime - Avg OEE -
Failures - Maintenance - Financial Loss

Charts: - Monthly Production - Monthly Downtime - Average OEE by Machine
Type - Failure Count by Failure Type

Final displayed KPIs: - Total Production = 10,870,300 - Good Units =
10,511,638 - Total Downtime = 45,484.71 hours - Avg OEE = 65.21% -
Failures = 6,766 - Maintenance = ₹83.49M - Financial Loss = ₹506.0M

### Page 2 – Machine Performance

Purpose: Compare machines and identify underperforming equipment.

KPI cards: - Total Production - Total Downtime - Avg OEE - Defect Rate

Charts: - Lowest 10 Machines by OEE - Highest 10 Machines by Downtime -
OEE vs Downtime - Highest Defect Rate

### Page 3 – Downtime & Failure Analysis

Purpose: Understand where production time is being lost and why.

KPI cards: - Total Downtime - Avg Downtime - Total Failure - Failure
Type count

Charts: - Downtime by Machine - Downtime by Reason - Failure Type
Distribution - Monthly Failure Trend

### Page 4 – Maintenance & Risk Analysis

Purpose: Prioritize machines using OEE, downtime, failures and
maintenance cost.

KPI cards: - Maintenance Cost - Maintenance Hours - Total Failure -
Machines

Charts/table: - Maintenance Cost by Machine - OEE by Maintenance /
Machine Type - Failure Count by Machine - High-Risk Machine table

High-risk table fields: - Machine ID - OEE % - Downtime Hours - Failure
Count - Maintenance Cost

### Page 5 – Financial Impact & KPI Validation

Purpose: Quantify machine-related financial losses.

KPI cards: - Revenue - Downtime Losses - Scrap Cost - Total Loss

Visuals: - Top 10 Financial Loss by Machine - Monthly Financial Loss
Trend

Final displayed KPIs: - Revenue = ₹1,634.46M - Downtime Losses =
₹391.80M - Scrap Cost = ₹30.73M - Total Loss = ₹506.01M

## Key Results / Insights

### Overall Performance

- Production: 10.87M units
- Good units: 10.51M
- Downtime: 45,484.71 hours
- Average OEE: 65.21%
- Failures: 6,766
- Maintenance cost: ₹83.49M
- Financial loss: about ₹506.01M

### OEE by Machine Type

Approximate average OEE: - CNC Lathe: 66% - CNC Mill: 65% - Grinding:
65% - Press: 65% - Injection Molding: 65%

### Failure Analysis

Failure counts: - Mechanical: 2,285 - Electrical: 1,555 - Hydraulic:
1,182 - Overheating: 928 - Tool Wear: 816

Mechanical failures are the largest category.

### Highest Downtime Machines

The dashboard identifies: - M-019 - M-015 - M-028 - M-006 - M-022 -
M-013 - M-004 - M-012

Top listed downtime: - M-019: about 1,740 hours - M-015: about 1,701
hours - M-028: about 1,662 hours - M-006: about 1,648 hours - M-022:
about 1,642 hours

### High-Risk Machines

Risk was evaluated using multiple indicators: - Low OEE - High
downtime - High failure count - High maintenance cost

Example: - M-019: OEE 63.85%, downtime 1,739.87 h, failures 259,
maintenance cost ₹3.07M - M-013: OEE 63.93%, downtime 1,620.28 h,
failures 259, maintenance cost ₹3.59M

### Financial Impact

- Revenue: ₹1,634.46M
- Downtime loss: ₹391.80M
- Scrap cost: ₹30.73M
- Total loss: ₹506.01M

Top financial-loss machines include: M-019, M-013, M-015, M-022, M-028,
M-006, M-016, M-024, M-001, M-018.

## Business Recommendations

1.  Prioritize high-risk machines with low OEE, high downtime, frequent
    failures and high maintenance cost.
2.  Investigate mechanical failures because they are the largest failure
    category.
3.  Use vibration, temperature, pressure, RPM and load for deeper
    condition monitoring.
4.  Reduce repeated/unplanned downtime.
5.  Monitor OEE at machine, machine-type, maintenance-team and monthly
    levels.
6.  Reduce downtime losses because downtime is a major contributor to
    total financial loss.
7.  Use the current analytics foundation as the basis for a future
    machine-failure prediction model.

## What I Learned

### Python

- Data loading
- Data inspection
- Data cleaning
- Missing-value handling
- Imputation
- EDA
- Distribution analysis
- Correlation
- Visualization
- Business analysis

### SQL

- Filtering
- Aggregation
- GROUP BY
- HAVING
- JOIN
- CASE
- Subqueries
- CTEs
- Window functions
- RANK
- DENSE_RANK
- ROW_NUMBER
- LAG
- Machine-level business analysis

### Power BI

- Power Query
- Data modeling
- Relationships
- DAX calculated columns
- DAX measures
- KPI cards
- Line charts
- Bar charts
- Scatter plots
- Slicers
- Date sorting
- Multi-page dashboard design
- KPI validation

## Interview Explanation – 30 Seconds

> I developed a manufacturing machine performance and
> predictive-maintenance analytics dashboard using Python, SQL and Power
> BI. I worked with 15,000 machine-operation records across 30 machines.
> I cleaned and explored the data in Python, performed business analysis
> and validation using SQL, and built a five-page Power BI dashboard
> covering production, OEE, downtime, failures, maintenance cost,
> defects and financial losses. I also created a high-risk machine
> analysis combining OEE, downtime, failure count and maintenance cost
> to help prioritize maintenance actions.

## Why This Project Fits Mechanical Engineering

The project connects mechanical manufacturing concepts such as machine
performance, downtime, maintenance, vibration, temperature, pressure,
production efficiency and OEE with data analytics. It is therefore
relevant to Smart Manufacturing and Industry 4.0 roles.

## Project Structure

``` text
Manufacturing-Machine-Analytics/
│
├── data/
│   ├── machine_operations_15000.csv
│   ├── machine_operations_cleaned.csv
│   └── machine_master.csv
│
├── python/
│   └── manufacturing_eda.ipynb
│
├── sql/
│   └── manufacturing_analysis.sql
│
├── powerbi/
│   └── manufacturing_performance_dashboard.pbix
│
├── screenshots/
│   ├── executive_overview.png
│   ├── machine_performance.png
│   ├── downtime_failure.png
│   ├── maintenance_risk.png
│   └── financial_impact.png
│
└── README.md
```

## Final Outcome

The final project follows the complete analytics lifecycle:

``` text
Data
  ↓
Cleaning
  ↓
EDA
  ↓
SQL Analysis
  ↓
Data Modeling
  ↓
DAX
  ↓
Power BI Dashboard
  ↓
KPI Validation
  ↓
Business Insights
  ↓
Maintenance Recommendations
```

**Author:** Gyanendra Kumar  
**Focus:**  Data Analytics \| Business
Analytics \| Smart Manufacturing
