#! /bin/bash -
 
#########################
# 
# Name: dcrypt.bash
#
# Purpose: Wrapper to encrypt files with openssl
#
# Usage: ./dcrypt.bash <file>
#
# Revision history: 2014-12-15  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0


function usage {
 echo "Usage:  ./dcrypt.bash <file-to-encrypt>
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

if [ ! $# -eq 1 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi

infile=$1
outfile=${infile%*.enc}

#while (( "$#" )); do 
#  case $1 in 
#     firstChoice)
#        ;;
#     --help|--hel|--he|--h|-help|-hel|-he|-h)
#        usage_and_exit
#        ;;
#      --)
#        set --
#        ;;
#      *)
#        printf '\n%s\n\n' "Unknown flag $1" 2>&1
#        usage_and_exit 1
#        ;;
#  esac  
#done
openssl enc -aes-256-cbc -d -in $infile -out $outfile
