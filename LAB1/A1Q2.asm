ORG 0H	
CLR C

MOV R7, #0H ; max value variable
MOV R3, #0H ; second max variable
MOV A, #0H ; comparison variable
MOV R1, #40H ; address location storing variable
MOV R2, #14H  ; counter for address
LOOP: MOV A, R7; R7 and A are equal and equal to max 
SUBB A, @R1 ; if A> @R1, Carry 0 else 1
JNC checkpoint ; jump if carry is 0 
MOV 03H, R7 ; store second max value in R3
MOV A, @R1 ; store max value in A
MOV R7, A ; store value of max in R7 again
LJMP checkpoint2
checkpoint:
MOV A, R3 ;store second largest value in A for comparison
CLR C
SUBB A, @R1 ; if R3> @R1, Carry 0 else 1
JNC checkpoint2 ; jump if carry is 0
MOV 03H, @R1 ; store second max value in R3
checkpoint2: INC R1
DJNZ R2, LOOP
MOV 70H, R7
MOV 71H, R3
HERE:SJMP HERE
END
	