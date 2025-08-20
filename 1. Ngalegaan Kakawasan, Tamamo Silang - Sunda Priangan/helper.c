#include <string.h>
#include <stddef.h>
#include <stdio.h>

int is_filename_safe(const char* filename) {
  if (filename == NULL || filename[0] == '\0') return 0;
  if (strstr(filename, "/") != NULL) return 0;
  if (strstr(filename, "..") != NULL) return 0;

  if (strcmp(filename, "server.asm") == 0 ||
    strcmp(filename, "helper.c") == 0 ||
    strcmp(filename, "Makefile") == 0 ||
    strcmp(filename, "server") == 0){
    return 0;
  }

  return 1; // Aman
}