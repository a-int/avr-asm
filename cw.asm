.include "m32def.inc"
.EQU SDI = 2
.EQU SCKI = 4
.EQU ADC_PORT = PORTC
.EQU CONV = 3
.EQU BUSY = 1
.EQU SDO = 0
.EQU ADC_PIN = PINC

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

	clr r16
	out DDRA, r16 ; ��������� PA0-4 (���1-5) �� ����
	ldi r16, 0b00100000
	out DDRB, r16 ; PB7-6(SCK, MISO) - �� ����
			; PB5 (MOSI) - �� �����
	ldi r16, 0b00011100; 
	out DDRC, r16; ��������� ����� � 
						; �� ����:
						; PC0(SDO), PC1(BUSY)
						; �� ����:

						; PC2(SDI), PC3(CNV), PC4(SCKI)
	ldi r16, 0b00000010
	out DDRD, r16 ; PD0(RX) - �� ����
		      ; PD1 (TX) - �� �����
	
	;��������� USART
	ldi r16, 0x00 ; ��������� BAUD = 9600 ���/� ��� F = 8 ���, 0,15625% �����������
	out UBRRH, r16
	ldi r16, 0x33
	out UBRRL, r16 ; ������ ����� 51(52,08 - 1) � UBRR
	ldi r16, 0b10000110; ����� UCSRC � ��������� ������� ������� (8 ���), ��� ���� �������� � ���� ���� ���
	out UCSRC, r16
	ldi r16, 0b00011000; 
	out UCSRB, r16; ��������� �������� � ������
	ldi r16, 0x00
	out UCSRA, r16; ������� ������
	sei
	
main:
	;sbis UCSRA, 7 ; �������� ���� 
	;rjmp main ; ������� � ������ ������������, ���� ��� �������
	
	rcall get_linear
	rcall get_nonlinear
	rcall get_dkd
	rcall peredacha_PK

	rjmp main 

get_linear:
	rcall adc_conv_linear ; ��������� ���� ��� ��� ��������� �������
	rcall adc_convert_result_linear ; �������������� ���� ��� � �������� �� ��������� �������
	ret

get_nonlinear:
	rcall adc_conv_nonlinear ; ��������� ���� ��� ��� ����������� �������
	rcall adc_convert_result_nonlinear ; �������������� ���� ��� � �������� �� ����������� �������
	ret

get_dkd:
	clr r17 ; ��������������� ������� ���������
	clr r18
	clr r19
	clr r20
	clr r21
	
	in r16, PINA ; ���������� ����������� ��������� ����� D
	sbis PINA, 0 ; �������� ���1
	ldi r17, 0x01 ; ��������� ������������ ���1
	sbis PINA, 1 ; �������� ���1
	ldi r18, 0x01 ; ��������� ������������ ���1
	sbis PINA, 2 ; �������� ���1
	ldi r19, 0x01 ; ��������� ������������ ���1
	sbis PINA, 3 ; �������� ���1
	ldi r20, 0x01 ; ��������� ������������ ���1
	sbis PINA, 4 ; �������� ���1
	ldi r21, 0x01 ; ��������� ������������ ���1
	
	sts $0610, r17 ; ���������� ����������� ���1
	sts $0611, r18 ; ���������� ����������� ���2
	sts $0612, r19 ; ���������� ����������� ���3
	sts $0613, r20 ; ���������� ����������� ���4
	sts $0614, r21 ; ���������� ����������� ���5
	ret

peredacha_PK:
	in r16, UDR
	nop
wait_0: sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait_0

	ldi R27, 0x06 ; ��������� ������� ����� ���������� ������( ������� r9)
	ldi R26, 0x00 ; ��������� �������� ����� ���������� ������( ������� r9)
	ldi r16, 0x11 ; ������ ���-�� ��������� ��� ��������
while:
	ld r17, X+; ���������� ������ �� ���������� ��������
	out UDR, r17 ; �������� ������ � ������� UDR(transmit)
wait: 
	sbis UCSRA, 5 ; �������� �� ��, ���� �� ������� UDR
	rjmp wait
	dec r16 ; ���������� ���-�� ���������� ���������
	brne while ; ������� � ������ �����, ���� �������� ��������
	nop
	
	ret; ������� �� ������� ������������

adc_conv_linear:
	ldi r31, 0x00	; select linear channel
	rcall adc_setup
	rcall adc_conv
	sts $0600, r1 ; ���������� �������� ����� � ����� ������ ���
	sts $0601, r0 ; ���������� �������� ����� � ����� ������ ���
	ret

