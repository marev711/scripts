#! /bin/bash -
 
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

function usage {
 echo "Usage: ./scalar-mesan.bash -i <input-grib-file>

        -i   input GRIB file (must be a scalar field)

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

while getopts "hi:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    i)
        input_grib_file=$OPTARG
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

# Remove any previous files
rm -f ${input_grib_file%*.grb}"-curvilinear.nc"
rm -f ${input_grib_file%*.grb}".nc"

grid_description_file=/tmp/grid_description.txt

# Convert to curvilinear netCDF
cdo -f nc setgridtype,curvilinear ${input_grib_file} ${input_grib_file%*.grb}"-curvilinear.nc" 
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
weightfile=${input_grib_file%*.grb}"-weight-"${md5grid}".nc"

if [ ! -f ${weightfile} ]
then
    cdo genbil,${grid_description_file} ${input_grib_file%*.grb}"-curvilinear.nc" ${weightfile}
fi

cdo remap,${grid_description_file},${weightfile} ${input_grib_file%*.grb}"-curvilinear.nc" ${input_grib_file%*.grb}".nc" 

rm -f ${grid_description_file}
