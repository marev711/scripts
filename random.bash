#! /bin/bash -
 
#########################
# 
# Name: 
#
# Purpose: 
#
# Usage: .//home/marev/scripts/random.bash
#
# Revision history: 2014-12-23  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
 echo "Usage: ./random.bash [--lower] [--upper] [--verbose]
    --lower: Lower limit exclusive (defaults to actual minimum 0)
    --upper: Upper limit exclusive (defaults to actual maximum 32767)
    --verbose: Extra info
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

# Who is running and where
function log_whoami {
echo "==================================="
echo "This script, $(basename $0), is run by $(whoami) on server $(hostname) from folder $(pwd)"
echo "==================================="
}

VERBOSE=false
LOWER=0
UPPER=32767
while (( "$#" )); do 
  case $1 in 
     --lower|--lowe|--low|--lo|--l|\
      -lower| -lowe| -low| -lo| -l)
        LOWER=$2
        shift 2
        ;;
     --upper|--uppe|--upp|--up|--u|\
      -upper| -uppe| -upp| -up| -u)
        UPPER=$2
        shift 2
        ;;
     --verbose|--verbos|--verbo|--verb|--ver|--ve|--v|\
      -verbose| -verbos| -verbo| -verb| -ver| -ve| -v)
        VERBOSE=true
        shift 1
        ;;
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
      --)
        set --
        ;;
      *)
        printf '\n%s\n\n' "Unknown flag $1" 2>&1
        usage_and_exit 1
        ;;
  esac  
done
FLOOR=$LOWER
RANGE=$UPPER

# Combine above two techniques to retrieve random number between two limits.
number=0   #initialize
while [ "$number" -le $FLOOR ]
do
      number=$RANDOM
        let "number %= $RANGE"  # Scales $number down within $RANGE.
done

set -vx
if [ $VERBOSE == "true" ];then
    echo "Random number between $FLOOR and $RANGE ---  $number"
else
    echo $number
fi
