load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

begin
files_in = (/"CMIP5_Amon_amip_CNRM-AM-PRE6_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-AM-PRE6_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-AM-PRE6_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-AM-PRE6_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-CM5_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-CM5_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-CM5_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_CNRM-CM5_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_EC-EARTH3_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_EC-EARTH3_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_EC-EARTH3_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_EC-EARTH3_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM2-A_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM2-A_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM2-A_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM2-A_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM3-A_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM3-A_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM3-A_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_HadGEM3-A_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5A-MR_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5A-MR_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5A-MR_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5A-MR_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5C-MR_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5C-MR_r1i1p1_T2Ms_ua-1000_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5C-MR_r1i1p1_T2Ms_ua-925_1982-2002.nc",\
             "CMIP5_Amon_amip_IPSL-CM5C-MR_r1i1p1_T2Ms_va-925_1982-2002.nc",\
             "CMIP5_Amon_amip_MPIESM-1-no-embrace_r1i1p1_T2Ms_pr-mmday_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-no-embrace_r1i1p1_T2Ms_ua-1000_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-no-embrace_r1i1p1_T2Ms_ua-925_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-no-embrace_r1i1p1_T2Ms_va-925_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-with-embrace_r1i1p1_T2Ms_pr-mmday_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-with-embrace_r1i1p1_T2Ms_ua-1000_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-with-embrace_r1i1p1_T2Ms_ua-925_1979-1999.nc",\
             "CMIP5_Amon_amip_MPIESM-1-with-embrace_r1i1p1_T2Ms_va-925_1979-1999.nc",\
             "CMIP5_Amon_observation_CMAP_r1i1p1_T2Ms_pr-mmday_1982-2002.nc",\
             "CMIP5_Amon_reanalysis_ERAINT_r1i1p1_T2Ms_ua-1000_1982-2009.nc",\
             "CMIP5_Amon_reanalysis_ERAINT_r1i1p1_T2Ms_ua-925_1982-2009.nc",\
             "CMIP5_Amon_reanalysis_ERAINT_r1i1p1_T2Ms_va-925_1982-2009.nc",\
             "CMIP5_Amon_reanalysis_NCEP_r1i1p1_T2Ms_ua-1000_1982-2009.nc",\
             "CMIP5_Amon_reanalysis_NCEP_r1i1p1_T2Ms_ua-925_1982-2009.nc",\
             "CMIP5_Amon_reanalysis_NCEP_r1i1p1_T2Ms_va-925_1982-2009.nc"/)

no_files =  dimsizes(files_in) - 1
do f_idx = 0, dimsizes(files_in) - 1
    print("Doing " + f_idx + " of " + no_files)
    fin = addfile(files_in(f_idx), "r")
    file_out = "tmp/" + files_in(f_idx)

    if (isfilepresent_general(file_out)) then
        print("Warning: skipping file " + file_out)
        continue
    end if
    
    fout = addfile(file_out, "c")
    filedimdef(fout, "time", -1,True)
    
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
        if (global_attnames(i) .eq. "infile_0000") then
           name = fin@$global_attnames(i)$
           split_name = str_split(name, "/")
           basename = split_name(3)
           newname = "work/climo-lsm/CMIP5/" + basename
           fout@$global_attnames(i)$ = newname
        else
            fout@$global_attnames(i)$ = fin@$global_attnames(i)$
        end if
    end do
end do
end
