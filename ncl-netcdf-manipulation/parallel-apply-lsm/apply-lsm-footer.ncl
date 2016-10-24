/)
;setfileoption("nc","Format","LargeFile") 

a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc", "r")
lsdata = a->LSMASK

no_files = dimsizes(indata) 
do idx = 0, no_files - 1
    print("Starting with " + idx + " of " + tostring(no_files - 1))
    file_split = str_split(indata(idx), "_")
    variable = file_split(6)
    fin = addfile(infolder + indata(idx), "r")
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
    fout = addfile(outfolder + indata(idx), "c")
    fout->$variable$ = data
    delete(data1D)
    delete(data)
    delete(lsm)
    delete(variable)
end do
