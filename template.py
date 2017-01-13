:insert
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import datetime
import os
import pdb
import re
import sys
from argparse import ArgumentParser

# Check command arguments.
description = """NAME
DESCRIPTION OF SCRIPT"""

parser = ArgumentParser(description=description)
parser.add_argument("-a", "--along",
                    dest="along",
                    type=str,
                    nargs='+',
                    required=True,
                    help="ALONG DESCRIPTION")
parser.add_argument("-b", "--blong",
                    action="store_true",
                    dest='oldtime',
                    default=False,
                    help="BLONG DESCRIPTION")
args = parser.parse_args()


# placecursorhere
.
