#!/bin/bash
# Simple script to find files of a certain type
# located in a specific directory.
# Directory is likely a mounted image.
# Created by Dr. Phil Polstra 

usage()
{
	echo "Usage: $0 [-s searchList] -d directory" >&2
	exit 1
}


# Parse command line parameters
# set values to empty
findList= directory=
while getopts :s:d: opt
do
	case $opt in
	s)	findList=$OPTARG
		;;
	d)	directory=$OPTARG
		;;
	'?')	echo "$0: invalid option -$OPTARG" >&2
		usage
		;;
	esac
done

# create an array from the findList
readarray -d ", " -t findArray <<< $findList

grepString=""
#load up the grepString based on findArray
for (( n=0; n < ${#findArray[*]}; n++))
do
	findArray[n]=$(echo "${findArray[n]}" | xargs) # strip trailing space
	case ${findArray[n]} in
		jpg | jpeg)
			grepString+="JPEG image|"
			;;
		png)
			grepString+="PNG image|"
			;;
		gif)
			grepString+="GIF image|"
			;;
		img | image)
			grepString+="JPEG image|PNG image|GIF image|"
			;;
		pdf)
			grepString+="PDF document|"
			;;
		exe)
			grepString+="executable|"
			;;
		zip)
			grepString+="archive|"
			;;
		ppt | powerpoint)
			grepString+="Composite Document File|PowerPoint|"
			;;
		doc | word)
			grepString+="Composite Document File|Microsoft Word|Microsoft WinWord|"
			;;
		xls | excel)
			grepString+="Composite Document File|Microsoft Excel|"
			;;
		ofc | office)
			grepString+="Composite Document File|PowerPoint|Microsoft Word|Microsoft WinWord|Microsoft Excel|"
			;;
		*)
			echo \'${findArray[n]}\': unknown file type
			exit 1
			;;
	esac	
			
done

#eliminate trailing |
grepString=${grepString%?}

echo "grep string is $grepString"

#did you give me an image file
if [ -z "$directory" ] 
then
	usage
fi


find "$directory" -print0 | while read -d $'\0' file
do
	resp=$(file "$file")
	if (echo $resp | egrep "$grepString" - >/dev/null)
	then
		echo $resp
	fi	
done
