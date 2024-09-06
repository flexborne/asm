section .data
    array_size    equ 64
    mmap_prot      equ 3      ; PROT_READ | PROT_WRITE
    mmap_flags     equ 34     ; MAP_PRIVATE | MAP_ANONYMOUS
    mmap_fd        equ -1     ; File descriptor for MAP_ANONYMOUS
    mmap_offset    equ 0      ; Offset for MAP_ANONYMOUS

section .bss
    first_arr resq 1
    second_arr resq 1
    first_arr_size resq 1
    second_arr_size resq 1
    status_var resq 1      ; Status variable (error codes for instance)

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

; Procedure to allocate memory for a single array
; Arguments:
;   rdi - Size of the array (in bytes)
; Returns:
;   rax - Address of allocated memory
allocate_array:
    ; Allocate memory using mmap
    mov rdx, rdi          ; Length in bytes for the array
    mov rax, mmap_prot    ; Protection flags (PROT_READ | PROT_WRITE)
    mov r10, mmap_flags   ; Flags (MAP_PRIVATE | MAP_ANONYMOUS)
    mov r8, mmap_offset   ; Offset (0)
    mov rsi, mmap_fd      ; File descriptor (MAP_ANONYMOUS)
    mov rax, 9            ; Syscall number for mmap
    syscall

    ; Return address of allocated memory in rax
    ret

; Procedure to find common elements in two arrays
; Arguments:
;   rdi - Address of the first array
;   rsi - Address of the second array
;   rcx - Number of elements in each array
; Prints first occured common element
find_common_elements:
    ; Initialize pointers and loop counters
    push rbx
    push rdx
    mov rbx, rdi          ; Pointer to first array
    mov rdx, rsi          ; Pointer to second array

    ; Outer loop over first array
outer_loop:
    mov rax, [rbx]        ; Get element from first array
    mov rdi, rsi          ; Reset pointer to second array
    mov r8, rcx          ; Number of elements
    mov r9, 0            ; Inner loop counter

    ; Inner loop over second array
inner_loop:
    cmp rax, [rdi + r9 * 8] ; Compare with element in second array
    je .found_common
    inc r9
    cmp r9, r8
    jl inner_loop

    ; Move to next element in first array
    add rbx, 8
    loop outer_loop

    ; Done
    pop rdx
    pop rbx
    ret

.found_common:
    call printa
    pop rdx
    pop rbx
    ret

; Procedure to free allocated memory
; Arguments:
;   rdi - Address of the memory to unmap
;   rsi - Size of the memory block to unmap
free_memory:
    ; Free memory using munmap
    mov rdx, rsi          ; Length of the memory block to unmap
    mov rax, 11           ; Syscall number for munmap
    syscall

    ; Return from procedure
    ret
    
_start:
    mov rdi, array_size
    call allocate_array
    mov [first_arr], rax

    mov qword [first_arr], 42
    mov qword [first_arr + 8], 33
    mov qword [first_arr + 16], 35
    
    mov rdi, array_size
    call allocate_array
    mov [second_arr], rax

    mov qword [first_arr], 43
    mov qword [first_arr + 8], 33
    mov qword [first_arr + 16], 35

    ; Perform set operations
    ; Find common elements
    mov rdi, first_arr  ; Load address of first array
    mov rsi, second_arr ; Load address of second array
    mov rcx, 3            ; Number of elements (assuming 10 for simplicity)
    call find_common_elements
    
    mov rdi, first_arr
    call free_memory

    mov rdi, second_arr
    call free_memory
exit:
    ; Exit program
    mov eax, 1   ; Set as error code for simple res validation
    xor ebx, ebx
    int 0x80