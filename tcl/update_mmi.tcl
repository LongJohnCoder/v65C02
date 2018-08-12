# Update the BIOS MMI file

proc update_mmi { { mmi_filename bios.mmi } } {
    set bram_locs [get_property LOC [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.bram.* && NAME =~ BIOS*}]]
    
    foreach bram_loc $bram_locs {
        set bram_name [get_property NAME $bram_loc]
        lappend bram_list [string trimleft $bram_name "BRAM36_"]
    }
    
    set template_file [open "bram_data/template.mmi" r]
    set template [read $template_file]
    close $template_file
    
    set mmi [format $template {*}$bram_list]
    
    set mmi_file [open "bram_data/$mmi_filename" w]
    puts -nonewline $mmi_file $mmi
    close $mmi_file
}