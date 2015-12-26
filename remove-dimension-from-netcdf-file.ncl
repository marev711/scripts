#! /home/sm_maeva/scripts/nclsh
load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

undef("print_usage")
procedure print_usage()
begin
   print("")
   print("Usage: ")
   print("     ./copy-netcdf-file.ncl -file_in=<input-file> -out_file=<output-file>")
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

if (.not. isdefined("file_out")) then
    print_usage_and_exit()
end if

fin = addfile(file_in, "r")

if (isfilepresent_general(file_out)) then
    system("rm -f " + file_out)
end if

fout = addfile(file_out, "c")
filedimdef(fout, "time", -1,True)

fvarnames = getfilevarnames(fin)
do idx=0, dimsizes(fvarnames) - 1
    tmp = fin->$fvarnames(idx)$
    if (fvarnames(idx) .eq. "lev") then
       plev=tmp
       ;fout->plev = plev
       delete(tmp)
       continue
    else if (fvarnames(idx) .eq. "time") then
        no_operation()
    else if (fvarnames(idx) .eq. "lat") then
        no_operation()
    else if (fvarnames(idx) .eq. "lon") then
        no_operation()
    else
        out=tmp(time|:, lev|1, lat|:, lon|:)
        delete(tmp)
        tmp=out
        delete(out)
    end if
    end if
    end if
    end if
    fout->$fvarnames(idx)$ = tmp
    delete(tmp)
end do

global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do
