transcript file questa_transcript.log
transcript on

if {[file exists work]} {
    vdel -lib work -all
}

if {[file exists alu_coverage.ucdb]} {
    file delete alu_coverage.ucdb
}

if {[file exists alu_coverage_report.txt]} {
    file delete alu_coverage_report.txt
}

vlib work
vmap work work

vlog -sv +cover=bcesft alu_if.sv alu_pkg.sv alu.sv tb_top.sv
vsim -coverage -voptargs="+acc +cover=bcesft" work.tb_top

onfinish stop
coverage save -onexit alu_coverage.ucdb
run -all
coverage save alu_coverage.ucdb

