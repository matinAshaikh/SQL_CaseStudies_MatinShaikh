SELECT traffic_source, 
    COUNT(CASE WHEN time_spent > 30 THEN 1 END) AS engaged_visitors,
    COUNT(*) AS total_visitors,
    COUNT(CASE WHEN time_spent > 30 THEN 1 END)::float / COUNT(*) AS engagement_ratio
FROM page_views
GROUP BY traffic_source;

WITH user_journey AS (
    SELECT user_id, STRING_AGG(page_url, ' -> ') AS journey
    FROM page_views
    GROUP BY user_id
)
SELECT user_id, journey
FROM user_journey
LIMIT 10;
