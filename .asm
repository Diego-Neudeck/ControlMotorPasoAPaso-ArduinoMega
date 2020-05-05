;
; integrador2_ejer1.asm
;
; Created: 26/9/2019 10:00:06
; Author : Diego Neudeck
;
			
;definiciones------------------------------
			.equ butt = 5					;cambio en valor de cada cuanto entra a ver los botones
			.equ VPC1 = 64500;400;63036;62000;			;valor de precarga
			.def temp1=R16
			.def aux1=R17						;Para ver el estado de la llave S1
			.def aux2=R18						;PAra ver el estado de la llave S2
			.def cont_butt=R19					;contador en TIMER0 para ver cuantas veces entro siendo cero P
			.def sregT=R20						;guardo las banderas en TIMER1
			.def ban=R21						;guardo las banderas en TIMER0
			.def cont_mp=R22						;
			.def pren=R23						;para saber si esta prendido o apagado el motor
			.def aux3=R24						;ocupo para enmascarar pren 
			.def ini=R25						
			

;vectores-----------------------------------------------------------------------------------
			.org 0x0000
			rjmp INICIO
			.org 0x0028
			rjmp TIM1_OV_prende	
			
		
;configuracion e inicializacion--------------------------------------------------------------
INICIO:		call conf_PORTA						; Puerto A, motor PAP
			call conf_PORTB						; Puerto B, boton e interruptores
			call conf_TC1						; TC1, temporización pasos del motor
								
			ldi cont_butt,butt					;contador para ver cuando ingreso a ver los botones
			clr temp1
			clr pren							;inicializo pren en cero
			ldi aux3,0x01						;utilizo para hacer la or exclusiva con pren
			clr ban
			sei									;actibo la bandera de interrupciones
ESPERA:		rjmp ESPERA


;Subrutina-----------------------------------
;-------------------------------------------
;puertos:
conf_PORTA:	ldi temp1, 0x0F
			out DDRA,temp1					;configuro como salida el puerto A
			clr temp1
			out PORTA, temp1				;inicializo en cero la salida
			ret

conf_PORTB:	ldi temp1,0x00					;configuro el puerto B como entrada
			out DDRB,temp1
			out PUD,temp1
			ldi temp1,0x07
			out PORTB,temp1
			ret

conf_TC1:	ldi temp1, 0x00		
			sts TCCR1A, temp1				;configuro como modo normal	
			ldi temp1,0x02					;configuro N=8 y como modo normal ;despues en 1024 para prueba es 5
			sts TCCR1B, temp1
			clr temp1
			out TIFR1,temp1
			ldi temp1,0x01
			sts TIMSK1, temp1				;configuro para llamar por desbordamiento
			ldi temp1,high(VPC1)			;precargo el registro
			sts TCNT1H,temp1				;contador del TC1 para inicializar, ver si cargo bien.
			ldi temp1,low(VPC1)
			sts TCNT1L,temp1
			ret


;---------------------------------------------
;Servicio a la interrupciones--------------------------------------------------------------
;---------------------------------------------

TIM1_OV_prende:
			in sregT,SREG
			dec cont_butt
			brne prende					;si cont_butt no es cero no entra a testear los botones
;testeo P despues de que el contador butt es cero, y si P es cero voy a leer, si es uno salgo de la interrupcion
			sbic PINB,0					;bits cero es P, se fija si esta en cero
			rjmp salir1
			rjmp leer	
;------------------------------------------------------------------------
;en accion veo los estados de los pines de entrada (P,S1,S2)
accion:		eor pren,aux3				;or exclusiva, asi toggleo el ultimo bits de pren y se el estado del motor. 
			sbic PINB,1					;leo el bits 1 que es el de la llave s1
			ldi aux1,0x00
			sbis PINB,1					;pregunto si el puerto b es uno
			ldi aux1,0x01				;asi salteo esta instruccion y no sobreescribo aux1.
			sbic PINB,2
			ldi aux2,0x00				;pregunto si el puerto b es uno
			sbis PINB,2					;asi salteo esta instruccion y no sobreescribo aux2.
			ldi aux2,0x01	
			ldi ban, 0x01
			clr temp1
			ldi cont_butt,butt			;restauro el valor de buttom
			rjmp prende
;-----------------------------------------------------------------------------------------------
;salgo de la interrupcion
salir1:		ldi cont_butt,butt			;restauro el valor de buttom
chau:		rjmp salir
;-----------------------------------------------------------------------------------------------
;en leer pongo la primera vez que entra temp1=0 (aux3=1) asi cargo temp1=1 y cont_but=1 asi entra de nuevo en la siguiente interrupcion
;y verifico el cero de P para ir a testear S1 y S2 en accion.
leer:		cp temp1,aux3
			breq accion
			ldi temp1,0x01				;salgo para ver el ruido del comienzo
			ldi cont_butt,0x01
			rjmp chau					;es decir que salgo con buttom igual a uno 
