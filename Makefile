# 'make' builds everything
# 'make clean' deletes everything except source files and Makefile
#
# You need to set NAME and PART for your project.
# NAME is the base name for most of the generated files.

NAME = led_blinker
PART = xc7a100tcsg324-1

CORES = axis_constant_v1_0 axis_counter_v1_0 axis_fifo_v2_0 axis_hub_v1_0 \
  axis_spi_v1_0 axis_usb_v1_0 axis_variable_v1_0 axis_zmod_adc_v1_0 \
  cdce_gpio_v1_0 cdce_iic_v1_0 dsp48_v1_0 port_selector_v1_0 port_slicer_v1_0

VIVADO = vivado -nolog -nojournal -mode batch
RM = rm -rf

.PRECIOUS: tmp/cores/% tmp/%.xpr tmp/%.bit

all: tmp/$(NAME).bit

cores: $(addprefix tmp/cores/, $(CORES))

xpr: tmp/$(NAME).xpr

bit: tmp/$(NAME).bit

run: tmp/$(NAME).bit
	xc3sprog -v -c jtaghs1_fast $<

tmp/cores/%: cores/%/core_config.tcl cores/%/*.v
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
