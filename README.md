
# Fuzzy Factory | E-commerce Data Analysis

## 1. Project Overview

This project analyzes the business performance of Fuzzy Factory, an e-commerce company, using SQL Server and Power BI.

The objective is to transform raw transactional and website data into actionable business insights, focusing on revenue growth, marketing performance, product profitability, and customer conversion.

- **Industry:** E-commerce
- **Data period:** March 2012 – March 2015
- **Tools:** SQL Server, SSMS, Power BI, Power Query, DAX
- **Project type:** End-to-end Data Analytics Portfolio Project

## 2. Business Objectives

- Evaluate business growth and key performance indicators.
- Identify major revenue-generating marketing sources and campaigns.
- Analyze product sales and profitability.
- Identify potential bottlenecks in the customer conversion funnel.
- Provide data-driven business recommendations.

## 3. Dataset

The dataset consists of six relational tables:

| Table | Description |
|---|---|
| website_sessions | Website session information |
| website_pageviews | Website pageview records |
| orders | Customer order information |
| order_items | Order-level product details |
| order_item_refunds | Product refund records |
| products | Product information |

The original dataset is not included because its redistribution permissions have not been verified.

## 4. Project Workflow

1. Business Understanding
2. Data Exploration and Validation
3. SQL Analysis
4. Data Transformation and Modeling
5. DAX Measures and KPI Development
6. Power BI Dashboard Development
7. Business Insights and Recommendations

## 5. Technical Skills

### SQL Server

- Joins and aggregate functions
- Common Table Expressions (CTEs)
- Window functions
- CASE WHEN statements
- Data validation
- Date and time analysis
- Month-over-month growth analysis
- Conversion funnel analysis

### Power BI

- Power Query transformations
- Data modeling and relationships
- Date dimension
- DAX measures
- KPI development
- Interactive dashboards and slicers
- Business data visualization

## 6. Dashboard Overview

### 6.1. E-commerce Growth Overview

Analyzes overall business performance through revenue, gross profit, orders, website sessions, conversion rate, and average order value.

![Growth Overview](images/01_Growth%20Overview.png)

**Key Findings — 2014**

- Total revenue reached approximately $1.08 million.
- Gross profit reached $679.72K.
- Monthly revenue increased by approximately 156% from January to December.
- Overall conversion rate reached 7.22%.

### 6.2. Marketing & Campaign Performance

Evaluates marketing sources and campaigns based on traffic, revenue, orders, and conversion rates.

![Marketing Performance](images/02_Marketing%20Performance.png)

**Key Findings — 2014**

- Gsearch was the largest revenue-generating traffic source, contributing approximately 64% of total revenue.
- Nonbrand was the leading campaign in terms of revenue contribution.
- Brand achieved a higher conversion rate than Nonbrand.
- Advertising cost data is required to evaluate marketing ROI and ROAS.

### 6.3. Product Performance

Analyzes product revenue, gross profit, sales volume, and gross margin.

![Product Performance](images/03_Product%20Performance.png)

**Key Findings — 2014**

- The Original Mr. Fuzzy was the leading product in revenue and gross profit.
- Overall gross margin reached 63.19%.
- The Birthday Sugar Panda and The Hudson River Mini Bear demonstrated relatively high gross margins, suggesting opportunities for further sales development.

### 6.4. Conversion Funnel Analysis

Examines website sessions across seven stages of the customer purchase journey.

![Conversion Funnel](images/04_Conversion%20Funnel.png)

**Key Findings — 2014**

- Overall funnel conversion rate reached 7.22%.
- Cart completion rate reached 34.55%.
- The Product Detail-to-Cart stage represented a potential conversion bottleneck, with an estimated drop-off rate of approximately 55%.

## 7. Business Recommendations

### Marketing Strategy

Maintain Nonbrand campaign performance while monitoring conversion efficiency and evaluating advertising costs before increasing investment.

### Product Strategy

Maintain The Original Mr. Fuzzy as the flagship product while exploring opportunities to increase sales of Sugar Panda and Mini Bear due to their relatively high gross margins.

### Conversion Optimization

Investigate potential friction in the Add-to-Cart experience through user research, session-level analysis, and usability testing.

## 8. Analysis Limitations

- March 2015 contains incomplete monthly data.
- Advertising cost data is unavailable, limiting ROI and ROAS analysis.
- Funnel stage ratios are based on session counts at each stage. Sequential session-level validation is required to confirm actual customer transitions and abandonment.
- Business recommendations represent potential opportunities rather than confirmed causal relationships.

## 9. Repository Structure

- `sql/` — SQL analysis scripts
- `images/` — Power BI dashboard screenshots
- `dataset/` — Dataset documentation
- `README.md` — Project documentation

## 10. Conclusion

This project demonstrates an end-to-end data analytics workflow, from SQL-based data exploration and business KPI calculation to Power BI visualization and actionable business recommendations.

The analysis highlights opportunities to sustain business growth, optimize marketing performance, improve product portfolio profitability, and enhance the customer purchase journey.
