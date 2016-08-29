
/*
 * FileName: SBStopLight.ino
 * Purpose: Learning for school, Making an arduino stoplight 
 * Notes: Run SBStoplightData.py to grab data via serial port
 * Revision History
 *         Steven Bulgin, 2015.07.18: Created, initial tests of wiring.
 *         Steven Bulgin, 2015.07.18: Added pause on last light and re-organized the sequence
 *         Steven Bulgin, 2015.07.18: Added advanced green and sensor button.
 *         Steven Bulgin, 2015.07.19: Fixed change state on button so it only flips on press, renamed vars to match Con College code standards
 *         Steven Bulgin, 2015.07.19: Added a fuction that listens for the button press every 100 mils through the light phase.
 *         Steven Bulgin, 2015.07.21: Added a second button to simulate trip the other direction. If tripped gives longer red(ie: advance the otherway)
 *                        If both buttons tripped gives a turning green(solid red & flashing green) or if the other tripped gives advanced
 *         Steven Bulgin, 2015.07.21: Add light sensor to mimic emergency vehicle response system. All seems to work, but needs a more thorough testing
 *                        of all senarios.
 *         Steven Bulgin, 2015.08.14: Merged emergency sensor, but has bug if tripped on yellow phase. 
 *         Steven Bulgin, 2015.08.15: Brought in safe_mode
 *         Steven Bulgin, 2015.08.15: Fixed up safe_mode and emergency sensor trips and yellow phase bug
 *         Steven Bulgin, 2015.08.15: Added read from the serial to the console.
 *         Steven Bulgin, 2015.08.20: Added Notes section to header comments to keep track of aux. files and such. Will git the python script
 *                                    Replaced a if-else in the ReadData function with a tenary just to learn
 *         Steven Bulgin, 2015.08.28: Read from python bool to reset counts ready for database insert.
 *         Steven Bulgin, 2015.08.30: Fixed "location" to STOPLIGHT_ID to match future db setup. 
 *         Steven Bulgin, 2015.09.10: Minor change to the read data string for reading it into db
 *         Steven Bulgin, 2015.09.11: Minor bug fix, couldn't read data on safe mode
 *         Steven Bulgin, 2015.09.11: Minor bug fix, wasn't reseting the vals for adv_green and emerge when in safe mode
 *                                    Also some code tidying 
 */

/**** Fixes Needed & improvements ****/
/*************************************/


// Constants

#define RED_LED 13 // sets a value for the red pin
#define YELLOW_LED 12 // sets a value for the 12 pin/yellow led
#define GREEN_LED 11 // sets a const for the 11/green pin
#define ADV_LED 10 // advanced green
#define BTN 7 // sets const for button
#define BTN_2 6 //sets const for button 2
#define LIGHT_SENS 0 // set pin for photo sensor

#define TEST_LED 5 
#define TEST_SENS A1

const String STOPLIGHT_ID = "5";

//Variables

