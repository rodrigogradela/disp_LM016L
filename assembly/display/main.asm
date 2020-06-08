;
; display.asm
;
; Created: 01/06/2020 17:11:56
; Author : Rodrigo Gradela
;          Gustavo Ferrara
;	   Marcelo Patricio
;          Vinícius do Carmo
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

ldi r17,0x80  ;Carrega 80h no registrador auxiliar 16
	out DDRD,r17  ;Configurando o PORTD7 como saida
	ldi r17,0x40  ;Carregando 40h no registrador auxiliar 16
	out PORTD,r17 ;Inicializando P07 em LOW e habilito P06 como pull-up
  call LCDinit

 
 
 loop:
	sbis PIND,PD6  ;Botão está solto?
	rjmp liga_led  ;Não, então liga o led
	cbi PORTD,PD7  ;Sim, então desliga o led
	rjmp strt      ;Desvia para loop

 
	liga_led:
	sbi PORTD,PD7   ; Liga led
	rjmp msg_ligado ; Muda mensagem para ligado
	
    msg_ligado:
	 call LCDinit
call dsplystr
 ldi zh,high(mesg2<<1)	; Carrega imediatamente do zh para o high
 ldi zl,low (mesg2<<1)	; Carrega imediatamente do zh para o low
 rjmp loop


 con:
 rjmp con
 LCDinit:

 ldi r16, 0x01	; Carregando o registrador r16
 call cmndwrt	;  Chamando a função cmndwrt do LCD
 ldi r16, 0x06	; Carregando o registrador r16 em 0x06
 call cmndwrt
 ldi r16,0x38	 ; Carregando o registrador r16 em 0x38
 call cmndwrt
 ldi r16, 0x38	 ; Carregando novamente o registrador r16 como 0x38
 call cmndwrt
 ldi r16, 0x0c
 call cmndwrt
 call dsplystr	; Chama a função do display
 ldi zh,high(mesg<<1)	; Carrega zh para high
 ldi zl,low (mesg<<1)	; Carrega zh para low
 ret
 dsplystr:
 clr r0
 cp r16, r0
 lpm r16,z+	; Carrega a memoria r16 do z
 breq check
 call datawrt
 rjmp dsplystr
 

 check:
 ret
 cmndwrt:
 cbi portb, en	;Limpa registrador com a porta en
 cbi portb, rs	;Limpa registrador com a porta rs
 cbi portb, rw
 out portc,r16	;Configura registrador r16 como saida da porta C
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

 delay:             ;delay de 2 ms
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



