set files [glob -nocomplain cores/*.v]

set part_name xc7a100tcsg324-1

foreach file_name $files {
  set core_name [file rootname [file tail $file_name]]
  set argv [list $core_name $part_name]
  source scripts/core.tcl
}
