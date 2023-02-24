create_clock -period 10 -waveform {0 5} [get_ports clk_i]

create_clock -period 16 -waveform {0 8} [get_ports usb_clk_i]
