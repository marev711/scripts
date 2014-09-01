#! /bin/bash -ue
 
#########################
# 
# Name: 
#
# Purpose: 
#
# Usage: .//home/sm_maeva/scripts/time_list.bash
#
# Revision history: 2014-08-31  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
echo "Usage: ./time_diff.bash [-h] [--variable <time-dim>] [--nl <nl_arg>] <netCDf-file>
   <time-dim>  -  variable name of time dimension (defaults to time)
   <nl_arg>  -  first line number to use (defaults to 1)
   <netCDf-file>  -  netCDF-file to investigate

   Print enumerated columns with the time dimension in a readable format
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

if [ $# -lt 1 -o $# -gt 6 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit
fi

file=${@: -1}
variable=time
nl_arg=1

while (( "$#" > 1 )); do 
  case $1 in 
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
     --variable|--variabl|--variab|--varia|--vari|--var|--va|--v|\
      -variable| -variabl| -variab| -varia| -vari| -var| -va| -v)
        variable=$2
        shift 2
        ;;
     --nl|--n| -nl| -n)
         nl_arg=$2
         shift 2
         ;;
  esac  
done
ncdump -tv $variable $file | sed -e '1,/data:/d' -e 's/time = //' -e 's/ ;//' -e '/}/d' | tr ',' '\n' | sed -e '/^\s\+$/d' -e 's/^\s\+//' |  nl -v $nl_arg
