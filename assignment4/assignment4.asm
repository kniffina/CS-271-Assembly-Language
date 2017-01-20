TITLE Program Template     (template.asm)

; Author: Adam Kniffin
; Course / Project ID: CS 271 / Assignment 4       Date: 7/29/2016
; Description:
;	Write and test a MASM program to perform the following tasks:
;	1. Introduce the program.
;	2. Get a user request in the range [min = 10 .. max = 200].
;	3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
;		of an array.	
;	4. Display the list of integers before sorting, 10 numbers per line.
;	5. Sort the list in descending order (i.e., largest first).
;	6. Calculate and display the median value, rounded to the nearest integer.
;	7. Display the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc

;constants declaration
	MIN = 10
	MAX = 200
	LO = 100
	HI = 999

.data
;---- Strings that will be used to display information to the user
	titleMsg	BYTE	"Sorting Random Integers				Programmed By Adam Kniffin", 0
	description1	BYTE	"This program generates random numbers in the range [100 .. 900]", 0
	description2	BYTE	"displays the original list, sorts the list, and calculates the", 0
	description3	BYTE	"median value. Finally it displays the list sorted in descending order.", 0
	numberDisp	BYTE	"How many numbers should be generated? [10 .. 200]: ", 0
	errorMsg	BYTE	"Invalid Input", 0	
	unsortedMsg	BYTE	"The unsorted random numbers: ", 0
	medianMsg	BYTE	"The median is ", 0
	sortedMsg	BYTE	"The sorted list: ", 0

;---- Other variables that will be used	
	spaces		BYTE	"  ", 0		;used to seperate numbers from eachother 
	request		DWORD	?			;variable to hold input that user enters	
	array		DWORD	MAX DUP(?)	;array that holds max (200) DWORD's
		

.code

.code
main PROC
;---- make a call to randomize once at the beginning of the program
	call	Randomize

;----  ***  introduction   ***
	;---- call Introduction to display what to do to the user
	call	introduction			;ESP

;---- ***  getData   ***
;---- push address of request to stack
	push	OFFSET request			;ESP + 4
	call	getData					;ESP

;----  ***  fillArray  ***
;---- push the address of array to stack and value of request
	push	OFFSET array			;ESP + 8
	push	request					;ESP + 4
	call	fillArray				;ESP

;---- ***  displayList  ***
;---- push address of array onto stack and request by value. Push the string that will be used onto stack as well
	push	OFFSET array			;ESP + 12
	push	request					;ESP + 8
	push	OFFSET unsortedMsg		;ESP + 4		NOTE: use a stack reference so we can change messages later
	call	displayList				;ESP	

;---- ***  sortList  ***
;---- push address of array and the request onto the stack. Call sortList
	push	OFFSET array			;ESP + 8
	push	request					;ESP + 4
	call	sortList				;ESP

;---- *** displayMedian ***
;---- push address of array, and request value on the stack, and call displayMedian
	push	OFFSET array			;ESP + 8
	push	request					;ESP + 4
	call	displayMedian			;ESP

;---- ***  displayList  ***
;---- push address of array onto stack and request by value. Push the string that will be used onto stack as well
	push	OFFSET array			;ESP + 12
	push	request					;ESP + 8
	push	OFFSET sortedMsg		;ESP + 4		NOTE: use a stack reference so we can change messages later
	call	displayList				;ESP	

	call	CrLF					;for spacing
	exit	; exit to operating system
main ENDP

;**************************************************************
;******			introduction							*******
;**************************************************************
;* procedure to display the insturctions to the user
;* receives: nothing
;* returns: nothing
;* register(s) changed: edx
;**************************************************************
introduction PROC
	;---- all calls simply move the address of messages to edx, and then WriteString is called.
	;---- this is done a total of 4 times
	mov		edx, OFFSET titleMsg
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET description1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET description2
	call	WriteString
	call	CrLf

	mov		edx, OFFSET description3
	call	WriteString
	call	CrLf
	call	CrLf

	ret
introduction ENDP

