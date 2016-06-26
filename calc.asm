;author - http://github.com/flouthoc
;Contributers - Add your name here
;; ----------------- calc.asm - Minimal arithmetic calculator in x86 assembly -------------------
section .data
	FEW_ARGS: db "To Few Arguments", 0xA
	INVALID_OPERATOR: db "Invalid Operator", 0xA
	INVALID_OPERAND: db "Invalid Operand", 0XA
	BYTE_BUFFER: times 10 db 0 ;Its just a memory to size 10 , each slot holds the value 0

section .text

	global _start

_start:
	pop rdx ;remove argc its not important for me
	cmp rdx, 4 ;if number of arguments are lesser that 4 i.e <operator> <operand1> <operand2>
	jne few_args ; go to error block - promt 'FEW_ARGS' and exit
	add rsp, 8 ; remove argv[0] that is programme name
	pop rsi ;lets pop our first argument (i.e argv[1]) from argument stack which is our operand

	;This is part is all checking part which switches the block according to our <operand> + - / *
	cmp byte[rsi], 0x2A ;If operator is '*' then goto block multiplication , can be used only if escaped manually while giving input 
        je multiplication
	cmp byte[rsi], 0x78 ;If operator is 'x' then goto block multiplication , cause you know some shells or every have '*' as wildcard
	je multiplication
	cmp byte[rsi], 0x2B ;If operator is '+' then goto block addition
	je addition
	cmp byte[rsi], 0x2D ;If operator is '-' then goto block subtraction
	je subtraction
	cmp byte[rsi], 0x2F ;If operator is '/' then goto block division 
	je division

	;If <operator> does not match to any case then goto block invalid_operator
	jmp invalid_operator ; go to error block - promt 'Invalid Operator' and exit

addition:
	pop rsi ;Lets Pop our second argument (i.e argv[2]) from argument stack which is our <operand1>
	;Well even if it is a number it is in its ASCII code representation lets convert it to our actual integer
	;This is function will take number in its ASCII form (rsi as arugment) and return its integer equivalent in rax
	call char_to_int
	mov r10, rax ;Lets store integer equivalent of <operand1> in r10
	pop rsi ;Lets Pop our third argument (i.e argv[3]) from argument stack which is our <operand2>
	call char_to_int ;Do same for <operand2>
	add rax, r10 ;Lets add them integer equivalent of <operand1> and integer equivalent of <operand2> 
	jmp print_result ;Throw cursor at block print cursor , well we have to print result right ?

;Same thing we are doing in block subtration , multiplication and division

subtraction:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	sub rax, r10
	jmp print_result

multiplication:
	pop rsi
        call char_to_int
        mov r10, rax
        pop rsi
        call char_to_int
	mul r10
	jmp print_result

division:
	pop rsi
	call char_to_int
	mov r10, rax
	pop rsi
	call char_to_int
	mov rdx, 0
	div r10
	jmp print_result


;This block is responsible for printing the content to the screen
;you have to store your content in rax and jump to it , it'll do the rest :) 
print_result:
	;This function will convert our integer in rax back to ASCII format (character)
	; Argument - takes integer to be converted (must be stored in rax)
	; Returns pointer to the char string (returns r9 as pointer to the string or char) 
	call int_to_char 
	mov rax, 1 ;Store syscall number , 1 is for sys_write
	mov rdi, 1 ;Descriptor where we want to write , 1 is for stdout
	mov rsi, r9 ;This is pointer to the string which was returned by int_to_char
	mov rdx, r11 ;r11 stores the number of chars in our string , read about how to make syscall in asm
	syscall ;intruppt , give the wheel to OS it'll handle your systemcall
	jmp exit


;Read previous comments , just performing printing in these blocks nothing special	
few_args:
	mov rax, 1
	mov rdi, 1
	mov rsi, FEW_ARGS
	mov rdx, 17
	syscall
	jmp exit

invalid_operator:
	mov rax, 1
	mov rdi, 1
	mov rsi, INVALID_OPERATOR
	mov rdx, 17
	syscall
	jmp exit

invalid_operand:
	mov rax, 1
	mov rdi, 1
	mov rsi, INVALID_OPERAND
	mov rdx, 16
	syscall
	jmp exit


;This is the function which will convert our character input to integeters
;Argument - pointer to string or char ( takes rsi as argument )
;Returns equivalent integer value (in rax)
char_to_int:
	xor al, al ;store zero in al
	xor cl, cl ;same
	mov dl, 10
	
.loop_block:

	;REMEMBER rsi is base address to the string which we want to convert to integer equivalent

	mov cl, [rsi] ;Store value at address (rsi + 0) or (rsi + index) in cl, rsi is incremented below so dont worry about where is index.
	cmp cl, byte 0 ;If value at address (rsi + index ) is byte 0 , means our string is terminated here
	je .return_block

	;Each digit must be between 0 and 9
	cmp cl, 0x30 ;If value is lesser than 0 goto invalid operand 
	jl invalid_operand
	cmp cl, 0x39 ;If value is greater than 9 goto invalid operand
	jg invalid_operand

	sub cl, 48 ;Convert ASCII to integer by subtracting 48 , google about it
	mul dl ;Is it the most significant digit and other digits are also there in number then shift its place like unit-to-tenth , tenth-to-hundred.
	add al, cl ;Add other digit to the exisitng greater number like if number is 23 then add 3 to 20.
	inc rsi ;Increment the rsi's index i.e (rdi + index ) we are incrementing the index

	jmp .loop_block ;Keep looping until loop breaks on its own

.return_block:
	ret


;This is the function which will convert our integers back to characters
;Argument - Integer Value in rax
;Returns pointer to equivalent string (in r9)
int_to_char:
	mov rbx, 10
	;We have declared a memory which we will use as buffer to store our result
	mov r9, BYTE_BUFFER+10 ;We are are storing the number in backward order like LSB in 10 index and decrementing index as we move to MSB
	mov [r9], byte 0 ;Store NULL terminating byte in last slot
	dec r9 ;Decrement memory index
	mov [r9], byte 0XA ;Store break line
	dec r9 ;Decrement memory index
	mov r11, 2;r11 will store the size of our string stored in buffer we will use it while printing as argument to sys_write 

.loop_block:
	mov rdx, 0 
	div rbx    ;Get the LSB by dividing number by 10 , LSB will be remainder like 23 divider 10 will give us 3 as remainder which is LSB here
	cmp rax, 0 ;If rax becomes 0 our procedure reached to the MSB of the number we should leave now
        je .return_block
        add dl, 48 ;Convert each digit to its ASCII value
        mov [r9], dl ;Store the ASCII value in memory by using r9 as index
        dec r9 ;Dont forget to decrement r9 remember we are using memory backwards
	inc r11 ;Increment size as soon as you add a digit in memory
        jmp .loop_block ;Loop until it breaks on its own
	
.return_block:
	add dl, 48 ;Dont forget to repeat the routine for out last MSB as loop ended early
	mov [r9], dl
	dec r9
	inc r11
	ret

exit:
	mov rax, 60
	mov rdi, 0
	syscall

;We are all done :) If you think you can improve this more make a pull request (http://github.com/flouthoc/calc.asm)



	
