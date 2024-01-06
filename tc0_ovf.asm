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
	
	rcall tc0_init; ����� ������������ ������������� ������-�������� 0
	rcall port_init; ����� ������������ ������������� ������
	sei; ���� i=1 ��� ���������� ���������
; �������� ����� ���������
main: nop
	
	rjmp main
;������������
tc0_init:
	ldi r16, 0x00; ������ 0 � ������� TCNT0
	out TCNT0, r16
	ldi r16, 0xF0; ������ ����� 240(256-16) � OCR0
	out TCNT0, r16
	ldi r20, 0x28; ������� ���������� T/C0
	ldi r16, 0b00000010; ������ �/�0 � ������ ��� � ������������� 8
	out TCCR0, r16
	ldi r16, 0b00000001; ���������� ���������� �� ���������� T/C0 � OCR0
	out TIMSK, r16
	out TIFR, r16; ����� ����� OCF0
	ret

port_init:
	; ��������� ����� ����� � �� �����
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


