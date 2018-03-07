TITLE Program 5     (prog5.asm)

; Assignment #5
; Author: David Mednikov
; Email: mednikod@oregonstate.edu
; Class & Section: CS271-400
; Due Date: 3/4/18
; Description: This program asks the user to enter a number between 10 and 200. It then generates that number
;              of random integers, ranging from 100 to 999. The list of numbers will be printed. Then the numbers
;              will be sorted. The program will calculate and display the median, then print the sorted list.


INCLUDE Irvine32.inc

	MAX = 200			; constants as required in prompt
	MIN = 10
	HI = 999
	LO = 100
	NEW_LINE = 10		; to print in lines of 10

.data

	input		DWORD	?
	array		DWORD	MAX	DUP(?)
	progName	byte	"   The Sorting Hat (but for integers, which are pretty much wizards)", 13, 10, 0
	myName		byte	"               ...Woven by David Mednikov", 13, 10, 13, 10, 13, 10, 0
	instr1		byte	"You will enter a number between 10 and 200, inclusive. Let's call this number.........x", 13, 10, 13, 10, 0
	instr2		byte	"I will generate x # of random integers, each of them between 100 and 999. I will print them out for you.", 13, 10, 13, 10, 0
	instr3		byte	"Then I will sort them, tell you the median, and print them again in descending order, because the Sorting Hat likes to waste ink.", 13, 10, 13, 10, 13, 10, 0
	getNum		byte	"Enter a number between 10 and 200: ", 0
	sortTitle	byte	"This is the sorted list:", 13, 10, 0
	unsorted	byte	"This is the unsorted list:", 13, 10, 0
	invalid		byte	"Your number was out of range! C'mon now!", 13, 10, 0
	medianIs	byte	"The median is: ", 0
	goodBye		byte	"The Sorting Hat chooses...to end this program!", 13, 10, 13, 10, 0
	oneTab		byte	" ", 9, 0

.code
main PROC

	call	Randomize			; seed Random
	call	introduction	

	push	OFFSET input		; pass by reference to get user input
	call	getData				; get input from user

	push	OFFSET array		; pass by reference because array
	push	input				; pass number of integers by value
	call	fillArray			; create array

	push	OFFSET array	
	push	input
	push	OFFSET unsorted		; pass title by reference
	call	printList			; print unsorted list

	push	OFFSET array		
	push	input
	call	sortList			; sort list using bubble sort

	push	OFFSET array
	push	input
	call	displayMedian		; calculate and print median

	push	OFFSET array
	push	input
	push	OFFSET sortTitle	
	call	printList			; print sorted list with title
	
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodBye ; c ya
	call	WriteString

	exit	; exit to operating system
main ENDP


; Procedure to introduce the program and programmer, and give the user instructions
; Receives: global variables progName, myName, instr1, instr2, instr3
; Returns: none
; Preconditions: none
; Registers changed: edx
introduction PROC

	push	ebp
	mov		ebp, esp
	
	call	CrLf
	mov		edx, OFFSET progName
	call	WriteString
	mov		edx, OFFSET myName
	call	WriteString
	mov		edx, OFFSET instr1
	call	WriteString
	mov		edx, OFFSET instr2
	call	WriteString
	mov		edx, OFFSET instr3
	call	WriteString

	pop		ebp
	ret
introduction ENDP


; Procedure to get the number of random integers numbers from user where 10 <= n <= 200
; Receives: input variable passed by reference
; Returns: saves the user's input to input variable
; Preconditions: none
; Registers changed: eax, ebx, edx
getData PROC

	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp+8]			; pointer to number of integers

tryAgain:
	mov		edx, OFFSET getNum		; ask user for input
	call	WriteString
	call	ReadInt					; get input
	cmp		eax, MIN				; check for < 10
	jl		outOfRange				; jump if <10
	cmp		eax, MAX				; cgecj for >200
	jg		outOfRange				; jump if >200
	mov		[ebx], eax				; move input to passed memory
	jmp		gotIt					; exit loop

outOfRange:							; invalid entry
	mov		edx, OFFSET invalid		; inform user of invalid entry
	call	WriteString
	jmp		tryAgain				; loop back and try again

gotIt:
	pop		ebp
	ret		4
getData	ENDP


; Procedure to fill the array with random integers
; Receives: input variable passed by value, array passed by reference
; Returns: array of n random integers
; Preconditions: none
; Registers changed: eax, ecx, edi
fillArray PROC

	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp+8]		; number of integers in loop counter
	mov		edi, [ebp+12]		; first element of array

moreNums:						; generate a random integer between 100 and 999
	mov		eax, HI				; 999 into eax
	sub		eax, LO				; subtract 100 from 999 (now 899)
	inc		eax					; add 1 (now 900)
	call	RandomRange			; generate number ween 0 and 899
	add		eax, LO				; add 100 so that random int is between 100 and 999

	mov		[edi], eax			; copy integer to current element of array
	add		edi, 4				; move to next element
	loop	moreNums			; repeat for all integers

	pop		ebp
	ret		8
