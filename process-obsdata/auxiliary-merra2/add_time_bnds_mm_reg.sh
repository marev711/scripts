# --- time bounds files ----
     file_dw_tmp=${path_out}'time_dw_tmp.nc'
     file_up=${path_out}'time_up.nc'
     file_dw=${path_out}'time_dw.nc'
     file_bnds=${path_out}'time_bnds.nc'
     file_bnds_tmp=${path_out}'tmp_time_bnds.nc'

    # --- remove temporary and output files ------
     [ -f ${file_dw_tmp} ] && rm ${file_dw_tmp}       # remove temporary lower time bound file if exist
     [ -f ${file_dw} ] && rm ${file_dw}               # remove lower time bound file if exist
     [ -f ${file_up} ] && rm ${file_up}               # remove upper time bound file if exist
     [ -f ${file_bnds_tmp} ] && rm ${file_bnds_tmp}   # remove temporary time bound file if exist
     [ -f ${file_bnds} ] && rm ${file_bnds}           # remove time bound file if exist
     [ -f ${file_dw}3 ] && rm ${file_dw}3             # remove temporary lower time bound file if exist
     [ -f ${file_up}3 ] && rm ${file_up}3             # remove temporary lower time bound file if exist

   # ----- fixing time bounds ----
     'ncks' -O -v time,${var_in[$var]} -d lat,0 -d lon,0 -h ${file_out} ${file_dw_tmp}     # down time limit temporary
#     'ncks' -O -v time,${var_in[$var]} -d northing,0 -d easting,0 -h ${file_out} ${file_dw_tmp}     # down time limit temporary

    'ncatted' -a coordinates,${var_in[$var]},d,, -h ${file_dw_tmp}
    'ncatted' -a grid_mapping,${var_in[$var]},d,, -h ${file_dw_tmp}
    'ncatted' -a bounds,time,d,, -h ${file_dw_tmp}

    ${cdo} -shifttime,-14days ${file_dw_tmp} ${file_dw}                                           # lower time limit
    ${cdo} -shifttime,1month ${file_dw} ${file_up}                                                # upper time limit

    'ncks' -O -3 ${file_dw} ${file_dw}3
    'ncks' -O -3 ${file_up} ${file_up}3
    'ncrename' -v time,time_dw -h ${file_dw}3
    'ncrename' -v time,time_up -h ${file_up}3
    'ncks' -O -4 ${file_dw}3 ${file_dw}
    'ncks' -O -4 ${file_up}3 ${file_up}

    'ncks' -v time_dw -h ${file_dw} ${file_bnds_tmp}
    'ncks' -A -v time_up -h ${file_up} ${file_bnds_tmp}

#    'ncap2' -h -O -S $path_meta'time_bnds_monthly.nco' -h $file_bnds_tmp $file_bnds
     'ncap2' -h -O -s 'defdim("bnds",2); time_bnds[$time, bnds]=0.; time_bnds(:, 0)=time_dw; time_bnds(:, 1)=time_up;' -h ${file_bnds_tmp} ${file_bnds}
     'ncks' -A -v time_bnds -h ${file_bnds} ${file_out}
     'ncatted' -a bounds,time,c,c,"time_bnds" -h ${file_out}

  # ---- remove temporary file (time bounds) --------
   [ -f ${file_dw_tmp} ] && rm ${file_dw_tmp}           # remove temporary time bounds file if exist
   [ -f ${file_dw} ] && rm ${file_dw}                   # remove temporary lower time bound file if exist
   [ -f ${file_dw}3 ] && rm ${file_dw}3                 # remove temporary lower time bound file if exist
   [ -f ${file_up} ] && rm ${file_up}                   # remove temporary upper time bound file if exist
   [ -f ${file_up}3 ] && rm ${file_up}3                 # remove temporary lower time bound file if exist
   [ -f ${file_bnds} ] && rm ${file_bnds}               # remove time bound file if exist
   [ -f ${file_bnds_tmp} ] && rm ${file_bnds_tmp}       # remove temporary time bound file if exist
   'ncatted' -a NCO,global,d,, -h ${file_out}