adc_convert_result_linear:
	ldi r18, 0x1F ;��������� ��� ������������ (K) 
	ldi r19, 0x1A ; 16 718 367
	ldi r20, 0xFF
	ldi r26, 0x00 ; ������� ����� ������ ����� P
	ldi r27, 0x06 ; ������� ����� ������ ����� P
	ld r24, X+    ; ���������� ������� ����� ����� P
	ld r23, X    ; ���������� ������� ����� ����� P
	rcall mul3x2 ; ��������� ���� ��� �� ��������� �
	
	ldi r16, 0x59 ; ������ ��������� � � ��� ����
	ldi r17, 0x1f
	ldi r18, 0x1a
	ldi r19, 0xeb
	ldi r20, 0xfb
	ldi r21, 0xff
	rcall AddB ; ����������� ��������� � � ���������� ������������

	ldi r26, 0x05 ; ���������� �������� ����� ������ ��� ����������
	ldi r27, 0x06 ; ���������� �������� ����� ������ ��� ����������
	st X+, r31 ; ���������� ����� �����
	st X+, r4     ; ������ ������� ����� ���������� 
	st X+, r3     ; ������ ������� ����� ����������
	st X+, r2     ; ������ �������� ����� ��� ����������
	st X+, r1     ; ������ ���������� ����� ��� ����������
	st X+, r0     ; ������ ������ ����� ��� ����������

	ret ; ������� � ������ ���������
	
adc_conv_nonlinear:
	ldi r31, 0x01 ; select non linear channel
	rcall adc_setup
	rcall adc_conv
	sts 0x0602, r0 ; ���������� �������� ����� � ����� ������ ���
	sts 0x0603, r1 ; ���������� �������� ����� � ����� ������ ���
	ret

adc_convert_result_nonlinear:
	lds r16, 0x0602 ; ��������� �������� ����� ���� ��� ��� ����������� �������
	swap r16 ; ������������ ������ �������
	andi r16, 0x0F ; ��������� ������� �������
	
	; ��������� �16 �� 8 ����� ���������� ����� ��� ���������
	lsl r16
	lsl r16
	lsl r16

	ldi r31, high(tablKiB*2)
	ldi r30, low(tablKiB*2)
	
	clr r1
	add r30, r16
	adc r31, r1

	lpm r20, Z+ ; ����������  ��������� � �� ���
	lpm r19, Z+
	lpm r18, Z+

	lds r24, 0x0602    ; ���������� ������� ����� ����� P
	lds r23, 0x0603    ; ���������� ������� ����� ����� P

	rcall mul3x2

	clr r21
	lds r16, $0602
	cpi r16, 0x00
	brne nonlinearB
	ldi r21, 0xff
nonlinearB:
	lpm r20, Z+ ; ���������� ��������� � �� ��� ����������
	lpm r19, Z+
	lpm r18, Z+
	lpm r17, Z+
	lpm r16, Z+

	rcall AddB

	ldi r26, 0x0B ; ���������� �������� ����� ������ ��� ����������
	ldi r27, 0x06 ; ���������� �������� ����� ������ ��� ����������
	st X+, r31 ; ���������� ����� �����
	st X+, r4     ; ������ ������� ����� ���������� 
	st X+, r3     ; ������ ������� ����� ����������
	st X+, r2     ; ������ �������� ����� ��� ����������
	st X+, r1     ; ������ ���������� ����� ��� ����������
	st X+, r0     ; ������ ������ ����� ��� ����������

	ret ; ������� � ������ ���������
	
adc_setup:
	;���������� ����� ��� ���������� �������������� ��������� �������
	; 8 ��� - ��������� � ��� 8 ��� ��� ����������� ���������� ���� ������
	; ����� ������� �� SCKI ������� 10 ��
	ldi r16, 0b10000001 ; ��������� ������ Softspan �� 0 �� 5 �
						; � ����� �������� ������ (�������� ������ ��������)
	sbi ADC_PORT, SDI		; ��������� V = 1 (������������ ����� ��������)
	sbi ADC_PORT, SCKI		; �������� ���� �� ����� SDI(PC2)
	cbi ADC_PORT, SDI
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; �������� ���� �� ����� SDI(PC2)
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; �������� CH[2]
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; �������� CH[1]
	nop
	cbi ADC_PORT, SCKI		
	cpi r31, 0x01
	brcs selectChannel		; jmp to selection of default channel (0)
	sbi ADC_PORT, SDI		; set ch1(non linear) if r0 = 1
selectChannel:
	sbi ADC_PORT, SCKI		; �������� CH[0]
	cbi ADC_PORT, SDI		; set SDI low
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; �������� SS[2]	
	nop
	cbi ADC_PORT, SCKI		
	nop
	sbi ADC_PORT, SCKI		; �������� SS[1]
	nop
	cbi ADC_PORT, SCKI		
	sbi ADC_PORT, SDI		
	sbi ADC_PORT, SCKI
	cbi ADC_PORT, SDI
	cbi ADC_PORT, SCKI
	ldi r16, 0x8
