set ns [new Simulator]

set f [open out.tr w]
$ns trace-all $f

set nf [open out.nam w]
$ns namtrace-all $nf

::oo::class create Switch {
	variable n_hosts
	variable hosts
	variable device
	variable ns
	
	constructor {n _ns switch_name} {
		set n_hosts $n
		set ns $_ns
		
		set device [$ns node]
		$device label $switch_name
		
		for {set i 0} {$i < $n} {incr i} {
		    set host [$ns node]
		    $ns duplex-link $host $device 1Mb 10ms DropTail
		    
		    set hosts($i) $host
		}
	}

	method test {} {
		puts "testing"
		set udp0 [new Agent/UDP]
		$ns attach-agent $device $udp0
		
		set cbr0 [new Application/Traffic/CBR]
		$cbr0 set packetSize_ 500
		$cbr0 set interval_ 0.005
		$cbr0 attach-agent $udp0
		
		set null0 [new Agent/Null]
		$ns attach-agent $hosts(0) $null0
		
		$ns connect $udp0 $null0
		$ns at 0.5 "$cbr0 start"
		$ns at 1.5 "$cbr0 stop"
		
		
	}
}

set s1 [Switch new 10 ns "s0"]

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


$ns at 0.1 "$s1 test"
$ns at 3.0 "finish"
$ns run

