TITLE Program Template     (template.asm)

; Author: Adam Kniffin
; Course / Project ID: Project 1         Date: 6/30/2016
; Description: 
;	Write and test a MASM program to perform the following tasks:
;	1. Display your name and program title on the output screen.
;	2. Display instructions for the user.
;	3. Prompt the user to enter two numbers.
;	4. Calculate the sum, difference, product, (integer) quotient and remainder of the numbers.
;	5. Display a terminating message.
;	EC1. Repeat until the user chooses to quit
;	EC2. Validate second number is less than the first
;	EC3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001

INCLUDE Irvine32.inc

.data 

intro			BYTE	"Program 1 by Adam Kniffin", 0
instructions	BYTE	"Enter 2 numbers, and I'll show you the sum, difference, product, quotient, and remainder.", 0
prompt1			BYTE	"First number: ", 0
prompt2			BYTE	"Second number: ", 0
termMsg			BYTE	"Impressed? Goodbye!", 0
number1			DWORD	?		; First number user will enter
number2			DWORD	?		; Second number user will enter
sum				DWORD	?		; Sum of number 1 and number 2
difference		DWORD	?		; Difference of number 1 and number 2
product			DWORD	?		; Product of number 1 and number 2
quotient		DWORD	?		; Quotient of number 1 and number 2
remainder		DWORD	?		; Remainder from quotient



;below are the strings that will output in between the two numbers to the user
sumString		BYTE	" + ", 0 
diffString		BYTE	" - ", 0
prodString		BYTE	" * ", 0
quotString		BYTE	" / ", 0
remString		BYTE	"  remainder ", 0
equalString		BYTE	" = ", 0


;Extra Credit Constant Definitions
ec1Intro		BYTE	"  *EC1: Repeat until the user chooses to quit.", 0
ec1Again		BYTE	"Would you like to play again? Enter 1 for yes and 0 for no ", 0
ec2Intro		BYTE	" **EC2: Validate second number is less than the first", 0
ec2Warn			BYTE	"The second number must be less than the first.", 0
ec3Intro		BYTE	"***EC3. Calculate and display the quotient as a floating-point number, rounded to the nearest .001", 0
ec3floatStr		BYTE	"EC: Floating Point Value rounded to nearest .001: ", 0
playAnsw		DWORD	?		
dot				BYTE	".",0
thousand		DWORD	1000	; Conversion for floating point
floatRemain		DWORD	?


; (insert variable definitions here)
.code
main PROC

INPUTNUMBER:
	;Outputs the instroduction and extra credit options to the screen
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf

	mov		edx, OFFSET ec1Intro
	call	WriteString
	call	CrLf

	mov		edx, OFFSET ec2Intro
	call	WriteString
	call	CrLf

	mov		edx, OFFSET ec3Intro
	call	WriteString
	call	CrLf
	call	CrLf

	;Prints Instructions to user
	mov		edx, OFFSET instructions
	call	WriteString
	call	CrLf
	call	CrLf

	; Get two numbers from the users
	; First Number
	mov		edx, OFFSET prompt1
	call	WriteString
	call	ReadInt
	mov		number1, eax


	; Second Number
	mov		edx, OFFSET prompt2
	call	WriteString
	call	ReadInt
	mov		number2, eax
	call	CrLf

	; Determine if number 
	mov		ebx, number1
	cmp		ebx, eax
	ja		CALCULATE

	;if number1 < number2 end program
	mov		edx, OFFSET ec2Warn
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		BYE


CALCULATE:
	;addition
	mov		eax, number1
	add		eax, number2
	mov		sum, eax

	;subtraction
	mov		eax, number1
	sub		eax, number2
	mov		difference, eax

	;multiplication
	mov		eax, number1
	mov		ebx, number2
	mul		ebx
	mov		product, eax

	;division / quotient
	mov		eax, number1
	mov		ebx, number2
	mov		edx, 0
	div		ebx
	mov		quotient, eax
	mov		remainder, edx

	;remainder
	mov		edx, 0
	fild	remainder
	mov		eax, remainder
	mov		ebx, number2
	fidiv	number2
	fimul	floatRemain 
	frndint				
	fist	floatRemain
	mov		edx, 0
	mov		eax, floatRemain
	fidiv	thousand
	mov		floatRemain, eax

	;print all of the calculations
	
	;Sum print
	mov		eax, number1
	call	WriteDec
	mov		edx, OFFSET sumString
	call	WriteString
	mov		eax, number2
	call	WriteDec
	mov		edx, OFFSET equalString
	call	WriteString
	mov		eax, sum
	call	WriteDec
	call	CrLf

	;Subtract Print
	mov		eax, number1
	call	WriteDec
	mov		edx, OFFSET diffString
	call	WriteString
	mov		eax, number2
	call	WriteDec
	mov		edx, OFFSET equalString
	call	WriteString
	mov		eax, difference
	call	WriteDec
	call	CrLf

	;Product / Multiplication Print
	mov		eax, number1
	call	WriteDec
	mov		edx, OFFSET prodString
	call	WriteString
	mov		eax, number2
	call	WriteDec
	mov		edx, OFFSET equalString
	call	WriteString
	mov		eax, product
	call	WriteDec
	call	CrLf

	;Quotient / Division Print
	mov		eax, number1
	call	WriteDec
	mov		edx, OFFSET quotString
	call	WriteString
	mov		eax, number2
	call	WriteDec
	mov		edx, OFFSET equalString
	call	WriteString
	mov		eax, quotient
	call	WriteDec

	;Remainder Print
	mov		edx, OFFSET remString
	call	WriteString
	mov		eax, remainder
	call	WriteDec
	call	CrLf

	;Asks user if they would like to play again
	mov		edx, OFFSET ec1Again
	call	WriteString
	call	readInt
	call	CrLf
	mov		playAnsw, eax	
	mov		eax, 1
	cmp		eax, playAnsw
	je		INPUTNUMBER

BYE:
	;terminate program
	mov		edx, OFFSET termMsg
	call	WriteString
	call	CrLf

	exit	; exit to operating system
main ENDP
END main
