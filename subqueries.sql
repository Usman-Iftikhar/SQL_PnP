
-- SUBQUERIES - build query from another query
-- Answer more complex questions than a single database table
-- Inner query is the sub query
-- Inner query must run first



-- The average number of events for each day for each channel.

-- The first table will provide the number of events for each day and channel
-- Then average these values.

SELECT channel, AVG(events) AS avg_events
FROM 
	(SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(*) AS events
	FROM web_events
	GROUP BY day, channel) sub
GROUP BY channel
ORDER BY avg_events;