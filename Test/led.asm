ORG 0000H
ljmp start

org 200h

start:
setb EA
setb ET1
CLR C

start1:
mov R5, #00H
mov TMOD,#00010001B;   timer for 0.01s
mov TH1,#0B1H
mov TL1,#0E0H; to count 20000 cycles = 0.01s 
setb TR1

JC secondone
JNC firstone

firstone:
setb P0.0
acall delay1
clr P0.0
acall delay1
jnc firstone

secondone:
setb P0.0
acall delay2
clr P0.0
acall delay2
jc secondone


ljmp start1


delay1: 
mov TMOD,#00010001B;   timer for 1.85ms
mov TH0,#0F1H
mov TL0,#89H; to count 3703 cycles                            
setb TR0                                 	                                              
final1: 
jnb TF0,final1
clr TR0 
clr TF0 
ret


delay2: 
mov TMOD,#00010001B;   timer for 3.3ms/2
mov TH0,#0F2H
mov TL0,#0FBH; to count 3333 cycles                            
setb TR0                                 		                                              
final2: 
jnb TF0,final2
clr TR0 
clr TF0 
ret
	  	  

;-----------

org 001BH
	handler:
	clr TR1 
	inc R5
	MOV A, #0C8H
	SUBB A, R5
	JNZ DONE1
	CPL C
	DONE1:
	setb EA
	setb ET1
    mov TH1,#0B1H
    mov TL1,#0E0H; to count 20000 cycles = 0.01s 
	setb TR1
	reti
;-----------				
				
end