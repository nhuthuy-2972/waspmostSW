/*  
 *  ------ WIFI Example -------- 
 *  
 *  Explanation: This example shows how to configure the WiFi module
 *  to join a specific Access Point. So, ESSID and password must be 
 *  defined.
 *  
 *  Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L. 
 *  http://www.libelium.com 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *  
 *  Version:           3.0
 *  Design:            David Gascon 
 *  Implementation:    Yuri Carmona
 */

#include <WaspSensorSW.h>
#include <WaspWIFI_PRO.h>


// choose socket (SELECT USER'S SOCKET)
///////////////////////////////////////
uint8_t socket = SOCKET0;
///////////////////////////////////////

// WiFi AP settings (CHANGE TO USER'S AP)
///////////////////////////////////////
char ESSID[] = "NhutHuy";
char PASSW[] = "0392597878";
///////////////////////////////////////


char type[] = "http";
char host[] = "server-smart-water.herokuapp.com";
char port[] = "80";
char url[]  = "display?";




// define variables
uint8_t error;
uint8_t status;
unsigned long previous;

float value_temp;
char node_ID[] = "Node_01";
pt1000Class TemperatureSensor;

char body[200];
char temparature[8];

void setup() 
{
  USB.println(F("Start program"));  

  Water.ON();
 
  //////////////////////////////////////////////////
  // 1. Switch ON the WiFi module
  //////////////////////////////////////////////////
  error = WIFI_PRO.ON(socket);

  if (error == 0)
  {    
    USB.println(F("1. WiFi switched ON"));
  }
  else
  {
    USB.println(F("1. WiFi did not initialize correctly"));
  }


  //////////////////////////////////////////////////
  // 2. Reset to default values
  //////////////////////////////////////////////////
  error = WIFI_PRO.resetValues();

  if (error == 0)
  {    
    USB.println(F("2. WiFi reset to default"));
  }
  else
  {
    USB.println(F("2. WiFi reset to default ERROR"));
  }


  //////////////////////////////////////////////////
  // 3. Set ESSID
  //////////////////////////////////////////////////
  error = WIFI_PRO.setESSID(ESSID);

  if (error == 0)
  {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else
  {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }


  //////////////////////////////////////////////////
  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  //////////////////////////////////////////////////
  error = WIFI_PRO.setPassword(WPA2, PASSW);

  if (error == 0)
  {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else
  {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }


  //////////////////////////////////////////////////
  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  //////////////////////////////////////////////////
  error = WIFI_PRO.softReset();

  if (error == 0)
  {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else
  {
    USB.println(F("5. WiFi softReset ERROR"));
  }


  USB.println(F("*******************************************"));
  USB.println(F("Once the module is configured with ESSID"));
  USB.println(F("and PASSWORD, the module will attempt to "));
  USB.println(F("join the specified Access Point on power up"));
  USB.println(F("*******************************************\n"));

  // get current time
  previous = millis();
}



void loop()
{ 
  //////////////////////////////////////////////////
  // Join AP
  //////////////////////////////////////////////////  

 
  
  // Check if module is connected
  if (WIFI_PRO.isConnected() == true)
  {    
    USB.print(F("WiFi is connected OK"));
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  

    
    
    USB.println(F("\n*** Program Start ***"));

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
//
//     value_temp = TemperatureSensor.readTemperature();
//     Utils.float2String(value_temp,temparature,3);
//     snprintf(body,sizeof(body),"{\"temp\":\"%s\",\"ph\":\"7.2\"}",temparature);
//      USB.println(body);
//      USB.println(temparature);
      error = WIFI_PRO.setURL( type, host, port, url );

  // check response
      if (error == 0)
      {
        USB.println(F("2. setURL OK"));
      }
      else
      {
        USB.println(F("2. Error calling 'setURL' function"));
        WIFI_PRO.printErrorCode();
      }

//      error = WIFI_PRO.setContentType("application/json");
//      // check response
//      if (error == 0)
//      {
//      USB.println(F("2. setContentType OK"));
//      }
//      else
//      {
//      USB.println(F("2. Error calling 'setContentType' function"));
//      WIFI_PRO.printErrorCode();
//      }

      
      error = WIFI_PRO.post("temp=69.7&ph=7.10"); 
      //error = WIFI_PRO.post(body);
    // check response
    if (error == 0)
    {
      USB.print(F("3.1. HTTP POST OK. "));
      USB.print(F("HTTP Time from OFF state (ms):"));
      USB.println(millis()-previous);
      
      USB.print(F("\nServer answer:"));
      USB.println(WIFI_PRO._buffer, WIFI_PRO._length);
    }
    else
    {
      USB.println(F("3.1. Error calling 'post' function"));
      WIFI_PRO.printErrorCode();
    }




    
//    for(int i = 0 ; i < 5 ; i++)
//    {
//        error = WIFI_PRO.ping("172.20.10.9");
//
//        if(error == 0)
//        {
//          USB.print(F("ROUND trip time(ms) = "));
//          USB.println(WIFI_PRO._rtt,DEC);
//        }
//        else
//        {
//          USB.print(F("Error calling 'ping' function"));
//          WIFI_PRO.printErrorCode();
//        }
//        delay(2000);
//     }
    } 
  else
  {
    USB.print(F("WiFi is connected ERROR")); 
    USB.print(F(" Time(ms):"));    
    USB.println(millis()-previous);  
  }

  delay(5000);
}


