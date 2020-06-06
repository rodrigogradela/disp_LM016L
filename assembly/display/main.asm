;
; display.asm
;
; Created: 01/06/2020 17:11:56
; Author : Rodrigo Gradela
;           Gustavo Ferrara
;	    Marcelo Patricio
;           Vinicius do Carmo
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
	ldi r17,0x40  ;vou carregar 40h no registrador auxiliar 16
	out PORTD,r17 ;inicializo o P07 em LOW e habilito P06 como pull-up
  call LCDinit

 
 
 loop:
	sbis PIND,PD6  ;botão solto?
	rjmp liga_led    ;não, então liga o led
	cbi PORTD,PD7  ;sim, então desliga o led
	rjmp strt      ;desvia para loop

 
	liga_led:
	sbi PORTD,PD7   ; liga led
	rjmp msg_ligado ; muda mensagem para ligado
	
    msg_ligado:
	 call LCDinit
call dsplystr
 ldi zh,high(mesg2<<1)
 ldi zl,low (mesg2<<1)
 rjmp loop


 con:
 rjmp con
 LCDinit:

 ldi r16, 0x01
 call cmndwrt
 ldi r16, 0x06
 call cmndwrt
 ldi r16,0x38
 call cmndwrt
 ldi r16, 0x38
 call cmndwrt
 ldi r16, 0x0c
 call cmndwrt
 call dsplystr
 ldi zh,high(mesg<<1)
 ldi zl,low (mesg<<1)
 ret
 dsplystr:
 clr r0
 cp r16, r0
 lpm r16,z+
 breq check
 call datawrt
 rjmp dsplystr
 

 check:
 ret
 cmndwrt:
 cbi portb, en
 cbi portb, rs
 cbi portb, rw
 out portc,r16
 sbi portb, en
 call delay
 cbi portb, en
 ret
 datawrt:
 cbi portb, en
 sbi portb, rs
 cbi portb, rw
 out portc,r16
 sbi portb, en
 call delay
 cbi portb, en
 ret

 delay:
 push r16
 push r17
 ldi r16, 0xff
 a1:ldi r17, 0x3f
 a2: dec r17
 brne a2
 dec r16
 brne a1
 pop r16
 pop r17
 ret

 

 mesg: .db "Fan Desligada!!!!",0x00
  mesg2: .db "Fan Ligada!!!! ",0x00
 

 


 .exit



