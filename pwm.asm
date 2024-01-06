.include "m32def.inc"
;вариант 1
reset:
	cli; флаг i=0 все прерывания запрещены
	ldi r16, 0x04 ; задаем Stack Pointer size High 
	out SPH, r16
	ldi r16, 0x5f; задаем Stack Pointer size Low
	out SPL, r16
	
	ldi r16, 0x00; запись 0 в регистр TCNT0
	out TCNT0, r16
	ldi r16, 0x19; запись числа 25(10) в OCR0. 510*5% - 1 = 24.5 = 25 
	out OCR0, r16
	ldi r20, 0x28; счетчик совпадений T/C0
	ldi r16, 0b11100001; запуск Т/С0 в режиме Phase Corret non-inverted и предделителем 1
	out TCCR0, r16
	ldi r16, 0b00000000; разрешение прерывания по совпадению T/C0 и OCR0
	out TIMSK, r16
	out TIFR, r16; сброс флага OCF0

	ldi r16, 0xff
	out DDRB, r16
	out PORTB, r16

	sei

main: nop
	rjmp main
