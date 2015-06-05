#! /usr/bin/env python

import argparse
import Model
import os
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
        curr_model_key = "-".join([m.var, m.mip, m.exp])
        uniq_keys = uniq(uniq_keys + [curr_model_key])

        # Save model-key
        model_key = curr_model_key + "-" + curr_model
        models_by_key.setdefault(model_key, []).append(file)

# Primary sort on experiment, secondary sort on MIP, Tertinary sort on variable
sort1 = sorted(uniq_keys, key=lambda x: (x.split("-", 2)[2], x.split("-", 2)[1], x.split("-", 2)[0]))

pdb.set_trace()


model = "HadGEM3-A"
#for key in uniq_keys:

