#! /home/sm_maeva/scripts/nclsh
; Script to replace 2D lat/lon coordinates with 1D ditto,
; NB: This should only be done under the assumption that
; the 2D coordinates can be equivalently described by
; 1D coordinates.

load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

fin = addfile(file_in, "r")

; Output file
file_out = out_dir + "/" + file_in
if (isfilepresent_general(file_out)) then
    print("")
    print("Output file: " + file_out + " already exists, aborting...")
    status_exit(1)
end if

file_in_array = str_split(file_in, "_")
variable_name = file_in_array(0)

; Remove output file if present
if (isfilepresent_general(file_out)) then
    system("rm -f " + file_out)
end if

; Make time dimension unlimited
fout = addfile(file_out, "c")
filedimdef(fout, "time", -1,True)

; Extract first lat/lon
tmp = fin->lat
lat = tmp(:, 1)
delete(tmp)
tmp = fin->lon
lon = tmp(1, :)

; Copy all variables in file
fvarnames = getfilevarnames(fin)
do idx=0, dimsizes(fvarnames) - 1
    delete(tmp)
    tmp = fin->$fvarnames(idx)$
    if (fvarnames(idx) .eq. "lat") then
       continue
    end if
    if (fvarnames(idx) .eq. "lon") then
       continue
    end if
    if (fvarnames(idx) .eq. variable_name) then
       varnames = getvardims(tmp)
       lat_idx = ind(varnames .eq. "y")
       lon_idx = ind(varnames .eq. "x")
       tmp!lat_idx = "lat"
       tmp&lat = lat
       tmp!lon_idx = "lon"
       tmp&lon = lon
    end if
    fout->$fvarnames(idx)$ = tmp
end do

; Copy all global attributes in file
global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do
