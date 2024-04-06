;:=============================================================================================================================
;: MyPrintf                  
;:=============================================================================================================================

section .text

global _start                  

_start:         
;fill the stack
                push number
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

                mov eax, dword [r9]
                rol eax, 1
                test eax, 1
                ror eax, 1
                jz L

                neg eax
                mov rsi, minus
                mov rdx, 1                              
                call print_string

        L:      mov r9, 10

        K:      xor edx, edx 
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
        W:        
                mov rax, r10
                mov r10, rcx
        Z:      xor dl, dl
                div r9
                add dl, '0'
                mov [symbol], dl

                mov rsi, symbol
                mov rdx, 1                              
                call print_string
                dec r10b

                cmp r10b, 0
                jne Z

                jmp D

_c:             cmp byte [rbp+1], 'c'
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

Done:           mov rsi, entr
                mov rdx, 1
                call print_string

                mov rax, 0x3C                           ; return 0
                xor rdi, rdi
                syscall

;---------------------------------------------------------------------------------------------------------------------------
; Output a string to standard output
; Entry: rsi - line address; rdx - line length
; Destroy: rax, rdi	
; Returns: -
;---------------------------------------------------------------------------------------------------------------------------
print_string:   push rax 
                push rdi

                mov rax, 1            
                mov rdi, 1
                syscall                                 ; syscal 0x1 - change value of 'rcx'

                pop rdi 
                pop rax
                ret

;---------------------------------------------------------------------------------------------------------------------------
section .data

formatStr        db      "%d", 0
;arg0            db      66
;arg1            db      "Egorik", 0
;arg2            db      '.'
number           dd      -38973549822398                                  ;    -2^31 (-2147483648) <= x <= 2^31 - 1 (2147483647)

percent         db      '%'
entr            db      10
minus           db      '-'
symbol          db      0
;check           equ     
;---------------------------------------------------------------------------------------------------------------------------