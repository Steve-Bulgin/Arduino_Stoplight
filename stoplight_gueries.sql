/* Filename: stoplight_queries.sql
 * Purpose: to collect and test queries for a web app
 * Revision History
 * 		Steven Bulgin, 2015.09.11: Created
 *		Steven Bulgin, 2015.09.11: Added 3 queries
 *      Steven Bulgin, 2015.10.18: Added output query
 *      Steven Bulgin, 2015.12.22: Added a query to find the time between failures
 *					   It works, but I have reservations. 
 *      Steven Bulgin, 2015.12.26: Created query calling stored procedures to find time between failures
 */

USE stoplightdb;

-- General desplay of data. Joins on the stoplight table to get the location off the Arduino
SELECT sld.stoplight_data_id, sl.stoplight_id, location, data_date, data_time, adv_greens, emerge
FROM stoplight sl
INNER JOIN stoplight_data sld
	ON sld.stoplight_id = sl.stoplight_id
ORDER BY sld.stoplight_data_id;

-- Same as first, but outputs to txt file. adding commas between fields and spaces between lines
SELECT sld.stoplight_data_id, sl.stoplight_id, location, data_date, data_time, adv_greens, emerge
INTO OUTFILE 'C:\\Users\\Steve\\Desktop\\booger.txt'
  FIELDS TERMINATED BY ', ' OPTIONALLY ENCLOSED BY '"'
  LINES TERMINATED BY '\r\n'
FROM stoplight sl
INNER JOIN stoplight_data sld
	ON sld.stoplight_id = sl.stoplight_id
ORDER BY sld.stoplight_data_id;

-- Finds time to failure of a light
SELECT sl.stoplight_id, slda.stoplight_data_id AS 'a', sldb.stoplight_data_id AS 'b', location, TIMEDIFF(sldb.data_time, slda.data_time) AS 'Time between failures'
FROM stoplight sl 
INNER JOIN stoplight_data slda 
	ON sl.stoplight_id = slda.stoplight_id
INNER JOIN stoplight_data sldb
    ON sldb.stoplight_data_id > (slda.stoplight_data_id)
WHERE slda.functional = 'No' AND sldb.functional = 'No' AND slda.data_time < sldb.data_time
GROUP BY slda.stoplight_data_id
HAVING slda.stoplight_data_id > 8;

-- Totals all the pertanent bits of data
-- Add WHERE between datas
-- With rollup doesn't work
SELECT stoplight_id, SUM(adv_greens) AS 'ADV Green Total', SUM(emerge) AS 'Emerge Total', SUM(functional = 'No') AS 'Non Functional'
FROM stoplightdb.stoplight_data
GROUP BY stoplight_id 
HAVING stoplight_id = 1;

-- Stoplight data with rollup
SELECT IFNULL(stoplight_id, 'Total') AS 'stoplight ID', SUM(adv_greens) AS 'ADV Green Total', SUM(emerge) AS 'Emerge Total'
FROM stoplightdb.stoplight_data
GROUP BY stoplight_id WITH ROLLUP;

-- Time between failures
-- This works, but think more complex then it needs to be
-- Added query to a stored procedure `uptime` that puts the result in a temp table stoplight_failures

	SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
	FROM stoplight sl 
	INNER JOIN stoplight_data sld1
		ON sl.stoplight_id = sld1.stoplight_id
	INNER JOIN stoplight_data sld2
		ON sld2.stoplight_data_id = sld1.stoplight_data_id
	WHERE  (sld1.functional = 'Yes' AND sld1.stoplight_data_id = (SELECT MIN(stoplight_data_id) 
																  FROM stoplight_data))  AND sl.stoplight_id = 6
