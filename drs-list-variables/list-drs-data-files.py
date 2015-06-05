#! /usr/bin/env python

import argparse
import Model
import os
import itertools
import pdb
import re

def uniq(seq):
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if not (x in seen or seen_add(x))]

MODELS = ["EC-EARTH3",
          "EC-EARTH3-WAM",
          "MPIESM_1_1",
          "MPIESM_1_no_embrace",
          "MPIESM_1_with_embrace",
          "HadGEM3-A",
          "HadGEM3-A-N216",
          "HadGEM3-GC2-N216",
          "HadGEM3-GC2-N96",
          "CNRM-AM-PRE6"]

parser = argparse.ArgumentParser()
parser.add_argument("-r", "--rootdir", type=str, help="The root path to scan for cmorized data sets")
parser.add_argument("-v", "--variable_file", type=str, help="The file with expected variables and their MIP, formatted as rows with: <VAR>  <MIP>")
args = parser.parse_args()

regex_ncfile = re.compile('.*.nc$')
regex_sftlf = re.compile('^sftlf_.*')

all_vars = []
all_exps = []
uniq_keys = []
models_by_key = {}

for root, dirs, files in os.walk(args.rootdir):
    if len(dirs) > 0:
        continue
    # Skip non-netCDF files and sftlf (lsm) file
    for file in [fil for fil in files
                   if regex_ncfile.search(fil) is not None
                 and
                   regex_sftlf.search(fil) is None]:
        curr_model = [model for model in MODELS if re.search(model, file + "$") is not None][0]
        curr_model_class = re.sub("-", "_", curr_model)

        # Initiate and append correct model class for each file
        m = getattr(vars()['Model'], curr_model_class)(file)
        all_vars.append(m)

        # Save new (uniqe variable-mip-experiment keys)
        curr_model_var_mip = "-".join([m.var, m.mip])
        uniq_keys = uniq(uniq_keys + [curr_model_var_mip])
        all_exps = uniq(all_exps + [m.exp])

        # Save model-key
        model_key = "-".join([m.var, m.mip, curr_model, m.exp])
        models_by_key.setdefault(model_key, []).append(file)

# Primary sort on experiment, secondary sort on MIP, Tertinary sort on variable
sorted_keys = sorted(uniq_keys, key=lambda x: (x.split("-", 2)[1], x.split("-", 2)[0]))

regex_key = re.compile("(.*)-(.*)")
headers = [x for x in itertools.product(MODELS, all_exps)]
header_str = ", ".join([x[0] + " (" + x[1] + ")" for x in headers])

output_csv = "test.csv"
fcsv = open(output_csv, "w")
fcsv.write(header_str)
fcsv.write("\n")


for key in sorted_keys:
    mip = regex_key.search(key).group(2)
    var = regex_key.search(key).group(1)

    headers_len = len(headers)
    for idx, header in enumerate([x[0] + "-" + x[1] for x in headers], start=1):
        request_key = "-".join([var, mip, header])
        if request_key in models_by_key.keys():
            fcsv.write(var)
        if idx < headers_len:
            fcsv.write(", ")
        else:
            fcsv.write("\n")
        
#    for model in MODELS:
        



model = "HadGEM3-A"
#for key in uniq_keys:

