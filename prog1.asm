TITLE Program 1     (prog1.asm)

; Assignment #1
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 1/21/18
; Description: Ask the user for two numbers and add, subtract, multiply, and divide them, then display the results to the user

INCLUDE Irvine32.inc

.data

; number variables
	input1			DWORD	?
	input2			DWORD	?
	sum				DWORD	?
	difference		DWORD	?
	product			DWORD	?
	quotient		DWORD	?
	remainder		DWORD	?
	again			DWORD	?

; strings
	myName			byte	"        David Mednikov Presents...  ", 0
	programTitle	byte	"The Freedom of Assembly", 0
	extraCredit1	byte	"**EC: Program repeats until the user chooses to quit.", 0
	extraCredit2	byte	"**EC: Program validates the second number to be less than the first.", 0
	blankLine		byte	" ", 0
	instructions1	byte	"You will enter two numbers. The second number must be less than the first.", 0
	instructions2	byte	"I will add, subtract, multiply, and divide them, then tell you the results.", 0
	instructions3	byte	"Then I will ask you if you want to run this thing again.", 0
	firstInput		byte	"What's the first number? ", 0
	secondInput		byte	"What's the second number? ", 0
	tooBig			byte		"The number you entered must be smaller than the first number. Please try again.", 0
	equals			byte	" = ", 0
	plusSign		byte	" + ", 0
	minusSign		byte	" - ", 0
	multSign		byte	" * ", 0
	divSign			byte	" / ", 0
	remainResult	byte	" remainder ", 0
	playAgain		byte	"Enter 0 to quit or any other number to repeat: ", 0
	terminateMsg	byte	"Thank you for coming! buh-bye now ;)", 0

.code

main PROC

start:								; Start of loop, repeat until user wants to quit

; Introduction

	; My Name and Program Title
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET programTitle
	call	WriteString
	call	CrLf

	; Print extra credit statements
	mov		edx, OFFSET extraCredit1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET extraCredit2
	call	WriteString
	call	CrLf

	; Print a blank line
	mov		edx, OFFSET blankLine
	call	WriteString
	call	CrLf

	; Print the instructions
	mov		edx, OFFSET instructions1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instructions2
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instructions3
	call	WriteString
	call	CrLf

	; Print a blank line
	mov		edx, OFFSET blankLine
	call	WriteString
	call	CrLf


; Get Data from User

	; Get first number from user
	mov		edx, OFFSET firstInput
	call	WriteString
	call	ReadInt
	mov		input1, eax;

	; Get second number from user, making sure that second number is less than first
	; ** Extra Credit #2

loopUntilSmaller:
	mov		edx, OFFSET secondInput
	call	WriteString
	call	ReadInt
	cmp		eax, input1				; Compare second input with first input
	jl		quitLoop				; If 2nd input is less than 1st, quit loop
	mov		edx, OFFSET tooBig		; 2nd number is too big, loop again
	call	WriteString
	call	CrLf
	jmp		loopUntilSmaller

quitLoop:
	mov		input2, eax;
	call	CrLf


; Calculations

	; Add
	mov		eax, input1
	mov		ebx, input2
	add		eax, ebx
	mov		sum, eax

	; Subtract
	mov		eax, input1
	mov		ebx, input2
	sub		eax, ebx
	mov		difference, eax

	; Multiply
	mov		eax, input1
	mov		ebx, input2
	mul		ebx
	mov		product, eax

	; Divide
	mov		edx, 0
	mov		eax, input1
	mov		ebx, input2
	div		ebx
	mov		quotient, eax
	mov		remainder, edx


; Display

	; Print sum
	mov		eax, input1
	call	WriteDec
	mov		edx, OFFSET plusSign
	call	WriteString
	mov		eax, input2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	; Print difference
	mov		eax, input1
	call	WriteDec
	mov		edx, OFFSET minusSign
	call	WriteString
	mov		eax, input2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf
	
	; Print Product
	mov		eax, input1
	call	WriteDec
	mov		edx, OFFSET multSign
	call	WriteString
	mov		eax, input2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf	

	; Print Quotient and Remainder
	mov		eax, input1
	call	WriteDec
	mov		edx, OFFSET divSign
	call	WriteString
	mov		eax, input2
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET remainResult
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	
; Offer User to Run Again ** Extra Credit #1

	call	CrLf
	mov		edx, OFFSET playAgain
	call	WriteString
	call	ReadInt
	mov		Again, eax;
	call	CrLf
	cmp		eax, 0					; Quit if user enters 0
	jne		start					; User entered an integer other than 0, loop back to start


; Goodbye
	
	; Print Good-bye
	mov		edx, OFFSET terminateMsg
	call	WriteString
	call	CrLf

	; Print a blank line
	mov		edx, OFFSET blankLine
	call	WriteString
	call	CrLf

	exit							; exit to operating system

main ENDP

; (insert additional procedures here)

END main
