load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

newline = str_get_nl()

f = addfile(target_file, "w")

if (isatt(f, "history")) then
    history = datestamp + ": " + text_to_add + newline + f@history
else
    history = datestamp + ": " + text_to_add
end if
f@history = history
