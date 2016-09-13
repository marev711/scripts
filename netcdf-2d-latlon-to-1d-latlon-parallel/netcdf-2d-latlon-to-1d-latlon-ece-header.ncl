#! /home/sm_maeva/scripts/nclsh
; Script to replace 2D lat/lon coordinates with 1D ditto,
; NB: This should only be done under the assumption that
; the 2D coordinates can be equivalently described by
; 1D coordinates.
;
; Usage:
;   .//netcdf-2d-latlon-to-1d-latlon.ncl -file_in=<input-file> -out_dir=<output-dir>

load "/home/sm_maeva/scripts/ncl-netcdf-manipulation/ncl-auxiliary.ncl"


