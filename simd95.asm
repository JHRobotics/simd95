; ==============================================================================
; MIT No Attribution
;
; Copyright 2022 Jaroslav Hensl <emulator@emulace.cz>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
; IN THE SOFTWARE.
;
; ==============================================================================
;
; This program enables SSE and AVX to DOS/Windows 9x
; Run this from real mode WITHOUT memory manager
;
; For Windows add this program to autoexec.bat.
;
; ==============================================================================
;

; print string, terminated by '$'
%macro print 1
mov dx,%1
mov ax,0x0900
int 0x21
%endmacro

org 100h
section .text

print msg_hello

; test V86
smsw ax
and eax,1
jz test_sse
  print msg_v86
  jmp exit

test_sse:
  mov eax,1
  cpuid
  and edx, (1 << 25)
  test edx,edx
  jz test_xstore
  mov al,0x1
  mov [have_sse],al
  print msg_sse

test_sse2:
  mov eax,1
  cpuid
  and edx, (1 << 26)
  test edx,edx
  jz test_avx
  print msg_sse2

test_sse3:
  mov eax,1
  cpuid
  and ecx, (1 << 0)
  test ecx,ecx
  jz test_ssse3
  print msg_sse3

test_ssse3:
  mov eax,1
  cpuid
  and ecx, (1 << 9)
  test ecx,ecx
  jz test_sse41
  print msg_ssse3

test_sse41:
  mov eax,1
  cpuid
  and ecx, (1 << 19)
  test ecx,ecx
  jz test_sse42
  print msg_sse41

test_sse42:
  mov eax,1
  cpuid
  and ecx, (1 << 19)
  test ecx,ecx
  jz test_xstore
  print msg_sse42

test_xstore:
  mov eax,1
  cpuid
  and ecx, (1 << 26)
  test ecx,ecx
  jz detect_done
  print msg_xstore

test_avx:
  mov eax,1
  cpuid
  and ecx, (1 << 28)
  test ecx,ecx
  jz detect_done
  mov al,0x1
  mov [have_avx],al
  print msg_avx

detect_done:
  print msg_break
  
enable_sse:
  mov al,[have_sse]
  test al,al
  jz enable_sse_skip
  mov eax,cr4
  or eax, (1 << 9) ; OSFXSR - enables FXSAVE/FXRSTOR + SSE
  mov cr4,eax
  xor eax,eax
  print msg_en_sse
  enable_sse_skip:

enable_avx:
  mov al,[have_avx]
  test al,al
  jz enable_avx_skip
  ; enable xstore first
  mov eax,cr4
  or eax, (1 << 18)
  mov cr4,eax
  xor eax,eax
  print msg_en_xst
  ; enable AVX now
  xor ecx, ecx ; ECX = 0
	xgetbv       ; Load XCR0 register (ECX = 0)
	or eax, 7    ; Set AVX, SSE, X87 bits
	xsetbv       ; Save back to XCR0
	print msg_en_avx
	enable_avx_skip:
	jmp exit

no_sse:
	jmp exit

exit:
	print msg_bye
	mov ax,0x4c00
	int 0x21

; data

have_sse db 0
have_avx db 0

; strings

msg_hello  db 0x20,0xC9,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD
           db 0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xBB,0x0D,0x0A
           db 0x20,0xBA,"    SIMD95.COM    ",0xBA,0x0D,0x0A
           db 0x20,0xCC,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD
           db 0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xB6,0x0D,0x0A,"$"
msg_sse    db 0x20,0xBA," SSE    supported ",0xBA,0x0D,0x0A,"$"
msg_sse2   db 0x20,0xBA," SSE2   supported ",0xBA,0x0D,0x0A,"$"
msg_sse3   db 0x20,0xBA," SSE3   supported ",0xBA,0x0D,0x0A,"$"
msg_ssse3  db 0x20,0xBA," SSSE3  supported ",0xBA,0x0D,0x0A,"$"
msg_sse41  db 0x20,0xBA," SSE4.1 supported ",0xBA,0x0D,0x0A,"$"
msg_sse42  db 0x20,0xBA," SSE4.2 supported ",0xBA,0x0D,0x0A,"$"
msg_xstore db 0x20,0xBA," XSTORE supported ",0xBA,0x0D,0x0A,"$"
msg_avx    db 0x20,0xBA," AVX    supported ",0xBA,0x0D,0x0A,"$"
msg_v86    db 0x20,0xBA,"Cannot run in V86!",0xBA,0x0D,0x0A,"$"
msg_break  db 0x20,0xCC,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD
           db 0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xB6,0x0D,0x0A,"$"
msg_en_sse db 0x20,0xBA," SSE     enabled! ",0xBA,0x0D,0x0A,"$"
msg_en_xst db 0x20,0xBA," XSTORE  enabled! ",0xBA,0x0D,0x0A,"$"
msg_en_avx db 0x20,0xBA," AVX     enabled! ",0xBA,0x0D,0x0A,"$"
msg_bye    db 0x20,0xC8,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD
           db 0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xCD,0xBC,0x0D,0x0A,"$"

