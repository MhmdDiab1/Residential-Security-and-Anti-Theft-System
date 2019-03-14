;------------------------------------------------------------------------------
;  File Description      :  Assembly code for LAB33.
;
;------------------------------------------------------------------------------
  .equ __33fj12GP202, 1
  .include "p33FJ12GP202.inc"
__FOSCSEL: .pword FNOSC_FRC 
__FOSC:    .pword OSCIOFNC_ON

;PORTB
.equiv 		DB7,0x00       ; la broche rw est sur RA1	
.equiv		DB6,0x01        ; la broche e est sur RA2
.equiv		DB5,0x02       ; la broche rw est sur RA1	
.equiv		DB4,0x03        ; la broche e est sur RA2
.equiv 		E,0x04       ; la broche rw est sur RA1	
.equiv 		RS,0x05        ; la broche e est sur RA2

;------------------------------------------------------------------------------
; Global Declarations:
;------------------------------------------------------------------------------
.global __reset                   ; The label for the first line of code. 
.global __T1Interrupt    ;Declare Timer 1 ISR name global
.global __INT0Interrupt    ;Declare INTERRUPT 0 ISR name global
.global __INT1Interrupt    ;Declare INTERRUPT 1 ISR name global
.global __INT2Interrupt    ;Declare INTERRUPT 2 ISR name global
.global _wreg_init  ;Provide global scope to _wreg_init routine In order to call
; this routine from a C file,place "wreg_init" in an "extern" declaration in the C file.
.global _main    ;The label for the first line of code. If the assembler 
        ;encounters "_main", it invokes the start-up code that initializes data sections
;
 .section .xdata, "d"
 ;       .align 2 ;Aligns the next word to be stored (here x_in) to a multiple of 32
BUFFER1: .space 2			   ; BUFFER1 REGISTER FOR GENERAL USE
SEC: 	.space 2			   ; SECOND REGISTERS
Attempts:	.space 2			;Attempts REGISTER
PASS:	.space 2				;Password REGISTER
PASSEL:		.space	2			;Password elements REGISTER
;------------------------------------------------------------------------------
; Start of Code Section in Program Memory
;------------------------------------------------------------------------------
.text
__reset:
        MOV     #__SP_init, W15     ; Initalize the Stack Pointer
        MOV     #__SPLIM_init, W0   ; Initialize the Stack Pointer Limit Register
        MOV     W0, SPLIM
        NOP                         ; Add NOP to follow SPLIM initialization

        ;----------------------------------------------------------------------
        ; CODE GOES HERE
      	MOV			#0XF880,W0;    				; 0:output  , 1: input
		MOV			W0,TRISB
		MOV			#0b0000000000000100,W0		; 
		MOV			W0,TRISA	
		MOV			#0X003F,W0;    				; 0:output  , 1: input
		MOV			W0,PORTB
		MOV			#0X0000,W0;
		MOV			W0,PORTA
		MOV			#0XFFFF,W0;    				; NO ANALOG INPUTS
		MOV			W0,AD1PCFGL
        ;  
        ;----------------------------------------------------------------------
		MOV			#0X0000,W0	; 10000010	
		MOV			W0,INTCON1
	
		MOV			#0X0001,W0	; 10000010	
		MOV			W0,INTCON2
		
		MOV			#0X0000,W0	; 10000010	
		MOV			W0,IFS0
	
		MOV			#0X0009,W0	; 10000010	
		MOV			W0,IEC0

		MOV			#0X0000,W0	; 10000010	
		MOV			W0,IFS1

		MOV			#0X0000,W0	; 10000010	
		MOV			W0,IEC1

		MOV			#0X0007,W0	; 10000010	
		MOV			W0,IPC4

		MOV			#0X7007,W0	; 10000010	
		MOV			W0,IPC0
		MOV			#57578,W0
		MOV			W0,PR1
	
		MOV			#0X0000,W0
		MOV			W0,TMR1
	

		MOV			#0x0100,W0	;1000 0000 0000 0000  /1
		MOV			W0,T1CON
		CLR SEC

		MOV		#15,W0
		MOV		W0,SEC
		MOV		#3,W0
		MOV		W0,Attempts

        REPEAT      #16000			; FOR BOUNCELESS SWITCH
		NOP

		CALL	LCD_INIT
Default:
		MOV		#3,W0
		MOV		W0,Attempts
		CALL	LCD_WR1
		MOV 	#'U',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'N',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'L',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'O',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'C',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'K',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'E',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'D',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		REPEAT  #1000			; FOR BOUNCELESS SWITCH
		NOP

SafeMod:BTSS	PORTA,#2		;*PRESSED keypad	
		GOTO	SafeMod

		REPEAT  #10000			; FOR BOUNCELESS SWITCH
		NOP
LOCKED:	BSET	PORTB,#6		;Laser Trans
								;LASER RECEIVER INT ENABLE		
DLOCK:	CALL	LCD_WR1
		MOV 	#'L',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'O',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'C',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'K',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'E',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'D',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#' ',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#' ',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR

BT1:	BTSC	PORTA,#2
		BRA		BT1

ArmedMod:BTSS	PORTA,#2		;	#PRESSED ON Keypad
		BRA		ArmedMod
		REPEAT  #1000			; FOR BOUNCELESS SWITCH
		NOP

		CLR		PASS
		CALL	Keypad
		MOV		#0x2222,W0
		SUB		W0,W1,W1
		BRA		Z,Default
		BSET	PORTA,#0		;WRONG PASS BUZZ ON
		REPEAT      #16000
		NOP	
		BCLR	PORTA,#0		;WRONG PASS BUZZ OFF
		DEC		Attempts
		BRA		NZ,DLOCK

Alerted:BSET	PORTA,#1		;ALERT BUZZ ON\
		CALL	LCD_WR1
		MOV 	#'A',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'L',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'E',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'R',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'T',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'E',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'D',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#' ',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		REPEAT  #1000			; FOR BOUNCELESS SWITCH
		NOP
		BCLR	T1CON,#TON
LOOP:	BTSS	PORTB,#15 		;Safe button ON ?
		BRA 	LOOP
		BCLR	PORTA,#1		;ALERT BUZZ OFF
		GOTO	Default

;;;;;;;        Timer 1 Interrupt Service Routine
__T1Interrupt:

        BCLR 	IFS0, #T1IF           ;Clear the Timer1 Interrupt flag Status
		DEC		SEC
		BRA		Z,Alerted
		CALL	LCD_WR1
		MOV 	#'W',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'A',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'R',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'N',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'I',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'N',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#'G',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		MOV 	#' ',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		RETFIE                     ;Return from Interrupt Service routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;      SUBPROGRAMS

;BITREV:	MOV		#0X0000,W1
;		MOV 	BUFFER1,W0
 ;       DO  	#15, AGAIN
;		SL    	W0, W0     
;AGAIN:  RRC		W1, W1       
;		NOP
;		SWAP	W1
;		MOV		W1, BUFFER1
;;		MOV		#0X000F,W0		
;		AND		W0,W1,W1
;		MOV		W1,NIBHI
;		MOV		BUFFER1,W1
;		SWAP.B	W1
;		AND		W0,W1,W1
;		MOV		W1,NIBLO
;		RETURN

Keypad:	MOV		#4,W0
		MOV		W0,PASSEL
		CLR		W1
		CALL	CLEAR
		

COLUMN1:BCLR 	PORTB,#8				
 		BSET	PORTB,#9
		BSET 	PORTB,#10
;		REPEAT	#50
		NOP
		BTSS	PORTB,#11				;R1
		BRA		KEY1
		BTSS	PORTB,#12				;R2
		BRA		KEY4
		BTSS	PORTB,#13				;R3
		BRA		KEY7
		BTSS	PORTB,#14				;R4
		BRA		KEYS	

COLUMN2:BCLR 	PORTB,#8				
 		BSET	PORTB,#9
		BSET 	PORTB,#10
;		REPEAT	#50
		NOP
		BTSS	PORTB,#11				;R1
		BRA		KEY2
		BTSS	PORTB,#12				;R2
		BRA		KEY5
		BTSS	PORTB,#13				;R3
		BRA		KEY8
		BTSS	PORTB,#14				;R4
		BRA		KEY0	

