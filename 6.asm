section .bss
    buffer resb 16                ; Buffer for user input
    input_num  resd 1
    result_loop resd 1
    result_rec resd 1

section .text
    global _start


; Function: fibonacci
; Calculates the Fibonacci number for index n.
; Arguments:
;   rax - index n (input)
; Returns:
;   rax - Fibonacci number (output)
fibonacci_it:
    ; Base cases
    cmp rax, 1
    jle .base_case  ; If n <= 1, the result is n

    ; Initialize variables
    mov rbx, 0    ; fib(0) = 0
    mov rcx, 1    ; fib(1) = 1
    mov rdx, rax  ; rdx = n

    sub rdx, 1    ; Set rdx = n - 1 (we already have the first two numbers)

.loop_start:
    ; Calculate next Fibonacci number
    add rbx, rcx  ; fib(i) = fib(i - 1) + fib(i - 2)
    mov rax, rcx  ; Save fib(i - 1) to rax (for the next iteration)
    mov rcx, rbx  ; Update fib(i - 1) to the current fib(i)
    mov rbx, rax  ; Set fib(i - 2) to the previous fib(i - 1)
    
    dec rdx       ; Decrease the loop counter
    jnz .loop_start ; Continue until rdx == 0

    ; Result is in rax
    mov rax, rcx  ; Return fib(n)

.base_case:
    ret

; Function: fibonacci
; Calculates the Fibonacci number for index n.
; Arguments:
;   rax - index n (input)
; Returns:
;   rax - Fibonacci number (output)
fibonacci_rec:
    cmp rax, 1
    jle .base_case

    dec rax
    push rax ; save -1 on the stack
    call fibonacci_rec  ; calc fib(n - 2)
    ; Exchange rax, [rsp], not via xchg
    mov rbx, rax     ; Save the current value of rax in rbx
    mov rax, [rsp]   ; Load the value from the stack into rax
    mov [rsp], rbx   ; Store the saved value (original rax) into [rsp]

    dec rax
    call fibonacci_rec  ; calc fib(n - 2)
    add rax, [rsp]  ; fib(n - 2) + fib(n - 1)
    add rsp, 8  ;   undo push

.base_case:
    ret


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
        

str_to_int:
    convert:
        movzx rdx, byte [rsi]
        cmp dl, 0x0A   ; newline character
        je done
        imul rax, 10
        sub rdx, '0'
        add rax, rdx
        inc esi
        jmp convert
    done:
        ret                     ; Return with the result in rax

_start:
    
    mov rax, 3
    mov rbx, 0
    lea rcx, [buffer]
    mov rdx, 16
    int 0x80

    xor rax, rax
    lea rsi, [buffer]

    call str_to_int

    push rax
    call fibonacci_rec

    call printa

    ; Back to input rax
    pop rax

    call fibonacci_it
    call printa

exit:
    mov eax, 1   ; Set as error code for simple res validation
    xor ebx, ebx
    int 0x80