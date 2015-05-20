#! /home/sm_maeva/scripts/nclsh
; Script to replace 2D lat/lon coordinates with 1D ditto,
; NB: This should only be done under the assumption that
; the 2D coordinates can be equivalently described by
; 1D coordinates.
;
; Usage:
;   .//netcdf-2d-latlon-to-1d-latlon.ncl -files_in=<input-file> -out_dir=<output-dir>
load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

undef("print_usage")
procedure print_usage()
begin
   print("")
   print("Usage: ")
   print("     ./merge-separate-plev-datasets -files_in=<input-file> -file_out=<output-file>")
end

undef("print_usage_and_exit")
procedure print_usage_and_exit(exit_status[1]:integer)
begin
    print_usage()
    status_exit(exit_status)
end

if (isdefined("h")) then
    if (h .eq. True) then
        print_usage_and_exit(0)
    end if
end if

if (isdefined("help")) then
    if (help .eq. True) then
        print_usage_and_exit(0)
    end if
end if

if (.not. isdefined("files_in")) then
    print_usage_and_exit(1)
end if

if (.not. isdefined("file_out")) then
    print_usage_and_exit(1)
end if


if (fileexists(file_out)) then
    system("rm -f " + file_out)
end if

fout = addfile(file_out, "c")
filedimdef(fout, "time", -1,True)


plevs = dimsizes(files_in)


fin = addfile(files_in(0), "r")

fvarnames = getfilevarnames(fin)
do idx=0, dimsizes(fvarnames) - 1
    tmp = fin->$fvarnames(idx)$
    if (fvarnames(idx) .eq. "lat") then
       no_operation()
    end if
    if (fvarnames(idx) .eq. "lon") then
       no_operation()
    end if
    fout->$fvarnames(idx)$ = tmp
    delete(tmp)
end do

global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do
