TITLE Program Template     (template.asm)

; Author: Adam Kniffin
; Course / Project ID  CS 271 / Assignment 2        Date: 7/9/2016
; Description: Write a program to calculate Fibonacci numbers.
;	• Display the program title and programmer’s name. Then get the user’s name, and greet the user.
;	• Prompt the user to enter the number of Fibonacci terms to be displayed. Advise the user to enter an integer
;	  in the range [1 .. 46].
;	• Get and validate the user input (n).
;	• Calculate and display all of the Fibonacci numbers up to and including the nth term. The results should be
;	  displayed 5 terms per line with at least 5 spaces between terms.
;	• Display a parting message that includes the user’s name, and terminate the program.

INCLUDE Irvine32.inc

.data

;Below are all of the prompts that will be used in the program
intro			BYTE	"Fibonacci Numbers", 0
author			BYTE	"Programmed by Adam Kniffin", 0
promptName		BYTE	"What's your name? ", 0
promptHello		BYTE	"Hello, ", 0
promptFib		BYTE	"Enter the number of Fibonacci terms to be displayed", 0
promptRange		BYTE	"Give the number as an integer in the range [1 .. 46]", 0
promptTerms		BYTE	"How many Fibonacci terms do you want? ", 0
promptRangeErr	BYTE	"Out of range. Enter a number in [1 .. 46]", 0
certified		BYTE	"Results certified by Adam Kniffin", 0
goodbye			BYTE	"Goodbye, ", 0
spacing			BYTE	"     ", 0			;5 spaces 


;below are different variables that will be entered by the user
userName	DWORD	32 DUP(0)	;variable to hold user's name
numberOfFib	DWORD	?			;number of fibonacci numbers to display based on users response
prev		DWORD	?			;stores previous fibonacci number
value		DWORD	?			;stores value of the fibonacci number
rowCount	DWORD	?			;counts how many numbers are in the row


.code
main PROC

	;intro prompts to display to the user
		mov		edx, OFFSET intro
		call	WriteString
		call	CrLf
		mov		edx, OFFSET author
		call	WriteString
		call	CrLf
		call	CrLf

	;Prompts user for name, and gets it using ReadString
		mov		edx, OFFSET promptName 
		call	WriteString				;asks user for their name
		mov		edx, OFFSET	userName
		mov		ecx, SIZEOF userName
		call	ReadString
	
	;Greet the user now that we know their name
		mov		edx, OFFSET	promptHello
		call	WriteString
		mov		edx, OFFSET userName	;print their name after Hello
		call	WriteString	
		call	CrLf

	;Instructions to print out
		mov		edx, OFFSET promptFib
		call	WriteString
		call	CrLf	
		mov		edx, OFFSET promptRange
		call	WriteString
		call	CrLf
		call	CrLf
	

ENTERTERMS:
	;Get the number of fibonacci terms from user
		mov		edx, OFFSET promptTerms
		call	WriteString
		call	ReadInt

	;Validate the user's response to see if it is within the limits (1 to 46)
		cmp		eax, 1			;validate user response is 1 or more
		jl		USERERROR		;jump if less than 1 to USERERROR
		cmp		eax, 46			;validate user response is 46 or less
		jg		USERERROR		;jump if greater than 46 to USERERROR section
		call	CrLF
		jmp		TERMSOKAY		;validation successful, jumpt to the TERMSOKAY section

			

TERMSOKAY:
	;The user's fibonacci terms have been validated and are okay
		mov		numberOfFib, eax		;move the value stored in eax, to numberOfFib (so we can decrement each iteration)
	
	;start by moving some numbers around so we can begin calculations
		mov		eax, 0
		mov		ebx, 1
		mov		value, 1				;set value at 1 for the start of the sequence
		mov		prev, 0					;since there are no previous calculations, prev will be set to 0
		mov		rowCount, 1				;one number in the row at the moment

		;display the first fibonacci number (1) in this case
		mov		eax, value	
		call	WriteDec	
		dec		numberOfFib				;decrement the numberOfFibs left to display

		;compare the number of terms left to display, if less than 1 to BYE message
		cmp		numberOfFib, 1			;check to make sure user didnt only ask for 1 number in the sequence
		jl		BYE						;if they asked for 1 fibonacci number, jump to closing

	
FIBLOOP:	;Enter the fibonacci loop that will calculate and display the fibonacci sequence in the amount the user specified

	;add the value currently being held, to the previous fibonacci number
		mov		eax, value
		add		eax, prev		;add value and the previous value
		mov		value, eax		;move that term from eax to value
		
		;move value in ebx, to previous value
		mov		prev, ebx
		mov		edx, OFFSET spacing		;create 5 spaces in between numbers
		call	WriteString
		mov		ebx, value				;move the value into ebx
		
		;compare the number of terms left to display, if less than 1 to BYE message
		cmp		numberOfFib, 1		
		jl		BYE						

		;check to see if the row is at capacity
		cmp		rowCount, 5
		jl		INROW					;jump to the same row (INROW) if less than 5
		cmp		rowCount, 5
		je		NEWROW					;jump to new row (NEWROW) if row count is at 5 (=)

		
NEWROW:	;value is at 5 and a new row needs to be created

		;create a new line and reset the count in the row to 0
		call	CrLf
		mov		rowCount, 0
	
	
INROW:	;if the numbers can continue to be counted in the same row i.e. 5 or less
		call	WriteDec		
		mov		edx, rowCount
		inc		edx					;increment the row count by 1
		mov		rowCount, edx		
		dec		numberOfFib			;decrement the number of fibonacci terms to display
		loop	FIBLOOP
		
	
USERERROR:	;user has made an error in their input, and will take them back to input section
		mov		edx, OFFSET promptRangeErr
		call	WriteString
		call	CrLf
		jmp		ENTERTERMS				;jump back to where the user can enter terms


BYE:
	;Print out the certification and goodbye prompts
	call	CrLf
	call	CrLf
	mov		edx, OFFSET certified
	call	WriteString
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf


	exit	; exit to operating system
main ENDP

END main