;-------------------------------------------------------------------------
;testeo para ver sentido y si es medio o paso completo
prende:		in sregT,SREG
										;aux3=1, si son iguales, el motor esta prendido
			cp pren,aux3
			breq prendido
			rjmp salir
prendido:	mov temp1,aux1				;guardo en temporal el valor de la llave S1
			sub temp1,aux3				;comparo aux3 con temporal1
			breq anti
			call horario
;sale de la intessupcion---------------------------------------------
salir:		out SREG,sregT
			reti
;---------------------------------------------------------------------
;si viene aca es por que es antihorario, y voy a antihor para ver si es pp o mp
anti:		call antihor
			rjmp salir

;veo si es medio paso o paso a paso y con eso ejecuto el sentido y los pasos 
antihor:	cp aux2,aux3
			breq ant_mp
			rjmp ant_pc
;-------------------------------------------------------
;mando uno a uno la secuencia que corresponde en el medio paso, dependiendo el valor del contador.
ant_mp:		cpi ban, 0x01
			brne aqui_a1
			ldi cont_mp,0x08
aqui_a1:	cpi cont_mp,0x08
			breq caso1a
			cpi cont_mp,0x07
			breq caso2a
			cpi cont_mp,0x06
			breq caso3a
			cpi cont_mp,0x05
			breq caso4a
			cpi cont_mp,0x04
			breq caso5a
			cpi cont_mp,0x03
			breq caso6a
			cpi cont_mp,0x02
			breq caso7a
			cpi cont_mp,0x01
			breq caso8a
			
caso1a:		ldi ini, 0b00001000
			out PORTA,ini
			rjmp out1
caso2a:		ldi ini, 0b00001100
			out PORTA,ini
			rjmp out1
caso3a:		ldi ini, 0b00000100
			out PORTA,ini
			rjmp out1
caso4a:		ldi ini, 0b00000110
			out PORTA,ini
			rjmp out1
caso5a:		ldi ini, 0b00000010
			out PORTA,ini
			rjmp out1
caso6a:		ldi ini, 0b00000011
			out PORTA,ini
			rjmp out1
caso7a:		ldi ini, 0b00000001
			out PORTA,ini
			rjmp out1
caso8a:		ldi ini, 0b00001001
			out PORTA,ini
			ldi cont_mp,0x09
out1:		clr ban
			dec cont_mp
			rjmp salir3
;-------------------------------------------------------------------------------
;corro el uno hasta el bits 0 y luego reseteo ini
ant_pc:		;ldi temp1,ban				;guardo los valores iniciales cuando entra por primera vez a p
			cpi ban, 0x01
			brne aqui
			ldi ini,0b00010000
			
aqui:	 
			lsr ini						;guiro ini
			out PORTA,ini
			
salir3:		clr ban
			sbrc ini,0
			ldi ini,0b00010000
			ret
;---------------------------------------------------------------------------------------
;si viene aca es por que es horario, y veo si tiene que ser pp o mp
horario:	cp aux2,aux3
			breq hor_mp
			rjmp hor_pc
;-----------------------------------------------------------------------------------
;mando uno por uno las salidas con un contador qe decrese 
hor_mp:		cpi ban, 0x01
			brne aqui_a
			ldi cont_mp,0x08
aqui_a:		cpi cont_mp,0x08
			breq caso1
			cpi cont_mp,0x07
			breq caso2
			cpi cont_mp,0x06
			breq caso3
			cpi cont_mp,0x05
			breq caso4
			cpi cont_mp,0x04
			breq caso5
			cpi cont_mp,0x03
			breq caso6
			cpi cont_mp,0x02
			breq caso7
			cpi cont_mp,0x01
			breq caso8
			
caso1:		ldi ini, 0b00000001
			out PORTA,ini
			rjmp out2
caso2:		ldi ini, 0b00000011
			out PORTA,ini
			rjmp out2
caso3:		ldi ini, 0b00000010
			out PORTA,ini
			rjmp out2
caso4:		ldi ini, 0b00000110
			out PORTA,ini
			rjmp out2
caso5:		ldi ini, 0b00000100
			out PORTA,ini
			rjmp out2
caso6:		ldi ini, 0b00001100
			out PORTA,ini
			rjmp out2
caso7:		ldi ini, 0b00001000
			out PORTA,ini
			rjmp out2
caso8:		ldi ini, 0b00001001
			out PORTA,ini
			ldi cont_mp,0x09
out2:		clr ban
			dec cont_mp
			rjmp salir4
;---------------------------------------------------------
hor_pc:	;	ldi temp1,ban				;guardo los valores iniciales cuando entra por primera vez a p
			cpi ban, 0x01
			brne aqui2
			ldi ini, 0b00000001
			
aqui2:		out PORTA,ini
			lsl ini
			sbrc ini, 4
			ldi ini, 0b00000001
			clr ban
salir4:		ret
