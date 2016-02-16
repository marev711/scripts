#! /bin/bash -eu

#########################
#
# Name:
#
# Purpose: PE-part of PhotoFloat on target folder and (optionally)
#          export on Publisher
#
# Usage: ./home/sm_maeva/scripts/photofloatify-PE.bash
#
# Revision history: 2016-02-16  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function exit_on_error()
{
    mail -s "${program} failed..." martin.evaldsson@smhi.se << EOMAIL
    See $1/$2
EOMAIL
}

function usage {
 echo "Usage: photofloatify_PE.bash [-o <output-folder>] [-n] -i <input-folder> -t <tarball-name>

 -o <output-folder>   skip default precompiled photofloat dir and create a new from scratch
 -i <input-folder> folder with figures
 -t <tarball-name> name to use for tarball download file
 -e <logical> if to export to publisher (True/False)
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

while getopts ":o:e:i:t:h" opt
do
  case $opt in
     e)
        EXPORT_TO_PUBLISHER=$OPTARG
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

if [ ! $# -eq 8 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi


(cd ${OUTPUT_FOLDER}/web; make > /dev/null )

tarball_folder=${OUTPUT_FOLDER}/web/${TARBALL_NAME}
tarball_file=${TARBALL_NAME}.tar

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
