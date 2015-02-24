load "/home/sm_maeva/scripts/ncl-auxiliary.ncl"

file_in = "pr_Amon_EC-EARTH3_improvedStratVertRes1993_S19921101_r1i2p1_199211-199712.nc"
fin = addfile(file_in, "r")

file_out = "test.nc"

if (isfilepresent_general(file_out)) then
    system("rm -f " + file_out)
end if

fout = addfile(file_out, "c")
filedimdef(fout, "time", -1,True)

fvarnames = getfilevarnames(fin)
do idx=0, dimsizes(fvarnames) - 1
    tmp = fin->$fvarnames(idx)$
    fout->$fvarnames(idx)$ = tmp
    delete(tmp)
end do

global_attnames = getvaratts(fin)
do i = 0, dimsizes(global_attnames) - 1 
    fout@$global_attnames(i)$ = fin@$global_attnames(i)$
end do 
