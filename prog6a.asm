TITLE Program 6A     (prog6a.asm)

; Assignment #6A
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 3/18/18
; Description: This program asks the user for 10 unsigned integers, places them all into an array, prints the array,
;			   and displays the sum and average to the user. Unsigned integers must be read by the program the hard way:
;			   by reading a string and converting the string to an integer one digit at a time. Likewise, when printing
;			   a number to the terminal window, it must convert the integer to a string one digit at a time. If the user
;			   enters a string that is not an unsigned integer (i.e., contains non-numeric characters or negative) or
;			   enters a number that cannot fit in a 32 bit register, the program will not accept that input and instruct
;			   the user to try again.

INCLUDE Irvine32.inc

;*********************************************************************************************************
; Macro to get a string from the user
; Receives: prompt to ask user for string, and memory location to store string to
; Returns: stores string in provided memory location
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
getString	MACRO	prompt, memLocation
	push	eax					; push registers
	push	ecx
	push	edx
	
	mov		edx, prompt			; write prompt to user
	call	WriteString			
	mov		edx, memLocation	; move destination string to edx
	mov		ecx, 32				; 32 bits max
	call	ReadString			; get number in string form, store to memLocation
	
	pop		edx					; pop registers
	pop		ecx
	pop		eax
ENDM

;*********************************************************************************************************
; Macro to display the string in the specified memory location
; Receives: memory location where string is stored
; Returns: none
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
displayString	MACRO	memLocation
	push	edx
	
	mov		edx, memLocation	; print string at memory location
	call	WriteString
	
	pop		edx
ENDM


.data

	sum			DWORD	?
	average		DWORD	?
	array		DWORD	10 DUP (?)			; array of 10 doublewords

	inString	byte	11 DUP (?)			; for string-> and int->string conversion
	outString	byte	11 DUP (?)			; for int->string conversion
	progName	byte	"Doing Things the Hard Way", 13, 10, 0
	myName		byte	"      ...an autobiography by David Mednikov", 13, 10, 13, 10, 0
	xtraCred	byte	"**EC: PROGRAM NUMBERS EACH LINE OF USER INPUT AND DISPLAYS A RUNNING SUBTOTAL", 13, 10, 13, 10, 13, 10, 0
	instr1		byte	"You will enter 10 unsigned numbers. I will consume them the hard way, because that's what I do.", 13, 10, 13, 10, 0
	instr2		byte	"Then I will display the list of numbers, the sum, and the average.", 13, 10, 13, 10, 13, 10, 0
	getNum		byte	". Enter an unsigned number: ", 0
	outOfRange	byte	"Uhhh...sorry that's too big.", 13, 10, 0
	invalid		byte	"C'mon dawg! That ain't an unsigned number!", 13, 10, 0
	tryAgain	byte	"Let's have another go: ", 0
	uEntered	byte	"You entered these numbers: ", 13, 10, 0
	comma		byte	", ", 0
	theSum		byte	"The sum of all these numbers is: ", 0
	subtotal	byte	"The running subtotal is: ", 0
	theAvg		byte	"The average is: ", 0
	later		byte	"For the 6th and final time, buh-bye now! ;)", 13, 10, 13, 10, 0


.code
main PROC

	push	OFFSET instr2		; push intro strings onto stack
	push	OFFSET instr1
	push	OFFSET xtraCred
	push	OFFSET myName
	push	OFFSET progName
	call	intro				; call intro procedure

	
	push	OFFSET outOfRange	; push 5 strings and prompts onto stack
	push	OFFSET tryAgain		
	push	OFFSET invalid
	push	OFFSET subtotal
	push	OFFSET getNum
	push	OFFSET sum			; pass sum parameter by reference to be stored
	push	OFFSET array		; pass array by reference to be filled
	push	OFFSET inString		; string to read chars, to be converted to int
	push	OFFSET outString	; will be passed to WriteVal
	call	getNumbers			; call procedure to fill array with 10 numbers
	
	push	sum					; pass sum by value to calculate average
	push	OFFSET average		; pass average by reference to be stored
	call	calcAverage			; call procedure to calculate average

	push	OFFSET comma		; push 4 strings and punctuation onto stack
	push	OFFSET uEntered
	push	OFFSET theAvg
	push	OFFSET theSum
	push	sum					; pass sum by value for printing
	push	average				; pass average by value for printing
	push	OFFSET array		; pass array by reference for printing
	push	OFFSET inString		; to convert string to int
	push	OFFSET outString	; reverse of inString for printing
	call	printCalcs			; call procedure to print array, sum, and average

	push	OFFSET later		; push string to stack
	call	goodBye				; say bye to the user

	exit	; exit to operating system
