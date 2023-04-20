TITLE Project 6 - String Primitives and Macros

; Author: Maya D'Souza
; Last Modified: 12/4/2022
; OSU email address: dsouzam@oregonstate.edu
; Course number/section: CS271 Section 400
; Project Number: 6      Due Date: 12/4/2022
; Description: This program will first display the title and a description of the program. It will then take 10
;	signed decimal integers. It will then display the list of numbers, the sum of the numbers,
;	and the truncated average. Last, it will display a closing message.

INCLUDE Irvine32.inc

; --------------------------------------------------------------------------------- 
; Name: mGetString
; 
; Reads string from user and stores in variable string.
; 
; Preconditions: prompt and string must be OFFSET strings and sLen must be a number of size DWORD
; 
; Receives: 
;	prompt = message to display to prompt user for a string
;	sLen = length of string entered by user
;	string = variable to store string user enters
; 
; Returns: string = string entered by user
; --------------------------------------------------------------------------------- 
mGetString MACRO prompt, string, sLen

	PUSHAD							; save registers

	; display prompt to enter string
	MOV		EDX,		prompt
	mDisplayString		EDX

	; save entered string in string
	mov		EDX,		string
	mov		ECX,		MAXSIZE
	Call	ReadString
	MOV		sLen,		EAX

	POPAD							; restore registers

ENDM

; --------------------------------------------------------------------------------- 
; Name: mDisplayString
; 
; Displays a string.
; 
; Preconditions: string must be an OFFSET string
; 
; Receives: string = message to display
; 
; Returns: None
; --------------------------------------------------------------------------------- 
mDisplayString MACRO string

	PUSHAD							; save registers

	; display string
	MOV		EDX, string
	CALL	WriteString

	POPAD							; restore registers

ENDM

; constants
ARRAYLENGTH = 10
MAXSIZE = 100

.data

	; Variables for messages
	intro			BYTE	"Program to calculate the sum and average of 10 numbers", 10,13,
							"By: Maya D'Souza",10,13,10,13,
							"Enter 10 signed decimal integers that can fit inside a 32 bit register.",10,13,
							"I will then display the list of numbers, the sum, and the average.",10,13,0
	enter_num_msg	BYTE	"Please enter a signed number: ",0
	error_msg		BYTE	"ERROR: You did not enter a signed number or your number was too large.",10,13,
							"Please try again.", 10,13,10,13,0
	closing			BYTE	"Goodbye, and thanks for using my program!",10,13,0
	list_msg		BYTE	"You entered the following numbers:",10,13,0
	sum_msg			BYTE	"The sum of these numbers is: ",0
	avg_msg			BYTE	"The truncated average is: ",0
	delimiter		BYTE	", ",0

	; Variables for calculations
	num_string		BYTE	MAXSIZE DUP(?)		; string to store number input from user
	nLen			DWORD	0					; length of num_string
	isNumber		DWORD	1					; used by checkIsNumber to tell ReadVal if value is a number
	num_array		SDWORD	ARRAYLENGTH DUP(?)	; variable to hold 10 numbers entered by user

.code

;--------------------------------------------------
; Name: main
;
; The main procedure will display the program title and my name. It will then display a message describing
; how the program works. It will then prompt the user for 10 signed integers that can fit in a 32 bit register. 
; It will then display the list of numbers, their sum, and their average.
;--------------------------------------------------
main				PROC

	;display introduction message and instructions on how program works
	PUSH	OFFSET		intro
	CALL	displayMessage

	; prompt the user for 10 numbers and input them in an array
	PUSH	OFFSET		error_msg
	PUSH	OFFSET		num_array
	PUSH	OFFSET		enter_num_msg
	PUSH	OFFSET		num_string
	PUSH	nLen
	PUSH	isNumber
	CALL	populateArray

	; show user the numbers they entered
	PUSH	OFFSET		list_msg
	PUSH	OFFSET		delimiter
	PUSH	OFFSET		num_array
	PUSH	LENGTHOF	num_array
	CALL	displayList

	; calculate and show the sum of the 10 numbers
	; calculate and show the average of the 10 numbers
	PUSH	OFFSET		avg_msg
	PUSH	OFFSET		sum_msg
	PUSH	OFFSET		num_array
	CALL	displaySumAndAvg

	; display closing message
	PUSH	OFFSET		closing
	CALL	displayMessage

	Invoke ExitProcess,0					; exit to operating system

