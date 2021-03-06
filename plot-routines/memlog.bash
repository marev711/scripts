#! /bin/bash -
 
#########################
# 
# Name: memlog.bash
#
# Purpose: Check and log memory usage on set of nodes
#
# Usage: ./memlog.bash -j jobid -r
#
#         For continuous logging, use something like, 
#         while true;do ./memlog.bash -j <JOBID>;sleep 30;done
#
# Revision history: 2016-09-26  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function usage {
 echo "Usage: ./memlog.bash -j jobid -r
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
while getopts "hj:r" opt; do
  case $opt in
    h)
      usage_and_exit 0
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
nodes=$(squeue -j ${jobid} -o "%N" | tail -1)
node_list=$(hostlist -e ${nodes} | tr '\n' ',' | sed 's/,$//')

if [ ${remove_memlog_files} == "true" ]
then
    for node in $(echo ${node_list} | sed 's/,/ /g')
    do
        rm -f mlog.${node}
    done
fi

for node in $(echo ${node_list} | sed 's/,/ /g')
do
    target_file=mlog.${node}
    max_mem=$(jobsh -j ${jobid} ${node} free 2>/dev/null | grep -i 'Mem:' | awk '{print $2}')
    curr_mem=$(jobsh -j ${jobid} ${node} free 2>/dev/null | grep -i 'cache:' | awk '{print $3}')
    mlog_current=$(echo $(date +%Y%m%d-%H:%M:%S)" "${max_mem}"    "${curr_mem})
    if [ ${#mlog_current} -lt 23 ]
    then
        break
    fi
    echo ${mlog_current} >> ${target_file}
    info logged $node of ${node_list} to file ${target_file}
    sleep 1
done
