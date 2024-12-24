#! /bin/bash

gone() {
    if [[ -n $1 ]]; then
        TIME=$1
        # loop indefinitely
        while true; do
            # use the --minimum flag to generate an exit code
            # based on a minimum threshold
            beengone -m "$TIME" &> /dev/null
            # get the exit code
            retVal=$?
            # if the exit code is 0, the user has been gone
            # for the specified time
            if [ $retVal -eq 0 ]; then
                # if a command was specified, execute it
                if [[ -n $COMMAND ]]; then
                    eval "$COMMAND"
                    exit $?
                fi
                break
            fi
            
        done
        
    else
        echo "Missing argument: TIME"
        exit 1
    fi
    
    exit 1
}

POSITIONAL_ARGS=()

display_help() {
    echo "Usage: ifgone [OPTIONS] TIME"
    echo
    echo "TIME (required) is the time to wait for the user to be gone"
    echo "TIME can be formatted as XXX (seconds), XXXm (minutes), XXXh (hours), XXXd (days)"
    echo
    echo "OPTIONS:"
    echo "  -c, --command   Command to execute upon success"
    echo "  -h, --help      Display this help message"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            display_help
        ;;
        -c|--command)
            COMMAND=$2
            shift
            shift
        ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
        ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
        ;;
    esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

gone "$1"