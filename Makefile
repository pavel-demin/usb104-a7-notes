# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME and PART for your project.
# NAME is the base name for most of the generated files.

NAME = led_blinker
PART = xc7a100tcsg324-1

CORES = axis_bram_writer axis_constant axis_counter axis_downsizer axis_fifo \
  axis_histogram axis_hub axis_negator axis_oscilloscope \
  axis_pulse_height_analyzer axis_selector axis_spi axis_timer axis_trigger \
  axis_usb axis_validator axis_variable axis_zmod_adc cdce_gpio cdce_iic dsp48 \
  port_selector port_slicer

VIVADO = vivado -nolog -nojournal -mode batch
XSCT = xsct
RM = rm -rf

.PRECIOUS: tmp/cores/% tmp/%.xpr tmp/%.bit

all: tmp/$(NAME).bit

cores: $(addprefix tmp/cores/, $(CORES))

xpr: tmp/$(NAME).xpr

bit: tmp/$(NAME).bit

run: tmp/$(NAME).bit
	$(XSCT) scripts/jtag.tcl $<

tmp/cores/%: cores/%.v
	mkdir -p $(@D)
	$(VIVADO) -source scripts/core.tcl -tclargs $* $(PART)

tmp/%.xpr: projects/% $(addprefix tmp/cores/, $(CORES))
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
