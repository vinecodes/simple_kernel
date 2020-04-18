# A simple kernel

##### Flow

``` CPU (16 bit mode) -> EIP -> BIOS -> Bootloader (CPU: 32 bit mode) -> Kernel ```

##### Address Jumps
```0xFFFFFFF0 -> 0x7c00 -> 0x10000000 ```

## The instruction pointer (EIP)

* All registers in the x86 CPU have default fixed values after power on.

* EIP's value is 0xFFFFFFF0. This memory address is called **reset vector**.

* This value points to the instruction in the BIOS. The BIOS boots copies itself to the RAM for faster access. This process is called **Shadowing**. 0xFFFFFFF0 contains a jump instruction to the address in memory where BIOS has copied itself.

* BIOS searches for a bootable device. It checks if the device has a certain magic number (whether bytes 511 and 512 of first sector are 0xAA55) to detect if the device is bootable or not.

* BIOS then copies the device's first sector at 0x7c00 in RAM. This code is the **bootloader**. 

* The bootlaoder copies the kernel at 0x10000000. The kernel starts executing from 0x10000000.

* Processors start in 16 bit mode also called the **real mode** and the bootloader changes it to **32 bit protected mode** by setting the CR0 register to 1. 

* For linux kernel, the GRUB bootloader detects the linux boot protocol and loads it in 16 bit mode (real mode) and then the kernel itself switches the CPU mode into 32 bit protected mode.

# Assembly Code

* `bits 32` is to instruct NASM to generate code to run on a processor running in 32 bit mode.

* `section .text` indicates the start of the section `text`.

* `global start` tells the linker that `start` is the entry point. 

* In `start`,

    * `cli` blocks the interrupts. 

    * `mov esp, stack_space` sets the **esp** register to the `stack_space` address.

    * `call kmain` calls the `kmain` function defined in the C program.

    * `hlt` halts the CPU. Interrupts can wake the CPU so it is blocked beforehand.

* In BSS section,
    * `resb 8192` allocates 8KB of memory for the stack in the memory.

    * `stack_space` points to the edge of the memory space for the stack.

    * `esp` is the stack pointer. `esp` is pointed to `stack_space`. 

    * This is usually done by the bootloader, but we are doing it for just in case. 