COLUMN3:BCLR 	PORTB,#8				
 		BSET	PORTB,#9
		BSET 	PORTB,#10
;		REPEAT	#50
		NOP
		BTSS	PORTB,#11				;R1
		BRA		KEY3
		BTSS	PORTB,#12				;R2
		BRA		KEY6
		BTSS	PORTB,#13				;R3
		BRA		KEY9
		BTSS	PORTB,#14				;R4
		BRA		KEYH	
		BRA		COLUMN1

KEY0:	MOV		#0,W2
		BRA		PEL
KEY1:	MOV		#1,W2
		BRA		PEL
KEY2:	MOV		#2,W2
		BRA		PEL
KEY3:	MOV		#3,W2
		BRA		PEL
KEY4:	MOV		#4,W2
		BRA		PEL
KEY5:	MOV		#5,W2
		BRA		PEL
KEY6:	MOV		#6,W2
		BRA		PEL
KEY7:	MOV		#7,W2
		BRA		PEL
KEY8:	MOV		#8,W2
		BRA		PEL
KEY9:	MOV		#9,W2
		BRA		PEL
KEYS:	MOV		#'*',W2
		BRA		PEL
KEYH:	MOV		#'#',W2
	
PEL:	CALL	LCD_WR1
		MOV 	#'*',W0
		MOV 	W0, BUFFER1 
		CALL	LCDCHR
		BSET	PORTA,#3		;ELEMENT WRITEN BUZZ
		REPEAT      #8000
		NOP	
		BCLR 	PORTA,#3
		
		ADD		W2,W1,W1
		MOV 	W1,PASS
		DEC		PASSEL
		BRA		Z,RET
		REPEAT	#3
		SL		PASS
		MOV 	PASS,W1
		BRA		COLUMN1
		
RET:	RETFIE

LCD_WR1:	
; DDRAM ADDRESS=00 ; TWO NIBBLES 08-->00  LINE 1
		BCLR	LATB,#RS

		BCLR	LATB,#DB4    ; SEND 08
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BSET	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4    ; SEND 00
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		RETURN
LCD_WR2:	
; DDRAM ADDRESS=00 ; TWO NIBBLES 0C-->00  LINE2
		BCLR	LATB,#RS

		BCLR	LATB,#DB4    ; SEND 04
		BCLR	LATB,#DB5
		BSET	LATB,#DB6
		BSET	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4    ; SEND 00
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		RETURN
LCDCHR:		
		BSET	LATB,#RS

		BTSS	BUFFER1,#4
		BRA		B0
		BSET	LATB,#DB4
		BRA		B1
B0:		BCLR	LATB,#DB4
B1:
		BTSS	BUFFER1,#5
		BRA		B2
		BSET	LATB,#DB5
		BRA		B3
B2:		BCLR	LATB,#DB5
B3:		
		BTSS	BUFFER1,#6
		BRA		B4
		BSET	LATB,#DB6
		BRA		B5
B4:		BCLR	LATB,#DB6
B5:
		BTSS	BUFFER1,#7
		BRA		B6
		BSET	LATB,#DB7
		BRA		B7
B6:		BCLR	LATB,#DB7
B7:
		CALL	CLOCKD

		REPEAT  #1000			; FOR BOUNCELESS SWITCH
		NOP

		BTSS	BUFFER1,#0
		BRA		B8
		BSET	LATB,#DB4
		BSET	PORTB,#DB4
		BRA		B9
B8:		BCLR	LATB,#DB4
		BCLR	PORTB,#DB4
B9:
		BTSS	BUFFER1,#1
		BRA		B10
		BSET	LATB,#DB5
		BRA		B11
B10:	BCLR	LATB,#DB5
B11:		
		BTSS	BUFFER1,#2
		BRA		B12
		BSET	LATB,#DB6
		BRA		B13
B12:	BCLR	LATB,#DB6
B13:
		BTSS	BUFFER1,#3
		BRA		B14
		BSET	LATB,#DB7
		BRA		B15
B14:	BCLR	LATB,#DB7
B15:
		CALL	CLOCKD

		REPEAT  #1000			; FOR BOUNCELESS SWITCH
		NOP

