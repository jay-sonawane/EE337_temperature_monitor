; This subroutine writes characters on the LCD
LCD_data equ P2    ;LCD Data port
LCD_rs   equ P0.0  ;LCD Register Select
LCD_rw   equ P0.1  ;LCD Read/Write
LCD_en   equ P0.2  ;LCD Enable
	
ORG 000H

LJMP MAIN

ORG 000BH

ljmp Handler
ORG 0050H
Handler: CLR TR0
INC R2
MOV TH0,#00H
MOV TL0,#00H 
SetB EA ; (or SetB IE.7) to enable interrupts
SetB ET0 ; (or SetB IE.1) to enable interrupts from T0
setb TR0
RETI

ORG 100H
	
MAIN:
acall lcd_init      ;initialise LCD	
CLR P1.4
SetB EA ; (or SetB IE.7) to enable interrupts
SetB ET0 ; (or SetB IE.1) to enable interrupts from T0

MAINLOOP:
	  mov a,#80h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string1   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  
	  mov a,#0C0h		  ;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string2
	  acall lcd_sendstring

ACALL LOOPDELAY
ACALL LOOPDELAY
SETB P1.4

MOV TMOD,#001H 
MOV TH0,#00H
MOV TL0,#00H 
SETB TR0 

SUBROUTINE:
MOV C, P1.0
JNC SUBROUTINE

CLR P1.4
CLR TR0
MOV R3, TH0
MOV R4, TL0

      mov a,#80h		 ;Put cursor on first row,1 column
	  acall lcd_command	 ;send command to LCD
	  acall delay
	  mov   dptr,#my_string3   ;Load DPTR with sring1 Addr
	  acall lcd_sendstring	   ;call text strings sending routine
	  acall delay
	  
	  mov a,#0C0h		  ;Put cursor on second row,0 column
	  acall lcd_command
	  acall delay
	  mov   dptr,#my_string4
	  acall lcd_sendstring

MOV A, R2
SWAP A
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata	  

MOV A, R2
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata

MOV A, #20H
acall lcd_senddata

MOV A, R3
SWAP A
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata	  

MOV A, R3
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata

MOV A, R4
SWAP A
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata	  

MOV A, R4
ANL A, #0FH
ACALL LCDpri
ADD A, #30H
acall lcd_senddata

ACALL LOOPDELAY
ACALL LOOPDELAY
ACALL LOOPDELAY
ACALL LOOPDELAY
ACALL LOOPDELAY

LJMP MAINLOOP

LCDpri: CLR C
SUBB A, #0AH
JC lab
ADD A, #07H
lab:
ADD A, #0AH
RET

LOOPDELAY:
MOV R6,#28H
LOOP: ACALL DELY
      DJNZ R6,LOOP
      LJMP final
DELY: MOV TMOD,#010H 
       MOV TH1,#03CH
       MOV TL1,#0B0H 
       SETB TR1 
HERE: JNB TF1,HERE 
      CLR TR1 
      CLR TF1
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
DB   "Toggle SW1", 00H
my_string2:
DB   "if LED glows", 00H
my_string3:
DB   "Reaction Time", 00H
my_string4:
DB   "Count is ", 00H

end

