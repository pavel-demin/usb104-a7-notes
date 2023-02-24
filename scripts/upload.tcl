
set project_name [lindex $argv 0]

open_project tmp/$project_name.xpr

open_hw_manager

connect_hw_server

open_hw_target

set_property PROGRAM.FILE tmp/$project_name.bit [current_hw_device]

program_hw_devices

close_project
