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
	
	; Настройка Порта В
	ldi r16, 0xff ; настройка линий порта В на выход
	out DDRB, r16
	out PORTB, r16
	
	;настройка Таймер-Счетчика 1
	ldi r16, 0x00
	out TCNT1H, r16; очистка таймер счетчика 1
	out TCNT1L, r16
	out TCCR1A, r16
	ldi r16, 0b00000010
	out TCCR1B, r16; установка режима Нормал и предделителя на 8
	ldi r16, 0b00001000
	out TIMSK,r16 ;прерывание по совпадению с В
	out TIFR, r16 ; сброс флага OCR1A
	
	ldi r16, 0x2A
	out OCR1BH, r16; запись старшей части числа 10800
	ldi r16, 0x2F
	out OCR1BL, r16; запись младшей части числа 10800
	
	ldi r20, 0x0A ; запись константы в регистр-счетчик
	ldi r21, 0x00; режим работы светодиода
	ldi r16, 0x80 ; установка начального значения для порта В
	out PORTB, r16 ; запись начального значения в порт В
	sei; флаг i=1 все прерывания разрешены

; ОСНОВНАЯ ЧАСТЬ ПРОГРАММЫ
main: nop
	rjmp main

timer1_compb:
	ldi r16, 0x00
	out TCNT1H, r16; очистка таймер счетчика 1
	out TCNT1L, r16 

	dec r20; дикремент регистра R20
	brne exit ; выход если пройденное время < 108 мс
	ldi r20, 0x0A; восстановление начального значения регистр-счетчика
	
	in r16, PORTB ; считывание значения с порта В
	
	cpi r21, 0x00; проверка работы отображения
	brne roll; переход в режим отображения справа-налево
	ror r16; циклический поворот вправо
	brcc m1; выход если нге дошел до края
	rol r16
	ldi r21, 0x01; установка следующиего режима

roll:
	rol r16; циклический поворот влево
	brcc exit; выход если край не достигнут
	ror r16
	ldi r21, 0x00; установка следующего режима
m1:out PORTB, r16; запись следующей комбинации	
exit:reti


int_0:
int_1:
int_2:
timer2_comp:
timer2_ovf:
timer1_capt:
timer1_compa:
;timer1_compb:
timer1_ovf:
timer0_comp:
timer0_ovf:
spi_cts:
usart_rxc:
usart_udre:
usart_txc:
a_d_c:
ee_rdy:
ana_comp:
t_w_i:
spm_rdy: reti


