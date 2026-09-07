## Files

| File                |  Rows | Purpose                                   |
| ------------------- | ----: | ----------------------------------------- |
| `customers.csv`     |   300 | Customer master data                      |
| `products.csv`      |    50 | Product master data                       |
| `orders.csv`        | 1,000 | Order header / transactions               |
| `order_items.csv`   | 2,000 | Products purchased in each order          |
| `sales_cleaned.csv` | 1,625 | Already joined/cleaned analytical dataset |

Your data naturally forms this model:

```text
                    customers.csv
                         │
                         │ customer_id
                         ▼
                    orders.csv
                         │
                         │ order_id
                         ▼
                 order_items.csv
                         │
                         │ product_id
                         ▼
                   products.csv
```

And `sales_cleaned.csv` is essentially your **analysis-ready flattened table**.

So I would build the project around the **relational structure**, rather than treating `sales_cleaned.csv` as your only dataset.

---

# 🛒 Your 7-Day Roadmap

## Project title

**E-Commerce Customer, Sales & Product Analytics**

### Main business question

> **How can an e-commerce company improve revenue and customer retention by understanding its customers, products, and purchasing behavior?**

We'll answer that using your actual files.

---

# Day 1 — Understand & Validate the Data

### Goal

Understand how the five files relate to each other and make sure the data is reliable.

Start with:

```text
customers.csv
products.csv
orders.csv
order_items.csv
sales_cleaned.csv
```

### 1. Profile each dataset

For each file investigate:

* Number of rows
* Number of columns
* Missing values
* Duplicate records
* Unique IDs
* Data types
* Date ranges
* Categories
* Status values

For example:

```python
customers["customer_id"].nunique()
products["product_id"].nunique()
orders["order_id"].nunique()
```

Your current numbers give us:

```text
Customers       300
Products         50
Orders        1,000
Order Items   2,000
```

That's a nice-sized dataset for a portfolio project.

---

## 2. Validate relationships

Check:

```text
orders.customer_id
        ↓
customers.customer_id
```

and:

```text
order_items.order_id
        ↓
orders.order_id
```

and:

```text
order_items.product_id
        ↓
products.product_id
```

You want to identify things such as:

> Are there orders belonging to customers who don't exist?
> Yes

> Are there order items referring to nonexistent products?
> No

> Are there duplicate order IDs?
> Yes

> Does every order contain at least one item?
> Yes

---

## 3. Investigate order status

Your `orders.csv` has:

```text
order_id
customer_id
order_date
status
```

Find all statuses:

```python
orders["status"].value_counts()
```

This is important because **you shouldn't automatically include every order in revenue calculations**.

For example, if you have:

```text
Completed
Cancelled
Pending
Returned
```

you'll need to establish your business rules.

### End of Day 1

You should have a document containing:

```text
Data Dictionary
Relationship Diagram
Data Quality Findings
Business Rules
```


## Day 1 Findings 
### Data Dictionary
All the Data has been converted into Datatypes and inserted into python
### Relationship Diagram
#### ./Results/ER_Diagram.png
### Data Quality Findings
1. There are 15 Customers without Orders.
2. There are 285 Customers with Orders.
3. Every Order item has orders.
4. Every Order item has a Product behind it.
5. There are duplicated order ids in Order items table.
6. There are no Null values in any tables.

### Business Rules
1. Only Orders with Completed status are to be completed.
2. Revenue is calculated as 5% of the sale price.
3. Average order value is calculated as AOV = Total Revenue / Number of Completed Orders

---

# Day 2 — Build the Data Model

### Goal

Create a proper analytical database in PostgreSQL.

This is where I recommend **not relying solely on `sales_cleaned.csv`**.

Use your original normalized files.

---

## PostgreSQL database

Create:

```text
ecommerce_analytics
```

Tables:

```text
customers
products
orders
order_items
```

And optionally:

```text
sales_cleaned
```

as an analytical/staging table.

---

# Your database architecture

I'd structure it like:

```text
                    ┌──────────────┐
                    │  customers   │
                    │──────────────│
                    │ customer_id  │
                    │ country      │
                    │ signup_date  │
                    └──────┬───────┘
                           │
                           │
                    ┌──────▼───────┐
                    │    orders    │
                    │──────────────│
                    │ order_id     │
                    │ customer_id  │
                    │ order_date   │
                    │ status       │
                    └──────┬───────┘
                           │
                           │
                  ┌────────▼────────┐
                  │   order_items   │
                  │─────────────────│
                  │ order_id        │
                  │ product_id      │
                  │ quantity        │
                  │ price           │
                  └────────┬────────┘
                           │
                           │
                    ┌──────▼───────┐
                    │   products   │
                    │──────────────│
                    │ product_id   │
                    │ product_name │
                    │ category     │
                    └──────────────┘
```

