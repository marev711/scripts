#! /home/sm_maeva/scripts/nclsh
; Script to replace 2D lat/lon coordinates with 1D ditto,
; NB: This should only be done under the assumption that
; the 2D coordinates can be equivalently described by
; 1D coordinates.
;
; Usage:
;   .//netcdf-2d-latlon-to-1d-latlon.ncl -file_in=<input-file> -out_dir=<output-dir>

load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

undef("print_usage")
procedure print_usage()
begin
   print("")
   print("Usage: ")
   print("     ./netcdf-2d-latlon-to-1d-latlon.ncl -file_in=<input-file> -out_dir=<output-dir>")
end

undef("print_usage_and_exit")
procedure print_usage_and_exit()
begin
    print_usage()
    status_exit(0)
end

if (isdefined("h")) then
    if (h .eq. True) then
        print_usage_and_exit()
    end if
end if

if (isdefined("help")) then
    if (help .eq. True) then
        print_usage_and_exit()
    end if
end if

if (.not. isdefined("file_in")) then
    print_usage_and_exit()
end if

if (.not. isdefined("out_dir")) then
    print_usage_and_exit()
end if


fin = addfile(file_in, "r")
file_in_fullpath = str_split(file_in, "/")
file_in_base = file_in_fullpath(dimsizes(file_in_fullpath) - 1)


; Output file
file_out = out_dir + "/" + file_in_base
if (isfilepresent_general(file_out)) then
    print("")
    print("Output file: " + file_out + " already exists, aborting...")
    status_exit(1)
end if

file_in_array = str_split(file_in_base, "_")
variable_name = file_in_array(0)

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

       ;; Check if 2D lat/lon dimension is name "i"/"j" or "x"/"y"
       if (any("i" .eq. varnames)) then
           x_coord_name = "i"
       end if
       if (any("j" .eq. varnames)) then
           y_coord_name = "j"
       end if
       if (any("x" .eq. varnames)) then
           x_coord_name = "x"
       end if
       if (any("y" .eq. varnames)) then
           y_coord_name = "y"
       end if

       ;; Replace with 1D dims
       lat_idx = ind(varnames .eq. y_coord_name)
       lon_idx = ind(varnames .eq. x_coord_name)
       tmp!lat_idx = "lat"
       delete(tmp&lat)
       tmp&lat = lat
       tmp!lon_idx = "lon"
       delete(tmp&lon)
       tmp&lon = lon
    end if
    fout->$fvarnames(idx)$ = tmp
end do

; Copy all global attributes in file
global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do
