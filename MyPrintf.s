;:=============================================================================================================================
;: MyPrintf                  
;:=============================================================================================================================

;---------------------------------------------------------------------------------------------------------------------------
section .data

formatStr       db      "Hello to %s. Your age is age %d%c", 0
arg1            db      "Egorik", 0
arg2            equ      -23465346                                 ;    -2^31 (-2147483648) <= x <= 2^31 - 1 (2147483647)
arg3            equ      '.'

percent         db      '%'
minus           db      '-'
entr            db      10
symbol          db      0

unSpec          db      10, "Unknown specificator - "
len             equ     $ - unSpec                 
;---------------------------------------------------------------------------------------------------------------------------

;---------------------------------------------------------------------------------------------------------------------------
section .text

global _start                  

_start:         
;fill the stack
                push arg3
                push arg2
                push arg1
                push formatStr
                
                xor rbx, rbx                       
                mov r8, [rsp]                             

D:              mov rbp, r8
                mov rcx, -1                     ; rsp too large
A:              cmp byte [rbp], '%'
                je B                            ; if([rbp] == '%' || [rbp] == '\0')
                cmp byte [rbp], 0
                je B
                inc rbp
                loop A                                 

B:              mov rsi, r8
                mov rdx, rbp
                sub rdx, r8
                call write
                mov r8, rbp
                add r8, 2                       ;skip specifier

                cmp byte [rbp], 0
                je Done
                cmp byte [rbp+1], '%'
                jb .Err
                cmp byte [rbp+1], 's'
                ja .Err

                xor rax, rax
                mov al, byte [rbp+1]
                sub  al, '%'
                mov rax, [.JumpTable + 8*rax]
                jmp rax

.JumpTable:     
                                dq      .percent
        times 'c' - '%' - 1     dq      .Err
                                dq      .c
                                dq      .d
        times 's' - 'd' - 1     dq      .Err
                                dq      .s

.percent:       mov rsi, percent
                mov rdx, 1
                call write
                jmp D

.d:             inc bl
                mov eax, dword [rsp+8*rbx]
                call print_number
                jmp D

.c:             inc bl 
                mov rax, 8
                mul bl
                mov rsi, rsp
                add rsi, rax
                mov rdx, 1                              
                call write
                jmp D 

.s:             inc bl
                mov rsi, [rsp+8*rbx]
                call print_string
                jmp D

.Err:           mov rsi, unSpec
                mov rdx, len
                call write

                mov rsi, rbp
                mov rdx, 2
                call write

Done:           mov rsi, entr
                mov rdx, 1
                call write

                mov rax, 0x3C                           ; return 0
                xor rdi, rdi
                syscall

;---------------------------------------------------------------------------------------------------------------------------
; Output a string to standard output
; Entry: rsi - line address; rdx - line length
; Destroy: rax, rdi	
; Returns: -
;---------------------------------------------------------------------------------------------------------------------------
write:          push rax 
                push rdi

                mov rax, 1            
                mov rdi, 1
                syscall                                 ; syscal 0x1 - change value of 'rcx'

                pop rdi 
                pop rax
                ret

;---------------------------------------------------------------------------------------------------------------------------
; Outputs a decimal number to standard output
; Entry: eax - number
; Destroy: rax, rsi, rdx, r9, r10 	
; Returns: -
;---------------------------------------------------------------------------------------------------------------------------
print_number:   push rax
                push rsi
                push rdx
                push r9
                push r10

                rol eax, 1
                test eax, 1                     ;check sign
                ror eax, 1
                jz L

                neg eax
                mov rsi, minus
                mov rdx, 1                              
                call write

L:              mov r9, 10

K:              xor edx, edx 
                div r9d
                push rax
                push rdx
                mov rax, r10 
                mul r9
                mov r10, rax
                pop rdx
                pop rax
                add r10, rdx
                inc cl
                cmp eax, 0
                jne K
                
                mov rax, r10
                mov r10, rcx
Z:              xor dl, dl
                div r9
                add dl, '0'
                mov [symbol], dl

                mov rsi, symbol
                mov rdx, 1                              
                call write
                dec r10b

                cmp r10b, 0
                jne Z

                pop r10
                pop r9
                pop rdx
                pop rsi
                pop rax
                ret

;---------------------------------------------------------------------------------------------------------------------------
; Outputs a string to standard output
; Entry: rsi - address of the beginning of the line
; Destroy: rax, rcx, rdi	
; Returns: -
;---------------------------------------------------------------------------------------------------------------------------
print_string:   push rax
                push rcx
                push rdi

                mov rcx, -1
                mov rdi, rsi 
                xor rax, rax
                repne scasb

                sub rdi, rsi         
                mov rdx, rdi
                call write 

                pop rdi
                pop rcx
                pop rax
                ret