bool advance_trip = false;
bool adv_trp_two = false;
int photo_val = 700;
bool safe_mode = false;
int green_count;
int emerge_count;
bool emerge_bool;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  
  //initialize pins 
  pinMode(RED_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(ADV_LED, OUTPUT);
  pinMode(BTN, INPUT);
  pinMode(BTN_2, INPUT);

  pinMode(TEST_LED, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:

  dataRead();

 //Checks if the serial has sent back a bool saying it's read data
 //If true reset emerge and adv_green count
  if (Serial.available() > 0){
    if (Serial.peek() == 't'){
      Resetter();
      while (Serial.available() > 0){
        Serial.read();
      }
    }
  }

  if ((advance_trip == false) ){
    advance_trip = button1Listener();
  }

    if ((advance_trip == true) && (adv_trp_two == false)){
      digitalWrite(GREEN_LED, HIGH);
       green_count++;
      
      
      for(int i=0; i < 6; i++){
        digitalWrite(ADV_LED, HIGH);
        delay(250);
        digitalWrite(ADV_LED, LOW);
        delay(250);
        advance_trip = false;
      }
      pauser(3);
      digitalWrite(GREEN_LED, LOW);   
      digitalWrite(TEST_LED, HIGH); 
    } 
    else if((adv_trp_two == true) && (advance_trip == false)){
      green_count++;
      digitalWrite(RED_LED, HIGH);
      pauser(10);
      digitalWrite(RED_LED, LOW);
      digitalWrite(GREEN_LED, HIGH);
      pauser(5);
      digitalWrite(GREEN_LED, LOW);
      adv_trp_two = false;
    } 
    else if ((adv_trp_two == true) && (advance_trip == true)){
      green_count = green_count + 2;;
      digitalWrite(RED_LED, HIGH);

      for (int i=0;i<7;i++){
        digitalWrite(ADV_LED, HIGH);
        delay(250);
        digitalWrite(ADV_LED, LOW);
        delay(250);
        advance_trip = false;
        adv_trp_two = false;
      }
      digitalWrite(RED_LED, LOW);
      digitalWrite(GREEN_LED, HIGH);
      pauser(5);
      digitalWrite(GREEN_LED, LOW);
    }
   // Main Green phase
   else {

   
    
      digitalWrite(TEST_LED, HIGH);
      safetyTest();
      safeMode();
      digitalWrite(GREEN_LED, HIGH);
      pauser(5);
      digitalWrite(GREEN_LED, LOW);
      safetyTest();
      safeMode();
    } 
    
  if(photo_val < 100){
    lightSensor();
  }
  //Main yellow
  else{ 
    digitalWrite(YELLOW_LED, HIGH);
    pauser(3);
    digitalWrite(YELLOW_LED, LOW);
    safetyTest();
    safeMode();
  }

  if(photo_val < 100){
    lightSensor();
  }
  else{
    safetyTest();
    safeMode();
    digitalWrite(RED_LED, HIGH);
    pauser(5);
    digitalWrite(RED_LED, LOW);
    digitalWrite(TEST_LED, LOW);
  }  
}

// Functions

//Button Listener

bool button1Listener(){
  bool x = false;
  int val = 0;
  val = digitalRead(BTN); // reads button
  if(val == HIGH && x == false){
      x = true;
  }
  return x;
}

//Listener for second button
bool button2Listener(){
  bool x = false;
  int val = 0;
  val = digitalRead(BTN_2); // reads button
  if(val == HIGH && x == false){
      x = true;
  }
  return x;
}

//Pauser
//Add an int representing a second count for the light HIGH

void pauser(int x){

  x = x * 10;
  
  
  for(int i = 0; i < x; i++){
    delay(100);
    if (advance_trip == false){
      advance_trip = button1Listener();
    } 

    photo_val = analogRead(LIGHT_SENS);

    if(adv_trp_two == false){
      adv_trp_two = button2Listener();      
    }
  }
}

void lightSensor(){

  do{
    digitalWrite(GREEN_LED, HIGH);
    emerge_bool = true;
  }while(analogRead(LIGHT_SENS) < 100);
  
  if(emerge_bool == true){
    emerge_count++;
    emerge_bool != emerge_bool;
  }
  
  digitalWrite(GREEN_LED, HIGH);
  pauser(10);
  digitalWrite(GREEN_LED, LOW);
  photo_val = 700;
  
  if(photo_val < 100){
    lightSensor();
  }
  
  digitalWrite(YELLOW_LED, HIGH);
  pauser(3);
  digitalWrite(YELLOW_LED, LOW);
    
  if(photo_val < 100){
    lightSensor();
  }
  
  digitalWrite(RED_LED, HIGH);
  pauser(5);
  digitalWrite(RED_LED, LOW);

  if(photo_val < 100){
    lightSensor();
  }
}

void safeMode(){
  
  while(safe_mode){
    if (Serial.available() > 0){
      if (Serial.peek() == 't'){
        Resetter();
        while (Serial.available() > 0){
          Serial.read();
        }
      }
    }
    dataRead();
    digitalWrite(RED_LED, HIGH);
    delay(250);
    digitalWrite(RED_LED, LOW);
    delay(250);
  }
}

void safetyTest(){
  if (TEST_LED == HIGH && (analogRead(TEST_SENS) < 5) || (analogRead(TEST_SENS) > 1000)){
    safe_mode = true;      
  }
}

// Prints data via serial to a python script
void dataRead(){
  String green_data = String(green_count);
  String emerge_data = String(emerge_count);
  String functional;
  String read_string;

  //Changed simple if-else to tenary
  functional = ((safe_mode)? "No" : "Yes");

  read_string = "Null, " + STOPLIGHT_ID + ", '" + functional + "', " + green_data + ", " + emerge_data;
  Serial.println(read_string);
  Serial.flush();
  
  read_string = "";
  green_data = "s";
  emerge_data = "s";
}

void Resetter(){
  emerge_count = 0;
  green_count = 0;
}