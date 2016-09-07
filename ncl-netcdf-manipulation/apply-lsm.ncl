#! /home/sm_maeva/scripts/nclsh

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

infolder = "/nobackup/rossby17/sm_maeva/projects/esmval/svn-deliverable-4.x/work/climo-lsm/CMIP5/"
outfolder = "/nobackup/rossby17/sm_maeva/projects/esmval/svn-deliverable-4.x/work/climo-lsm/CMIP5/tmp/"

infiles = (/"CMIP5_Omon_obs_MOHC-HadISST_r1i1p1_T2Ms_ts_1982-2009.nc",\
            "CMIP5_Amon_observation_CMAP_r1i1p1_T2Ms_pr_1982-2009.nc",\
            "CMIP5_Amon_observation_CMAP_r1i1p1_T2Ms_pr-mmday_1982-2009.nc",\
            "CMIP5_Amon_reanalysis_ERAINT_r1i1p1_T3M_va_1982-2009.nc",\
            "CMIP5_Amon_reanalysis_NCEP_r1i1p1_T3M_va_1982-2009.nc",\
            "CMIP5_Amon_reanalysis_NCEP_r1i1p1_T2Ms_ua-1000_1982-2009.nc"/)

;setfileoption("nc","Format","LargeFile") 

a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
lsdata = a->LSMASK

no_files = dimsizes(infiles) 
do idx = 0, no_files - 1
    print("Starting with " + idx + " of " + tostring(no_files - 1))
    file_split = str_split(infiles(idx), "_")
    variable = file_split(6)
    fin = addfile(infolder + infiles(idx), "r")
    data = fin->$variable$
    ; assume data is 3D (time,lat,lon)
    lsm = landsea_mask(lsdata, data&lat, data&lon)

    ; lsm is a 2D array, in order to use it in mask, we must conform it
    ; to the size of the 3D array "data". 
    if (dimsizes(dimsizes(data)) .eq. 3) then
        data = mask(data, conform(data, lsm,(/1,2/)) .ge. 1, False)
    else  ; assume 3D-field (time, plev, lat, lon)
        data = mask(data, conform(data, lsm,(/2,3/)) .ge. 1, False)  ; 3D field (skip plev at 1)
    end if
    data1D = ndtooned(data)
    data1D(ind(ismissing(data1D))) = -999.
    data = onedtond(data1D, dimsizes(data))
    fout = addfile(outfolder + infiles(idx), "c")
    fout->$variable$ = data
    delete(data1D)
    delete(data)
    delete(lsm)
    delete(variable)
end do
