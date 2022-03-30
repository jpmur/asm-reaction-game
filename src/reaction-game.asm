;---------------------------------------------------------------------------------------------------
			;	Microcomputer Apps. Mini Project        ;      
			;                Reaction Game 	                ;     
			;            Jason Murphy, Dec 2018		;      	
;---------------------------------------------------------------------------------------------------

				list 		p=18F242
				include		<p18F242.inc>
				
loopcount		        equ 		0x1
				org		0x0000
				goto		Main

				org	        0x0028
Main:			        clrf		PORTB
				movlw		0x38
				movwf		TRISB
				
				movlw		0x0A
				movwf		loopcount
				
				
				
; initial wait for middle button to be pressed before starting game

WaitReset:		        movlw		0x0A			; load loopcount value of 10
				movwf		loopcount		
				btfsc		PORTB,3			; check reset switch
				goto		WaitReset		; if not pressed, check again
				goto		Countdown		; if pressed, start countdown


; when reset button pressed => start countdown
	
Countdown:		        movlw		0x0000			; reset PORTB
				movwf		PORTB
				movlw		0x31			; delay loop
				movwf		T1CON			; set up Timer 1
				movlw		0x0B
				movwf		TMR1H
				movlw		0xDC
				movwf		TMR1L
				bcf		PIR1,TMR1IF
				bsf		T1CON,TMR1ON	        ; start Timer 
				
; check for early presses and timer flag simoultaneously while countdown is active

CheckDly:		        goto		CheckFalse1	
				goto		CheckFalse2
				goto		CheckTimer
				
; after timer loop is  complete:

Cont:			        decfsz		loopcount		; decrement loop count by 1
				goto		Countdown		; if its not zero, run delay loop again
				bcf		T1CON,TMR1ON	        ; turn off Timer 1
				movlw		0x01			; if it is zero, delay over - turn on LED
				movwf		PORTB
				goto 		CheckButton1	        ; go and check player buttons
				
				
; this section checks both players buttons after LED comes one and whoever presses first, wins.		

CheckButton1:	btfsc		PORTB,4			                ; check P1 button	
				goto		CheckButton2 
				movlw		0x03			; pressed, turn on P1 winning LED
				movwf		PORTB
				goto		WaitReset		; if this button is pressed, go back and wait for reset to restart game
				
CheckButton2:	btfsc		PORTB,5			                ; check P2 button
				goto		CheckButton1	        ; not pressed, check P1 button
				movlw		0x5			; pressed, turn on P2 winning LED
				movwf		PORTB
				goto 		WaitReset		; if this button is pressed, go back and wait for reset to restart game
				
				

CheckFalse1:	btfsc		PORTB,4	                                ; check P1 switch
				goto		CheckFalse2		; not pressed, check P2 switch
				movlw		0x04			; if player 1 presses during countdown
				movwf		PORTB			; turn on P2 win light 
				goto		WaitReset
				
CheckFalse2:	btfsc		PORTB,5			                ; check P2 switch
				goto		CheckTimer		; not pressed, check timer next
				movlw		0x02			; if player 2 presses during countdown
				movwf		PORTB			; turn on P1 win light 
				goto 		WaitReset

CheckTimer:		        btfss		PIR1,TMR1IF		; check timer done?
				goto		CheckDly		; no, go back and check switches again for early presses
				goto		Cont			; if timer is done, goto continue


				END
