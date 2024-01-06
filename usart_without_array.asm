.include "m32def.inc"
.org 0
	jmp reset ; ������ ���������� �� �������
	jmp int_0 ; ������ ���������� �� �������� ����� INT0
	jmp int_1 ; ������ ���������� �� �������� ����� INT1
	jmp int_2 ; ������ ���������� �� �������� ����� INT2
	jmp timer2_comp ; ������ ���������� �� ���������� T/C2
	jmp timer2_ovf ; ������ ���������� �� ������������ T/C2
	jmp timer1_capt ; ������ ���������� �� ������� T/C1
	jmp timer1_compa ; ������ ���������� �� ���������� T/C1A
	jmp timer1_compb ; ������ ���������� �� ���������� T/C1B
	jmp timer1_ovf ; ������ ���������� �� ������������ T/C2
	jmp timer0_comp ; ������ ���������� �� ���������� T/C0
	jmp timer0_ovf ; ������ ���������� �� ������������ T/C2
	jmp spi_cts ; ������ ���������� �� ��������� ������ SPI
	jmp usart_rxc ; ������ ���������� �� ��������� ������ USART
	jmp usart_udre ; ������ ���������� ����� UDR ����������� ...
	jmp usart_txc ; ������ ���������� �� ��������� �������� USART
	jmp a_d_c ; ������ ���������� �� ��������� �������������� ���
	jmp ee_rdy ; ������ ���������� �� ���������� EEPROM
	jmp ana_comp ; ������ ���������� �� ����������� �����������
	jmp t_w_i ; ������ ���������� �� ��������� ������ TWI
	jmp spm_rdy ; ������ ���������� �� ���������� SPM

; ������������ �������������
reset:
	cli; ���� i=0 ��� ���������� ���������
	ldi r16, 0x04 ; ������ Stack Pointer size High 
	out SPH, r16
	ldi r16, 0x5f; ������ Stack Pointer size Low
	out SPL, r16

	ldi r16, 0x02
	out DDRD, r16 ; ��������� PD1-PD0 �� ����� � ���� ��������������
;��������� USART
	ldi r16, 0x00 ; ��������� BAUD = 9600 ���/� ��� F = 16 ���, 0,15625% �����������
	out UBRRH, r16
	ldi r16, 0x67
	out UBRRL, r16 ; ������ ����� 103(104,16 - 1) � UBRR
	ldi r16, 0b10110100; ����� UCSRC � ��������� ������� ������� (7 ���), ��� ���������� � ���� ���� ���
	out UCSRC, r16
	ldi r16, 0b00011000; 
	out UCSRB, r16; ��������� �������� � ������
	ldi r16, 0x00
	out UCSRA, r16; ������� ������
	sei; ���������� ������ ����������

main: nop
	sbic UCSRA, 7; �������� ����� ������� ������ � �������� UDR(recieve)
	rcall peredacha_PK ; ����� ������������ �������� ������ USART
	rjmp main ; ������� � ������ ���������

peredacha_PK:
	in r16, UDR
	nop
wait_0: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_0
	out UDR, r9 ; �������  ������ �� �������� r9 � ������� UDR(transmit)
	nop
wait_1: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_1
	out UDR, r10 ; �������  ������ �� �������� r10 � ������� UDR(transmit)
	nop
wait_2: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_2
	out UDR, r11 ; �������  ������ �� �������� r11 � ������� UDR(transmit)
	nop
wait_3: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_3
	out UDR, r12 ; �������  ������ �� �������� r12 � ������� UDR(transmit)
	nop
wait_4: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_4
	ret ; ������� �� ������������


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
