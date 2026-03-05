# Chinook Music Store Sales Analysis

## Project Overview

This project analyzes the sales performance of the Chinook Music Store, a digital music retailer that sells tracks from different artists, albums, and genres across multiple countries. The goal of this analysis is to understand sales performance, customer behavior, market opportunities, and product trends in order to provide actionable business insights.

Using SQL and Power BI, the project explores how revenue is generated, which products and genres drive the most sales, how customers behave, and how performance changes over time.

The analysis ultimately answers key business questions such as:

* Which tracks, artists, and genres generate the most revenue?
* Which countries and markets contribute the most sales?
* How do customers behave and how loyal are they?
* What factors drive monthly revenue changes?


## Tools & Technologies
SQL (Data Exploration & Business Analysis)

SQL was used to explore the database, and answer analytical business questions. The main tasks performed with SQL include:
* Exploring the Chinook relational database
* Creating analytical queries for KPIs and insights
* Performing aggregations and window function analysis
* Identifying trends in sales, customers, and product performance
* Calculating key metrics such as:
    * Total Revenue
    * Units Sold
    * Average Order Value
    * Customer Lifetime Value
    * Monthly Revenue Growth
    * Repeat Purchase Rate
 

## Power BI (Data Modeling & Visualization)
Power BI was used to transform the SQL results into an interactive business intelligence dashboard.

The key tasks performed in Power BI include:
* Importing the dataset from SQL
* Building a Star Schema data model
* Creating relationships between fact and dimension tables
* Developing interactive dashboards
* Building measures using DAX
* Visualizing key performance indicators and trends

The dashboard allows users to:
* Monitor revenue performance
* Identify top-performing products
* Compare sales across countries
* Track monthly sales trends


## Data Model
Although the Chinook database is originally structured as a snowflake schema, a star schema model was implemented in Power BI to improve analytical performance and simplify reporting.

The main Fact Table represents sales transactions (invoice line level), while supporting Dimension Tables provide descriptive context for analysis.

Fact Table
* Sales (InvoiceLine level)

Dimension Tables
* Customer
* Track
* Employee (Sales Agent)
* Date

This structure enables efficient slicing of sales metrics across multiple dimensions such as time, geography, product category, and customer behavior.
