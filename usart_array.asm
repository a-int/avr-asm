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

	ldi r16, 0x02
	out DDRD, r16 ; установка PD1-PD0 на выход и вход соответственно
;настройка USART
	ldi r16, 0x00 ; Настройка BAUD = 9600 бит/с при F = 16 МГц, 0,15625% погрешность
	out UBRRH, r16
	ldi r16, 0x67
	out UBRRL, r16 ; запись числа 103(104,16 - 1) в UBRR
	ldi r16, 0b10110100; выбор UCSRC и установка размера посылки (7 бит), бит нечетности и один стоп бит
	out UCSRC, r16
	ldi r16, 0b00011000; 
	out UCSRB, r16; включение отправки и приема
	ldi r16, 0x00
	out UCSRA, r16; очистка флагов
	sei; разрешение работы прерываний

main: nop
	sbic UCSRA, 7; проверка флага наличия данных в регистре UDR(recieve)
	rcall peredacha_PK ; вызов подпрограммы проверки работы USART
	rjmp main ; переход в начало программы

peredacha_PK:
	in r16, UDR
	nop
wait_0: sbis UCSRA, 5 ; проверка на то, пуст ли регистр UDR
	rjmp wait_0

	ldi R27, 0x0 ; установка сташего байта начального адреса( регитср r9)
	ldi R26, 0x9 ; установка младшего байта начального адреса( регитср r9)
	;push r12 ; сохранение данных из регистра r12
	;push r11 ; сохранение данных из регистра r11
	;push r10 ; сохранение данных из регистра r10
	;push r9 ; сохранение данных из регистра r9
	ldi r16, 0x04 ; запись кол-ва регистров для отправки
while:
	;pop r17
	ld r17, X+; считывание данных из следующего регистра
	out UDR, r17 ; отправка данных в регистр UDR(transmit)
wait: sbis UCSRA, 5 ; проверка на то, пуст ли регистр UDR
	rjmp wait
	dec r16 ; уменьшение кол-ва оставшихся элементов
	brne while ; переход в начало цикла, если остались элементы
	nop
	ret; возврат из функции подпрограммы


int_0:
int_1:
int_2:
timer2_comp:
timer2_ovf:
timer1_capt:
timer1_compa:
timer1_compb:
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
