# Federal Spend Intelligence

> **$95B in federal contracts. 23% awarded without competition. 
> 3 companies captured 41% of non-competed spending.**

An end-to-end data analytics project analyzing 774,934 US federal 
contract records from USAspending.gov — covering data extraction, 
ETL pipeline, MySQL warehouse design, and a 5-page Power BI dashboard 
uncovering spending patterns, vendor concentration, and industry dynamics.

**[View Live Dashboard →]( https://app.powerbi.com/view?r=eyJrIjoiYTg5MjFmZjgtODEwYi00MzA3LTg4YjQtOTYwMDk1OGQzOTNiIiwidCI6IjAzNWRkZWY2LTI0MzMtNDhiNi04NTI2LTcwY2E4MTgxZjc2ZCIsImMiOjN9
)**


------
## 📊 Dashboard Preview

### Page 1: Executive Summary
![Executive Summary](screenshots/page1_executive_summary.jpg)

### Page 2: Competition & Transparency
![Competition](screenshots/page2_competition_transparency.jpg)

### Page 3: Vendor Concentration & Power
![Vendor Concentration](screenshots/page3_vendor_concentration.jpg)

### Page 4: Geography Analysis
![Geography](screenshots/page4_geography_analysis.jpg)

### Page 5: Industry Analysis
![Industry](screenshots/page5_industry_analysis.jpg)

---

## 🔍 Key Findings

| Finding | Detail |
|---|---|
| **$22.19B bypassed competition** | 23% of all federal obligations awarded without competitive bidding |
| **3 companies, 41% of non-competed spend** | Lockheed ($5.04B), Boeing ($2.33B), Raytheon ($1.68B) |
| **3 states = 54% of spending** | Texas, Virginia, California dominate federal contract geography |
| **DHS drove $20.86B into 2 states** | 71.3% of DHS budget went to Texas + California alone |
| **McKesson controls 96.7% of federal pharma** | Competition doesn't guarantee market diversity |
| **Guided Missiles: 99.5% not competed** | Defense manufacturing is a closed market by design |

---

## 🏗️ Architecture

USAspending.gov Bulk Data (6GB raw)
↓
Python — chunked ingestion, 32 of 297 columns selected
↓
Pandas — cleaning, deduplication, date parsing
↓
MySQL — 4-table normalized schema
↓
Power BI — DAX measures, 5-page dashboard

---

## 🗄️ Database Schema

4 normalized tables with foreign key relationships:

- **contracts** — 774,934 rows, core fact table
- **agencies** — 124 unique agency/sub-agency combinations
- **recipients** — 19,900 unique vendors
- **locations** — 10,000+ unique performance locations

![Schema](screenshots/schema_diagram.png)

---

## 📁 Repository Structure
