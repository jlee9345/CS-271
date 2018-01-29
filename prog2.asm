TITLE Program 2     (prog2.asm)

; Assignment #2
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 1/28/18
; Description: This program asks the user for their name and the number of Fibonacci terms to print. The Fibonacci numbers are printed in rows of 5, and are aligned into columns.

INCLUDE Irvine32.inc

	UPPER_LIMIT = 46
	LOWER_LIMIT = 1
	MAX_PER_ROW = 5
	TWO_TABS_UNTIL = 30		; For alignment, two tabs after each number until 30 numbers printed, then only one tab after number to maintain alignment

.data

; strings
	programTitle	byte	"The Fibonacci Program: better than the last 2 programs, combined!", 13, 10, 0
	myName			byte	".....brought to you by David Mednikov", 13, 10, 13, 10, 0
	extraCredit1	byte	"**EC: Program displays the numbers in aligned columns.", 13, 10, 0
	extraCredit2	byte	"**EC: Program does something incredible!", 13, 10, 13, 10, 13, 10, 0
	fullScreen		byte	"For best results, view me in full screen!", 13, 10, 13, 10, 13, 10, 0
	instructions1	byte	"1. First, you will tell me your name.", 13, 10, 0
	instructions2	byte	"2. Then, you will enter the number of Fibonacci terms to be displayed, an integer between 1 and 46.", 13, 10, 0
	instructions3	byte	"3. And believe me, I will make sure that your input is within that range.", 13, 10, 0
	instructions4	byte	"4. I will then calculate and display all Fibonacci numbers up to and including the number you enter.", 13, 10, 0
	instructions5	byte	"5. Fibonacci numbers will be displayed in rows of 5, and are aligned into columns.", 13, 10, 0
	instructions6	byte	"6. Then, I will do something incredible!", 13, 10, 13, 10, 0
	getName			byte	"Tell me dawg, what's yo name? ", 0
	greeting		byte	"Well hello there, ", 0
	getNumber		byte	", why don't you give me a number between 1 and 46? ", 0
	invalidInput	byte	"Say man, you got a number between 1 and 46? It'd be a lot cooler if you did! ", 0
	incredible		byte	"Now, do yo want to see someting incredible? I present to you, the Fibonacci spiral!", 13, 10, 13, 10, 0
	goodBye			byte	"Later, ", 0
	userName		byte	81	DUP	(?)
	
; punctuation
	exclMark		byte	"!", 13, 10, 13, 10, 0
	oneTab			byte	" ", 09, 0
	twoTabs			byte	" ", 09, 09, 0

; integers
	fibNums			DWORD	?
	tempInt			DWORD	?
	printed			DWORD	0
	printedInRow	DWORD	0

