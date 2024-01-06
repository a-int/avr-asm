.include "m32def.inc"
.EQU SDI = 2
.EQU SCKI = 4
.EQU ADC_PORT = PORTC
.EQU CONV = 3
.EQU BUSY = 1
.EQU SDO = 0
.EQU ADC_PIN = PINC

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

	clr r16
	out DDRA, r16 ; настройка PA0-4 (ДКД1-5) на вход
	ldi r16, 0b00100000
	out DDRB, r16 ; PB7-6(SCK, MISO) - на вход
			; PB5 (MOSI) - на выход
	ldi r16, 0b00011100; 
	out DDRC, r16; настройка порта С 
						; На вход:
						; PC0(SDO), PC1(BUSY)
						; На вход:

						; PC2(SDI), PC3(CNV), PC4(SCKI)
	ldi r16, 0b00000010
	out DDRD, r16 ; PD0(RX) - на вход
		      ; PD1 (TX) - на выход
	
	;настройка USART
	ldi r16, 0x00 ; Настройка BAUD = 9600 бит/с при F = 8 МГц, 0,15625% погрешность
	out UBRRH, r16
	ldi r16, 0x33
	out UBRRL, r16 ; запись числа 51(52,08 - 1) в UBRR
	ldi r16, 0b10000110; выбор UCSRC и установка размера посылки (8 бит), без бита проверки и один стоп бит
	out UCSRC, r16
	ldi r16, 0b00011000; 
	out UCSRB, r16; включение отправки и приема
	ldi r16, 0x00
	out UCSRA, r16; очистка флагов
	sei
	
main:
	;sbis UCSRA, 7 ; проверка бита 
	;rjmp main ; переход в начало подпрограммы, если нет запроса
	
	rcall get_linear
	rcall get_nonlinear
	rcall get_dkd
	rcall peredacha_PK

	rjmp main 

get_linear:
	rcall adc_conv_linear ; получение кода АЦП для линейного датчика
	rcall adc_convert_result_linear ; преобразование кода АЦП в значение от линейного датчика
	ret

get_nonlinear:
	rcall adc_conv_nonlinear ; получение кода АЦП для нелинейного датчика
	rcall adc_convert_result_nonlinear ; преобразование кода АЦП в значение от нелинейного датчика
	ret

get_dkd:
	clr r17 ; предварительная очистка регистров
	clr r18
	clr r19
	clr r20
	clr r21
	
	in r16, PINA ; считывание актуального состояния ПОРТА D
	sbis PINA, 0 ; проверка ДКД1
	ldi r17, 0x01 ; установка срабатывания ДКД1
	sbis PINA, 1 ; проверка ДКД1
	ldi r18, 0x01 ; установка срабатывания ДКД1
	sbis PINA, 2 ; проверка ДКД1
	ldi r19, 0x01 ; установка срабатывания ДКД1
	sbis PINA, 3 ; проверка ДКД1
	ldi r20, 0x01 ; установка срабатывания ДКД1
	sbis PINA, 4 ; проверка ДКД1
	ldi r21, 0x01 ; установка срабатывания ДКД1
	
	sts $0610, r17 ; сохранение результатов ДКД1
	sts $0611, r18 ; сохранение результатов ДКД2
	sts $0612, r19 ; сохранение результатов ДКД3
	sts $0613, r20 ; сохранение результатов ДКД4
	sts $0614, r21 ; сохранение результатов ДКД5
	ret

peredacha_PK:
	in r16, UDR
	nop
wait_0: sbis UCSRA, 5 ; проверка на то, пуст ли регистр UDR
	rjmp wait_0

	ldi R27, 0x06 ; установка сташего байта начального адреса( регитср r9)
	ldi R26, 0x00 ; установка младшего байта начального адреса( регитср r9)
	ldi r16, 0x11 ; запись кол-ва регистров для отправки
while:
	ld r17, X+; считывание данных из следующего регистра
	out UDR, r17 ; отправка данных в регистр UDR(transmit)
