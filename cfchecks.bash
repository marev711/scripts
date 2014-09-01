#! /bin/bash -
 
#########################
# 
# Name: cfchecks.bash
#
# Purpose: 
#
# Usage: ./cfchecks.bash
#
# Revision history: 2012-12-20  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

LD_LIBRARY_PATH=/software/apps/netcdf/4.2/i1214-hdf5-1.8.9/lib:/usr/lib64 /nobackup/rossby16/sm_maeva/software/python_packages/bin/cfchecks -u /usr/share/udunits/udunits2.xml -s /home/${USER}/scripts/cf-standard-name-table.xml -a /home/${USER}/scripts/area-type-table.xml $*
