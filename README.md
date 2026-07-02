# Global Geopolitical Risk Intelligence Dashboard

##  Problem Statement
Organizations require real-time visibility into global security threats to protect physical assets and personnel. This project engineers an end-to-end data pipeline that ingests raw unstructured intelligence reports, classifies the events, and surfaces high-risk geographic anomalies to decision-makers.

##  Architecture & Technologies Used
* **Data Extraction & NLP (Python/Pandas):** Processed raw text feeds to classify threat types.
* **Data Storage & Modeling (MS SQL Server):** Engineered a normalized Star Schema (Fact/Dimension tables).
* **Data Transformation (SQL):** Utilized CTEs, Window Functions, and Stored Procedures to calculate anomalies and ranks.
* **Data Visualization (Power BI & DAX):** Built an interactive, 3-page dark-themed Command Center dashboard.

##  Key Strategic Insights
* **The Pareto Principle in Security:** Over 55% of global incidents are highly concentrated in just 5 high-risk nations.
* **Severity Skew:** 80% of all recorded events are classified as Level 4 or 5 critical threats.
* **Digital vs. Physical:** While Cyberattacks are low-volume, their average severity (4.33) rivals physical military conflict. 

##  Limitations & Future Work
* The NLP classification model used for initial text parsing has a margin of error; edge-case headlines may occasionally be misclassified. 
* Future iterations will integrate real-time API streaming rather than static CSV ingestion.
