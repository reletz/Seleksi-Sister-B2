# Assembly HTTP Server

A lightweight, blazing-fast HTTP server written in x86-64 assembly language.

---

## Program Source Code

- `server.asm` — Main HTTP server in x86-64 assembly
- `helper.c` — Helper C code (if any)
- `index.html`, `test.html`, `style.css` — Example static files
- `Makefile` — Build instructions

---

## 📄 Features & Usage Guide

### 1. Serving Static Files

- **Description:**
  The server can serve static files (HTML, CSS, etc.) located in the same directory.
- **How it works:**
  If a user accesses `/filename`, the server will send that file if it exists and is safe.
- **Instructions:**
  Place your HTML/CSS files in the same folder, then access them via browser:
  `http://localhost:8080/index.html`
- **Screenshot:**
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/4937e65a-5521-423a-a61d-6c3779b05156" />

### 2. POST Request (Save Data)

- **Description:**
  The server accepts POST data and saves it to the file `post_result.txt`.
- **How it works:**
  The body data from the POST request will be written to the file.
- **Instructions:**
  Send data using curl or another tool:
  ```bash
  curl -X POST -d "data" http://localhost:8080
  ```
- **Screenshot:**
  <img width="1071" height="901" alt="image" src="https://github.com/user-attachments/assets/5b40170f-c973-4ba4-bab5-15f7476120f0" />


### 3. PUT & DELETE (Update & Delete File)

- **Description:**
  Supports updating files (PUT) and deleting files (DELETE) with filename validation.
- **How it works:**
  - PUT: Overwrites or creates a new file.
  - DELETE: Deletes a file if the name is valid.
- **Instructions:**
  ```bash
  curl -X PUT --data-binary @file.txt http://localhost:8080/file.txt
  curl -X DELETE http://localhost:8080/file.txt
  ```
- **Screenshot:**
  <img width="1114" height="974" alt="image" src="https://github.com/user-attachments/assets/c169e166-3406-447c-b19f-131512ea6c31" />
  <img width="1065" height="908" alt="image" src="https://github.com/user-attachments/assets/b68f1b7f-5ed1-4798-9e28-9b5319fab25d" />

### 4. Navigation & Search Endpoint (Frontend) [Creativity]

- **Description:**
  The HTML page includes navigation and a search feature to easily switch endpoints.
- **How it works:**
  Users can type a filename and will be redirected to that endpoint.
  If the file cannot be accessed, it will give 404 Not Found or 400 Bad Request, depending on the file type.
- **Instructions:**
  Open `index.html` in your browser and use the search bar.
  
- **Screenshot:**
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/dd99887b-8a57-46e9-8506-d68e3959eabf" />
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/10c992d5-d2cb-4002-9b7e-16bbf4f39e45" />
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/18651d5c-a271-4229-86bf-f71d8eadfbdf" />

### 5. Port Forwarding

- **Description:**
  This can be port forwarded using ngrok.
- **Instructions:**
  Run the server. Then,
  Type:
  ```bash
  ngrok http 8080
  ```
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fe71338e-d1b4-4ec9-81f8-03d5c814ee27" />
<img width="1073" height="318" alt="image" src="https://github.com/user-attachments/assets/9c6fcca2-9f5d-4d68-8532-da097b0c9878" />

---

## 🛠️ Build & Run

### Prerequisites

- Linux-based OS (x86-64 architecture)
- FASM (Flat Assembler)
- GCC

### Build

```bash
make
```

### Run the Server

```bash
make run
```

The server runs on port 8080 by default.

---

## 📸 Notes on Images/Screenshots

- Save screenshots in the `docs/` folder (or attach them in the PDF if submitting offline).
- For PDF, include an image for each feature explanation.

---

## 🔍 Usage Examples

### Serving Static Files

```
http://localhost:8080/filename.html
```

The root path (`/`) will serve `index.html`.

### POST Requests

```bash
curl -X POST -d "Your data here" http://localhost:8080
```

POST data will be saved to `post_result.txt`.

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
