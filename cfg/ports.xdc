# clock input

set_property IOSTANDARD LVCMOS33 [get_ports clk_i]
set_property PACKAGE_PIN E3 [get_ports clk_i]

### LED

set_property IOSTANDARD LVCMOS33 [get_ports {led_o[*]}]
set_property SLEW SLOW [get_ports {led_o[*]}]
set_property DRIVE 4 [get_ports {led_o[*]}]

set_property PACKAGE_PIN R17 [get_ports {led_o[0]}]
set_property PACKAGE_PIN P15 [get_ports {led_o[1]}]
set_property PACKAGE_PIN R15 [get_ports {led_o[2]}]
set_property PACKAGE_PIN T14 [get_ports {led_o[3]}]

### PMOD

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_a_tri_io[*]}]

set_property PACKAGE_PIN F4 [get_ports {pmod_a_tri_io[0]}]
set_property PACKAGE_PIN F3 [get_ports {pmod_a_tri_io[1]}]
set_property PACKAGE_PIN E2 [get_ports {pmod_a_tri_io[2]}]
set_property PACKAGE_PIN D2 [get_ports {pmod_a_tri_io[3]}]
set_property PACKAGE_PIN H2 [get_ports {pmod_a_tri_io[4]}]
set_property PACKAGE_PIN G2 [get_ports {pmod_a_tri_io[5]}]
set_property PACKAGE_PIN C2 [get_ports {pmod_a_tri_io[6]}]
set_property PACKAGE_PIN C1 [get_ports {pmod_a_tri_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_b_tri_io[*]}]

