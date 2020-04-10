/*
 *  ------   [Ut_06] - Stack EEPROM Basic operation   -------- 
 *
 *  Explanation: This example shows how to use the Stack EEPROM
 *  library of Waspmote in order to store and get pending frames
 *  using the EEPROM memory of the Waspmote device
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
 *  Implementation:    Alejandro Gallego
 */

#include <WaspSensorSW.h>
#include <WaspStackEEPROM.h>
      
int answer;

uint8_t buffer_sensor[7];
uint8_t buf_length = 7;

////////////////////0 1 2 3 4 5 6 7 8 9 10///////////
uint8_t temp[11] = {1,0,0,0,0,0,1,1,1,0,1};
uint8_t get_buffer[7];
uint8_t get_buf_length;
uint8_t position = 0;

uint8_t node_id = 1;
float temparature;

pt1000Class TemperatureSensor;

void setup() 
{
  
 
  
  //////////////////////////////////////////////////
  // 1. inits the block size and the stack  
  //////////////////////////////////////////////////
  
  // init block size
  USB.println(F("Set Block Size to '10' Bytes"));
  stack.initBlockSize(10);
  
  // clear stack initializing to zeros
  USB.println(F("Clearing Stack..."));
  answer = stack.initStack(FIFO_MODE);
  if (answer == 1)
  {   
    USB.println(F("Stack with FIFO mode initialized"));
  }
  else
  {   
    USB.println(F("Stack NOT initialized"));
  }

  Water.ON();
}
void loop() 
{
      temparature = TemperatureSensor.readTemperature();

      uint8_t h = temparature/10;
      uint8_t e = temparature%10;

      RTC.ON();
      RTC.getTime();
      
      buffer_sensor[0] = node_id; // id
      buffer_sensor[1] = h; //temparature nguyen
      buffer_sensor[2] = e;//temparature du
      buffer_sensor[3] = RTC.hour; // hour
      buffer_sensor[4] = RTC.minute; // min
      buffer_sensor[5] = RTC.second ;// sec
      buffer_sensor[6] = PWR.getBatteryLevel(); //batery
  if(temp[position]== 1)//co ket noi
  {
    USB.println(F("co ket noi"));
   //////////////////////////////////////////////////
  // 4. pop frame from the stack
  //////////////////////////////////////////////////
      
      do
      {

         get_buf_length = stack.pop( get_buffer );
  
          if (get_buf_length == 6)
          {   
            USB.println(F("show buffer got:"));
            for(uint8_t j = 0; j<6 ;j++)
            {
               USB.print(get_buffer[j],DEC);
            }
            USB.println();
          }
          else if(get_buf_length == 0)
          {   
            USB.println(F("emmty eeprom"));
          }
          else
          {
            USB.println(F("error"));
          }
        
      }while(get_buf_length != 0);
      

       USB.println(F("new buffer:"));
       for(uint8_t j = 0; j<6 ;j++)
       {
          USB.print(buffer_sensor[j],DEC);
       }
       USB.println();
  }
  else{
      USB.println(F("k co ket noi"));
      answer = stack.push( buffer_sensor,buf_length);
      if (answer == 1)
      {   
        USB.println(F("Frame pushed"));
      }
      else if (answer == 2)
      {   
        USB.println(F("Stack is full, frame not pushed"));
      }
      else if (answer == 3)
      {   
        USB.println(F("Block size too small, frame not pushed"));
      }
      else
      {   
        USB.println(F("Error pushing the frame"));
      }
    }
  
  

  position++;
  USB.println(F("enter deep sleep"));
  // Go to sleep disconnecting all switches and modules
  // After 10 seconds, Waspmote wakes up thanks to the RTC Alarm
  PWR.deepSleep("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);

  USB.ON();
  USB.println(F("\nwake up"));

  // After wake up check interruption source
  if( intFlag & RTC_INT )
  {
    // clear interruption flag
    intFlag &= ~(RTC_INT);
    
    USB.println(F("---------------------"));
    USB.println(F("RTC INT captured"));
    USB.println(F("---------------------"));
  }

}






