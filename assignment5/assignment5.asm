TITLE Program Template     (template.asm)

; Author: Adam Kniffin
; Course / Project ID: CS 271 / Assignment 5           Date: 8/3/2016
; Description:
;	A system is required for statistics students to use for drill and practice in combinatorics. In particular, the
;	system will ask the student to calculate the number of combinations of r items taken from a set of n items
;	(i.e., nCr ). The system generates random problems with n in [3 .. 12] and r in [1 .. n]. The student enters
;	his/her answer, and the system reports the correct answer and an evaluation of the student’s answer. The
;	system repeats until the student chooses to quit.

INCLUDE Irvine32.inc

;**************************************************************
;******			MACROS									*******
;**************************************************************
printString	Macro	buff
	push	edx
	mov		edx, OFFSET buff
	call	WriteString
	pop		edx

ENDM
;**************************************************************

;----Constants
NMIN = 3
NMAX = 12
RMIN = 1

.data
;---- Below are all of the strings that will be used to display to the user
	welcomeMsg		BYTE	"Welcome to the Combinations Calculator	    Implemented by Adam Kniffin", 0
	howtoMsg1		BYTE	"I'll give you a combinations problem. You enter your answer,", 0
	howtoMsg2		BYTE	"and I'll let you know if you're right.",0
	problem1		BYTE	"Problem: ", 0
	problem2		BYTE	"Number of elements in the set: ", 0
	problem3		BYTE	"Number of elements to choose from the set: ", 0
	problem4		BYTE	"How many ways can you choose? ", 0

	a1				BYTE	"There are ", 0
	a2				BYTE	" combinations of ", 0
	a3				BYTE	" items from a set of ", 0
	practiceMsg		BYTE	"You need more practice.", 0
	anotherMsg		BYTE	"Another problem? (y/n): ", 0
	correctMsg		BYTE	"You are correct!", 0
	invalidMsg		BYTE	"Invalid Response.  ", 0
	
	goodbye			BYTE	"OK ... goodbye.", 0
	dot				BYTE	".", 0
	yes				BYTE	"y", 0
	no				BYTE	"n", 0

	result			DWORD	?	
	n				DWORD	?				;number of elements in the set
	r				DWORD	?				;number of elements to CHOOSE from the set
	response		BYTE	10 DUP(0)		;holds the answer to yes or no from user
	userString		DWORD	33 DUP(0)		;holds the users response
	userAnswer		DWORD	?				;holds response that the user inputs

.code
main PROC
	call	Randomize
	pushad

;----Introduction call. Since strings are globals we do not need to push onto stack (per notes).
	call	introduction
	
;----This loop is going to continue until the user has specified that they want to stop
	PROBLEM:

	;----  showProblem pushes n and r onto the stack and then makes the procedure call
		push	OFFSET n			;ESI + 8
		push	OFFSET r			;ESI + 4
		call	showProblem			;ESI
	
	;---- getData pushes userAnswer onto the stack and stores the value that the user chooses
		push	OFFSET userAnswer	;ESI + 4
		call	getData

	;---- combinations pushes n and r onto the stack and the address of result
		push	n					;ESI + 12
		push	r					;ESI + 8
		push	OFFSET result		;ESI + 4
		call	combinations		;ESI

	;--- showResults pushes n, r, userAnswer, and result onto the stack and displays them to the user and tells them if they are right.
		push	n					;ESI + 16
		push	r					;ESI + 12
		push	userAnswer			;ESI + 8
		push	result				;ESI + 4
		call	showResults			;ESI

	;---- getResponse get's the user's response to if they would like to do another problem
		call	getResponse

	;---- Check to see if the response is equal to yes
		mov esi, OFFSET response	;load response
		mov	edi, OFFSET yes			;move yes into the di register
		cmpsb						;compare the two values
		je PROBLEM				;if the value is equal to "y" start process all over
		printString goodbye	
		call CrLf

		popad	;return the registers					

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
;----Using the macro to print out the welcome messages to the user
	printString		welcomeMsg
	call	CrLf

	printString		howtoMsg1
	call			CrLf

	printString		howtoMsg2
	call			CrLf
	ret
introduction ENDP

