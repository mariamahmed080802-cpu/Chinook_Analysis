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


## Key Performance Indicators (KPIs)

Over the period of our dataset, the Chinook Music Store generated $2.33k in total revenue, with 2.24k units sold across all tracks and albums. The average order value (AOV) stood at $5.65, highlighting how much customers spend per purchase on average.

The store's top-selling genres accounted for over 80% of revenue, confirming the Pareto principle. Notably, Rock consistently led sales globally, and in the USA, Rock, Jazz, and Blues contributed the majority of revenue. This indicates that genre preference varies by region and offers a clear path for targeted promotions.


## Product & Genre Insights

* Top Tracks vs. Top Artists: Interestingly, the tracks that generated the highest revenue did not always belong to the highest-earning artists. This suggests that artist popularity does not always translate into maximum revenue, and promotional strategies should consider both track-level and artist-level performance.

Genre Distribution: Rock dominates revenue, followed by Latin and Metal. Conversely, Pop and some niche genres contributed minimally, suggesting untapped potential or low engagement.

* Media Type Preference: Customers overwhelmingly purchased MPEG audio files, while AAC formats saw very low sales. Digital format choice is clearly influencing revenue streams.

Recommendation: Focus marketing campaigns and inventory strategies on Rock, Latin, and Metal tracks in major markets to maximize returns.


## Geographic & Market Insights

* Revenue by Country: The USA and Canada are the largest markets, together representing the majority of revenue.

* Regional Genre Insights: In the USA, Rock, Jazz, and Blues were top-performing genres, while Pop lagged behind. This illustrates how music preference varies geographically, providing opportunities for region-specific promotions.

Recommendation: Promote high-performing genres in regions where they sell best, and explore niche genres in smaller markets to capture additional revenue.


## Customer Insights

* Repeat Purchases: All customers made more than one purchase, showing strong loyalty, but order frequency is relatively low, with the top customers placing a maximum of seven orders in four years.

Top Customers: Helena holy, Richard Cunningham, and Luis Rojas are the store’s most frequent shoppers. Encouraging these customers through loyalty programs, exclusive offers, and targeted engagement could drive further revenue.


## Sales Agent Performance

* Only three employees manage all customers, with workload and sales fairly balanced.

* Average revenue per customer varies slightly, indicating that individual agent strategies could influence sales.

Recommendation: Train sales agents to identify high-potential customers and upsell tracks or albums that align with their preferences.


## Monthly Trends & Revenue Spikes

* Revenue drops often coincided with minimal Rock sales, confirming that this genre is the primary driver of revenue.

* The number of new customers did not significantly impact spikes, highlighting the importance of retention and high-value repeat purchases.


## Summary & Recommendations

* Focus on top-performing genres (Rock, Latin, Metal) in high-revenue markets like the USA.

* Encourage repeat purchases through loyalty programs and exclusive offers.

* Monitor low-margin tracks and underperforming genres to adjust pricing or promotions.

* Leverage high-value customers during spikes to maximize revenue impact.

* Use geographic insights to optimize marketing campaigns and inventory.