rest8bit:	; �������� �������� ����������� ������ ������ 16 ���
	sbi ADC_PORT, SCKI
	dec r16
	cbi ADC_PORT, SCKI
	brne rest8bit

	ret ; ������� �� ������������

adc_conv:
	sbi ADC_PORT, CONV ; ��������� ������� � conv (t cnv high ��� 40 ��)
	cbi ADC_PORT, SDI ; ��������� ����, ��� ������������ ������ ������ ���
	sbi ADC_PORT, SCKI ; ��� �������� SCKI
	nop
	cbi ADC_PORT, CONV ; ��������� ���� � CONV

waitBusy:
	sbic ADC_PIN, BUSY ; �������� ����� BUSY
	rjmp waitBusy ; �������� ���� BUSY ����������
	
	sbi ADC_PORT, SCKI ; ��� �������� SCKI
	clr r0 ; ������� �������� �������� ���������� ������� ����
	clr r1 ; ������� �������� �������� ���������� ������� ����
	ldi r17, 0x10 ; ���������� ���-�� ����� � ����������
readADC:
	cbi ADC_PORT, SCKI ; ���������� ���������� ���� � ���
	nop
	in R16, ADC_PIN ; ������ �������� �� �����
	ror r16 ; ������� ����������� ���� � ���� �
	rol r0 ; ����������� ���� msb first
	rol r1 ; ����������� ���� msb first

	sbi ADC_PORT, SCKI ; ������������ ���������� ����
	dec r17 ; ���������� ����������� ���-�� ���
	brne readADC

	nop ; t quiet ������� 20 ��
	ret

mul3x2:
	clr r0 			; ������� �������� �0 ��� ���������� ����������
	clr r1 			; ������� �������� �1 ��� ���������� ����������
	clr r2			; ������� �������� �2 ��� ���������� ����������
	clr r3			; ������� �������� �3 ��� ���������� ���������� 
	clr r4			; ������� �������� �4 ��� ���������� ����������

	clr r21			; ������� ��� �������� ��� ������ ���������
	clr r22			; ������� ��� �������� ��� ������ ���������
	ldi r16, 0x10		; ���������� ����������� ����� � ���������
n1:				
	lsr r24			; ����� �������� ����� ��������� ������
	ror r23			; ����������� ����� �������� ����� ��������� ������
	brcc sdv		; ���� ��� � ����� � = 0 �� �������
	add r0, r18		; ����������� �������� ����� ���������
	adc r1, r19		; ����������� ������� ����� ���������
	adc r2, r20		; ����������� �������� ����� ���������
	adc r3, r21		; ����������� ���������� ����� ���������
	adc r4, r22		; ����������� ������ ����� ���������
sdv:
	lsl r18			; ����� �������� ����� ��������� �����
	rol r19			; ����� ������� ����� ��������� �����
	rol r20			; ����� �������� ����� ��������� �����
	rol r21			; ����� ���������� ����� ��������� �����
	rol r22			; ����� ������ ����� ��������� �����
	dec r16			; ���������� ����������� ���-�� ����� � ���������
	brne n1			; ���� �������� ���� ������� � ������ �����

	ret

AddB:	
	clr r5; ������� �������� ������� ����� �������������� ��� 6 ����
	add r0, r16 ; �������� ���� �����
	adc r1, r17
	adc r2, r18
	adc r3, r19
	adc r4, r20
	adc r5, r21

	clr r31 ; ������� �������� ��� ����
	mov r16, r5 ; ����������� �������� �����
	rol r16 ; ����������� ����� ����� ��� �������� �����
	brcc exit ; ���� ������� ��� ��� ���� �� ����� ������, ������� � ���������� �����
	ldi r16, 0x01 ; ���������� ������� ��� �������� � ������� ����
	clr r17 ; �������� �������� ��������
	sub r0, r16 ; ��������� ������� �� �������� ����� 
	sbc r1, r17 ; ��������� � ������ ��������
	sbc r2, r17 ; ��������� � ������ ��������
	sbc r3, r17 ; ��������� � ������ ��������
	sbc r4, r17 ; ��������� � ������ ��������
	
	com r0 ; �������� ����� 
	com r1 ; �������� ����� 
	com r2 ; �������� ����� 
	com r3 ; �������� ����� 
	com r4 ; �������� ����� 
	ldi r31, 0x01 ; ���������� ������ � ������� �31(������ ��� ����� �������������)
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
	
