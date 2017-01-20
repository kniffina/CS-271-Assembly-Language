TITLE Assignment 3     (assignment3.asm)

; Author: Adam Kniffin
; Course / Project ID: CS 271 / Assignment 3        Date: 7/20/2016
; Description: This program begins by asking the user ot enter how many
; composite numbers that they would like to be shown to the console. The
; user input must be between 1 and 400, if it is not, then an error message
; will be displayed and the user will be required to enter another number. 
; Once the user's number has been identified and is within the range (1-400)
; then a composite is determine and displayed for the amount of numbers the 
; user specified. This is done by procedure calls throughout the program. 
; The results are displayed with 10 numbers for each line, and 3 spaces
; between each result.


INCLUDE Irvine32.inc

;numbers that can easily be changed that are the high
;and low limits of the user input (in case the programmer wants to change at a later date)
HIGH_LIMIT EQU 400
LOW_LIMIT EQU 1		

.data

		;below are all of the strings that will be used to output to the user
	nameAndBy		BYTE	"Composite Numbers  Programmed by Adam Kniffin", 0
	instruction1	BYTE	"Enter the number of composite numbers you would like to see.", 0
	instruction2	BYTE	"I'll accept orders for up to 400 composites.", 0
	enterNumber		BYTE	"Enter the number of composites to display [1 .. 400]: ", 0
	extraCredit		BYTE	"**EC: Align the output columns", 0
	error			BYTE	"Out of range. Try again.", 0
	endMessage		BYTE	"Results certified by Adam Kniffin. Goodbye.", 0
	spaces			BYTE	"   ", 0		;3 spaces to seperate the numbers

		;below are the 
	userNumber		DWORD	?	;number to hold input from the user
	numberCount		DWORD	?	;
	currentNumber	DWORD	4	;start of the composite numbers
	rowCount		BYTE	0	;keeps track if the output needs a new line (starts at 0)


.code
main PROC
	
	;all of the procedure calls
	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit

main ENDP

;**************************************************************
;******			introduction							*******
;**************************************************************
;* procedure is used to lay out who made the program and what
;*	 the user can expect to do while using it.
;* receives: nothing
;* returns: nothing
;* preconditions: none
;* register(s) changed: edx
;**************************************************************
introduction PROC
	mov		edx, OFFSET nameAndBy
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET instruction1
	call	WriteString
	call	CrLf

	mov		edx, OFFSET instruction2
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET extraCredit
	call	WriteString
	call	CrLf
	call	CrLf

	ret

introduction ENDP


;**************************************************************
;******			getUserData								*******
;**************************************************************
;* procedure is used to gather the number of composite numbers
;*		that they would like to be printed to the screen.
;* receives: nothing
;* returns: input from users
;* preconditions: none
;* register(s) changed: eax, edx
;**************************************************************
getUserData PROC
	mov		edx, OFFSET enterNumber
	call	WriteString

	;get the amount of numbers the user wants to go through
	call	ReadInt;
	mov		userNumber, eax
	call	validate	;call validate to check user's data entered

	ret

getUserData	ENDP

;**************************************************************
;******			checkData								*******
;**************************************************************
;* procedure checks to see if the data entered by the user is 
;*		valid
;* receives: userNumber
;* returns: whether the user data was within the limits
;* preconditions: none
;* register(s) changed: eax, edx
;**************************************************************
validate PROC
	
	;check if the number is between 1 and 400
	STARTLOOOP:
		cmp		userNumber, HIGH_LIMIT  ;check if the number is too high
		jg		ERRORLOOP		    	;if it is high, jump to error loop
		cmp		userNumber, LOW_LIMIT	;check if the number is too low
		jl		ERRORLOOP				;if it is low, jump to the error loop
		jmp		NUMBERGOOD				;otherwise, number within bounds, jump to ret

	ERRORLOOP:
		;display the error and get the user's input again
		mov		edx, OFFSET error
		call	WriteString
		call	CrLf

		
		mov		edx, OFFSET enterNumber
		call	WriteString
		call	ReadInt
		mov		userNumber, eax
		call	validate	   ;call back to the start of validate procedure
	
	;leave the procedure with ret		
	NUMBERGOOD: 
		ret
