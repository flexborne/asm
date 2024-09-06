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

    add eax, ebx
    add eax, ecx

    ; Store the result in the reserved memory location
    mov [result], eax    ; Store the value of EAX in the result variable

    mov rdi, [result]   ; Set as error code for simple res validation
    mov rax, 60
    syscall