;; kernel.asm
bits 32
section .text

global start
extern kmain ; defined in the C file

start:
    cli
    mov esp, stack_space ; set stack pointer
    call kmain
    hlt

section .bss
resb 8192
stack_space: ; stack starts from here