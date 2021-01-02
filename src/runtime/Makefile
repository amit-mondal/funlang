
CC = gcc
CFLAGS = -fPIE -Wall -Wextra -O3

runtime.o: RUNTIME_SOURCES

RUNTIME_SOURCES = runtime.c stack.c node.c gmachine.c

out.o:
	cargo run

a.out: $(RUNTIME_SOURCES) out.o
	$(CC) $(CFLAGS) $(RUNTIME_SOURCES) out.o

ref_a.out: ref_runtime.c ref_runtime.h out.o
	$(CC) $(CFLAGS) ref_runtime.c out.o -o ref_a.out

test_runtime: runtime.c test.c stack.c node.c
	$(CC) $(CFLAGS) -o test_runtime runtime.c test.c stack.c node.c

clean:
	rm -f *.o
