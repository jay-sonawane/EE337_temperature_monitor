LED EQU P1.7
	
;ORG 000BH
	;ACALL Timer0_interrupt	
	;RETI
NAME    Timer0_subroutines

?PR?timer_init?TIMER_INIT    SEGMENT CODE
        PUBLIC  timer_init
        RSEG    ?PR?timer_init?TIMER_INIT
		;USING register bank 2	
timer_init: MOV TMOD,#0x01
			SETB PSW.4
			;MOV TCON,#0x01
			SETB ET0
			MOV R0,81H
			MOV TH0,@R0
			INC R0
			MOV TL0,@R0
			CLR PSW.4
			SETB EA
			SETB TR0
			RET
				
?PR?init?INIT    SEGMENT CODE
        PUBLIC  init
        RSEG    ?PR?init?INIT
		;USING register bank 2	
	init:SETB PSW.4
		MOV P1,#0x0F
		 MOV R0,#81H
         MOV @R0,#0FCH
         INC R0
         MOV @R0,#48H
		 CLR PSW.4
         RET		 
		 
?PR?timer0_int?TIMER0_INT    SEGMENT CODE
        PUBLIC  timer0_int
        RSEG    ?PR?timer0_int?TIMER0_INT
			
			;USING register bank 2	
timer0_int: CLR TF0
			  CLR TR0
			  SETB PSW.4
			  MOV R0,#81H
			  MOV TH0,@R0
			  INC R0
			  MOV TL0,@R0
			  CPL LED
			  CLR PSW.4
			  SETB TR0
			  RET
				  
END				  