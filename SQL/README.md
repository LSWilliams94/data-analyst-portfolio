# Sales Data Analysis with SQL

## Overview

This project showcases my SQL skills through comprehensive data analysis of a sales dataset. The analysis includes revenue trends, customer behavior, product performance, and store insights. The data has been cleaned, normalised, and optimised for querying in SQL Server 2022 Developer Edition.

## Dataset

The dataset includes the following tables:
- Product: Details of products sold
- Customer: Information about customers
- Customer Geolocation: Information about customers location e.g. state, city, zip code
- Store: Store details
- Orders: Orders placed
- Order Line Items: Detailed breakdown of items within each order
- Category & Subcategory: Product classification

## Data Preparation

### Challenges Encountered

Unicode and Conversion Issues: While importing the CSV using the "Import Data" feature, I faced unicode and data conversion errors.
Solution: I created a staging table with all fields as VARCHAR(255) to handle the initial data load. Afterward, I converted data types appropriately before loading it into the target tables and proceeded with normalisation.

## Key SQL Queries

- Revenue per store, per square meter
- Seasonality of sales
- Customer segmentation by age groups
- Product performance and sales trends
- New vs. returning customer analysis
- Store performance metrics

## Key Findings

### Customer Insights:
- Demographics: Average customer age is 56 (range: 23–90) with an even gender split (50:50).
- Geography: Most customers are from the USA, primarily California, Texas, and New York.
#### Behavior: 
- 11,887 unique customers identified.
- 83% of sales come from repeat customers, with an average of 2 orders per customer.
- The average gap between a customer’s first and last purchase is 425 days.
- Retention rates fluctuate from 20% (2016) to 4% (2020), showing room for growth.
#### Spending Patterns:
- 65+ age group contributes the highest revenue however this is because they have the most unique customers. Looking at revenue per age group, each age group is roughly the same revenue.
- Male and female customers spend equally on average.
### Product Insights:
#### Product Mix: 
- 8 product categories, with computers driving 34% of total sales, followed by home appliances (19%).
#### Top Products: 
- Best sellers include WW1 Desktop PC2.33 (Black) with revenue of $505,450.
#### Key revenue-driving colors:
- Black, White, and Silver.
#### Cross-Selling: 
- Frequent bundles: Contoso DVD 7-Inch with SV Hand Games, and Contoso DVD Storage Binder with Touch Stylus Pen.
#### Performance Metrics: 
- Average Order Value: $888.64
- Annual Revenue: ~$9.29M, with an average of 32,959 units sold annually.
- Most Sold Product: Computers with 44,151 units sold.
### Store Performance Insights:
#### Growth: 
- Revenue grew 72% from 2017 to 2018.
#### Seasonality: 
- Strongest sales in winter, followed by autumn.
#### Top Channels: 
- Online is the leading sales channel with 4,547 unique customers.
- Physical stores like Store 55, Store 50, and Store 54 also perform well.
#### Logistics: 
- Average delivery time: 4 days (consistent across countries).
-Sales Trends: First 30 days of store openings show interesting patterns worth deeper analysis to compare launch sales vs. long-term trends.
