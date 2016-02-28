#! /bin/bash -
 
#########################
# 
# Name: ./postimage.bash
#
# Purpose:Post image from command line to http://postimg.org/ and echo URL
#
# Usage: .//home/sm_maeva/scripts/postimage.bash
#
# Revision history: 2016-02-27  --  Script created, Martin Evaldsson, Rossby Centre
#
# Contact persons:  martin.evaldsson@smhi.se
#
########################

program=$0

function exit_on_error()
{
    mail -s "${program} failed..." martin.evaldsson@smhi.se << EOMAIL
    See $1/$2
EOMAIL
}

function usage {
 echo "Usage: ./postimage.bash -h <path>
  -h      display this text
  <path>  path to image to upload

  Upload image at <path> to postimg.org and echo URL
" 1>&2 
}

function usage_and_exit {
  exit_code=${1:-0}
  usage
  exit $exit_code
}

# Default behaviour without any arguments
if [ $# -eq 0 ]; then
  usage_and_exit 0
fi

while getopts "h" opt; do
  case $opt in
    h)
      usage_and_exit 0
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage_and_exit 1
      ;;
  esac
done

if [ $# -gt 1 ]; then
  echo "Wrong number of arguments" 2>&1
  usage_and_exit 1
fi

image=$1
if [ ! -f $image ]
then
    echo "Image $image not found" 1>&2
    usage_and_exit 1
fi

# Postimage
rm -f postimage.html
curl -Ls -F "upload[]=@${image}" -F "adult=no" http://postimage.org/ > postimage.html 2>&1 
cat postimage.html | grep "href='http:\/\/postimg.org\/image\/" | sed "s%.*href='\(http:\/\/postimg.org\/image\/[a-z0-9]*\)\/.*%\1%"

