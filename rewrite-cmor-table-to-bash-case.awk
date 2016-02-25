#! /bin/bash -
 
#########################
# 
# Name: rewrite-to-bash-case.bash
#
# Purpose: Rewrite CMIP5-tables to bash case selection
#
# Usage: ./rewrite-to-bash-case.bash
#
# Revision history: 2016-02-25  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################
function ceil(x){return x%1 ? int(x)+1 : x}
function floor(x){return x%1 ? int(x) : x}

function repeat( str, n,    rep, i )
{
    for( ; i<n; i++ )
        rep = rep str   
    return rep
}

function pre_ws( str, maxws )
{
    prews=floor(maxws/2)
    str_ws = repeat(" ", prews, i, ii)
    return str_ws
}

function post_ws( str, maxws )
{
    postws=no_ws - length(str)-3
    str_ws = repeat(" ", postws, i, ii)
    return str_ws
}

BEGIN {
  newvar="none"
  no_ws=20
  ws=repeat(" ", no_ws, rep, i)
  print "case"
}

{
    #print newvar"  "$1",  --   "$0
    if ($1 == "variable_entry:")
    {
        if (newvar == "true")
            printf "%s", ";;\n\n"
        prews=pre_ws($2, length(ws))
        postws=post_ws($2, length(ws))
        printf "%s", "  "$2")"postws   
        newvar="true"
    }
    if ($1 == "standard_name:" && newvar=="true")
    {
        printf "%s", "standard_name='"$2"'"   
    }

    attrs[0] = "long_name:"
    attrs[1] = "units:"
    attrs[2] = "cell_methods:"

    for (attr in attrs)
    {
        if ($1 == attrs[attr] && newvar=="true")
        {
            output=substr($0,index($2,$9))
            sub(":[[:space:]]*", "='", output)
            printf "%s", "\n"ws""output"'"
        }
    }
}

END {
  print "\nesac"
}
