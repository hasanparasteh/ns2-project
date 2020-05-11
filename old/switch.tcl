proc create_switch {name _color} {
    global ns
    
    set sw [$ns node]
    $sw label $name
    $sw shape square
    $sw color $_color
    
    return $sw
}

proc create_hosts_for_switch {sw sw_name n_hosts _color _orient} {
    global ns
    
    for {set i 0} {$i < $n_hosts} {incr i} {
        set host [$ns node]
        $host label "$sw_name host($i)"
        $host color $_color
        
        set hosts($i) $host
        $ns duplex-link $host $sw 1Mb 10ms DropTail
        #$ns duplex-link-op $host $sw orient $_orient
    }
   
    return [array get hosts]
}


proc create_bottom_layer {} {
}
