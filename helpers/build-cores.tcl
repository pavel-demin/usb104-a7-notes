set cores [list \
  axis_bram_writer_v1_0 axis_constant_v1_0 axis_counter_v1_0 \
  axis_downsizer_v1_0 axis_fifo_v2_0 axis_histogram_v1_0 axis_hub_v1_0 \
  axis_negator_v1_0 axis_oscilloscope_v1_0 axis_pulse_height_analyzer_v1_0 \
  axis_selector_v1_0 axis_spi_v1_0 axis_timer_v1_0 axis_trigger_v1_0 \
  axis_usb_v1_0 axis_validator_v1_0 axis_variable_v1_0 axis_zmod_adc_v1_0 \
  cdce_gpio_v1_0 cdce_iic_v1_0 dsp48_v1_0 port_selector_v1_0 port_slicer_v1_0 \
]

set part_name xc7a100tcsg324-1

foreach core_name $cores {
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
