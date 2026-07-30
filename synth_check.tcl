open_project Sentinel_RV-Project/Sentinel_RV-Project.xpr
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} { exit 1 }
exit 0
