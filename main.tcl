set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 Red
$ns color 2 Blue

######################
set end_users {0 1 2 3 4 5 6 7 8 9 10 11}
set servers {26 27 28 29 30 31 32 33}

set indexLayout {
    {0 1 2 3 4 5 6 7 8 9 10 11}
    {12 13 14 15}
    {16 17 18}
    {19}
    {20 21}
    {22 23 24 25}
    {26 27 28 29 30 31 32 33}
}

set counter 0
foreach row $indexLayout {
	foreach col $row {
		set n($counter) [$ns node]
		incr counter
	}
}

proc make_connection {main_node other_nodes} {
	global ns n
	foreach h $other_nodes {
		$ns duplex-link $n($h) $n($main_node) 1Mb 10ms DropTail
	}
}

set switches {12 13 14 15 22 23 24 25}
foreach sw $switches {
	$n($sw) shape square
}

set blue_nodes {0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15}
foreach bn $blue_nodes {
	$n($bn) color blue
}

set red_nodes {19 20 21}
foreach rn $red_nodes {
	$n($rn) color red
}

set purple_nodes {22 23 24 25 26 27 28 29 30 31 32 33}
foreach pn $purple_nodes {
	$n($pn) color purple
}

set _ [make_connection 12 {0 1 2}]
set _ [make_connection 13 {3 4 5}]
set _ [make_connection 14 {6 7 8}]
set _ [make_connection 15 {9 10 11}]

set _ [make_connection 17 {12 13 14}]
set _ [make_connection 18 {15}]
set _ [make_connection 19 {17 18 20 21}]
set _ [make_connection 20 {21 22 23}]
set _ [make_connection 21 {24 25}]

set _ [make_connection 22 {26 27}]
set _ [make_connection 23 {28 29}]
set _ [make_connection 24 {30 31}]
set _ [make_connection 25 {32 33}]

# Bottom switches to mid router

# Describe the space we're going to lay them out over; you might need to tune this
set originX 0
set originY 0
set width   300
set height  400

# Do the layout
set nRows [llength $indexLayout]
set rowsize [expr {$height / $nRows}]
set rowY [expr {$originY + $rowsize / 2}]
foreach row $indexLayout {
    set nCols [llength $row]
    set colsize [expr {$width / $nCols}]
    set rowX [expr {$originX + $colsize / 2}]
    foreach index $row {
        $n($index) set X_ $rowX
        $n($index) set Y_ $rowY
        set rowX [expr {$rowX + $colsize}]
    }
    set rowY [expr {$rowY + $rowsize}]
}

##################################

##################################
### Traffic
##################################
#array set udp_origin {0 3 6 9}
#set udp_dest {27 29 31 33}
#set i 0

#puts $udp_origin(2)

array set udp_connections {
	0 27
	3 29
	6 31
	9 33
}
set i 0
foreach udp_origin [array names udp_connections] {
	set udp_dest $udp_connections($udp_origin)
	
	puts "Connecting UDP node: $udp_origin to node: $udp_dest"
	
	set _udp [new Agent/UDP]
	set udp($i) $_udp
	$ns attach-agent $n($udp_origin) $_udp
	
	set _null [new Agent/Null]
	set null($i) $_null
	$ns attach-agent $n($udp_dest) $_null
	
	set _cbr [new Application/Traffic/CBR]
	set cbr($i) $_cbr
	
	$_cbr set packetSize_ 8
	$_cbr set interval [expr 0.1 * $i]
	$_cbr attach-agent $_udp

	$ns connect $_udp $_null
	
	incr i
}

proc start_traffic {} {

}

proc stop_traffic {} {

}

proc finish {} {
    puts "Finishing..."
    global ns f nf
    $ns flush-trace
    close $f
    close $nf
    
    puts "Opening NAM"
    exec nam out.nam &
    exit 0
}

$ns at 1.0 "finish"

$ns run