main				ENDP

;--------------------------------------------------
; Name: displayMessage
;
; Displays input string stored in [EBP+8]
;
; Preconditions: none
; 
; Postconditions: none
;
; Recieves:
;	[EBP+8] = input string (message to display)
;
; Returns: none
;--------------------------------------------------
displayMessage		PROC

	; preserve EBP, assign static frame pointer
	PUSH	EBP
	MOV		EBP,		ESP

	; display message provided in input string
	mDisplayString		[EBP+8]
	CALL	CrLf

	; restore EBP and return
	POP		EBP
	RET		4

displayMessage		ENDP

;--------------------------------------------------
; Name: populateArray
;
; Asks users for 10 numbers and stores them in an array
;
; Preconditions: none
; 
; Postconditions: none
;
; Receives:
;	[EBP+8] = isNumber (used by helper function to tell populateArray if number is valid)
;	[EBP+12] = length of num_string
;	[EBP+16] = string entered by user to write to element in array
;	[EBP+20] = message asking user to enter number
;	[EBP+24] = array to fill with numbers from user
;	[EBP+28] = message to let user know the number they entered is invalid
;
; Returns: ;	[EBP+24] array filled with numbers from user
;--------------------------------------------------
populateArray		PROC

	; preserve EBP, assign static frame pointer, preserve registers
	PUSH	EBP
	MOV		EBP,		ESP
	PUSHAD

	; initialize loop counter to size of array
	MOV		ECX,		ARRAYLENGTH

_addElement:
	; add one element to array
	CALL	ReadVal
	LOOP	_addElement

	; restore EBP and return
	POPAD
	POP		EBP
	RET		24

populateArray		ENDP

;--------------------------------------------------
; Name: ReadVal
;
; Asks users for a number, converts the string to that number, and writes the number
;
; Preconditions: [EBP+24] should point to current array element to populate
; 
; Postconditions: none
;
; Receives:
;	[EBP+8] = isNumber (used by helper function to tell populateArray if number is valid)
;	[EBP+12] = length of num_string
;	[EBP+16] = string entered by user to write to element in array
;	[EBP+20] = message asking user to enter number
;	[EBP+24] = array to fill with numbers from user
;	[EBP+28] = message to let user know the number they entered is invalid
;
; Returns: writes value to location of [EBP+24]
;--------------------------------------------------
ReadVal				PROC

	PUSHAD									; save registers

_readVal:
	
	Call		CrLf
	mGetString	[EBP+20], [EBP+16], [EBP+12]; ask user for number

	; check if their input string is a number
	CALL		checkIsNumber
	MOV			EBX, [EBP+8]
	CMP			EBX, 0
	
	; display an error if not
	JZ			_error

	; convert their input string to a number if so
	CALL		stringToNum

	; if number is too large (or small) to fit in register, display error
	MOV			EBX, [EBP+8]
	CMP			EBX, 0
	JZ			_error
	
	JMP			_return

_error:
	mDisplayString	[EBP+28]				; tell user their input is invalid
	JMP			_readVal					; ask for new input

_return:
	POPAD									; restore registers
	RET

ReadVal				ENDP

;--------------------------------------------------
; Name: checkIsNumber
;
; Returns 1 if string is a number and 0 if not
;
; Preconditions: none
; 
; Postconditions: none
;
; Recieves:
;	[EBP+8] = isNumber (used by helper function to tell populateArray if number is valid)
;	[EBP+12] = length of num_string
;	[EBP+16] = string entered by user to write to element in array
;
; Returns: [EBP+8] changed to 0 if not a number and 1 if is a number
;--------------------------------------------------
checkIsNumber		PROC
	
	PUSHAD									; preserve registers

	CLD										; clear direction flag to move forward through string
	MOV		ECX,		[EBP+12]			; set loop counter to length of string
	MOV		ESI,		[EBP+16]			; point source to start of num_string

	; set isNumber to true
	MOV		EBX,		1					
	MOV		[EBP+8],	EBX			

