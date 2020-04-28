char filename[]="DATA.TXT";

// define variable
uint8_t sd_answer;

uint8_t is_connect[10] = {1,0,0,1,1,0,0,0,1,0};
uint8_t is_sended[50] = {1,0,0,1,1,0,0,0,1,0,1,0,0,1,1,1,0,0,1,0,1,0,1,1,0,1,0,1,1,1,1,0,1,1,0,1,1,0,0,0,1};
//                       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
uint8_t position = 0;
uint8_t position_send = 0;
int32_t number_line;

char *line[20];
uint8_t count_not_send = 0;
uint8_t i;



void setup()
{
  // open USB port
  USB.ON();
  USB.println(F("SD_4 example"));
  
  // Set SD ON
  SD.ON();
    
  // Delete file
  sd_answer = SD.del(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file deleted"));
  }
  else 
  {
    USB.println(F("file NOT deleted"));  
  }
    
  // Create file
  sd_answer = SD.create(filename);
  
  if( sd_answer == 1 )
  {
    USB.println(F("file created"));
  }
  else 
  {
    USB.println(F("file NOT created"));  
  } 

  
  SD.appendln(filename,"{\"id\":\"node1\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}");
  SD.appendln(filename,"{\"id\":\"node2\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}");
  SD.appendln(filename,"{\"id\":\"node3\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}");
  SD.appendln(filename,"{\"id\":\"node4\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}");
  USB.println(F("\n-------------------"));
  USB.print(F("SHOW THE FILE CONTENTS"));
  SD.showFile(filename);
  //USB.println(strlen(body));
  //USB.println(body[123]);
  //USB.println();
  delay(3000);  
  
}


void loop()
{ 

  if(is_connect[position++])
  {
    USB.println(F("Co ket noi wifi"));
    count_not_send = 0;
    number_line=SD.numln(filename);
    if(number_line!=0 )
    {
      USB.print(F("file co du lieu "));
      USB.println(number_line);
      SD.showFile(filename);
      for(i = 0; i < number_line ; i++)
      {
        USB.println(F("------------READ Line-----------------"));
        SD.catln(filename,i,1);
        USB.println( SD.buffer );
        USB.print(F("position send : "));
        USB.println(is_sended[position_send],DEC);
        if(is_sended[position_send++]==0)
        {
          USB.println(F("Loi gui http"));
          USB.println(F("Them vao line"));
          line[count_not_send] = (char*)malloc(150*sizeof(char));
          strcpy(line[count_not_send++],SD.buffer);
          //line[count_not_send++]=SD.buffer;
        }  
        USB.println(F("----------- END-----------------")); 
      }
    }
    USB.println(F("Du lieu moi doc"));
    USB.print(F("position send "));
    USB.println(is_sended[position_send],DEC);
    
    if(is_sended[position_send++]==0)
      {
        USB.println(F("Loi gui http NEW"));
        USB.println(F("Them vao line"));
        line[count_not_send] = (char*)malloc(150*sizeof(char));
        strcpy(line[count_not_send++],"new er{\"id\":\"node4\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}\n");
        //line[count_not_send++]="new er{\"id\":\"node4\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}";
      }
      
      USB.println(F("Xoa File"));
      sd_answer = SD.del(filename);
  
      if( sd_answer == 1 )
      {
        USB.println(F("file deleted"));
      }
      else 
      {
        USB.println(F("file NOT deleted"));  
      }

      USB.println(F("Tao lai file"));
      sd_answer = SD.create(filename);
  
      if( sd_answer == 1 )
      {
        USB.println(F("file created"));
      }
      else 
      {
        USB.println(F("file NOT created"));  
      }

      USB.println(F("neu co line loi them vao file"));
      if(count_not_send!=0)
      {
        USB.print(F("Da co loi so loi la :"));
        USB.println(count_not_send,DEC);
        USB.println(F("Start append in file"));
        for(i = 0; i < count_not_send ; i++)
        {
          SD.append(filename,line[i]);
          free(line[i]);    
        }
        USB.println(F("Done"));
      }
    
  }else
  {
     USB.println(F("no connect"));
     USB.println(F("Them vao cuoi file"));
     SD.appendln(filename,"new dis{\"id\":\"node4\",\"temp\" : \"32.2\",\"pH\" :\"7\",\"DO\" : \"10.12\",\"ORP\" : \"10.12\",\"DI\" : \"10.12\",\"PIN\" : \"10\",\"ttemp\" : \"121212121212\"}");
  }
  

  USB.println(F("*****************************"));
 
  delay(5000); 
}


