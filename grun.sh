#!/bin/bash

#Program: Compare Floats
#Author: Joseph Eggers

#Purpose: script file to run the program files together.
#Clear any previously compiled outputs
rm *.o
rm *.lis
rm *.out

#echo "compile driver.cpp using the g++ compiler standard 2017"

nasm -f elf64 -l manager.lis -o manager.o manager.asm -g -gdwarf
nasm -f elf64 -l strlen.lis -o strlen.o strlen.asm -g -gdwarf
nasm -f elf64 -l cosine.lis -o cosine.o cosine.asm -g -gdwarf
nasm -f elf64 -l itoa.lis -o itoa.o itoa.asm -g -gdwarf
nasm -f eelf64 -o atof.o -l atof.lis atof.asm -g -gdwarf
nasm -f elf64 -l degToRadian.lis -o degToRadian.o degToRadian.asm -g -gdwarf
nasm -f elf64 -l ftoa.lis -o ftoa.o ftoa.asm -g -gdwarf
nasm -f elf64 -l _math.lis -o _math.o _math.asm

#echo "Link object files using the gcc Linker standard 2017"
ld -o final.out manager.o strlen.o cosine.o degToRadian.o itoa.o ftoa.o atof.o -g

#echo "Run the driver Program:" 
gdb ./gfinal.out

#echo "Script file has terminated."

rm *.o
rm *.lis
rm *.out