; ascii spiral
	spiral1			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8c. :oO@@@@@@@@.@@@@@@@@Oc :O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral2			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8c :O@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@O:.8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral3			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o C@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@o.8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral4			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8.:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@O 8@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral5			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o:@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral6			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.o@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@oc@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral7			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral8			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@8 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral9			byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Cc@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral10		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@:", 13, 10, 0
	spiral11		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@:", 13, 10, 0
	spiral12		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@OO@@@@@@@@@:", 13, 10, 0
	spiral13		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@:", 13, 10, 0
	spiral14		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@:", 13, 10, 0
	spiral15		byte	" :@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@:", 13, 10, 0
	spiral16		byte	" :@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@:", 13, 10, 0
	spiral17		byte	" :@@@@@@@@@@@@@@@@@@@OC@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@:", 13, 10, 0
	spiral18		byte	" :@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@:", 13, 10, 0
	spiral19		byte	" :@@@@@@@@@@@@@@@@OO@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@C@@:", 13, 10, 0
	spiral20		byte	" :@@@@@@@@@@@@@@@c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@@:", 13, 10, 0
	spiral21		byte	" :@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@:", 13, 10, 0
	spiral22		byte	" :@@@@@@@@@@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o@:", 13, 10, 0
	spiral23		byte	" :@@@@@@@@@@@oC@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@::", 13, 10, 0
	spiral24		byte	" :@@@@@@@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@::", 13, 10, 0
	spiral25		byte	" :@@@@@@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ", 13, 10, 0
	spiral26		byte	" :@@@@@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ", 13, 10, 0
	spiral27		byte	" :@@@@@@@C8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.", 13, 10, 0
	spiral28		byte	" :@@@@@@8O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral29		byte	" :@@@@@@c@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.cocoocoo.     ocooccoo oococococococococococococococococ.", 13, 10, 0
	spiral30		byte	" :@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@.O@@@@@8@@@@o.@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral31		byte	" :@@@@:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@.@@@@@@@@8@@@@@@@ @@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ", 13, 10, 0
	spiral32		byte	" :@@@@O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.OO@@@@@@@@@8@@@@@@@@o@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ", 13, 10, 0
	spiral33		byte	" :@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.c@@@@@@@@@@8@@@@@@@@@c @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.:", 13, 10, 0
	spiral34		byte	" :@@O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@8@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@o:", 13, 10, 0
	spiral35		byte	" :@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @:", 13, 10, 0
	spiral36		byte	" :@O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.O@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@@:", 13, 10, 0
	spiral37		byte	" :@.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@. @@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@:@@@:", 13, 10, 0
	spiral38		byte	" :88@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.88@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@:", 13, 10, 0
	spiral39		byte	" :.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@:@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@:", 13, 10, 0
	spiral40		byte	" ::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@ @@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@8o@@@@@@:", 13, 10, 0
	spiral41		byte	"  8@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@o@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@:", 13, 10, 0
	spiral42		byte	"  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@.@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@8.@@@@@@@@@@:", 13, 10, 0
	spiral43		byte	"  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@8:@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@:", 13, 10, 0
	spiral44		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@ 8@@@@@@@@@@@ @@@@@@@@@@@@@@@o.@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral45		byte	" :@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.@@@@@@@@@@@@c:@@@@@@@@ @@@@@@@@@@8.c@@@@@@@@@@@@@@@@@@@@:", 13, 10, 0
	spiral46		byte	"  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: :::::::::::::::::  .:: :::.   ::::::::::::::::::::::::::", 13, 10, 13, 10, 13, 10, 0

.code
main PROC

; Introductions

	call	CrLf
	mov		edx, OFFSET	programTitle
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET	extraCredit1
	call	WriteString
	mov		edx, OFFSET	extraCredit2
	call	WriteString
	mov		edx, OFFSET	fullScreen
	call	WriteString

; User Instructions

	mov		edx, OFFSET instructions1
	call	WriteString
	mov		edx, OFFSET instructions2
	call	WriteString
	mov		edx, OFFSET instructions3
	call	WriteString
	mov		edx, OFFSET instructions4
	call	WriteString
	mov		edx, OFFSET instructions5
	call	WriteString
	mov		edx, OFFSET instructions6
	call	WriteString

; Get User Data

	; Get Name
	
	mov		edx, OFFSET getName
	call	WriteString
	mov		edx, OFFSET userName
	mov		ecx, 32
	call	ReadString

	call	CrLf
	mov		edx, OFFSET greeting
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclMark
	call	WriteString

	; Get Integer and Validate Input

	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET getNumber
	call	WriteString

loopUntilWithinRange:
	call	ReadInt
	mov		fibNums, eax
	cmp		fibNums, LOWER_LIMIT			; if input is too low, try again
	jl		tryAgain
	cmp		fibNums, UPPER_LIMIT			; if input is too high, try again
	jg		tryAgain
	jmp		inputIsValid

tryAgain:
	call	CrLf
	mov		edx, OFFSET invalidInput
	call	WriteString
	jmp		loopUntilWithinRange			; loop back and try input again

inputIsValid:

; Display Fibonacci Numbers

	call	CrLf
	mov		ecx, fibNums					; prepare registers for Fibonacci adding
	mov		eax, 1
	mov		ebx, 0

printFibonacciNumbers:
	
	cmp		printedInRow, MAX_PER_ROW		; check how many numbers already printed in row
	je		newRow							; create new row if there are 5 numbers in row

printNumber:
	call	WriteDec						
	inc		printed
	cmp		printed, TWO_TABS_UNTIL			; for alignment, print 1 or 2 tabs after number, begining with 31st number
	jg		moreThanThirty

