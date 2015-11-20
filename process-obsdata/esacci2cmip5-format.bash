#! /bin/bash -eux
 
#########################
# 
# Name: esacci2cmip5-format.bash
#
# Purpose: Rewrite ESA-CCI cc_total files to CMIP5:ish format
#
# Usage: ./esacci2cmip5-format.bash [-h] -i input-directory -o output-directory
#
#    -h   displays help text
#    -i   input directory
#    -o   output directory
#
#    Extracts, rename and concateante variable 'cc_total' from raw ESA-CCI files
#    into a sinlge CMIP5:ish file.
#
# Revision history: 2015-11-20  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

cmip_filename=clt_Amon_ESACCI-L3C_CLOUD-CLD_PRODUCTS-AVHRR-fv1.4_observation_r1i1p1_

function usage {
 echo "
 Usage: ./esacci2cmip5-format.bash [-h] -i input-directory -o output-directory

    -h   displays help text
    -i   input directory
    -o   output directory

    Extracts, rename and concateante variable 'cc_total' from raw ESA-CCI files
    into a sinlge CMIP5:ish file.
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


while getopts "hi:o:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    i)
        input_directory=$OPTARG
      ;;
    o)
        output_directory=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

all_input=$(ls -1 ${input_directory}/*nc)
first_date=$(basename $(ls -1 ${input_directory}/*nc | awk -F - '{print $1}' | sort | head -1))
last_date=$(basename $(ls -1 ${input_directory}/*nc | awk -F - '{print $1}' | sort | tail -1))

output_tmp=${output_directory}/tmp
mkdir $output_tmp
cmip5_file=${output_directory}/${cmip_filename}_${first_date}-${last_date}.nc

for line in ${all_input}
do
    # Extract cc_total and adjust units
    cdo mulc,100 -selvar,cc_total $line ${output_tmp}/$(basename ${line%*.nc})-clt.nc
done

# Concatenate to singel file
ncrcat $(ls -1 ${output_tmp}/* | tr '\n' ' ') ${output_tmp}/tmp1.nc

# Change untis
ncatted -a units,cc_total,c,c,"%" ${output_tmp}/tmp1.nc

# Rename variable
ncrename -v cc_total,clt ${output_tmp}/tmp1.nc ${cmip5_file}
