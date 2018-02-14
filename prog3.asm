TITLE Program 3     (prog3.asm)

; Assignment #3
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 2/11/18
; Description: This program asks the user to enter numbers between -1 and -100 until they enter a positive. The program calculates and displays the sum and average of all valid numbers entered by the user.

INCLUDE Irvine32.inc

	LOWER_LIMIT = -100
	ZERO = 0
	DOUBLE = -2				; for rounding
	INVERT = -1				; for printing floating point number

.data

; strings
	programName		byte	"Accumulating Integers like it's Debt :'(", 13, 10, 0
	myName			byte	".....by David Mednikov", 13, 10, 13, 10, 0
	extraCredit1	byte	"**EC: THIS PROGRAM NUMBERS THE LINES DURING USER INPUT.", 13, 10, 0
	extraCredit2	byte	"**EC: THIS PROGRAM CALCULATES AND DISPLAYS THE AVERAGE AS A FLOATING POINT NUMBER, ROUNDED TO THE NEAREST .001", 13, 10, 13, 10, 0
	getName			byte	"Hello! What is your name, user? ", 0
	greeting		byte	"Pleasure to meet you, ", 0
	exclMark		byte	"!", 13, 10, 13, 10, 13, 10, 0
	instructions1	byte	"1. You will repeatedly enter a negative number between -1 and -100.", 13, 10, 13, 10, 0
	instructions2	byte	"2. When you enter a non-negative number, I will stop asking you for numbers.", 13, 10, 13, 10, 0
	instructions3	byte	"3. I will add the negative numbers and calculate their average and round it.", 13, 10, 13, 10, 0
	instructions4	byte	"4. I will then display the sum and average to you.", 13, 10, 13, 10, 0
	tldr			byte	"tl;dr: Enter numbers between -1 and -100. Enter positive number to stop.", 13, 10, 13, 10, 13, 10, 0
	getNumber		byte	". Enter a number:  ", 0
	tooLowInvalid	byte	"Number must be >= -100:  ", 0
	zeroInvalid		byte	"Either negative, or positive to quit. Don't get cute now:  ", 0
	youEntered		byte	"You entered ", 0
	validNumbers	byte	" valid numbers.", 13, 10, 0
	skipped			byte	"I reckon...you didn't enter any valid numbers now didja!", 13, 10, 13, 10, 0
	theSum			byte	"The sum of your valid numbers is: ", 0
	roundedAvg		byte	"The rounded average is: ", 0
	floatingAvg		byte	"The average, accurate to the .001, is: ", 0
	thankYou		byte	"Thank you for playing, ", 0
	goodBye			byte	"Buh-bye now! ;)", 13, 10, 13, 10, 0
	userName		byte	81 DUP (?)
	decimalPoint	byte	".", 0			; for extra credit #2, printing the floating point number

; integers
	validNums		SDWORD	0		; valid entries by user
	sum				SDWORD	0
	lineNum			DWORD	1		; for extra credit #1
	input			SDWORD	?
	average			SDWORD	?
	remainder		SDWORD	?
	floatAvg		SDWORD	?		; before decimal sign, for extra credit #2
	floating		DWORD	?		; after decimal sign, for extra credit #2
	
.code
main PROC

; Introductions

	; program name, my name, extra credits
	call	CrLf
	mov		edx, OFFSET programName
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET extraCredit1
	call	WriteString
	mov		edx, OFFSET extraCredit2
	call	WriteString

	; get user's name
	mov		edx, OFFSET getName
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString

	; greet user
	call	CrLf
	mov		edx, OFFSET greeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclMark
	call	WriteString

; User Instructions

	; print all instructions
	mov		edx, OFFSET instructions1
	call	WriteString
	mov		edx, OFFSET instructions2
	call	WriteString
	mov		edx, OFFSET instructions3
	call	WriteString
	mov		edx, OFFSET instructions4
	call	WriteString
	mov		edx, OFFSET	tldr
	call	WriteString

