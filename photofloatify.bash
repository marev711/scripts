#! /bin/bash -xeu
 
#########################
# 
# Name: 
#
# Purpose: Run PhotoFloat on target folder and (optionally) 
#          export on Publisher
#
# Usage: ./photofloatify.bash
#
# Revision history: 2015-07-01  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0


# source variables
# * photofloat_src
# * photofloat_workdir
# * EXPORT_TO_PUBLISHER
source ${HOME}/scripts/photofloatify.cfg

function usage {
 echo "Usage: photofloatify.bash [-o <output-folder>] [-n] -i <input-folder> 

 -o <output-folder>   skip default precompiled photofloat dir and create a new from scratch
 -n skip publisher (default is set in cfg file)
 -i <input-folder> folder with figures
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

OUTPUT_FOLDER="False"
INPUT_FOLDER="False"

while getopts ":o:ni:h" opt
do
  case $opt in 
     n)
        EXPORT_TO_PUBLISHER="False"
        ;;
     o)
        OUTPUT_FOLDER=$OPTARG
        ;;
     i)
        INPUT_FOLDER=$OPTARG
        ;;
     h)
        usage_and_exit
        ;;
      \?)
        printf '\n%s\n\n' "Unknown option $1" 1>&2
        usage_and_exit 1
        ;;
  esac  
done
if [ ${INPUT_FOLDER} == "False"  ]
then
    error "Input folder not set"
fi

if [ ${OUTPUT_FOLDER} == "False"  ]
then
    OUTPUT_FOLDER=${photofloat_workdir}
else
    if [ -d ${OUTPUT_FOLDER} ]
    then
        error "Output folder ${OUTPUT_FOLDER} already exists"
    fi
fi

git clone file://${photofloat_src} ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER}/web/albums
mkdir -p ${OUTPUT_FOLDER}/web/cache
(cd ${OUTPUT_FOLDER}/web; make > /dev/null )

rsync -vaz ${INPUT_FOLDER}/ ${OUTPUT_FOLDER}/web/albums/
cd ${OUTPUT_FOLDER}/scanner

./main.py ../web/albums ../web/cache

if [ ${EXPORT_TO_PUBLISHER} == "True"  ]
then
    pcmd $(readlink -f ../web) tmp_rossby
fi