thirtyOrLess:								; for first 30 numbers, print with two tabs for alignment
	mov		edx, OFFSET twoTabs
	call	WriteString
	jmp		getNextNumber

moreThanThirty:								; for 31st number and up, print with one tab per column
	mov		edx, OFFSET oneTab
	call	WriteString

getNextNumber:								; to find Fibonacci number, add curent number to previous number
	inc		printedInRow
	mov		tempInt, eax					; store current number to later become previous number
	add		eax, ebx						; add previous number to current number to find new current number
	mov		ebx, tempInt					; move old current to new previous
	loop	printFibonacciNumbers			; loop back if more numbers
	jmp		donePrinting					; done printing

newRow:
	call	CrLf							
	mov		printedInRow, 0					; reset row counter to 0
	jmp		printNumber						; loop back to top

donePrinting:

; Do Something Incredible

	call	CrLf
	call	CrLf
	call	CrLf
	mov		edx, OFFSET incredible
	call	WriteString
	call	CrLf
	
	mov		edx, OFFSET spiral1				; print out the entire spiral
	call	WriteString	
	mov		edx, OFFSET spiral2
	call	WriteString	
	mov		edx, OFFSET spiral3
	call	WriteString	
	mov		edx, OFFSET spiral4
	call	WriteString	
	mov		edx, OFFSET spiral5
	call	WriteString	
	mov		edx, OFFSET spiral6
	call	WriteString	
	mov		edx, OFFSET spiral7
	call	WriteString	
	mov		edx, OFFSET spiral8
	call	WriteString	
	mov		edx, OFFSET spiral9
	call	WriteString	
	mov		edx, OFFSET spiral10
	call	WriteString	
	mov		edx, OFFSET spiral11
	call	WriteString	
	mov		edx, OFFSET spiral12
	call	WriteString	
	mov		edx, OFFSET spiral13
	call	WriteString	
	mov		edx, OFFSET spiral14
	call	WriteString	
	mov		edx, OFFSET spiral15
	call	WriteString	
	mov		edx, OFFSET spiral16
	call	WriteString	
	mov		edx, OFFSET spiral17
	call	WriteString	
	mov		edx, OFFSET spiral18
	call	WriteString	
	mov		edx, OFFSET spiral19
	call	WriteString	
	mov		edx, OFFSET spiral20
	call	WriteString	
	mov		edx, OFFSET spiral21
	call	WriteString	
	mov		edx, OFFSET spiral22
	call	WriteString	
	mov		edx, OFFSET spiral23
	call	WriteString	
	mov		edx, OFFSET spiral24
	call	WriteString	
	mov		edx, OFFSET spiral25
	call	WriteString	
	mov		edx, OFFSET spiral26
	call	WriteString	
	mov		edx, OFFSET spiral27
	call	WriteString	
	mov		edx, OFFSET spiral28
	call	WriteString	
	mov		edx, OFFSET spiral29
	call	WriteString	
	mov		edx, OFFSET spiral30
	call	WriteString	
	mov		edx, OFFSET spiral31
	call	WriteString	
	mov		edx, OFFSET spiral32
	call	WriteString	
	mov		edx, OFFSET spiral33
	call	WriteString	
	mov		edx, OFFSET spiral34
	call	WriteString	
	mov		edx, OFFSET spiral35
	call	WriteString	
	mov		edx, OFFSET spiral36
	call	WriteString	
	mov		edx, OFFSET spiral37
	call	WriteString	
	mov		edx, OFFSET spiral38
	call	WriteString	
	mov		edx, OFFSET spiral39
	call	WriteString	
	mov		edx, OFFSET spiral40
	call	WriteString	
	mov		edx, OFFSET spiral41
	call	WriteString	
	mov		edx, OFFSET spiral42
	call	WriteString	
	mov		edx, OFFSET spiral43
	call	WriteString	
	mov		edx, OFFSET spiral44
	call	WriteString	
	mov		edx, OFFSET spiral45
	call	WriteString	
	mov		edx, OFFSET spiral46
	call	WriteString	

; Farewell

	Call	CrLf

	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET exclMark
	call	WriteString

	exit	; exit to operating system

main ENDP

; (insert additional procedures here)

END main
