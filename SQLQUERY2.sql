USE SecurityIncidentsDB;
CREATE OR ALTER VIEW vw_Monthly_Trends AS
SELECT 
    YEAR(f.event_date) AS Event_Year,
    MONTH(f.event_date) AS Event_Month,
    c.category_name,
    COUNT(f.event_id) AS Total_Events
FROM fact_events f
INNER JOIN dim_categories c ON f.category_id = c.category_id
GROUP BY 
    YEAR(f.event_date), 
    MONTH(f.event_date), 
    c.category_name;
GO

SELECT TOP 10 * FROM vw_Monthly_Trends;




CREATE OR ALTER VIEW vw_Top_5_Countries AS
SELECT TOP 5 
    c.country_name,
    COUNT(f.event_id) AS Total_Events,
    AVG(f.severity_score) AS Average_Severity
FROM fact_events f
INNER JOIN dim_countries c ON f.country_id = c.country_id
GROUP BY 
    c.country_name
ORDER BY 
    Total_Events DESC;
GO

SELECT * FROM vw_Top_5_Countries;


CREATE OR ALTER VIEW vw_Worst_Event_Per_Country AS
WITH RankedEvents AS (
    SELECT 
        c.country_name,
        f.event_date,
        f.headline,
        f.severity_score,
        ROW_NUMBER() OVER (PARTITION BY c.country_name ORDER BY f.severity_score DESC) as Rank_Number
    FROM fact_events f
    INNER JOIN dim_countries c ON f.country_id = c.country_id
)
SELECT 
    country_name, 
    event_date, 
    headline, 
    severity_score
FROM RankedEvents
WHERE Rank_Number = 1;
GO
SELECT TOP 10 * FROM vw_Worst_Event_Per_Country;



CREATE OR ALTER PROCEDURE sp_GetCriticalEvents
    @MinSeverity INT 
AS
BEGIN
    SELECT 
        event_date, 
        headline, 
        severity_score
    FROM fact_events
    WHERE severity_score >= @MinSeverity
    ORDER BY event_date DESC;
END;
GO

EXEC sp_GetCriticalEvents @MinSeverity = 5;