fillArray ENDP



; Procedure to print the list of random integers
; Receives: input variable passed by value, array passed by reference, title passed by reference
; Returns: none
; Preconditions: none
; Registers changed: eax, ebx, ecx, edx, edi
printList PROC

	push	ebp
	mov		ebp, esp
	mov		edx, [ebp+8]			; title
	mov		ecx, [ebp+12]			; loop counter
	mov		edi, [ebp+16]			; first element of array
	mov		ebx, 0					; set elements per row counter to 0
	call	CrLf
	call	WriteString				; print title

keepPrinting:
	mov		eax, [edi]				; copy current element to eax
	call	WriteDec				; print to screen
	mov		edx, OFFSET oneTab		; move over one tab
	call	WriteString
	add		edi, 4					; increment array pointer
	inc		ebx						; increment elements per row counter
	cmp		ebx, NEW_LINE			; check if 10 elements in row
	je		newLine					; new line if 10 elements
	loop	keepPrinting			; loop back to top and keep printing
	jmp		donePrinting			; printed all integers

newLine:
	mov		ebx, 0					; reset per row counter to 0
	call	CrLf					; new line
	loop	keepPrinting			; loop back to top

donePrinting:
	pop		ebp
	ret		12
printList ENDP



; Procedure to sort the list of random integers using bubble sort
; Receives: input variable passed by value, array passed by reference
; Returns: sorted array of random integers
; Preconditions: none
; Registers changed: eax, ebx, ecx, edi
sortList PROC

	push	ebp
	mov		ebp, esp

	mov		ecx, [ebp+8]		; copy number of integers to loop counter
	dec		ecx					; decrement by 1 for sorting
	mov		[ebp+8], ecx		; update passed variable
	mov		edi, [ebp+12]		; point to first element of array

keepSorting:	
	mov		eax, [edi]			; copy current element to eax
	mov		ebx, [edi+4]		; copy next element to ebx
	cmp		eax, ebx			; comper the two
	jl		swap				; if first element is less than second, swap them
	add		edi, 4				; increment array pointer
	loop	keepSorting			; loop back and keep sorting
	jmp		sorted				; list is sorted

swap:							; swap 1st and 2nd elements
	mov		[edi], ebx			; move 2nd num to 1st spot
	mov		[edi+4], eax		; move current num to 2nd spot
	add		edi, 4				; increment array pointer
	loop	keepSorting			; loop back and keep sorting

sorted:							; last integer is sorted, reset ecx counter to sort up to n-1th integer and repeat
	mov		ecx, [ebp+8]		; move counter to ecx
	dec		ecx					; decrement by 1
	cmp		ecx, 0				; check if fully sorted
	je		done				; fully sorted so jump our
	mov		[ebp+8], ecx		; not fully sorted, copy new counter variable to argument
	mov		edi, [ebp+12]		; point to first element
	jmp		keepSorting			; keep sorting

done:
	pop		ebp
	ret		8
sortList ENDP



; Procedure to calculate and display the median of the sorted random integers
; Receives: input variable passed by value, sorted array passed by reference
; Returns: none
; Preconditions: none
; Registers changed: eax, ebx, edx, edi
displayMedian PROC

	push	ebp
	mov		ebp, esp

	mov		eax, [ebp+8]				; copy input to eax
	mov		edi, [ebp+12]				; first element to edi

	mov		ebx, 2						; copy 2 to ebx for division
	mov		edx, 0						; set up edx for division
	div		ebx							; divide input by 2
	cmp		edx, 0						; compare remainder with 2, if even, get average of 2 middle nums
	je		getAverage

										; odd number of elements
	mov		ebx, 4						; move 4 to ebx to get mem address
	mul		ebx							; multiply 1/2 * number of elements by 4
	add		edi, eax					; incremenent pointer from first variable to median
	mov		eax, [edi]					; copy median to eax
	jmp		printIt						; print median

getAverage:								; even number of elements so need average of two middle values
	dec		eax							; eax = half of number of total elements, decrement by 1
	mov		ebx, 4						
	mul		ebx							; multiply eax by 4 to get memory offset
	add		edi, eax					; add eax to stack pointer for "left middle" element
	mov		eax, [edi]					; copy "left middle" element into eax
	mov		ebx, [edi+4]				; copy "right middle" element into ebx
	add		eax, ebx					; add two middle elements together
	mov		ebx, 2						; move 2 to ebx for division
	mov		edx, 0						; set up edx for division
	div		ebx							; divide eax by 2
	cmp		edx, 1						; compare remainder to 1
	je		round						; if remainder = 1, round up
	jmp		printIt						; no remainder, print median

round:									; remainder = 1 so round up
	inc		eax							; increment quotient

printIt:
	call	CrLf						; blank lines
	call	CrLf
	mov		edx, OFFSET medianIs		; print string
	call	WriteString
	call	WriteDec					; print median in eax
	call	CrLf

	pop		ebp
	ret		8
displayMedian ENDP

END main