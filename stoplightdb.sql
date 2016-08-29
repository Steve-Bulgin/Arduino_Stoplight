/* Filename: stoplightdb.sql
 * Purpose: To collect data from SBStopLight.ino (arduino project)
 * Revision History
 * 		Steven Bulgin, 2015.08.27: Created
 * 		Steven Bulgin, 2015.08.27: Completed the basic db
 * 					   ready for python insert/JSP connect
 *		Steven Bulgin, 2015.08.29: Added dumby data for testing/remembering sql
 *      Steven Bulgin, 2015.09.10: Got db and python working. Dropped db and
 *                     commented out dummy data ready for thorough testing.
 *		Steven Bulgin, 2015.10.04: Added triggers for insert and update to the stoplight_maint table
 *					   to check that comments are not null if maintenance_type not routine
 *      Steven Bulgin, 2015.10.05: Added a date calculating trigger on the stoplight_data table and date field
 *					   Delete field, trigger, and un comment dummy data in production
 *      Steven Bulgin, 2015.10.05: Added dayofweek col to maint for play. Remove later
 *      Steven Bulgin, 2015.10.05: Added holiday table for testing procedures. Delete when done
 *      Steven Bulgin, 2015.12.07: Added commenting to triggers so I remember what I've done
 *      Steven Bulgin, 2015.12.07: Added curdate to the trigger for the maint_tbl so it sets automatically on insert
 *      Steven Bulgin, 2015.12.08: Added trigger to the holidays tbl that updates the stoplight_maint.next_inpection_date
 *					   when the holidays tbl is updated
 *      Steven Bulgin, 2015.12.26: Added a Stored proc 'uptime(IN stopnum INT)' finds the tops and bottoms of failure points
 *					   and inserts them in a temp table 'stoplight_failures'
 *      Steven Bulgin, 2015.12.26: Added stored procedure 'failures(IN stop_num INT)' that calls uptime() in order to find
 * 					   the time to failure of a stoplight stores result in temp tbl uptime_tbl
 *			**** Add a NULL query to procedure that will return fails for all lights *****
 *      Steven Bulgin, 2015.12.28: Added NULL query to failures which returns a value for all lights
 *								   Found bug in uptime proc query. FIXED BUG
 */



DROP DATABASE IF EXISTS stoplightdb;
CREATE DATABASE stoplightdb;
USE stoplightdb;

-- CREATE THE TABLES FOR THE DATABASE
CREATE TABLE stoplight
 (stoplight_id INT,
 location VARCHAR(50),
 CONSTRAINT stoplight_stoplight_id_pk PRIMARY KEY(stoplight_id));

CREATE TABLE stoplight_data
 (stoplight_data_id INT AUTO_INCREMENT,
 stoplight_id INT,
 functional VARCHAR(30),
 adv_greens INT,
 emerge INT,
 data_date DATE,
 data_time TIME,
 future_date TIME, -- Remove from production
 CONSTRAINT stoplight_data_stoplight_data_id_pk PRIMARY KEY(stoplight_data_id));

CREATE TABLE Stoplight_maint
 (stoplight_maint_id INT AUTO_INCREMENT,
 stoplight_id INT,
 service_date DATE,
 team_lead_fName VARCHAR(40),
 team_lead_lName VARCHAR(40),
 t_lead_email VARCHAR(40),
 maintenance_type ENUM('routine', 'emergency', 'upgrade', 'special'),
 next_inspection_date DATE,
 day INT,
 comments LONGTEXT,
 CONSTRAINT Stoplight_maint_Stoplight_maint_id_pk PRIMARY KEY(Stoplight_maint_id));


-- Holidays table
CREATE TABLE holidays
 (holiday_id INT AUTO_INCREMENT,
 holiday_date DATE,
 CONSTRAINT holidays_holiday_id_pk PRIMARY KEY(holiday_id));

