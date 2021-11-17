/**********************************************************
EE337: ADC IC MCP3008 interfacing with pt-51
(1) Complete spi_init() function from spi.h 
(2) Uncomment LM35 interfacing code from main function
		Choose appropriate scaling factor for converting temperature 
		sensor reading sampled using ADC such that it will be in 
		degree Celsius and display it on the LCD)
***********************************************************/
#include <at89c5131.h>
#include "lcd.h"																				//Driver for interfacing lcd 
#include "mcp3008.h"																		//Driver for interfacing ADC ic MCP3008
sbit Port = P0^7;

void print_temp1(unsigned int y);
void print_temp2(unsigned int y);
void print_temp3(unsigned int y);
void print_alert();

unsigned int avg;
char adc_ip_data_ascii[6]={0,0,0,0,0,'\0'};							//string array for saving ascii of input sample
code unsigned char display_msg1[]="Volt.: ";						//Display msg on 1st line of lcd
code unsigned char display_msg2[]=" mV";								//Display msg on 2nd line of lcd
unsigned char display_msg3[]={0,0,'.',0,' ','\0'};//"xxx °C", Display msg on 2nd line of lcd
code unsigned char display_msg4[]="Avg: ";						//Display msg on 2nd line of lcd
code unsigned char display_msg5[]="ALERT!          ";						//Display msg on 2nd line of lcd

void print_alert()
{
		lcd_cmd(0x80);																			//Move cursor to 2nd line of LCD
		lcd_write_string(display_msg5);
}

void print_average(float Av)
{
		float temperature;
   	temperature = (Av*0.32258); 															//NOTE: LM35 O/P: 10mV/°C, Refer to LM35 datasheet for more information
   	avg = (unsigned int) (temperature*10.0);							//Convert float value to unsigned int 
	
		int_to_string(avg,adc_ip_data_ascii);									//Converting integer to string of ascii
		lcd_cmd(0xC0);																			//Move cursor to 2nd line of LCD
		display_msg3[0] = adc_ip_data_ascii[2];
		display_msg3[1] = adc_ip_data_ascii[3];
		display_msg3[3] = adc_ip_data_ascii[4];
		
		lcd_write_string(display_msg4);
 
		lcd_write_string(display_msg3);
}
	

void print_temp1(unsigned int y)
{
		float temperature;
   	temperature = (y*0.32258); 															//NOTE: LM35 O/P: 10mV/°C, Refer to LM35 datasheet for more information
   	y = (unsigned int) (temperature*10.0);							//Convert float value to unsigned int 
																												//Multiply with 10 to retain 0.1 deg C as a least count of temp
		int_to_string(y,adc_ip_data_ascii);									//Converting integer to string of ascii
		lcd_cmd(0x80);																			//Move cursor to 2nd line of LCD
		display_msg3[0] = adc_ip_data_ascii[2];
		display_msg3[1] = adc_ip_data_ascii[3];
		display_msg3[3] = adc_ip_data_ascii[4];
										 
		lcd_write_string(display_msg3);
}
void print_temp2(unsigned int y)
{
		float temperature;
   	temperature = (y*0.32258); 															//NOTE: LM35 O/P: 10mV/°C, Refer to LM35 datasheet for more information
   	y = (unsigned int) (temperature*10.0);							//Convert float value to unsigned int 
																												//Multiply with 10 to retain 0.1 deg C as a least count of temp
		int_to_string(y,adc_ip_data_ascii);									//Converting integer to string of ascii
		lcd_cmd(0x85);																			//Move cursor to 2nd line of LCD
		display_msg3[0] = adc_ip_data_ascii[2];
		display_msg3[1] = adc_ip_data_ascii[3];
		display_msg3[3] = adc_ip_data_ascii[4];
										 
		lcd_write_string(display_msg3);
}
void print_temp3(unsigned int y)
{
		float temperature;
   	temperature = (y*0.32258); 															//NOTE: LM35 O/P: 10mV/°C, Refer to LM35 datasheet for more information
   	y = (unsigned int) (temperature*10.0);							//Convert float value to unsigned int 
																												//Multiply with 10 to retain 0.1 deg C as a least count of temp
		int_to_string(y,adc_ip_data_ascii);									//Converting integer to string of ascii
		lcd_cmd(0x8A);																			//Move cursor to 2nd line of LCD
		display_msg3[0] = adc_ip_data_ascii[2];
		display_msg3[1] = adc_ip_data_ascii[3];
		display_msg3[3] = adc_ip_data_ascii[4];
										 
		lcd_write_string(display_msg3);
}


void main(void)
{ 
	int m,n,i=0;
	unsigned int adc_data=0;
	unsigned int x[10];
  float average=0.0;	
	float sum=0.0;
	Port=0;
	
	spi_init();																					
	adc_init();
  lcd_init();

	for(m=0; m<10; m++)
	{
		x[m]=adc(7);    //Read analog value from 7th channel of ADC Ic MCP3008
		msdelay(1);
    sum=sum+x[m];		
	}																				

    average=sum/10;	
		print_temp1(x[7]);
		print_temp2(x[8]);
		print_temp3(x[9]);
		print_average(average);	
		msdelay(1000);
	
	while(1)
	{   
		sum=0.0;
			for(n=0;n<9;n++)
				{
					x[n]=x[n+1];
					sum=sum+x[n];	
				}		
		x[9]= adc(7);	

		if ((x[9]>(average+ 6))|(x[9]<(average-6)))
		{ 
			print_alert();						
			TMOD=0X01;

			for(i=1; i<=2160;i++)
				{
					TH0= 0X0F1;
					TL0= 0X089;
					TR0=1;
          while(TF0==0)
					{
            continue;
          }
					TR0=0;
					TF0=0;
					Port=!Port;
					
					if(i%540==0)
					{
						sum=0.0;
						for(n=0;n<9;n++)
							{
								x[n]=x[n+1];
								sum=sum+x[n];	
							}	
						x[9]= adc(7);	
						sum=sum+x[9];
						average=sum/10;		
					}
				}
		}	
		else if ((x[9]<(average+ 6)) && (x[9]>(average-6)))
		{  		
			sum=sum+x[9];
			average=sum/10;
			print_temp1(x[7]);
			print_temp2(x[8]);
			print_temp3(x[9]);
			print_average(average);

			msdelay(1000);
		}		
	}
}