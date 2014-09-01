#! /bin/bash -eu
 
#########################
# 
# Name: insert_history.bash
#
# Purpose: Insert a history comment in the global netCDF "history"
#          attribute (with datestamp)
#
# Usage: ./insert_history.bash [-b] "text" <file>
#
# Revision history: 2014-03-27  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function exit_on_error()
{
    :
}

trap 'exit_on_error' ERR

function usage {
 echo "Usage: ./insert_history.bash [-b] <text> <file>
   -b  --  keep backup file
   Inserts <text> at the beginning of the global history attribute
" 1>&2 
}

function log {
 echo "[ $(date -u '+%Y-%m-%d  %H:%M') ]: " $*
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

if [ $# -lt 2 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi

keep_backup=false
while (( "$#" > 2 )); do 
  case $1 in 
     -b)
        keep_backup=true
        shift
        ;;
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
      *)
        printf '\n%s\n\n' "Unknown flag $1" 2>&1
        usage_and_exit 1
        ;;
  esac  
done
datestamp=$(date -u)
text_to_add="$1"
target_file="${2}"
target_file_backup="${2}.backup.nc"
cp $target_file $target_file_backup
ncl ~/scripts/insert_history_attribute.ncl text_to_add=\""$text_to_add"\" target_file=\"$target_file\" datestamp=\""$datestamp"\"

if ${keep_backup}; then
    :  # noop
else
    rm -f $target_file_backup
fi
