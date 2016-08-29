# Arduino_Stoplight
This is a project I started working on in the summer of 2015 and picked away at as time allowed. It is a simple stoplight tree with an advanced green/turning green. If one sensor is tripped it mimics a one way advanced green. If the other sensor is tripped it extends the red phase mimicing an advance in the other direction. If both sensors ar tripped before the next red phase you get a turning green ie. left turn only phase. There is also a photo sensor. This mimics the sensors emergency vehicles use to get a green phase. In the real world the system uses a strobe light. In my world a bright light will do the job. There is an orange led which is just a test light. I wanted to detect a failure in the system, so if the led or a wire is pulled the system will go into a safe mode and only flash red until reset. Useing a python script I have it setup to log data from the arduino over the serial port into a MySQL database. I have made web interfaces in JSP and ASP.NET to display the data from the database, but I'm not really pleased with where they are at so I haven't included them for now. 