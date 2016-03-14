#!/bin/bash -eu
#SBATCH -N 1
#SBATCH -t 80:00:00

#######################################################################
####                                                               ####
####   MERRA2 files to CMIP5 style netCDF                          ####
####                         CMIP5 format                          ####
####                        montly statistics                      ####
####                                                               ####
#######################################################################


# --------------------
# ---   VARIABLES  ---
# --------------------
#var_in=(pr prCorr)
var_in=(tas ts psl)

# --------------------
# --- SIMULATIONS  ---
# --------------------
run_in=(MERRA2)


#---- FIRST and LAST YEARS ---
fy_in=(1980)   # first year
ly_in=(2015)   # last year


# --- NUMBER OF YEARS in OUTPUT FILES ---
# if sy_in=(0) all years between 'fy' and 'ly' will be in one output file
# sy_in must have the same size as fy_in and ly_in !!!!
#sy_in=(5)
sy_in=(0)

# fluxes
#path_in="/nobackup/rossby17/sm_maeva/Data/Primavera-upload/merra-2/MERRA2/V5.12.4/orig/2016-02-25-flx/"
#path_out="/nobackup/rossby17/sm_maeva/Data/Primavera-upload/merra-2/MERRA2/V5.12.4/input/"

# single levels
path_in="/nobackup/rossby17/sm_maeva/Data/Primavera-upload/merra-2/MERRA2/V5.12.4/orig/2016-02-25-slv/"
path_out="/nobackup/rossby17/sm_maeva/Data/Primavera-upload/merra-2/MERRA2/V5.12.4/input/"

# --------------------
# --- PREPARATION  ---
# --------------------

# --- META INFO ---
path_meta="./auxiliary-merra2/"          # path to meta files
ref_time='1949-12-01,00:00'  # reference time
mm_s=(01 02 03 04 05 06 07 08 09 10 11 12) # months
cdo='cdo -s -L'

freq=mon
table_out=Amon


