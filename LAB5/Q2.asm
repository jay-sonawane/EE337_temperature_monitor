; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable
	
ORG 000H
	  acall lcd_init      ;initialise LCD
	
LJMP MAIN
ORG 100H
	
MAIN:

MOV R1, #09H
MOV R2, #01H

MOV A, P1
ANL A, #07H

MOV R3, A

MOV A, R1
SUBB A, R3
MOV R1, A

MOV A, R2
ADD A, R3
MOV R2, A

	  mov a,#80h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
      MOV A, R1
	  ADD A, #030H
	  acall lcd_senddata
	  MOV A, #030H
	  acall lcd_senddata
	  
	  mov a,#0C0h		  ;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string2
	  acall lcd_sendstring
	  
	  MOV A, R1	  
	  ADD A, R1
	  DA A
	  MOV R4, A
	  SWAP A
	  ANL A, #0FH
	  ADD A, #030H
	  acall lcd_senddata
	  MOV A, R4
	  ANL A, #0FH
	  ADD A, #030H
	  acall lcd_senddata
	  MOV A, #030H
	  acall lcd_senddata
	  MOV A, #030H
	  acall lcd_senddata	  
	  
	  
	  
LOOPON:
SETB P1.4
SETB P1.5
SETB P1.6
SETB P1.7
ACALL LOOP1S
DJNZ R1, LOOPON

LOOPOFF:
CLR P1.4
CLR P1.5
CLR P1.6
CLR P1.7
ACALL LOOP1S
DJNZ R2, LOOPOFF

LJMP MAIN

LOOP1S:
MOV R6,#8H
LOOP: ACALL DELY
      DJNZ R6,LOOP
      LJMP final
DELY: MOV TMOD,#001B 
       MOV TH0,#03CH
       MOV TL0,#0B0H 
       SETB TR0 
HERE: JNB TF0,HERE 
      CLR TR0 
      CLR TF0 
      RET  
      final: RET


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

;------------- ROM text strings---------------------------------------------------------------
my_string1:
DB   "Duty Cycle:", 00H
my_string2:
DB   "Pulse Width:", 00H
end

