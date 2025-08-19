; =======================================
; Program "Hello, World!" untuk Linux x86-64 dengan FASM
; =======================================
format ELF64 executable
entry start

; Segmen untuk data yang bisa dibaca/ditulis
segment readable writeable
  hello_msg db 'Hello from FASM!', 0Ah  ; 0Ah adalah karakter newline
  hello_len = $ - hello_msg

; Segmen untuk kode yang bisa dieksekusi
segment readable executable
start:
  ; Syscall untuk write(stdout, message, length)
  mov     rax, 1              ; Nomor syscall untuk 'write'
  mov     rdi, 1              ; File descriptor 1 = stdout
  mov     rsi, hello_msg      ; Alamat memori dari pesan
  mov     rdx, hello_len      ; Panjang pesan
  syscall

  ; Syscall untuk exit(0)
  mov     rax, 60             ; Nomor syscall untuk 'exit'
  xor     rdi, rdi            ; Exit code 0
  syscall