_checkFirstChar:

	; move first character into AL
	; if not ASCII code for +,-,0-9 then display an error because not a number
	LODSB
	CMP		AL,			43
	JL		_error
	CMP		AL,			57
	JG		_error
	CMP		AL,			44
	JE		_error
	CMP		AL,			46
	JE		_error
	CMP		AL,			47
	JE		_error

	; iterate through remaining characters
	LOOP _checkCharLoop
	
	; if only one character long, than must be 0-9
	; if character is + or -, then display an error and return
	CMP		AL,			43
	JE		_error
	CMP		AL,			45
	JE		_error
	JMP		_return
	
_checkCharLoop:

	; if not ascii code for 0-9, display an error
	LODSB
	CMP		AL,			48
	JL		_error
	CMP		AL,			57
	JG		_error

	LOOP	_checkCharLoop
	JMP		_return

_error:
	; change isNumber to 0 to represent that string is not a number
	MOV			EBX, 0
	MOV			[EBP+8], EBX

_return:
	POPAD									; restore registers
	RET

checkIsNumber		ENDP

;--------------------------------------------------
; Name: stringToNum
;
; Converts string to a number.
;
; Preconditions: [EBP+24] should point to location to store number
; 
; Postconditions: None
;
; Recieves:
;	[EBP+12] = length of num_string
;	[EBP+16] = string entered by user to write to element in array
;	[EBP+24] = points to current element in array to write number to
;
; Returns: [EBP+24] updated to number entered by user
;--------------------------------------------------
stringToNum	PROC

	PUSHAD									; preserve registers

	; initialization 
	;clear registers/direction flag, set loop counter, and point ESI to string
	MOV		EAX,		0
	CLD
	MOV		ECX,		[EBP+12]
	MOV		ESI,		[EBP+16]
	MOV		EDX,		0
	
_checkCharLoop:

	; check if first character is a +, -, or number and move to respective code 
	LODSB
	cmp		AL,			43
	je		_positiveSign
	cmp		AL,			45
	je		_negativeSign
	jmp		_unsigned

_positiveSign:

	; initialization 
	;clear registers, and direction flag, set loop counter, and point ESI to string
	CLD
	MOV		ECX,		[EBP+12]
	MOV		ESI,		[EBP+16]
	MOV		EAX,		0
	
	LODSB									; ignore first character (+), load to point to next char
	
	LOOP			_nextDigitUnsigned

_unsigned:
	
	; initialization 
	;clear registers, and direction flag, set loop counter, and point ESI to string
	CLD
	MOV		ECX,		[EBP+12]
	MOV		ESI,		[EBP+16]
	MOV		EAX,		0
	
	; move first character into EAX, convert to digit, and add to EDX
	LODSB
	SUB		AL,			48
	ADD		EDX,		EAX
	LOOP	_nextDigitUnsigned
	JMP		_ret


_nextDigitUnsigned:

	; multiply number by 10
	MOV		EAX,		EDX
	MOV		EBX,		10
	CMP		EAX,		214748364
	JG		_error							; raise an error because number is too large
	JE		_specialconditionUnsigned		; number right on cusp, check if too large before proceeding
	IMUL	EBX

	; add next digit
	MOV		EDX,		EAX
	MOV		EAX,		0
	LODSB
	SUB		AL,			48
	ADD		EDX,		EAX
	LOOP	_nextDigitUnsigned
	JMP		_ret

_specialconditionUnsigned:					; case where number begins with 214748364..."
	IMUL	EBX
	MOV		EDX,		EAX
	MOV		EAX,		0
	LODSB
	SUB		AL,			48
	CMP		EAX,		7
	JG		_error							; number larger than 2147483647 --> too big to fit in 32-bit register
	ADD		EDX,		EAX
	LOOP	_nextDigitUnsigned
	JMP		_ret

_negativeSign:
	
	; initialization 
	;clear registers, and direction flag, set loop counter, and point ESI to string
	CLD
	MOV		ECX,		[EBP+12]
	MOV		ESI,		[EBP+16]
	MOV		EAX,		0


	LODSB									; ignore first character (+), load to point to next char
	
	LOOP	_nextDigitSigned

