function idletil --description 'Wait until system idle time has reached X seconds and optionally execute command'
    argparse 'h/help' 'c/command=+' -- $argv
    or return

    if set -q _flag_help
        echo "Usage: idletil SECONDS [-c \"command to execute\"]"
        echo "SECONDS may be represented as XdXhXmXs or any combination"
        return 0
    end

    set -l minimum "$argv"

    echo "> Waiting for $minimum of idle time"

    beengone -w $minimum

    echo "Time's up: "(beengone -n)" seconds"

    for cmd in $_flag_c
        eval $cmd
        if test $status != 0
            return $status
        end
    end

    return 0
end
