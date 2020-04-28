#include <WaspSensorSW.h>
#include <WaspWIFI_PRO.h>

///////////////Wifi-Config///////////////////

// choose socket
uint8_t socket = SOCKET0;

// WiFi AP settings (CHANGE TO USER'S AP)
char ESSID[] = "NhutHuy";
char PASSW[] = "0392597878";


////////////////Variable-sensors-read////////////////

float value_temp;
float value_pH;
//float value_pH_calculated;
float value_orp;
//float value_orp_calculated;
float value_do;
//float value_do_calculated;
float value_cond;
//float value_cond_calculated;

// Calibration values

#define cal_point_10 1.985
#define cal_point_7 2.070
#define cal_point_4 2.227
// Temperature at which calibration was carried out
#define cal_temp 23.7
// Offset obtained from sensor calibration
#define calibration_offset 0.0
// Calibration of the sensor in normal air
#define air_calibration 2.65
// Calibration of the sensor under 0% solution
#define zero_calibration 0.0
// Value 1 used to calibrate the sensor
#define point1_cond 10500
// Value 2 used to calibrate the sensor
#define point2_cond 40000
// Point 1 of the calibration 
#define point1_cal 197.00
// Point 2 of the calibration 
#define point2_cal 150.00

/////////Sensors-Class//////////////

char node_ID[] = "Node_1";

pt1000Class TemperatureSensor;
pHClass pHSensor;
ORPClass ORPSensor;
DOClass DOSensor;
conductivityClass ConductivitySensor;



// define variables-system

uint8_t error;
uint8_t status;
unsigned long previous;

uint8_t i = 0;
char body[200];


void configWifi()
{
  USB.println(F("****************Wifi-Config****************\n"));
  // 1. Switch ON the WiFi module
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  // 2. Reset to default values

  error = WIFI_PRO.resetValues();

  if (error == 0)
  {    
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }

  // 3. Set ESSID

  error = WIFI_PRO.setESSID(ESSID);

  if (error == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }

  // 4. Set password key (It takes a while to generate the key)

  error = WIFI_PRO.setPassword(WPA2, PASSW);

  if (error == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }

  // 5. Software Reset
  error = WIFI_PRO.softReset();

  if (error == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }

   USB.println(F("****************Finished-Wifi-Config****************\n"));
}


void setup()
{
  //config the calibration values
  pHSensor.setCalibrationPoints(cal_point_10, cal_point_7, cal_point_4, cal_temp);
  DOSensor.setCalibrationPoints(air_calibration, zero_calibration);
  ConductivitySensor.setCalibrationPoints(point1_cond, point1_cal, point2_cond, point2_cal);
 
  //config wifi
  configWifi();
 
  //power on SW
  Water.ON();
  SD.ON();
  delay(2000);//wait the Smart Water stability
   
   // get current time
  previous = millis();
}


void loop()
{

  // 2. Read sensors

  // Read the temperature sensor
  value_temp = TemperatureSensor.readTemperature();

  // Read the ph sensor
  value_pH = pHSensor.readpH();
  // Convert the value read with the information obtained in calibration
  value_pH = pHSensor.pHConversion(value_pH,value_temp);
  
  // Reading of the ORP sensor
  value_orp = ORPSensor.readORP();
  // Apply the calibration offset
  value_orp = value_orp - calibration_offset;
  
  // Reading of the DO sensor
  value_do = DOSensor.readDO();
  // Conversion from volts into dissolved oxygen percentage
  value_do = DOSensor.DOConversion(value_do);

  // Reading of the Conductivity sensor
  value_cond = ConductivitySensor.readConductivity();
  // Conversion from resistance into ms/cm
  value_cond = ConductivitySensor.conductivityConversion(value_cond);

  
  
 
   // Check if module is connected
  if (WIFI_PRO.isConnected() == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous); 

    error = WIFI_PRO.getIP();

    if(error == 0)
    {
      USB.print(F("Ip address : "));
      USB.println(WIFI_PRO._ip);
    }
    else
    {
      USB.println(F("getIP error"));
    }

    USB.print(F("Data :"));
    USB.println(body);
    delay(20000);
  }
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }


//////////////DEEP SLEEP MODE//////////////////////////////////////////
  USB.println(F("enter deep sleep"));                               ///
  // Go to sleep disconnecting all switches and modules             ///
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm    ///
  PWR.deepSleep("00:00:00:20",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);   ///
                                                                    ///        
  USB.ON();                                                         ///
  USB.println(F("\nwake up"));                                      ///
                                                                    ///
  // After wake up check interruption source                        ///
  if( intFlag & RTC_INT )                                           ///
  {                                                                 ///
    // clear interruption flag                                      ///
    intFlag &= ~(RTC_INT);                                          ///
                                                                    ///
    USB.println(F("---------------------"));                        ///
    USB.println(F("RTC INT captured"));                             ///
    USB.println(F("---------------------"));                        ///
  }                                                                 ///
///////////////////////////////////////////////////////////////////////
  
  // 1. Switch ON the WiFi module
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }
  // get current time
  previous = millis();
}


