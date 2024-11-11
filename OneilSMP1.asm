; Samantha Erica O'Neil - S18
%include "io64.inc"

section .data
dna_var db 50 dup(0)  
orig_var db 50 dup(0)    
reversed_var db 50 dup(0)  
invalid_alphabet db "invalid DNA alphabet", 10, 0
continue_message db "Do you want to continue (Y/N)? ", 0
done_message db "Done", 10, 0
palindrome db "Reverse palindrome? Yes", 10, 0
not_palindrome db "Reverse palindrome? No", 10, 0

section .text
global main

main:
    mov rbp, rsp
start:
    GET_STRING dna_var, 100
    
    ; Step 2: Check if the last character is a newline (from the Enter key)
    ; If so, remove it
    mov rbx, dna_var       ; Load address of dna_var
    mov rsi, 0             ; Set index to 0
check_newline:
    cmp byte [rbx + rsi], 0    ; Check for null terminator
    je start_cont              ; If null terminator, done
    cmp byte [rbx + rsi], 10   ; Check for newline (ASCII value 10)
    je remove_newline         ; If newline, remove it
    inc rsi
    jmp check_newline

remove_newline:
    mov byte [rbx + rsi], 0    ; Replace newline with null terminator

start_cont:
    PRINT_STRING "DNA string: "
    PRINT_STRING dna_var
    NEWLINE
    mov rbx, dna_var
    xor ecx, ecx
    lea rsi, [dna_var]   
    lea rdi, [orig_var]
    call L1
    jmp end

copy_loop:
    mov al, byte [rsi]      
    cmp al, '.'             
    je comp_prep           
    mov byte [rdi], al      
    inc rsi                 
    inc rdi                 
    jmp copy_loop           

L1:
    cmp byte [rbx], 0
    je check_terminator
    inc ecx
    cmp ecx, 40
    jg too_long
    inc rbx
    jmp L1

check_terminator:
    cmp ecx, 0
    je null_input
    cmp byte [rbx-1], '.'
    jne invalid_terminator
    jmp L2

L2:
    mov rbx, dna_var
    xor ecx, ecx
    jmp validate_dna

validate_dna:
    cmp byte [rbx], 0
    je valid_inputs
    cmp byte [rbx], 'G'     
    je next_char
    cmp byte [rbx], 'T'       
    je next_char
    cmp byte [rbx], 'A'       
    je next_char
    cmp byte [rbx], 'C'       
    je next_char
    cmp byte [rbx], '.'     
    je next_char
    jmp invalid_dna 

next_char:
    inc rbx
    jmp validate_dna

valid_inputs:
    mov rbx, dna_var
    lea rsi, [dna_var]   
    lea rdi, [orig_var]
    jmp copy_loop
    
comp_prep:
    xor r11, r11
    mov rbx, dna_var
    mov rsi, 0
    mov rdi, 0
    mov ecx, 0

complement:
    cmp byte [rbx], 0
    je done_comp
    cmp byte [rbx], 'G'
    je compG
    cmp byte [rbx], 'T'
    je compT
    cmp byte [rbx], 'C'
    je compC
    cmp byte [rbx], 'A'
    je compA
    cmp byte [rbx], '.'
    je done_comp

compG:
    mov byte [rbx], 'C'
    inc rbx
    jmp complement
compC:
    mov byte [rbx], 'G'
    inc rbx
    jmp complement
compA:
    mov byte [rbx], 'T'
    inc rbx
    jmp complement
compT:
    mov byte [rbx], 'A'
    inc rbx
    jmp complement

done_comp:
    mov byte [rbx], 0
    xor rcx, rcx
    mov rbx, dna_var
    ;PRINT_STRING dna_var
    ;NEWLINE
    jmp length_var

length_var:
    cmp byte [rbx], 0
    je reverse
    inc rbx
    inc rcx
    jmp length_var

reverse:
    mov r9, rcx
    mov r11, rcx
    lea rsi, [dna_var + r9 - 1]
    lea rdi, reversed_var
    mov byte [rdi + r9], 0
reverse_loop:
    dec r9
    cmp r9, -1
    jl palindrome_prep
    mov al, [rsi]
    mov [rdi], al
    dec rsi
    inc rdi
    jmp reverse_loop

palindrome_prep:
    PRINT_STRING "Reverse complement: "
    PRINT_STRING reversed_var
    mov rax, orig_var  
    lea rdi, [reversed_var]
    mov rcx, 0

palindrome_check:
    ; need to compare to the original input not the complemented string
    mov dl, [rax + rcx]
    mov bl, [rdi + rcx]
    inc rcx
 
    cmp dl, bl
    jne palindrome_no
 
    cmp r11, rcx
    jg palindrome_check
    
    jmp palindrome_yes

invalid_terminator:
    PRINT_STRING "Error: "
    PRINT_STRING "No terminator or invalid terminator"
    NEWLINE
    jmp continue_loop 

null_input:
    PRINT_STRING "Error: "
    PRINT_STRING "null input"
    NEWLINE
    jmp continue_loop    

too_long:
    PRINT_STRING "Error: "
    PRINT_STRING "more than 40 characters"
    NEWLINE
    jmp continue_loop    

invalid_dna:     
    PRINT_STRING "Error: "
    PRINT_STRING "invalid DNA alphabet"
    NEWLINE  
    jmp continue_loop 

palindrome_yes:
    NEWLINE
    PRINT_STRING palindrome
    jmp continue_loop

palindrome_no:
    NEWLINE
    PRINT_STRING not_palindrome
    jmp continue_loop
    
continue_loop:
    GET_CHAR al              ; Read the next character (either 'Y', 'N', or something else)
    
    ; Now clear any leftover newline or unwanted characters from the buffer
    ; This will ensure we don't have any stray characters lingering
    GET_CHAR r10b            ; Discard any extra newline (if present)

    PRINT_STRING continue_message
    PRINT_CHAR al
    NEWLINE
    NEWLINE

    cmp al, 'Y'              ; Check if the input is 'Y'
    je start                 ; Jump to start if 'Y'

    cmp al, 'y'              ; Check if the input is 'y'
    je start                 ; Jump to start if 'y'

    cmp al, 'N'              ; Check if the input is 'N'
    je end                   ; Jump to end if 'N'

    cmp al, 'n'              ; Check if the input is 'n'
    je end                   ; Jump to end if 'n'
    jne invalid_yn
    NEWLINE
    jmp continue_loop        ; Re-prompt the user

invalid_yn:
    PRINT_STRING "Invalid input (Y/N) only. "
    NEWLINE
    jmp continue_loop

end:
    NOP
    xor eax, eax
    ret
