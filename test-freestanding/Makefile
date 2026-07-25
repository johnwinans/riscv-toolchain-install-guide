TOP=.
include $(TOP)/Make.rules

LDLIBS=-lgcc
CFLAGS+=-O2

#LDFLAGS+=-Wl,--no-relax
LDFLAGS+=-Wl,-T,vanilla.ld

PROGS=prog prog.lst

all::
	@echo "⚙️  Compiling test code..."

all:: $(PROGS)
	@echo "✅ Build complete"

prog: crt0.o
	$(LINK.c) -o $@ $^ $(LDLIBS)
	$(SIZE) -A -x $@

.PHONY: test
test: prog
	@echo "🚀 Running executable and checking output..."
	@timeout 5 qemu-system-riscv32 -machine virt -m 128M -bios none \
		-device loader,file=./prog -nographic 2>/dev/null | \
		grep -m1 "Hello World!" > /dev/null
	@echo "✅ Test passed"

clean::
	rm -f $(PROGS) *.o *.s *.lst