-- INSERTS FOR TESTING
-- INSERT FOR stoplight
INSERT INTO stoplight VALUES
 (1, 'Homer Watson & Sterling'),
 (2, 'Homer Watson & Ottawa'),
 (3, 'Homer Watson & Hanson'),
 (4, 'Homer Watson & Bleams'),
 (5, 'Homer Watson & Manitou'),
 (6, 'Homer Watson & Pioneer'),
 (7, 'Homer Watson & Doon South'),
 (8, 'Homer Watson & Conestoga College'),
 (9, 'Homer Watson & HWY 401(WEST BOUND INTERCHANGE)'),
 (10, 'Homer Watson & HWY 401(EAST BOUND INTERCHANGE)');


-- INSERT FOR stoplight_data
-- INSERT INTO stoplight_data (stoplight_data_id,stoplight_id,functional, adv_greens,emerge,data_date,data_time) VALUES
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:05'),
-- (NULL, 2, 'Yes', 5, 1, '2015-08-29', '13:10'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '13:15'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:20'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:25'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:30'),
-- (NULL, 2, 'Yes', 7, 2, '2015-08-29', '13:35'),
-- (NULL, 2, 'No', 4, 0, '2015-08-29', '13:40'),
-- (NULL, 2, 'Yes', 3, 0, '2015-08-29', '13:45'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '13:55'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:05'),
-- (NULL, 2, 'Yes', 5, 1, '2015-08-29', '14:10'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '14:15'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:20'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:25'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:30'),
-- (NULL, 2, 'Yes', 7, 2, '2015-08-29', '14:35'),
-- (NULL, 2, 'No', 4, 0, '2015-08-29', '14:40'),
-- (NULL, 2, 'Yes', 3, 0, '2015-08-29', '14:45'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '14:55'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:05'),
-- (NULL, 2, 'Yes', 5, 1, '2015-08-29', '13:10'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '13:15'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:20'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:25'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '13:30'),
-- (NULL, 2, 'Yes', 7, 2, '2015-08-29', '13:35'),
-- (NULL, 2, 'No', 4, 0, '2015-08-29', '13:40'),
-- (NULL, 2, 'Yes', 3, 0, '2015-08-29', '13:45'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '13:55'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:05'),
-- (NULL, 2, 'Yes', 5, 1, '2015-08-29', '14:10'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '14:15'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:20'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:25'),
-- (NULL, 2, 'Yes', 2, 0, '2015-08-29', '14:30'),
-- (NULL, 2, 'Yes', 7, 2, '2015-08-29', '14:35'),
-- (NULL, 2, 'No', 4, 0, '2015-08-29', '14:40'),
-- (NULL, 2, 'Yes', 6, 0, '2015-08-29', '11:45'),
-- (NULL, 2, 'Yes', 8, 0, '2015-08-29', '14:55');


-- INSERT FOR stoplight_maint
INSERT INTO stoplight_maint VALUES
 (NULL, 5, '2015-08-29', 'Tom', 'Jones', 'tjones@region.waterloo.on.ca', 'routine', NULL, NULL, 'Standard'),
 (NULL, 6, '2015-08-29', 'Gary', 'Pallone', 'gpallone@region.waterloo.on.ca', 'emergency', NULL, NULL,  'Vandalized. Minor damage to internals. Report filed with WRPS. WRPS occurance #15183906'),
 (NULL, 7, '2015-08-29', 'Tom', 'Jones', 'tjones@region.waterloo.on.ca', 'special', NULL, NULL, 'Closed intersection for LTC'),
 (NULL, 8, '2015-08-29', 'Tom', 'Jones', 'tjones@region.waterloo.on.ca', 'routine', NULL, NULL, 'Standard'),
 (NULL, 7, '2015-09-08', 'Tom', 'Jones', 'tjones@region.waterloo.on.ca', 'routine', NULL, NULL, 'Replaced a slightly damaged crosswalk button'),
 (NULL, 9, '2015-09-19', 'Mike', 'Boos', 'mboos@region.waterloo.on.ca', 'upgrade', NULL, NULL, 'Added countdown signs to crosswalk'),
 (NULL, 1, '2015-09-29', 'Mike', 'Boos', 'mboos@region.waterloo.on.ca', 'upgrade', NULL, NULL, 'Added audio signal to crosswalk'),
 (NULL, 2, '2015-10-02', 'Gary', 'Pallone', 'gpallone@region.waterloo.on.ca', 'routine', NULL, NULL, 'Standard'),
 (NULL, 6, '2015-07-09', 'Gary', 'Pallone', 'gpallone@region.waterloo.on.ca', 'routine', NULL, NULL, 'Standard'),
 (NULL, 3, '2015-06-20', 'Gary', 'Pallone', 'gpallone@region.waterloo.on.ca', 'routine', NULL, NULL, 'Standard');

-- Inserts for holiday
INSERT INTO holidays VALUES
 (NULL, '2015-10-12'),
 (NULL, '2015-10-13'),
 (NULL, '2015-10-14'),
 (NULL, '2016-12-25'),
 (NULL, '2016-01-01'),
 (NULL, '2016-04-05'),
 (NULL, '2016-04-06'),
 (NULL, '2016-04-15'),
 (NULL, '2016-04-25'),
 (NULL, '2016-05-05'),
 (NULL, '2016-06-01'),
 (NULL, '2016-03-31');


-- Triggers for inserts and updated to the stoplight_maint Table
DELIMITER $$

 CREATE TRIGGER mainInsertCheck BEFORE INSERT ON stoplight_maint
 FOR EACH ROW 
 BEGIN
	IF (NEW.maintenance_type NOT LIKE 'routine' AND NEW.comments IS NULL) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = '\'comments\' cannot be null when maintenance_type is not routine';
	END IF;
	-- SET NEW.service_date = CURDATE();
	SET NEW.next_inspection_date = ADDDATE(NEW.service_date, INTERVAL 7 DAY);
	SET NEW.day = DAYOFWEEK(NEW.next_inspection_date);
	WHILE (DAYOFWEEK(NEW.next_inspection_date) = 1) OR (DAYOFWEEK(NEW.next_inspection_date) = 7) OR 
		  (NEW.next_inspection_date = (SELECT holiday_date FROM holidays WHERE holiday_date = NEW.next_inspection_date)) DO
		SET NEW.next_inspection_date = ADDDATE(NEW.next_inspection_date, INTERVAL 1 DAY);
	END WHILE;
 END$$
 
 CREATE TRIGGER mainUpdateCheck BEFORE UPDATE ON stoplight_maint
 FOR EACH ROW 
 BEGIN
	IF (NEW.maintenance_type NOT LIKE 'routine' AND NEW.comments IS NULL) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = '\'comments\' cannot be null when maintenance_type is not routine';
	END IF;
	-- SET NEW.service_date = CURDATE();
	SET NEW.next_inspection_date = ADDDATE(NEW.service_date, INTERVAL 7 DAY); 
	SET NEW.day = DAYOFWEEK(NEW.next_inspection_date); 
	WHILE (DAYOFWEEK(NEW.next_inspection_date) = 1) OR (DAYOFWEEK(NEW.next_inspection_date) = 7) OR 
		  (NEW.next_inspection_date = (SELECT holiday_date FROM holidays WHERE holiday_date = NEW.next_inspection_date)) DO
		SET NEW.next_inspection_date = ADDDATE(NEW.next_inspection_date, INTERVAL 1 DAY); -- test
	END WHILE;
 END$$
 
 CREATE TRIGGER stop_date BEFORE INSERT ON stoplight_data
 FOR EACH ROW 
 BEGIN
	SET NEW.future_date = ADDDATE(NEW.data_time, INTERVAL 30 SECOND);
 END$$
 
 CREATE TRIGGER holiday_update AFTER INSERT ON holidays
 FOR EACH ROW 
 BEGIN
	WHILE (NEW.holiday_date = (SELECT next_inspection_date FROM stoplight_maint WHERE next_inspection_date = NEW.holiday_date))  DO
		UPDATE stoplight_maint
		SET next_inspection_date = ADDDATE(next_inspection_date, INTERVAL 1 DAY) -- test
		WHERE next_inspection_date = NEW.holiday_date;
	END WHILE;
 END$$

DELIMITER ;

-- Procedures

-- Create a Temporay table 'stoplight_failures'that contains the the upper 'Yes' after a 'No' 
-- and the lower 'Yes'before a 'No' to determine uptime before failues
-- takes an input INT stoplight_id

DELIMITER $$

 DROP PROCEDURE IF EXISTS uptime$$
 CREATE PROCEDURE uptime(IN stopnum INT)
 	DETERMINISTIC
 BEGIN

	DROP TABLE IF EXISTS stoplight_failures;
	CREATE TEMPORARY TABLE stoplight_failures AS 
			SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
			FROM stoplight sl 
			INNER JOIN stoplight_data sld1
				ON sl.stoplight_id = sld1.stoplight_id
			INNER JOIN stoplight_data sld2
				ON sld2.stoplight_data_id = sld1.stoplight_data_id
			WHERE  (sld1.functional = 'Yes' AND sld1.stoplight_data_id = (SELECT MIN(stoplight_data_id) 
																		  FROM stoplight_data
																		  WHERE stoplight_id = stopnum))  AND sl.stoplight_id = stopnum
		UNION
			SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
			FROM stoplight sl 
			INNER JOIN stoplight_data sld1
				ON sl.stoplight_id = sld1.stoplight_id
			INNER JOIN stoplight_data sld2
				ON sld2.stoplight_data_id +1 = sld1.stoplight_data_id  
			WHERE (sld1.functional = 'Yes' AND sld2.functional = 'No')  AND (sld1.stoplight_data_id <> (SELECT MAX(stoplight_data_id) 
																		  							    FROM stoplight_data
																		  							    WHERE stoplight_id = stopnum)) AND sl.stoplight_id = stopnum
			-- ORDER BY sld1.stoplight_data_id
		UNION 
			SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
			FROM stoplight sl 
			INNER JOIN stoplight_data sld1
				ON sl.stoplight_id = sld1.stoplight_id
			INNER JOIN stoplight_data sld2
				ON sld2.stoplight_data_id = sld1.stoplight_data_id +1  
			WHERE (sld1.functional = 'Yes' AND sld2.functional = 'No') AND sl.stoplight_id = stopnum
			-- ORDER BY sld1.stoplight_data_id
		UNION
			SELECT sld1.stoplight_data_id AS 'stoplight_data_id', sld2.stoplight_data_id AS 'b', sl.stoplight_id, sld1.data_date, sld1.data_time, sld1.functional
			FROM stoplight sl 
			INNER JOIN stoplight_data sld1
				ON sl.stoplight_id = sld1.stoplight_id
			INNER JOIN stoplight_data sld2
				ON sld2.stoplight_data_id = sld1.stoplight_data_id
			WHERE  (sld1.functional = 'Yes' AND sld1.stoplight_data_id = (SELECT MAX(stoplight_data_id) 
																		  FROM stoplight_data
																		  WHERE stoplight_id = stopnum)) AND sl.stoplight_id = stopnum
			ORDER BY stoplight_data_id;
 END$$

DELIMITER ;

--- Failures

DELIMITER $$

 DROP PROCEDURE IF EXISTS failures$$
 CREATE PROCEDURE failures(IN stop_num INT)
 DETERMINISTIC
 BEGIN
 DECLARE counter  INT;
 DECLARE max_count  INT;

 IF stop_num IS NOT NULL THEN

	CALL uptime(stop_num);
	DROP TABLE IF EXISTS temp;
	CREATE TEMPORARY TABLE temp LIKE stoplight_failures; 
	INSERT temp SELECT * FROM stoplight_failures;
		
	SET @rownum := 0;
	SET @rownum2 := 0;

	DROP TABLE IF EXISTS uptime_tbl;
	CREATE TEMPORARY TABLE uptime_tbl AS
		
		SELECT dt1.stoplight_id, dt1.stoplight_data_id AS 'start_id', dt2.stoplight_data_id AS 'end_id',
			   dt1.data_date AS 'startup_date', dt1.data_time AS 'startup_time', dt2.data_date AS 'down_date', dt2.data_time AS 'down_time',  CONCAT(
			   FLOOR(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))) / 24), ' Days ',
			   LPAD(MOD(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 24), 2, '0'), ':', 
			   LPAD(MINUTE(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0'), ':',
			   LPAD(SECOND (TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0')) 
			   AS 'Uptime (Days HH:MM:SS)'
		FROM (

				SELECT @rownum := @rownum + 1 AS 'rownum', stoplight_failures.*
				FROM stoplight_failures
			  ) dt1
		INNER JOIN (
					SELECT @rownum2 := @rownum2 + 1 AS 'rownum', temp.*
					FROM temp
					) dt2
		ON (dt2.rownum = dt1.rownum + 1)
	WHERE dt1.rownum % 2 = 1;

 ELSE
	SET @switch := 0;
	SET counter = (SELECT MIN(stoplight_id) FROM stoplight LIMIT 1);
	SET max_count = (SELECT MAX(stoplight_id) FROM stoplight LIMIT 1);
	
	WHILE counter  <= max_count DO
		IF @switch = 0 THEN
			CALL uptime(counter);
			DROP TABLE IF EXISTS temp;
			CREATE TEMPORARY TABLE temp LIKE stoplight_failures; 
			INSERT temp SELECT * FROM stoplight_failures;
				
			SET @rownum := 0;
			SET @rownum2 := 0;

			DROP TABLE IF EXISTS uptime_tbl;
			CREATE TEMPORARY TABLE uptime_tbl AS
				SELECT dt1.stoplight_id, dt1.stoplight_data_id AS 'start_id', dt2.stoplight_data_id AS 'end_id',
					   dt1.data_date AS 'startup_date', dt1.data_time AS 'startup_time', dt2.data_date AS 'down_date', dt2.data_time AS 'down_time',  CONCAT(
					   FLOOR(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))) / 24), ' Days ',
					   LPAD(MOD(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 24), 2, '0'), ':', 
					   LPAD(MINUTE(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0'), ':',
					   LPAD(SECOND (TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0')) 
					   AS 'Uptime (Days HH:MM:SS)'
				FROM (

						SELECT @rownum := @rownum + 1 AS 'rownum', stoplight_failures.*
						FROM stoplight_failures
					  ) dt1
				INNER JOIN (
							SELECT @rownum2 := @rownum2 + 1 AS 'rownum', temp.*
							FROM temp
							) dt2
				ON (dt2.rownum = dt1.rownum + 1)
			WHERE dt1.rownum % 2 = 1;
			SET  counter = counter + 1;
			SET @switch := 1;
		ELSE

			CALL uptime(counter);
			DROP TABLE IF EXISTS temp;
			CREATE TEMPORARY TABLE temp LIKE stoplight_failures; 
			INSERT temp SELECT * FROM stoplight_failures;
				
			SET @rownum := 0;
			SET @rownum2 := 0;

			INSERT INTO uptime_tbl
				SELECT dt1.stoplight_id, dt1.stoplight_data_id AS 'start_id', dt2.stoplight_data_id AS 'end_id',
					   dt1.data_date AS 'startup_date', dt1.data_time AS 'startup_time', dt2.data_date AS 'down_date', dt2.data_time AS 'down_time',  CONCAT(
					   FLOOR(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))) / 24), ' Days ',
					   LPAD(MOD(HOUR(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 24), 2, '0'), ':', 
					   LPAD(MINUTE(TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0'), ':',
					   LPAD(SECOND (TIMEDIFF(CONCAT(dt2.data_date, " ", dt2.data_time), CONCAT(dt1.data_date, " ",dt1.data_time))), 2, '0')) 
					   AS 'Uptime (Days HH:MM:SS)'
				FROM (

						SELECT @rownum := @rownum + 1 AS 'rownum', stoplight_failures.*
						FROM stoplight_failures
					  ) dt1
				INNER JOIN (
							SELECT @rownum2 := @rownum2 + 1 AS 'rownum', temp.*
							FROM temp
							) dt2
				ON (dt2.rownum = dt1.rownum + 1)
				WHERE dt1.rownum % 2 = 1;
			SET  counter = counter + 1;

		END IF;
	END WHILE;

 END IF;
 END$$ 

DELIMITER ;

-- EVENTS

DROP EVENT IF EXISTS test_event;
CREATE EVENT test_event
  ON SCHEDULE
    EVERY 30 MINUTE
    STARTS '2015-12-31 21:33:00' ON COMPLETION PRESERVE ENABLE 
  DO CALL failures(NULL);