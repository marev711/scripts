#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime
import os
import pdb
import re
import sys
from argparse import ArgumentParser

def skip_file(err_string, array):
    array.append(err_string)

# Check command arguments.
description = """parse-members.py
Reads, parses and writes input txt files with membership info to csv"""

parser = ArgumentParser(description=description)
parser.add_argument("-i", "--input",
                    dest="input",
                    type=str,
                    nargs='+',
                    required=True,
                    help="Input files to parse")
parser.add_argument("-o", "--old-style",
                    action="store_true",
                    dest='oldtime',
                    default=False,
                    help="Expect the old-style text file structure")
parser.add_argument("-s", "--skip-on-error",
                    action="store_true",
                    dest='fail_on_error',
                    default=False,
                    help="Skip erroneous files")
args = parser.parse_args()

if args.oldtime:
    skipping_files = []
    for file in args.input:
        infile = open(file, "r")
        lines = infile.readlines()
        if len(lines[2].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (1)", skipping_files)
            continue
        if re.search('[0-9 ]{5,6}', lines[3].strip()) is None and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected postal number (1): " + lines[3].strip(), skipping_files)
            continue
        if len(lines[4].strip()) == 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (1)", skipping_files)
            continue
        if re.search('[0-9 ]{5,6}', lines[5].strip()) is None and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected postal number (2): " + lines[5].strip(), skipping_files)
            continue
        if len(lines[9].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (2)", skipping_files)
            continue
        if len(lines[11].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (3)", skipping_files)
            continue
        if len(lines[13].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (4)", skipping_files)
            continue
        datum = datetime.datetime.strptime("2015" + re.search("([0-9]{4})-[0-9]{2}.txt", file).group(1), "%Y%m%d")
        datum_str = datum.strftime('%Y-%m-%d').strip()
        namn = re.search('Från (.*)', lines[0]).group(1).strip()
        epost = re.search('Email <(.*)>', lines[1]).group(1).strip()
        if re.search('[^@]+@[^@]+\.[^@]+', epost) is None and args.fail_on_error:
            skip_file("skipping file " + file + ", e-post error", skipping_files)
            continue
        postalnumber = lines[3].strip()
        adress = lines[4].strip()
        stad = lines[6].strip()
        lan = lines[7].strip()
        land = lines[8].strip()
        telefon = re.search('Telefonnummer: ([0-9- ]*)', lines[10]).group(1).strip()
        fodelsedatum = re.search('Födelsedatum: ([0-9]+).*', lines[12].strip()).group(1).strip()
        kon = re.search('Födelsedatum: [0-9]+[ ]*(.*)', lines[12].strip()).group(1).strip()
        meddelande = re.search('Eventuellt meddelande:(.*)', lines[14].strip()).group(1).strip()
        print ";".join([datum_str, namn, epost, postalnumber, adress, stad, lan, land, telefon, fodelsedatum, kon, meddelande])
else:
    skipping_files = []
    for file in args.input:
        infile = open(file, "r")
        lines = infile.readlines()
        if len(lines[2].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (1)", skipping_files)
            continue
        if re.search('[0-9 ]{5,6}', lines[4].strip()) is None and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected postal number (1): " + lines[4].strip(), skipping_files)
            continue
        if len(lines[4].strip()) == 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (1)", skipping_files)
            continue
        if len(lines[8].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (2)", skipping_files)
            continue
        if len(lines[10].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (3)", skipping_files)
            continue
        if len(lines[12].strip()) != 0 and args.fail_on_error:
            skip_file("skipping file " + file + ", unexpected non-empty line (4)", skipping_files)
            continue
        datum = datetime.datetime.strptime("2015" + re.search("([0-9]{4})-[0-9]{2}.txt", file).group(1), "%Y%m%d")
        datum_str = datum.strftime('%Y-%m-%d').strip()
        namn = re.search('Från: (.*)', lines[0]).group(1).strip()
        epost = re.search('E-post: (.*)', lines[1]).group(1).strip()
        if re.search('[^@]+@[^@]+\.[^@]+', epost) is None and args.fail_on_error:
            skip_file("skipping file " + file + ", e-post error", skipping_files)
            continue
        adress = re.search('Gatuadress: (.*)', lines[3].strip()).group(1).strip()
        postalnumber = re.search('Postnummer: (.*)', lines[4].strip()).group(1).strip()
        stad = re.search('Ort: (.*)', lines[5].strip()).group(1).strip()
        lan = re.search('Län: (.*)', lines[6].strip()).group(1).strip()
        land = re.search('Land: (.*)', lines[7].strip()).group(1).strip()
        telefon = re.search('Telefonnummer: (\+*[0-9- ]*)', lines[9]).group(1).strip()
        fodelsedatum = re.search('Födelsedatum: ([0-9]+).*', lines[11].strip()).group(1).strip()
        kon = re.search('Födelsedatum: [0-9]+[ ]*(.*)', lines[11].strip()).group(1).strip()
        meddelande = re.search('Eventuellt meddelande:(.*)', lines[13].strip()).group(1).strip()
        print ";".join([datum_str, namn, epost, postalnumber, adress, stad, lan, land, telefon, fodelsedatum, kon, meddelande])

if len(skipping_files) > 0:
    for skipped in skipping_files:
        print skipped