set_property PACKAGE_PIN C4 [get_ports {pmod_b_tri_io[0]}]
set_property PACKAGE_PIN B2 [get_ports {pmod_b_tri_io[1]}]
set_property PACKAGE_PIN B3 [get_ports {pmod_b_tri_io[2]}]
set_property PACKAGE_PIN B4 [get_ports {pmod_b_tri_io[3]}]
set_property PACKAGE_PIN B1 [get_ports {pmod_b_tri_io[4]}]
set_property PACKAGE_PIN A1 [get_ports {pmod_b_tri_io[5]}]
set_property PACKAGE_PIN A3 [get_ports {pmod_b_tri_io[6]}]
set_property PACKAGE_PIN A4 [get_ports {pmod_b_tri_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {pmod_c_tri_io[*]}]

set_property PACKAGE_PIN C5 [get_ports {pmod_c_tri_io[0]}]
set_property PACKAGE_PIN C6 [get_ports {pmod_c_tri_io[1]}]
set_property PACKAGE_PIN B6 [get_ports {pmod_c_tri_io[2]}]
set_property PACKAGE_PIN C7 [get_ports {pmod_c_tri_io[3]}]
set_property PACKAGE_PIN A5 [get_ports {pmod_c_tri_io[4]}]
set_property PACKAGE_PIN A6 [get_ports {pmod_c_tri_io[5]}]
set_property PACKAGE_PIN B7 [get_ports {pmod_c_tri_io[6]}]
set_property PACKAGE_PIN D8 [get_ports {pmod_c_tri_io[7]}]

### USB FIFO

set_property IOSTANDARD LVCMOS33 [get_ports {usb_data_tri_io[*]}]

set_property PACKAGE_PIN M18 [get_ports {usb_data_tri_io[0]}]
set_property PACKAGE_PIN R12 [get_ports {usb_data_tri_io[1]}]
set_property PACKAGE_PIN R13 [get_ports {usb_data_tri_io[2]}]
set_property PACKAGE_PIN M13 [get_ports {usb_data_tri_io[3]}]
set_property PACKAGE_PIN R18 [get_ports {usb_data_tri_io[4]}]
set_property PACKAGE_PIN T18 [get_ports {usb_data_tri_io[5]}]
set_property PACKAGE_PIN N14 [get_ports {usb_data_tri_io[6]}]
set_property PACKAGE_PIN P14 [get_ports {usb_data_tri_io[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports usb_clk_i]
set_property IOSTANDARD LVCMOS33 [get_ports usb_rxfn_i]
set_property IOSTANDARD LVCMOS33 [get_ports usb_txen_i]
set_property IOSTANDARD LVCMOS33 [get_ports usb_rdn_o]
set_property IOSTANDARD LVCMOS33 [get_ports usb_wrn_o]
set_property IOSTANDARD LVCMOS33 [get_ports usb_oen_o]
set_property IOSTANDARD LVCMOS33 [get_ports usb_siwun_o]

set_property PACKAGE_PIN P17 [get_ports usb_clk_i]
set_property PACKAGE_PIN M16 [get_ports usb_rxfn_i]
set_property PACKAGE_PIN M17 [get_ports usb_txen_i]
set_property PACKAGE_PIN N15 [get_ports usb_rdn_o]
set_property PACKAGE_PIN N16 [get_ports usb_wrn_o]
set_property PACKAGE_PIN N17 [get_ports usb_oen_o]
set_property PACKAGE_PIN P18 [get_ports usb_siwun_o]

### ADC

set_property IOSTANDARD LVCMOS18 [get_ports {adc_data_i[*]}]

set_property PACKAGE_PIN H14 [get_ports {adc_data_i[0]}]
set_property PACKAGE_PIN K15 [get_ports {adc_data_i[1]}]
set_property PACKAGE_PIN E16 [get_ports {adc_data_i[2]}]
set_property PACKAGE_PIN C16 [get_ports {adc_data_i[3]}]
set_property PACKAGE_PIN C17 [get_ports {adc_data_i[4]}]
set_property PACKAGE_PIN J14 [get_ports {adc_data_i[5]}]
set_property PACKAGE_PIN G18 [get_ports {adc_data_i[6]}]
set_property PACKAGE_PIN J17 [get_ports {adc_data_i[7]}]
set_property PACKAGE_PIN H15 [get_ports {adc_data_i[8]}]
set_property PACKAGE_PIN E15 [get_ports {adc_data_i[9]}]
set_property PACKAGE_PIN F18 [get_ports {adc_data_i[10]}]
set_property PACKAGE_PIN J18 [get_ports {adc_data_i[11]}]
set_property PACKAGE_PIN J15 [get_ports {adc_data_i[12]}]
set_property PACKAGE_PIN G14 [get_ports {adc_data_i[13]}]

set_property IOSTANDARD LVCMOS18 [get_ports adc_dco_i]
set_property PACKAGE_PIN H16 [get_ports adc_dco_i]

set_property IOSTANDARD LVCMOS18 [get_ports {adc_spi_o[*]}]

set_property PACKAGE_PIN A15 [get_ports {adc_spi_o[0]}]
set_property PACKAGE_PIN A16 [get_ports {adc_spi_o[1]}]
set_property PACKAGE_PIN E17 [get_ports {adc_spi_o[2]}]

### CDCE GPIO

set_property IOSTANDARD LVCMOS18 [get_ports {cdce_gpio_tri_io[*]}]

set_property PACKAGE_PIN B18 [get_ports {cdce_gpio_tri_io[0]}]
set_property PACKAGE_PIN A13 [get_ports {cdce_gpio_tri_io[1]}]
set_property PACKAGE_PIN B17 [get_ports {cdce_gpio_tri_io[2]}]
set_property PACKAGE_PIN A18 [get_ports {cdce_gpio_tri_io[3]}]
set_property PACKAGE_PIN D15 [get_ports {cdce_gpio_tri_io[4]}]

### CDCE IIC

set_property IOSTANDARD LVCMOS18 [get_ports {cdce_iic_tri_io[*]}]

set_property PACKAGE_PIN A14 [get_ports {cdce_iic_tri_io[0]}]
set_property PACKAGE_PIN B16 [get_ports {cdce_iic_tri_io[1]}]
