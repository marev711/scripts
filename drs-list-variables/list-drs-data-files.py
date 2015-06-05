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

all_vars = []
regex_ncfile = re.compile('.*.nc$')
regex_sftlf = re.compile('^sftlf_.*')

for root, dirs, files in os.walk(args.rootdir):
    if len(dirs) > 0:
        continue
        continue
    for file in [fil for fil in files 
                   if regex_ncfile.search(fil) is not None
                 and 
                   regex_sftlf.search(fil) is None]:
        curr_model = [model for model in MODELS if re.search(model, file + "$") is not None][0]
        curr_model_class = re.sub("-", "_", curr_model)
        all_vars.append(getattr(vars()['Model'], curr_model_class)(file))
#        if len(all_vars) == 6858:
#            pdb.set_trace()

uniq_keys = []
for model in MODELS:
    curr_model_keys = ["-".join([m.var, m.mip, m.exp]) for m in all_vars if m.model_name == model]
    uniq_keys = uniq(uniq_keys + curr_model_keys)

pdb.set_trace()
    
