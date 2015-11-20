#! /home/sm_maeva/scripts/nclsh
; Script to merge separate separate files with the same
; variable but on different plevels
;
; Usage:
;   ./merge-separate-plev-datasets -files_in=<input-file> -file_out=<output-file>
;
;   Expects the variables, e.g., ua/va, to be named ua200/v850i
;   etc.. to indicate their plevel
load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

undef("print_usage")
procedure print_usage()
begin
   print("")
   print("Usage: ")
   print("     ./merge-separate-plev-datasets -variable_prefix=variable_prefix -files_in=<input-file> -file_out=<output-file>")
   print("")
   print("     Expects the a plev variable to be present though not as a dimension variable")
   print("     -variable_prefix: initial characters used to identify the variable")
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

if (.not. isdefined("variable_prefix")) then
    print_usage_and_exit(1)
end if


if (fileexists(file_out)) then
    system("rm -f " + file_out)
end if

fout = addfile(file_out, "c")
filedimdef(fout, "time", -1,True)


plevs = dimsizes(files_in)


fidx = 0
fin = addfile(files_in(fidx), "r")

fvarnames = getfilevarnames(fin)
do idx=0, dimsizes(fvarnames) - 1
    tmp = fin->$fvarnames(idx)$
    match_idx = str_match_ind(fvarnames(idx), variable_prefix)

    if (.not. ismissing(match_idx)) then
        if (match_idx .eq. 0) then
            plev_var = tmp
            varsizes = dimsizes(tmp)
            plev_var_out = conform_dims((/varsizes(0),\
                                          1,\
                                          varsizes(1),\
                                          varsizes(2)/),\
                                        tmp,\
                                        (/0, 2, 3/))
        else
            fout->$fvarnames(idx)$ = tmp
        end if
    else
        fout->$fvarnames(idx)$ = tmp
    end if
    delete(tmp)
end do
plev_var_out!0 = "time"
plev_var_out!1 = "plev"
plev_var_out!2 = "lat"
plev_var_out!3 = "lon"

global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do

do fidx = 1, dimsizes(files_in) - 1
    delete(fin)
    delete(fvarnames)
    fin = addfile(files_in(fidx), "r")
    fvarnames = getfilevarnames(fin)
    do idx=0, dimsizes(fvarnames) - 1
        match_idx = str_match_ind(fvarnames(idx), variable_prefix)

        if (.not. ismissing(match_idx)) then
            if (match_idx .eq. 0) then
                tmp := fin->$fvarnames(idx)$
                currsize = dimsizes(plev_var_out)
                currsize(1) = currsize(1) + 1
                plev_idx := new(currsize, "float")
                plev_idx(:, 0:currsize(1)-2, :, :) = plev_var_out
                plev_idx(:, currsize(1)-1, :, :) = fin->$fvarnames(idx)$
                plev_var_out := plev_idx

                plevsize = dimsizes(plev_var_out&plev)
                plevsize = plevsize + 1
                plev_coord := new(currsize, "double")
                plev_coord(0:plevsize-2) = plev_var_out&plev
                plev_coord(plevsize-1) = fin->plev
                delete(plev_var_out&plev)
                plev_var_out!1 = "plev"
                plev_var_out&plev = plev_coord
            end if
        else
            no_operation()
        end if
    end do
end do
fout->$variable_prefix$ = plev_var_out
