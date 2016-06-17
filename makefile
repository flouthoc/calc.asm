NASM=nasm
CFLAGS=-f elf64
LINKER=ld
OBJ=calc.o

all: calc

%.o: %.asm
	$(NASM) $(CFLAGS) -o $@ $<

calc: $(OBJ)
	$(LINKER) -o calc $(OBJ)

.PHONY: clean
clean:
	rm *.o calc
