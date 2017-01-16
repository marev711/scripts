#! /bin/bash -ue
 
#########################
# 
# Name: plot-mlog.bash
#
# Purpose: Plot timings files prepared with the associated "01-rewrite-timings.py"-script
#
# Usage: ./plot-mlog.bash -n <output png filename>
#
# Revision history: 2016-09-26  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

# Hard coded gnuplot variables to configure further down
# xrange
# format
# yrange

# Hard codes settings to configure here
title="IFS T255 at 127 cores, 7 2D varibales from ISCCP + CALIPSO"
xlabel="Wall clock time"
ylabel="Computational time step (s)"

function usage {
 echo "Usage: ./02-plot-timings.bash -n <output png filename> -i <infile1>,<infile2>,... -l <legend1>,<legend2>,...

 Plot the the indata files <infile1> with legend
 <legend1>, etc.. Indata files has to be prepared
 with the associate script 01-rewrite-timings.py
 script

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

while getopts "hn:i:l:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    n)
      png_filename=$OPTARG
      ;;
    i)
      IFS="," read -r -a infiles <<< $OPTARG
      ;;
    l)
      IFS="," read -r -a legends <<< $OPTARG
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

tmpgnu=tmp.gnuplot
plotcmd="plot "

echo '#!/usr/bin/gnuplot -persist' > ${tmpgnu}
{
    echo set title \"${title}\"
    echo set xlabel \"${xlabel}\"
    echo set timefmt \"%d/%m\"
    echo set xdata time
    echo set xrange '[ "1/1":"31/1" ]'
    echo set format x \"%d Jan\"
    echo set yrange [ 0 : 6]
    echo set ylabel \"${ylabel}\"
    echo set timefmt \"%d,%H,%M\"
    echo set grid
    echo set key left
    echo set terminal png
} >> ${tmpgnu}
echo set output '"'${png_filename}'"' >> ${tmpgnu}
for ((i=0; i<${#infiles[*]}; ++i))
do
    echo ${plotcmd} \"${infiles[i]}\" using 6:8 title \"${legends[i]}\", \\ >> ${tmpgnu}
    plotcmd=""
    set +u
done
set -u
sed -i '$ s/, \\//' ${tmpgnu}
echo 'replot' >> ${tmpgnu}

chmod 755 ${tmpgnu}
./${tmpgnu}
