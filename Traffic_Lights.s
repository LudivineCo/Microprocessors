#include <xc.inc>
    
global  Traffic_lights_setup,Traffic_Lights_Light_pattern,After_button_press
extrn   LCD_delay_ms
extrn   Button, Other_Button,check_photodiode

psect	udata_acs   ; reserve data space in access ram
;test:    ds 1    ; reserve one byte for a test variable    
    
psect	Traffic_Lights_code,class=CODE 
    
Traffic_lights_setup:;set up ports
    movlw   0x00
    movwf   TRISB, A ;output- for buzzer
    movlw   0x00
    movwf   TRISD, A ;output- for traffic lights set 1
    movlw   0x00
    movwf   TRISJ, A ;output- for traffic lights set 2
    movlw   0x00
    movwf   TRISH, A  ;Setting the pedestrian crossing to be an output
    movlw   0x03
    movwf   TRISE, A ;pins 1 and 2 input, 3 output- external buttons and button lights
    movlb   0xF
    bsf     REPU
    clrf    LATE
;    
;    movlw   0xFF ;set up buzzer with ccp4- extension method
;    movwf   PR2 ;set the period
;    movlw   0xFF
;    movwf   CCPR4L;set duty cycle
;    movlw   0xFF
;    movwf   CCP4CON;extra duty cycle bits
;    clrf    TRISC,A; clear approprite tris bits
;    clrf    TRISB,A
;    movlw   0xFF; set prescaler
;    movwf   TMR2
;    movlw   0xFF; enable timer2
;    movwf   T2CON
    ;configure CCp4 module
        
    return
Traffic_Lights_Light_pattern:;standard traffic light sequence
       movlw 0x04
    movwf LATH, A    ;Setting the pedestrian crossing to red as default
    movlw  0x09;red
    movwf  LATD, A
     
    movlw  0x03; red and orange
    movwf  LATJ, A
    call   delay
    
    movlw  0x04; green
    movwf  LATJ, A
    call   delay
    movlw  0x02; orange
    movwf  LATJ, A    
    call   delay
    
    movlw  0x01; red 
    movwf  LATJ, A
    ;call   delay   
    call   crossing   
red_orange:
    movlw  0x1B; red and orange
    movwf  LATD, A
    call   delay
   
    movlw  0x24; green
    movwf  LATD, A
    call   delay
    movlw  0x12; orange
    movwf  LATD, A
    call   delay 
    return    

delay:	
       ; call    check_photodiode ;uncommement to use photodiode to detect person
	movlw	0x23 ;set length of delay
	movwf	0x01
	movlw	0xC2
	movwf	0x02
	movlw	0x46
	movwf	0x03
Delay_0:
        call    Button
	;call    Other_Button
	decfsz	0x01, f ;loop until zero
	goto	loop1
	decfsz	0x02, f
loop1:	goto	loop2
	decfsz	0x03, f
loop2:	goto	Delay_0			;2 cycles
	;goto	$+1			;4 cycles (including call)
	return
    
end    


