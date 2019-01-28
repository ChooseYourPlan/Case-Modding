;************************
;*    Case Moding      *
;************************ 

.INCLUDE <m328Pdef.inc>

; Initialisierungen
			ldi r16, 0b00111111
			ldi r17, 0b00000000

			out DDRC, r16
			out DDRD, r17

; Hauptprogramm
START:		
			;ldi r25, 27			
			;call LFSR

			ldi r16, 0b00010000
			out PORTC, r17
				
			;in r16, PIND

			cpi r16,0b00100000
			breq anhaltendes_lauflicht
			
			cpi r16,0b10000000
			breq alle_leds

			
			cpi r16,0b01000000
			breq lauflicht
						
			cpi r16,0b00010000
			breq random		
			
			rjmp START


random:	
		ldi r25,0x02 ;LOAD THIS REGISTER
		out TCCR0B,r25 ;SET PRESCALLER AND INTERNAL CLOCK
		
		ldi r24, 0b10000000
		in r24, TCNT0

		rjmp START


anhaltendes_lauflicht:

			ldi r16,0b00000001	
			
	anhaltendes_lauflicht_loop:
			call Wait
			out PORTC,r16
			
			LSL r16
			inc r16
			cpi r16,0b11111111
			breq START

			rjmp anhaltendes_lauflicht_loop 

alle_leds:
			ldi r16,0b00111111
			out PORTC, r16
			
			call Wait
			call Wait
			call Wait
			call Wait

			rjmp START
lauflicht:

			ldi r16,0b00000001	

	lauflicht_loop:
			call Wait
			out PORTC,r16
			
			LSL r16
			cpi r16,0b10000000
			breq START

			rjmp lauflicht_loop	
 
Wait:
	ldi r18, 0
	mov r19, r18
	mov r20, r18
	
	Wait_loop1:
		inc r18
		cpi r18, 0x20
		brne Wait_loop2
		
		ret

	Wait_loop2:
		inc r19
		cpi r19, 0xff
		brne Wait_loop3

		rjmp Wait_loop1

	 Wait_loop3:
		inc r20
		cpi r20, 0xff
		brne Wait_loop3

		rjmp Wait_loop2


/*

LFSR:     clr   r26

          sbrc  r25,7
   		  
		  inc   r26
    	  sbrc  r25,5
          
		  inc   r26
          sbrc  r25,4
          
		  inc   r26
          sbrc  r25,3
          
		  inc   r26
          ror   r26
          rol   r25
          brne  lfsrx
          
		  ldi   r25,128
lfsrx:    ret
*/
