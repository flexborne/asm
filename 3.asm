section .data
    first   dd  5       
    second  dd  10 
    third   dd  17

section .bss
    result  resd 1

section .text
    global _start        

_start:
    ; Load the values into registers
    mov eax, [first]     
    mov ebx, [second]     
    mov ecx, [third]

    cmp eax, ebx  ; comparison
    jge first_greater
    mov eax, ebx

first_greater:
    cmp eax, ecx
    jge store   ; First is the biggest
    mov eax, ecx    ; Third is bigger

store:
    mov [result], eax  
exit:
    mov rdi, [result]   ; Set as error code for simple res validation
    mov rax, 60
    syscall