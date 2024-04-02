;:=============================================================================================================================
;: MyPrintf                  
;:=============================================================================================================================

section .text

global _start                  

_start:         
;fill the stack
                push arg2
                push arg1
                push formatStr
                
                mov rbx, 0                       
                mov r8, [rsp]                             

D:              mov rbp, r8
                mov rcx, -1
A:              cmp byte [rbp], '%'
                je B
                cmp byte [rbp], 0
                je B
                inc rbp
                loop A                                 

B:              mov rsi, r8
                mov rdx, rbp
                sub rdx, r8
                call print_string
                mov r8, rbp
                add r8, 2

                cmp byte [rbp], 0
                je Done

E:              cmp byte [rbp+1], '%'
                jne C

                mov rsi, percent
                mov rdx, 1
                call print_string
                jmp D

C:              inc bx
                mov rcx, -1
                mov rdi, [rsp+8*rbx] 
                xor rax, rax
                repne scasb

                sub rdi, [rsp+rbx*8]         
                mov rdx, rdi
                mov rsi, [rsp+rbx*8]
                call print_string 
                jmp D

; return 0
Done:           mov rax, 0x3C      
                xor rdi, rdi
                syscall

;---------------------------------------------------------------------------------------------------------------------------
; Output a string to standard output
; Entry: rsi - line address; rdx - line length
; Destroy: rax, rdi	
; Returns: -
;---------------------------------------------------------------------------------------------------------------------------
print_string:   mov rax, 0x1            
                mov rdi, 1
                syscall

                ret

section .data

formatStr       db      "%%%", 0
arg1            db      "Egorik", 0
arg2            db      65
percent         db      '%'