; Get Numbers

loopWhileNegative:					; loop while user enters negative numbers in range

	; ask user for number
	mov		eax, lineNum			; for extra credit #1, print lines
	call	WriteDec
	mov		edx, OFFSET getNumber
	call	WriteString

tryAgain:							; loop to validate if input is in range

	call	ReadInt
	mov		input, eax
	cmp		input, LOWER_LIMIT
	jl		tooLow					; less than -100, try again
	cmp		input, ZERO
	jg		breakOutOfLoop			; positive number, break out of loop
	cmp		input, ZERO
	je		enteredZero				; enterd zero, try again
	inc		lineNum					
	inc		validNums				; valid input, increment line number and valid numbers
	add		sum, eax				; add recent input to sum
	jmp		loopWhileNegative		; loop back for more numbers until user enters a positive number

tooLow:								; tell user number is too low and try again
	mov		edx, OFFSET tooLowInvalid
	call	WriteString
	jmp		tryAgain				; loop back to top

enteredZero:						; tell user not to enter 0 and try again
	mov		edx, OFFSET zeroInvalid
	call	WriteString
	jmp		tryAgain				; loop back to top

breakOutOfLoop:

	cmp		validNums, ZERO			; if user entered 0 valid numbers, skip to end
	je		youSkipped
	
; Calculate Averages

	; Rounded average
	mov		eax, sum				; move sum to eax
	cdq								; sign extend for signed division
	mov		ebx, validNums			; set up ebx register for division
	idiv	ebx						; divide to find average

	mov		average, eax			; save result to average
	mov		floatAvg, eax			; for extra credit #2, save result to float average
	cmp		edx, ZERO				; check to see if there is a remainder
	je		noRound					; if no remainder, no rounding
	
	; check for rounding
	mov		remainder, edx			; save remainder to memory
	mov		eax, remainder			; move remainder to eax
	mov		ebx, DOUBLE				
	imul	eax, ebx				; double and invert remainder for rounding
	cmp		eax, validNums			; compare double remainder to divisor
	jl		noRound					; double remainder is less than divisor, do not round
	
	; double remainder is greater than divisor, so round "up"
	mov		eax, average			; copy average to eax
	sub		eax, 1					; subtract 1 from average
	mov		average, eax			; save to memory

noRound:							; jump here if not rounding

	; Floating average
	mov		eax, remainder			; move remainder to eax
	mov		ebx, INVERT				
	mul		ebx						; invert remainder for division
	mov		ebx, 1000				
	mul		ebx						; multiply remainder by 1000 for 3 digits after decimal point
	mov		ebx, validNums			; set up ebx for division
	div		ebx						; divide remainder by divisor for decimal to 0.001
	mov		floating, eax			; save result to memory

display:

; Display sum and averages

	; how many valid numbers
	call	CrLf
	call	CrLf
	mov		edx, OFFSET	youEntered
	call	WriteString
	mov		eax, validNums
	call	WriteDec
	mov		edx, OFFSET validNumbers
	call	WriteString

	; sum
	mov		edx, OFFSET	theSum
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf

	; rounded average
	mov		edx, OFFSET roundedAvg
	call	WriteString
	mov		eax, average
	call	WriteInt
	call	CrLf

	; floating point average
	mov		edx, OFFSET	floatingAvg
	call	WriteString
	mov		eax, floatAvg
	call	WriteInt
	mov		edx, OFFSET decimalPoint
	call	WriteString
	mov		eax, floating
	call	WriteDec
	call	CrLf
	call	CrLf
	call	CrLf
	jmp		buhbye

youSkipped:
	; if user entered 0 valid numbers, display special message
	call	CrLf
	call	CrLf
	mov		edx, OFFSET skipped
	call	WriteString


; Goodbye

buhbye:
	mov		edx, OFFSET thankYou
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET	exclMark
	call	WriteString
	mov		edx, OFFSET goodBye
	call	WriteString
	
	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
