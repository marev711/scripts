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

undef("isfilepresent_general")
function isfilepresent_general(file_path [1]: string)
;                             return_val [dimsizes(file_path)] :  logical
; Description
;         Wrapper introduced to handle the backwards-incompatitable changes
;         introduced in NCL v6.2.1, see the official announcement for details,
;
; http://www.ncl.ucar.edu/current_release.shtml#BackwardsIncompatibleChanges6.2.1
;
;         This wrapper checks the existance of any path for any NCL version,
;         i.e., pre- and post- version 6.2.1).
; Arguments:
;         @brief isfilepresent(...) work-around for NCL v6.2.1 code changes
;         @param file_path  -  single path as string to check for existence
local ASCII_ZERO,   FILEEXISTS_MIN_VERSION,  file_is_present,\
    ncl_version,  temp_char,               temp_int_1,\
    temp_int_2,   temp_str,                use_fileexists
begin
    ASCII_ZERO = 48  ; Used for char to int single digit conversion
    FILEEXISTS_MIN_VERSION = (/6, 2, 1/)  ;; 'fileexists' only available
                                          ;; in 6.2.1+

    ;; Get NCL version, to determine whether to use 'fileexists' or
    ;; 'isFilePresent'

    ncl_version = (/0, 0, 0/)  ; Start with an undefined value
    temp_str = get_ncl_version()
    temp_char = stringtochar(temp_str)
    ncl_version(0) = chartointeger(temp_char(0))\
                      - ASCII_ZERO  ; Convert ascii to 0-9
    ncl_version(1) = chartointeger(temp_char(2))\
                      - ASCII_ZERO  ; Convert ascii to 0-9
    ncl_version(2) = chartointeger(temp_char(4))\
                      - ASCII_ZERO  ; Convert ascii to 0-9

    ;; Determine whether version is sufficient for use of 'fileexists'
    temp_int_1 = ncl_version(0) * 100\
                 + ncl_version(1) * 10\
                 + ncl_version(2)
    temp_int_2 = FILEEXISTS_MIN_VERSION(0) * 100\
                 + FILEEXISTS_MIN_VERSION(1) * 10\
                 + FILEEXISTS_MIN_VERSION(2)
    use_fileexists = temp_int_1.ge.temp_int_2

    ;; Set default return value
    file_is_present = False

    if (use_fileexists) then  ; Only for version >= 6.2.1
        if (fileexists(file_path)) then
            file_is_present = True
        end if
    else
        if (isfilepresent(file_path)) then  ; Only for version < 6.2.1
            file_is_present = True
        end if
    end if
    return file_is_present
end

undef("noop")
procedure noop()
begin
end

undef("no_operation")
procedure no_operation()
begin
    noop()
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
