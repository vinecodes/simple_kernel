# A simple kernel

##### Flow

``` CPU (16 bit mode) -> EIP -> BIOS -> Bootloader (CPU: 32 bit mode) -> Kernel ```

##### Address Jumps
```0xFFFFFFF0 -> 0x7c00 -> 0x100000 ```

## The Instruction Pointer (EIP)

* All registers in the x86 CPU have default fixed values after power on.

* EIP's value is 0xFFFFFFF0. This memory address is called **reset vector**.

* This value points to the instruction in the BIOS. The BIOS boots copies itself to the RAM for faster access. This process is called **Shadowing**. 0xFFFFFFF0 contains a jump instruction to the address in memory where BIOS has copied itself.

* BIOS searches for a bootable device. It checks if the device has a certain magic number (whether bytes 511 and 512 of first sector are 0xAA55) to detect if the device is bootable or not.

* BIOS then copies the device's first sector at 0x7c00 in RAM. This code is the **bootloader**. 

* The bootlaoder copies the kernel at 0x100000. The kernel starts executing from 0x100000.

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

* We also add a header (within first 8 KiloBytes) to our kernel so the GRUB bootloader can boot our kernel. 

* The standard way to boot an x86 kernel from a bootloader is `Multiboot Specification`.

* The header must contain:
    * `magic` field: `0x1BADB002` to identify the header.
    * `flags` field: We set it to 0.
    * `checksum` field: `"checksum - (magic + flags)"`  must be zero.

* `dd`: Double word of size 4 bytes. 

# Kernel In C

* `0xb8000` is the start of the memory address for the video in protected mode. 

* It supports 25 lines of 80 columns. Each element is made up of 2 bytes. The first byte is for the character in ASCII and the second byte is for the formatting of the character. 

* 0x07 is value for grey foreground and black background.

* The first for loop writes a blank character to the screen.

* The second for loop writes the characters on the screen.

# The Work Of The Linker

* `OUTPUT_FORMAT(elf32-i386)`: The output format of the kernel should be a 32 bit ELF (Executable and Linkable Format) for Unix systems running on a 32 bit architecture. 

* `ENTRY(start)` is the starting point of our executable. 

* `SECTIONS` define the layout of our executable. 

* `.` is the location counter. We set the starting location of the kernel in the memory to `0x100000`.

* `*(.text)` is merges all the .text sections of all the files in the executable text section. Similarly, `bss` and `data` are merged and stored in the executable.

# References
[Kernels 101 – Let’s write a Kernel](https://arjunsreedharan.org/post/82710718100/kernels-101-lets-write-a-kernel)

[Make GRUB Show on Boot](https://communities.vmware.com/thread/435192)