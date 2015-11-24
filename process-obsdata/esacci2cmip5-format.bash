#! /bin/bash -eu
 
#########################
# 
# Name: esacci2cmip5-format.bash
#
# Purpose: Rewrite ESA-CCI variable files to CMIP5:ish format
#
# Usage: ./esacci2cmip5-format.bash [-h] -i input-directory -o output-directory
#
#    -h   displays help text
#    -i   input directory
#    -o   output directory
#
#    Extracts, rename and concateante variables from ESA-CCI files
#    into a sinlge CMIP5:ish file.
#
# Revision history: 2015-11-20  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

cmip_variable=clwvi  # clivi, clt
cci_variable=lwp     # iwp  , cc_total
cmip_filename=${cmip_variable}_Amon_ESACCI-L3C_CLOUD-CLD_PRODUCTS-AVHRR-fv1.4_observation_r1i1p1
# data folder as of Nov 2015: /nobackup/rossby17/rossby/joint_exp/esacci/Clouds/phase2/

function usage {
 echo "
 Usage: ./esacci2cmip5-format.bash [-h] -i input-directory -o output-directory

    -h   displays help text
    -i   input directory
    -o   output directory

    Extracts, rename and concateante variables from ESA-CCI files
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
      usage_and_exit 1
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
    case ${cmip_variable} in
        cc_total)
            # Extract cci_variable and scale variable (fraction -> %)
            cdo mulc,100 -selvar,${cci_variable} $line ${output_tmp}/$(basename ${line%*.nc})-${cmip_variable}.nc
            ;;
        clwvi)
            # Extract lwp
            cdo selvar,${cci_variable} $line ${output_tmp}/$(basename ${line%*.nc})-${cmip_variable}.nc
            ;;
        clivi)
            # Extract lwp
            cdo selvar,${cci_variable} $line ${output_tmp}/$(basename ${line%*.nc})-${cmip_variable}.nc
            ;;
    esac

done

# Concatenate to single file
ncrcat $(ls -1 ${output_tmp}/* | tr '\n' ' ') ${output_tmp}/tmp1.nc

# Update unit attribute
ncatted -a units,${cci_variable},c,c,"%" ${output_tmp}/tmp1.nc

# Rename variable
ncrename -v ${cci_variable},${cmip_variable} ${output_tmp}/tmp1.nc ${cmip5_file}
