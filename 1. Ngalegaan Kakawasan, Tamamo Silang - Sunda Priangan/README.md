# Assembly HTTP Server

A lightweight, blazing-fast HTTP server written in x86-64 assembly language.

## 🚀 Features

- Handles common HTTP methods (GET, POST, PUT, DELETE)
- File-based routing
- Security validation for file access
- Concurrent connections through process forking

## 🛠️ Getting Started

### Prerequisites

- Linux-based OS (x86-64 architecture)
- FASM (Flat Assembler)
- GCC

### Building

Clone the repository and build the server:

```bash
git clone [repository-url]
cd [repository-directory]
make
```

### Running

Start the server:

```bash
make run
```

The server runs on port 8080 by default.

## 🔍 Usage Examples

### Serving Static Files

Place HTML files in the same directory as the server. Access them via:

```
http://localhost:8080/filename.html
```

The root path (`/`) serves `index.html`.

### POST Requests

Send data to the server:

```bash
curl -X POST -d "Your data here" http://localhost:8080
```

POST data is saved to `post_result.txt`.

### PUT Requests

Create or update files:

```bash
curl -X PUT -d "File content" http://localhost:8080/newfile.txt
```

### DELETE Requests

Remove files:

```bash
curl -X DELETE http://localhost:8080/file-to-delete.txt
```

## 🔧 Technical Details

This server is built using:

- Raw socket with Linux syscalls
- x86-64 assembly for core functionality
- C for security helper functions
- Process-based concurrency model

## 🔒 Security

All file operations include path validation to prevent directory traversal attacks. The server validates filenames before processing any request.

## 📝 Note

This server is primarily designed for educational purposes to demonstrate low-level systems programming. While functional, it lacks many features of production-ready servers.

---

Built for Seleksi Labsister 23
Built along with Gemini :D