wait: 
	sbis UCSRA, 5 ; проверка на то, пуст ли регистр UDR
	rjmp wait
	dec r16 ; уменьшение кол-ва оставшихся элементов
	brne while ; переход в начало цикла, если остались элементы
	nop
	
	ret; возврат из функции подпрограммы

adc_conv_linear:
	ldi r31, 0x00	; select linear channel
	rcall adc_setup
	rcall adc_conv
	sts $0600, r1 ; сохранение старшего байта в адрес данных ДДЛ
	sts $0601, r0 ; сохранение младшего байта в адрес данных ДДЛ
	ret

adc_convert_result_linear:
	ldi r18, 0x1F ;константа для перемножения (K) 
	ldi r19, 0x1A ; 16 718 367
	ldi r20, 0xFF
	ldi r26, 0x00 ; младшая часть адреса числа P
	ldi r27, 0x06 ; старшая часть адреса числа P
	ld r24, X+    ; сохранение старшей части числа P
	ld r23, X    ; сохранение младшей части числа P
	rcall mul3x2 ; умножение кода АЦП на константу К
	
	ldi r16, 0x59 ; запись константы В в доп коде
	ldi r17, 0x1f
	ldi r18, 0x1a
	ldi r19, 0xeb
	ldi r20, 0xfb
	ldi r21, 0xff
	rcall AddB ; прибавление константы В к результату перемножения

	ldi r26, 0x05 ; сохранение младшего байта адреса для сохранения
	ldi r27, 0x06 ; сохранение старшего байта адреса для сохранения
	st X+, r31 ; сохранение знака числа
	st X+, r4     ; запись первого байта результата 
	st X+, r3     ; запись второго байта результата
	st X+, r2     ; запись третьего байта для результата
	st X+, r1     ; запись четвертого байта для результата
	st X+, r0     ; запись пятого байта для результата

	ret ; переход в начало программы
	
adc_conv_nonlinear:
	ldi r31, 0x01 ; select non linear channel
	rcall adc_setup
	rcall adc_conv
	sts 0x0602, r0 ; сохранение старшего байта в адрес данных ДДН
	sts 0x0603, r1 ; сохранение младшего байта в адрес данных ДДН
	ret

adc_convert_result_nonlinear:
	lds r16, 0x0602 ; получение старшего байта кода АЦП для нелинейного датчика
	swap r16 ; перестановка тетрад местами
	andi r16, 0x0F ; зануление старшей тетрады
	
	; умножение р16 на 8 чтобы определить сдвиг для интервала
	lsl r16
	lsl r16
	lsl r16

	ldi r31, high(tablKiB*2)
	ldi r30, low(tablKiB*2)
	
	clr r1
	add r30, r16
	adc r31, r1

	lpm r20, Z+ ; считывание  константы К из ПЗУ
	lpm r19, Z+
	lpm r18, Z+

	lds r24, 0x0602    ; сохранение старшей части числа P
	lds r23, 0x0603    ; сохранение младшей части числа P

	rcall mul3x2

	clr r21
	lds r16, $0602
	cpi r16, 0x00
	brne nonlinearB
	ldi r21, 0xff
nonlinearB:
	lpm r20, Z+ ; считывание константы В из ПЗУ устройства
	lpm r19, Z+
	lpm r18, Z+
	lpm r17, Z+
	lpm r16, Z+

	rcall AddB

	ldi r26, 0x0B ; сохранение младшего байта адреса для сохранения
	ldi r27, 0x06 ; сохранение старшего байта адреса для сохранения
	st X+, r31 ; сохранение знака числа
	st X+, r4     ; запись первого байта результата 
	st X+, r3     ; запись второго байта результата
	st X+, r2     ; запись третьего байта для результата
	st X+, r1     ; запись четвертого байта для результата
	st X+, r0     ; запись пятого байта для результата

	ret ; переход в начало программы
	
