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
        curr_model = [model for model in MODELS if re.search("_" + model + "_", file) is not None][0]
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

# Primary sort on MIP, secondary sort on variable
mip_order = ["Amon", "day", "3hr", "6hrPlev", "Lmon", "OImon", "Omon", "Oyr"]
sorted_keys = sorted(uniq_keys, key=lambda x: (mip_order.index(x.split("-", 2)[1]), x.split("-", 2)[0]))

#sorted_keys = sorted(uniq_keys, key=lambda x: (x.split("-", 2)[1], x.split("-", 2)[0]))

regex_key = re.compile("(.*)-(.*)")
headers = [x for x in itertools.product(MODELS, all_exps)]
header_str = ", " + ", ".join([x[0] + " (" + x[1] + ")" for x in headers])
headers_len = len(headers)

output_csv = "test.csv"
fcsv = open(output_csv, "w")
fcsv.write(header_str)
fcsv.write("\n")

regex_yrs = re.compile("([0-9]{4})[0-9]*-([0-9]{4})[0-9]*.*.nc")

# Write the main table
for key in sorted_keys:
    mip = regex_key.search(key).group(2)
    var = regex_key.search(key).group(1)

    # Special loop for intersection years
    request_keys = ["-".join([var, mip, header[0], header[1]]) for header in headers]
    all_files = [models_by_key[f] for f in request_keys if f in models_by_key.keys()]
#    pdb.set_trace()
    min_yrs = [min([regex_yrs.search(x).group(1) for x in l]) for l in all_files]
    max_yrs = [max([regex_yrs.search(x).group(2) for x in l]) for l in all_files]
    min_all = max(min_yrs)
    max_all = min(max_yrs)

    for idx, header in enumerate([x[0] + "-" + x[1] for x in headers], start=1):
        request_key = "-".join([var, mip, header])

        if idx == 1:
            fcsv.write(mip + " (" + min_all + "-" + max_all + "), ")

        if request_key in models_by_key.keys():
            fcsv.write(var)

        if idx < headers_len:
            fcsv.write(", ")
        else:
            fcsv.write("\n")
fcsv.close()


output_yrs = "test.yrs"
fyrs = open(output_yrs, "w")
fyrs.write(header_str)
fyrs.write("\n")

# Write table with years
all_mips = uniq([regex_key.search(m).group(2) for m in sorted_keys])

for mip in all_mips:

    for idx, header in enumerate([x[0] + "-" + x[1] for x in headers], start=1):
        request_key = "-".join([mip, header])

        var_key = [varkey for varkey in models_by_key.keys() if re.search(request_key, varkey) is not None]
        if len(var_key) > 0:
            all_files = [models_by_key[f] for f in var_key]
            files = [item for sublist in all_files for item in sublist]
            all_yrs = [regex_yrs.search(x).group(1,2) for x in files]
            min_yrs = min([x[0] for x in all_yrs])
            max_yrs = max([x[1] for x in all_yrs])

        if idx == 1:
            fyrs.write(mip + ", ")

        #pdb.set_trace()
        if len(var_key) > 0:
            yrs_str = min_yrs + "-" + max_yrs
            fyrs.write(yrs_str)

        if idx < headers_len:
            fyrs.write(", ")
        else:
            fyrs.write("\n")

fyrs.close()
