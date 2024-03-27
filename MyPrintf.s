;:================================================
;: MyPrintf                  
;:================================================

section .text

global _start                  

_start:    
;we are looking for the length of the string with the program name
            mov rdi, [rsp+8]                ;we will get in RDI the address of the path to the file that was used when calling
            xor rax, rax                    
            mov rcx, -1                     ;the file paths can be long, we put a very large number in rcx
            repne scasb                     ;looking for a null byte        do{rdi++; } while(cx != 0 && al != [rdi])
            mov byte [rdi-1], 0ah           ;0ah = '\n'
            sub rdi, [rsp+8]                ;get line length   

;output the line
            mov rax, 0x1
            mov rdx, rdi
            mov rdi, 1
            mov rsi, [rsp+8]
            syscall

; return 0
            mov rax, 0x3C      
            xor rdi, rdi
            syscall