_nextDigitSigned:

	; multiply number by 10
	MOV		EAX,		EDX
	MOV		EBX,		10
	CMP		EAX,		214748364			
	JG		_error							; raise an error because number is too large				
	JE		_specialConditionSigned			; number right on cusp, check if too large before proceeding
	IMUL	EBX

	; add next digit
	MOV		EDX,		EAX
	MOV		EAX,		0
	LODSB
	SUB		AL,			48
	ADD		EDX,		EAX
	LOOP	_nextDigitSigned


	; multiply number by -1 to make it negative
	MOV		EAX,		EDX
	MOV		EBX,		-1
	IMUL	EBX
	MOV		EDX,		EAX
	JMP		_ret

_specialconditionSigned:

	; generate next digit
	IMUL	EBX
	MOV		EDX,		EAX
	MOV		EAX,		0
	LODSB
	SUB		AL,			48

	
	; add next digit
	CMP		EAX,		8
	JG		_error							; if digit is larger than 8 number too big (number < -2147483648)
	JE		_lowerbound						; if digit equal to 8, number = -2147483648 (move to special case to avoid overflow math)
	ADD		EDX,		EAX
	LOOP	_nextDigitSigned
	
	; multiply number by -1 to make it negative	
	MOV		EAX,		EDX
	MOV		EBX,		-1
	IMUL	EBX
	MOV		EDX,		EAX
	JMP		_ret

_lowerbound:								; special case where number starts with -2147483648
	CMP		ECX, 1
	JG		_error							; number has more digits, too big to fit in register
	MOV		EDX,		-2147483648			; number has no more digits, so exactly equal to lower bound of register
	JMP		_ret


_error:										; set error condition and exit
	MOV		EBX,		0
	MOV		[EBP+8],	EBX
	POPAD									; restore registers
	RET

_ret:	

	; number is valid, write to location in array and return
	MOV		EAX,		[EBP+24]
	MOV		[EAX],		EDX
	MOV		EBX,		4
	ADD		[EBP+24],	EBX
	POPAD									; restore registers
	RET

stringToNum ENDP

;--------------------------------------------------
; Name: writeVal
;
; Displays number stored in EAX (converts number to string and displays string)
;
; Preconditions: EAX should hold value to display
; 
; Postconditions: None
;
; Receives:
;		EAX: value to display
;
; Returns: None
;--------------------------------------------------
WriteVal			PROC
	
	LOCAL	interimString[25]:BYTE, finalString[25]:BYTE
	
	; preserve registers
	PUSHAD

	
	MOV		ECX,		0					; counter for length of string (incremented when character loaded into string)


	CLD										; clear direction flag to move forward through string
	LEA		EDI,		interimString		; set destination to interimString
	CMP		EAX,		0							
	JL		_writeValNegFirstChar			; this code accounts for negative numbers

_writeVal:									; creates string for positive numbers
	
	CDQ
	MOV		EBX,		10
	IDIV	EBX								; remainder = edx, dividend = eax
	MOV		EBX,		EAX					; save dividend in ebx
	MOV		EAX,		EDX					; move remainder to eax
	ADD		AL,			48					; convert to ascii
	STOSB									; load into string (will load smallest digit first)
	INC		ECX
	MOV		EAX,		EBX					; restore dividend to eax
	CMP		EAX,		0
	JNZ		_writeVal
	JMP		_return

_writeValNegFirstChar:						; creates first character (smallest digit) in negative numbers
	MOV		EBX,		-1
	CDQ
	MOV		EBX,		-10
	IDIV	EBX								; remainder = edx, dividend = eax

	MOV		EBX,		EAX					; save dividend in ebx
	MOV		EAX,		EDX					; move remainder to eax
	MOV		EDX,		-1
	IMUL	EDX								; make remainder positive (represents smallest digit first)
	ADD		EAX,		48					; convert to ascii
	STOSB									; load into string
	INC					ECX
	MOV		EAX,		EBX					; restore dividend to eax
	CMP		EAX,		0
	JNZ		_writeValNeg

	; add minus sign to end of string for negative numbers
	MOV		EAX,		45
	STOSB
	INC		ECX

	JMP		_return


