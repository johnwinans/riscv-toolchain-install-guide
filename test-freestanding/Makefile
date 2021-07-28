TOP=.
include $(TOP)/Make.rules

LDLIBS=-lc -lgcc
CFLAGS+=-O2

#LDFLAGS+=-Wl,--no-relax
LDFLAGS+=-Wl,-T,vanilla.ld

PROGS=prog prog.lst

all:: $(PROGS)

prog: crt0.o
	$(LINK.c) -o $@ $^ $(LDLIBS)
	$(SIZE) -A -x $@

clean::
	rm -f $(PROGS) *.o *.s *.lst