adc_setup:
	;установить режим для следующего преобразования линейного датчика
	; 8 бит - настройка и еще 8 бит для корректного завершения окна записи
	; время периода на SCKI минимум 10 нс
	ldi r16, 0b10000001 ; утсноавка режима Softspan от 0 до 5 В
						; и выбор нулевого канала (линейный датчик давления)
	sbi ADC_PORT, SDI		; установка V = 1 (передаваемый пакет валидный)
	sbi ADC_PORT, SCKI		; передача бита по линии SDI(PC2)
	cbi ADC_PORT, SDI
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; передача нуля по линии SDI(PC2)
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; передача CH[2]
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; передача CH[1]
	nop
	cbi ADC_PORT, SCKI		
	cpi r31, 0x01
	brcs selectChannel		; jmp to selection of default channel (0)
	sbi ADC_PORT, SDI		; set ch1(non linear) if r0 = 1
selectChannel:
	sbi ADC_PORT, SCKI		; передача CH[0]
	cbi ADC_PORT, SDI		; set SDI low
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; передача SS[2]	
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; передача SS[1]
	nop
	cbi ADC_PORT, SCKI		
	sbi ADC_PORT, SDI		
	sbi ADC_PORT, SCKI
	cbi ADC_PORT, SDI
	cbi ADC_PORT, SCKI
	ldi r16, 0x8
rest8bit:	; согласно даташиту минимальный размер обмена 16 бит
	sbi ADC_PORT, SCKI
	dec r16
	cbi ADC_PORT, SCKI
	brne rest8bit

	ret ; возврат из подпрограммы

adc_conv:
	sbi ADC_PORT, CONV ; установка единицы в conv (t cnv high мин 40 нс)
	cbi ADC_PORT, SDI ; установка нуля, так производится только чтение АЦП
	sbi ADC_PORT, SCKI ; нач значение SCKI
	nop
	cbi ADC_PORT, CONV ; установка нуля в CONV

waitBusy:
	sbic ADC_PIN, BUSY ; проверка флага BUSY
	rjmp waitBusy ; ожидание пока BUSY установлен
	
	sbi ADC_PORT, SCKI ; нач значение SCKI
	clr r0 ; очистка регистра хранения результата младший байт
	clr r1 ; очистка регистра хранения результата старший байт
	ldi r17, 0x10 ; сохранение кол-ва битов в результате
readADC:
	cbi ADC_PORT, SCKI ; считывание следующего бита с АЦП
	nop
	in R16, ADC_PIN ; чтение значения на линии
	ror r16 ; перенос полученного бита в флаг С
	rol r0 ; продвижение бита msb first
	rol r1 ; продвижение бита msb first

	sbi ADC_PORT, SCKI ; выталкивание следующего бита
	dec r17 ; уменьшение оставшегося кол-ва бит
	brne readADC

	nop ; t quiet минимум 20 нс
	ret

mul3x2:
	clr r0 			; очистка регистра р0 для сохранения результата
	clr r1 			; очистка регистра р1 для сохранения результата
	clr r2			; очистка регистра р2 для сохранения результата
	clr r3			; очистка регистра р3 для сохранения результата 
	clr r4			; очистка регистра р4 для сохранения результата

	clr r21			; очистка доп регистра для сдвига множимого
	clr r22			; очистка доп регистра для сдвига множимого
	ldi r16, 0x10		; сохранения колличества битов в множителе
n1:				
	lsr r24			; сдвиг старшего байта множителя вправо
	ror r23			; цикличиский свдиг младшего байта множимого вправо
	brcc sdv		; если бит в флаге С = 0 то пропуск
	add r0, r18		; прибавление младшего байта множимого
	adc r1, r19		; прибавление второго байта множимого
	adc r2, r20		; прибавление третьего байта множимого
	adc r3, r21		; прибавление четвертого байта множимого
	adc r4, r22		; прибавление пятого байта множимого
