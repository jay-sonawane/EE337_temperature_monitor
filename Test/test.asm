; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable

ORG 0000H
ljmp start

org 200h
start:
    setb EA
    setb ET0
    mov TMOD,#00000001B
	mov TH0,#0D8H
	mov TL0,#0F0H; to count 10000 cycles = 0.005s
	;setb TR0
      mov P2,#00h
	  clr P1.7
	  clr P1.6
	  clr P1.5
	  clr P1.4
     ; mov P1,#00h
	  ;initial delay for lcd power up

	;here1:setb p1.0
      acall delay
	;clr p1.0
	  acall delay
	;sjmp here1


	  acall lcd_init      ;initialise LCD
start2:	
	  	  mov a,#82h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay

	  mov a,#0C6h		  ;Put cursor on second row,3 column
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string2
	  acall lcd_sendstring

acall delay1sec
acall delay1sec
setb P1.4
setb TR0

next:
jnb P1.0, next

clr P1.4
clr TR0

mov A, R5
mov B, #10H
div AB
mov 51H, A
mov 50H, B

mov A, TH0
mov B, #10H
div AB
mov 53H, A
mov 52H, B

mov A, TL0
mov B, #10H
div AB
mov 55H, A
mov 54H, B
				
mov a,#80h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string3   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay

mov a,#0C0h		 ;Put cursor on first row,5 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string4   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	    mov A, 51H
		subb A, #0AH
		jnc later1
		mov A, #30H
		add A, 51H
		acall lcd_senddata
		sjmp nextone1
		later1:
		mov A, #37H
		add A, 51H
		acall lcd_senddata
		nextone1:
		mov A, 50H
		subb A, #0AH
		jnc later2
		mov A, #30H
		add A, 50H
		acall lcd_senddata
		sjmp nextone2
		later2:
		mov A, #37H
		add A, 51H
		acall lcd_senddata
		nextone2:
		mov A, #20H
		acall lcd_senddata
		mov A, #44H
		acall lcd_senddata
		mov A, #38H
		acall lcd_senddata
		mov A, #46H
		acall lcd_senddata
		mov A, #30H
		acall lcd_senddata	  
		

acall delay1sec
acall delay1sec
acall delay1sec
acall delay1sec
acall delay1sec

ljmp start2
;------------------------LCD Initialisation routine----------------------------------------------------
lcd_init:
         mov   LCD_data,#38H  ;Function set: 2 Line, 8-bit, 5x7 dots
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
	     acall delay

         mov   LCD_data,#0CH  ;Display on, Curson off
         clr   LCD_rs         ;Selected instruction register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay
         mov   LCD_data,#01H  ;Clear LCD
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         
		 acall delay

         mov   LCD_data,#06H  ;Entry mode, auto increment with no shift
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en

		 acall delay
         
         ret                  ;Return from routine

;-----------------------command sending routine-------------------------------------
 lcd_command:
         mov   LCD_data,A     ;Move the command to LCD port
         clr   LCD_rs         ;Selected command register
         clr   LCD_rw         ;We are writing in instruction register
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
		 acall delay
    
         ret  
;-----------------------data sending routine-------------------------------------		     
 lcd_senddata:
         mov   LCD_data,A     ;Move the command to LCD port
         setb  LCD_rs         ;Selected data register
         clr   LCD_rw         ;We are writing
         setb  LCD_en         ;Enable H->L
		 acall delay
         clr   LCD_en
         acall delay
		 acall delay
         ret                  ;Return from busy routine

;-----------------------text strings sending routine-------------------------------------
lcd_sendstring:
	push 0e0h
	lcd_sendstring_loop:
	 	 clr   a                 ;clear Accumulator for any previous data
	         movc  a,@a+dptr         ;load the first character in accumulator
	         jz    exit              ;go to exit if zero
	         acall lcd_senddata      ;send first char
	         inc   dptr              ;increment data pointer
	         sjmp  LCD_sendstring_loop    ;jump back to send the next character
exit:    pop 0e0h
         ret                     ;End of routine

;----------------------delay routine-----------------------------------------------------
delay:	 push 0
	 push 1
         mov r0,#1
loop2:	 mov r1,#255
	 loop1:	 djnz r1, loop1
	 djnz r0, loop2
	 pop 1
	 pop 0 
	 ret 
;------------------------------------------------
delay1sec:
        mov R2, #15
		delay2:mov R3,#255
			
		delay1: 
			mov R4, #255
			here : djnz R4, here
			djnz R3,delay1 
			
		djnz R2,delay2
		ret	
;------------- ROM text strings---------------------------------------------------------------
org 300h
my_string1:
         DB "Toggle SW1", 00H
my_string2:
		 DB     "if LED glows", 00H


;-------------------------------------------------------------
org 000BH
	handler:
	final3: 
	jnb TF1,final3
	clr TR0
	clr TF1
	inc R5
	mov TMOD,#00000001B;   timer for 0.005s
	mov TH0,#0D8H
	mov TL0,#0F0H;
	setb EA
	setb ET0
	setb TR0
	reti

;------------- ROM text strings---------------------------------------------------------------

my_string3:
         DB "Reaction Time", 00H
my_string4:
		 DB   "Count is ", 00H
			 

end