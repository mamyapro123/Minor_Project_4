# Minor_Project_4

# 🚨 RedFlag — Financial Fraud Detection with SQL

> **The Unlox Academy · DA / DS Track · Week 3 Minor Project**

A comprehensive SQL-based fraud detection analysis on **200,000 synthetic financial transactions** from a fictional Indian FinTech platform called **PayFast**. The project covers everything from basic data exploration to advanced red-flag scoring using window functions, CTEs, and statistical methods.

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [File Structure](#file-structure)
- [Analysis Sections](#analysis-sections)
- [Red Flag Detection Rules](#red-flag-detection-rules)
- [Risk Scoring Model](#risk-scoring-model)
- [How to Run](#how-to-run)
- [Key Insights](#key-insights)
- [Tech Stack](#tech-stack)
- [Author](#author)

---

## 📌 Project Overview

**RedFlag** is a SQL-driven fraud detection case study designed to simulate real-world financial monitoring. Using structured queries across 30 analytical questions (plus a bonus executive dashboard), it identifies suspicious user behaviour patterns such as high-velocity transactions, multi-city activity, abnormal amounts, and late-night activity.

---

## 🗃️ Dataset

| Property        | Details                              |
|----------------|--------------------------------------|
| **Source**      | Synthetic / Fictional (PayFast FinTech) |
| **Records**     | 200,000 transactions                 |
| **Period**      | 01 Jan 2024 — 30 Jun 2024            |
| **Geography**   | 20 Indian Cities                     |
| **Database**    | `redflag`                            |
| **Table**       | `transactions`                       |

### Key Columns

| Column         | Description                               |
|---------------|-------------------------------------------|
| `txn_id`       | Unique transaction identifier             |
| `user_id`      | User performing the transaction           |
| `merchant_id`  | Merchant receiving the payment            |
| `amount`       | Transaction amount (INR)                  |
| `txn_time`     | Timestamp of transaction                  |
| `status`       | `SUCCESS` / `FAILED`                      |
| `payment_mode` | UPI, Card, Net Banking, Wallet, etc.      |
| `txn_type`     | PURCHASE, REFUND, TRANSFER, etc.          |
| `city`         | City where transaction occurred           |

---

## 📁 File Structure

```
minor project 4/
│
├── redflag_analysis.sql       # Main analysis script (630 lines, 30 questions + bonus)
├── redflag_transactions.sql   # Dataset — bulk INSERT statements for the transactions table
├── RedFlag_Project_Brief.pdf  # Original project brief and requirements
└── README.md                  # This file
```

---

## 📊 Analysis Sections

### Section 0 · Database Setup & Verification
- Validates total rows, unique users, merchants, and cities
- Checks dataset date range and coverage period

### Section 1 · Basic Exploration `(Q1–Q5)`
| # | Query |
|---|-------|
| Q1 | Preview first 10 transactions |
| Q2 | Transaction count & percentage by status |
| Q3 | Transaction count & average amount by payment mode |
| Q4 | Transaction count & total volume by transaction type |
| Q5 | Overall amount statistics (min, max, avg, sum) |

### Section 2 · Aggregations & Grouping `(Q6–Q10)`
| # | Query |
|---|-------|
| Q6  | Total transaction volume by city |
| Q7  | Monthly transaction trends (with failed count) |
| Q8  | Hourly transaction patterns |
| Q9  | Top 10 merchants by transaction volume |
| Q10 | Top 10 high-value users by total spending |

### Section 3 · Filtering & Conditions `(Q11–Q15)`
| # | Query |
|---|-------|
| Q11 | Large transactions above ₹30,000 |
| Q12 | Failed transactions analysis by city (with failure rate %) |
| Q13 | Late-night transactions (midnight to 4 AM) |
| Q14 | Users with both SUCCESS and FAILED transactions |
| Q15 | Refund analysis by city |

### Section 4 · Window Functions `(Q16–Q20)`
| # | Query |
|---|-------|
| Q16 | Rank users by total spending (`DENSE_RANK`) |
| Q17 | Running cumulative transaction volume by date |
| Q18 | Top 3 merchants within each city (`RANK + PARTITION BY`) |
| Q19 | Time gap between consecutive transactions per user (`LAG`) |
| Q20 | Transaction amount bucketing (Low / Medium / High / Very High) |

### Section 5 · Fraud / Red-Flag Detection `(Q21–Q25)`
> See [Red Flag Detection Rules](#red-flag-detection-rules) below.

### Section 6 · Advanced Analysis `(Q26–Q30)`
| # | Query |
|---|-------|
| Q26 | Dominant payment mode by city |
| Q27 | Week-over-Week (WoW) growth in transaction volume |
| Q28 | Users with high failed transaction ratio (> 30%) |
| Q29 | Top 5 merchants by highest average transaction value |
| Q30 | Comprehensive Red-Flag Risk Score Card |

### Bonus · Executive Summary Dashboard
Single-query snapshot of all key KPIs:
- Total transactions, unique users & merchants
- Total volume (INR), average transaction amount
- Failed transactions, refunds issued
- Large transactions (> ₹30K) and late-night transactions

---

## 🚩 Red Flag Detection Rules

Five fraud indicators are identified, each with a defined trigger condition:

| Flag | Rule | Trigger |
|------|------|---------|
| **RF1 — Velocity Check** | Too many transactions in a single hour | > 10 txns per user per hour |
| **RF2 — Multi-City Activity** | Transactions across multiple cities in one day | > 2 cities in 24 hours |
| **RF3 — Rapid Repeat Transactions** | Same user → same merchant in very short time | < 120 seconds between txns |
| **RF4 — Failed-to-Success Retry** | Rapid retry after a failed transaction | FAILED → SUCCESS within 300 sec |
| **RF5 — Statistical Outlier Amounts** | Unusually large amount vs user's own history | Z-Score > 3 (requires ≥ 5 past txns) |

---

## 🎯 Risk Scoring Model

The composite risk score card (Q30) aggregates all five flags into a per-user risk level:

| Flag Triggered | Score Awarded |
|----------------|---------------|
| High Velocity (> 10 txns/hr) | +3 |
| Multi-City (> 2 cities/day) | +2 |
| High Failure Rate (> 30%) | +2 |
| Large Transaction (> ₹30K) | +1 |
| Late-Night Activity (00–03h) | +1 |

| Total Risk Score | Risk Level |
|-----------------|------------|
| ≥ 6 | 🔴 **CRITICAL** |
| ≥ 4 | 🟠 **HIGH** |
| ≥ 2 | 🟡 **MEDIUM** |
| < 2 | 🟢 **LOW** |

---

## ▶️ How to Run

### Prerequisites
- MySQL 8.0+ (or any MySQL-compatible RDBMS)
- A MySQL client (MySQL Workbench, DBeaver, CLI, etc.)

### Steps

```sql
-- Step 1: Create the database
CREATE DATABASE redflag;
USE redflag;

-- Step 2: Load the dataset
-- Run redflag_transactions.sql to create and populate the transactions table

-- Step 3: Run the analysis
-- Execute redflag_analysis.sql section by section, or run the full script
```

> **Note:** `redflag_transactions.sql` is ~19 MB and contains the full dataset INSERT statements. Loading it may take a few minutes depending on your system.

---

## 💡 Key Insights

- **30 analytical SQL queries** progressing from basic SELECTs to advanced CTEs and window functions
- **5 distinct fraud detection patterns** modelled with real-world logic
- **Z-Score outlier detection** identifies statistically anomalous transaction amounts per user
- **Composite risk scoring** enables risk triage and prioritisation of suspicious accounts
- **Executive dashboard** provides a single-query KPI summary for stakeholder reporting

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **MySQL 8.0+** | Primary database engine |
| **SQL (DDL + DML)** | Data definition and analytical queries |
| **Window Functions** | `RANK`, `DENSE_RANK`, `LAG`, `LEAD`, `SUM OVER` |
| **CTEs** | Modular fraud flag logic (`WITH ... AS`) |
| **Aggregate Functions** | `COUNT`, `SUM`, `AVG`, `STDDEV`, `MIN`, `MAX` |

---

## 👤 Author

**Manya**  
The Unlox Academy · DA / DS Track · Week 3 Minor Project

---

*Dataset is entirely synthetic and fictional. All user IDs, merchant IDs, and transaction data are randomly generated for educational purposes only.*
