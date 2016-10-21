#!/bin/bash -x
date
if [[ $# -gt 0 ]]; then
    tid=$1    
else	   
    tid=00:25:00 
fi	
cd ~/bin/timers/wmtimer-2.92/wmtimer
./wmtimer -e ./done -t $tid -c &
hour=$(echo $tid | awk 'BEGIN { FS=":"}; {print $1}')
min=$(echo $tid | awk 'BEGIN { FS=":"}; {print $2}')
sec=$(echo $tid | awk 'BEGIN { FS=":"}; {print $3}')
hours=$((10#$hour*3600))
mins=$((10#$min*60))
secs=$(($hours+$mins+$sec+8))
sleep $secs
wmtimer_id=$(ps -e | awk '/wmtimer/ && !/awk/ {print $1}')
kill $wmtimer_id
~/scripts/pomodoro-is-up.py
date