main ENDP

;*********************************************************************************************************
; Procedure to introduce the program and programmer, and give the user instructions
; Receives: progName, myName, extraCredit, instructions1, instructions2 all pushed to the stack
; Returns: none
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
intro PROC

	push	ebp
	mov		ebp, esp

	call	CrLf
	
	displayString	[ebp+8]			; program name
	displayString	[ebp+12]		; my name
	displayString	[ebp+16]		; extra credit
	displayString	[ebp+20]		; instructions 1
	displayString	[ebp+24]		; instructions 2

	pop		ebp
	ret		20						; 5 parameters passed, return 20
intro ENDP


;*********************************************************************************************************
; Procedure to get string input from the user and convert it to an integer the hard way. validates that the input is an integer
; Receives: out string, in string, current element of array, prompts, and error messages
; Returns: stores the integer in the array at the provided memory location
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
ReadVal PROC

	push			ebp
	mov				ebp, esp

	push			eax						; push all registers that will change
	push			ebx
	push			ecx
	push			edx
	push			esi

	getString		[ebp+16], [ebp+8]		; ask (ebp+16) user for number and store to in-string (ebp+8)

validate:	
	mov				esi, [ebp+8]			; point source pointer to in-string

	mov				eax, 0					; to read new char
	mov				ebx, 1					; 10s factor, start at 1, then 10, 100, etc.
	mov				ecx, 0					; count number of digits
	mov				edx, 0					; accumulator when converting string to int one digit at a time
	cld

getLength:									; to get number of digits
	lodsb									; get first digit
	cmp				al, 0					; if equal to \0, end of string, jump out
	je				lengthKnown				
	inc				ecx						; increment digit counter
	jmp				getLength				; loop until \0

lengthKnown:
	cmp				ecx, 10					; 32 bit number will fit in 10 digits, so any more digits means the number is invalid
	jg				tooBig					; invalid if 11 digits or more
	mov				esi, [ebp+8]			; point at front of string
	add				esi, ecx				; add number of digits, pointing to \0
	dec				esi						; decrement esi to point to last digit
	std										; move through string from back to front

keepReading:
	lodsb									; get current digit
	cmp				al, 48					; check if less than 48 (ascii for 0)
	jl				notValid				; not valid
	cmp				al, 57					; check if greater than 57 (ascii for 9)
	jg				notValid				; not valid
	sub				al, 48					; subtract 48 from ascii value to get int value
	push			edx						; push edx for division
	mul				ebx						; multiply digit by 10s factor
	pop				edx						; restore current sum
	jc				tooBig					; if eax overflows over 32 bits, then the number is invalid. jump out and try again

	add				edx, eax				; add current digit value to sum
	jc				tooBig					; if carry flag is set after addition, number is invalid. jump out and try again
	push			edx						; push edx for multiplication of 10 factor

											; multiple 10s factor by 10 for next digit
	mov				eax, ebx				; copy 10s factor to eax
	mov				ebx, 10					; move 10 to ebx
	mul				ebx						; multiply 10s factor by 10
	mov				ebx, eax				; move 10s factor back to edx

	mov				eax, 0					; clear al for next digit
	pop				edx						; pop running sum back to edx

	loop			keepReading				; more digits
	jmp				isValid					; no more digits, jump out

notValid:									; was not an unsigned integer
	displayString	[ebp+20]				; tell user it was invalid, try again
	call			CrLf

	getString		[ebp+24], [ebp+8]		; get input from user
	jmp				validate				; go back and validate user's input

