# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME and PART for your project.
# NAME is the base name for most of the generated files.

NAME = led_blinker
PART = xc7a100tcsg324-1

FILES = $(wildcard cores/*.v)
CORES = $(FILES:.v=)

VIVADO = vivado -nolog -nojournal -mode batch
XSCT = xsct
RM = rm -rf

.PRECIOUS: tmp/cores/% tmp/%.xpr tmp/%.bit

all: tmp/$(NAME).bit

cores: $(addprefix tmp/, $(CORES))

xpr: tmp/$(NAME).xpr

bit: tmp/$(NAME).bit

run: tmp/$(NAME).bit
	$(XSCT) scripts/jtag.tcl $<

tmp/cores/%: cores/%.v
	mkdir -p $(@D)
	$(VIVADO) -source scripts/core.tcl -tclargs $* $(PART)

tmp/%.xpr: projects/% $(addprefix tmp/, $(CORES))
	mkdir -p $(@D)
	$(VIVADO) -source scripts/project.tcl -tclargs $* $(PART)

tmp/%.bit: tmp/%.xpr
	mkdir -p $(@D)
	$(VIVADO) -source scripts/bitstream.tcl -tclargs $*

clean:
	$(RM) tmp
	$(RM) .Xil usage_statistics_webtalk.html usage_statistics_webtalk.xml
	$(RM) vivado*.jou vivado*.log
	$(RM) webtalk*.jou webtalk*.log