# --- Number of variables, runs etc..  ---
num_var=${#var_in[@]}
num_run=${#run_in[@]}
num_fy=${#fy_in[@]}
num_ly=${#ly_in[@]}
num_sy=${#sy_in[@]}

# --- check if fy_in, ly_in and sy_in have the same dimension ---
if [ $num_fy -ne $num_ly -o $num_fy -ne $num_sy ]; then
    echo ... fy_in, ly_in and sy_in have different dimensions .... TERMINATED
    exit
fi


# --------------------
# ---  MAIN BLOCK  ---
# --------------------
echo
beg_time="$(date +%s)"

# --- SIMULATION LOOP ---
for ((run=0;run<=num_run-1;run++)); do

    # ---- read simulation info -----
    exp_definition="./auxiliary-merra2/exp_definition_file.txt"
    source $exp_definition

    # --- VARIABLE LOOP ---
    for ((var=0;var<=num_var-1;var++)); do   # variable loop

        # --- read variable info ---
        file_var='./auxiliary-merra2/cmip5_meta.txt'
        source $file_var

        case ${var_in[$var]} in
            tas) merra_name=T2M
                 mask_in='.tavgM_2d_slv_Nx.';;
            t2m) merra_name=T2M
                 mask_in='.tavgM_2d_slv_Nx.';;
            pr)  merra_name=PRECTOT
                 mask_in='.tavgM_2d_flx_Nx.';;
            prCorr) merra_name=PRECTOTCORR
                 mask_in='.tavgM_2d_flx_Nx.';;
            psl) merra_name=SLP
                 mask_in='.tavgM_2d_slv_Nx.';;
            ts) merra_name=TS
                 mask_in='.tavgM_2d_slv_Nx.';;
        esac


        # --- YEAR LOOP (OVER CHUNKS) ---
        for ((nn=0;nn<num_fy;nn++)); do
            fy=${fy_in[$nn]}
            ly=${ly_in[$nn]}
            sy=${sy_in[$nn]}

            year_p=$(($ly - $fy + 1))  # number of years

            # --- number of output files ----
            if [ $sy -eq 0 ]; then
                sy=$year_p
                file_p=1
            else
                file_p=$((year_p/sy))
                if [ $((year_p%sy)) -ne 0 ]; then
                    file_p=$((file_p+1))
                fi
            fi

            # --- OUTPUT FILE LOOP ---
            for ((ff=1;ff<=file_p;ff++)); do

                bft="$(date +%s)"

                # --- first and last year in output file ---
                fy_out=$((fy+(ff-1)*sy)) #  first year in output file
                ly_out=$((fy_out+sy-1))  #  last year in output file

                # --- output and temporary files ---
                file_out=$path_out${var_in[$var]}_$table_out'_'$gcm_name'_'$experiment_id'_'$gcm_version_id'_'$fy_out'-'$ly_out'.nc'
                file_tmp0=$path_out'tmp0_'${var_in[$var]}_$table_out'_'$gcm_name'_'$experiment_id'_'$gcm_version_id'_'$fy_out'-'$ly_out'.nc'

                # --- remove output and temporary files ---
                [ -f $file_out ] && rm $file_out
                [ -f $file_tmp0 ] && rm $file_tmp0


                # --- post-processing info ---
                echo ... VARIABLE NETCDF      ' '... ${var_in[$var]} '|' $standard_name '|' $long_name '|' $units
                echo ... SIMULATION' ... ' ${run_in[$run]}':' $gcm_name '|' $experiment_id '|' $gcm_version_id '|' $fy_out'-'$ly_out '|'
                echo ... OUTPUT FILE ... $file_out
                echo


                # --- YEAR LOOP (WITHIN CHUNKS) ---
                for ((yy=fy_out;yy<=ly_out;yy++)); do

                    # --- MONTH LOOP ---
                    for mm in 0 1 2 3 4 5 6 7 8 9 10 11 ; do

                        # --- input file ---
                        if [ $yy -ge 1979 -a $yy -le 1991 ]; then
                            version='svc_MERRA2_100'
                        fi

                        if [ $yy -ge 1992 -a $yy -le 2000 ]; then
                            version='svc_MERRA2_200'
                        fi

                        if [ $yy -ge 2001 -a $yy -le 2010 ]; then
                            version='svc_MERRA2_300'
                        fi

                        if [ $yy -ge 2011 ]; then
                            version='svc_MERRA2_400'
                        fi

                        file_in=$path_in$version$mask_in$yy${mm_s[$mm]}'.nc4'


                        if [ -f $file_in ]; then
                            echo ... now processing ... $file_in
                            $cdo cat -selname,$merra_name $file_in $file_tmp0
                        else
                            echo ... not exists $file_in
                        fi
                    done  # month loop
                done # year loop (within chunks)


                if [ -f "$file_tmp0" ]; then

                    echo
                    echo
                    echo ... FINALIZING OUTPUT FILE ... $file_out
                    echo


                    # -----------------
                    # --- FIX TIME  ---
                    # -----------------
                    $cdo -setmissval,1.e20 -setreftime,$ref_time -shifttime,14day -setcalendar,standard $file_tmp0 $file_out

                    ncatted -a long_name,time,c,c,"time" \
                            -a bounds,time,c,c,"time_bnds" \
                            -a axis,time,c,c,"T" -h $file_out

                    # ------------------------------
                    # --- HORIZONTAL COORDINATES ---
                    # ------------------------------

                    # --------------------------------
                    # --- -180 to 180 --> 0 to 360 ---
                    # --------------------------------
                    ncap2 -O -h -s ''${var_in[$var]}'='$merra_name'; '${var_in[$var]}'(:,:,0:287)='$merra_name'(:,:,288:575); '${var_in[$var]}'(:,:,288:575)='$merra_name'(:,:,0:287);' $file_out $file_out
                    ncap2 -O -h -s 'lon_old=lon; lon(0:287)=lon_old(288:575); lon(288:575)=lon_old(0:287);  where(lon < 0) lon=lon+360;lon(0) = 0.0;' $file_out $file_out
                    ncks -O -x -v lon_old,$merra_name -h $file_out $file_out


                    # ---------------------------
                    # --- VARIABLE ATTRIBUTES ---
                    # ---------------------------
                    #  ncrename -v $merra_name,${var_in[$var]} -h $file_out
                    ncatted -a grid_name,${var_in[$var]},d,, \
                            -a comments,${var_in[$var]},d,, \
                            -a level_description,${var_in[$var]},d,, \
                            -a time_statistic,${var_in[$var]},d,, \
                            -a standard_name,${var_in[$var]},c,c,"$standard_name" \
                            -a long_name,${var_in[$var]},m,c,"$long_name" \
                            -a units,${var_in[$var]},c,c,"$units" \
                            -a missing_value,${var_in[$var]},c,f,1.e+20 \
                            -a cell_methods,${var_in[$var]},c,c,"mean" -h $file_out


                    # --- ADDING TIME BOUNDS ---
                    file_bnds_mm='./auxiliary-merra2/add_time_bnds_mm_reg.sh'
                    source $file_bnds_mm

                    # --- ADDING 2-m HEIGHT ---
                    case ${var_in[$var]} in
                           tas | tasmin | tasmax)   ncks -A -h -v height 'auxiliary-merra2/height_2m.nc' $file_out;;
                    esac


                    # -------------------------------------
                    # ---  DATES in FILE NAME: YYYYMMDD ---
                    # -------------------------------------
                    num_time=`$cdo ntime $file_out`
                    f_date=`$cdo showdate -seltimestep,1 $file_out`; f_date=${f_date// /}; f_date=${f_date//-/}
                    f_time=`$cdo showtime -seltimestep,1 $file_out`; f_time=${f_time:1:2}
                    l_date=`$cdo showdate -seltimestep,$num_time $file_out`; l_date=${l_date// /}; l_date=${l_date//-/}
                    l_time=`$cdo showtime -seltimestep,$num_time $file_out`; l_time=${l_time:1:2}
                    file_cmip=$path_out${var_in[$var]}_$table_out'_'$gcm_name'_'$experiment_id'_'$gcm_version_id'_'${f_date:0:6}'-'${l_date:0:6}'.nc'
                    mv $file_out $file_cmip

                    # --- GLOBAL ATTRIBUTES ----
                    ncatted -a Conventions,global,m,c,"CF-1.4" -h $file_cmip
                    ncatted -a source,global,c,c,"MERRA2 Reanalysis" -h $file_cmip
                    ncatted -a institution,global,c,c,"GSFC" -h $file_cmip
                    ncatted -a references,global,c,c,"http://gmao.gsfc.nasa.gov/merra/" -h $file_cmip
                    ncatted -a calendar,global,d,, -h $file_cmip
                    ncatted -a history,global,d,, -h $file_cmip
                    ncatted -a CDI,global,d,, -h $file_cmip
                    ncatted -a CDO,global,d,, -h $file_cmip
                    ncatted -a NCO,global,d,, -h $file_cmip


                    [ -f $file_tmp0 ] && rm $file_tmp0


                else
                    echo ... TEMPORARY FILE does not exist $file_tmp0
                fi # if file_out exists

                echo
                echo ---------------------------------------------------------------------------------------------------------------------
                echo

                done  # output file loop
            done  # year loop (over chunks)
    done  # variable loop
done  # simulation loop

end_time="$(date +%s)"
echo ELAPSED TOTAL TIME: "$(expr $end_time - $beg_time)" sec
echo
echo "END"
