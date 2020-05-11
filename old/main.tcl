set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

$ns color 1 Red

source "switch.tcl"

###########################################
### Bottom Layer
###########################################

set bottom_switch_0 [create_switch "b_0" "blue"]
#$bottom_switch_0 set X_ 10
#$bottom_switch_0 set Y_ 10

array set bottom_hosts_0 [create_hosts_for_switch $bottom_switch_0 "b_0" 3  "blue" down]

set bottom_switch_1 [create_switch "b_1" "blue"]
#$bottom_switch_1 set X_ 30
#$bottom_switch_1 set Y_ 10

array set bottom_hosts_1 [create_hosts_for_switch $bottom_switch_1 "b_1" 3 "blue" down]


set bottom_switch_2 [create_switch "b_2" "blue"]
array set bottom_hosts_2 [create_hosts_for_switch $bottom_switch_2 "b_2" 3 "blue" down]

set bottom_switch_3 [create_switch "b_3" "blue"]
array set bottom_hosts_3 [create_hosts_for_switch $bottom_switch_3 "b_3" 3 "blue" down]


###########################################
### Mid Layer
###########################################

set mid_router_0 [$ns node]
$mid_router_0 shape hexagon
$mid_router_0 color green

set mid_router_1 [$ns node]
$mid_router_1 shape hexagon
$mid_router_1 color green

set mid_router_2 [$ns node]
$mid_router_2 shape hexagon
$mid_router_2 color green

###########################################
### Core Layer
###########################################
set core_layer_router [$ns node]
$core_layer_router shape hexagon
$core_layer_router color yellow

###########################################
### Aggregation Layer
###########################################
set aggregation_layer_router0 [$ns node]
$aggregation_layer_router0  shape hexagon
$aggregation_layer_router0 color "purple"

set aggregation_layer_router1 [$ns node]
$aggregation_layer_router1 shape hexagon
$aggregation_layer_router1 color "purple"


###########################################
### Access Layer
###########################################
set access_layer_switch_0 [create_switch "a_0" "red"]
array set access_layer_hosts_0 [create_hosts_for_switch $access_layer_switch_0 "a_0" 8 "red" "up"]

set access_layer_switch_1 [create_switch "a_1" "red"]
array set access_layer_hosts_1 [create_hosts_for_switch $access_layer_switch_1 "a_1" 8 "red" "up"]

set access_layer_switch_2 [create_switch "a_2" "red"]
array set access_layer_hosts_2 [create_hosts_for_switch $access_layer_switch_2 "a_2" 8 "red" "up"]

set access_layer_switch_3 [create_switch "a_3" "red"]
array set access_layer_hosts_3 [create_hosts_for_switch $access_layer_switch_3 "a_3" 8 "red" "up"]

###########################################
### Creating connections
###########################################
$ns duplex-link $bottom_switch_0 $mid_router_1 10Mb 15ms DropTail
$ns duplex-link $bottom_switch_1 $mid_router_1 10Mb 15ms DropTail
$ns duplex-link $bottom_switch_2 $mid_router_1 10Mb 15ms DropTail
$ns duplex-link $bottom_switch_3 $mid_router_1 10Mb 15ms DropTail

$ns duplex-link $core_layer_router $mid_router_0 10Mb 15ms DropTail
$ns duplex-link $core_layer_router $mid_router_1 10Mb 15ms DropTail
$ns duplex-link $core_layer_router $mid_router_2 10Mb 15ms DropTail

$ns duplex-link $aggregation_layer_router0 $aggregation_layer_router1 10Mb 15ms DropTail
$ns duplex-link $core_layer_router $aggregation_layer_router0 10Mb 15ms  DropTail
$ns duplex-link $core_layer_router $aggregation_layer_router1 10Mb 15ms DropTail

$ns duplex-link $aggregation_layer_router0 $access_layer_switch_0 10Mb 15ms DropTail
$ns duplex-link $aggregation_layer_router0 $access_layer_switch_1 10Mb 15ms DropTail

$ns duplex-link $aggregation_layer_router1 $access_layer_switch_2 10Mb 15ms DropTail
$ns duplex-link $aggregation_layer_router1 $access_layer_switch_3 10Mb 15ms DropTail

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

### UDP Traffic
set udp0 [new Agent/UDP]
$udp0 set fid_ 1
ns attach-agent $bottom_hosts_0(0) $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 8
$cbr0 set interval 0.001
$cbr0 attach-agent $udp0

set null0 [new Agent/Null]
$ns attach-agent $access_layer_hosts_3(7) $null0

$ns connect $udp0 $null0

$ns at 0.2 "$cbr0 start"
$ns at 2.2 "$cbr0 stop"
$ns at 2.3 "finish"
$ns run