sdv:
	lsl r18			; сдиви младшего байта множимого влево
	rol r19			; сдвиг второго байта множимого влево
	rol r20			; сдвиг третьего байта множимого влево
	rol r21			; сдвиг четвертого байта множимого влево
	rol r22			; сдвиг пятого байта множимого влево
	dec r16			; уменьшение оставшегося кол-ва битов в множителе
	brne n1			; если остались биты переход в начало цикла

	ret

AddB:	
	clr r5; очистка регистра который будет использоваться под 6 байт
	add r0, r16 ; сложение двух чисел
	adc r1, r17
	adc r2, r18
	adc r3, r19
	adc r4, r20
	adc r5, r21

	clr r31 ; очистка регистра под знак
	mov r16, r5 ; копирование старшего байта
	rol r16 ; циклический сдвиг влево для проверки знака
	brcc exit ; если старший бит был ноль то число четное, переход к сохранению числа
	ldi r16, 0x01 ; сохранение единицы для перехода к прямому коду
	clr r17 ; создание нулевого регистра
	sub r0, r16 ; вычитание единицы из младшего байта 
	sbc r1, r17 ; вычитание с учетом переноса
	sbc r2, r17 ; вычитание с учетом переноса
	sbc r3, r17 ; вычитание с учетом переноса
	sbc r4, r17 ; вычитание с учетом переноса
	
	com r0 ; инверсия байта 
	com r1 ; инверсия байта 
	com r2 ; инверсия байта 
	com r3 ; инверсия байта 
	com r4 ; инверсия байта 
	ldi r31, 0x01 ; сохранение единцы в регистр р31(потмоу что число отрицательное)
exit:
	ret

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

tablKib:
	.db 0x10, 0xd1
	.db 0x7f, 0xff
	.db 0xc8, 0x2f
	.db 0xb7, 0xcc

	.db 0x10, 0x71
	.db 0x13, 0x10
	.db 0x99, 0xaf
	.db 0x1d, 0xdc

	.db 0x10, 0x24
	.db 0x3d, 0x21
	.db 0x0a, 0xc2
	.db 0x79, 0xee

	.db 0x0f, 0xe8
	.db 0x0a, 0x31
	.db 0x2e, 0xff
	.db 0xf7, 0x6d

	.db 0x0f, 0xba
	.db 0x5f, 0x41
	.db 0x17, 0x09
	.db 0xca, 0xed

	.db 0x0f, 0x99
	.db 0xc3, 0x50
	.db 0xd1, 0x68
	.db 0xbb, 0x6d
	
	.db 0x0f, 0x85
	.db 0x39, 0x60
	.db 0x6b, 0x2c
	.db 0x24, 0x40

	.db 0x0f, 0x7c
	.db 0x26, 0x6f
	.db 0xf0, 0x65
	.db 0x21, 0xbc

	.db 0x0f, 0x7e
	.db 0x47, 0x7f
	.db 0x6c, 0x8a
	.db 0xf4, 0x7b

	.db 0x0f, 0x8b
	.db 0xad, 0x8e
	.db 0xea, 0xd2
	.db 0x68, 0x40

	.db 0x0f, 0xa4
	.db 0xba, 0x9e
	.db 0x76, 0x7f
	.db 0xcf, 0x50

	.db 0x0f, 0xca
	.db 0x2d, 0xae
	.db 0x1b, 0x3a
	.db 0x3f, 0x59

	.db 0x0f, 0xfd
	.db 0x2e, 0xbd
	.db 0xe5, 0x66
	.db 0xf1, 0x13

	.db 0x10, 0x3f
	.db 0x70, 0xcd
	.db 0xe2, 0x94
	.db 0xfe, 0xb7

	.db 0x10, 0x93
	.db 0x56, 0xde
	.db 0x22, 0x04
	.db 0xa1, 0xe7

	.db 0x10, 0xfc
	.db 0x3e, 0xee
	.db 0xb5, 0x5a
	.db 0x64, 0x3d
	
