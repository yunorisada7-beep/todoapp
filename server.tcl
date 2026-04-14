set port 3000
set rootdir [file dirname [info script]]

proc serve {chan addr port} {
    global rootdir
    fconfigure $chan -translation crlf -buffering line
    if {[gets $chan request] < 0} { close $chan; return }
    # Drain headers
    while {[gets $chan line] > 0} {}

    set file [file join $rootdir preview.html]
    if {[file exists $file]} {
        set fp [open $file rb]
        fconfigure $fp -translation binary
        set content [read $fp]
        close $fp
        fconfigure $chan -translation binary -buffering full
        puts -nonewline $chan "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: [string length $content]\r\nConnection: close\r\n\r\n"
        puts -nonewline $chan $content
    } else {
        fconfigure $chan -translation binary -buffering full
        puts -nonewline $chan "HTTP/1.1 404 Not Found\r\nContent-Length: 9\r\n\r\nNot Found"
    }
    flush $chan
    close $chan
}

socket -server serve $port
puts "Serving on http://localhost:$port"
vwait forever
