# SIMD95
Simple hack for enabling SSE/AVX instructions on DOS and Windows 95/98/Me.

## Requirements
CPU with SSE support, program is designed to be run in Virtual Machine.

## Usage
Copy `simd95.com` to C:\ directory and add following line to the (at begin of) `autoexec.bat` file

```
C:\simd95.com
```

And reboot a system. Don't run program directly, it must be run from real mode before memory manager is loaded (!).

(You can download binary in releases)

## Behaviour
DOS and Windows 95 doesn't support SSE instruction set, so this program will turn on SSE and AVX and these instructions will be exposed to user programs.

Windows 98 and Me already supporting SSE, so behaviour is changed only with usability of AVX.

## Disadvantages
You cannot have two or more application running with new instructions or one multi-thread application.

The system doesn't care about swapping SSE and AVX registers on context change (switching actual program or *its thread* to another). If you running program with new instructions and the system switch running application to another (multi-thread system do it and do it very often) in SSE and AVX registers isn't its old content but some mess which probably leads to crash.

## The Meaning of Life
I'm using this to run Mesa LLVMpipe software renderer (require SSE, with AVX run faster) to draw 3D graphics without real 3D acceleration.

## Compilation from source
You need [Netwide Assembler (NASM)](https://www.nasm.us/) and this command to create executable binary:
```
nasm simd95.asm -f bin -o simd95.com
```

## Credit
This program was inspired by [Falcosoft SSE 1.0](http://falcosoft.hu/dos_softwares.html#sse). Thanks!
