#! /bin/bash -eu
 
#########################
# 
# Name: clara2cmip5-format.bash
#
# Purpose: Rewrite CLARA cfc files to CMIP5:ish format
#
# Usage: ./clara-a2cmip5-format.bash [-h] -o output-directory
#
#    -h   displays help text
#    -o   output directory
#
#    Extracts, rename and concateante variable 'cc_total' from raw CLARA-A2 files
#    into a sinlge CMIP5:ish file.
#
# Revision history: 2015-11-20  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

clara_globbed_dir='/nobackup/smhid11/foua/data/CLARA-A2/[0-9][0-9][0-9][0-9]/[0-9][0-9]/nc/AVPOS_[0-9][0-9][0-9][0-9][0-9][0-9]_GAC_V002_L3/'
filename_var=CFC
origvarname=cfc
targetvarname=clt
cmip_filename=${targetvarname}_Amon_CLARA-A2-GAC-V002-L3_observation_r1i1p1

function usage {
 echo "
 Usage: ./clara-a2cmip5-format.bash [-h] -o output-directory

    -h   displays help text
    -o   output directory

    Extracts, rename and concateante variable 'cc_total' from raw CLARA-A2 files
    into a sinlge CMIP5:ish file.
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

if [ $# -eq 0 ]; then
  usage_and_exit 0
fi


while getopts "ho:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    o)
        output_directory=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

all_input=$(ls -1 ${clara_globbed_dir}/${filename_var}*GL.nc)
first_date=$(echo $all_input | basename $(tr ' ' '\n' | head -1) | awk -F m '{print $3}' | sed 's/\([0-9][0-9][0-9][0-9][0-9][0-9]\)[0-9]*.*/\1/')
last_date=$(echo $all_input | basename $(tr ' ' '\n' | tail -1) | awk -F m '{print $3}' | sed 's/\([0-9][0-9][0-9][0-9][0-9][0-9]\)[0-9]*.*/\1/')
output_tmp=${output_directory}/tmp
mkdir $output_tmp
cmip5_file=${output_directory}/${cmip_filename}_${first_date}-${last_date}.nc

for line in ${all_input}
do
    # Extract variable
    cdo selvar,${origvarname} $line ${output_tmp}/$(basename ${line%*.nc})-${targetvarname}.nc
done

# Concatenate to single file
ncrcat $(ls -1 ${output_tmp}/* | tr '\n' ' ') ${output_tmp}/tmp1.nc

# Rename variable
ncrename -v ${origvarname},${targetvarname} ${output_tmp}/tmp1.nc ${cmip5_file}
