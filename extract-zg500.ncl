#! /home/sm_maeva/scripts/nclsh
load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

output_folder = "tmp/"

begin
files_in = (/"zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20380101-20381231.nc"/)

;files_in = (/"zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20380101-20381231.nc",\
;             "zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20390101-20391231.nc",\
;             "zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20400101-20401231.nc",\
;             "zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20410101-20411231.nc",\
;             "zg500_day_MPI-ESM-LR_rcp85_r1i1p1_20420101-20421231.nc"/)


no_files =  dimsizes(files_in) - 1

;; Loop over all files in "file_in"-array
do f_idx = 0, dimsizes(files_in) - 1
    print("Doing " + f_idx + " of " + no_files)
    fin = addfile(files_in(f_idx), "r")
    file_split = str_split(files_in(f_idx), "_")
    file_split(0) = "zg500"
    file_out = output_folder + "/" + str_join(file_split, "_")

    if (isfilepresent_general(file_out)) then
        print("Warning: output file already exists, skipping: " + file_out)
        continue
    end if
    
    fout = addfile(file_out, "c")
    filedimdef(fout, "time", -1,True)
    
    ;; Copy all variable in input file to output file
    fvarnames = getfilevarnames(fin)
    do idx=0, dimsizes(fvarnames) - 1
        tmp = fin->$fvarnames(idx)$
        ;; Special treatment for zg (=extract 50000)
        if (fvarnames(idx) .eq. "zg") then
           tmp2 = tmp({time|:}, {plev|50000}, {lat|:}, {lon|:})
           delete(tmp)
           tmp = tmp2
           delete(tmp2)
           no_operation()
        end if
        fout->$fvarnames(idx)$ = tmp
        delete(tmp)
    end do
    
    ;; Copy all global attributes from input file to output file
    global_attnames = getvaratts(fin)
    do i = 0, dimsizes(global_attnames) - 1
        fout@$global_attnames(i)$ = fin@$global_attnames(i)$
    end do
    delete(global_attnames)
    delete(fvarnames)
end do
end