;**************************************************************
;******			showProblem								*******
;**************************************************************
;* procedure Generates the random numbers and displays the problem
;		strings to the user. Accepts address of 'n' and 'r'
;* receives: setNumber, userNumber
;* returns: value of n and r
;* register(s) changed: eax, ebx,
;**************************************************************
showProblem PROC
	push	ebp			;push ebp onto the stack
	mov		ebp, esp	;point esp at it
	pushad				;push all the general purpose registers onto the stack

	;---- get random number in the range of 3-12 
	mov		eax, NMAX	
	sub		eax, NMIN
	inc		eax
	call	RandomRange			

	add		eax, NMIN
	mov		ebx, [ebp + 12]	;move n into the ebx register
	mov		[ebx], eax		;put the random value from eax, into ebx (n)

	mov		eax, [ebx]		;value for n is moved eax to be stored as high point
	sub		eax, RMIN		;determine the range of values
	inc		eax				;increase by 1 to substitute for 0
	call	RandomRange		;get the random number

	add		eax, RMIN		
	mov		ebx, [ebp + 8]	;move 'r' into the ebx reg
	mov		[ebx], eax		;store the value in address of 'r'
	call	CrLf
	call	CrLf

	printString	problem1
	call	CrLf

	printString problem2
	mov		ebx, [ebp + 12]		;put value of n into ebx
	mov		eax, [ebx]			;address of ebx into eax
	call	WriteDec			;write down the value of 'n' to the user
	call	CrLf	

	printString problem3
	mov		ebx, [ebp + 8]		;value of r into ebx
	mov		eax, [ebx]
	call	WriteDec
	call	CrLf		

	popad			;return registers
	pop ebp			;pop ebp off stack

	ret 8			;clear stack
showProblem ENDP


;**************************************************************
;******			getData									*******
;**************************************************************
;* procedure to get the answer from the user and determine
;		if it is a valid number.
;* receives: userAnswer my reference
;* returns: value of userAnswer
;* register(s) changed: eax, ebx, ecx
;**************************************************************
getData PROC
	push	ebp			;push ebp onto the stack
	mov		ebp, esp	;point esp at it
	pushad				;push all the general purpose registers onto the stack		

	CONTINUELOOPING:
		mov		eax, 0			;
		mov		ebx, [ebp + 8]
		mov		[ebx], eax

		printString problem4	
		mov		edx, OFFSET userString
		mov		ecx, 32
		call	ReadString
		mov		ecx, eax
		mov		esi, OFFSET userString

	NEXTNUMBER:
		mov		ebx, [EBP + 8]		;move userAnswer into ebx register
		mov		eax, [ebx]			;now move it to eax
		mov		ebx, 10				
		mul		ebx					;mul userAnswer * 10
		mov		ebx, [ebp + 8]		
		mov		[ebx], eax
		mov		al, [esi]			

		cmp		al, 48
		jl		ERROR

		cmp		al, 57
		jg		error				;compare was incorrect, jump to error

		inc		esi					;incr esi to move to next position
		sub		al, 48

		mov		ebx, [ebp + 8]
		add		[ebx], al

		loop	NEXTNUMBER			;loop until ecx is 0
		jmp		ENDPROGRAM

		ERROR:
			;---- print an invalid message to user
			printString invalidMsg
			call	CrLf	
			jmp		CONTINUELOOPING

		ENDPROGRAM:
			popad			;return registers
			pop ebp			;pop ebp off stack

			ret 4			;clear the stack
getData ENDP

;**************************************************************
;******			combinations							*******
;**************************************************************
;* procedure to determine the calculations of how many elements
;		there are based on the value of n and r. Also compares
;		the userAnswer to the correct one.
;* receives: userAnswer by reference, and value of n and r
;* returns: The combinations of !n / n! (n - r)!
;* register(s) changed: eax, ebx, ecx
;**************************************************************
combinations PROC
	push	ebp			;push ebp onto the stack
	mov		ebp, esp	;point esp at it
	push	eax			;push eax, ebx, and edx onto stack
	push	ebx		
	push	edx

	sub		esp, 16		
	push	[ebp + 16]	;push n onto stack
	push	[ebp + 8]	;userAnswer onto stack by address
	call	factorial	;get the factorial for

	mov		ebx, [ebp + 8]
	mov		eax, [ebx]
	mov		DWORD PTR [ebp - 4], eax	;locally store the n!

	push	[ebp + 12]	;push r onto the stack
	push	[ebp + 8]	;push result onto the stack
	call	factorial	;get r!

	mov		ebx, [ebp + 8]
	mov		eax, [ebx]
	mov		DWORD PTR [ebp - 8], eax	;locally store the r!

	mov		eax, [ebp + 16]
	mov		ebx, [ebp + 12]
	;---- If n - r has no remainder then they are the same and (n - r) will = 1
	sub		eax, ebx
	cmp		eax, 0						;if no remainder
	je		EQUALONE					;jmp to EQUALONE
	mov		DWORD PTR [ebp -12], eax	;store the (n - r) locally

	;---- Otherwise push the values onto the stack and call factorial to calculate
	push	[ebp - 12]		
	push	[ebp + 8]
	call	factorial		;calculate (n - r)!

	mov		ebx, [ebp + 8]
	mov		eax, [ebx]
	mov		DWORD PTR [ebp - 16], eax	;store (n - r)! in locally

	;---- now that we have all of the factorials calculated and stored we have to solve the equation n! / r! (n - r)!
	mov		eax, [ebp - 8]	;put r! into eax
	mov		ebx, [ebp - 16]	;put (n - r)! into ebx
	mul		ebx				;multiply to get the result
	mov		edx, 0

	mov		ebx, eax		;store the value into ebx of the calculation r! (n - r)!
	mov		eax, [ebp - 4]	;put n! into eax for calculations
	div		ebx
	mov		ebx, [ebp + 8]
	mov		[ebx], eax

	jmp		ENDPROGRAM

	EQUALONE:
		;---- Since we know the divisor is 1. We just need the top component
		mov		eax, 1
		mov		ebx, [ebp + 8]
		mov		[ebx], eax
		mov		eax, [ebx]
		
	ENDPROGRAM:
			;---- Restore registers and remove data stored locally from stack
			pop	edx
			pop	ebx
			pop	eax
			mov	esp, ebp

			pop ebp			;pop ebp off stack

			ret 12			;clear the stack
