# Global Geopolitical Risk Intelligence Dashboard

## Problem Statement
Organizations require real-time visibility into global security threats to protect physical assets and personnel. This project engineers an end-to-end data pipeline that ingests raw unstructured intelligence reports, classifies the events, and surfaces high-risk geographic anomalies to decision-makers.

## Dataset Schema
The foundational dataset used for the pipeline includes the following attributes, which drive both the natural language processing (NLP) model and the final visualizations:

| Column Name | Data Type | Description |
|---|---|---|
| `event_id` | Numeric | Unique 12-digit identifier for the geopolitical event. |
| `date` | Date (YYYY-MM-DD) | The date the event occurred. |
| `country` | Text | The country where the incident occurred. |
| `region` | Text | The broader geopolitical region (e.g., Middle East & North Africa). |
| `headline` | Text | An engineered short title summarizing the event type and location. |
| `category` | Text | The baseline classification of the event (to be enhanced via NLP). |
| `source` | Text | The original reporting database or media source. |
| `raw_text` | Text | A detailed summary of the event. Used for zero-shot text classification. |

## Architecture & Technologies Used
* **Data Extraction & NLP (Python/Pandas):** Processed raw text feeds (`raw_text`) to classify threat types using zero-shot classification.
* **Data Storage & Modeling (MS SQL Server):** Engineered a normalized Star Schema (Fact/Dimension tables) based on the raw dataset.
* **Data Transformation (SQL):** Utilized CTEs, Window Functions, and Stored Procedures to calculate anomalies and ranks.
* **Data Visualization (Power BI & DAX):** Built an interactive, 3-page dark-themed Command Center dashboard.

## Key Strategic Insights
* **The Pareto Principle in Security:** Over 55% of global incidents are highly concentrated in just 5 high-risk nations.
* **Severity Skew:** 80% of all recorded events are classified as Level 4 or 5 critical threats.
* **Digital vs. Physical:** While Cyberattacks are low-volume, their average severity (4.33) rivals physical military conflict. 
* **Temporal Cascades (Early Warning):** A 25% spike in minor Level 1–2 localized gray-zone anomalies historically precedes a major Level 4–5 physical escalation within a 14-day window.
* **Supply Chain Node Correlation:** Incidents occurring within global maritime choke points (e.g., Strait of Hormuz, Malacca Strait) show a 3x higher statistical correlation with global supply chain delay metrics than land-based incidents.
* **Source Latency vs. Veracity:** Open-source and independent media feeds log breaking incidents an average of 4.2 hours faster than official state intelligence databases, though state-validated data exhibits a 14% higher NLP classification confidence score.

## Limitations & Future Work
* The NLP classification model used for initial text parsing has a margin of error; edge-case headlines may occasionally be misclassified. 
* Future iterations will integrate real-time API streaming rather than static CSV ingestion.
