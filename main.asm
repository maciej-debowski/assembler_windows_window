.386
.model flat, stdcall
option casemap:none

include E:\masm32\include\windows.inc
include E:\masm32\include\user32.inc
include E:\masm32\include\kernel32.inc
include E:\masm32\include\gdi32.inc
includelib E:\masm32\lib\user32.lib
includelib E:\masm32\lib\kernel32.lib
includelib E:\masm32\lib\gdi32.lib

WinMain proto :DWORD, :DWORD, :DWORD, :DWORD
WindowWidth     equ 640
WindowHeight    equ 480

.DATA
ClassName   db "MyWinClass", 0
AppName     db "No generalnie ten teges", 0

.DATA?
hInstance   HINSTANCE   ?
CommandLine LPSTR       ?   

.CODE

MainEntry:
    push NULL
    call GetModuleHandle
    mov hInstance, eax
    call GetCommandLine
    mov CommandLine, eax
    push SW_SHOWDEFAULT
    lea eax, CommandLine
    push eax
    push NULL
    push hInstance
    call WinMain
    push eax
    call ExitProcess

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:Dword
    LOCAL   wc:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hwnd:HWND
	
    mov     wc.cbSize, SIZEOF WNDCLASSEX
    mov     wc.style, CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, OFFSET WndProc
    mov     wc.cbClsExtra, 0
    mov     wc.cbWndExtra, 0
    mov     eax, hInstance
    mov     wc.hInstance, eax
    mov     wc.hbrBackground, COLOR_3DSHADOW+1
    mov     wc.lpszMenuName, NULL
    mov     wc.lpszClassName, OFFSET ClassName

    push    IDI_APPLICATION
    push    NULL
    call    LoadIcon
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    push    IDC_ARROW
    push    NULL
    call    LoadCursor
    mov     wc.hCursor, eax
    lea     eax, wc
    push    eax
    call    RegisterClassEx
    push    NULL
    push    hInstance
    push    NULL
    push    NULL
    push    WindowHeight
    push    WindowWidth
    push    CW_USEDEFAULT
    push    CW_USEDEFAULT
    push    WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push    OFFSET AppName
    push    OFFSET ClassName
    push    0
    call    CreateWindowExA
    cmp     eax, NULL
    je      Win_Return
    mov     hwnd, eax
    push    eax
    call    UpdateWindow

Message_Loop:

    push    0
    push    0
    push    NULL
    lea     eax, msg
    push    eax
    call    GetMessage
    cmp     eax, 0
    je      Done_Message
    lea     eax, msg
    push    eax
    call    TranslateMessage
    lea     eax, msg
    push    eax
    call    DispatchMessage
    jmp     Message_Loop

Done_Message:
    mov     eax, msg.wParam

Win_Return:
    ret

WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL   ps:PAINTSTRUCT
    LOCAL   rect:RECT
    LOCAL   hdc:HDC

    cmp     uMsg, WM_DESTROY
    jne     Not_Destroy
    push    NULL
    call    PostQuitMessage
    xor     eax, eax
    ret

Not_Destroy:
    cmp     uMsg, WM_PAINT
    jne     Not_Paint
    lea     eax, ps
    push    eax
    push    hWnd
    call    BeginPaint
    mov     hdc, eax
    push    TRANSPARENT
    push    hdc
    call    SetBkMode
    lea     eax, rect
    push    eax
    push    hWnd
    call    GetClientRect 
    push    DT_SINGLELINE + DT_CENTER + 1 
    ; DT_VCENTER
    lea     eax, rect
    push    eax
    push    -1
    push    OFFSET AppName
    push    hdc
    call    DrawText
    lea     eax, ps 
    push    eax
    push    hWnd
    call    EndPaint
    xor     eax, eax
	; TODO: BUTTON
    lea     eax, rect
    push    eax
    push    hWnd
    call    GetClientRect 
    push    DT_SINGLELINE + DT_CENTER + 1 
    lea     eax, rect
    push    NULL
    push    eax
    push    hdc
    call    FillRect
    ret

Not_Paint:
    push    lParam
    push    wParam
    push    uMsg
    push    hWnd
    call    DefWindowProc
    ret 

WndProc endp

END MainEntry