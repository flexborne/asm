section .data
    arr dd 1, 3, 52, 18, 13, 1
    len equ ($ - arr) / 4

section .bss
    res resd 1

section .text
    global _start

    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; print_RAX ;;;;;;;;;;;;;;;;;;;;;;;
printa:
    ; ----------------------------------------------------------------------
    ;    TAKES
    ;        ||------> 1. RAX => The number
    ;
    ;    GIVES (void)
    ;
    ; ----------------------------------------------------------------------
section .bss 
    _char resb 2

section .text
%macro writechr 1
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, 1
    syscall
%endmacro
    pushaq
    push rax      

    mov rcx, 1            
    mov r10, 10           
    .get_divisor:
        xor rdx, rdx
        div r10           
        
        cmp rax, 0        
        je ._after        
        imul rcx, 10      
        jmp .get_divisor   

    ._after:
        pop rax           

    .to_string:
        xor rdx, rdx
        div rcx           
        
        push rdx      
        push rcx

        add al, '0'       
        mov [_char], al    

        writechr _char

        pop rcx
        xor rdx, rdx      
        mov rax, rcx     
        div r10
        mov rcx, rax     

        pop rax           
        
        cmp rcx, 0        
        jg .to_string      

    mov byte [_char], 10
    writechr _char

    popaq
    ret


_start:
    mov ecx, len

    lea rsi, [arr]
    mov eax, [rsi]
    
next:
    add rsi, 4
    dec ecx
    jz end_loop

body:
    mov ebx, [rsi]
    cmp eax, ebx
    jge it1

    mov eax, ebx
it1:
    dec ecx
    jz end_loop
    add rsi, 4

    mov ebx, [rsi]
    cmp eax, ebx
    jge it2

    mov eax, ebx

it2:
    dec ecx
    jz end_loop
    add rsi, 4

    mov ebx, [rsi]
    cmp eax, ebx
    jge it3

    mov eax, ebx
it3:
    dec ecx
    jz end_loop
    add rsi, 4

    mov ebx, [rsi]
    cmp eax, ebx
    jge next

end_loop:
    mov [res], eax

call printa

exit:
    mov eax, 1
    xor ebx, ebx 
    int 0x80
