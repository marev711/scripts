#! /home/sm_maeva/scripts/nclsh
; Script to merge separate separate files with the same
; variable but on different plevels
;
; Usage:
;   ./merge-separate-plev-datasets -files_in=<input-file> -file_out=<output-file>
;
;   Expects the variables, e.g., ua/va, to be named ua200/v850i
;   etc.. to indicate their plevel
load "/home/sm_maeva/scripts/ncl-netcdf-manipulation/ncl-auxiliary.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"

undef("print_usage")
procedure print_usage()
begin
   print("")
   print("Usage: ")
   print("     ./cosp-plot [-h] -infile=<input-file>")
   print("")
   print("     Reads CMORized input file 'infile' and creates a plot")
end

undef("print_usage_and_exit")
procedure print_usage_and_exit(exit_status[1]:integer)
begin
    print_usage()
    status_exit(exit_status)
end

begin
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

    if (.not. isdefined("infile")) then
        print("")
        print(" *EE* 'infile' not defined")
        print_usage_and_exit(0)
    end if

;-;    if (.not. isdefined("outfile")) then
;-;        print("'outfile' not defined")
;-;        print_usage_and_exit(0)
;-;    end if

;-;    if (.not. isdefined("date")) then
;-;        print("'date' not defined")
;-;        print_usage_and_exit(0)
;-;    end if

    ifilename = systemfunc("basename " + infile)
    varname = str_get_field(ifilename, 1, "_")
    mip = str_get_field(ifilename, 2, "_")

    fhandle = addfile(infile, "r")
    variable = fhandle->$varname$
    lat = fhandle->lat
    lon = fhandle->lon
    time = fhandle->time
    cdtime = cd_calendar(time, 0)
    months = cdtime(:, 1)
    days = cdtime(:, 2)
    if (mip .eq. "cfMon") then
       time_ind = ind(months .gt. 0)
       time_fmt = "%Y%N"
       title_pre = "Monthly "
       subfolder = "monthly"
    else if (mip .eq. "cfDay") then
       time_ind = ind(days .eq. 15)
       time_fmt = "%Y%N%D"
       title_pre = "Daily "
       subfolder = "daily"
    end if
    end if
    data = variable(time_ind, :, :)
    res = True
    res@cnFillOn = True
    res@gsnAddCyclic = False
    res@sfYArray = lat
    res@sfXArray = lon

    output_type = "png"
    output_type@wkWidth = 2000
    output_type@wkHeight = 2000
    long_name = str_sub_str(variable@long_name," ", "_")
    sname = variable@standard_name
    outdir = "plots/" + sname + "/" + subfolder
    system("mkdir -p " + outdir)

    do i=0, dimsizes(time_ind) - 1
        t_ind = time_ind(i)
        date_str = cd_string(time(t_ind), time_fmt)
        figure_name = outdir + "/" + date_str + "_" + long_name + ".png"
        res@tiMainString = title_pre + date_str
        res@gsnRightString = "units: " + variable@units
        res@gsnLeftString = variable@long_name + " (" + sname + ")"
        wks = gsn_open_wks(output_type, figure_name)
        contour = gsn_csm_contour_map(wks, variable(t_ind, :, :), res)
    end do
end
