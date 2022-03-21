#include <xc.inc>

extrn	UART_Setup, UART_Transmit_Message  ; external uart subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex ; external LCD subroutines
extrn	ADC_Setup, ADC_Read; external ADC subroutines
;extrn   LCD_delay_ms   
extrn   Traffic_lights_setup, Traffic_Lights_Light_pattern ;traffic lights
extrn   crossing, Button, Other_Button, Button_reset, check_photodiode; button
extrn   photo_diode_setup; photodiode
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
    
;psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
;myArray:    ds 0x80 ; reserve 128 bytes for message data   
;;d1:         ds 1
;;d2:         ds 1
;;d3:         ds 1

;psect	data    
	; ******* myTable, data in programme memory, and its length *****
;myTable:
;	db	'H','e','l','l','o',' ','W','o','r','l','d','!',0x0a
;					; message, plus carriage return
;	myTable_l   EQU	13	; length of data
;	align	2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup UART
	;call	ADC_Setup	; setup ADC
	call    photo_diode_setup; includes ADC_setup
	call    Traffic_lights_setup
	call    Button_reset
	Goto	start
	
	; ******* Main programme ****************************************
start: 
    call Traffic_Lights_Light_pattern ;default pattern
    call crossing  ;check crossing
    call Button_reset 
    goto start
   
;measure_loop:
;	call	ADC_Read
;	
;	movf	ADRESH, W, A
;	;movlw	0xF
;	call	LCD_Write_Hex
;	movf	ADRESL, W, A
;	call	LCD_Write_Hex
;	goto	measure_loop ;$		; goto current line in code
;	
;	; a delay subroutine if you need one, times around loop in delay_count
;delay:	decfsz	delay_count, A	; decrement until zero
;	bra	delay
;	return
;	

	end	rst
