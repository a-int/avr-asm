.include "m32def.inc"
.org 0
	jmp reset ; вектор прерывания по сброрсу
	jmp int_0 ; вектор прерывания по внешнему входу INT0
	jmp int_1 ; вектор прерывания по внешнему входу INT1
	jmp int_2 ; вектор прерывания по внешнему входу INT2
	jmp timer2_comp ; вектор прерывания по совпадению T/C2
	jmp timer2_ovf ; вектор прерывания по переполнению T/C2
	jmp timer1_capt ; вектор прерывания по захвату T/C1
	jmp timer1_compa ; вектор прерывания по совпадению T/C1A
	jmp timer1_compb ; вектор прерывания по совпадению T/C1B
	jmp timer1_ovf ; вектор прерывания по переполнению T/C2
	jmp timer0_comp ; вектор прерывания по совпадению T/C0
	jmp timer0_ovf ; вектор прерывания по переполнению T/C2
	jmp spi_cts ; вектор прерывания по окончанию обмена SPI
	jmp usart_rxc ; вектор прерывания по окончанию приема USART
	jmp usart_udre ; вектор прерывания когда UDR передатчика ...
	jmp usart_txc ; вектор прерывания по окончании передачи USART
	jmp a_d_c ; вектор прерывания по окончании преобразовании АЦП
	jmp ee_rdy ; вектор прерывания по готовности EEPROM
	jmp ana_comp ; вектор прерывания от аналогового компаратора
	jmp t_w_i ; вектор прерывания по окончании обмена TWI
	jmp spm_rdy ; вектор прерывания по готовности SPM

; ПОДПРОГРАММА ИНИЦИАЛИЗАЦИИ
reset:
	cli; флаг i=0 все прерывания запрещены
	ldi r16, 0x04 ; задаем Stack Pointer size High 
	out SPH, r16
	ldi r16, 0x5f; задаем Stack Pointer size Low
	out SPL, r16
	
	rcall tc0_init; вызов подпрограммы инициализации таймер-счетчика 0
	rcall port_init; вызов подпрограммы инициализации портов
	sei; флаг i=1 все прерывания разрешены
; ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ
main: nop
	
	rjmp main
;ПОДПРОГРАММЫ
tc0_init:
	ldi r16, 0x00; запись 0 в регистр TCNT0
	out TCNT0, r16
	ldi r16, 0xF0; запись числа 240(256-16) в OCR0
	out TCNT0, r16
	ldi r20, 0x28; счетчик совпадений T/C0
	ldi r16, 0b00000010; запуск Т/С0 в режиме СТС и предделителем 8
	out TCCR0, r16
	ldi r16, 0b00000001; разрешение прерывания по совпадению T/C0 и OCR0
	out TIMSK, r16
	out TIFR, r16; сброс флага OCF0
	ret

port_init:
	; настройка линий порта В на выход
	ldi r16, 0xff
	out DDRB, r16
	out PORTB, r16
	ret

timer0_ovf:
	dec r20
	brne exit
	ldi r20, 0x28
	ldi r16, 0xf0
	out TCNT0, r16
	in r16, PORTB
	com r16
	out PORTB, r16
exit: reti

int_0:
int_1:
int_2:
timer2_comp:
timer2_ovf:
timer1_capt:
timer1_compa:
timer1_compb:
timer1_ovf:
;timer0_ovf:
timer0_comp:
spi_cts:
usart_rxc:
usart_udre:
usart_txc:
a_d_c:
ee_rdy:
ana_comp:
t_w_i:
spm_rdy: reti


