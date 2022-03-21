#include <xc.inc>

global  ADC_Setup, ADC_Read, ADC_multiply_16_16  

psect	udata_acs   ; reserve data space in access ram
ARG1H: ds 1
ARG2H: ds 1
ARG1L: ds 1
ARG2L: ds 1
RES0: ds 1
RES1: ds 1
RES2: ds 1
RES3: ds 1 

psect	adc_code, class=CODE
ADC_Setup:
	bsf	TRISA, PORTA_RA0_POSN, A  ; pin RA0==AN0 input
	banksel ANCON0
	;movlb	0x0f
	bsf	ANSEL0	    ; set AN0 to analog
	banksel 0
	;movlb	0x00
	movlw   0x01	    ; select AN0 for measurement
	movwf   ADCON0, A   ; and turn ADC on
	movlw   0x30	    ; Select 4.096V positive reference
	movwf   ADCON1,	A   ; 0V for -ve reference and -ve input
	movlw   0xF6	    ; Right justified output
	movwf   ADCON2, A   ; Fosc/64 clock and acquisition times
	return

ADC_Read:
	bsf	GO	    ; Start conversion by setting GO bit in ADCON0
;	movf    ADRESH, W, A ;multiply 12 bit hex by k (0x418A) 12bit by 16bit=
;	movwf   ARG1H
;	movf    ADRESL, W, A
;	movwf   ARG1L
;	
;	movlw   0x41 ;set k
;	movwf   ARG2H
;	movlw   0x8A
;	movwf   ARG2L
;	bra     ADC_multiply_16_16; multiply
;	
;	RLCF    RES1, 0, 0 
	;movlw   0x100
	;ANDWF   RES3
	
	
adc_loop:
	btfsc   GO	    ; check to see if finished
	bra	adc_loop
	return
ADC_multiply_16_16:	        
	MOVF ARG1L, W
	MULWF ARG2L ; ARG1L * ARG2L-> ; PRODH:PRODL
	MOVFF PRODH, RES1 ;
	MOVFF PRODL, RES0 ;
	;
	MOVF ARG1H, W
	MULWF ARG2H ; ARG1H * ARG2H-> ; PRODH:PRODL
	MOVFF PRODH, RES3 ;
	MOVFF PRODL, RES2 ;
	;
	MOVF ARG1L, W
	MULWF ARG2H ; ARG1L * ARG2H-> ; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
	
	MOVF ARG1H, W ;
	MULWF ARG2L ; ARG1H * ARG2L-> ; PRODH:PRODL
	MOVF PRODL, W ;
	ADDWF RES1, F ; Add cross
	MOVF PRODH, W ; products
	ADDWFC RES2, F ;
	CLRF WREG ;
	ADDWFC RES3, F ;
;		
        return

end