tooBig:
	displayString	[ebp+28]				; tell user it was too big, try again
	call			CrLf

	getString		[ebp+24], [ebp+8]		; get input from user
	jmp				validate				; go back and validate again

isValid:									; valid unsigned integer	
	mov				ebx, [ebp+12]			; address of current element to register
	mov				[ebx], edx				; copy int form of input to current element

	pop				esi						; pop all registers
	pop				edx
	pop				ecx
	pop				ebx
	pop				eax

	pop				ebp
	ret				24						; 7 parameters passed, return 28
ReadVal ENDP


;*********************************************************************************************************
; Procedure to convert an integer to a string and use the displayString macro to print it to the terminal
; Receives: memory location of the integer, in string, out string
; Returns: none
; Preconditions: value to be written is a valid integer
; Registers changed: none
; ***Uses code borrowed from demo program #6***
;*********************************************************************************************************
WriteVal PROC

	push			ebp
	mov				ebp, esp

	push			eax					; push all registers
	push			ebx
	push			ecx
	push			edx
	push			edi
	push			esi

	mov				eax, [ebp+16]		; number to print to eax
	mov				edi, [ebp+12]		; destination pointer to in string
	mov				ecx, 0				; digits counter
	cld
	
convertChars:
	mov				edx, 0				; clear for division
	mov				ebx, 10				; to divide by 10
	div				ebx					; divide number by 10
	mov				ebx, edx			; move remainder to ebx
	add				ebx, 48				; add 48 to get ascii code
	push			eax					; push remaining numbers to be printed
	mov				eax, ebx			; move current digit to eax so that it can be read from al
	stosb								; move digit from al to edi and increment edi pointer
	pop				eax					; pop remaining numbers back
	inc				ecx					; increment number of digits
	cmp				eax, 0				; if remaining number is 0, fully converted, jump out
	je				doneConverting
	jmp				convertChars		; still more digits

doneConverting:							; string is now in reverse
	
	stosb								; move 0 to edi to indicate end of string
	
	mov				esi, [ebp+12]		; move source pointer to beginning of in string
	add				esi, ecx			; add number of digits, now pointing to \0
	dec				esi					; point to last digit
	mov				edi, [ebp+8]		; point destination pointer to out string

;*********************************************************************************************************
; CODE TO FLIP STRING BORROWED FROM DEMO PROGRAM #6
;*********************************************************************************************************
flip:									; to reverse digits in string
	
	std									; set direction flag, so that esi moves in reverse
	lodsb								; move current digit from esi to al, decrement esi
	cld									; clear direction flag, so that edi moves forward
	stosb								; move current digit from al to destination, increment edi
	loop			flip				; repeat for all digits

	mov				eax, 0				; add 0 to end of string
	stosb								; move to edi

	displayString	[ebp+8]				; call macro to write integer in string form
	
	pop				esi					; pop all registers back
	pop				edi
	pop				edx
	pop				ecx
	pop				ebx
	pop				eax

	pop				ebp
	ret				12					; 3 paramters passed, return 12
WriteVal ENDP


;*********************************************************************************************************
; Procedure to get 10 integers from the user and place them into an array, while also keeping a running subtotal
; Receives: in string, out string, array, sum by reference, 5 strings and prompts
; Returns: 10 integers stored to the array and the sum stored in memory
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
getNumbers PROC

	push			ebp
	mov				ebp, esp

	push			eax				; push all registers
	push			ebx
	push			ecx
	push			edx
	push			edi

	mov				eax, 1			; line counter
	mov				ebx, 0			; sum counter
	mov				ecx, 10			; loop 10 times to get 10 nums
	mov				edi, [ebp+16]	; first element of array

