#! /bin/bash -
 
#########################
# 
# Name: plot-mlog.bash
#
# Purpose: 
#
# Usage: ./plot-mlog.bash -n <output png filename>
#
# Revision history: 2016-09-26  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0


function usage {
 echo "Usage: ./plot-mlog.bash  -n <output png filename>
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

while getopts "hn:" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    n)
      png_filename=$OPTARG
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

if [ ! $# -eq 0 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi

tmpgnu=tmp.gnuplot
plotcmd="plot "
echo '#!/usr/bin/gnuplot -persist' > ${tmpgnu}
echo '     set title "Memory usage by node"
      set timefmt "%Y%m%d-%H:%M:%S"
      set xdata time
      set xlabel "Wall clock time"
      set yrange [0:1]
      set ylabel "Ratio of Node memory used"
      set terminal png' >> ${tmpgnu}
echo 'set output '${png_filename} >> ${tmpgnu}
for mfil in $(ls mlog.*)
do
    echo ${plotcmd}\"${mfil}\"' using 1:($3)/($2) with linespoints, \' >> ${tmpgnu}
    plotcmd=""
done
sed -i '$ s/, \\//' ${tmpgnu}
echo 'replot' >> ${tmpgnu}

chmod 755 ${tmpgnu}
./${tmpgnu}

#-#gnuplot -persist <<-EOFMarker
#-#    set title "Memory usage by node"
#-#    set timefmt "%Y%m%d-%H:%M:%S"
#-#    set xdata time
#-#    set xlabel "Wall clock time"
#-#    set yrange [0:1]
#-#    set ylabel "Ratio of Node memory used"
#-#    plot "mlog.n592" using 1:(\$3/\$2) with linespoints, \
#-#         "mlog.n591" using 1:(\$3/\$2) with linespoints
#-#EOFMarker
    #plot "mlog.592" using 1:3 with linespoints
    #plotplot "mlog.n592" using 1:(\$3/\$2) with linespoints, \ "mlog.592" using 1:($3/1000000) with linespoints
