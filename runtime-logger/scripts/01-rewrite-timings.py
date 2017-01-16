import argparse
import datetime
import pdb
import re
import sys

parser = argparse.ArgumentParser(description="Read EC-Earth IFS stdout.err file and rewrite timings to be run with seprate plot script plot-timings.bash")
parser.add_argument("-i",
                    "--infile",
                    dest="infile",
                    type=str,
                    required=True,
                    help="Input file")
parser.add_argument("-c",
                    "--cumulative",
                    dest="cumulative",
                    action="store_true",
                    default=False,
                    help="Cumulative timings")
args = parser.parse_args()

regex = re.compile("(.*H=\s+)([0-9][0-9]*):([0-9][0-9])(\s+\+CPU=\s+)([0-9][0-9]*[0-9.][0-9]*)")
tot_cumulative = 0.0
tfactor=1.
f = open(args.infile, "r")
for line in f.readlines():
    hours, minutes = regex.search(line.strip()).group(2, 3)
    seconds = int(hours) * 3600 + int(minutes) * 60
    date = datetime.datetime(2017, 1, 1) + datetime.timedelta(seconds=seconds)
    day = str(date.day)
    hour = str(date.hour)
    minute = str(date.minute)
    pre, cpu, timings = regex.search(line.strip()).group(1, 4, 5)
    if args.cumulative:
        tot_cumulative = tot_cumulative + float(timings)
        timings = tot_cumulative
        tfactor=60.

    sys.stdout.write(pre + ",".join([day, hour, minute]) + cpu + " " + str(float(timings)/tfactor) + "\n")
