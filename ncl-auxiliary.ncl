load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("insert_history_attribute")
procedure insert_history_attribute(target_file [1] : string,
                                  text_to_add [1] : string)
local newline, history, f
begin
    newline = str_get_nl()
    
    f = addfile(target_file, "w")
    datestamp = systemfunc("date -uR") 
    if (isatt(f, "history")) then
        history = datestamp + ": " + text_to_add + newline + f@history
    else
        history = datestamp + ": " + text_to_add
    end if
    f@history = history
end

;undef("insert_history_attribute")
;procedure insert_history_attribute(target_var,
;                                  text_to_add [1] : string)
;local newline, history
;begin
;    newline = str_get_nl()
;    
;    datestamp = systemfunc("date -uR") 
;    if (isatt(target_var, "history")) then
;        history = datestamp + ": " + text_to_add + newline + target_var@history
;    else
;        history = datestamp + ": " + text_to_add
;    end if
;printVarSummary(target_var)
;    target_var@history = history
;end
