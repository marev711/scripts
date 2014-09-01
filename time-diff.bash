#! /bin/bash
 
#########################
# 
# Name: 
#
# Purpose: 
#
# Usage: .//home/sm_maeva/scripts/time_diff.bash
#
# Revision history: 2014-08-31  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
echo "Usage: ./time_diff.bash [-h] <time-dim> <netCDf-file>
   <time-dim>  -  variable name of time dimension
   <netCDf-file>  -  netCDF-file to investigate

   Print enumerated columns with consectutive diffs along the time dimension
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

if [ $# -lt 1 -o $# -gt 2 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit
fi

while (( "$#" )); do 
  case $1 in 
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
  esac  
  variable=$1
  file=$2
  shift 2
done
ncdump -v $variable $file | sed -e '1,/data:/d' -e 's/time = //' -e 's/ ;//' -e '/}/d' | tr ',' '\n' | sed -e '/^\s\+$/d' -e 's/^\s\+//' | awk 'NR==2{prev=$0} NR>=3 {print $0"  --  "$0-prev;prev=$0}' | nl 
