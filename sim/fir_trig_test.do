onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/rst
add wave -noupdate -color Magenta -radix decimal /tb/group_num
add wave -noupdate -color Magenta /tb/valid_in
add wave -noupdate -color Magenta -radix unsigned /tb/din
add wave -noupdate -color Magenta /tb/fvalid_out
add wave -noupdate -color Magenta -radix unsigned /tb/dout
add wave -noupdate -color Magenta -radix decimal /tb/fout
add wave -noupdate -color Magenta /tb/tot
add wave -noupdate -color Salmon -radix decimal /tb/Q_out
add wave -noupdate -color Salmon -radix decimal /tb/Q_valid_out
add wave -noupdate -color {Olive Drab} -radix decimal /tb/ftrig/bsum
add wave -noupdate -color {Olive Drab} -radix decimal /tb/bsum_out
add wave -noupdate -color {Olive Drab} /tb/bsum_reset
add wave -noupdate -color {Olive Drab} /tb/ftrig/int_pause_override
add wave -noupdate -color {Olive Drab} /tb/pause_override
add wave -noupdate -color {Olive Drab} /tb/ftrig/sum/pause
add wave -noupdate -color {Olive Drab} /tb/ftrig/bsum_pause
add wave -noupdate -color {Cornflower Blue} /tb/coeff_req
add wave -noupdate -color {Cornflower Blue} /tb/coeff_ack
add wave -noupdate -color {Cornflower Blue} /tb/ftrig/coeff_in_areset
add wave -noupdate -color {Cornflower Blue} /tb/ftrig/coeff_in_adr
add wave -noupdate -color {Cornflower Blue} /tb/ftrig/coeff_in_we
add wave -noupdate -color {Cornflower Blue} -radix decimal /tb/coeff_in_data
add wave -noupdate -color {Cornflower Blue} /tb/coeff_valid
add wave -noupdate -color {Cornflower Blue} /tb/coeff_in_read
add wave -noupdate -color {Cornflower Blue} -radix decimal /tb/coeff_out_data
add wave -noupdate -color {Cornflower Blue} -radix decimal /tb/coeff_read_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135829 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 207
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {693944 ps}