This is much better for your portfolio than simply loading one CSV into PostgreSQL.

---

# Day 3 — Sales Analysis with SQL

### Goal

Answer the core business questions.

Create:

```text
sql/
├── 01_data_quality.sql
├── 02_sales_analysis.sql
├── 03_product_analysis.sql
├── 04_customer_analysis.sql
└── 05_rfm_analysis.sql
```

---

## KPI #1 — Total Revenue

Your revenue can be calculated:

```text
quantity × price
```

You already have this in `sales_cleaned.csv` as:

```text
Revenue
```

But demonstrate that you can calculate it yourself from the relational tables.

---

## KPI #2 — Total Orders

```sql
COUNT(DISTINCT order_id)
```

---

## KPI #3 — Total Customers

```sql
COUNT(DISTINCT customer_id)
```

---

## KPI #4 — Units Sold

```sql
SUM(quantity)
```

---

## KPI #5 — Average Order Value

```text
Total Revenue / Total Orders
```

---

## KPI #6 — Revenue by Month

Your dataset already has:

```text
year
month
```

but I'd calculate the date dimension properly in SQL.

You'll eventually produce:

```text
Month       Revenue
2024-01     XXXX
2024-02     XXXX
2024-03     XXXX
...
```

---

# Day 4 — Product Analysis

### Goal

Determine which products and categories drive the business.

You have:

```text
product_id
product_name
category
```

and:

```text
quantity
price
Revenue
```

So we can answer:

### Top products by revenue

```text
Product 42       $XX,XXX
Product 17       $XX,XXX
Product 8        $XX,XXX
...
```

### Top products by quantity

This is important because **highest-selling doesn't necessarily mean highest-revenue**.

For example:

```text
Product A
10,000 units
$20,000 revenue

Product B
1,000 units
$80,000 revenue
```

---

## Category analysis

Your categories include things such as:

```text
Body
Skin
...
```

Calculate:

* Revenue by category
* Units by category
* Orders by category
* Average price
* Revenue percentage
* Category growth

---

## Product profitability proxy

You don't appear to have a **cost** field.

Therefore, don't call this "profit".

Instead use:

> **Revenue performance**

You can calculate:

```text
Revenue
Average Selling Price
Units Sold
Revenue per Order
```

This is an important distinction for your portfolio.

---

# Day 5 — Customer Analytics + RFM

### 🎯 This is the most important day.

Your `customers.csv` gives you:

```text
customer_id
country
signup_date
```

and orders tell you what they bought.

Combine these to build a customer-level analytical table.

---

# Customer KPIs

Calculate:

### Customer Revenue

```text
SUM(order revenue)
```

### Number of Orders

```text
COUNT(DISTINCT order_id)
```

### Average Order Value

```text
Revenue / Orders
```

### Last Purchase Date

```text
MAX(order_date)
```

### First Purchase Date

```text
MIN(order_date)
```

### Customer Lifetime

```text
Last Purchase - First Purchase
```

---

# RFM Analysis

Now calculate:

### Recency

Days since last purchase.

### Frequency

Number of orders.

### Monetary

Total revenue.

You'll end up with:

```text
customer_id | recency | frequency | monetary
```

For example:

```text
101 | 12 | 15 | 8,420
205 | 97 |  3 | 1,250
156 | 23 |  8 | 3,900
```

---

# Create segments

Turn RFM into:

```text
🏆 Champions

💎 Loyal Customers

🌱 Potential Loyalists

🆕 New Customers

⚠️ At Risk

🚨 Can't Lose Them

💤 Lost Customers
```

This will become one of the most impressive parts of your Power BI dashboard.

---

# Day 6 — Power BI Dashboard

Now connect Power BI to your PostgreSQL database.

Don't just import `sales_cleaned.csv`.

Build your model around the relational structure.

I'd create:

```text
                 DimCustomer
                      │
                      │
DimProduct ──── FactSales ──── DimDate
                      │
                      │
                  DimOrder
```

---

# Dashboard Page 1

