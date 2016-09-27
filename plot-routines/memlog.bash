#! /bin/bash -
 
#########################
# 
# Name: memlog.bash
#
# Purpose: Check and log memory usage on set of nodes
#
# Usage: ./memlog.bash -n node-list -j jobid -s
#
# Revision history: 2016-09-26  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
 echo "Usage: ./memlog.bash -n node-list -j jobid -r
 -n  nodelist  - nodelist as listed by sq on Bi, e.g., n[530-545,551]
 -j     jobid  - job ID
 -r            - remove existing memlog-files
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
    log "*WW* $*" 1>&2
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

# Default behaviour without any arguments
if [ $# -eq 0 ]; then
  usage_and_exit 0
fi

remove_memlog_files=false
while getopts "hn:j:r" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    n)
        nodes=$(hostlist -e $OPTARG | tr '\n' ',' | sed 's/,$//')
      ;;
    j)
        jobid=$OPTARG
      ;;
    r)
        remove_memlog_files=true
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

if [ ${remove_memlog_files} == "true" ]
then
    for node in $(echo $nodes | sed 's/,/ /g')
    do
        rm -f mlog.${node}
    done
fi

for node in $(echo $nodes | sed 's/,/ /g')
do
    target_file=mlog.${node}
    mlog_current=$(echo $(date +%Y%m%d-%H:%M:%S)" " $(jobsh -j ${jobid} ${node} free 2>/dev/null | grep Mem | sed 's/Mem://'))
    if [ ${#mlog_current} -lt 20 ]
    then
        break
    fi
    echo ${mlog_current} >> ${target_file}
    info logged $node of $nodes to file ${target_file}
    sleep 1
done
