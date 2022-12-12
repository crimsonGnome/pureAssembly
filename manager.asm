
;****************************************************************************************************************************
; Program name: "Pure Assembly". This program takes in a degree number as a float and outputs it as a radian, and the cosine 
; of the agle. This program is use Copyright (C) 2022 Joseph Eggers.
;                                                                                                                           *
;This file is part of the software program "Pure Assembly".                                                              *
;Pure Assembly is free software: you can redistribute it and/or modify it under the terms of the GNU General Public      *
;License version 3 as published by the Free Software Foundation.                                                            *
; Eculid Length is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied     *
;warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.     *
;A copy of the GNU General Public License v3 is available here:  <https:;www.gnu.org/licenses/>.                            *
;****************************************************************************************************************************

;=======1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3**
;Author information
;  Author name: Joseph Eggers
;  Author email: joseph.eggers@csu.fullerton.edu
;  Author CWID: 885939488
;  Author Section: 3
;  Date program Updated last: 2022 October 30th
;  collabarotors/ Contributors: Johnson Tong, Timothy Vu (shlim), sapphiregnome, amethystgnome, diamondburned, abd Chandry Lindy
;
;   
;    
;Status
;  This software is not an application program, but rather it is a single function licensed for use by other applications.
;  This function can be embedded within both FOSS programs and in proprietary programs as permitted by the LGPL.

;Function information
;  Function name: Eculid Length
;  Programming language: X86 assembly in Intel syntax.
;  Date development began:  2022-Oct-12
;  Date version 1.0 finished: 2022-Oct-12
;  System requirements: an X86 platform with nasm installed o other compatible assembler.
;  Know issues: <now in testing phase>
;  Assembler used for testing: Nasm version 2.14.02
;
;
;========= Begin source code ====================================================================================
extern degToRadian
extern strlen
extern itoa
extern cosine
extern ftoa
extern atof

sys_write equ 1
sys_read equ 0
stdout equ 1
stdin equ 0
array_size equ 32


global _start

segment .data
welcome db "Welcome to Accurate Cosines by Joseph Eggers.", 10 ,0
time db "The time is now tics ",0
timePart2 db " tics.", 10, 0
inputDegreePrompt db "Please enter an angle in degrees and press enter: " ,0
dataEntered db "You entered ",0
dataRadians db "The equivalent radians is ", 0
dataCosine db "The cosine of those degrees is ", 0
endMessage db "Have a nice day. Bye.", 10 ,0
newline db 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0        ;Declare an array of 8 bytes where each byte is initialize with ascii value 10 (newline)                                   
tab db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0    ;Declare an array of 8 bytes where each byte is initialize with 32 (blank space).  Thus, this array equals 
    

segment .bss  
tic resb 50
tic2 resb 50
input_integer_string resb array_size
output_string resb array_size

float_string resb 30

cos_string resb 30

segment .text

_start:

;=========== Insurance for any caller of this assembly module ========================================================
;Any future program calling this module that the data in the caller's GPRs will not be modified.
push rbp
mov  rbp,rsp
push rdi                                                    ;Backup rdi
push rsi                                                    ;Backup rsi
push rdx                                                    ;Backup rdx
push rcx                                                    ;Backup rcx
push r8                                                     ;Backup r8
push r9                                                     ;Backup r9
push r10                                                    ;Backup r10
push r11                                                    ;Backup r11
push r12                                                    ;Backup r12
push r13                                                    ;Backup r13
push r14                                                    ;Backup r14
push r15                                                    ;Backup r15
push rbx                                                    ;Backup rbx
pushf                                                       ;Backup rflags

;======================== Program start ========================================
push qword 0 

;============= welcome message - start - ===================
push qword 0 
;find the length of the string
mov rax, 0
mov rdi, welcome
call strlen
mov r15, rax
pop rax

push qword 0
;print welcome
mov rax, sys_write
mov rdi, stdout
mov rsi, welcome
mov rdx, r15
syscall
pop rax
;============= welcome message - end - ===================
;============= Tics message - start - ====================

;find the length of the string - time

push qword 0 
mov rax, 0
mov rdi, time
call strlen
mov r15, rax
pop rax

push qword 0
;output time prompt
mov rax, sys_write
mov rdi, stdout
mov rsi, time
mov rdx, r15
syscall
pop rax
;---------- Sub part - calculate time  in tics----------
push qword 0
cpuid
rdtsc
shl rdx, 32
or rdx, rax
mov r14, rdx
pop rax
;---------- Sub part - turn int into array ----------
push qword 0
mov rax, 0
mov rdi, r14
mov rsi, tic
call itoa
mov r13, tic
pop rax

