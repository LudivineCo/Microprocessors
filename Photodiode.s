#include <xc.inc>

global photo_diode_setup
extrn  ADC_Setup,ADC_Read
    
    
psect	uart_code,class=CODE
    
photo_diode_setup:
    movlw 0x01
    movwf TRISF ,A
    call ADC_Setup
return
    
    
;check_photodiode:
;    call ADC_Read ;check person if there
;    movlw 300
;    movlb 0x0F
;    CPFSLT ADRESL, 0
;    return; no one there- cancel
;    movlw  0x01; someone there-press button
;    movwf  Buttons,A;button pressed  
;    return
    


end
