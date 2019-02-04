;************************
;*    Case Moding      *
;************************ 

.INCLUDE <m328Pdef.inc>

; Initialisierungen
			ldi r16, 0b00111111
			ldi r17, 0b01000000

			out DDRC, r16
			out DDRD, r17

			ldi r25, 0b00000010 
			out TCCR0B,r25 ;Interner Timer Tabelle bei 15.9			

; Hauptprogramm
START:		
			ldi r16, 0b00000000
			out PORTC, r17

			rjmp pulsieren
				
			in r16, PIND

			cpi r16,0b10000000
			breq anhaltendes_lauflicht
			
			cpi r16,0b01000000
			breq alle_leds

			
			cpi r16,0b00100000
			breq lauflicht
						
			cpi r16,0b00010000
			breq random_leds	
			
			cpi r16,0b00001000
			breq pulsieren

			rjmp START


pulsieren:

		ldi r27, 1<<COM0A1 | 1<<WGM00 | 1<<WGM01
		out TCCR0A, r27
		
		ldi r27, 1<<CS01
		out TCCR0B, r27

		ldi r27, 0b00000001
		ldi r26, 0b00001000 

	pulsieren_loop:
	
		out OCR0A, r27
		
		call WAIT
		
		add r27,r26

		cpi r27, 0b00000001 ; Overflow darum 0x01
		brne pulsieren_loop
		
		ldi r27, 0b11111111

	pulsieren_loop_back:

		call WAIT

		out OCR0A, r27

		sub r27, r26 
		
		cpi r27, 0b11111111 ; Overflow darum 0xFF
		brne pulsieren_loop_back
		
		call WAIT
		
		rjmp START



random_leds:
		ldi r25, 0b00000000	
		random_leds_loop:

		in r24, TCNT0  ;15.2.2 Datenblatt 15.5
		
		out PORTC, r24
		call WAIT		
		
		inc r25
		cpi r25, 0b00001111
		breq START
		
		rjmp random_leds_loop 


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
			brne lauflicht_loop	

			rjmp START	
 
Wait:
	ldi r18, 0
	mov r19, r18
	mov r20, r18
	
	Wait_loop1:
		inc r18
		cpi r18, 0x05
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
The 8-bit comparator continuously compares TCNT0 with the Output Compare Registers (OCR0A and
OCR0B). Whenever TCNT0 equals OCR0A or OCR0B, the comparator signals a match.
*/

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
