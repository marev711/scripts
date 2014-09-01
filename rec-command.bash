#! /bin/bash -eu
 
#########################
# 
# Name: rec-command.bash
#
# Purpose: Record and run command
#
# Usage: ./rec-command.bash --logfile <logfile> <command>
#
# Revision history: 2013-07-11  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
 echo "Usage: ./rec-command.bash --logfile <logfile> <command>

Records command into <logfile> and executes it" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
    usage
      exit $exit_code
}

mycommand=empty
datestring=" "$(date +%Y%m%d:%H%M%S)" "
command_identifier="-----|$datestring|----->"

while (( "$#" )); do 
  case $1 in 
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
     --logfile|--logfil|--logfi|--logf|--log|--lo|--l|\
      -logfile| -logfil| -logfi| -logf| -log| -lo| -l)
        logfile=$2
        shift 2
        ;;
     --)
        set --
        shift 1
        ;;
     *)
        mycommand="$*"
        shift $#
        ;;
  esac  
done
if [[ x$mycommand == x ]];then
    echo "Command missing" 1>&2 
    usage_and_exit
fi

if [[ x$logfile == x ]];then
    echo "No logfile specified" 1>&2 
    usage_and_exit
fi

# Record command
echo $command_identifier $mycommand >> $logfile
eval $mycommand 2>&1 | tee -a $logfile
echo "" 2>&1 | tee -a $logfile
