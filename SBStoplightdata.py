# FileName: SBStoplightdata.py
# Purpose: Strip data from Arduino SBStopLight.ino and save to txt file
#		   to be read into SBStopLight java web app
# Notes: To run the script C:> Python path to file of not already in dir
# Revision History
#		Steven Bulgin, 2015.08.15: Created
#		Steven Bulgin, 2015.08.15: Serial reading works With bugs...
#								   Bug: Clips way, way too fast
#								   Bug: Duplicates time stamp. May be related to the speed
#										Arduino isn't sending that fast
#		Steven Bulgin, 2015.08.20: Added to the stoplight git repository
#		Steven Bulgin, 2015.08.25: Start of File IO
#		Steven Bulgin, 2015.08.28: Poll every 15min.
# 		Steven Bulgin, 2015.08.28: Minor code and comment tidying
# 		Steven Bulgin, 2015.09.07: Testing code snippets
# 		Steven Bulgin, 2015.09,07: Snippets work for header commenting
# 		Steven Bulgin, 2015-09-10: Added db connection. Reset read interval to 15min
#       Steven Bulgin, 2015.12.22: Added time print on start to keep track of things
#       Steven Bulgin, 2015.12.28: Added a user to the database -u sl_inserter -p *****
#					   that only has insert priviledges on stoplight_data table

import serial
import datetime
import os
import mysql.connector


data = serial.Serial('com5', 9600)
current_time = datetime.datetime.now()
print(current_time.strftime("%H:%M:%S"))
file_path = "C:/Users/Steve/Documents/Arduino/SBStoplight/web/WEB-INF/stoplight_data.txt"
reset = False

while 1==1:

	time2 = datetime.datetime.now()
	minutes = time2 - datetime.timedelta(minutes=10)
			
			
	date = datetime.datetime.now().strftime("%Y-%m-%d")
	

	if reset:
		data.write("t")
		reset = False

	myData = (data.readline().strip()) #Reads from the serial
	

	while minutes >= current_time:
		current_time = time2
		strtime = current_time.strftime("%H:%M:%S")
		reset = True
		
# Makes a db connection object
		cnx = mysql.connector.connect(user='sl_inserter', password='*****',
                              host='127.0.0.1',
                              database='stoplightdb')

# Sets a cursor for writting to the db
		cursor = cnx.cursor()

# Build insertion string from data
		add_stoplightdata = ("INSERT INTO stoplight_data "
               "(stoplight_data_id, stoplight_id, functional, adv_greens, emerge, data_date, data_time) "
               "VALUES (" + myData + ", '" + date + "', '" + strtime + "')")

		cursor.execute(add_stoplightdata) # Writes the string to the database
		cnx.commit() # Commits changes to db, without it they won't be saved
		cnx.close() # Closes db connection
		print(add_stoplightdata)

		myData = ""