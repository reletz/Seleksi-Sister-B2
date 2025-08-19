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

; --- Segmen Data ---
segment readable writeable
  method_get  db 'GET '
  method_post db 'POST '
  method_del  db 'DELETE '
  method_put  db 'PUT '

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
  xor rcx, rcx ; Gunakan rcx sebagai counter/index loop
find_body_loop:
  ; Bandingkan 4 byte dari posisi saat ini dengan 0A0D0A0D (CRLFCRLF)
  mov eax, dword [request_buffer + rcx]
  cmp eax, 0A0D0A0Dh
  je found_body

  inc rcx ; Pindah ke byte selanjutnya
  cmp rcx, r15 ; Cek apakah sudah sampai akhir buffer
  jl find_body_loop

  ; Jika loop selesai tanpa menemukan body, anggap request tidak valid
  jmp handle_400 ; (Kamu perlu buat handler ini)

found_body:
  ; Jika kita sampai sini, artinya kita menemukan separatornya.
  ; Alamat awal body adalah: request_buffer + rcx + 4
  lea rbx, [request_buffer + rcx + 4]

  mov rdx, r15 ; r15 masih berisi total byte dari read
  sub rdx, rcx
  sub rdx, 4

  mov r15, rdx

  jmp write_post_to_file

handle_put:
  mov rsi, http_200
  mov rdx, len_200
  jmp send_response

handle_del:
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
  ; --- Cek untuk path "/test" ---
  lea rdi, [request_buffer + 4]
  lea rsi, [path_test]
  mov rcx, 5
  repe cmpsb
  jne check_root  ; Jika tidak diawali "/test", cek untuk "/"

  cmp byte [rdi], ' '
  je handle_test  ; Jika ya, ini path yang valid

  jmp handle_404

check_root:
  ; --- Cek untuk path "/" ---
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

write_post_to_file:
  ; 1. Buka file untuk ditulis (O_WRONLY | O_CREAT | O_TRUNC)
  mov rax, SYS_OPEN
  mov rdi, post_filename
  mov rsi, O_WRONLY or O_CREAT or O_TRUNC ; Flags: WRONLY | CREAT | TRUNC
  mov rdx, 644o        ; Mode izin file
  syscall
  mov r14, rax ; Simpan file descriptor

  ; 2. Tulis body ke file
  mov rax, SYS_WRITE
  mov rdi, r14 ; file descriptor
  mov rsi, rbx ; pointer ke body (dari hasil pencarian)
  mov rdx, r15 ; berisi panjang body (dari hasil pencarian)
  syscall

  ; 3. Tutup file
  mov rax, SYS_CLOSE
  mov rdi, r14
  syscall

  ; 4. Kirim respons ke klien
  mov rsi, http_201
  mov rdx, len_201
  jmp send_response

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