### clock input

create_bd_port -dir I clk_i

### buttons

create_bd_port -dir I -from 1 -to 0 btn_i

### LED

create_bd_port -dir O -from 3 -to 0 led_o

### PMOD

create_bd_port -dir IO -from 7 -to 0 pmod_a_tri_io
create_bd_port -dir IO -from 7 -to 0 pmod_b_tri_io
create_bd_port -dir IO -from 7 -to 0 pmod_c_tri_io

### USB FIFO

create_bd_port -dir IO -from 7 -to 0 usb_data_tri_io

create_bd_port -dir I usb_clk_i
create_bd_port -dir I usb_rxfn_i
create_bd_port -dir I usb_txen_i

create_bd_port -dir O usb_rdn_o
create_bd_port -dir O usb_wrn_o
create_bd_port -dir O usb_oen_o
create_bd_port -dir O usb_siwun_o

### ADC

create_bd_port -dir I -from 13 -to 0 adc_data_i

create_bd_port -dir I adc_dco_i

create_bd_port -dir O -from 2 -to 0 adc_spi_o

create_bd_port -dir IO -from 4 -to 0 cdce_gpio_tri_io

create_bd_port -dir IO -from 1 -to 0 cdce_iic_tri_io