;**************************************************************
;******			getData									*******
;**************************************************************
;* procedure to retrive data from the user
;* receives: request by reference
;* returns: the contents in the address of request
;* register(s) changed: eax, ebx, edx
;**************************************************************
getData PROC 
	push	ebp					;push old ebp onto stack
	mov		ebp, esp			;point esp at ebp [+ 4 to esp]
	mov		ebx, [ebp + 8]		;value of request

	ENTERNUMBERLOOP:
		;---- display prompt for user to follow, and get data from user (readInt)	
		mov		edx, OFFSET numberDisp
		call	WriteString
		call	ReadInt
		
		;---- we got the number of numbers the user wants, now check to make sure it is valid
		cmp		eax, MIN			;check to see if it is within the max number range
		jl		ERRORLOOP			;if less than MIN jump to error loop
		cmp		eax, MAX
		jg		ERRORLOOP			;if greater thenk, error and jump to display that
		jmp		DATAGOOD			;data in range, jmp to loop
			
	
	ERRORLOOP:		;---- displays that the user made an error, and jumps them to top to enter information again
		mov		edx, OFFSET errorMsg
		call	WriteString
		call	CrLf
		jmp		ENTERNUMBERLOOP
	
	DATAGOOD:
		mov		[ebx], eax			;move value in eax to request variable (address of)
		pop		ebp					;pop ebp off stack
	
	;clear the stack
	ret 4
getData ENDP


;**************************************************************
;******			fillArray								*******
;**************************************************************
;* procedure to fill the array with random values (unsorted) until
;		all of the values that the user specified have been filled.
;* receives: array address, request value
;* returns: an array address that has values stored in its contiguous memory
;* register(s) changed: eax, ecx
;**************************************************************
fillArray PROC 
	push	ebp				;push ebp onto the stack fram
	mov		ebp, esp		;point esp to ebx
	mov		edi, [ebp + 12] ;starting address of the array into edi
	mov		ecx, [ebp + 8]  ;ecx now holds the numberInput which will count down each loop

	ARRAYFILL:
		mov		eax, HI			;move HI into eax register
		sub		eax, LO + 1		;subtract the HI from LO + 1 to get the entire range
		call	RandomRange		;Produce a number inside of the range
		add		eax, LO			
		mov		[edi], eax		;transfer that number into location in array
		add		edi, 4			;increase edi by 4 (DWORD) to get to next contiguous location in memory
		loop	ARRAYFILL

		pop ebp					;pop ebp from the stack

	;clear whats left on the stack
	ret 8
fillArray ENDP

;**************************************************************
;******			displayList								*******
;**************************************************************
;* procedure to display the values in the array.
;* receives: array address, request value, and unsortedMsg by reference
;* returns: displays values in array. (nothing)
;* register(s) changed: edx, eax, ebx, ecx
;**************************************************************
displayList PROC
	push	ebp				;push ebp onto stack, +4 to all elements on stack
	mov		ebp, esp		;point esp at ebp
	mov		ecx, [ebp + 12]	;move user input to the ecx register for decrementing
	mov		esi, [ebp + 16] ;address of array to esi
	mov		ebx, 1			;will be used to count elements in row (start at 1)

	mov		edx, [ebp + 8]	;move the unsorted message into the edx register for WriteString
	call	CrLf
	call	WriteString
	call	CrLf

	DISPLAYVALUE:
		;---- determine if a new line is necessary, if not display value
		cmp		ebx, MIN	;compare ebx counter to MIN (10)	
		jg		NEWROW		;if greater than, create a new row
		mov		eax, [esi]  ;move array element into eax register
		call	WriteDec	;display the value

		;---- spacing
		mov		edx, OFFSET spaces
		call	WriteString

		add		esi, 4			;add 4 to esi to move down array (DWORD so 4)
		inc		ebx				;increment ebx
		loop	DISPLAYVALUE	;loop DISPLAYVALUE, and decrement ecx (request)
		jmp		DONE			;loop finished, jump to DONE and clear the stack
		
	NEWROW:
		call	CrLf		;create new line
		mov		ebx, 1		;move 1 into ebx
		jmp		DISPLAYVALUE	;continue displaying values

	DONE:
		pop		ebp		;done with display, pop ebp from stack
		ret	12			;clear the stack