;---------- Sub part - printing number as string -----
;find the length of the string - the time
push qword 0
mov rax, 0
mov rdi, r13
call strlen
mov r15, rax
pop rax
;output the time
push qword 0
mov rax, sys_write
mov rdi, stdout
mov rsi, r13
mov rdx, r15
syscall
pop rax

;find the length of the string - time2
push qword 0
mov rax, 0
mov rdi, timePart2
call strlen
mov r15, rax
pop rax
;Sub component --- output time2
push qword 0
mov rax, sys_write
mov rdi, stdout
mov rsi, timePart2
mov rdx, r15
syscall
pop rax
;============= Tics message - end - ======================
;============= degree prompt - start - ===================

;find the length of the string - inputDegreePrompt

push qword 0 
mov rax, 0
mov rdi, inputDegreePrompt

call strlen
mov r15, rax
pop rax
;output inputDegreePrompt

push qword 0
mov rax, sys_write
mov rdi, stdout
mov rsi, inputDegreePrompt

mov rdx, r15
syscall
pop rax

;============= degree prompt - end - =====================
;============= degree data - start - =====================
push qword 0 

;Preloop initialization
    mov rbx, input_integer_string 
    mov r12,0       
    push qword 0    

Begin_loop:       
    mov    rax, sys_read
    mov    rdi, stdin
    mov    rsi, rsp
    mov    rdx, 1    ;
    syscall

    mov al, byte [rsp]

    cmp al, 10
    je Exit_loop     
                    

    inc r12          ;Count the number of bytes placed into the array.

    ;Check that the destination array has not overflowed.
    cmp r12,array_size
    ;if(r12 >= Input_array_size)
         jge end_if_else
    ;else (r12 < array_size)
          mov byte [rbx],al
          inc rbx
    end_if_else:

jmp Begin_loop

Exit_loop:
    
    mov byte [rbx], 0       

    pop rax          
pop rax

;============= degree data - end - =======================
;============= data message output - start - =============
push qword 0 
;find the length of the string - entered
mov rax, 0
mov rdi, dataEntered
call strlen
mov r15, rax
pop rax

push qword 0
;output dataEntered
mov rax, sys_write
mov rdi, stdout
mov rsi, dataEntered
mov rdx, r15
syscall
pop rax
;============= data message prompt - end - ==============
;============= data message output - end - ==============
;find the length of the string - inputted number

push qword 0 
mov rax, 0
mov rdi, input_integer_string
call strlen
mov r15, rax
pop rax 

push qword 0
;output input_integer_string
mov rax, sys_write
mov rdi, stdout
mov rsi, input_integer_string
mov rdx, r15
syscall
pop rax
;============= Convert char array to flaot - start - ============
push qword 0
;output newline
mov rax, sys_write
mov rdi, stdout
mov rsi, newline
mov rdx, 1
syscall
pop rax
;============= data message output - end - ==============
push qword 0
;call atof
mov rax, 0
mov rdi, input_integer_string
call atof
movsd xmm15, xmm0
pop rax
;============= Convert char array to flaot - end - =================
;============= Convert data from degrees to rad print - start - ====
push qword 0
push qword 0
;find the length of the string - dataRadians
mov rax, 0
mov rdi, dataRadians
call strlen
mov r15, rax
pop rax

push qword 0
;output dataRadians
mov rax, sys_write
mov rdi, stdout
mov rsi, dataRadians
mov rdx, r15
syscall
pop rax
;============= Convert data from degrees to rad print - end - ====
;============= Convert data from degrees to rad - start - ========
push qword 0
mov rax, 1
movsd xmm0, xmm15
call degToRadian
movsd xmm14, xmm0
pop rax
; ==== sub component - convert  radians to string ====
push qword 0
;call ftoa to get radian value
mov rax, 1
movsd xmm0, xmm14
mov rdi, float_string
mov rsi, 30
call ftoa
pop rax

;==== sub component - print  radians ====
;Get length of string 
push qword 0
;find the length of the string - dataRadians
mov rax, 0
mov rdi, float_string
call strlen
mov r15, rax
pop rax

