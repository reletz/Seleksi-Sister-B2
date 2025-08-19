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
O_WRONLY    equ 1
O_CREAT     equ 64
O_TRUNC     equ 512

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
SYS_UNLINK equ 87

; --- Segmen Data ---
segment readable writeable
  file_root db 'index.html', 0
  file_test db 'test.html', 0

  ; Header HTTP
  http_200      db 'HTTP/1.1 200 OK', 0Dh, 0Ah, 'Content-Type: text/html', 0Dh, 0Ah, 0Dh, 0Ah
  len_200      = $ - http_200

  post_filename db 'post_result.txt', 0
  http_201      db 'HTTP/1.1 201 Created', 0Dh, 0Ah, 0Dh, 0Ah, 'File created successfully.'
  len_201      = $ - http_201

  http_400      db 'HTTP/1.1 400 Bad Request', 0Dh, 0Ah, 0Dh, 0Ah, '<h1>400 Bad Request</h1>'
  len_400       = $ - http_400

  http_404      db 'HTTP/1.1 404 Not Found', 0Dh, 0Ah, 0Dh, 0Ah, '<h1>404 Not Found</h1>'
  len_404       = $ - http_404

  http_405      db 'HTTP/1.1 405 Method Not Allowed', 0Dh, 0Ah, 0Dh, 0Ah, 'Method Not Allowed.'
  len_405       = $ - http_405
  
  ; Path untuk routing
  path_test   db '/test'

; --- Segmen BSS ---
segment readable writeable
  sockaddr_in     rb 16
  request_buffer  rb 2048
  file_buffer     rb 8192
  parsed_filename rb 256 ;

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

  mov r15, rax
  mov eax, dword [request_buffer]

  cmp eax, 'POST'
  je handle_post

  cmp eax, 'PUT '
  je handle_put

  cmp eax, 'DELE'
  je handle_del

  cmp eax, 'GET '
  je handle_get

  ; Jika tidak ada yang cocok
  jmp handle_405

handle_post:
  xor rcx, rcx
find_body_loop:
  ; Bandingkan 4 byte dari posisi saat ini dengan 0A0D0A0D (CRLFCRLF)
  mov eax, dword [request_buffer + rcx]
  cmp eax, 0A0D0A0Dh
  je found_body

  inc rcx
  cmp rcx, r15
  jl find_body_loop

  jmp handle_400

found_body:
  ; Jika kita sampai sini, artinya kita menemukan separatornya.
  ; Alamat awal body adalah: request_buffer + rcx + 4
  lea rbx, [request_buffer + rcx + 4]

  mov rdx, r15
  sub rdx, rcx
  sub rdx, 4

  mov r15, rdx

  jmp write_post_to_file

write_post_to_file:
  mov rax, SYS_OPEN
  mov rdi, post_filename
  mov rsi, O_WRONLY or O_CREAT or O_TRUNC
  mov rdx, 644o        ; Mode izin file
  syscall
  mov r14, rax

  mov rax, SYS_WRITE
  mov rdi, r14 ; file descriptor
  mov rsi, rbx ; pointer ke body (dari hasil pencarian)
  mov rdx, r15 ; berisi panjang body (dari hasil pencarian)
  syscall

  mov rax, SYS_CLOSE
  mov rdi, r14
  syscall

  mov rsi, http_201
  mov rdx, len_201
  jmp send_response

handle_del:
  lea rsi, [request_buffer + 8] 
  lea rdi, [parsed_filename]   

parse_loop_del:
  mov al, byte [rsi]
  cmp al, ' '
  je  found_eof_del
  
  mov byte [rdi], al
  inc rsi
  inc rdi
  jmp parse_loop_del

found_eof_del:
  mov byte [rdi], 0       
  mov rax, SYS_UNLINK
  lea rdi, [parsed_filename]
  syscall

  cmp rax, 0
  jne handle_404 

  mov rsi, http_200
  mov rdx, len_200
  jmp send_response

handle_put:
  lea rsi, [request_buffer + 5] ; Offset 4 "PUT /"
  lea rdi, [parsed_filename]
parse_loop_put:
  mov al, byte [rsi]
  cmp al, ' '
  je  found_eof_put
  mov byte [rdi], al
  inc rsi
  inc rdi
  jmp parse_loop_put
found_eof_put:
  mov byte [rdi], 0
  ;call sanitize_filename
  
  xor rcx, rcx
find_body_loop_put:
  mov eax, dword [request_buffer + rcx]
  cmp eax, 0A0D0A0Dh
  je found_body_put
  inc rcx
  cmp rcx, r15
  jl find_body_loop_put
  jmp handle_400

found_body_put:
  lea rbx, [request_buffer + rcx + 4]
  mov rdx, r15
  sub rdx, rcx
  sub rdx, 4
  mov r15, rdx

  mov rax, SYS_OPEN
  lea rdi, [parsed_filename]
  mov rsi, O_WRONLY or O_CREAT or O_TRUNC
  mov rdx, 644o
  syscall
  mov r14, rax

  mov rax, SYS_WRITE
  mov rdi, r14
  mov rsi, rbx
  mov rdx, r15
  syscall

  mov rax, SYS_CLOSE
  mov rdi, r14
  syscall

  mov rsi, http_200
  mov rdx, len_200
  jmp send_response

handle_400:
  mov rsi, http_400      
  mov rdx, len_400       
  jmp send_response 

handle_404:
  mov rsi, http_404       
  mov rdx, len_404        
  jmp send_response 

handle_405:
  mov rsi, http_405
  mov rdx, len_405
  jmp send_response

handle_get:
  lea rsi, [request_buffer + 5] ; rsi = pointer ke awal nama file di request
  lea rdi, [parsed_filename]    ; rdi = pointer ke buffer tujuan
  mov rcx, 5

parse_loop_get:
  mov al, byte [rsi]
  cmp al, ' '
  je  found_eof_get
  mov byte [rdi], al
  inc rsi
  inc rdi
  jmp parse_loop_get
found_eof_get:
  mov byte [rdi], 0

  ; Jika path-nya hanya "/", hasil parsing akan menjadi string kosong.
  cmp byte [parsed_filename], 0

  lea rdi, [parsed_filename]
  jne serve_parsed_file

  lea rdi, [file_root]
  jmp serve_file

serve_parsed_file:
  ; call sanitize_filename
  lea rdi, [parsed_filename]
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
  mov rsi, http_200
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