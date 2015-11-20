:insert
#! /bin/ksh -
 
#########################
# 
# Name: 
#
# Purpose: 
#
# Usage: 
#
# Revision history: 
#
# Contact persons:
#
########################

program=$0

function exit_on_error()
{
    mail -s "${program} failed..." martin.evaldsson@smhi.se << EOMAIL
    See $1/$2
EOMAIL
}

# trap 'exit_on_error $LOG_DIR $LOG_FILE' ERR

if [[ $0 == */* ]] ; then 
  export HOME_DIR=`cd ${0%/*}/.. && echo $PWD` 
else 
  export HOME_DIR=`cd .. && echo $PWD`
fi
LOG_DIR=$HOME_DIR/log
OUTPUT_DIR=$HOME_DIR/data
BIN_DIR=$HOME_DIR/bin
SCRIPT_DIR=$HOME_DIR/script

function usage {
 echo "Usage: 
" 1>&2 
}

function log {
 echo "[ $(date -u '+%Y-%m-%d  %H:%M') ]: " $*
}

info()
{
    log "*II* $*"
}

warning()
{
    log "*WW* $*"
}

error()
{
    log "*EE* $*" 1>&2
    exit 1
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

# Default behaviour without any arguments
if [ $# -eq 0 ]; then
  usage_and_exit 0
fi

while getopts "ha:b:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    a)
        aopt=$OPTARG
      ;;
    b)
        bopt=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

if [ ! $# -eq 1 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi

.