_writeValNeg:								; writes remaining digits in string for negative numbers
	CDQ
	MOV		EBX,		10
	IDIV	EBX								; remainder = edx, dividend = eax

	MOV		EBX,		EAX					; save dividend in ebx
	MOV		EAX,		EDX					; move remainder to eax
	ADD		EAX,		48					; convert to ascii
	STOSB									; load into string
	INC		ECX
	MOV		EAX,		EBX					; restore dividend to eax
	CMP		EAX, 0
	JNZ		_writeValNeg

	; add minus sign to end of string for negative numbers
	MOV		EAX, 45
	STOSB
	INC ECX

	JMP		_return

_return:

	; Reverse the string so smallest digit is last

	; Set up loop counter and indexes (indices?)
	LEA		ESI,		interimString
	ADD		ESI,		ECX
	DEC		ESI
	LEA		EDI,		finalString
  
	; Reverse string
_revLoop:
    STD
	LODSB
    CLD
    STOSB
	LOOP   _revLoop
    
	; Null terminate the string
	MOV	EAX, 0
	STOSB

	; Display the string
	LEA EDX, finalString
	mDisplayString EDX
	
	; restore registers and return
	POPAD
	RET

WriteVal			ENDP

;--------------------------------------------------
; Name: displayList
;
; Displays the array
;
; Preconditions: None
; 
; Postconditions: None
;
; Receives:
;		[EBP+20] = Message telling user what list is
;		[EBP+16] = String ", " to put spaces between numbers when displaying them
;		[EBP+12] = Starting address of array
;		[EBP+8] = Length of array
;
; Returns: None
;--------------------------------------------------
displayList			PROC

	; preserve EBP/registers, assign static frame pointer
	PUSH	EBP
	MOV		EBP,		ESP
	PUSHAD

	; display message saying what list is
	Call	CrLf
	mDisplayString		[EBP+20]

	MOV		ECX,		10					; loop counter intialized to length of array	

_displayList:

	; display element
	MOV		ESI,		[EBP+12]
	MOV		EAX,		[ESI]
	PUSH	ECX
	CALL	WriteVal
	POP		ECX

	; display ", " after the element
	CMP		ECX,		1
	JE		_exit							; don't display comma after last element
	mDisplayString [EBP+16]

	MOV		EBX,		4
	ADD		[EBP+12],	EBX					; Increment ESI by 4 to point to next element
	
	
	LOOP	_displayList					; repeat to show next element

_exit:
	; restore EBP and return
	CALL	CrLf
	CALL	CrLf
	POPAD
	POP		EBP
	RET		16

displayList			ENDP

;--------------------------------------------------
; Name: displaySumAndAvg
;
; Calculates and displays sum and average of array
;
; Preconditions: None
; 
; Postconditions: None
;
; Receives:
;		[EBP+20] = Message telling user the average is...
;		[EBP+16] = Message telling user the sum is...
;		[EBP+8] = points to start of array
;
; Returns: None
;--------------------------------------------------
displaySumAndAvg	PROC

	; preserve EBP/registers, assign static frame pointer
	PUSH	EBP
	MOV		EBP,		ESP
	PUSHAD

	; display message "The sum of the numbers is:"
	MOV		EDX,		[EBP+12]
	mDisplayString		EDX

	MOV		ESI,		[EBP+8]				; ESI points to start of array
	MOV		ECX,		ARRAYLENGTH			; loop counter intialized to length of array
	MOV		EAX,		0					; EAX initialized to 0 (where sum will be calculated)

	; calculate sum
_sum:
	MOV		EBX,		[ESI]				; move value of first element into EBX
	ADD		EAX,		EBX					; add value to sum stored in EAX
	ADD		ESI,		4					; point to next element
	LOOP	_sum

	; display sum
	CALL	WriteVal
	CALL	CrLf

	; display message "The truncated average is:"
	MOV		EDX,		[EBP+16]
	mDisplayString		EDX

	; divide sum by array length to find average
	CDQ
	MOV		EBX,		ARRAYLENGTH
	IDIV	EBX

	; display average
	CALL	WriteVal
	CALL	CrLf
	CALL	CrLf

	; restore EBP/registers and return
	POPAD
	POP		EBP
	RET		12

displaySumAndAvg	ENDP

END main
