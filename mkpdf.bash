#! /bin/bash -e
 
#########################
# 
# Name: mkpdf.bash
#
# Purpose: Compile a LaTeX document to pdf
#
# Usage: ./mkpdf.bash
#
# Revision history: 2013-08-06  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################


function usage {
  echo "Usage: ./mkdpdf.bash <input-latex-file>
Runs latex/dvips/ps2pdf repeatedly to produce a pdf-document
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

author=""
title=""
keywords=""
while (( "$#" )); do 
  case $1 in 
     --help|--hel|--he|--h|-help|-hel|-he|-h)
        usage_and_exit
        ;;
     --author|--autho|--auth|--aut|--au|--a|\
      -author| -autho| -auth| -aut| -au| -a)
        author=$2
        shift 2
        ;;
     --title|--titl|--tit|--ti|--t|\
      -title| -titl| -tit| -ti| -t)
        title=$2
        shift 2
        ;;
     --keywords|--keyword|--keywor|--keywo|--keyw|--key|--ke|--k|\
      -keywords| -keyword| -keywor| -keywo| -keyw| -key| -ke| -k)
        keywords=$2
        shift 2
        ;;
      --)
        set --
        ;;
      *)
        input_file=$1
        shift
        ;;
  esac  
done

exifstring=""
if [ ${#author} -gt  0 ]; then
    exifstring='-Author="${author}"'
fi
if [ ${#title} -gt  0 ]; then
    exifstring=${exifstring}' -Title="${title}"'
fi

if [ ${#keywords} -gt  0 ]; then
    exifstring=${exifstring}' -Keywords="${keywords}"'
fi

rm -f ${input_file%.*}.aux
latex ${input_file%.*}.tex
latex ${input_file%.*}.tex
dvips ${input_file%.*}.dvi
ps2pdf ${input_file%.*}.ps
if [ ${#exifstring} -gt 0 ];then
    eval exiftool -overwrite_original -q $exifstring ${input_file%.*}.pdf
fi
