
CC = gcc
CFLAGS = -fPIE -Wall -Wextra

runtime.o: runtime.c stack.c node.c

out.o:
	cargo run

a.out: runtime.c stack.c node.c out.o
	$(CC) $(CFLAGS) runtime.c stack.c node.c out.o

test_runtime: runtime.c test.c stack.c node.c
	$(CC) $(CFLAGS) -o test_runtime runtime.c test.c stack.c node.c