combinations ENDP

;**************************************************************
;******			factorial							*******
;**************************************************************
;* procedure procedure is used to calculate the factorial of
;		a given number.
;* receives: userAnswer by reference, and value of n and r
;* returns: The combinations of !n, r!, and (n - r)!
;* register(s) changed: eax, ebx, ecx
;**************************************************************
factorial PROC
	push	ebp			;push ebp onto the stack
	mov		ebp, esp	;point esp at it
	pushad				;push all the general purpose registers onto the stack

	mov		eax, [ebp + 12]		
	mov		ebx, [ebp + 8]
	cmp		eax, 0
	ja		AGAIN

	mov		esi, [ebp + 8]
	mov		eax, 1
	mov		[esi], eax
	jmp		ENDPROGRAM

	;--- calculate factorial recursively
	AGAIN:
		dec		eax
		push	eax
		push	ebx
		call	factorial

		mov		esi, [ebp + 8]
		mov		ebx, [esi]
		mov		eax, [ebp + 12]
		mul		ebx
		mov		[esi], eax
	
	ENDPROGRAM:
		popad			;return registers
		pop ebp			;pop ebp off stack
		ret 8			;clear the stack

factorial ENDP

;**************************************************************
;******			showResults							*******
;**************************************************************
;* procedure displays the calculated result and the result that
;		the user entered originally. 
;* receives: n, r, userAnswer, result
;* returns: String displaying the results
;* register(s) changed: eax, edx
;**************************************************************
showResults PROC
	push	ebp			;push ebp onto the stack
	mov		ebp, esp	;point esp at it
	pushad				;push all the general purpose registers onto the stack
	call	CrLf		;spacing

	;---- Print out the Answer strings with the correct answer
	printString	a1
	mov		eax, [ebp + 8]		;move result into eax
	call	WriteDec			

	printString a2
	mov		eax, [ebp +16]		;move n into eax
	call	WriteDec

	printString a3
	mov		eax, [ebp + 20]		;mov r into eax
	call	WriteDec

	printString dot				;period and new line for formatting
	call	CrLf
	
	;---- Check to see if the user's answer matches the correct result
	mov		eax, [ebp + 12]		;user answer
	cmp	eax, [ebp + 8]		;the correct result (result)
	je		CORRECT
	jne		INCORRECT

	CORRECT:
		printString	correct
		call	CrLf
		call	CrLf
		jmp		DONE

	INCORRECT: 
		printString practiceMsg 
		call	CrLf
		call	CrLf
		jmp		DONE

	DONE:
		popad			;return registers
		pop ebp			;pop ebp off stack

		ret 16			;clear the stack
showResults ENDP

;**************************************************************
;******			getResponse								*******
;**************************************************************
;* procedure gets the response of the user if they want to do
;		another problem.
;* receives: nothing
;* returns: if the user wants to continue with another problem
;* register(s): edx, ecx
;**************************************************************
getResponse	PROC
	pushad				;push the registers onto the stack

	ANOTHERPROGRAM:
		printString	anotherMsg		
		mov		edx, OFFSET response
		mov		ecx, 9
		call	ReadString

		mov		esi, OFFSET response
		mov		edi, OFFSET yes
		cmpsb							;compare answer of user to yes
		je		DONE

		mov		esi, OFFSET response	;compare answer to no
		mov		edi, OFFSET no
		cmpsb
		je		DONE					;if response equals no, then jump to end of program
		jne		ASKAGAIN				;response not valid so re-ask questions
	
	ASKAGAIN:
		printString	invalidMsg
		jmp	ANOTHERPROGRAM

	DONE:
		popad	;return registers
		
		ret	
getResponse ENDP
END main
