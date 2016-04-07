#! /bin/bash -eu

#########################
#
# Name: scalar-mesan.bash
#
# Purpose: Convert rotatad scalar fields (MESAN) from GRIB to unrotated netCDF
#
# Usage: ./scalar-mesan.bash -i <input-grib-file>
#
# Revision history: 2016-03-22  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0
root_t2m_grib_folder=/nobackup/smhid9/sm_tland/euro4m/mesan_e4m/t2m/
output=/nobackup/rossby17/sm_maeva/Data/Primavera-upload/mesan/input/intermediate/t2m/

function usage {
 echo "Usage: ./scalar-mesan-t2m.bash -y <year>

   -y   year The year to convert (assumes smhid9 file structure)

  Convert rotatad scalar fields (MESAN) from GRIB to unrotated netCDF.
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

# Default behaviour without more than one
if [ $# -eq 0 ]; then
  usage_and_exit 0
fi

while getopts "hy:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    y)
        year=$OPTARG
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

root_t2m_grib_folder=${root_t2m_grib_folder}/${year}
output=${output}/${year}
mkdir -p ${output}

grid_description_file=/tmp/grid_description-${year}.txt

abs_value_files=$(ls ${root_t2m_grib_folder}/????????/*[^d].grb)
#std_value_files=$(ls ${root_t2m_grib_folder}/????????/*sd.grb)


for fullpath_input_grib_file in ${abs_value_files}
do
    input_grib_file=$(basename $fullpath_input_grib_file)
    log $input_grib_file
    # Remove any previous files
    if [ -f ${output}/${input_grib_file%*.grb}".nc" ]
    then
        continue
    fi

    rm -f ${output}/${input_grib_file%*.grb}"-curvilinear.nc"
    rm -f ${output}/${input_grib_file%*.grb}".nc"

    # Convert to curvilinear netCDF
    cdo -f nc setgridtype,curvilinear ${fullpath_input_grib_file} ${output}/${input_grib_file%*.grb}"-curvilinear.nc"
    echo "gridtype  : lonlat
    xsize     : 1286
    ysize     : 1222
    xinc      : 0.084
    yinc      : 0.049
    xfirst    : -44.2
    yfirst    : 22.1" > ${grid_description_file}

    # Reuse existing weight file
    set -- $(md5sum ${grid_description_file})
    md5grid=$1
    weightfile=${output}/$()
    weightfile=${output}/${input_grib_file%*_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].grb}"-weight-"${md5grid}"-"${year}".nc"

    if [ ! -f ${weightfile} ]
    then
        cdo genbil,${grid_description_file} ${output}/${input_grib_file%*.grb}"-curvilinear.nc" ${weightfile}
    fi
    cdo remap,${grid_description_file},${weightfile} ${output}/${input_grib_file%*.grb}"-curvilinear.nc" ${output}/${input_grib_file%*.grb}".nc"

    # Remove any curivlinear file
    rm -f ${output}/${input_grib_file%*.grb}"-curvilinear.nc"
done

rm -f ${grid_description_file}
