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
	
	; ��������� ����� �
	ldi r16, 0xff ; ��������� ����� ����� � �� �����
	out DDRB, r16
	out PORTB, r16
	
	;��������� ������-�������� 1
	ldi r16, 0x00
	out TCNT1H, r16; ������� ������ �������� 1
	out TCNT1L, r16
	out TCCR1A, r16
	ldi r16, 0b00000010
	out TCCR1B, r16; ��������� ������ ������ � ������������ �� 8
	ldi r16, 0b00001000
	out TIMSK,r16 ;���������� �� ���������� � �
	out TIFR, r16 ; ����� ����� OCR1A
	
	ldi r16, 0x2A
	out OCR1BH, r16; ������ ������� ����� ����� 10800
	ldi r16, 0x2F
	out OCR1BL, r16; ������ ������� ����� ����� 10800
	
	ldi r20, 0x0A ; ������ ��������� � �������-�������
	ldi r21, 0x00; ����� ������ ����������
	ldi r16, 0x80 ; ��������� ���������� �������� ��� ����� �
	out PORTB, r16 ; ������ ���������� �������� � ���� �
	sei; ���� i=1 ��� ���������� ���������

; �������� ����� ���������
main: nop
	rjmp main

timer1_compb:
	ldi r16, 0x00
	out TCNT1H, r16; ������� ������ �������� 1
	out TCNT1L, r16 

	dec r20; ��������� �������� R20
	brne exit ; ����� ���� ���������� ����� < 108 ��
	ldi r20, 0x0A; �������������� ���������� �������� �������-��������
	
	in r16, PORTB ; ���������� �������� � ����� �
	
	cpi r21, 0x00; �������� ������ �����������
	brne roll; ������� � ����� ����������� ������-������
	ror r16; ����������� ������� ������
	brcc m1; ����� ���� ��� ����� �� ����
	rol r16
	ldi r21, 0x01; ��������� ����������� ������

roll:
	rol r16; ����������� ������� �����
	brcc exit; ����� ���� ���� �� ���������
	ror r16
	ldi r21, 0x00; ��������� ���������� ������
m1:out PORTB, r16; ������ ��������� ����������	
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


