TITLE Program 4     (prog4.asm)

; Assignment #4
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 2/18/18
; Description: This program prints composite numbers in rows of 10.
;			   The number of composite numbers to be printed will be determined by the user.
;			   The user must enter a number between 1 and 400, inclusive.

INCLUDE Irvine32.inc

	UPPER_LIMIT = 400
	LOWER_LIMIT = 1
	FIRST_COMPOSITE = 4		; the lowest composite number is 4, so start here every time
	IS_COMPOSITE = 1		; for comparing a boolean
	IS_EVEN = 2				; first check for a composite number is being even, so set divisor to 2
	ZERO = 0
	LINE_FULL = 10			; print new line after 10 numbers

.data

	progName		byte	"Deposit Your Composites Here, Please!", 13, 10, 0
	myName			byte	"   by David Mednikov", 13, 10, 13, 10, 0
	extraCredit		byte	"EC**: ALIGNS THE OUTPUT COLUMNS", 13, 10, 13, 10, 13, 10, 0
	instructions1	byte	"You will enter a number between 1 and 400, let's call it n.", 13, 10, 0
	instructions2	byte	"Then, I will show the first n composite numbers. Numbers will be aligned.", 13, 10, 13, 10, 13, 10, 0
	getInt			byte	"Enter a number between 1 and 400: ", 0
	outOfRange		byte	"Your entry is out of range. Seriously, it's not that hard.", 13, 10, 13, 10, 0
	goodbye			byte	"Thank you for playing! See ya!", 13, 10, 13, 10, 0
	oneTab			byte	" ", 09, 0

	compositeNums	DWORD	?		; set by user
	numsInLine		DWORD	0
	checkComposite	DWORD	?		; current number being checked for being composite
	divIncrementer	DWORD	?		; increment divisor to check if number is composite
	compositeBool	DWORD	?		; set to 1 if current number is a composite

.code

main PROC

	call	intro
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP


; Procedure to introduce the program and programmer, and give the user instructions
; Receives: global variables progName, myName, extraCredit, instructions1, instructions2
; Returns: none
; Preconditions: none
; Registers changed: edx
intro PROC
	
	push	ebp
	mov		ebp, esp

	mov		edx, OFFSET progName
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET extraCredit
	call	WriteString
	mov		edx, OFFSET instructions1
	call	WriteString
	mov		edx, OFFSET instructions2
	call	WriteString

	mov		esp, ebp
	pop		ebp
	ret
intro ENDP



; Procedure to get the number of composite numbers from user where 1 <= n <= 400
; Receives: compositeNums is a global variable and UPPER_LIMIT and LOWER_LIMIT are constants
; Returns: saves the user's input to compositeNums
; Preconditions: none
; Registers changed: eax, edx
getUserData PROC

	push	ebp
	mov		ebp, esp

	mov		edx, OFFSET getInt			; ask user for number
	call	WriteString
	call	ReadInt
	mov		compositeNums, eax

	call	validate					; make sure that input is within range

	mov		esp, ebp
	pop		ebp
	ret
getUserData ENDP



; Procedure to make sure the user's input is >= 1 and <= 400
; Receives: compositeNums is a global variable and UPPER_LIMIT and LOWER_LIMIT are constants
; Returns: saves the user's input to compositeNums
; Preconditions: none
; Registers changed: eax, edx
validate PROC
	
	push	ebp
	mov		ebp, esp

; loop until valid input
tryAgain:
	cmp		compositeNums, UPPER_LIMIT
	jg		invalid							; greater than 400, try again
	cmp		compositeNums, LOWER_LIMIT
	jl		invalid							; less than 1, try again
	jmp		validInput						; in range, break out of loop

; input is out of range
invalid:
	mov		edx, OFFSET outOfRange			; notify user that input was out of range
	call	WriteString
	mov		edx, OFFSET getInt				; ask user for input again
	call	WriteString					
	call	ReadInt							; get new input
	mov		compositeNums, eax
	jmp		tryAgain						; loop back to range test

; input is in range, leave procedure
validInput:
	mov		esp, ebp
	pop		ebp
	ret
validate ENDP


; Procedure to print all composite numbers in rows of 10
; Receives: compositeNums is a global variable, how many numbers to print
; Returns: none
; Preconditions: 1 <= compositeNums <= 400
; Registers changed: eax, ebx, ecx, edx
showComposites PROC

	push	ebp
	mov		ebp, esp

	mov		ecx, compositeNums					; for looping
	mov		checkComposite, FIRST_COMPOSITE		; start checking composites at 4
	call	CrLf

; loop until current number is composite
print:

	call	isComposite							; check if current number is composite
	cmp		compositeBool, IS_COMPOSITE			; test bool for true
	je		composite							; composite number, print it
	inc		checkComposite						; not composite, increment counter
	jmp		print								; loop back

; current number is composite, print
composite:
	mov		eax, checkComposite					; write composite number
	call	WriteDec
	mov		edx, OFFSET oneTab					; align columns
	call	WriteString
	inc		checkComposite						; increment counter
	mov		compositeBool, ZERO					; set bool back to 0
	inc		numsInLine							; increment nums printed in line
	cmp		numsInLine, LINE_FULL				; check if line is full (10 numbers)
	je		newLine								; 10 nums printed, new line
	loop	print								; loop back and subtract 1 from ecx
	jmp		donePrinting						; after looping is done jump to end of procedure

; 10 nums in row, new line
newLine:
	call	CrLf
	mov		numsInLine, ZERO
	loop	print

donePrinting:

	call	CrLf
	call	CrLf

	mov		esp, ebp
	pop		ebp
	ret
showComposites ENDP



; Procedure to check if current number is composite
; Receives: checkComposite is a global variable
; Returns: compositeBool is a global variable
; Registers changed: eax, ebx, edx
isComposite PROC
	
	push	ebp
	mov		ebp, esp
	
	mov		divIncrementer, IS_EVEN				; start by dividing by 2
	
increaseDivisor:
	mov		eax, checkComposite					; set dividend to current number being tested for being composite
	mov		ebx, divIncrementer					; set divisor to current factor
	mov		edx, 0								; clear out edx for div
	div		divIncrementer						; divide
	cmp		edx, ZERO							; if no remainder then number is compoite
	je		setCompositeBool					; set bool to true
	inc		divIncrementer						; current divisor not a factor, increment by 1
	mov		eax, divIncrementer
	cmp		eax, checkComposite					; compare divisor to current number
	je		done								; if equal then not a factor. break out of loop
	jmp		increaseDivisor						; increased divisor so loop back to top

; set bool to true for calling function
setCompositeBool:
	mov		compositeBool, IS_COMPOSITE			; set composite bool to true

; done testing current number
done:
	mov		esp, ebp
	pop		ebp
	ret
isComposite ENDP



; Procedure to say farewell to the user
; Receives: goodBye is a global variable
; Returns: none
; Preconditions: none
; Registers changed: edx
farewell PROC

	push	ebp
	mov		ebp, esp

	mov		edx, OFFSET goodBye
	call	WriteString

	mov		esp, ebp
	pop		ebp
	ret
farewell ENDP

END main