validate ENDP

;**************************************************************
;******			showComposites							*******
;**************************************************************
;* procedure to calculate and then check the first composite
;*		numbers
;* receives: userNumber
;* returns: nothing
;* preconditions: userNumber is between 1 and 400
;* register(s) changed: eax, ecx
;**************************************************************
showComposites PROC
	
	mov		ecx, userNumber		;move the userNumber into the ecx register to decrement as we loop

	COMPOSITELOOP: 
			call	isComposite			;call isComposite procedure to get next composite number / check
			mov		eax, currentNumber
			call	WriteDec			;print number
			mov		edx, OFFSET spaces	;3 spaces between numbers
			call	WriteString
			;increase all of the relevant numbers
			inc		currentNumber
			inc		numberCount
			inc		rowCount

			cmp		rowCount, 10	;check if there needs to be a new line
			je		NEWLINE
			loop	COMPOSITELOOP	;loop until userNumber is 0
			jmp		COMPOSITEDONE	;ecx register is at 0, can't loop anymore

	NEWLINE:
			;create a new line, and reset the row count
			call	CrLf
			mov		rowCount, 0
			loop	COMPOSITELOOP
		
	COMPOSITEDONE: 
			ret
showComposites ENDP


;**************************************************************
;******			isComposite								*******
;**************************************************************
;* procedure to calculate the next composite number 
;* receives: currentNumber
;* returns: currentNumber. If it was a composite number already then
;		it is not changed, if it is prime, then 1 is added to it. 
;* preconditions: if currentNumber is greater than 4 
;		(or equal to. 4 is the first number)
;* register(s) changed: eax, ebx, edx
;**************************************************************
isComposite PROC
	
	;check to see if currentNumber is even, if it is, then it classifies as composite
	mov		edx, 0
	mov		eax, currentNumber
	mov		ebx, 2		;divide the currentNumber by 2 (will determine if there is a quotient)
	div		ebx			
	cmp		edx, 0			;if it is not equal to 0, then it is NOT composite
	je		COMPOSITERETURN	;jump to COMPOSITERETURN if the number is a composite

	;check to see if currentNumber is odd. If it can be divided by 3, then it classifies as composite
	mov		edx, 0
	mov		eax, currentNumber
	mov		ebx, 3			
	div		ebx					;divide current number by 3 to see if there is a remainder
	cmp		edx, 0				;if no remainder then composite
	je		COMPOSITERETURN		;no quotient so jump to return

	;set numberCount to 5 since we know it is not divisible by 3, and is 1 more than starting
	;point. We can now move to the calculations to make it composite
	mov		numberCount, 5

	CALCULATECOMPOSITE:
		

		;set the registers so we can begin calculations
		mov		eax, currentNumber
		mov		ebx, numberCount
		mov		edx, 0			;set edx register to 0

		;compare currentNumber and numberCount. If they are equal, the number is prime
		cmp		eax, ebx	
		je		PRIME

		;if currentNumber can be divided by the numberCounter then it is composite
		div		ebx
		cmp		edx, 0
		je		COMPOSITERETURN


		add		numberCount, 2		;add 2 to the numberCount
		mov		edx, 0
		mov		eax, currentNumber
		mov		ebx, numberCount
		cmp		eax, ebx			;if eax, and ebx (currentNumber and numberCount) are equal to each
									;then the current number is prime
		je		PRIME			
		div		ebx					;if they are not check to see if they can be divided
		cmp		edx, 0			
		je		COMPOSITERETURN			

		add		numberCount, 4		
		mov		edx, 0				
		mov		eax, numberCount
		mul		numberCount			
		cmp		eax, numberCount
		jle		CALCULATECOMPOSITE

	PRIME:
		inc		currentNumber	;increase the current number by 1 to make it composite


	COMPOSITERETURN:
		ret
isComposite	ENDP



farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET endMessage
	call	WriteString
	call	CrLf

	ret
farewell ENDP

END main