;		MOV		NIBHI,W0		
;		MOV		#0XFFF0,W2
;		MOV		PORTB,W1
;		AND		W2,W1,W1
;		MOV		#0X000F,W2
;		IOR		W2,W1,W1
;		MOV 	W2,LATB
;		CALL	CLOCKD

;		MOV		NIBLO,W0		
;		MOV		#0XFFF0,W2
;		MOV		PORTB,W1
;		AND		W2,W1,W1
;		MOV		#0X000F,W2
;		IOR		W2,W1,W1
;		MOV 	W2,LATB
;		CALL	CLOCKD



;		BSET	LATB,#DB4    ; SEND 0F
;		BSET	LATB,#DB5
;		BSET	LATB,#DB6
;		BSET	LATB,#DB7
;		CALL	CLOCKD
;		BSET	LATB,#DB4    ; SEND 0F
;		BSET	LATB,#DB5
;		BSET	LATB,#DB6
;		BSET	LATB,#DB7
;		CALL	CLOCKD
		RETURN

LCD_INIT:BCLR	LATB,#RS
		REPEAT  #100		; FOR BOUNCELESS SWITCH
		NOP
; START UP
;		BSET	LATB,#DB4    ; SEND 03
;		BSET	LATB,#DB5
;		BCLR	LATB,#DB6
;		BCLR	LATB,#DB7
;		CALL	CLOCKD
;		BSET	LATB,#DB4	 ; SEND 03
;		BSET	LATB,#DB5
;		BCLR	LATB,#DB6
;		BCLR	LATB,#DB7
;		CALL	CLOCKD
;		BSET	LATB,#DB4	; SEND 03
;		BSET	LATB,#DB5
;		BCLR	LATB,#DB6
;		BCLR	LATB,#DB7
;		CALL	CLOCKD
;Function Set
		BCLR	LATB,#DB4    ; SEND 02
		BSET	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4	 ; SEND 02
		BSET	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4	; SEND 08
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BSET	LATB,#DB7
		CALL	CLOCKD
		REPEAT  #2000			; FOR BOUNCELESS SWITCH
		NOP
;  Display on/off control  DISPLAY ON , CURSOR ON  , BLINK OFF
		BCLR	LATB,#DB4    ; SEND 00
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4	 ; SEND 0E
		BSET	LATB,#DB5
		BSET	LATB,#DB6
		BSET	LATB,#DB7
		CALL	CLOCKD

		REPEAT  #200			; FOR BOUNCELESS SWITCH
		NOP
;Display Clear
		CALL	CLEAR
;Entry mode set INCREMENT MODE, SHIFT OFF
		BCLR	LATB,#DB4    ; SEND 00
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		BCLR	LATB,#DB4	 ; SEND 06
;		BSET	LATB,#DB4
		BSET	LATB,#DB5
		BSET	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		RETURN

CLOCKD:	REPEAT      #900			; FOR BOUNCELESS SWITCH
		NOP
		BCLR		LATB,#E
		REPEAT      #900			; FOR BOUNCELESS SWITCH
		NOP
		BSET		LATB,#E
		REPEAT      #900			; FOR BOUNCELESS SWITCH
		NOP
		RETURN

CLEAR:	BCLR	LATB,#DB4    ; SEND 00
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD
		BSET	LATB,#DB4	 ; SEND 01
		BCLR	LATB,#DB5
		BCLR	LATB,#DB6
		BCLR	LATB,#DB7
		CALL	CLOCKD

		REPEAT  #10000			; FOR BOUNCELESS SWITCH
		NOP
		RETURN

;--------End of All Code Sections ---------------------------------------------

;;;;;;;;;;;;;;;;;;;;INTERRUPT 0 Interrupt Service Routine
__INT0Interrupt:
       	
	BCLR 		IFS0, #INT0IF           ;Clear the INT0 Interrupt flag Status
	BSET		T1CON,#TON
	BCLR		PORTB,#6	;Turn off Laser Trans
	RETFIE 	
;-------- End of All Code Sections --------------------------------------------

.end ; End of program code in this file