displayList ENDP


;**************************************************************
;******			sortList								*******
;**************************************************************
;* procedure that will sort the array from ascending to
;		descending values
;* receives: array address, request value
;* returns: address of start of array that is sorted
;* register(s) changed: eax, ecx
;* NOTE: part of this code was taken from "Assembly Language for
;		x86 Processors, 7th edition." Author: Kip Irvine
;**************************************************************
sortList PROC
	push	ebp				;move ebp onto the stack
	mov		ebp, esp		;point esp at ebp
	mov		ecx, [ebp + 8]	;request that will decrement
	dec		ecx				;decrement count by 1

	;----  OUTER LOOP
	L1: 
		push	ecx					;save outer loop count
		mov		esi, [ebp + 12]		;address of beginning of array. Point at first value
	
	;---- INNER LOOP
	L2:
		mov		eax, [esi]			;get array value
		cmp		[esi +4], eax		;compare current value to the value next in memory (+4)
		jl		L3					;if it is less then, do not swap (in order) high -> low
		xchg	eax, [esi+4]		;if not less, exchange the pair so they are in order
		mov		[esi], eax									

	;---- Move down array or pop to outerloop if count is 0
	L3:
		add		esi, 4				;move to next element [esi + 4]
		loop	L2					;loop back to inner loop

		; return to outer loop
		pop		ecx						;retrieve outloop count
		loop	L1						; repeat outer loop

	;--- Outer loop counter has reached 0
	L4:
		pop		ebp						; pop what's been pushed
		ret		8						; outer loop counter down to 0,
	ret
sortList ENDP

;**************************************************************
;******			displayMedian							*******
;**************************************************************
;* procedure that calculates and determines the median value
;		of a sorted array.
;* receives: array address, request value
;* returns: Nothing. Displays the median value to user
;* register(s) changed: eax, ebx, ecx, edx
;**************************************************************
displayMedian PROC
	push	ebp				;push ebp on to stack
	mov		ebp, esp		;point esp at ebp
	mov		eax, [ebp + 8]	;value of request 
	mov		esi, [ebp + 12]	;move the address to the beginning of array into esi
	mov		edx, 0			;set edx to 0 

	mov		ebx, 2			;put two into ebx to cut array in half (depending on request)
	div		ebx				;divide array in half
	cmp		edx, 0			;if no quontient in edx then jump (no quotient means we have to calculate and there is no middle number)
	je		CALCULATEMEDIAN


	mov		ebx, 4			;move 4 into ebx
	mul		ebx				;multiply eax by ebx (4) that will take us to location in array	
	add		esi, eax		;eax's value  holds where the value we are looking for is in the array [esi]
	mov		eax, [esi]		; no remainder, no further calculations, move the value in esi at location for printing
	jmp		DISPLAY

	DISPLAY:	;---- Display's Median to the User
		call	CrLf
		call	CrLf
		mov		edx, OFFSET medianMsg
		call	WriteString
		call	WriteDec									;display element in the eax register
		call	CrLf
		jmp		DONE

	CALCULATEMEDIAN:
		;---- 2 Values are Median and we need to average the two
		mov		ebx, 4										
		mul		ebx											;multiply eax by ebx (4) that will take us to location in array
		add		esi, eax									;eax's value  holds where the value we are looking for is in the array [esi]
		mov		edx, [esi]									;store the value in the edx register

		;---- Get the position of the lower value
		mov		eax, esi									;address of value above
		sub		eax, 4										;-4, moves down 1 spot in the array
		mov		esi, eax									;we can move to esi
		mov		eax, [esi]									;and store the value in eax
		
		;----- Calculate the average between the two numbers
		add		eax, edx									;add the two values (stored in eax, and edx)
		mov		edx, 0										;value is in eax, set edx to 0 so we can divide properly
		mov		ebx, 2										;move 2 to ebx for two divide by the number of elements (calculating average)
		div		ebx											;divide the number in eax by the number in ebx (2) to get median

		jmp		DISPLAY										;calculations done, jump to DISPLAY
		
	DONE:
		pop		ebp		;pop ebp off system stack
		ret 8			;clear system stack
displayMedian ENDP

END main
