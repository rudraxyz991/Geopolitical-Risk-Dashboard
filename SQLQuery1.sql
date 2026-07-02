CREATE DATABASE SecurityIncidentsDB;
GO

USE SecurityIncidentsDB;
GO
CREATE TABLE dim_countries (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    country_name VARCHAR(150) NOT NULL UNIQUE,
    region_name VARCHAR(150) NOT NULL
);

CREATE TABLE dim_categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE fact_events (
    event_id VARCHAR(50) PRIMARY KEY,
    event_date DATE NOT NULL,
    country_id INT NOT NULL,
    category_id INT NOT NULL,
    headline VARCHAR(500) NOT NULL,
    severity_score INT NOT NULL CHECK (severity_score BETWEEN 1 AND 5),
    source_name VARCHAR(255) NULL,
    raw_text NVARCHAR(MAX) NULL,
    
    -- Enforce Relational Integrity via Constraints
    CONSTRAINT FK_fact_events_country FOREIGN KEY (country_id) REFERENCES dim_countries(country_id),
    CONSTRAINT FK_fact_events_category FOREIGN KEY (category_id) REFERENCES dim_categories(category_id)
);
GO
-- View the first 15 rows of the Geography Dimension
SELECT TOP 15 * FROM dim_countries;

SELECT * FROM dim_categories;

SELECT TOP 10 * FROM fact_events;

--Verify the exact number of records successfully loaded
SELECT COUNT(*) AS total_fact_records 
FROM fact_events;

SELECT 
    SUM(CASE WHEN country_id IS NULL THEN 1 ELSE 0 END) AS null_countries,
    SUM(CASE WHEN category_id IS NULL THEN 1 ELSE 0 END) AS null_categories,
    SUM(CASE WHEN event_date IS NULL THEN 1 ELSE 0 END) AS null_dates
FROM fact_events;


-- Reconstruct the schema to show the volume and severity per category
SELECT 
    c.category_name, 
    COUNT(f.event_id) AS total_incidents,
    ROUND(AVG(CAST(f.severity_score AS FLOAT)), 2) AS average_severity
FROM fact_events f
INNER JOIN dim_categories c ON f.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_incidents DESC;