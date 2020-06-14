;
; display.asm
;
; Created: 01/06/2020 17:11:56
; Author : Rodrigo Gradela
;          Gustavo Ferrara
;	   Marcelo Patricio
;          Vinícius do Carmo
;
;


.include "m32def.inc"
.equ en=PB3 		;configurações iniciais para o display (necessárias)
.equ rs=pb2		;configurações iniciais para o display (necessárias)
.equ rw=PB1		;configurações iniciais para o display (necessárias)

.org 0x00		;instrução inicial

rjmp strt


strt: 			;função de início (start)
cli 			;desativa interrupção global
ldi r16, high(ramend)	;última localização da memória no chip (ramend)
out sph, r16		;saída
ldi r16, low(ramend)	;última localização da memória no chip (ramend)
out spl, r16 		;saída

ldi r16, 0xff		;carregando no registrador 16
out ddrb,r16 		;configurando todas as portas como saída
out ddrc, r16		;configurando todas as portas como saída

ldi r16, 0x00		;carregando no registrador 16
out portb, r16		;desligando todas as portas
out portc, r16		;desligando todas as portas

ldi r17,0x80  		;carrega 80h no registrador auxiliar 17
out DDRD,r17  		;configurando o PORTD7 como saída
ldi r17,0x40  		;carregando 40h no registrador auxiliar 17
out PORTD,r17 		;inicializando P07 em LOW e habilito P06 como pull-up
call LCDinit

 
 
loop:
sbis PIND,PD6  		;botão está solto?
rjmp liga_led  		;não, então liga o led
cbi PORTD,PD7  		;sim, então desliga o led
rjmp strt      		;desvia para loop

 
liga_led:
sbi PORTD,PD7   	;liga led
rjmp msg_ligado 	;muda mensagem para ligado
	
msg_ligado:
call LCDinit
call dsplystr 		;chama o display
ldi zh,high(mesg2<<1)	;carrega imediatamente do zh para o high
ldi zl,low (mesg2<<1)	;carrega imediatamente do zh para o low
rjmp loop



 
LCDinit: 		;inicialização do display
ldi r16, 0x01		;carregando o registrador r16
call cmndwrt		;chamando a função cmndwrt do LCD
ldi r16, 0x06		;carregando o registrador r16 em 0x06
call cmndwrt
ldi r16,0x38	 	;carregando o registrador r16 em 0x38
call cmndwrt
ldi r16, 0x38	 	;carregando novamente o registrador r16 como 0x38
call cmndwrt
ldi r16, 0x0c
call cmndwrt
call dsplystr		;chama a função do display
ldi zh,high(mesg<<1)	;carrega zh para high
ldi zl,low (mesg<<1)	;carrega zh para low
ret 			;garante o retorno da subrotina

dsplystr:
clr r0 			;limpa o registro
cp r16, r0 		;compara os registros
lpm r16,z+		;carrega a memoria r16 do z
breq check 		;faz um branch se igual
call datawrt
rjmp dsplystr
 

 check:
 ret 			;garante o retorno da subrotina
 
 cmndwrt:
 cbi portb, en		;limpa registrador com a porta en requisito obrigatorio para o uso do display
 cbi portb, rs		;limpa registrador com a porta rs requisito obrigatorio para o uso do display
 cbi portb, rw
 out portc,r16		;configura registrador r16 como saida da porta C
 sbi portb, en 		;defini o bit no registro i/o
 call delay
 cbi portb, en
 ret 			;garante o retorno da subrotina
 
 datawrt: 		;configuração da datawart do display
 cbi portb, en 		;limpa bit no registro i/o
 sbi portb, rs 		;defini o bit no registro i/o
 cbi portb, rw
 out portc,r16
 sbi portb, en 		;defini o bit no registro i/o
 call delay
 cbi portb, en
 ret 			;garante o retorno da subrotina

 delay:             	;carrega toda instrução para um delay de 2 ms 
 push r16 		;empurra o r16 para pilha
 push r17 		;empurra o r16 para pilha
 ldi r16, 0xff
 a1:ldi r17, 0x3f
 a2: dec r17
 brne a2 		;faz branch se nao for igual
 dec r16 		;decrementa r16
 brne a1 		;faz branch se nao for igual
 pop r16 		;pega registro da pilha
 pop r17 		;pega o registro da pilha
 ret

 

 mesg: .db "Fan Desligada!!!!",0x00 		;mensagem inicial
 mesg2: .db "Fan Ligada!!!! ",0x00 		;mensagem quando circuito está ativado
 

 


 .exit



