#!/bin/bash

# Author: Dominic Gabriel
# Version: 0.0.1
#
# Script requires exiftool to be installed
# Tested on ubuntu 20.10

help() {
    echo "
Script to print and set datetimeoriginal EXIF data on pictures in a folder from a datetime as script parameter or read from the filename

    Usage: ${0##*/}
        [ -d | --datetime <datetime> ]   Datetime to set for the pictures. Format 'YYYY:MM:DD HH:MM:SS'
        [ -f | --datefromfilename ]      Read the date from the filename instead of -d parameter. Filename format 'YYYY-MM-DD HH.MM.SS.jpg'
        [ -h | --help ]                  Display help message
        [ -o | --printonly ]             Print only but do not modify files
        [ -p | --path <directory> ]      Directory where to process pictures

    Examples:
        # Print filenames and the datetimeoriginal
        $ bash picture_exif_date_setter.sh -o -p test_pictures/

        # Set datetimeoriginal for pictures in folder test_pictures and increment each picture by 1 minute
        $ bash picture_exif_date_setter.sh -p test_pictures/ -d "2022:02:20 15:10:00"

        # Set datetimeoriginal for pictures in folder test_pictures from the filename in format 'YYYY-MM-DD HH.MM.SS.jpg'
        $ bash picture_exif_date_setter.sh -p test_pictures/ -f
"
    exit 0
}

SHORT=d:,f,h,o,p:
LONG=datetime:,datefromfilename,help,printonly,path:
OPTS=$(getopt -a -n picture --options $SHORT --longoptions $LONG -- "$@")

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
  exit 0
fi

eval set -- "$OPTS"

while :
do
  case "$1" in
    -d | --datetime)
      datetime="$2"
      shift 2
      ;;
    -f | --datefromfilename)
      datefromfilename=true
      shift 1
      ;;
    -h | --help)
      help
      exit 0
      ;;
    -o | --printonly)
      printonly=true
      shift 1
      ;;
    -p | --path)
      dir="$2"
      shift 2
      ;;
    --)
      shift;
      break
      ;;
    *)
      echo "Unexpected option: $1"
      help
      ;;
  esac
done

check_dir_set() {
  if [ -z ${dir+x} ]; then
    echo "Error: Path was not provided. Please set a path"
    help
    exit 0
  fi
}


check_datetime_set() {
  if [ -z ${datetime+x} ]; then
    echo "Error: Datetime was not provided. Please set a datetime"
    help
    exit 0
  fi
}


get_absolute_dir() {
  absolutedir=$(readlink -f $dir)
  echo "Picture path: $absolutedir"
}


read_datetime_filename() {
  # format: YYYY-MM-DD HH.MM.SS.jpg
  filedatetime=$1
  # format: YYYY:MM:DD
  filedate=$(echo $filedatetime | awk '{split($0,a," "); print a[1]}' | sed 's/-/:/g')
  # format: HH:MM:SS
  filetime=$(echo $filedatetime | awk '{split($0,a," "); print a[2]}' | awk -F '.' '{print $1":"$2":"$3}')
}


set_all_date_from_arg() {
  check_datetime_set
  # Set datetime for all pictures in path. Format YYYY:MM:DD HH:MM:SS
  exiftool -overwrite_original -P -datetimeoriginal="$datetime" "$absolutedir"
  # Increase datetime by 1 minute
  exiftool -overwrite_original -P '-datetimeoriginal+<0:$filesequence' "$absolutedir"
}


set_all_date_from_filename() {
  if [ "$datefromfilename" = true ]; then
    set_date_time_from_filename
    exit 0
  fi
}

set_date_time_from_filename() {
  find "$absolutedir" -maxdepth 1 \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -print0 | while read -r -d $'\0' file; do
    filename="${file##*/}"
    read_datetime_filename "$filename"
    exiftool -overwrite_original -P -datetimeoriginal="$filedate $filetime" "$file"
  done
}


print_all_date_time() {
  exiftool -p '$filename | $dateTimeOriginal' -q -f "$absolutedir"
}


print_only() {
  if [ "$printonly" = true ]; then
    print_all_date_time
    exit 0
  fi
}


check_dir_set
get_absolute_dir
print_only
set_all_date_from_filename
set_all_date_from_arg
