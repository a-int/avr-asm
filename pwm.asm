.include "m32def.inc"
;������� 1
reset:
	cli; ���� i=0 ��� ���������� ���������
	ldi r16, 0x04 ; ������ Stack Pointer size High 
	out SPH, r16
	ldi r16, 0x5f; ������ Stack Pointer size Low
	out SPL, r16
	
	ldi r16, 0x00; ������ 0 � ������� TCNT0
	out TCNT0, r16
	ldi r16, 0x19; ������ ����� 25(10) � OCR0. 510*5% - 1 = 24.5 = 25 
	out OCR0, r16
	ldi r20, 0x28; ������� ���������� T/C0
	ldi r16, 0b11100001; ������ �/�0 � ������ Phase Corret non-inverted � ������������� 1
	out TCCR0, r16
	ldi r16, 0b00000000; ���������� ���������� �� ���������� T/C0 � OCR0
	out TIMSK, r16
	out TIFR, r16; ����� ����� OCF0

	ldi r16, 0xff
	out DDRB, r16
	out PORTB, r16

	sei

main: nop
	rjmp main