push qword 0
;output radian value
mov rax, sys_write
mov rdi, stdout
mov rsi, float_string
mov rdx, r15
syscall
pop rax
;============= Convert data from degrees to rad - end - ========
; new line 
push qword 0
;output newline
mov rax, sys_write
mov rdi, stdout
mov rsi, newline
mov rdx, 1
syscall
pop rax
;============= rad to cosine - start - =========================
push qword 0
;call cosine
mov rax, 1
movsd xmm0, xmm14
call cosine
movsd xmm13, xmm0
pop rax
;============= rad to cosine - end - ==========================
;============= Cosine Prompt - start - ========================
push qword 0
;find the length of the string - dataCosine
mov rax, 0
mov rdi, dataCosine
call strlen
mov r15, rax
pop rax

push qword 0
;output dataCosine
mov rax, sys_write
mov rdi, stdout
mov rsi, dataCosine
mov rdx, r15
syscall
pop rax

;============= Cosine Prompt - end - ========================
;============= Cosine convert to string - start - ===========
push qword 0
; call ftoa
mov rax, 1
movsd xmm0, xmm13
mov rdi, cos_string
mov rsi, 30
call ftoa
pop rax
;============= Cosine convert to string - end - =============
;============= Cosine Print - start - =======================
;Get length of String
push qword 0
;find the length of the string - dataRadians
mov rax, 0
mov rdi, cos_string
call strlen
mov r15, rax
pop rax

push qword 0
;output float_string
mov rax, sys_write
mov rdi, stdout
mov rsi, cos_string
mov rdx, r15
syscall
pop rax
;============= Cosine Print - end - =======================
; ++ new line ++
push qword 0
;output newline
mov rax, sys_write
mov rdi, stdout
mov rsi, newline
mov rdx, 1
syscall
pop rax

;=============  Print time prompt - start - ===================
push qword 0
;find the length of the string - time
mov rax, 0
mov rdi, time
call strlen
mov r15, rax
pop rax

push qword 0
;output time
mov rax, sys_write
mov rdi, stdout
mov rsi, time
mov rdx, r15
syscall
pop rax

;=============  Print time prompt - end - ===================
;============= Get Tics - start - ===========================
;get time
cpuid
rdtsc
shl rdx, 32
or rdx, rax
mov r14, rdx
;============= Get Tics - end - =============================
;=============  Convert tic to string - start - =============
push qword 0
;call itoa
mov rax, 0
mov rdi, r14
mov rsi, tic2
call itoa
mov r13, tic2
pop rax
;=============  Convert tic to string - end - ===============
;============= Tic Print - start - ==========================

;find the length of the string - the time
push qword 0
mov rax, 0
mov rdi, r13
call strlen
mov r15, rax
pop rax

; %lf, argument
;output the time
push qword 0
mov rax, sys_write
mov rdi, stdout
mov rsi, r13
mov rdx, r15
syscall
pop rax

;find the length of the string - timePart2
push qword 0
mov rax, 0
mov rdi, timePart2
call strlen
mov r15, rax
pop rax
push qword 0
;output timePart2
mov rax, sys_write
mov rdi, stdout
mov rsi, timePart2
mov rdx, r15
syscall
pop rax

;============= Eng message - start - ===================
push qword 0 
;find the length of the string
mov rax, 0
mov rdi, endMessage
call strlen
mov r15, rax
pop rax

push qword 0
;print endMessage
mov rax, sys_write
mov rdi, stdout
mov rsi, endMessage
mov rdx, r15
syscall
pop rax

pop rax

;===== extra pops that I missing ====
mov        rax, 60                                          ;60 is the number of the syscall subfunction that terminates an executing program.
mov        rdi, 0                                           ;0 is the code number that will be returned to the OS.
syscall
;===== Restore original values to integer registers ===================================================================
popf                                                        ;Restore rflags
pop rbx                                                     ;Restore rbx
pop r15                                                     ;Restore r15
pop r14                                                     ;Restore r14
pop r13                                                     ;Restore r13
pop r12                                                     ;Restore r12
pop r11                                                     ;Restore r11
pop r10                                                     ;Restore r10
pop r9                                                      ;Restore r9
pop r8                                                      ;Restore r8
pop rcx                                                     ;Restore rcx
pop rdx                                                     ;Restore rdx
pop rsi                                                     ;Restore rsi
pop rdi                                                     ;Restore rdi
pop rbp                                                     ;Restore rbp

ret

;========1=========2=========3=========4=========5=========6=========7=========8=========9=========0=========1=========2=========3**
