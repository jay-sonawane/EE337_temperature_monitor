org 0h
ljmp main
org 100h
		
		main : 
			setb p1.4
			;setb p1.2
			acall delay
			clr p1.4
			;clr p1.2
			acall delay
			sjmp main
			
		delay :
			mov R2,#255
			
		delay1 : 
			mov R1, #255
			here : djnz R1, here
			djnz R2,delay1 
		ret
			
end
				