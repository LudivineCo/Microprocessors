#include <xc.inc>
    
    
global  crossing, Button, Other_Button, Button_reset ,check_photodiode, crossing_sound
extrn   UART_Transmit_Message,LCD_Write_Message,After_button_press, LCD_delay_ms
extrn    ADC_Read
    
psect	udata_acs   ; reserve data space in access ram
Buttons:    ds 1  ;Reserve ony byte for both buttons of pedestrain crossing
myTable_1:    ds 1 ;Reserve ony byte for table for countdown
sound:          ds 1; used to loop trhough crossing osund function
;psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
;myArray:    ds 0x80 ; reserve 128 bytes for message data   

psect	data    
;	 ******* myTable, data in programme memory, and its length *****
myTable: ;for countdown on screen
	db	'9','8','7','6','5','4','3','2','l',0x0a
					; message, plus carriage return
	myArray   EQU	0x400	; location
        counter   EQU   0x10    ;length
	align	2 
	
psect	Button_code,class=CODE 
    
 crossing:; checks if button was pressed and activates crossing mode
    movlw  0x01 ;put 1 in w
    cpfseq Buttons, A; check if button was pressed
    return; not pressed
    call ADC_Read ;check if person is still there
    movlw 42; choosen threshold
    movlb 0x0F
    CPFSLT ADRESL, 0; in bank
    return; no one there- cancel
    movlw 0x09; someone there -make red; crossing state
    movwf LATD, A
    movlw 0x02         ; Setting the pedestrain crossing to green
    movwf LATH, A
    call crossing_sound
    call Button_reset 
    call countdown
    movlw 0x04       ; Setting the pedestrain crossing to red
    movwf LATH, A    
    call After_button_press 
return

   
crossing_sound: ;function which switches buzzer on and off
    movlw  0x64 ;loop for approx 1 sec
    movwf  sound,A
    repeat:
    movlw  0x40 ;turn buzzer on
    movwf  LATB, A
    movlw  5
    call   LCD_delay_ms
    movlw  0x00 ;turn buzzer off
    movwf  LATB, A
    movlw  5
    call   LCD_delay_ms
    decfsz sound, A
    goto repeat    
return
    
countdown:; ouput to screen
    	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	10	; bytes to read
	movwf 	counter, A		; our counter register
loop: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop		; keep going until finished
	
	call    crossing_sound
	
	movlw	10	; output message to UART
	lfsr	2, myArray
	call	UART_Transmit_Message
	movlw	10	; output message to LCD
	addlw	0xff	; don't send the final carriage return to LCD
	lfsr	2, myArray
	call	LCD_Write_Message
    return
    
Button: ;checks button is pressed
    movlw  0x01
    cpfseq PORTE, A 
    return ;button not pressed
    movwf  Buttons,A;button pressed 
    movlw  0x04 ;turn button lights on
    movwf  LATE,A
 return
    
Other_Button:
    movlw 0x02
    cpfseq PORTE, A ;check if other butrton is pressed
    return
    movlw 0x01
    movwf  Buttons,A
    movlw  0x04; turn button lights on
    movwf  LATE,A
return
    
Button_reset:
    movlw  0x00; reset buttons
    movwf  Buttons,A 
    movlw  0x00; turn off button lights
    movwf  LATE,A
    return
    
check_photodiode:
    call ADC_Read ;check person if there
    movlw 300
    movlb 0x0F
  ;  movf  ADRESL, W,A
    CPFSLT ADRESL, 0;in b
    bra reset1; no one there- cancel
    movlw  0x01; someone there-press button
    movwf  Buttons,A;button pressed 
    movlw  0x04 ;turn button lights on
    movwf  LATE,A
    return
reset1:
    call Button_reset
    return
    
    
    
 end


