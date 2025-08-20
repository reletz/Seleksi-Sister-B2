CC = gcc
AS = fasm

TARGET = server

OBJS = server.o helper.o

all: build clean run

build: $(TARGET)

run: 
	./$(TARGET)

$(TARGET): $(OBJS)
	$(CC) -no-pie -nostartfiles $(OBJS) -o $(TARGET)
	@echo "Server '$(TARGET)' berhasil dibuat."

server.o: server.asm
	$(AS) server.asm server.o

helper.o: helper.c
	$(CC) -c -o helper.o helper.c

clean:
	rm -f $(OBJS)

.PHONY: all build run clean