;
; display.asm
;
; Created: 01/06/2020 17:11:56
; Author:	Rodrigo Gradela
;         	Gustavo Ferrara
;		  	Marcelo Patricio
;			Vinícius do Carmo
;


.include "m32def.inc"
.equ en=PB3
.equ rs=pb2
.equ rw=PB1
.org 0x00
rjmp strt


strt:

cli
ldi r16, high(ramend)
out sph, r16
ldi r16, low(ramend)
out spl, r16

ldi r16, 0xff
out ddrb,r16
out ddrc, r16

ldi r16, 0x00
out portb, r16
out portc, r16

ldi r17,0x80  ;carrega 80h no registrador auxiliar 16
	out DDRD,r17  ;estou configurando o PORTD7 como saida
	ldi r17,0x40  ;carregando 40h no registrador auxiliar 16
	out PORTD,r17 ;inicializando o P07 em LOW e habilitando P06 como pull-up
  call LCDinit

 
 
 loop:
	sbis PIND,PD6  ;botao solto?
	rjmp liga_led    ;nao, entao liga o led
	cbi PORTD,PD7  ;sim, entao desliga o led
	rjmp strt      ;desvia para loop