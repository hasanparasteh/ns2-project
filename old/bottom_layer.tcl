proc create_bottom_layer {} {
    for {set i 0} {$i < 4} {incr i} {
        set name "b_s_$i"
        set s [create_switch $name]
        array set hosts [create_hosts_for_switch $s $name 8]
        
        set out("$name switch") $s
        set out("$name hosts") $hosts 
    }
    
    return out
}