getMoreNums:
	push			eax				; push line number to stack
	push			[ebp+12]		; in string
	push			[ebp+8]			; out string
	call			WriteVal		; write value to terminal
	
	push			[ebp+40]		; out of range error
	push			[ebp+36]		; try again prompt
	push			[ebp+32]		; invalid error
	push			[ebp+24]		; prompt to get number
	push			edi				; current element
	push			[ebp+12]		; in string
	call			ReadVal

	displayString	[ebp+28]		; print subtotal string
	
	add				ebx, [edi]		; add new element to running subtotal
	
	push			ebx				; push running subtotal to stack
	push			[ebp+12]		; in string
	push			[ebp+8]			; out string
	call			WriteVal		; write subtotal to terminal window


	add				edi, 4			; move to next element in array
	inc				eax				; increment line counter
	call			CrLf
	call			CrLf
	loop			getMoreNums		; loop until 10 nums have been entered

done:
	mov				eax, [ebp+20]	; copy sum address to eax
	mov				[eax], ebx		; move sum to passed parameter

	pop				edi				; pop all registers
	pop				edx
	pop				ecx
	pop				ebx
	pop				eax

	pop				ebp
	ret				36				; 9 parameters passed, return 36
getNumbers ENDP


;*********************************************************************************************************
; Procedure to calculate the average of the 10 integers
; Receives: memory location of the average parameter, sum passed by value
; Returns: average stored in memory
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
calcAverage PROC

	push			ebp
	mov				ebp, esp

	push			eax					; push registers
	push			ebx
	push			edx

	mov				eax, [ebp+12]		; sum to eax
	mov				ebx, 10				; divisor to ebx
	mov				edx, 0				; set up for division
	div				ebx					; divide eax by 10 to get average

	mov				ebx, [ebp+8]		; move average variable address to ebx
	mov				[ebx], eax			; write average to passed parameter

	pop				edx					; pop registers
	pop				ebx
	pop				eax

	pop				ebp
	ret				8					; 2 parameters passed, return 8
calcAverage ENDP


;*********************************************************************************************************
; Procedure to print the array and display the sum and average
; Receives: out string, in string, array, average by value, sum by value, strings and punctuation
; Returns: none
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
printCalcs PROC

	push			ebp
	mov				ebp, esp

	displayString	[ebp+36]		; print "You entered the following: "

	; print array
	push			[ebp+40]		; push comma
	push			[ebp+16]		; push array
	push			[ebp+12]		; push in string
	push			[ebp+8]			; push out string
	call			printArray

	call			CrLf
	call			CrLf
	
	displayString	[ebp+28]		; tell user the sum

	push			[ebp+24]		; push sum
	push			[ebp+12]		; in string
	push			[ebp+8]			; out string
	call			WriteVal		; print to terminal

	call			CrLf
	call			CrLf
	
	displayString	[ebp+32]		; tell user the average

	push			[ebp+20]		; push average
	push			[ebp+12]		; in string
	push			[ebp+8]			; out string
	call			WriteVal		; print to terminal

	call			CrLf
	call			CrLf

	pop				ebp
	ret				36				; 9 parameters passed, return 36
printCalcs ENDP


;*********************************************************************************************************
; Procedure to print the 10 elements of the array
; Receives: in string, out string, array, comma
; Returns: none
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
printArray PROC

	push			ebp
	mov				ebp, esp
		
	push			ecx				; push registers
	push			esi

	mov				ecx, 10			; set loop counter to 10
	mov				esi, [ebp+16]	; point source pointer to array

keepPrinting:

	push			[esi]			; pass current element
	push			[ebp+12]		; in string
	push			[ebp+8]			; out string
	call			WriteVal

	cmp				ecx, 1			; if last element, then no comma
	je				noComma			; jump out
	displayString	[ebp+20]		; write comma

	add				esi, 4			; point to next element

noComma:
	loop			keepPrinting	; set ecx to 0
	
	pop				esi				; restore registers
	pop				ecx

	pop				ebp
	ret				16				; 4 parameters passed, return 16
printArray ENDP


;*********************************************************************************************************
; Procedure to say goodbye to the user
; Receives: goodbye string
; Returns: none
; Preconditions: none
; Registers changed: none
;*********************************************************************************************************
goodBye PROC

	push			ebp
	mov				ebp, esp

	displayString	[ebp+8]			; say bye now!

	pop				ebp
	ret				4
goodBye ENDP

END main