UNION
	SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
	FROM stoplight sl 
	INNER JOIN stoplight_data sld1
		ON sl.stoplight_id = sld1.stoplight_id
	INNER JOIN stoplight_data sld2
		ON sld2.stoplight_data_id +1 = sld1.stoplight_data_id  
	WHERE (sld1.functional = 'Yes' AND sld2.functional = 'No')  AND (sld1.stoplight_data_id <> (SELECT MAX(stoplight_data_id) 
																  							    FROM stoplight_data)) AND sl.stoplight_id = 6
	-- ORDER BY sld1.stoplight_data_id
UNION 
	SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
	FROM stoplight sl 
	INNER JOIN stoplight_data sld1
		ON sl.stoplight_id = sld1.stoplight_id
	INNER JOIN stoplight_data sld2
		ON sld2.stoplight_data_id = sld1.stoplight_data_id +1  
	WHERE (sld1.functional = 'Yes' AND sld2.functional = 'No') AND sl.stoplight_id = 6
	-- ORDER BY sld1.stoplight_data_id
UNION
	SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
	FROM stoplight sl 
	INNER JOIN stoplight_data sld1
		ON sl.stoplight_id = sld1.stoplight_id
	INNER JOIN stoplight_data sld2
		ON sld2.stoplight_data_id = sld1.stoplight_data_id
	WHERE  (sld1.functional = 'Yes' AND sld1.stoplight_data_id = (SELECT MAX(stoplight_data_id) 
																  FROM stoplight_data)) AND sl.stoplight_id = 6
ORDER BY stoplight_data_id;

-- Query finds time between failures
-- failures(NULL); returns all lights tops and bottoms
-- Calls stored procedure failures (which calls proc uptime), which sorts failures of IN param stoplight
-- inserts results into temp table uptime_tbl, which can then be joined on others

CALL failures(6);
SELECT ut.stoplight_id, sl.location, ut.startup_date, ut.startup_time, ut.down_date, ut.down_time, `Uptime (Days HH:MM:SS)`
FROM uptime_tbl ut
INNER JOIN stoplight sl
	ON(ut.stoplight_id = sl.stoplight_id);

/*
	FROM uptime_tbl ut
	LEFT JOIN stoplight sl
	Means stoplight will supply the nulls where there is data in uptime_tbl
	FROM uptime_tbl ut
	RIGHT JOIN stoplight sl
	Means uptime_tbl will supply the nulls when there is no joining data for stoplight
	ie We will get the full result for stoplight and where there is no corresponding data in 
	uptime_tbl we will get null.
 */


CALL failures(NULL);
SELECT sl.stoplight_id, sl.location, COALESCE(ut.startup_date, 'No Data') AS 'startup_date', 
	   COALESCE(ut.startup_time, 'No Data') AS 'startup_time', COALESCE(ut.down_date, 'No Data') AS 'down_date', 
	   COALESCE(ut.down_time, 'No Data') AS 'down_time', COALESCE(`Uptime (Days HH:MM:SS)`, 'No Data') AS 'Uptime (Days HH:MM:SS)'
FROM uptime_tbl ut
RIGHT JOIN stoplight sl
	ON(ut.stoplight_id = sl.stoplight_id)
ORDER BY sl.stoplight_id; # Line end commenting


--FULL OUTER JOIN TEST
--

-- Case Statement and Flow control

SELECT stoplight_data_id, stoplight_id, CASE functional WHEN 'Yes' THEN 'This is a Yes'
														WHEN 'No'  THEN 'This is a No'
														ELSE 'Neither' END AS 'functional'
FROM stoplight_data
WHERE stoplight_data_id <= 50
ORDER BY stoplight_data_id 
ASC;


-- Same as above, but gets the bottom 50 records of the table

SELECT stoplight_data_id, stoplight_id, CASE functional WHEN 'Yes' THEN 'This is a Yes'
														WHEN 'No'  THEN 'This is a No'
														ELSE 'Neither' END AS 'functional' 
FROM (
    SELECT stoplight_data_id, stoplight_id, functional 
    FROM stoplight_data 
    ORDER BY stoplight_data_id 
    DESC LIMIT 50
) sub  # All derived tables must have a name 
ORDER BY stoplight_data_id ASC;