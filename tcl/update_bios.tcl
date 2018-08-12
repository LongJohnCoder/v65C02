# Update the BIOS on the v65C02 8-bit Computer

proc update_bios { { bios_name bios } } {
    set bram_data_dir bram_data    
    append mmi_file $bram_data_dir {/} $bios_name {.mmi}
    append mem_file $bram_data_dir {/} $bios_name {.mem}
    
    append bit_dir [get_property NAME [current_project]] {.runs} {/} [current_run]
    set top_module [get_property TOP [current_fileset]]
    append in_file $bit_dir {/} $top_module {.bit}
    append out_file $bit_dir {/} $top_module {_updated.bit}

    puts [exec updatemem --force --proc dummy --meminfo $mmi_file --data $mem_file --bit $in_file --out $out_file]
    }
