#! /bin/bash -eu

#########################
#
# Name:
#
# Purpose: Run PhotoFloat on target folder and (optionally)
#          export on Publisher
# Reference: https://git.zx2c4.com/PhotoFloat/about/
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
 echo "Usage: photofloatify.bash [-o <output-folder>] [-n] -i <input-folder> -t <tarball-name>

 -n skip publisher (default is set in cfg file)
 -i <input-folder> folder with figures
 -t <tarball-name> name to use for tarball download file
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
TARBALL_NAME="False"

# Default behaviour without any arguments
if [ $# -eq 0 ]; then
  usage_and_exit 0
fi


while getopts ":ni:t:h" opt
do
  case $opt in
     n)
        EXPORT_TO_PUBLISHER="False"
        ;;
     i)
        INPUT_FOLDER=$OPTARG
        ;;
     t)
        TARBALL_NAME=$OPTARG
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
old_outputs=""
then
    OUTPUT_FOLDER=${photofloat_workdir}
    if [ -d ${OUTPUT_FOLDER} ]
    then
        for num in 2 3 4 5 6 7 8 9
        do
            OUTPUT_FOLDER=$(dirname ${photofloat_workdir})"/"$(basename ${photofloat_workdir})$num
            if [ -d ${OUTPUT_FOLDER} ]
            then
                warning "Output folder ${OUTPUT_FOLDER} already exists"
                old_outputs=${old_outputs},${OUTPUT_FOLDER}
            else
                break
            fi
        done
        if [ -d ${OUTPUT_FOLDER} ]
        then
            error "Output folder ${OUTPUT_FOLDER} already exists"
        fi
    fi
fi

if [ ${TARBALL_NAME} == "False"  ]
then
    TARBALL_NAME=$(basename ${INPUT_FOLDER})
fi

git clone file://${photofloat_src} ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER}/web/albums
mkdir -p ${OUTPUT_FOLDER}/web/cache

sbatch -n 1 -t 45 -J ${OUTPUT_FOLDER} ~/scripts/photofloatify_PE.bash -i ${INPUT_FOLDER} -o ${OUTPUT_FOLDER} -t ${TARBALL_NAME} -e ${EXPORT_TO_PUBLISHER}
echo "======================="
echo "Obselete work dirs"
echo $old_outputs | sed 's/,/\n/g'
echo "======================="

echo "Wait for ${OUTPUT_FOLDER} to finish, then run,

  pcmd ${OUTPUT_FOLDER}/web tmp_rossby"
