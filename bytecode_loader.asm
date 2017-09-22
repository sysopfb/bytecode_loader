.686
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib


.data

.data?
argc dd ?
argv dd 16 dup (?) 
hFile HANDLE ?
fSize dd ?
hMem dd ?
bytesRead dd ?
.code

ProcessCmdLine proc uses ebx esi edi
call GetCommandLine
mov esi, eax
mov edi, OFFSET argv
xor ecx, ecx
xor ebx, ebx
xor edx, edx
@@cmss: 
mov eax, esi
mov dl, 20h
cmp byte ptr [esi], 22h
sete cl
lea edx, [edx+ecx*2]
add eax, ecx
stosd
@@cm00: 
inc esi
cmp byte ptr [esi], 0
je @@cm01
cmp byte ptr [esi], dl
jne @@cm00
mov byte ptr [esi], 0
add esi, ecx
;inc esi
cmp byte ptr [esi], 0
je @@cm01
inc esi
inc [argc]
jmp @@cmss
@@cm01: 
inc [argc]
ret 
ProcessCmdLine endp

Main proc

	invoke ProcessCmdLine
	mov ecx, [argc]
	cmp ecx, 1
	jz endl
	mov eax, [argv+4]
	
	invoke CreateFile,eax,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile, eax
	cmp hFile, -1
	jz endl
	
	invoke GetFileSize, eax, 0
	mov fSize, eax
	inc eax
	
	invoke VirtualAlloc,NULL, fSize,MEM_COMMIT, PAGE_EXECUTE_READWRITE
	mov hMem, eax
	
	invoke ReadFile, hFile, hMem, fSize, ADDR bytesRead, 0
	
	jmp hMem
	
	invoke CloseHandle, hFile
	
	invoke VirtualFree, hMem, 0, MEM_RELEASE
	
endl:
	ret
Main endp
end Main
