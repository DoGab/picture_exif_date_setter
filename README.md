# Picture exif date setter
Script to set datetime exif data on pictures. This script was tested on Ubuntu 20.10 and bash. 

## Requirements
The script requires the exiftool to be installed.

```bash
sudo apt install exiftool
```

## Usage

```
Script to print and set datetimeoriginal EXIF data on pictures in a folder from a datetime as script parameter or read from the filename

    Usage: picture_exif_date_setter.sh
        [ -d | --datetime <datetime> ]   Datetime to set for the pictures. Format 'YYYY:MM:DD HH:MM:SS'
        [ -f | --datefromfilename ]      Read the date from the filename instead of -d parameter. Filename format 'YYYY-MM-DD HH.MM.SS.jpg'
        [ -h | --help ]                  Display help message
        [ -o | --printonly ]             Print only but do not modify files
        [ -p | --path <directory> ]      Directory where to process pictures

    Examples:
        # Print filenames and the datetimeoriginal
        $ bash picture_exif_date_setter.sh -o -p test_pictures/

        # Set datetimeoriginal for pictures in folder test_pictures and increment each picture by 1 minute
        $ bash picture_exif_date_setter.sh -p test_pictures/ -d 2022:02:20 15:10:00

        # Set datetimeoriginal for pictures in folder test_pictures from the filename in format 'YYYY-MM-DD HH.MM.SS.jpg'
        $ bash picture_exif_date_setter.sh -p test_pictures/ -f
```

## Possible improvements

- [ ] Add a verbose option that logs to stdout
- [ ] Option to pass additional exiftool arguments
- [ ] Possibility to define additional datetime formats