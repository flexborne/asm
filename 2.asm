section  .data
    msg db 'DDD, SD', 0xa
    len equ $ - msg

section .bss
    reversed resb len

section  .text
    global _start

_start:
    mov rcx, len
    
    mov rsi, reversed
    
    lea rdi, [msg + len - 1]
    
body:
    mov al, [rdi]
    mov [rsi], al
    
    inc rsi
    dec rdi
        
    loop body
    
    
    mov byte [rsi], 0

    ; Show
    mov eax, 4
    mov ebx, 1
    mov ecx, reversed
    mov edx, len
    int 0x80
    
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
