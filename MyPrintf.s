;:================================================
;: MyPrintf                  
;:================================================

section .text

global _start                  

_start:    
            mov rbx, 1                      ;index of args without first arg

scan_args:  inc rbx
;we are looking for the length of the string with the program name
            mov rdi, [rsp+8*rbx]                ;we will get in RDI the address of argument with number rbx
            xor rax, rax                    
            mov rcx, -1                     ;argument can be long, we put a very large number in rcx
            repne scasb                     ;looking for a null byte        do{rdi++; } while(cx != 0 && al != [rdi])
            mov byte [rdi-1], 0ah           ;0ah = '\n'
            sub rdi, [rsp+8*rbx]                ;get line length   

;output the line
            mov rax, 0x1
            mov rdx, rdi
            mov rdi, 1
            mov rsi, [rsp+8*rbx]
            syscall

            cmp rbx, [rsp]
            jne scan_args
; return 0
            mov rax, 0x3C      
            xor rdi, rdi
            syscall