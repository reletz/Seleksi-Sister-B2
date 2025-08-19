format ELF64 executable
entry start

; rax = nomor syscall
; rdi = argumen 1
; rsi = argumen 2
; rdx = argumen 3
; r10 = argumen 4
; r8 = argumen 5
; r9 = argumen 6

; --- Konstanta & Syscall ---
AF_INET     equ 2
SOCK_STREAM equ 1
O_RDONLY    equ 0

SYS_SOCKET  equ 41
SYS_BIND    equ 49
SYS_LISTEN  equ 50
SYS_ACCEPT  equ 43
SYS_WRITE   equ 1
SYS_CLOSE   equ 3
SYS_EXIT    equ 60
SYS_FORK    equ 57
SYS_READ    equ 0
SYS_OPEN    equ 2

; --- Segmen Data ---
segment readable writeable
  method_get  db 'GET '
  method_post db 'POST '
  method_del  db 'DELETE '
  method_put  db 'PUT '

  file_root db 'index.html', 0
  file_test db 'test.html', 0

  ; Header HTTP
  http_200_get  db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 0Dh, 0Ah
  len_200       = $ - http_200_get

  http_200_post db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 0Dh, 0Ah, 'POST request received.'
  len_200_post  = $ - http_200_post

  http_200_put  db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 0Dh, 0Ah, 'PUT request received.'
  len_200_put   = $ - http_200_put

  http_200_del  db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 0Dh, 0Ah, 'DELETE request received.'
  len_200_del   = $ - http_200_del

  http_404      db 'HTTP/1.1 404 Not Found', 0Dh, 0Ah, 0Dh, 0Ah, '<h1>404 Not Found</h1>'
  len_404       = $ - http_404

  http_405      db 'HTTP/1.1 405 Method Not Allowed', 0Dh, 0Ah, 0Dh, 0Ah, 'Method Not Allowed.'
  len_405       = $ - http_405
  
  ; Path untuk routing
  path_test   db '/test'

; --- Segmen BSS ---
segment readable writeable
  sockaddr_in rb 16
  request_buffer rb 2048
  file_buffer    rb 8192

; --- Segmen Kode ---
segment readable executable
start:
  mov rax, SYS_SOCKET
  mov rdi, AF_INET
  mov rsi, SOCK_STREAM
  xor rdx, rdx
  syscall
  mov r12, rax
  mov word [sockaddr_in], AF_INET
  mov word [sockaddr_in+2], 0x901F ; 8080
  mov dword [sockaddr_in+4], 0
  mov rax, SYS_BIND
  mov rdi, r12
  mov rsi, sockaddr_in
  mov rdx, 16
  syscall
  mov rax, SYS_LISTEN
  mov rdi, r12
  mov rsi, 5 ; Backlog 5
  syscall

accept_loop:
  mov rax, SYS_ACCEPT
  mov rdi, r12
  xor rsi, rsi
  xor rdx, rdx
  syscall
  mov r13, rax
  mov rax, SYS_FORK
  syscall
  cmp rax, 0
  je  child_process
parent_process:
  mov rax, SYS_CLOSE
  mov rdi, r13
  syscall
  jmp accept_loop

child_process:
  mov rax, SYS_CLOSE
  mov rdi, r12
  syscall
  mov rax, SYS_READ
  mov rdi, r13
  mov rsi, request_buffer
  mov rdx, 2048
  syscall

  lea rdi, [request_buffer]
  lea rsi, [method_post]
  mov rcx, 5
  repe cmpsb
  je handle_post

  lea rdi, [request_buffer]
  lea rsi, [method_put]
  mov rcx, 4  
  repe cmpsb
  je handle_put

  lea rdi, [request_buffer] ;
  lea rsi, [method_del]
  mov rcx, 7
  repe cmpsb
  je handle_del

  lea rdi, [request_buffer]
  lea rsi, [method_get]
  mov rcx, 4
  repe cmpsb
  je handle_get;

  ; Jika tidak ada metode yang cocok, kirim 405 Method Not Allowed
  jmp handle_405
  
handle_post:
  mov rsi, http_200_post
  mov rdx, len_200_post
  jmp send_response

handle_put:
  mov rsi, http_200_put
  mov rdx, len_200_put
  jmp send_response

handle_del:
  mov rsi, http_200_del
  mov rdx, len_200_del
  jmp send_response

handle_404:
  mov rsi, http_404       
  mov rdx, len_404        
  jmp send_response 

handle_405:
  mov rsi, http_405
  mov rdx, len_405
  jmp send_response

handle_get: ; Routing
  lea rdi, [request_buffer + 4]
  lea rsi, [path_test]
  mov rcx, 5
  repe cmpsb
  jne check_root

  cmp byte [rdi], ' '
  jne handle_404

  jmp handle_test

check_root:
  mov al, byte [request_buffer + 4]
  mov ah, byte [request_buffer + 5]
  cmp al, '/'
  jne handle_404
  cmp ah, ' '
  je handle_root

  jmp handle_404

handle_root:
  mov rdi, file_root
  jmp serve_file
handle_test:
  mov rdi, file_test
  jmp serve_file

serve_file:
  mov rax, SYS_OPEN
  mov rsi, O_RDONLY
  xor rdx, rdx
  syscall
  cmp rax, 0
  jl handle_404
  mov r14, rax
  mov rax, SYS_READ
  mov rdi, r14
  mov rsi, file_buffer
  mov rdx, 8192
  syscall
  mov r15, rax
  mov rax, SYS_CLOSE
  mov rdi, r14
  syscall
  mov rax, SYS_WRITE
  mov rdi, r13
  mov rsi, http_200_get
  mov rdx, len_200
  syscall
  mov rax, SYS_WRITE
  mov rdi, r13
  mov rsi, file_buffer
  mov rdx, r15
  syscall
  jmp close_and_exit

send_response:
  mov rax, SYS_WRITE
  mov rdi, r13
  syscall
  jmp close_and_exit

close_and_exit:
  mov rax, SYS_CLOSE
  mov rdi, r13
  syscall
  mov rax, SYS_EXIT
  xor rdi, rdi
  syscall