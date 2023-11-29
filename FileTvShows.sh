#!/bin/bash

if [[ $# != 2 ]]; then
	echo "Usage $0 <source directory> <destination directory>"
	echo "Destination directory should not include the show directory."
	echo "Show directories will be created if needed."
	exit 1
fi

source=$1
destination=$2

if [[ ! -d $source ]]; then
	echo "Source directory $source does not exist"
	exit 2
fi

if [[ ! -d $destination ]]; then
	echo "Destination directory $destination does not exist"
	exit 2
fi

echo Filing $source in $destination

files=`find "$source" -name "*mkv" -not -path '*/.*'`

# deal with spaces in filenames
IFS=$(echo -en "\n\b")
for filein in $files; do
	filename=`basename $filein`

	if [[ `expr match "$filename" '.*[sS][0-9][0-9]'` -eq 0 ]]; then
		echo Unable to extract showname from $filename -- skipping
	else
		showname=${filename%[.,\ ][s,S][0-9][0-9]*}
		#Fix filenames
		#Code cribbed from tvtorrentorganizer / tvtorrentorganizer on github
		showname=${showname//./ } #Change all . to spaces
		showname=${showname//-/ } #Change all - to spaces
		showname=${showname//_/ } #Change all _ to spaces
		#Capitalize the first letter of each word in the show name
		#This is not perfect because it doesn't account for acronyms like US or UK
		showname=$(echo $showname | tr '[A-Z]' '[a-z]' | sed 's/\(^\| \)\([a-z]\)/\1\u\2/g')

		destinationDirectory="$destination/$showname"

		if [[ ! -d $destinationDirectory ]]; then
			echo Creating $destinationDirectory
			mkdir "$destinationDirectory"
			if [[ $? -ne 0 ]]; then
				echo mkdir $destinationDirectory failed exiting
				exit 3
			fi
		fi
	
		echo Moving $filein to $destinationDirectory
		mv "$filein" "$destinationDirectory" 
		if [[ $? -ne 0 ]]; then
			echo Moving $filein to $destinationDirectory failed
			exit 4
		fi
	fi
done
