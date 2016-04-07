#! /bin/bash -eu

#########################
#
# Name: scalar-mesan-t2m-meta.bash
#
# Purpose: Add variable meta data to mesan scalar field file t2m
#
# Usage: ./scalar-mesan-var-meta.bash -y <year>
#
# Revision history: 2016-03-25  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0
input=/nobackup/rossby17/sm_maeva/Data/Primavera-upload/mesan/input/intermediate/t2m/
output=/nobackup/rossby17/sm_maeva/Data/Primavera-upload/mesan/input/intermediate/t2m/
run_in=(MESAN)
run=0
var_in=(tas)
var=0
var_out=${var_in[$var]}
cdo='cdo -s -L'
scratch=/scratch/local

case ${var_in[$var]} in
    tas) 
        mesan_name=var11
        var_grb=t2m
        ;;
esac

function usage {
 echo "Usage: ./scalar-mesan-t2m-meta.bash -y <year>

   -y   year Sub folder

  Add variable meta data to mesan t2m scalar field file
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

input=${input}/${year}
output=${output}/${year}

# ---- read simulation info -----
exp_definition="./auxiliary-merra2/exp_definition_file.txt"
source $exp_definition

case ${var_grb} in
    t2m)
        table_out="3hr"
        time_snippet=${year}010100-${year}123121
        ;;
esac
        
file_out=${output}/${var_out}_$table_out'_'$gcm_name'_'$experiment_id'_'$gcm_version_id'_'${time_snippet}'.nc'
file_tmp=${output}/tmp_${var_out}_$table_out'_'$gcm_name'_'$experiment_id'_'$gcm_version_id'_'${time_snippet}'.nc'

log "Set reftime for ${file_tmp}"
ref_time='1949-01-01,00:00'  # reference time
ls -1 ${input}/${var_grb}_* | grep -v '.*weight.*' | while read line 
do
    $cdo -setreftime,${ref_time} ${line} ${scratch}/"reftime_"$(basename ${line})
done
log "Set reftime done"

log "Concatenate files into ${file_out}"
if [ ! -f ${file_out} ]
then
    ncrcat -h $(ls -1 ${scratch}/reftime_*_${year}* | grep -v '.*weight.*') ${file_out}
fi
log "Files concatenated"

rm -f ${scratch}/reftime_*

log "Renaming file ${file_out}"
ncrename -v "."${mesan_name},${var_out} ${file_out} -h
log "File renamed"

# --- read variable info ---
file_var='./auxiliary-merra2/cmip5_meta.txt'
source $file_var

# ---------------------------
# --- VARIABLE ATTRIBUTES ---
# ---------------------------
#  ncrename -v $merra_name,${var_in[$var]} -h $file_out
log "Adding attributes to ${file_out}"
ncatted -a grid_name,${var_out},d,, \
        -a comments,${var_out},d,, \
        -a table,${var_out},d,, \
        -a level_description,${var_out},d,, \
        -a standard_name,${var_out},d,, \
        -a long_name,${var_out},d,, \
        -a units,${var_out},d,, \
        -a time_statistic,${var_out},d,, \
        -a standard_name,${var_out},c,c,"$standard_name" \
        -a long_name,${var_out},c,c,"$long_name" \
        -a units,${var_out},c,c,"$units" \
        -a missing_value,${var_out},m,f,1.e+20 \
        -a _FillValue,${var_out},m,f,1.e+20 \
        -a cell_methods,${var_out},c,c,"mean" -h $file_out

log "Complete: ${file_out}"
