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
 echo "Usage: photofloatify.bash [-o <output-folder>] [-n] -i <input-folder> -t <tarball-name>

 -o <output-folder>   skip default precompiled photofloat dir and create a new from scratch
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

while getopts ":o:ni:t:h" opt
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
then
    OUTPUT_FOLDER=${photofloat_workdir}
else
    if [ -d ${OUTPUT_FOLDER} ]
    then
        error "Output folder ${OUTPUT_FOLDER} already exists"
    fi
fi

if [ ${TARBALL_NAME} == "False"  ]
then
    TARBALL_NAME=$(basename ${INPUT_FOLDER})
fi

tarball_folder=${OUTPUT_FOLDER}/web/${TARBALL_NAME}
tarball_file=${TARBALL_NAME}.tar

git clone file://${photofloat_src} ${OUTPUT_FOLDER}
mkdir -p ${OUTPUT_FOLDER}/web/albums
mkdir -p ${OUTPUT_FOLDER}/web/cache
(cd ${OUTPUT_FOLDER}/web; make > /dev/null )

rsync -vaz ${INPUT_FOLDER}/ ${OUTPUT_FOLDER}/web/albums/
rsync -vaz ${INPUT_FOLDER}/ ${tarball_folder}/
(
cd $(dirname $tarball_folder)
tar cf ${tarball_file} ${TARBALL_NAME}
rm -rf ${tarball_folder}
)

cd ${OUTPUT_FOLDER}/scanner

./main.py ../web/albums ../web/cache
(
cd ../web
sed -i "/<div id=\"subalbums\"><\/div>/a \<div\>\<h3\>Download all: \<a href=\""${tarball_file}\"">"${tarball_file}"\<\/a\>\<\/h3\>\<\/div\>" index.html
rm -f *~
)

if [ ${EXPORT_TO_PUBLISHER} == "True"  ]
then
    pcmd $(readlink -f ../web) tmp_rossby
fi
