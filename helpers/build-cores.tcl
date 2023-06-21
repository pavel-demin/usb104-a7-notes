set cores [list \
  axis_bram_writer axis_constant axis_counter axis_downsizer axis_fifo \
  axis_histogram axis_hub axis_negator axis_oscilloscope \
  axis_pulse_height_analyzer axis_selector axis_spi axis_timer axis_trigger \
  axis_usb axis_validator axis_variable axis_zmod_adc cdce_gpio cdce_iic dsp48 \
  port_selector port_slicer \
]

set part_name xc7a100tcsg324-1

foreach core_name $cores {
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
