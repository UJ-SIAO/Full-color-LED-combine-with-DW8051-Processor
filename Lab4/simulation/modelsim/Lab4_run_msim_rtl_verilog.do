transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4 {D:/QuartusCode/Lab4/Key.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4 {D:/QuartusCode/Lab4/edge_detect.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051/DW8051_parameter.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/ram.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/rom.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4 {D:/QuartusCode/Lab4/Top8051.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4 {D:/QuartusCode/Lab4/LED_v2.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_alu.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_biu.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_control.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_core.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_cpu.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_intr_0.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_intr_1.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_main_regs.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_op_decoder.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_serial.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_shftreg.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_timer.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_timer_ctr.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_timer2.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_u_ctr_clr.v}
vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/DW8051 {D:/QuartusCode/Lab4/DW8051/DW8051_updn_ctr.v}

vlog -vlog01compat -work work +incdir+D:/QuartusCode/Lab4/simulation/modelsim {D:/QuartusCode/Lab4/simulation/modelsim/Lab4_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  Lab4_tb

add wave *
view structure
view signals
run -all
