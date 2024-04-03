;:=============================================================================================================================
;: MyPrintf                  
;:=============================================================================================================================

section .text

global _start                  

_start:         
;fill the stack
                push arg3
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

_pc:            cmp byte [rbp+1], '%'
                jne _d

                mov rsi, percent
                mov rdx, 1
                call print_string
                jmp D

_d:             cmp byte [rbp+1], 'd'
                jne _c

                inc bx
                mov r9, [rsp+8*rbx]

                mov rcx, 10
                xor r10, r10
        M:      mov rdi, arrNumber
                add rdi, r10
                inc r10
                mov byte [rdi], 0
                loop M

                mov eax, dword [r9]
                xor r10b, r10b
                mov r9, 10
        N:      xor rdx, rdx
                div r9d
                add dl, 48
                mov rdi, arrNumber+10
                sub rdi, r10

                mov [rdi], dl

                inc r10b
                cmp eax, 0
                jne N

                mov rsi, arrNumber
                mov rdx, 11
                call print_string 
                jmp D

_c:             cmp word [rbp+1], 'с'
                jne _s

                inc bx
                mov rsi, [rsp+8*rbx]
                mov rdx, 1
                call print_string
                jmp D 

_s:             inc bx
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
Done:           mov rsi, entr
                mov rdx, 1
                call print_string

                mov rax, 0x3C      
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

;---------------------------------------------------------------------------------------------------------------------------
section .data

formatStr       db      "%c %d Hello %s", 0
arg1            db      30
arg2            dd      3
arg3            db      "Egorik", 0                                    ;    -2^31 (-2147483648) <= x <= 2^31 - 1 (2147483647)
arrNumber       times  11 db 0
percent         db      '%'
entr            db      10
;---------------------------------------------------------------------------------------------------------------------------