## 📊 Executive Overview

KPIs:

```text
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ Total Revenue│ Total Orders │  Customers   │     AOV      │
│              │              │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

Charts:

* Revenue over time
* Orders over time
* Revenue by country
* Revenue by category
* Top 10 products

Slicers:

```text
Date
Country
Category
Product
Order Status
```

---

# Dashboard Page 2

## 📦 Product Performance

Visuals:

### Revenue by Category

### Top 10 Products

### Bottom 10 Products

### Quantity Sold

### Average Selling Price

### Monthly Product Performance

I'd also include a table:

```text
Product | Category | Units | Revenue | % of Revenue
```

---

# Dashboard Page 3

## 👥 Customer Analytics

This should be your showcase page.

KPIs:

```text
Total Customers
Active Customers
Repeat Customers
Repeat Purchase Rate
Average Customer Revenue
```

Charts:

### Customer Revenue Distribution

### Customers by Country

### RFM Segments

```text
Champions
Loyal
Potential Loyalists
At Risk
Lost
```

### Top Customers

```text
Customer | Country | Orders | Revenue | Segment
```

---

# Day 7 — Business Story + GitHub

This is where you turn the technical work into a **portfolio project**.

Don't just say:

> "I created a Power BI dashboard."

Instead answer:

### What did the business learn?

For example, your final report could contain:

## Finding 1 — Revenue concentration

> X% of revenue is generated by X% of customers.

## Finding 2 — Product concentration

> Category X accounts for X% of total revenue.

## Finding 3 — Customer retention

> X% of customers made more than one purchase.

## Finding 4 — At-risk customers

> X high-value customers have not purchased recently.

## Finding 5 — Geographic performance

> Country X generates the highest revenue while Country Y has the highest average order value.

**These numbers must come from your analysis. Don't invent them.**

---

# Your final recommendations

Based on the actual findings, recommend things such as:

### 🏆 Champions

Reward them with:

* Loyalty benefits
* Early access
* Exclusive products

### ⚠️ At Risk

Target them with:

* Personalized offers
* Email campaigns
* Product recommendations

### 💤 Lost

Test:

* Win-back campaigns
* Discounts
* New-product promotions

### 📦 Products

Use your sales data to determine:

* Products worth promoting
* Products requiring investigation
* High-volume products
* High-value products



# Your final project should demonstrate

| Skill             | Where you'll demonstrate it |
| ----------------- | --------------------------- |
| Python            | Cleaning + validation + RFM |
| Pandas            | Data transformation         |
| PostgreSQL        | Database + SQL              |
| SQL               | Business analysis           |
| Data modeling     | Relational/star schema      |
| Power BI          | Dashboard                   |
| DAX               | KPIs                        |
| RFM               | Customer segmentation       |
| Business analysis | Insights                    |
| Git/GitHub        | Portfolio                   |

---

# 🗓️ Final 7-Day Schedule

| Day   | Main Work        | Target                                     |
| ----- | ---------------- | ------------------------------------------ |
| **1** | Data exploration | Understand all 5 files                     |
| **2** | PostgreSQL       | Build database + relationships             |
| **3** | SQL              | Sales & KPI analysis                       |
| **4** | SQL + Python     | Product analysis                           |
| **5** | Python + SQL     | Customer + RFM analysis                    |
| **6** | Power BI         | 3-page dashboard                           |
| **7** | GitHub           | Insights + recommendations + documentation |

### Estimated effort

**Day 1:** 3–4 hours
**Day 2:** 4–5 hours
**Day 3:** 4–5 hours
**Day 4:** 3–4 hours
**Day 5:** 4–5 hours
**Day 6:** 5–7 hours
**Day 7:** 3–4 hours

**Total: ~26–34 hours**

---

## One particularly useful thing about your files

You already have `sales_cleaned.csv`, which contains:

```text
order_id
product_id
quantity
price
Revenue
customer_id
order_date
status
year
month
```

So **don't throw it away**.

Use it as your **validation/analytical layer**.

For example:

```text
Raw relational data
       ↓
PostgreSQL joins
       ↓
Your calculated Revenue
       ↓
Compare against sales_cleaned.csv
       ↓
Validate your pipeline
```

That gives you an additional portfolio story:

> **"I validated my transformed analytical dataset against a pre-cleaned reference dataset."**

That's a much better demonstration of data engineering/data analyst thinking than simply loading the cleaned CSV into Power BI.
